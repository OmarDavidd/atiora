import 'dart:async';

import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:atiora/features/books/domain/repositories/book_repository.dart';
import 'home_stats_event.dart';
import 'home_stats_state.dart';

class HomeStatsBloc extends Bloc<HomeStatsEvent, HomeStatsState> {
  final BooksRepository _repository;
  StreamSubscription<void>? _statsSub;

  HomeStatsBloc(this._repository) : super(HomeStatsInitial()) {
    on<LoadHomeStats>((event, emit) async {
      if (state is HomeStatsLoading) return;
      emit(HomeStatsLoading());
      try {
        final homeStats = await _repository.loadHomeStats();
        final data = HomeStatsData(
          pagesMonth: homeStats['pagesThisMonth'] ?? 0,
          booksMonth: homeStats['booksTouched'] ?? 0,
          streak: homeStats['streak'] ?? 0,
          averageRating:
              (homeStats['averageRating'] as num?)?.toDouble() ?? 0.0,
        );
        emit(HomeStatsLoaded(data));
      } catch (e) {
        emit(HomeStatsError('Error: $e'));
      }
    }, transformer: droppable());

    _statsSub = _repository.statsChanges.listen((_) {
      add(LoadHomeStats());
    });
  }

  @override
  Future<void> close() {
    _statsSub?.cancel();
    return super.close();
  }
}
