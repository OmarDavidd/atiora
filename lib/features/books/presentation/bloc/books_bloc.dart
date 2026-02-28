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
  }
}
