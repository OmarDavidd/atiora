import 'package:atiora/features/books/domain/repositories/book_repository.dart';
import 'package:atiora/features/dashboards/presentation/bloc/stats_event.dart';
import 'package:atiora/features/dashboards/presentation/bloc/stats_state.dart';
import 'package:bloc_concurrency/bloc_concurrency.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class StatsBloc extends Bloc<StatsEvent, StatsState> {
  final BooksRepository _repository;
  bool _isGlobal = false;

  StatsBloc(this._repository) : super(StatsInitial()) {
    on<LoadStats>(_onLoadStats, transformer: droppable());
    on<RefreshStats>(
      (event, emit) => add(LoadStats()),
      transformer: droppable(),
    );
    on<ToggleStatsPeriod>(_onToggleStatsPeriod, transformer: restartable());
  }

  Future<void> _onToggleStatsPeriod(
    ToggleStatsPeriod event,
    Emitter<StatsState> emit,
  ) async {
    // Guardar estado actual brevemente para transición suave
    if (state is StatsLoaded) {
      emit(StatsLoading());
    }
    await Future.delayed(const Duration(milliseconds: 200));
    _isGlobal = !_isGlobal;
    add(LoadStats());
  }

  Future<void> _onLoadStats(LoadStats event, Emitter<StatsState> emit) async {
    emit(StatsLoading());
    try {
      final statsData = await _repository.loadStats();
      emit(StatsLoaded(statsData, isGlobal: _isGlobal));
    } catch (e) {
      emit(StatsError('No pudimos cargar las estadísticas'));
    }
  }
}
