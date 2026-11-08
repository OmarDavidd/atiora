import 'package:atiora/core/errors/app_exception.dart';
import 'package:atiora/core/utils/error_handler.dart';
import 'package:atiora/features/books/domain/repositories/notes_repository.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'notes_event.dart';
import 'notes_state.dart';

class NotesBloc extends Bloc<NotesEvent, NotesState> {
  final NotesRepository _repository;

  NotesBloc(this._repository) : super(NotesInitial()) {
    on<LoadNotes>((event, emit) async {
      emit(NotesLoading());
      try {
        final notes = await _repository.getNotesByBook(event.bookId);
        emit(NotesLoaded(notes, event.bookId));
      } catch (e) {
        final message = e is AppException
            ? ErrorHandler.map(e)
            : 'Error al cargar notas';
        emit(NotesError(message, bookId: event.bookId));
      }
    }, transformer: restartable());

    on<AddNote>((event, emit) async {
      final currentBookId = event.note.bookId;
      try {
        await _repository.addNote(event.note);
        emit(NoteAddSuccess());
        add(LoadNotes(currentBookId));
      } catch (e) {
        final message = e is AppException
            ? ErrorHandler.map(e)
            : 'Error al añadir nota';
        final currentNotes = state is NotesLoaded
            ? (state as NotesLoaded).notes
            : <dynamic>[];
        emit(
          NotesError(
            message,
            previousNotes: currentNotes.cast(),
            bookId: currentBookId,
          ),
        );
      }
    }, transformer: restartable());

    on<UpdateNote>((event, emit) async {
      final currentBookId = event.note.bookId;
      try {
        await _repository.updateNote(event.note);
        emit(NoteUpdateSuccess());
        add(LoadNotes(currentBookId));
      } catch (e) {
        final message = e is AppException
            ? ErrorHandler.map(e)
            : 'Error al actualizar nota';
        final currentNotes = state is NotesLoaded
            ? (state as NotesLoaded).notes
            : <dynamic>[];
        emit(
          NotesError(
            message,
            previousNotes: currentNotes.cast(),
            bookId: currentBookId,
          ),
        );
      }
    }, transformer: restartable());

    on<DeleteNote>((event, emit) async {
      final currentBookId = event.bookId;
      try {
        await _repository.deleteNote(event.noteId);
        emit(NoteDeleteSuccess());
        add(LoadNotes(currentBookId));
      } catch (e) {
        final message = e is AppException
            ? ErrorHandler.map(e)
            : 'Error al eliminar nota';
        final currentNotes = state is NotesLoaded
            ? (state as NotesLoaded).notes
            : <dynamic>[];
        emit(
          NotesError(
            message,
            previousNotes: currentNotes.cast(),
            bookId: currentBookId,
          ),
        );
      }
    }, transformer: droppable());

    on<SyncPendingNotes>((event, emit) async {
      try {
        await _repository.processPendingNotesOperations();
        if (state is NotesLoaded) {
          add(LoadNotes((state as NotesLoaded).bookId));
        }
      } catch (_) {}
    });
  }
}
