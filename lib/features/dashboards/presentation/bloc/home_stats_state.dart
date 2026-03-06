abstract class HomeStatsState {}

class HomeStatsInitial extends HomeStatsState {}
class HomeStatsLoading extends HomeStatsState {}
class HomeStatsLoaded extends HomeStatsState {
  final HomeStatsData stats;

  HomeStatsLoaded(this.stats);
}
class HomeStatsError extends HomeStatsState {
  final String message;
  HomeStatsError(this.message);
}

class HomeStatsData {
  final int pagesMonth;
  final int streak;
  final int booksMonth;

  HomeStatsData({
    required this.pagesMonth,
    required this.streak,
    required this.booksMonth,
  });
}
