import 'package:atiora/core/storage/hive_service.dart';
import 'package:atiora/data/models/book_model.dart';
import 'package:atiora/features/books/data/datasources/books_local_datasource.dart';
import 'package:atiora/features/books/data/datasources/books_remote_datasource.dart';
import 'package:atiora/features/books/data/repositories/books_repository_impl.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBooksLocalDataSource extends Mock implements BooksLocalDataSource {}

class MockBooksRemoteDataSource extends Mock implements BooksRemoteDataSource {}

class MockHiveService extends Mock implements HiveService {}

void main() {
  late MockBooksLocalDataSource mockLocalDataSource;
  late MockBooksRemoteDataSource mockRemoteDataSource;
  late BooksRepositoryImpl repository;
  late _StubConnectivity connectivity;
  late MockHiveService mockHiveService;

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
    mockHiveService = MockHiveService();
    connectivity = _StubConnectivity(isOnline: true);
    when(
      () => mockHiveService.getPendingOperations(),
    ).thenAnswer((_) async => <MapEntry<String, Map<String, dynamic>>>[]);
    when(
      () => mockHiveService.enqueuePendingOperation(any()),
    ).thenAnswer((_) async => 'pending');
    when(
      () => mockHiveService.removePendingOperation(any()),
    ).thenAnswer((_) async {});
    when(() => mockLocalDataSource.getBooks()).thenAnswer((_) async => []);
    when(() => mockLocalDataSource.addBook(any())).thenAnswer((_) async {});
    when(() => mockLocalDataSource.updateBook(any())).thenAnswer((_) async {});
    when(() => mockLocalDataSource.deleteBook(any())).thenAnswer((_) async {});
    when(() => mockLocalDataSource.addBooks(any())).thenAnswer((_) async {});
    when(() => mockLocalDataSource.clearAll()).thenAnswer((_) async {});
    when(() => mockRemoteDataSource.addBook(any())).thenAnswer((_) async {});
    when(() => mockRemoteDataSource.updateBook(any())).thenAnswer((_) async {});
    when(() => mockRemoteDataSource.deleteBook(any())).thenAnswer((_) async {});
    when(
      () => mockRemoteDataSource.logReadingSession(
        any(),
        any(),
        sessionDate: any(named: 'sessionDate'),
      ),
    ).thenAnswer((_) async {});
    when(
      () => mockRemoteDataSource.updateBookState(
        any(),
        any(),
        currentPage: any(named: 'currentPage'),
        rating: any(named: 'rating'),
        finishedAt: any(named: 'finishedAt'),
      ),
    ).thenAnswer((_) async {});
    repository = BooksRepositoryImpl(
      mockLocalDataSource,
      mockRemoteDataSource,
      connectivity: connectivity,
      hive: mockHiveService,
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
          () => mockRemoteDataSource.getBooks(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          ),
        ).thenAnswer(
          (_) async => PaginatedBooksResult(
            books: [testBook],
            page: 0,
            pageSize: 20,
            hasMore: false,
          ),
        );
        when(() => mockLocalDataSource.clearAll()).thenAnswer((_) async {});
        when(
          () => mockLocalDataSource.addBooks(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockLocalDataSource.getBooks(),
        ).thenAnswer((_) async => [testBook]);

        final result = await repository.getBooks();

        expect(result, [testBook]);
        verify(
          () => mockRemoteDataSource.getBooks(
            page: any(named: 'page'),
            pageSize: any(named: 'pageSize'),
          ),
        ).called(1);
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
        when(() => mockLocalDataSource.addBook(any())).thenAnswer((_) async {});

        await repository.addBook(testBook);

        verify(() => mockLocalDataSource.addBook(any())).called(1);
        verifyNever(() => mockRemoteDataSource.addBook(any()));
      });

      test('syncs remote when online', () async {
        connectivity.isOnline = true;

        await repository.addBook(testBook);

        verify(() => mockRemoteDataSource.addBook(any())).called(1);
      });

      test('queues pending operation when offline', () async {
        connectivity.isOnline = false;
        when(() => mockLocalDataSource.addBook(any())).thenAnswer((_) async {});
        when(
          () => mockLocalDataSource.updateBook(any()),
        ).thenAnswer((_) async {});

        await repository.addBook(testBook);

        verify(() => mockHiveService.enqueuePendingOperation(any())).called(1);
      });
    });

    group('updateBook', () {
      test('updates local copy', () async {
        connectivity.isOnline = false;

        await repository.updateBook(testBook);

        verify(() => mockLocalDataSource.updateBook(any())).called(1);
        verifyNever(() => mockRemoteDataSource.updateBook(any()));
      });

      test('propagates to remote when online', () async {
        connectivity.isOnline = true;

        await repository.updateBook(testBook);

        verify(() => mockRemoteDataSource.updateBook(any())).called(1);
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
      final stats = {'pagesThisMonth': 10, 'averageRating': 3.5};
      when(
        () => mockRemoteDataSource.loadHomeStats(),
      ).thenAnswer((_) async => stats);

      final result = await repository.loadHomeStats();

      expect(result['pagesThisMonth'], 10);
      expect(result['averageRating'], 3.5);
      expect(result['booksTouched'], isA<int>());
      verify(() => mockRemoteDataSource.loadHomeStats()).called(1);
      verify(() => mockLocalDataSource.getBooks()).called(1);
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

    group('logReadingSession', () {
      test('envía sesión al remoto cuando está online y emite stats', () async {
        connectivity.isOnline = true;
        when(
          () => mockRemoteDataSource.logReadingSession(
            'book-1',
            25,
            sessionDate: any(named: 'sessionDate'),
          ),
        ).thenAnswer((_) async {});

        final expectation = expectLater(repository.statsChanges, emits(null));

        await repository.logReadingSession('book-1', 25);

        await expectation;
        verify(
          () => mockRemoteDataSource.logReadingSession(
            'book-1',
            25,
            sessionDate: any(named: 'sessionDate'),
          ),
        ).called(1);
        verifyNever(() => mockHiveService.enqueuePendingOperation(any()));
      });

      test('cuando está offline encola la operación y emite stats', () async {
        connectivity.isOnline = false;

        final expectation = expectLater(repository.statsChanges, emits(null));

        await repository.logReadingSession('book-1', 30);

        await expectation;
        final captured = verify(
          () => mockHiveService.enqueuePendingOperation(captureAny()),
        ).captured;
        expect(captured, isNotEmpty);
        final payload = captured.first as Map<String, dynamic>;
        expect(payload['type'], 'reading_session');
        expect(payload['bookId'], 'book-1');
        expect(payload['pagesDelta'], 30);
        expect(payload['sessionDate'], isNotNull);
        verifyNever(
          () => mockRemoteDataSource.logReadingSession(
            any(),
            any(),
            sessionDate: any(named: 'sessionDate'),
          ),
        );
      });

      test(
        'cuando Supabase falla encola la operación y sigue notificando',
        () async {
          connectivity.isOnline = true;
          when(
            () => mockRemoteDataSource.logReadingSession(
              'book-1',
              15,
              sessionDate: any(named: 'sessionDate'),
            ),
          ).thenThrow(Exception('network'));

          final expectation = expectLater(repository.statsChanges, emits(null));

          await repository.logReadingSession('book-1', 15);

          await expectation;
          final captured = verify(
            () => mockHiveService.enqueuePendingOperation(captureAny()),
          ).captured;
          expect(captured, isNotEmpty);
          final payload = captured.first as Map<String, dynamic>;
          expect(payload['type'], 'reading_session');
          expect(payload['bookId'], 'book-1');
          expect(payload['pagesDelta'], 15);
          expect(payload['sessionDate'], isNotNull);
        },
      );

      test(
        'logReadingSession acepta deltas negativos cuando corrige progreso',
        () async {
          connectivity.isOnline = true;
          when(
            () => mockRemoteDataSource.logReadingSession(
              any(),
              any(),
              sessionDate: any(named: 'sessionDate'),
            ),
          ).thenAnswer((_) async {});

          await repository.logReadingSession('book-1', -12);

          verify(
            () => mockRemoteDataSource.logReadingSession(
              'book-1',
              -12,
              sessionDate: any(named: 'sessionDate'),
            ),
          ).called(1);
        },
      );
    });

    group('processPendingOperations', () {
      test('does nothing when offline', () async {
        connectivity.isOnline = false;
        when(() => mockHiveService.getPendingOperations()).thenAnswer(
          (_) async => [
            MapEntry('1', <String, dynamic>{'type': 'add'}),
          ],
        );

        await repository.processPendingOperations();

        verifyNever(() => mockRemoteDataSource.addBook(any()));
      });

      test('replays queued add operations when online', () async {
        connectivity.isOnline = true;
        final pendingBook = testBook.copyWith(pendingSync: true);
        when(() => mockHiveService.getPendingOperations()).thenAnswer(
          (_) async => [
            MapEntry('op-1', <String, dynamic>{
              'type': 'add',
              'payload': pendingBook.toJson(),
            }),
          ],
        );
        when(
          () => mockRemoteDataSource.addBook(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockLocalDataSource.getBook(pendingBook.id),
        ).thenAnswer((_) async => pendingBook);
        when(
          () => mockLocalDataSource.updateBook(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockHiveService.removePendingOperation('op-1'),
        ).thenAnswer((_) async {});

        await repository.processPendingOperations();

        verify(() => mockRemoteDataSource.addBook(any())).called(1);
        verify(() => mockHiveService.removePendingOperation('op-1')).called(1);
        final captured = verify(
          () => mockLocalDataSource.updateBook(captureAny()),
        ).captured;
        expect(captured, isNotEmpty);
        final saved = captured.first as BookModel;
        expect(saved.pendingSync, isFalse);
      });

      test(
        'reproduce sesiones de lectura pendientes cuando está online',
        () async {
          connectivity.isOnline = true;
          final sessionDate = DateTime(2024, 2, 10);
          when(() => mockHiveService.getPendingOperations()).thenAnswer(
            (_) async => [
              MapEntry('op-session', <String, dynamic>{
                'type': 'reading_session',
                'bookId': 'book-1',
                'pagesDelta': 18,
                'sessionDate': sessionDate.toIso8601String(),
              }),
            ],
          );

          await repository.processPendingOperations();

          verify(
            () => mockRemoteDataSource.logReadingSession(
              'book-1',
              18,
              sessionDate: sessionDate,
            ),
          ).called(1);
          verify(
            () => mockHiveService.removePendingOperation('op-session'),
          ).called(1);
        },
      );
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
