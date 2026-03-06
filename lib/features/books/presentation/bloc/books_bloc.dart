import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:atiora/features/books/domain/repositories/book_repository.dart';
import 'books_event.dart';
import 'books_state.dart';

class BooksBloc extends Bloc<BooksEvent, BooksState> {
  final BooksRepository _repository;

  BooksBloc(this._repository) : super(BooksInitial()) {
    on<LoadBooks>((event, emit) async {
      if (state is BooksLoading) return;
      emit(BooksLoading());
      try {
        final books = await _repository.getBooks();
        emit(BooksLoaded(books));
      } catch (e) {
        debugPrint('❌ getBooks error: $e');
        emit(BooksError("Error al cargar los libros"));
      }
    }, transformer: droppable());

    on<UpdateBookState>((event, emit) async {
      if (state is BooksLoaded) {
        final currentBooks = (state as BooksLoaded).books;
        final updatedBooks = currentBooks.map((book) {
          if (book.id == event.bookId) {
            return book.copyWith(status: event.newState);
          }
          return book;
        }).toList();
        emit(BooksLoaded(updatedBooks));
      }
      try {
        await _repository.updateBookState(event.bookId, event.newState);
        debugPrint('✅ Estado actualizado: ${event.newState}');
        emit(BookStateUpdateSuccess());
      } catch (e) {
        debugPrint('❌ updateBookState error: $e');
        add(LoadBooks());
        emit(BookStateUpdateError('Error al actualizar estado'));
      }
    }, transformer: restartable());
  }
}
