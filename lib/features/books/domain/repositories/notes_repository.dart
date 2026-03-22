import 'package:atiora/data/models/note_model.dart';

abstract class NotesRepository {
  Future<List<NoteModel>> getNotesByBook(String bookId);
  Future<List<NoteModel>> getRecentNotes({int limit = 5});
  Future<NoteModel?> getNote(String id);
  Future<void> addNote(NoteModel note);
  Future<void> updateNote(NoteModel note);
  Future<void> deleteNote(String id);
  Future<void> processPendingNotesOperations();
}
