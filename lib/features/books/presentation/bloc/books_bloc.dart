import 'package:atiora/core/errors/app_exception.dart';
import 'package:atiora/core/storage/hive_service.dart';
import 'package:atiora/core/utils/error_handler.dart';
import 'package:atiora/data/models/book_model.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:atiora/features/books/domain/repositories/book_repository.dart';
import 'books_event.dart';
import 'books_state.dart';

class BooksBloc extends Bloc<BooksEvent, BooksState> {
  final BooksRepository _repository;
  final HiveService _hive;

  BooksBloc(this._repository, {HiveService? hive})
    : _hive = hive ?? HiveService.instance,
      super(BooksInitial()) {
    on<LoadBooks>((event, emit) async {
      final currentState = state;
      if (currentState is BooksLoaded) {
        emit(BooksLoading());
      } else if (currentState is! BooksLoading) {
        emit(BooksLoading());
      }

      try {
        final books = await _repository.getBooks();
        final pendingOps = (await _hive.getPendingOperations()).isNotEmpty;
        emit(BooksLoaded(books, hasPendingOperations: pendingOps));
      } catch (e) {
        final message = e is AppException
            ? ErrorHandler.map(e)
            : 'Error al cargar los libros';
        emit(BooksError(message));
      }
    }, transformer: restartable());

    on<SyncPendingOperations>((event, emit) async {
      try {
        await _repository.processPendingOperations();
      } catch (_) {}
      add(LoadBooks());
    });

    on<UpdateBookState>((event, emit) async {
      final normalizedState = event.newState.toLowerCase();
      final shouldComplete = normalizedState == 'completado';
      final revertingToReading = normalizedState == 'leyendo';
      final completionTimestamp = shouldComplete
          ? (event.finishedAt ?? DateTime.now())
          : null;

      BookModel? updatedBook;
      BookModel? originalBook;

      if (state is BooksLoaded) {
        final books = List<BookModel>.from((state as BooksLoaded).books);
        final idx = books.indexWhere((b) => b.id == event.bookId);
        if (idx != -1) {
          originalBook = books[idx];
          final nextCurrentPage = shouldComplete
              ? originalBook.totalPages
              : (event.updatedPage ?? originalBook.currentPage);
          final nextFinishedAt = shouldComplete
              ? completionTimestamp
              : ((revertingToReading || event.clearFinishedAt)
                    ? null
                    : event.finishedAt ?? originalBook.finishedAt);
          final nextRating = event.rating ?? originalBook.rating;

          final nextBook = originalBook.copyWith(
            status: event.newState,
            currentPage: nextCurrentPage,
            rating: nextRating,
            finishedAt: nextFinishedAt,
          );

          books[idx] = nextBook;
          updatedBook = nextBook;
        }
        emit(
          BooksLoaded(
            books,
            hasPendingOperations: (state as BooksLoaded).hasPendingOperations,
          ),
        );
      }

      final repoCurrentPage =
          updatedBook?.currentPage ??
          (shouldComplete
              ? originalBook?.totalPages ?? event.updatedPage
              : event.updatedPage ?? originalBook?.currentPage);
      final repoFinishedAt =
          updatedBook?.finishedAt ??
          (shouldComplete
              ? completionTimestamp
              : ((revertingToReading || event.clearFinishedAt)
                    ? null
                    : event.finishedAt ?? originalBook?.finishedAt));

      try {
        await _repository.updateBookState(
          event.bookId,
          event.newState,
          currentPage: repoCurrentPage,
          rating: event.rating,
          finishedAt: repoFinishedAt,
        );
      } catch (e) {
        final message = e is AppException
            ? ErrorHandler.map(e)
            : 'No pudimos actualizar el estado del libro';
        emit(BookStateUpdateError(message));
        add(LoadBooks());
        return;
      }
      add(LoadBooks());
    }, transformer: restartable());

    on<LogReadingSession>((event, emit) async {
      if (event.pagesDelta == 0) {
        return;
      }
      try {
        await _repository.logReadingSession(
          event.bookId,
          event.pagesDelta,
          sessionDate: event.sessionDate,
        );
      } catch (_) {
        emit(BookStateUpdateError('No pudimos registrar tu sesión de lectura'));
      }
    });

    on<UpdateBookEvent>((event, emit) async {
      try {
        await _repository.updateBook(event.book);
        emit(BookUpdateSuccess());
        add(LoadBooks());
      } catch (e) {
        final message = e is AppException
            ? ErrorHandler.map(e)
            : 'No pudimos actualizar el libro';
        emit(BookUpdateError(message));
      }
    }, transformer: restartable());

    on<DeleteBookEvent>((event, emit) async {
      try {
        await _repository.deleteBook(event.bookId);
        emit(BookDeleteSuccess());
        add(LoadBooks());
      } catch (e) {
        final message = e is AppException
            ? ErrorHandler.map(e)
            : 'No pudimos eliminar el libro';
        emit(BookDeleteError(message));
      }
    }, transformer: droppable());
  }
}
