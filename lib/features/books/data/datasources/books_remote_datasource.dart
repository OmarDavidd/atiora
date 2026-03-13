import 'package:atiora/data/models/book_model.dart';
import 'package:flutter/material.dart';
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

  Future<Map<String, dynamic>> loadHomeStats() async {
    final statsResponse = await _supabase
        .from('current_month_stats')
        .select()
        .eq('user_id', _supabase.auth.currentUser!.id)
        .maybeSingle();

    debugPrint('🟡 Antes RPC: user ${_supabase.auth.currentUser!.id}');
    dynamic streakResponse;
    try {
      streakResponse = await _supabase.rpc(
        'get_current_streak',
        params: {'p_user_id': _supabase.auth.currentUser!.id},
      );
      debugPrint(
        '🟢 Streak RAW: $streakResponse (type: ${streakResponse.runtimeType})',
      );
    } catch (e) {
      debugPrint('🔴 Streak RPC error: $e');
      streakResponse = 0;
    }

    final streak = _extractStreak(streakResponse);
    debugPrint('🟢 Streak final: $streak');

    return {
      'pagesThisMonth': statsResponse?['total_pages_mes'] ?? 0,
      'booksTouched': statsResponse?['libros_tocados_mes'] ?? 0,
      'booksFinished': statsResponse?['libros_terminados_mes'] ?? 0,
      'streak': streak,
    };
  }

  Future<void> updateBookState(String bookId, String newState) async {
    try {
      await _supabase
          .from('books')
          .update({'status': newState})
          .eq('id', bookId)
          .eq('user_id', _supabase.auth.currentUser!.id);
      debugPrint('✅ Supabase OK');
    } catch (e) {
      rethrow;
    }
  }

  int _extractStreak(dynamic response) {
    if (response == null) return 0;
    if (response is int) return response;
    if (response is List) {
      return response.isNotEmpty ? (response.first as int? ?? 0) : 0;
    }
    if (response is Map && response.containsKey('streak')) {
      return response['streak'] as int? ?? 0;
    }
    return 0;
  }
}
