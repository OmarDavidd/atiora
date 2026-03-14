import 'package:flutter_test/flutter_test.dart';
import 'package:atiora/data/models/book_model.dart';

void main() {
  group('BookModel', () {
    final testJson = {
      'id': 'test-id-123',
      'user_id': 'user-456',
      'title': 'Clean Code',
      'author': 'Robert C. Martin',
      'genre': ['programming', 'software'],
      'total_pages': 400,
      'current_page': 150,
      'status': 'leyendo',
      'rating': 4.5,
      'cover_url': 'https://example.com/cover.jpg',
      'created_at': '2024-01-15T10:00:00.000Z',
      'updated_at': '2024-01-20T15:30:00.000Z',
      'started_at': '2024-01-16T08:00:00.000Z',
      'finished_at': null,
    };

    test('fromJson should correctly parse complete JSON', () {
      final book = BookModel.fromJson(testJson);

      expect(book.id, 'test-id-123');
      expect(book.userId, 'user-456');
      expect(book.title, 'Clean Code');
      expect(book.author, 'Robert C. Martin');
      expect(book.genre, ['programming', 'software']);
      expect(book.totalPages, 400);
      expect(book.currentPage, 150);
      expect(book.status, 'leyendo');
      expect(book.rating, 4.5);
      expect(book.coverUrl, 'https://example.com/cover.jpg');
      expect(book.startedAt, isNotNull);
      expect(book.finishedAt, isNull);
    });

    test('fromJson should handle missing optional fields', () {
      final minimalJson = {
        'id': 'test-id',
        'user_id': 'user-id',
        'title': 'Test Book',
        'genre': <String>[],
        'total_pages': 100,
        'current_page': 0,
        'status': 'pendiente',
        'rating': 0.0,
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-01T00:00:00.000Z',
      };

      final book = BookModel.fromJson(minimalJson);

      expect(book.author, isNull);
      expect(book.coverUrl, isNull);
      expect(book.startedAt, isNull);
      expect(book.finishedAt, isNull);
    });

    test('fromJson should use defaults for null/missing fields', () {
      final jsonWithNulls = {
        'id': 'test-id',
        'user_id': 'user-id',
        'title': 'Test',
        'genre': null,
        'total_pages': null,
        'current_page': null,
        'status': null,
        'rating': null,
        'created_at': '2024-01-01T00:00:00.000Z',
        'updated_at': '2024-01-01T00:00:00.000Z',
      };

      final book = BookModel.fromJson(jsonWithNulls);

      expect(book.genre, isEmpty);
      expect(book.totalPages, 0);
      expect(book.currentPage, 0);
      expect(book.status, 'leyendo');
      expect(book.rating, 0.0);
    });

    test('toJson should correctly serialize model', () {
      final book = BookModel.fromJson(testJson);
      final json = book.toJson();

      expect(json['id'], 'test-id-123');
      expect(json['user_id'], 'user-456');
      expect(json['title'], 'Clean Code');
      expect(json['author'], 'Robert C. Martin');
      expect(json['genre'], ['programming', 'software']);
      expect(json['total_pages'], 400);
      expect(json['current_page'], 150);
      expect(json['status'], 'leyendo');
      expect(json['rating'], 4.5);
      expect(json['pending_sync'], isFalse);
    });

    test('toRemoteJson should exclude id and user_id', () {
      final book = BookModel.fromJson(testJson);
      final remoteJson = book.toRemoteJson();

      expect(remoteJson.containsKey('id'), isFalse);
      expect(remoteJson.containsKey('user_id'), isFalse);
      expect(remoteJson['title'], 'Clean Code');
    });

    test('copyWith should create new instance with updated fields', () {
      final book = BookModel.fromJson(testJson);
      final updatedBook = book.copyWith(
        title: 'Clean Architecture',
        currentPage: 200,
        rating: 5.0,
        pendingSync: true,
      );

      expect(updatedBook.title, 'Clean Architecture');
      expect(updatedBook.currentPage, 200);
      expect(updatedBook.rating, 5.0);
      expect(updatedBook.author, book.author);
      expect(updatedBook.id, book.id);
      expect(updatedBook.pendingSync, isTrue);
    });

    test('copyWith with no changes should return equal copy', () {
      final book = BookModel.fromJson(testJson);
      final copy = book.copyWith();

      expect(copy, equals(book));
    });

    test('props should include all fields for equality', () {
      final book1 = BookModel.fromJson(testJson);
      final book2 = BookModel.fromJson(testJson);

      expect(book1, equals(book2));
      expect(book1.props.length, 15);
    });

    test('books with different fields should not be equal', () {
      final book1 = BookModel.fromJson(testJson);
      final differentJson = {...testJson, 'title': 'Different Title'};
      final book2 = BookModel.fromJson(differentJson);

      expect(book1, isNot(equals(book2)));
    });
  });
}
