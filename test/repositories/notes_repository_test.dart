import 'package:atiora/core/storage/hive_service.dart';
import 'package:atiora/data/models/note_model.dart';
import 'package:atiora/features/books/data/datasources/notes_local_datasource.dart';
import 'package:atiora/features/books/data/datasources/notes_remote_datasource.dart';
import 'package:atiora/features/books/data/repositories/notes_repository_impl.dart';
import 'package:connectivity_plus_platform_interface/connectivity_plus_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockNotesLocalDataSource extends Mock implements NotesLocalDataSource {}

class MockNotesRemoteDataSource extends Mock implements NotesRemoteDataSource {}

class MockHiveService extends Mock implements HiveService {}

class _StubConnectivity implements ConnectivityPlatform {
  final bool isOnline;

  _StubConnectivity({required this.isOnline});

  @override
  Stream<List<ConnectivityResult>> get onConnectivityChanged =>
      const Stream<List<ConnectivityResult>>.empty();

  @override
  Future<List<ConnectivityResult>> checkConnectivity() async {
    return isOnline ? [ConnectivityResult.wifi] : [ConnectivityResult.none];
  }
}

void main() {
  late MockNotesLocalDataSource mockLocalDataSource;
  late MockNotesRemoteDataSource mockRemoteDataSource;
  late NotesRepositoryImpl repository;
  late MockHiveService mockHiveService;

  setUpAll(() {
    registerFallbackValue(
      NoteModel(
        id: 'fallback',
        bookId: 'book-1',
        userId: 'user-1',
        noteType: 'resumen',
        content: 'Fallback',
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
    );
  });

  setUp(() {
    mockLocalDataSource = MockNotesLocalDataSource();
    mockRemoteDataSource = MockNotesRemoteDataSource();
    mockHiveService = MockHiveService();
  });

  group('NotesRepositoryImpl', () {
    final testNote = NoteModel(
      id: 'note-1',
      bookId: 'book-1',
      userId: 'user-1',
      noteType: 'resumen',
      content: 'Nota de prueba',
      pageNumber: 10,
      createdAt: DateTime(2024, 1, 1),
      updatedAt: DateTime(2024, 1, 1),
    );

    group('getNotesByBook', () {
      test('retorna notas remotas cuando está online', () async {
        final connectivity = _StubConnectivity(isOnline: true);
        repository = NotesRepositoryImpl(
          mockLocalDataSource,
          mockRemoteDataSource,
          connectivity: connectivity,
          hive: mockHiveService,
        );

        when(
          () => mockRemoteDataSource.getNotesByBook(any()),
        ).thenAnswer((_) async => [testNote]);
        when(
          () => mockHiveService.getPendingOperations(),
        ).thenAnswer((_) async => []);
        when(() => mockHiveService.deleteNote(any())).thenAnswer((_) async {});
        when(() => mockLocalDataSource.addNote(any())).thenAnswer((_) async {});

        final result = await repository.getNotesByBook('book-1');

        expect(result.length, 1);
        expect(result.first.id, 'note-1');
        verify(() => mockRemoteDataSource.getNotesByBook('book-1')).called(1);
      });

      test('retorna notas locales cuando falla el remoto', () async {
        final connectivity = _StubConnectivity(isOnline: true);
        repository = NotesRepositoryImpl(
          mockLocalDataSource,
          mockRemoteDataSource,
          connectivity: connectivity,
          hive: mockHiveService,
        );

        when(
          () => mockRemoteDataSource.getNotesByBook(any()),
        ).thenThrow(Exception('Error de red'));
        when(
          () => mockLocalDataSource.getNotesByBook(any()),
        ).thenAnswer((_) async => [testNote]);
        when(
          () => mockHiveService.getPendingOperations(),
        ).thenAnswer((_) async => []);

        final result = await repository.getNotesByBook('book-1');

        expect(result.length, 1);
        expect(result.first.id, 'note-1');
        verify(() => mockLocalDataSource.getNotesByBook('book-1')).called(1);
      });
    });

    group('addNote', () {
      test('guarda local y remota cuando está online', () async {
        final connectivity = _StubConnectivity(isOnline: true);
        repository = NotesRepositoryImpl(
          mockLocalDataSource,
          mockRemoteDataSource,
          connectivity: connectivity,
          hive: mockHiveService,
        );

        when(() => mockLocalDataSource.addNote(any())).thenAnswer((_) async {});
        when(
          () => mockRemoteDataSource.addNote(any()),
        ).thenAnswer((_) async {});

        await repository.addNote(testNote);

        verify(() => mockLocalDataSource.addNote(testNote)).called(1);
        verify(() => mockRemoteDataSource.addNote(testNote)).called(1);
      });

      test('guarda local y encola operación cuando está offline', () async {
        final connectivity = _StubConnectivity(isOnline: false);
        repository = NotesRepositoryImpl(
          mockLocalDataSource,
          mockRemoteDataSource,
          connectivity: connectivity,
          hive: mockHiveService,
        );

        when(() => mockLocalDataSource.addNote(any())).thenAnswer((_) async {});
        when(
          () => mockHiveService.enqueuePendingOperation(any()),
        ).thenAnswer((_) async => 'queued');

        await repository.addNote(testNote);

        verify(() => mockLocalDataSource.addNote(testNote)).called(1);
        verify(() => mockHiveService.enqueuePendingOperation(any())).called(1);
        verifyNever(() => mockRemoteDataSource.addNote(any()));
      });

      test('lanza excepción cuando falla el guardado local', () async {
        final connectivity = _StubConnectivity(isOnline: true);
        repository = NotesRepositoryImpl(
          mockLocalDataSource,
          mockRemoteDataSource,
          connectivity: connectivity,
          hive: mockHiveService,
        );

        when(
          () => mockLocalDataSource.addNote(any()),
        ).thenThrow(Exception('Error de Hive'));

        expect(() => repository.addNote(testNote), throwsA(isA<Exception>()));
      });
    });

    group('updateNote', () {
      test('actualiza local y remota cuando está online', () async {
        final connectivity = _StubConnectivity(isOnline: true);
        repository = NotesRepositoryImpl(
          mockLocalDataSource,
          mockRemoteDataSource,
          connectivity: connectivity,
          hive: mockHiveService,
        );

        when(
          () => mockLocalDataSource.updateNote(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockRemoteDataSource.updateNote(any()),
        ).thenAnswer((_) async {});

        final updatedNote = testNote.copyWith(content: 'Contenido actualizado');
        await repository.updateNote(updatedNote);

        verify(() => mockLocalDataSource.updateNote(any())).called(1);
        verify(() => mockRemoteDataSource.updateNote(any())).called(1);
      });

      test('actualiza local y encola operación cuando está offline', () async {
        final connectivity = _StubConnectivity(isOnline: false);
        repository = NotesRepositoryImpl(
          mockLocalDataSource,
          mockRemoteDataSource,
          connectivity: connectivity,
          hive: mockHiveService,
        );

        when(
          () => mockLocalDataSource.updateNote(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockHiveService.enqueuePendingOperation(any()),
        ).thenAnswer((_) async => 'queued');

        await repository.updateNote(testNote);

        verify(() => mockLocalDataSource.updateNote(any())).called(1);
        verify(() => mockHiveService.enqueuePendingOperation(any())).called(1);
      });
    });

    group('deleteNote', () {
      test('elimina local y remota cuando está online', () async {
        final connectivity = _StubConnectivity(isOnline: true);
        repository = NotesRepositoryImpl(
          mockLocalDataSource,
          mockRemoteDataSource,
          connectivity: connectivity,
          hive: mockHiveService,
        );

        when(
          () => mockLocalDataSource.deleteNote(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockRemoteDataSource.deleteNote(any()),
        ).thenAnswer((_) async {});

        await repository.deleteNote('note-1');

        verify(() => mockLocalDataSource.deleteNote('note-1')).called(1);
        verify(() => mockRemoteDataSource.deleteNote('note-1')).called(1);
      });

      test('elimina local y encola operación cuando está offline', () async {
        final connectivity = _StubConnectivity(isOnline: false);
        repository = NotesRepositoryImpl(
          mockLocalDataSource,
          mockRemoteDataSource,
          connectivity: connectivity,
          hive: mockHiveService,
        );

        when(
          () => mockLocalDataSource.deleteNote(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockHiveService.enqueuePendingOperation(any()),
        ).thenAnswer((_) async => 'queued');

        await repository.deleteNote('note-1');

        verify(() => mockLocalDataSource.deleteNote('note-1')).called(1);
        verify(() => mockHiveService.enqueuePendingOperation(any())).called(1);
      });
    });

    group('processPendingNotesOperations', () {
      test('no hace nada cuando está offline', () async {
        final connectivity = _StubConnectivity(isOnline: false);
        repository = NotesRepositoryImpl(
          mockLocalDataSource,
          mockRemoteDataSource,
          connectivity: connectivity,
          hive: mockHiveService,
        );

        await repository.processPendingNotesOperations();

        verifyNever(() => mockHiveService.getPendingOperations());
        verifyNever(() => mockRemoteDataSource.addNote(any()));
      });

      test('procesa operaciones pendientes cuando está online', () async {
        final connectivity = _StubConnectivity(isOnline: true);
        repository = NotesRepositoryImpl(
          mockLocalDataSource,
          mockRemoteDataSource,
          connectivity: connectivity,
          hive: mockHiveService,
        );

        final pendingOp = MapEntry('key-1', <String, dynamic>{
          'type': 'note_add',
          'payload': testNote.toJson(),
        });

        when(
          () => mockHiveService.getPendingOperations(),
        ).thenAnswer((_) async => [pendingOp]);
        when(
          () => mockRemoteDataSource.addNote(any()),
        ).thenAnswer((_) async {});
        when(
          () => mockHiveService.removePendingOperation(any()),
        ).thenAnswer((_) async {});

        await repository.processPendingNotesOperations();

        verify(() => mockRemoteDataSource.addNote(any())).called(1);
        verify(() => mockHiveService.removePendingOperation('key-1')).called(1);
      });
    });

    group('getRecentNotes', () {
      test('retorna notas remotas recientes cuando está online', () async {
        final connectivity = _StubConnectivity(isOnline: true);
        repository = NotesRepositoryImpl(
          mockLocalDataSource,
          mockRemoteDataSource,
          connectivity: connectivity,
          hive: mockHiveService,
        );

        final notes = [
          testNote,
          testNote.copyWith(id: 'note-2', createdAt: DateTime(2024, 1, 2)),
          testNote.copyWith(id: 'note-3', createdAt: DateTime(2024, 1, 3)),
        ];

        when(
          () => mockRemoteDataSource.getAllNotes(),
        ).thenAnswer((_) async => notes);
        when(
          () => mockHiveService.getPendingOperations(),
        ).thenAnswer((_) async => []);

        final result = await repository.getRecentNotes(limit: 2);

        expect(result.length, 2);
      });
    });
  });
}
