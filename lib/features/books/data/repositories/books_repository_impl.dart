import 'package:atiora/core/errors/app_exception.dart';
import 'package:atiora/core/storage/hive_service.dart';
import 'package:atiora/data/models/book_model.dart';
import 'package:atiora/features/books/data/datasources/books_local_datasource.dart';
import 'package:atiora/features/books/data/datasources/books_remote_datasource.dart';
import 'package:atiora/features/books/domain/entities/add_book_draft.dart';
import 'package:atiora/features/books/domain/repositories/book_repository.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter/foundation.dart';

class BooksRepositoryImpl implements BooksRepository {
  final BooksLocalDataSource _local;
  final BooksRemoteDataSource _remote;
  final ConnectivityPlatform _connectivity;
  final HiveService _hive;

  DateTime? _lastSync;

  BooksRepositoryImpl(
    this._local,
    this._remote, {
    ConnectivityPlatform? connectivity,
    HiveService? hive,
  }) : _connectivity = connectivity ?? ConnectivityPlatform.instance,
       _hive = hive ?? HiveService.instance;

  @override
  Future<List<BookModel>> getBooks() async {
    final now = DateTime.now();
    final shouldSync =
        _lastSync == null ||
        now.difference(_lastSync!) > const Duration(minutes: 5);

    if (shouldSync && await _isOnline()) {
      final synced = await _syncBooks();
      if (synced) {
        _lastSync = now;
      }
    }
    await processPendingOperations();

    try {
      return await _local.getBooks();
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
        debugPrint('BooksRepositoryImpl.addBook remote sync failed: $e');
        final pendingVersion = localBook.copyWith(
          pendingSync: true,
          updatedAt: DateTime.now(),
        );
        await _local.updateBook(pendingVersion);
        await _queueOperation('add', payload: pendingVersion.toJson());
        throw AppException.network(
          'Error al sincronizar el libro; guardado offline',
          cause: e,
          stackTrace: stackTrace,
        );
      }
      final syncedVersion = localBook.copyWith(pendingSync: false);
      await _local.updateBook(syncedVersion);
    } else {
      await _queueOperation('add', payload: serialized);
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
        debugPrint('BooksRepositoryImpl.deleteBook remote sync failed: $e');
        await _queueOperation('delete', bookId: id);
        throw AppException.network(
          'No se pudo eliminar el libro en la nube; se reintentará',
          cause: e,
          stackTrace: stackTrace,
        );
      }
    } else {
      await _queueOperation('delete', bookId: id);
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
        debugPrint('BooksRepositoryImpl.updateBook remote sync failed: $e');
        final pendingVersion = book.copyWith(
          pendingSync: true,
          updatedAt: DateTime.now(),
        );
        await _local.updateBook(pendingVersion);
        await _queueOperation('update', payload: pendingVersion.toJson());
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
      await _queueOperation('update', payload: serialized);
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
    final pending = _hive.getPendingOperations();
    for (final entry in pending) {
      final key = entry.key;
      final op = entry.value;
      final type = op['type'] as String?;
      try {
        switch (type) {
          case 'add':
            final payload = Map<String, dynamic>.from(op['payload'] as Map);
            final book = BookModel.fromJson(payload);
            await _remote.addBook(book);
            await _clearPendingFlag(book.id);
            break;
          case 'update':
            final payload = Map<String, dynamic>.from(op['payload'] as Map);
            final book = BookModel.fromJson(payload);
            await _remote.updateBook(book);
            await _clearPendingFlag(book.id);
            break;
          case 'delete':
            await _remote.deleteBook(op['bookId'] as String);
            break;
          case 'state':
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
          default:
            debugPrint('Unknown pending op type: $type');
        }
        await _hive.removePendingOperation(key);
      } catch (e) {
        debugPrint('Failed to process pending op $type: $e');
      }
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
      final remoteBooks = await _remote.getBooks();
      await _local.clearAll();
      await _local.addBooks(remoteBooks);
      return true;
    } catch (e) {
      debugPrint('BooksRepositoryImpl._syncBooks failed: $e');
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
  }) async {
    await _hive.enqueuePendingOperation({
      'type': type,
      if (payload != null) 'payload': payload,
      if (bookId != null) 'bookId': bookId,
      if (newState != null) 'newState': newState,
      if (currentPage != null) 'currentPage': currentPage,
      if (rating != null) 'rating': rating,
      if (finishedAt != null) 'finishedAt': finishedAt.toIso8601String(),
    });
  }

  @override
  Future<Map<String, dynamic>> loadHomeStats() async {
    return await _remote.loadHomeStats();
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
    } catch (e) {
      debugPrint('BooksRepositoryImpl.updateBookState local update failed: $e');
      await _queueOperation(
        'state',
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
