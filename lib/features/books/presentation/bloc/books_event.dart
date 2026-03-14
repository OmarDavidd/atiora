abstract class BooksEvent {}

class LoadBooks extends BooksEvent {}

class SyncPendingOperations extends BooksEvent {}

class UpdateBookState extends BooksEvent {
  final String bookId;
  final String newState;
  final int? updatedPage;
  final double? rating;
  final DateTime? finishedAt;
  final bool clearFinishedAt;

  UpdateBookState({
    required this.bookId,
    required this.newState,
    this.updatedPage,
    this.rating,
    this.finishedAt,
    this.clearFinishedAt = false,
  });
}

class LogReadingSession extends BooksEvent {
  final String bookId;
  final int pagesDelta;
  final DateTime sessionDate;

  LogReadingSession({
    required this.bookId,
    required this.pagesDelta,
    DateTime? sessionDate,
  }) : sessionDate = sessionDate ?? DateTime.now();
}
