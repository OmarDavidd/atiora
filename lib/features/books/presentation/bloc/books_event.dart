abstract class BooksEvent {}

class LoadBooks extends BooksEvent {}

class UpdateBookState extends BooksEvent {
  final String bookId;
  final String newState;

  UpdateBookState({required this.bookId, required this.newState});
}
