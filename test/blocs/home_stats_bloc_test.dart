import 'dart:async';

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
  late StreamController<void> statsController;

  setUp(() {
    mockRepository = MockBooksRepository();
    statsController = StreamController<void>.broadcast();
    when(
      () => mockRepository.statsChanges,
    ).thenAnswer((_) => statsController.stream);
  });

  tearDown(() async {
    await statsController.close();
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
          (_) async => {'pagesThisMonth': 500, 'booksTouched': 5, 'streak': 10},
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
          (_) async => {'pagesThisMonth': 300, 'booksTouched': 3, 'streak': 7},
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

    blocTest<HomeStatsBloc, HomeStatsState>(
      'recarga estadísticas cuando el stream statsChanges emite',
      build: () {
        var callCount = 0;
        when(() => mockRepository.loadHomeStats()).thenAnswer((_) async {
          callCount += 1;
          return {
            'pagesThisMonth': callCount * 100,
            'booksTouched': callCount,
            'streak': callCount,
          };
        });
        return HomeStatsBloc(mockRepository);
      },
      act: (bloc) async {
        bloc.add(LoadHomeStats());
        await Future<void>.microtask(() {});
        statsController.add(null);
      },
      expect: () => [
        isA<HomeStatsLoading>(),
        isA<HomeStatsLoaded>(),
        isA<HomeStatsLoading>(),
        isA<HomeStatsLoaded>(),
      ],
      verify: (_) {
        verify(() => mockRepository.loadHomeStats()).called(2);
      },
    );
  });
}
