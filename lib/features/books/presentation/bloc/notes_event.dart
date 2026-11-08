import 'package:atiora/data/models/note_model.dart';

abstract class NotesEvent {}

class LoadNotes extends NotesEvent {
  final String bookId;
  LoadNotes(this.bookId);
}

class AddNote extends NotesEvent {
  final NoteModel note;
  AddNote(this.note);
}

class UpdateNote extends NotesEvent {
  final NoteModel note;
  UpdateNote(this.note);
}

class DeleteNote extends NotesEvent {
  final String noteId;
  final String bookId;
  DeleteNote(this.noteId, this.bookId);
}

class SyncPendingNotes extends NotesEvent {}
