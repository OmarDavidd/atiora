import 'package:atiora/data/models/book_model.dart';
import 'package:equatable/equatable.dart';
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

class BooksError extends BooksState with EquatableMixin {
  final String message;

  BooksError(this.message);

  @override
  List<Object?> get props => [message];
}

class BookStateUpdateSuccess extends BooksState {}

class BookStateUpdateError extends BooksState with EquatableMixin {
  final String message;
  BookStateUpdateError(this.message);

  @override
  List<Object?> get props => [message];
}

class BookUpdateSuccess extends BooksState {}

class BookUpdateError extends BooksState with EquatableMixin {
  final String message;
  BookUpdateError(this.message);

  @override
  List<Object?> get props => [message];
}

class BookDeleteSuccess extends BooksState {}

class BookDeleteError extends BooksState with EquatableMixin {
  final String message;
  BookDeleteError(this.message);

  @override
  List<Object?> get props => [message];
}
