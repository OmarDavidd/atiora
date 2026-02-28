import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:atiora/features/books/domain/repositories/book_repository.dart';
import 'home_stats_event.dart';
import 'home_stats_state.dart';

class HomeStatsBloc extends Bloc<HomeStatsEvent, HomeStatsState> {
  final BooksRepository _repository;

  HomeStatsBloc(this._repository) : super(HomeStatsInitial()) {
    on<LoadHomeStats>((event, emit) async {
      if (state is HomeStatsLoading) return;
      emit(HomeStatsLoading());
      try {
        final homeStats = await _repository.loadHomeStats();
        emit(
          HomeStatsLoaded(
            HomeStatsData(
              pagesToday: homeStats['pagesToday'],
              pagesMonth: homeStats['pagesMonth'],
              streak: homeStats['streak'],
              booksMonth: homeStats['booksMonth'],
            ),
          ),
        );
      } catch (e) {
        emit(HomeStatsError("Error al cargar estadísticas: ${e.toString()}"));
      }
    }, transformer: droppable());
  }
}
