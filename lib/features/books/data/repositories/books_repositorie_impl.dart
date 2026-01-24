import 'package:atiora/data/models/book_model.dart';
import 'package:atiora/features/books/data/datasources/books_local_datasource.dart';
import 'package:atiora/features/books/data/datasources/books_remote_datasource.dart';
import 'package:atiora/features/books/domain/repositories/book_repository.dart';

class BooksRepositoryImpl implements BooksRepository {
  final BooksLocalDataSource _local;
  final BooksRemoteDataSource _remote;
  final String _userId;

  BooksRepositoryImpl(this._local, this._remote, this._userId);

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
      await _remote.addBook(book);
    }
  }

  @override
  Future<void> deleteBook(String id) async {
    await _local.deleteBook(id);
    if (await _isOnline()) {
      await _remote.deleteBook(id);
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
      await _remote.updateBook(book);
    }
  }

  //TODO corregir
  Future<bool> _isOnline() async {
    return true;
  }

  Future<void> _syncBooks() async {
    final books = await _remote.getBooks();
    for (var b in books) {
      await _local.addBook(b);
    }
  }
}
