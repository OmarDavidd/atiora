import 'package:atiora/data/models/book_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BooksRemoteDataSource {
  final SupabaseClient _supabase;

  BooksRemoteDataSource(this._supabase);

  Future<List<BookModel>> getBooks() async {
    try {
      final response = await _supabase
          .from('books')
          .select()
          .eq('user_id', _supabase.auth.currentUser!.id);
      return response.map((json) => BookModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<BookModel?> getBook(String id) async {
    try {
      final response = await _supabase
          .from('books')
          .select()
          .eq('id', id)
          .eq('user_id', _supabase.auth.currentUser!.id)
          .maybeSingle();
      return response != null ? BookModel.fromJson(response) : null;
    } catch (e) {
      return null;
    }
  }

  Future<void> addBook(BookModel book) async {
    try {
      final data = book.toJson()..remove('id');

      //..remove('user_id');
      await _supabase.from('books').insert(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> updateBook(BookModel book) async {
    try {
      final data = {...book.toJson()..remove('user_id'), 'id': book.id};
      await _supabase.from('books').upsert(data);
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteBook(String id) async {
    try {
      await _supabase
          .from('books')
          .delete()
          .eq('id', id)
          .eq('user_id', _supabase.auth.currentUser!.id);
    } catch (e) {
      rethrow;
    }
  }
}
