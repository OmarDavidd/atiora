import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:atiora/data/models/book_model.dart';
import 'package:atiora/features/books/data/datasources/books_local_datasource.dart';
import 'package:atiora/features/books/data/datasources/books_remote_datasource.dart';
import 'package:atiora/features/books/data/repositories/books_repository_impl.dart';

class MockBooksLocalDataSource extends Mock implements BooksLocalDataSource {}

class MockBooksRemoteDataSource extends Mock implements BooksRemoteDataSource {}

void main() {
  late MockBooksLocalDataSource mockLocalDataSource;
  late MockBooksRemoteDataSource mockRemoteDataSource;
  late BooksRepositoryImpl repository;

  setUp(() {
    mockLocalDataSource = MockBooksLocalDataSource();
    mockRemoteDataSource = MockBooksRemoteDataSource();
    repository = BooksRepositoryImpl(mockLocalDataSource, mockRemoteDataSource);
  });

  setUpAll(() {
    registerFallbackValue(
      BookModel(
        id: 'fallback',
        userId: 'user',
        title: 'Fallback',
        genre: [],
        totalPages: 100,
        currentPage: 0,
        status: 'pendiente',
        rating: 0.0,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      ),
    );
  });

  group('BooksRepositoryImpl', () {
    final testBook = BookModel(
      id: 'book-1',
      userId: 'user-1',
      title: 'Test Book',
      author: 'Test Author',
      genre: ['fiction'],
      totalPages: 200,
      currentPage: 50,
      status: 'leyendo',
      rating: 4.0,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 2),
    );

    group('getBooks', () {
      test('should return books from local when offline', () async {
        when(
          () => mockRemoteDataSource.getBooks(),
        ).thenThrow(Exception('Offline'));
        when(
          () => mockLocalDataSource.getBooks(),
        ).thenAnswer((_) async => [testBook]);

        final result = await repository.getBooks();

        expect(result, [testBook]);
      });

      test('should sync and return books when online', () async {
        when(
          () => mockRemoteDataSource.getBooks(),
        ).thenAnswer((_) async => [testBook]);
        when(() => mockLocalDataSource.clearAll()).thenAnswer((_) async {});
        when(
          () => mockLocalDataSource.addBooks(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockLocalDataSource.getBooks(),
        ).thenAnswer((_) async => [testBook]);

        final result = await repository.getBooks();

        expect(result, [testBook]);
        verify(() => mockRemoteDataSource.getBooks()).called(1);
      });
    });

    group('getBook', () {
      test('should return book from local data source', () async {
        when(
          () => mockLocalDataSource.getBook('book-1'),
        ).thenAnswer((_) async => testBook);

        final result = await repository.getBook('book-1');

        expect(result, testBook);
        verify(() => mockLocalDataSource.getBook('book-1')).called(1);
      });

      test('should return null when book not found', () async {
        when(
          () => mockLocalDataSource.getBook('nonexistent'),
        ).thenAnswer((_) async => null);

        final result = await repository.getBook('nonexistent');

        expect(result, isNull);
      });
    });

    group('addBook', () {
      test('should save to local first', () async {
        when(
          () => mockLocalDataSource.addBook(testBook),
        ).thenAnswer((_) async {});

        await repository.addBook(testBook);

        verify(() => mockLocalDataSource.addBook(testBook)).called(1);
      });

      test('should attempt remote save when online', () async {
        when(
          () => mockLocalDataSource.addBook(testBook),
        ).thenAnswer((_) async {});
        when(
          () => mockRemoteDataSource.addBook(testBook),
        ).thenAnswer((_) async {});

        await repository.addBook(testBook);

        verify(() => mockRemoteDataSource.addBook(testBook)).called(1);
      });
    });

    group('updateBook', () {
      test('should update local first', () async {
        when(
          () => mockLocalDataSource.updateBook(testBook),
        ).thenAnswer((_) async {});

        await repository.updateBook(testBook);

        verify(() => mockLocalDataSource.updateBook(testBook)).called(1);
      });

      test('should attempt remote update when online', () async {
        when(
          () => mockLocalDataSource.updateBook(testBook),
        ).thenAnswer((_) async {});
        when(
          () => mockRemoteDataSource.updateBook(testBook),
        ).thenAnswer((_) async {});

        await repository.updateBook(testBook);

        verify(() => mockRemoteDataSource.updateBook(testBook)).called(1);
      });
    });

    group('deleteBook', () {
      test('should delete from local first', () async {
        when(
          () => mockLocalDataSource.deleteBook('book-1'),
        ).thenAnswer((_) async {});

        await repository.deleteBook('book-1');

        verify(() => mockLocalDataSource.deleteBook('book-1')).called(1);
      });

      test('should attempt remote delete when online', () async {
        when(
          () => mockLocalDataSource.deleteBook('book-1'),
        ).thenAnswer((_) async {});
        when(
          () => mockRemoteDataSource.deleteBook('book-1'),
        ).thenAnswer((_) async {});

        await repository.deleteBook('book-1');

        verify(() => mockRemoteDataSource.deleteBook('book-1')).called(1);
      });
    });

    group('loadHomeStats', () {
      test('should return stats from remote', () async {
        final stats = {'pagesThisMonth': 500, 'booksTouched': 5, 'streak': 10};
        when(
          () => mockRemoteDataSource.loadHomeStats(),
        ).thenAnswer((_) async => stats);

        final result = await repository.loadHomeStats();

        expect(result, stats);
        verify(() => mockRemoteDataSource.loadHomeStats()).called(1);
      });
    });

    group('updateBookState', () {
      test('should update state in remote', () async {
        when(
          () => mockRemoteDataSource.updateBookState('book-1', 'terminado'),
        ).thenAnswer((_) async {});

        await repository.updateBookState('book-1', 'terminado');

        verify(
          () => mockRemoteDataSource.updateBookState('book-1', 'terminado'),
        ).called(1);
      });
    });
  });
}
