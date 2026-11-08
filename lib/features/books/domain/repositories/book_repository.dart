import 'dart:io';

import 'package:atiora/data/models/book_model.dart';
import 'package:atiora/features/books/domain/entities/add_book_draft.dart';
import 'package:atiora/features/dashboards/presentation/bloc/stats_state.dart';

abstract class BooksRepository {
  Future<List<BookModel>> getBooks({int? page, int pageSize = 20});
  Future<BookModel?> getBook(String id);
  Future<void> addBook(BookModel book);
  Future<void> updateBook(BookModel book);
  Future<void> deleteBook(String id);
  Future<Map<String, dynamic>> loadHomeStats();
  Future<StatsData> loadStats();
  Future<void> processPendingOperations();
  void resetSync();
  void dispose();
  Future<void> updateBookState(
    String bookId,
    String newState, {
    int? currentPage,
    double? rating,
    DateTime? finishedAt,
  });

  Future<void> logReadingSession(
    String bookId,
    int pagesDelta, {
    DateTime? sessionDate,
  });

  Stream<void> get statsChanges;

  Future<void> saveAddBookDraft(String userId, AddBookDraft draft);

  AddBookDraft? getAddBookDraft(String userId);

  Future<void> clearAddBookDraft(String userId);

  Future<String?> uploadCoverImage(String bookId, File imageFile);

  Future<void> deleteCoverImage(String coverUrl);
}
