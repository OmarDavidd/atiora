import 'package:atiora/data/models/book_model.dart';
import 'package:flutter/foundation.dart';

abstract class BooksState {}

class BooksInitial extends BooksState {}

class BooksLoading extends BooksState {}

class BooksLoaded extends BooksState {
  final List<BookModel> books;
  BooksLoaded(this.books);

  BooksLoaded copyWith({List<BookModel>? books}) {
    return BooksLoaded(books ?? this.books);
  }

  @override
  bool operator ==(Object other) => identical(this, other) ||
    other is BooksLoaded && listEquals(other.books, books);

  @override
  int get hashCode => books.hashCode;
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
