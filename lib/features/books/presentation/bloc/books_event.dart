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
