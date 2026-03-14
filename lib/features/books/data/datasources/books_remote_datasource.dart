import 'package:atiora/data/models/book_model.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class BooksRemoteDataSource {
  final SupabaseClient _supabase;

  BooksRemoteDataSource(this._supabase);

  Future<List<BookModel>> getBooks() async {
    final userId = _requireUser();

    try {
      final response = await _supabase
          .from('books')
          .select()
          .eq('user_id', userId);
      return response.map((json) => BookModel.fromJson(json)).toList();
    } catch (e, stackTrace) {
      debugPrint('BooksRemoteDataSource.getBooks failed: $e');
      debugPrint('$stackTrace');
      rethrow;
    }
  }

  Future<BookModel?> getBook(String id) async {
    final userId = _requireUser();

    try {
      final response = await _supabase
          .from('books')
          .select()
          .eq('id', id)
          .eq('user_id', userId)
          .maybeSingle();
      return response != null ? BookModel.fromJson(response) : null;
    } catch (e, stackTrace) {
      debugPrint('BooksRemoteDataSource.getBook failed: $e');
      debugPrint('$stackTrace');
      rethrow;
    }
  }

  Future<void> addBook(BookModel book) async {
    try {
      final data = book.toJson()..remove('id');
      await _supabase.from('books').insert(data);
    } catch (e) {
      debugPrint('BooksRemoteDataSource.addBook failed: $e');
      rethrow;
    }
  }

  Future<void> updateBook(BookModel book) async {
    try {
      final data = {...book.toJson()..remove('user_id'), 'id': book.id};
      await _supabase.from('books').upsert(data);
    } catch (e) {
      debugPrint('BooksRemoteDataSource.updateBook failed: $e');
      rethrow;
    }
  }

  Future<void> deleteBook(String id) async {
    final userId = _requireUser();

    try {
      await _supabase.from('books').delete().eq('id', id).eq('user_id', userId);
    } catch (e) {
      debugPrint('BooksRemoteDataSource.deleteBook failed: $e');
      rethrow;
    }
  }

  Future<Map<String, dynamic>> loadHomeStats() async {
    final userId = _requireUser();

    final statsResponse = await _supabase
        .from('current_month_stats')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    dynamic streakResponse;
    try {
      streakResponse = await _supabase.rpc(
        'get_current_streak',
        params: {'p_user_id': userId},
      );
    } catch (e) {
      debugPrint('BooksRemoteDataSource.loadHomeStats streak RPC failed: $e');
      streakResponse = 0;
    }

    final streak = _extractStreak(streakResponse);

    return {
      'pagesThisMonth': statsResponse?['total_pages_mes'] ?? 0,
      'booksTouched': statsResponse?['libros_tocados_mes'] ?? 0,
      'booksFinished': statsResponse?['libros_terminados_mes'] ?? 0,
      'streak': streak,
    };
  }

  Future<void> updateBookState(
    String bookId,
    String newState, {
    int? currentPage,
    double? rating,
    DateTime? finishedAt,
  }) async {
    final userId = _requireUser();

    try {
      final payload = <String, dynamic>{'status': newState};
      if (currentPage != null) payload['current_page'] = currentPage;
      if (rating != null) payload['rating'] = rating;
      payload['finished_at'] = finishedAt?.toIso8601String();

      await _supabase
          .from('books')
          .update(payload)
          .eq('id', bookId)
          .eq('user_id', userId);
    } catch (e) {
      debugPrint('BooksRemoteDataSource.updateBookState failed: $e');
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

  String _requireUser() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('BooksRemoteDataSource requires an authenticated user');
    }
    return userId;
  }
}
