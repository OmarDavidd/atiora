import 'package:atiora/data/models/book_model.dart';
import 'package:atiora/features/books/domain/entities/add_book_draft.dart';

abstract class BooksRepository {
  Future<List<BookModel>> getBooks();
  Future<BookModel?> getBook(String id);
  Future<void> addBook(BookModel book);
  Future<void> updateBook(BookModel book);
  Future<void> deleteBook(String id);
  Future<Map<String, dynamic>> loadHomeStats();
  Future<void> processPendingOperations();
  Future<void> updateBookState(
    String bookId,
    String newState, {
    int? currentPage,
    double? rating,
    DateTime? finishedAt,
  });

  Future<void> saveAddBookDraft(String userId, AddBookDraft draft);

  AddBookDraft? getAddBookDraft(String userId);

  Future<void> clearAddBookDraft(String userId);
}
