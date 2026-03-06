import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:atiora/features/books/domain/repositories/book_repository.dart';
import 'home_stats_event.dart';
import 'home_stats_state.dart';

class HomeStatsBloc extends Bloc<HomeStatsEvent, HomeStatsState> {
  final BooksRepository _repository;

  HomeStatsBloc(this._repository) : super(HomeStatsInitial()) {
    on<LoadHomeStats>((event, emit) async {
      debugPrint('🟡 HomeStatsBloc: CARGANDO...');
      if (state is HomeStatsLoading) return;
      emit(HomeStatsLoading());
      try {
        final homeStats = await _repository.loadHomeStats();
        debugPrint('🟢 Datos RAW: $homeStats');
        emit(
          HomeStatsLoaded(
            HomeStatsData(
              pagesMonth: homeStats['pagesThisMonth'] ?? 0,
              booksMonth: homeStats['booksTouched'] ?? 0,
              streak: homeStats['streak'] ?? 0,
            ),
          ),
        );
        debugPrint('✅ HomeStatsLoaded OK');
      } catch (e) {
        debugPrint('❌ HomeStats ERROR: $e');
        emit(HomeStatsError("Error: $e"));
      }
    }, transformer: droppable());
  }
}
