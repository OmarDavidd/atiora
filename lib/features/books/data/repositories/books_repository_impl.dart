import 'dart:async';
import 'dart:math' as math;

import 'package:atiora/core/errors/app_exception.dart';
import 'package:atiora/core/storage/hive_service.dart';
import 'package:atiora/core/utils/constants.dart';
import 'package:atiora/data/models/book_model.dart';
import 'package:atiora/features/books/data/datasources/books_local_datasource.dart';
import 'package:atiora/features/books/data/datasources/books_remote_datasource.dart';
import 'package:atiora/features/books/domain/entities/add_book_draft.dart';
import 'package:atiora/features/books/domain/repositories/book_repository.dart';
import 'package:atiora/features/dashboards/presentation/bloc/stats_state.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';

class BooksRepositoryImpl implements BooksRepository {
  final BooksLocalDataSource _local;
  final BooksRemoteDataSource _remote;
  final ConnectivityPlatform _connectivity;
  final HiveService _hive;
  final StreamController<void> _statsController =
      StreamController<void>.broadcast();

  DateTime? _lastSync;

  @override
  void resetSync() {
    _lastSync = null;
  }

  @override
  void dispose() {
    _statsController.close();
  }

  BooksRepositoryImpl(
    this._local,
    this._remote, {
    ConnectivityPlatform? connectivity,
    HiveService? hive,
  }) : _connectivity = connectivity ?? ConnectivityPlatform.instance,
       _hive = hive ?? HiveService.instance;

