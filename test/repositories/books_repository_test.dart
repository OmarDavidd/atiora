import 'package:atiora/data/models/book_model.dart';
import 'package:atiora/features/books/data/datasources/books_local_datasource.dart';
import 'package:atiora/features/books/data/datasources/books_remote_datasource.dart';
import 'package:atiora/features/books/data/repositories/books_repository_impl.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBooksLocalDataSource extends Mock implements BooksLocalDataSource {}

class MockBooksRemoteDataSource extends Mock implements BooksRemoteDataSource {}

void main() {
  late MockBooksLocalDataSource mockLocalDataSource;
  late MockBooksRemoteDataSource mockRemoteDataSource;
  late BooksRepositoryImpl repository;
  late _StubConnectivity connectivity;

  setUpAll(() {
    registerFallbackValue(
      BookModel(
        id: 'fallback',
        userId: 'user',
        title: 'Fallback',
        genre: const [],
        totalPages: 100,
        currentPage: 0,
        status: 'pendiente',
        rating: 0.0,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
    );
  });

  setUp(() {
    mockLocalDataSource = MockBooksLocalDataSource();
    mockRemoteDataSource = MockBooksRemoteDataSource();
    connectivity = _StubConnectivity(isOnline: true);
    repository = BooksRepositoryImpl(
      mockLocalDataSource,
      mockRemoteDataSource,
      connectivity: connectivity,
    );
  });

  group('BooksRepositoryImpl', () {
    final testBook = BookModel(
      id: 'book-1',
      userId: 'user-1',
      title: 'Test Book',
      author: 'Test Author',
      genre: const ['fiction'],
      totalPages: 200,
      currentPage: 50,
      status: 'leyendo',
      rating: 4.0,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 2),
    );

    group('getBooks', () {
      test('returns local data when sync fails or offline', () async {
        connectivity.isOnline = false;
        when(() => mockRemoteDataSource.getBooks()).thenThrow(Exception());
        when(
          () => mockLocalDataSource.getBooks(),
        ).thenAnswer((_) async => [testBook]);

        final result = await repository.getBooks();

        expect(result, [testBook]);
      });

      test('syncs remote books when online', () async {
        connectivity.isOnline = true;
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

    test('getBook delegates to local datasource', () async {
      when(
        () => mockLocalDataSource.getBook('book-1'),
      ).thenAnswer((_) async => testBook);

      final result = await repository.getBook('book-1');

      expect(result, testBook);
      verify(() => mockLocalDataSource.getBook('book-1')).called(1);
    });

    group('addBook', () {
      test('always writes to local', () async {
        connectivity.isOnline = false;
        when(
          () => mockLocalDataSource.addBook(testBook),
        ).thenAnswer((_) async {});

        await repository.addBook(testBook);

        verify(() => mockLocalDataSource.addBook(testBook)).called(1);
        verifyNever(() => mockRemoteDataSource.addBook(any()));
      });

      test('syncs remote when online', () async {
        connectivity.isOnline = true;
        when(
          () => mockLocalDataSource.addBook(testBook),
        ).thenAnswer((_) async {});
        when(
          () => mockRemoteDataSource.addBook(testBook),
        ).thenAnswer((_) async {});
        when(
          () => mockRemoteDataSource.addBook(testBook),
        ).thenAnswer((_) async {});

        await repository.addBook(testBook);

        verify(() => mockRemoteDataSource.addBook(testBook)).called(1);
      });
    });

    group('updateBook', () {
      test('updates local copy', () async {
        connectivity.isOnline = false;
        when(
          () => mockLocalDataSource.updateBook(testBook),
        ).thenAnswer((_) async {});

        await repository.updateBook(testBook);

        verify(() => mockLocalDataSource.updateBook(testBook)).called(1);
        verifyNever(() => mockRemoteDataSource.updateBook(any()));
      });

      test('propagates to remote when online', () async {
        connectivity.isOnline = true;
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
      test('removes from local cache', () async {
        connectivity.isOnline = false;
        when(
          () => mockLocalDataSource.deleteBook('book-1'),
        ).thenAnswer((_) async {});

        await repository.deleteBook('book-1');

        verify(() => mockLocalDataSource.deleteBook('book-1')).called(1);
        verifyNever(() => mockRemoteDataSource.deleteBook(any()));
      });

      test('removes from remote when online', () async {
        connectivity.isOnline = true;
        when(
          () => mockLocalDataSource.deleteBook('book-1'),
        ).thenAnswer((_) async {});
        when(
          () => mockRemoteDataSource.deleteBook('book-1'),
        ).thenAnswer((_) async {});

        await repository.deleteBook('book-1');

        verify(() => mockRemoteDataSource.deleteBook('book-1')).called(1);
        verify(() => mockLocalDataSource.deleteBook('book-1')).called(1);
      });
    });

    test('loadHomeStats reads from remote datasource', () async {
      final stats = {'pagesThisMonth': 10};
      when(
        () => mockRemoteDataSource.loadHomeStats(),
      ).thenAnswer((_) async => stats);

      final result = await repository.loadHomeStats();

      expect(result, stats);
      verify(() => mockRemoteDataSource.loadHomeStats()).called(1);
    });

    test('updateBookState proxies to remote datasource', () async {
      connectivity.isOnline = true;
      when(
        () => mockRemoteDataSource.updateBookState('book-1', 'terminado'),
      ).thenAnswer((_) async {});
      when(
        () => mockLocalDataSource.getBook('book-1'),
      ).thenAnswer((_) async => testBook);
      when(
        () => mockLocalDataSource.updateBook(any()),
      ).thenAnswer((_) async {});

      await repository.updateBookState('book-1', 'terminado');

      verify(
        () => mockRemoteDataSource.updateBookState('book-1', 'terminado'),
      ).called(1);
    });
  });
}

class _StubConnectivity extends ConnectivityPlatform {
  _StubConnectivity({required bool isOnline}) : _isOnline = isOnline;

  bool _isOnline;

  set isOnline(bool value) => _isOnline = value;

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream<List<ConnectivityResult>>.empty();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    return _isOnline ? [ConnectivityResult.wifi] : [ConnectivityResult.none];
  }
}
