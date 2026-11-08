import 'package:atiora/data/models/book_model.dart';
import 'package:flutter/foundation.dart';
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
    final userId = _requireUser();
    debugPrint('📝 updateBook - ALL DATA: $data');
    debugPrint('📝 updateBook - userId: $userId');
    debugPrint('📝 updateBook - cover_url en data: ${data['cover_url']}');

    // Hacer UPDATE explícito en lugar de upsert
    await _supabase
        .from('books')
        .update(data)
        .eq('id', data['id'])
        .eq('user_id', userId);
  }

  Future<void> deleteBook(String id) async {
    final userId = _requireUser();
    await _supabase.from('books').delete().eq('id', id).eq('user_id', userId);
  }

  Future<Map<String, dynamic>> loadHomeStats() async {
    final userId = _requireUser();

    final allBooks = await _supabase
        .from('books')
        .select('id, current_page')
        .eq('user_id', userId);

    int totalPagesRead = 0;
    for (final book in allBooks) {
      totalPagesRead += (book['current_page'] as int?) ?? 0;
    }

    int globalStreak = allBooks.isNotEmpty ? 1 : 0;

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

    // Solo usar tabla books, ignore reading_sessions
    final monthBooks = await _supabase
        .from('books')
        .select('id, current_page, total_pages, rating, status, updated_at')
        .eq('user_id', userId)
        .gte('updated_at', startOfMonth)
        .lte('updated_at', endOfMonth);

    int pagesThisMonthCalc = 0;
    for (final book in monthBooks) {
      pagesThisMonthCalc += (book['current_page'] as int?) ?? 0;
    }

    int currentStreak = monthBooks.isNotEmpty ? 1 : 0;

    final monthNotes = await _supabase
        .from('book_notes')
        .select('id')
        .eq('user_id', userId)
        .gte('created_at', startOfMonth)
        .lte('created_at', endOfMonth);
    int notesThisMonth = monthNotes.length;

    final finishedBooksThisMonth = await _supabase
        .from('books')
        .select('id, rating')
        .eq('user_id', userId)
        .eq('status', 'Completado')
        .gte('finished_at', startOfMonth)
        .lte('finished_at', endOfMonth);

    int booksThisMonthCalc = finishedBooksThisMonth.length;
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

  Future<void> updateBookState(
    String bookId,
    String newState, {
    int? currentPage,
    double? rating,
    DateTime? finishedAt,
  }) async {
    final userId = _requireUser();
    final now = DateTime.now().toIso8601String();
    final payload = <String, dynamic>{'status': newState, 'updated_at': now};
    if (currentPage != null) payload['current_page'] = currentPage;
    if (rating != null) payload['rating'] = rating;
    if (finishedAt != null) {
      payload['finished_at'] = finishedAt.toIso8601String();
    }
    // debugPrint('📖 updateBookState: $payload');

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
    // debugPrint('📖 logReadingSession: INSERTED');
  }

  Future<String?> uploadCoverImage(
    String bookId,
    Uint8List fileBytes,
    String fileName,
  ) async {
    try {
      final userId = _requireUser();
      final filePath = '$userId/$bookId/$fileName';
      debugPrint(
        '🎨 Storage: Subiendo a path=$filePath, bytes=${fileBytes.length}',
      );

      await _supabase.storage
          .from('book-covers')
          .uploadBinary(
            filePath,
            fileBytes,
            fileOptions: FileOptions(contentType: 'image/jpeg', upsert: true),
          );

      final publicUrl = _supabase.storage
          .from('book-covers')
          .getPublicUrl(filePath);
      debugPrint('🎨 Storage: Upload exitoso, URL=$publicUrl');
      return publicUrl;
    } catch (e) {
      debugPrint('🎨 Storage ERROR uploading cover: $e');
      return null;
    }
  }

  Future<void> deleteCoverImage(String coverUrl) async {
    try {
      final uri = Uri.parse(coverUrl);
      final pathParts = uri.pathSegments;
      if (pathParts.isNotEmpty) {
        final filePath = pathParts
            .sublist(pathParts.indexOf('book-covers') + 1)
            .join('/');
        await _supabase.storage.from('book-covers').remove([filePath]);
      }
    } catch (e) {
      debugPrint('Error deleting cover image: $e');
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
