import 'package:atiora/core/storage/hive_service.dart';
import 'package:atiora/data/models/book_model.dart';

class BooksLocalDataSource {
  final HiveService _hive;

  BooksLocalDataSource(this._hive);

  Future<List<BookModel>> getBooks() async {
    return _hive.getAllBooks();
  }

  Future<BookModel?> getBook(String id) async {
    return _hive.getBook(id);
  }

  Future<void> addBook(BookModel book) async {
    await _hive.saveBook(book);
  }

  Future<void> updateBook(BookModel book) async {
    await _hive.saveBook(book);
  }

  Future<void> deleteBook(String id) async {
    await _hive.deleteBook(id);
  }

  Future<void> clearAll() async {
    await _hive.clearAllBooks();
  }

  Future<void> addBooks(List<BookModel> books) async {
    await _hive.saveAllBooks(books);
  }
}
