import 'package:atiora/data/models/book_model.dart';

abstract class BooksRepository {
  Future<List<BookModel>> getBooks();
  Future<BookModel?> getBook(String id);
  Future<void> addBook(BookModel book);
  Future<void> updateBook(BookModel book);
  Future<void> deleteBook(String id);
  Future<Map<String, dynamic>> loadHomeStats();
  Future<void> updateBookState(
    String bookId,
    String newState, {
    int? currentPage,
    double? rating,
    DateTime? finishedAt,
  });
}
