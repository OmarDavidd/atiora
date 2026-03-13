import 'package:bloc_test/bloc_test.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:atiora/features/books/domain/repositories/book_repository.dart';
import 'package:atiora/features/dashboards/presentation/bloc/home_stats_bloc.dart';
import 'package:atiora/features/dashboards/presentation/bloc/home_stats_event.dart';
import 'package:atiora/features/dashboards/presentation/bloc/home_stats_state.dart';

class MockBooksRepository extends Mock implements BooksRepository {}

void main() {
  late MockBooksRepository mockRepository;

  setUp(() {
    mockRepository = MockBooksRepository();
  });

  group('HomeStatsBloc', () {
    test('initial state should be HomeStatsInitial', () {
      final bloc = HomeStatsBloc(mockRepository);
      expect(bloc.state, isA<HomeStatsInitial>());
    });

    blocTest<HomeStatsBloc, HomeStatsState>(
      'emits [HomeStatsLoading, HomeStatsLoaded] when LoadHomeStats succeeds',
      build: () {
        when(() => mockRepository.loadHomeStats()).thenAnswer(
          (_) async => {
            'pagesThisMonth': 500,
            'booksTouched': 5,
            'booksFinished': 2,
            'streak': 10,
          },
        );
        return HomeStatsBloc(mockRepository);
      },
      act: (bloc) => bloc.add(LoadHomeStats()),
      expect: () => [isA<HomeStatsLoading>(), isA<HomeStatsLoaded>()],
      verify: (_) {
        verify(() => mockRepository.loadHomeStats()).called(1);
      },
    );

    blocTest<HomeStatsBloc, HomeStatsState>(
      'emits [HomeStatsLoading, HomeStatsError] when LoadHomeStats throws',
      build: () {
        when(
          () => mockRepository.loadHomeStats(),
        ).thenThrow(Exception('Failed to load'));
        return HomeStatsBloc(mockRepository);
      },
      act: (bloc) => bloc.add(LoadHomeStats()),
      expect: () => [isA<HomeStatsLoading>(), isA<HomeStatsError>()],
    );

    blocTest<HomeStatsBloc, HomeStatsState>(
      'HomeStatsLoaded contains correct data',
      build: () {
        when(() => mockRepository.loadHomeStats()).thenAnswer(
          (_) async => {
            'pagesThisMonth': 300,
            'booksTouched': 3,
            'booksFinished': 1,
            'streak': 7,
          },
        );
        return HomeStatsBloc(mockRepository);
      },
      act: (bloc) => bloc.add(LoadHomeStats()),
      verify: (bloc) {
        final state = bloc.state as HomeStatsLoaded;
        expect(state.stats.pagesMonth, 300);
        expect(state.stats.booksMonth, 3);
        expect(state.stats.streak, 7);
      },
    );
  });
}
