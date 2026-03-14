import 'package:atiora/data/models/book_model.dart';
import 'package:flutter/foundation.dart';

abstract class BooksState {}

class BooksInitial extends BooksState {}

class BooksLoading extends BooksState {}

class BooksLoaded extends BooksState {
  final List<BookModel> books;
  final bool hasPendingOperations;
  BooksLoaded(this.books, {this.hasPendingOperations = false});

  BooksLoaded copyWith({List<BookModel>? books, bool? hasPendingOperations}) {
    return BooksLoaded(
      books ?? this.books,
      hasPendingOperations: hasPendingOperations ?? this.hasPendingOperations,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BooksLoaded &&
          listEquals(other.books, books) &&
          other.hasPendingOperations == hasPendingOperations;

  @override
  int get hashCode => Object.hash(books, hasPendingOperations);
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