  @override
  Future<List<BookModel>> getBooks({int? page, int pageSize = 20}) async {
    if (_lastSync == null && await _isOnline()) {
      final synced = await _syncBooks();
      if (synced) {
        _lastSync = DateTime.now();
      }
    }

    try {
      await processPendingOperations();
    } catch (_) {}

    try {
      final allBooks = await _local.getBooks();

      if (page == null) {
        return allBooks;
      }

      final start = page * pageSize;
      if (start >= allBooks.length) {
        return [];
      }
      final end = (start + pageSize).clamp(0, allBooks.length);
      return allBooks.sublist(start, end);
    } catch (e, stackTrace) {
      throw AppException.cache(
        'No pudimos leer tus libros',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }

  @override
  Future<void> addBook(BookModel book) async {
    final isOnline = await _isOnline();
    final now = DateTime.now();
    final localBook = book.copyWith(
      pendingSync: !isOnline,
      updatedAt: isOnline ? book.updatedAt : now,
    );
    try {
      await _local.addBook(localBook);
    } catch (e, stackTrace) {
      throw AppException.cache(
        'No pudimos guardar el libro localmente',
        cause: e,
        stackTrace: stackTrace,
      );
    }
    final serialized = localBook.toJson();
    if (isOnline) {
      try {
        await _remote.addBook(book);
      } catch (e, stackTrace) {
        final pendingVersion = localBook.copyWith(
          pendingSync: true,
          updatedAt: DateTime.now(),
        );
        await _local.updateBook(pendingVersion);
        await _queueOperation(
          PendingOperationType.add,
          payload: pendingVersion.toJson(),
        );
        throw AppException.network(
          'Error al sincronizar el libro; guardado offline',
          cause: e,
          stackTrace: stackTrace,
        );
      }
      final syncedVersion = localBook.copyWith(pendingSync: false);
      await _local.updateBook(syncedVersion);
    } else {
      await _queueOperation(PendingOperationType.add, payload: serialized);
      await _local.updateBook(
        localBook.copyWith(pendingSync: true, updatedAt: DateTime.now()),
      );
    }
  }

  @override
  Future<void> deleteBook(String id) async {
    try {
      await _local.deleteBook(id);
    } catch (e, stackTrace) {
      throw AppException.cache(
        'No pudimos eliminar el libro localmente',
        cause: e,
        stackTrace: stackTrace,
      );
    }
    if (await _isOnline()) {
      try {
        await _remote.deleteBook(id);
      } catch (e, stackTrace) {
        await _queueOperation(PendingOperationType.delete, bookId: id);
        throw AppException.network(
          'No se pudo eliminar el libro en la nube; se reintentará',
          cause: e,
          stackTrace: stackTrace,
        );
      }
    } else {
      await _queueOperation(PendingOperationType.delete, bookId: id);
    }
  }

  @override
  Future<BookModel?> getBook(String id) async {
    return await _local.getBook(id);
  }

  @override
  Future<void> updateBook(BookModel book) async {
    final isOnline = await _isOnline();
    final localCopy = isOnline
        ? book.copyWith(pendingSync: false)
        : book.copyWith(pendingSync: true);
    try {
      await _local.updateBook(localCopy);
    } catch (e, stackTrace) {
      throw AppException.cache(
        'No pudimos actualizar el libro localmente',
        cause: e,
        stackTrace: stackTrace,
      );
    }
    final serialized = localCopy.toJson();
    if (isOnline) {
      try {
        await _remote.updateBook(book);
      } catch (e, stackTrace) {
        final pendingVersion = book.copyWith(
          pendingSync: true,
          updatedAt: DateTime.now(),
        );
        await _local.updateBook(pendingVersion);
        await _queueOperation(
          PendingOperationType.update,
          payload: pendingVersion.toJson(),
        );
        throw AppException.network(
          'No se pudo actualizar el libro en la nube; reintentaremos',
          cause: e,
          stackTrace: stackTrace,
        );
      }
      final synced = book.copyWith(
        pendingSync: false,
        updatedAt: DateTime.now(),
      );
      await _local.updateBook(synced);
    } else {
      await _queueOperation(PendingOperationType.update, payload: serialized);
    }
  }

  Future<bool> _isOnline() async {
    final connectivityResults = await _connectivity.checkConnectivity();
    if (connectivityResults.isEmpty) {
      return false;
    }
    return connectivityResults.any(
      (result) => result != ConnectivityResult.none,
    );
  }

  @override
  Future<void> processPendingOperations() async {
    if (!await _isOnline()) return;
    final pending = await _hive.getPendingOperations();
    var statsChanged = false;
    for (final entry in pending) {
      final key = entry.key;
      final op = entry.value;
      final type = op['type'] as String?;
      try {
        switch (type) {
          case PendingOperationType.add:
            final payload = Map<String, dynamic>.from(op['payload'] as Map);
            final book = BookModel.fromJson(payload);
            await _remote.addBook(book);
            await _clearPendingFlag(book.id);
            break;
          case PendingOperationType.update:
            final payload = Map<String, dynamic>.from(op['payload'] as Map);
            final book = BookModel.fromJson(payload);
            await _remote.updateBook(book);
            await _clearPendingFlag(book.id);
            break;
          case PendingOperationType.delete:
            await _remote.deleteBook(op['bookId'] as String);
            break;
          case PendingOperationType.state:
            await _remote.updateBookState(
              op['bookId'] as String,
              op['newState'] as String,
              currentPage: op['currentPage'] as int?,
              rating: (op['rating'] as num?)?.toDouble(),
              finishedAt: op['finishedAt'] != null
                  ? DateTime.parse(op['finishedAt'] as String)
                  : null,
            );
            break;
          case PendingOperationType.readingSession:
            final rawDelta = op['pagesDelta'] ?? op['pagesRead'];
            if (rawDelta is! int) {
              throw StateError('Pending reading session missing delta');
            }
            await _remote.logReadingSession(
              op['bookId'] as String,
              rawDelta,
              sessionDate: op['sessionDate'] != null
                  ? DateTime.parse(op['sessionDate'] as String)
                  : null,
            );
            break;
          default:
            await _hive.removePendingOperation(key);
            continue;
        }
        await _hive.removePendingOperation(key);
        if (type == PendingOperationType.readingSession ||
            type == PendingOperationType.state ||
            type == PendingOperationType.add ||
            type == PendingOperationType.update ||
            type == PendingOperationType.delete) {
          statsChanged = true;
        }
      } catch (_) {
        await _hive.removePendingOperation(key);
      }
    }
    if (statsChanged) {
      _statsController.add(null);
    }
  }

  Future<void> _clearPendingFlag(String bookId) async {
    final local = await _local.getBook(bookId);
    if (local != null && local.pendingSync) {
      await _local.updateBook(
        local.copyWith(pendingSync: false, updatedAt: DateTime.now()),
      );
    }
  }

  Future<bool> _syncBooks() async {
    try {
      final result = await _remote.getBooks(page: 0, pageSize: 1000);
      await _local.clearAll();
      await _local.addBooks(result.books);
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _queueOperation(
    String type, {
    Map<String, dynamic>? payload,
    String? bookId,
    String? newState,
    int? currentPage,
    double? rating,
    DateTime? finishedAt,
    int? pagesDelta,
    DateTime? sessionDate,
  }) async {
    await _hive.enqueuePendingOperation({
      'type': type,
      if (payload != null) 'payload': payload,
      if (bookId != null) 'bookId': bookId,
      if (newState != null) 'newState': newState,
      if (currentPage != null) 'currentPage': currentPage,
      if (rating != null) 'rating': rating,
      if (finishedAt != null) 'finishedAt': finishedAt.toIso8601String(),
      if (pagesDelta != null) 'pagesDelta': pagesDelta,
      if (sessionDate != null) 'sessionDate': sessionDate.toIso8601String(),
    });
  }

  Future<Map<String, dynamic>> _buildLocalStats() async {
    final books = await _local.getBooks();
    if (books.isEmpty) {
      return {
        'pagesThisMonth': 0,
        'booksTouched': 0,
        'booksFinished': 0,
        'streak': 0,
        'averageRating': 0.0,
      };
    }

    int totalRead = 0;
    int booksTouched = 0;
    int booksFinished = 0;
    double ratingSum = 0;
    int ratedCount = 0;

    for (final book in books) {
      final normalizedStatus = book.status.toLowerCase().trim();
      final safePage = math.min(book.currentPage, book.totalPages);
      totalRead += safePage;
      if (book.currentPage > 0 || normalizedStatus != 'pendiente') {
        booksTouched++;
      }
      if (normalizedStatus == 'completado') {
        booksFinished++;
      }
      if (book.rating > 0) {
        ratingSum += book.rating;
        ratedCount++;
      }
    }

    final averageRating = ratedCount == 0 ? 0.0 : ratingSum / ratedCount;

    return {
      'pagesThisMonth': totalRead,
      'booksTouched': booksTouched,
      'booksFinished': booksFinished,
      'streak': 0,
      'averageRating': double.parse(averageRating.toStringAsFixed(1)),
    };
  }

  @override
  Future<Map<String, dynamic>> loadHomeStats() async {
    final fallback = await _buildLocalStats();
    try {
      final remoteStats = await _remote.loadHomeStats();
      return {
        ...fallback,
        ...remoteStats,
        'averageRating':
            remoteStats['averageRating'] ?? fallback['averageRating'],
      };
    } catch (_) {
      return fallback;
    }
  }

  @override
  Future<StatsData> loadStats() async {
    final books = await getBooks();

    final booksByState = <String, int>{};
    final genreCount = <String, int>{};

    for (final book in books) {
      final status = book.status;
      booksByState[status] = (booksByState[status] ?? 0) + 1;

      for (final genre in book.genre) {
        genreCount[genre] = (genreCount[genre] ?? 0) + 1;
      }
    }

    final topGenres = genreCount.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    final monthlyBooks = _calculateMonthlyBooks(books);

    final homeStats = await loadHomeStats();

    final completedBooks = books
        .where((b) => b.status == 'Completado')
        .toList();
    double avgRating = 0;
    if (completedBooks.isNotEmpty) {
      final rated = completedBooks.where((b) => b.rating > 0).toList();
      if (rated.isNotEmpty) {
        avgRating =
            rated.fold<double>(0, (sum, b) => sum + b.rating) / rated.length;
      }
    }

    return StatsData(
      totalBooks: books.length,
      booksReading: booksByState['Leyendo'] ?? 0,
      booksCompleted: booksByState['Completado'] ?? 0,
      booksCompletedThisMonth: homeStats['booksFinished'] ?? 0,
      booksPaused: booksByState['Pausado'] ?? 0,
      booksPending: booksByState['Pendiente'] ?? 0,
      totalNotes: homeStats['totalNotes'] ?? 0,
      notesThisMonth: homeStats['notesThisMonth'] ?? 0,
      averageRating: avgRating,
      pagesThisMonth: homeStats['pagesThisMonth'] ?? 0,
      currentStreak: homeStats['streak'] ?? 0,
      globalStreak: homeStats['globalStreak'] ?? 0,
      booksByState: booksByState,
      booksByMonth: {},
      topGenres: Map.fromEntries(topGenres.take(5)),
      monthlyBooks: monthlyBooks,
      totalPagesRead: homeStats['totalPagesRead'] ?? 0,
      totalBooksRead: homeStats['booksRead'] ?? 0,
      globalAverageRating: homeStats['averageRating'] > 0
          ? (homeStats['averageRating'] as num).toDouble()
          : avgRating,
    );
  }

  List<MonthlyBooks> _calculateMonthlyBooks(List<BookModel> books) {
    final now = DateTime.now();
    final monthNames = [
      'Ene',
      'Feb',
      'Mar',
      'Abr',
      'May',
      'Jun',
      'Jul',
      'Ago',
      'Sep',
      'Oct',
      'Nov',
      'Dic',
    ];

    final monthly = <String, int>{};
    for (int i = 5; i >= 0; i--) {
      final date = DateTime(now.year, now.month - i);
      final key =
          '${monthNames[date.month - 1]} ${date.year.toString().substring(2)}';
      monthly[key] = 0;
    }

    for (final book in books) {
      final created = book.createdAt;
      final key =
          '${monthNames[created.month - 1]} ${created.year.toString().substring(2)}';
      if (monthly.containsKey(key)) {
        monthly[key] = (monthly[key] ?? 0) + 1;
      }
    }

    return monthly.entries
        .map((e) => MonthlyBooks(month: e.key, count: e.value))
        .toList();
  }

  @override
  Future<void> updateBookState(
    String bookId,
    String newState, {
    int? currentPage,
    double? rating,
    DateTime? finishedAt,
  }) async {
    try {
      await _remote.updateBookState(
        bookId,
        newState,
        currentPage: currentPage,
        rating: rating,
        finishedAt: finishedAt,
      );
      final localBook = await _local.getBook(bookId);
      if (localBook != null) {
        await _local.updateBook(
          localBook.copyWith(
            status: newState,
            updatedAt: DateTime.now(),
            currentPage: currentPage ?? localBook.currentPage,
            rating: rating ?? localBook.rating,
            finishedAt: finishedAt ?? localBook.finishedAt,
            pendingSync: false,
          ),
        );
      }
      _statsController.add(null);
    } catch (e) {
      await _queueOperation(
        PendingOperationType.state,
        bookId: bookId,
        newState: newState,
        currentPage: currentPage,
        rating: rating,
        finishedAt: finishedAt,
      );
      throw AppException.network(
        'No pudimos actualizar el estado del libro; se sincronizará luego',
        cause: e,
      );
    }
  }

  @override
  Future<void> logReadingSession(
    String bookId,
    int pagesDelta, {
    DateTime? sessionDate,
  }) async {
    final normalizedDate = sessionDate ?? DateTime.now();
    if (pagesDelta == 0) {
      return;
    }
    try {
      final isOnline = await _isOnline();
      if (isOnline) {
        await _remote.logReadingSession(
          bookId,
          pagesDelta,
          sessionDate: normalizedDate,
        );
      } else {
        await _queueOperation(
          PendingOperationType.readingSession,
          bookId: bookId,
          pagesDelta: pagesDelta,
          sessionDate: normalizedDate,
        );
      }
    } catch (_) {
      await _queueOperation(
        PendingOperationType.readingSession,
        bookId: bookId,
        pagesDelta: pagesDelta,
        sessionDate: normalizedDate,
      );
    } finally {
      _statsController.add(null);
    }
  }

  @override
  Stream<void> get statsChanges => _statsController.stream;

  @override
  Future<void> saveAddBookDraft(String userId, AddBookDraft draft) async {
    await _hive.saveAddBookDraft(userId, draft);
  }

  @override
  AddBookDraft? getAddBookDraft(String userId) {
    return _hive.getAddBookDraft(userId);
  }

  @override
  Future<void> clearAddBookDraft(String userId) async {
    await _hive.clearAddBookDraft(userId);
  }
}
