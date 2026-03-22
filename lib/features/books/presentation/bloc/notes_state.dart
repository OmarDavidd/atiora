import 'package:atiora/data/models/note_model.dart';
import 'package:equatable/equatable.dart';

abstract class NotesState extends Equatable {
  const NotesState();
  @override
  List<Object?> get props => [];
}

class NotesInitial extends NotesState {}

class NotesLoading extends NotesState {}

class NotesLoaded extends NotesState {
  final List<NoteModel> notes;
  final String bookId;

  const NotesLoaded(this.notes, this.bookId);

  @override
  List<Object?> get props => [notes, bookId];
}

class NotesError extends NotesState {
  final String message;
  final List<NoteModel> previousNotes;
  final String bookId;

  const NotesError(
    this.message, {
    this.previousNotes = const [],
    required this.bookId,
  });

  @override
  List<Object?> get props => [message, previousNotes, bookId];
}

class NoteAddSuccess extends NotesState {}

class NoteUpdateSuccess extends NotesState {}

class NoteDeleteSuccess extends NotesState {}
