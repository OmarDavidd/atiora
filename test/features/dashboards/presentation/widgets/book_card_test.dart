import 'package:atiora/data/models/book_model.dart';
import 'package:atiora/features/books/presentation/bloc/books_bloc.dart';
import 'package:atiora/features/books/presentation/bloc/books_event.dart';
import 'package:atiora/features/books/presentation/bloc/books_state.dart';
import 'package:atiora/features/dashboards/presentation/widgets/book_card.dart';
import 'package:atiora/features/dashboards/presentation/widgets/books_carousel.dart';
import 'package:bloc_test/bloc_test.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';

class MockBooksBloc extends MockBloc<BooksEvent, BooksState>
    implements BooksBloc {}

class _FakeBooksEvent extends Fake implements BooksEvent {}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  setUpAll(() {
    registerFallbackValue(_FakeBooksEvent());
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMessageHandler('flutter/assets', (message) async {
          return ByteData(0);
        });
  });

  group('BookCard', () {
    testWidgets('shows pending pill when sync is pending', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BookCard(
              title: 'Clean Code',
              author: 'Robert C. Martin',
              coverPath: 'assets/missingbook.webp',
              isPendingSync: true,
            ),
          ),
        ),
      );

      expect(find.text('En cola'), findsOneWidget);
    });

    testWidgets('hides pending pill when sync is not pending', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: BookCard(
              title: 'Clean Code',
              author: 'Robert C. Martin',
              coverPath: 'assets/missingbook.webp',
              isPendingSync: false,
            ),
          ),
        ),
      );

      expect(find.text('En cola'), findsNothing);
    });
  });

  group('BooksCarousel', () {
    late MockBooksBloc mockBloc;

    setUp(() {
      mockBloc = MockBooksBloc();
    });

    testWidgets('shows banner when there are pending operations', (
      tester,
    ) async {
      final pendingBook = BookModel(
        id: 'book-1',
        userId: 'user-1',
        title: 'Clean Code',
        author: 'Robert C. Martin',
        genre: const ['programming'],
        totalPages: 400,
        currentPage: 100,
        status: 'leyendo',
        rating: 4.5,
        createdAt: DateTime(2024, 1, 1),
        updatedAt: DateTime(2024, 1, 2),
        pendingSync: true,
      );
      final loadedState = BooksLoaded([
        pendingBook,
      ], hasPendingOperations: true);
      when(() => mockBloc.state).thenReturn(loadedState);
      whenListen(
        mockBloc,
        Stream<BooksState>.fromIterable([loadedState]),
        initialState: loadedState,
      );
      when(() => mockBloc.add(any(that: isA<BooksEvent>()))).thenAnswer((_) {});

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: BlocProvider<BooksBloc>.value(
              value: mockBloc,
              child: const BooksCarousel(),
            ),
          ),
        ),
      );

      // Allow BlocBuilder to rebuild with provided state
      await tester.pump();

      expect(
        find.text('Sin conexión: sincronizaremos tus cambios al volver la red'),
        findsOneWidget,
      );
      expect(find.text('Clean Code'), findsWidgets);
    });
  });
}
