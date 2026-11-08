import 'package:atiora/core/storage/hive_service.dart';
import 'package:atiora/data/models/note_model.dart';

class NotesLocalDataSource {
  final HiveService _hive;

  NotesLocalDataSource(this._hive);

  Future<List<NoteModel>> getNotesByBook(String bookId) async {
    final allNotes = await _hive.getAllNotes();
    return allNotes.where((note) => note.bookId == bookId).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  Future<NoteModel?> getNote(String id) async {
    return _hive.getNote(id);
  }

  Future<void> addNote(NoteModel note) async {
    await _hive.saveNote(note);
  }

  Future<void> updateNote(NoteModel note) async {
    await _hive.saveNote(note);
  }

  Future<void> deleteNote(String id) async {
    await _hive.deleteNote(id);
  }
}
