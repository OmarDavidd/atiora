import 'dart:io';

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
    final data = book.toRemoteJson();
    await _supabase.from('books').insert(data);
  }

  Future<void> updateBook(BookModel book) async {
    final data = book.toRemoteJson();
    await _supabase.from('books').upsert(data);
  }

  Future<void> deleteBook(String id) async {
    final userId = _requireUser();
    await _supabase.from('books').delete().eq('id', id).eq('user_id', userId);
  }

  Future<Map<String, dynamic>> loadHomeStats() async {
    final userId = _requireUser();

    final allSessions = await _supabase
        .from('reading_sessions')
        .select('pages_read, session_date')
        .eq('user_id', userId)
        .order('session_date', ascending: false);

    int totalPagesRead = 0;
    for (final session in allSessions) {
      totalPagesRead += (session['pages_read'] as int?) ?? 0;
    }

    int globalStreak = _calculateStreak(allSessions);

    final allNotes = await _supabase
        .from('book_notes')
        .select('id')
        .eq('user_id', userId);
    int totalNotes = allNotes.length;

    final completedBooks = await _supabase
        .from('books')
        .select('id, rating')
        .eq('user_id', userId)
        .eq('status', 'Completado');

    int booksRead = completedBooks.length;

    final now = DateTime.now();
    final startOfMonth = DateTime(now.year, now.month, 1).toIso8601String();
    final endOfMonth = DateTime(now.year, now.month + 1, 0).toIso8601String();

    final monthSessions = await _supabase
        .from('reading_sessions')
        .select('pages_read, session_date')
        .eq('user_id', userId)
        .gte('session_date', startOfMonth)
        .lte('session_date', endOfMonth)
        .order('session_date', ascending: false);

    int pagesThisMonthCalc = 0;
    for (final session in monthSessions) {
      pagesThisMonthCalc += (session['pages_read'] as int?) ?? 0;
    }

    int currentStreak = _calculateStreak(monthSessions);

    final monthNotes = await _supabase
        .from('book_notes')
        .select('id')
        .eq('user_id', userId)
        .gte('created_at', startOfMonth)
        .lte('created_at', endOfMonth);
    int notesThisMonth = monthNotes.length;

    final monthBooks = await _supabase
        .from('books')
        .select('id, rating')
        .eq('user_id', userId)
        .eq('status', 'Completado')
        .gte('finished_at', startOfMonth)
        .lte('finished_at', endOfMonth);

    int booksThisMonthCalc = monthBooks.length;
    double avgRatingMonth = 0;
    if (monthBooks.isNotEmpty) {
      double sumRating = 0;
      int ratedCount = 0;
      for (final book in monthBooks) {
        final rating = book['rating'];
        if (rating != null && rating > 0) {
          sumRating += rating.toDouble();
          ratedCount++;
        }
      }
      if (ratedCount > 0) {
        avgRatingMonth = sumRating / ratedCount;
      }
    }

    return {
      'pagesThisMonth': pagesThisMonthCalc,
      'booksTouched': monthBooks.length,
      'booksFinished': booksThisMonthCalc,
      'streak': currentStreak,
      'globalStreak': globalStreak,
      'totalPagesRead': totalPagesRead,
      'booksRead': booksRead,
      'averageRating': avgRatingMonth,
      'totalNotes': totalNotes,
      'notesThisMonth': notesThisMonth,
    };
  }

  int _calculateStreak(List<dynamic> sessions) {
    if (sessions.isEmpty) return 0;

    final Set<String> uniqueDates = {};
    for (final session in sessions) {
      final date = session['session_date'];
      if (date != null) {
        String dateStr;
        if (date is String) {
          dateStr = date.split('T').first;
        } else {
          dateStr = date.toString().split('T').first;
        }
        uniqueDates.add(dateStr);
      }
    }

    if (uniqueDates.isEmpty) return 0;

    final sortedDates = uniqueDates.toList()..sort((a, b) => b.compareTo(a));
    final today = DateTime.now().toIso8601String().split('T').first;
    final yesterday = DateTime.now()
        .subtract(const Duration(days: 1))
        .toIso8601String()
        .split('T')
        .first;

    if (sortedDates.first != today && sortedDates.first != yesterday) {
      return 0;
    }

    int streak = 1;
    for (int i = 0; i < sortedDates.length - 1; i++) {
      final current = DateTime.parse(sortedDates[i]);
      final next = DateTime.parse(sortedDates[i + 1]);
      if (current.difference(next).inDays == 1) {
        streak++;
      } else {
        break;
      }
    }

    return streak;
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

  Future<String?> uploadCoverImage(File imageFile, String bookId) async {
    try {
      final bytes = await imageFile.readAsBytes();
      final extension = imageFile.path.split('.').last.toLowerCase();
      final validExtensions = ['jpg', 'jpeg', 'png', 'webp'];
      final ext = validExtensions.contains(extension) ? extension : 'jpg';

      final path = '$bookId.$ext';

      final response = await _supabase.storage
          .from('book-covers')
          .uploadBinary(path, bytes);

      if (response.isNotEmpty) {
        final publicUrl = _supabase.storage
            .from('book-covers')
            .getPublicUrl(path);
        return publicUrl;
      }
      return null;
    } catch (e) {
      return null;
    }
  }

  String _requireUser() {
    final userId = _supabase.auth.currentUser?.id;
    if (userId == null) {
      throw StateError('BooksRemoteDataSource requires an authenticated user');
    }
    return userId;
  }
}
