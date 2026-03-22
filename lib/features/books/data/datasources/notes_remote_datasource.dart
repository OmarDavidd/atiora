import 'package:atiora/data/models/note_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class NotesRemoteDataSource {
  final SupabaseClient _supabase;

  NotesRemoteDataSource(this._supabase);

  Future<List<NoteModel>> getNotesByBook(String bookId) async {
    final userId = _requireUser();
    final response = await _supabase
        .from('book_notes')
        .select()
        .eq('book_id', bookId)
        .eq('user_id', userId)
        .order('created_at', ascending: false);

    return response.map((json) => NoteModel.fromJson(json)).toList();
  }

  Future<NoteModel?> getNote(String id) async {
    final userId = _requireUser();
    final response = await _supabase
        .from('book_notes')
        .select()
        .eq('id', id)
        .eq('user_id', userId)
        .maybeSingle();

    return response != null ? NoteModel.fromJson(response) : null;
  }

  Future<void> addNote(NoteModel note) async {
    final data = note.toRemoteJson();
    await _supabase.from('book_notes').insert(data);
  }

  Future<void> updateNote(NoteModel note) async {
    final userId = _requireUser();
    final data = note.toRemoteJson();
    data['updated_at'] = DateTime.now().toIso8601String();
    await _supabase
        .from('book_notes')
        .update(data)
        .eq('id', note.id)
        .eq('user_id', userId);
  }

  Future<void> deleteNote(String id) async {
    final userId = _requireUser();
    await _supabase
        .from('book_notes')
        .delete()
        .eq('id', id)
        .eq('user_id', userId);
  }

  String _requireUser() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('NotesRemoteDataSource requires an authenticated user');
    }
    return userId;
  }
}
