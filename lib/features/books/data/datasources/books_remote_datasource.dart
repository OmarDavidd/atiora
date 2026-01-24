import 'package:atiora/data/models/book_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BooksRemoteDataSource {
  final SupabaseClient _supabase;
  final String _userId;
  BooksRemoteDataSource(this._supabase, this._userId);

  Future<List<BookModel>> getBooks() async {
    try {
      final books = await _supabase
          .from('books')
          .select()
          .eq('user_id', _userId);
      return books.map((json) => BookModel.fromJson(json)).toList();
    } catch (e) {
      return [];
    }
  }

  Future<BookModel?> getBook(String id) async {
    try {
      final book = await _supabase
          .from('books')
          .select()
          .eq('id', id)
          .eq('user_id', _userId)
          .single();
      return BookModel.fromJson(book);
    } catch (e) {
      return null;
    }
  }

  Future<void> addBook(BookModel book) async {
    try {
      await _supabase.from('books').insert(book.toJson());
    } catch (e) {
      return;
    }
  }

  Future<void> updateBook(BookModel book) async {
    try {
      await _supabase.from('books').upsert(book.toJson());
    } catch (e) {
      return;
    }
  }

  Future<void> deleteBook(String id) async {
    try {
      await _supabase.from('books').delete().eq('id', id);
    } catch (e) {
      return;
    }
  }
}
