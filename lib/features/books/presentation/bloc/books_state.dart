import 'package:atiora/data/models/book_model.dart';

abstract class BooksState {}

class BooksInitial extends BooksState {}

class BooksLoading extends BooksState {}

class BooksLoaded extends BooksState {
  final List<BookModel> books;

  BooksLoaded(this.books);
}

class BooksError extends BooksState {
  final String message;

  BooksError(this.message);
}

class BookStateUpdateSuccess extends BooksState {}

class BookStateUpdateError extends BooksState {
  final String message;
  BookStateUpdateError(this.message);
}
