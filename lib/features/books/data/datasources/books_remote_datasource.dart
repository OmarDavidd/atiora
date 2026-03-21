import 'package:atiora/data/models/book_model.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class PaginatedBooksResult {
  final List<BookModel> books;
  final int page;
  final int pageSize;
  final bool hasMore;

  PaginatedBooksResult({
    required this.books,
    required this.page,
    required this.pageSize,
    required this.hasMore,
  });
}

class BooksRemoteDataSource {
  final SupabaseClient _supabase;

  BooksRemoteDataSource(this._supabase);

  Future<PaginatedBooksResult> getBooks({int? page, int pageSize = 20}) async {
    final userId = _requireUser();
    final from = page != null ? page * pageSize : 0;

    final response = await _supabase
        .from('books')
        .select()
        .eq('user_id', userId)
        .order('updated_at', ascending: false)
        .range(from, from + pageSize - 1);

    final books = response.map((json) => BookModel.fromJson(json)).toList();

    return PaginatedBooksResult(
      books: books,
      page: page ?? 0,
      pageSize: pageSize,
      hasMore: books.length == pageSize,
    );
  }

  Future<BookModel?> getBook(String id) async {
    final userId = _requireUser();
    final response = await _supabase
        .from('books')
        .select()
        .eq('id', id)
        .eq('user_id', userId)
        .maybeSingle();
    return response != null ? BookModel.fromJson(response) : null;
  }

  Future<void> addBook(BookModel book) async {
    final data = book.toJson()..remove('id');
    await _supabase.from('books').insert(data);
  }

  Future<void> updateBook(BookModel book) async {
    final data = {...book.toJson()..remove('user_id'), 'id': book.id};
    await _supabase.from('books').upsert(data);
  }

  Future<void> deleteBook(String id) async {
    final userId = _requireUser();
    await _supabase.from('books').delete().eq('id', id).eq('user_id', userId);
  }

  Future<Map<String, dynamic>> loadHomeStats() async {
    final userId = _requireUser();

    final statsResponse = await _supabase
        .from('current_month_stats')
        .select()
        .eq('user_id', userId)
        .maybeSingle();

    dynamic streakResponse = 0;
    try {
      streakResponse = await _supabase.rpc(
        'get_current_streak',
        params: {'p_user_id': userId},
      );
    } catch (_) {}

    return {
      'pagesThisMonth': statsResponse?['total_pages_mes'] ?? 0,
      'booksTouched': statsResponse?['libros_tocados_mes'] ?? 0,
      'booksFinished': statsResponse?['libros_terminados_mes'] ?? 0,
      'streak': _extractStreak(streakResponse),
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
    final payload = <String, dynamic>{'status': newState};
    if (currentPage != null) payload['current_page'] = currentPage;
    if (rating != null) payload['rating'] = rating;
    if (finishedAt != null) {
      payload['finished_at'] = finishedAt.toIso8601String();
    }

    await _supabase
        .from('books')
        .update(payload)
        .eq('id', bookId)
        .eq('user_id', userId);
  }

  Future<void> logReadingSession(
    String bookId,
    int pagesDelta, {
    DateTime? sessionDate,
  }) async {
    final userId = _requireUser();
    await _supabase.from('reading_sessions').insert({
      'user_id': userId,
      'book_id': bookId,
      'pages_read': pagesDelta,
      'session_date': (sessionDate ?? DateTime.now()).toIso8601String(),
    });
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
