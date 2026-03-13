import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:atiora/data/models/book_model.dart';
import 'package:atiora/features/books/domain/repositories/book_repository.dart';
import 'package:atiora/features/books/presentation/bloc/books_bloc.dart';
import 'package:atiora/features/books/presentation/bloc/books_event.dart';
import 'package:atiora/features/books/presentation/bloc/books_state.dart';

class MockBooksRepository extends Mock implements BooksRepository {}

void main() {
  late MockBooksRepository mockRepository;

  setUp(() {
    mockRepository = MockBooksRepository();
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

  group('BooksBloc', () {
    final testBooks = [
      BookModel(
        id: 'book-1',
        userId: 'user-1',
        title: 'Clean Code',
        author: 'Robert Martin',
        genre: ['programming'],
        totalPages: 400,
        currentPage: 100,
        status: 'leyendo',
        rating: 4.5,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
      ),
      BookModel(
        id: 'book-2',
        userId: 'user-1',
        title: 'The Pragmatic Programmer',
        author: 'David Thomas',
        genre: ['programming'],
        totalPages: 350,
        currentPage: 0,
        status: 'pendiente',
        rating: 0.0,
        createdAt: DateTime(2024, 1, 3),
        updatedAt: DateTime(2024, 1, 3),
      ),
    ];

    test('initial state should be BooksInitial', () {
      final bloc = BooksBloc(mockRepository);
      expect(bloc.state, isA<BooksInitial>());
    });

    blocTest<BooksBloc, BooksState>(
      'emits [BooksLoading, BooksLoaded] when LoadBooks succeeds',
      build: () {
        when(
          () => mockRepository.getBooks(),
        ).thenAnswer((_) async => testBooks);
        return BooksBloc(mockRepository);
      },
      act: (bloc) => bloc.add(LoadBooks()),
      expect: () => [isA<BooksLoading>(), isA<BooksLoaded>()],
      verify: (_) {
        verify(() => mockRepository.getBooks()).called(1);
      },
    );

    blocTest<BooksBloc, BooksState>(
      'emits [BooksLoading, BooksError] when LoadBooks throws',
      build: () {
        when(
          () => mockRepository.getBooks(),
        ).thenThrow(Exception('Network error'));
        return BooksBloc(mockRepository);
      },
      act: (bloc) => bloc.add(LoadBooks()),
      expect: () => [isA<BooksLoading>(), isA<BooksError>()],
    );

    blocTest<BooksBloc, BooksState>(
      'emits updated BooksLoaded when UpdateBookState succeeds',
      build: () {
        when(
          () => mockRepository.updateBookState('book-1', 'terminado'),
        ).thenAnswer((_) async {});
        return BooksBloc(mockRepository);
      },
      seed: () => BooksLoaded(testBooks),
      act: (bloc) =>
          bloc.add(UpdateBookState(bookId: 'book-1', newState: 'terminado')),
      expect: () => [isA<BooksLoaded>()],
      verify: (_) {
        verify(
          () => mockRepository.updateBookState('book-1', 'terminado'),
        ).called(1);
      },
    );

    blocTest<BooksBloc, BooksState>(
      'reloads books when UpdateBookState fails',
      build: () {
        when(
          () => mockRepository.updateBookState('book-1', 'terminado'),
        ).thenThrow(Exception('Update failed'));
        when(
          () => mockRepository.getBooks(),
        ).thenAnswer((_) async => testBooks);
        return BooksBloc(mockRepository);
      },
      seed: () => BooksLoaded(testBooks),
      act: (bloc) =>
          bloc.add(UpdateBookState(bookId: 'book-1', newState: 'terminado')),
      expect: () => [
        isA<BooksLoaded>(),
        isA<BooksLoading>(),
        isA<BooksLoaded>(),
      ],
    );
  });
}
