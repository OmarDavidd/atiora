import 'package:flutter/foundation.dart';
import 'package:atiora/data/models/book_model.dart';
import 'package:atiora/features/books/data/datasources/books_local_datasource.dart';
import 'package:atiora/features/books/data/datasources/books_remote_datasource.dart';
import 'package:atiora/features/books/domain/repositories/book_repository.dart';

class BooksRepositoryImpl implements BooksRepository {
  final BooksLocalDataSource _local;
  final BooksRemoteDataSource _remote;

  DateTime? _lastSync;

  BooksRepositoryImpl(this._local, this._remote);

  @override
  Future<List<BookModel>> getBooks() async {
    final now = DateTime.now();
    final shouldSync =
        _lastSync == null ||
        now.difference(_lastSync!) > const Duration(minutes: 5);

    if (shouldSync && await _isOnline()) {
      await _syncBooks();
      _lastSync = now;
    }

    return await _local.getBooks();
  }

  @override
  Future<void> addBook(BookModel book) async {
    await _local.addBook(book);
    if (await _isOnline()) {
      try {
        await _remote.addBook(book);
      } catch (e) {
        debugPrint('Remote addBook failed: $e');
      }
    }
  }

  @override
  Future<void> deleteBook(String id) async {
    await _local.deleteBook(id);
    if (await _isOnline()) {
      try {
        await _remote.deleteBook(id);
      } catch (e) {
        debugPrint('Remote deleteBook failed: $e');
      }
    }
  }

  @override
  Future<BookModel?> getBook(String id) async {
    return await _local.getBook(id);
  }

  @override
  Future<void> updateBook(BookModel book) async {
    await _local.updateBook(book);
    if (await _isOnline()) {
      try {
        await _remote.updateBook(book);
      } catch (e) {
        debugPrint('Remote updateBook failed: $e');
      }
    }
  }

  Future<bool> _isOnline() async => true; // TODO: connectivity_plus

  Future<void> _syncBooks() async {
    try {
      final remoteBooks = await _remote.getBooks();
      await _local.clearAll();
      await _local.addBooks(remoteBooks);
    } catch (e) {
      debugPrint('Sync failed: $e');
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
      debugPrint('Fallo actualizar estado: $e');
    }
  }
}
