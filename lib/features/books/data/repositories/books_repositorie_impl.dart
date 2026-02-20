import 'package:atiora/data/models/book_model.dart';
import 'package:atiora/features/books/data/datasources/books_local_datasource.dart';
import 'package:atiora/features/books/data/datasources/books_remote_datasource.dart';
import 'package:atiora/features/books/domain/repositories/book_repository.dart';

class BooksRepositoryImpl implements BooksRepository {
  final BooksLocalDataSource _local;
  final BooksRemoteDataSource _remote;

  BooksRepositoryImpl(this._local, this._remote);

  @override
  Future<List<BookModel>> getBooks() async {
    final books = await _local.getBooks();
    if (await _isOnline()) {
      await _syncBooks();
    }
    return books;
  }

  @override
  Future<void> addBook(BookModel book) async {
    await _local.addBook(book);

    if (await _isOnline()) {
      try {
        await _remote.addBook(book);
      } catch (e) {
        print('Remote sync failed: $e');
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
        print('Remote delete failed: $e');
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
        print('Remote update failed: $e');
      }
    }
  }

  //TODO corregir con una libreria o algo
  Future<bool> _isOnline() async {
    return true;
  }

  Future<void> _syncBooks() async {
    try {
      final remoteBooks = await _remote.getBooks();
      for (var book in remoteBooks) {
        await _local.addBook(book);
      }
    } catch (e) {
      print('Sync failed: $e');
    }
  }
}
