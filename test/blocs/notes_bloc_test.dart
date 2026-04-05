import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:atiora/data/models/note_model.dart';
import 'package:atiora/features/books/domain/repositories/notes_repository.dart';
import 'package:atiora/features/books/presentation/bloc/notes_bloc.dart';
import 'package:atiora/features/books/presentation/bloc/notes_event.dart';
import 'package:atiora/features/books/presentation/bloc/notes_state.dart';

class MockNotesRepository extends Mock implements NotesRepository {}

class FakeNoteModel extends Fake implements NoteModel {}

void main() {
  late MockNotesRepository mockRepository;

  setUpAll(() {
    registerFallbackValue(FakeNoteModel());
  });

  setUp(() {
    mockRepository = MockNotesRepository();
  });

  group('NotesBloc', () {
    final testNotes = [
      NoteModel(
        id: 'note-1',
        bookId: 'book-1',
        userId: 'user-1',
        noteType: 'resumen',
        content: 'Nota de prueba 1',
        pageNumber: 10,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 1),
      ),
      NoteModel(
        id: 'note-2',
        bookId: 'book-1',
        userId: 'user-1',
        noteType: 'cita',
        content: 'Nota de prueba 2',
        pageNumber: 20,
        createdAt: DateTime(2024, 1, 2),
        updatedAt: DateTime(2024, 1, 2),
      ),
    ];

    group('LoadNotes', () {
      blocTest<NotesBloc, NotesState>(
        'emite [NotesLoading, NotesLoaded] cuando LoadNotes tiene éxito',
        build: () {
          when(
            () => mockRepository.getNotesByBook(any()),
          ).thenAnswer((_) async => testNotes);
          return NotesBloc(mockRepository);
        },
        act: (bloc) => bloc.add(LoadNotes('book-1')),
        expect: () => [NotesLoading(), NotesLoaded(testNotes, 'book-1')],
        verify: (_) {
          verify(() => mockRepository.getNotesByBook('book-1')).called(1);
        },
      );

      blocTest<NotesBloc, NotesState>(
        'emite [NotesLoading, NotesError] cuando LoadNotes falla',
        build: () {
          when(
            () => mockRepository.getNotesByBook(any()),
          ).thenThrow(Exception('Error de red'));
          return NotesBloc(mockRepository);
        },
        act: (bloc) => bloc.add(LoadNotes('book-1')),
        expect: () => [
          NotesLoading(),
          isA<NotesError>().having(
            (e) => e.message,
            'message',
            'Error al cargar notas',
          ),
        ],
      );

      blocTest<NotesBloc, NotesState>(
        'emite [NotesLoading, NotesLoaded] con lista vacía cuando no hay notas',
        build: () {
          when(
            () => mockRepository.getNotesByBook(any()),
          ).thenAnswer((_) async => []);
          return NotesBloc(mockRepository);
        },
        act: (bloc) => bloc.add(LoadNotes('book-1')),
        expect: () => [NotesLoading(), NotesLoaded([], 'book-1')],
      );
    });

    group('AddNote', () {
      final newNote = NoteModel(
        id: 'note-new',
        bookId: 'book-1',
        userId: 'user-1',
        noteType: 'resumen',
        content: 'Nueva nota',
        pageNumber: 5,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      blocTest<NotesBloc, NotesState>(
        'emite [NoteAddSuccess] y recarga notas cuando AddNote tiene éxito',
        build: () {
          when(() => mockRepository.addNote(any())).thenAnswer((_) async {});
          when(
            () => mockRepository.getNotesByBook(any()),
          ).thenAnswer((_) async => testNotes);
          return NotesBloc(mockRepository);
        },
        act: (bloc) => bloc.add(AddNote(newNote)),
        expect: () => [
          NoteAddSuccess(),
          NotesLoading(),
          NotesLoaded(testNotes, 'book-1'),
        ],
        verify: (_) {
          verify(() => mockRepository.addNote(any())).called(1);
        },
      );

      blocTest<NotesBloc, NotesState>(
        'emite [NotesError] cuando AddNote falla',
        build: () {
          when(
            () => mockRepository.addNote(any()),
          ).thenThrow(Exception('Error al guardar'));
          return NotesBloc(mockRepository);
        },
        act: (bloc) => bloc.add(AddNote(newNote)),
        expect: () => [
          isA<NotesError>().having(
            (e) => e.message,
            'message',
            'Error al añadir nota',
          ),
        ],
      );
    });

    group('UpdateNote', () {
      final updatedNote = NoteModel(
        id: 'note-1',
        bookId: 'book-1',
        userId: 'user-1',
        noteType: 'resumen',
        content: 'Nota actualizada',
        pageNumber: 10,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 3),
      );

      blocTest<NotesBloc, NotesState>(
        'emite [NoteUpdateSuccess] y recarga notas cuando UpdateNote tiene éxito',
        build: () {
          when(() => mockRepository.updateNote(any())).thenAnswer((_) async {});
          when(
            () => mockRepository.getNotesByBook(any()),
          ).thenAnswer((_) async => testNotes);
          return NotesBloc(mockRepository);
        },
        act: (bloc) => bloc.add(UpdateNote(updatedNote)),
        expect: () => [
          NoteUpdateSuccess(),
          NotesLoading(),
          NotesLoaded(testNotes, 'book-1'),
        ],
      );

      blocTest<NotesBloc, NotesState>(
        'emite [NotesError] cuando UpdateNote falla',
        build: () {
          when(
            () => mockRepository.updateNote(any()),
          ).thenThrow(Exception('Error al actualizar'));
          return NotesBloc(mockRepository);
        },
        act: (bloc) => bloc.add(UpdateNote(updatedNote)),
        expect: () => [
          isA<NotesError>().having(
            (e) => e.message,
            'message',
            'Error al actualizar nota',
          ),
        ],
      );
    });

    group('DeleteNote', () {
      blocTest<NotesBloc, NotesState>(
        'emite [NoteDeleteSuccess] y recarga notas cuando DeleteNote tiene éxito',
        build: () {
          when(() => mockRepository.deleteNote(any())).thenAnswer((_) async {});
          when(
            () => mockRepository.getNotesByBook(any()),
          ).thenAnswer((_) async => [testNotes.first]);
          return NotesBloc(mockRepository);
        },
        act: (bloc) => bloc.add(DeleteNote('note-2', 'book-1')),
        expect: () => [
          NoteDeleteSuccess(),
          NotesLoading(),
          NotesLoaded([testNotes.first], 'book-1'),
        ],
        verify: (_) {
          verify(() => mockRepository.deleteNote('note-2')).called(1);
        },
      );

      blocTest<NotesBloc, NotesState>(
        'emite [NotesError] cuando DeleteNote falla',
        build: () {
          when(
            () => mockRepository.deleteNote(any()),
          ).thenThrow(Exception('Error al eliminar'));
          return NotesBloc(mockRepository);
        },
        act: (bloc) => bloc.add(DeleteNote('note-1', 'book-1')),
        expect: () => [
          isA<NotesError>().having(
            (e) => e.message,
            'message',
            'Error al eliminar nota',
          ),
        ],
      );
    });

    group('SyncPendingNotes', () {
      blocTest<NotesBloc, NotesState>(
        'no hace nada cuando no hay notas cargadas',
        build: () {
          when(
            () => mockRepository.processPendingNotesOperations(),
          ).thenAnswer((_) async {});
          return NotesBloc(mockRepository);
        },
        act: (bloc) => bloc.add(SyncPendingNotes()),
        expect: () => [],
        verify: (_) {
          verify(
            () => mockRepository.processPendingNotesOperations(),
          ).called(1);
        },
      );

      blocTest<NotesBloc, NotesState>(
        'recarga notas cuando hay estado NotesLoaded',
        build: () {
          when(
            () => mockRepository.processPendingNotesOperations(),
          ).thenAnswer((_) async {});
          when(
            () => mockRepository.getNotesByBook(any()),
          ).thenAnswer((_) async => testNotes);
          return NotesBloc(mockRepository);
        },
        seed: () => NotesLoaded(testNotes, 'book-1'),
        act: (bloc) => bloc.add(SyncPendingNotes()),
        expect: () => [NotesLoading(), NotesLoaded(testNotes, 'book-1')],
      );
    });
  });
}
