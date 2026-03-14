import 'package:atiora/core/errors/app_exception.dart';
import 'package:atiora/data/models/book_model.dart';
import 'package:atiora/features/books/data/datasources/books_local_datasource.dart';
import 'package:atiora/features/books/data/datasources/books_remote_datasource.dart';
import 'package:atiora/features/books/domain/repositories/book_repository.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter/foundation.dart';

class BooksRepositoryImpl implements BooksRepository {
  final BooksLocalDataSource _local;
  final BooksRemoteDataSource _remote;
  final ConnectivityPlatform _connectivity;

  DateTime? _lastSync;

  BooksRepositoryImpl(
    this._local,
    this._remote, {
    ConnectivityPlatform? connectivity,
  }) : _connectivity = connectivity ?? ConnectivityPlatform.instance;

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
    try {
      await _local.addBook(book);
    } catch (e, stackTrace) {
      throw AppException.cache(
        'No pudimos guardar el libro localmente',
        cause: e,
        stackTrace: stackTrace,
      );
    }
    if (await _isOnline()) {
      try {
        await _remote.addBook(book);
      } catch (e, stackTrace) {
        debugPrint('BooksRepositoryImpl.addBook remote sync failed: $e');
        throw AppException.network(
          'Error al sincronizar el libro',
          cause: e,
          stackTrace: stackTrace,
        );
      }
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
        throw AppException.network(
          'No se pudo eliminar el libro en la nube',
          cause: e,
          stackTrace: stackTrace,
        );
      }
    }
  }

  @override
  Future<BookModel?> getBook(String id) async {
    return await _local.getBook(id);
  }

  @override
  Future<void> updateBook(BookModel book) async {
    try {
      await _local.updateBook(book);
    } catch (e, stackTrace) {
      throw AppException.cache(
        'No pudimos actualizar el libro localmente',
        cause: e,
        stackTrace: stackTrace,
      );
    }
    if (await _isOnline()) {
      try {
        await _remote.updateBook(book);
      } catch (e, stackTrace) {
        debugPrint('BooksRepositoryImpl.updateBook remote sync failed: $e');
        throw AppException.network(
          'No se pudo actualizar el libro en la nube',
          cause: e,
          stackTrace: stackTrace,
        );
      }
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
          ),
        );
      }
    } catch (e) {
      debugPrint('BooksRepositoryImpl.updateBookState local update failed: $e');
      throw AppException.network(
        'No pudimos actualizar el estado del libro',
        cause: e,
      );
    }
  }
}
