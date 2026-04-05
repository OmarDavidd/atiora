import 'package:equatable/equatable.dart';

abstract class StatsState extends Equatable {
  const StatsState();

  @override
  List<Object?> get props => [];
}

class StatsInitial extends StatsState {}

class StatsLoading extends StatsState {}

class StatsLoaded extends StatsState {
  final StatsData stats;

  const StatsLoaded(this.stats);

  @override
  List<Object?> get props => [stats];
}

class StatsError extends StatsState {
  final String message;

  const StatsError(this.message);

  @override
  List<Object?> get props => [message];
}

class StatsData extends Equatable {
  final int totalBooks;
  final int booksReading;
  final int booksCompleted;
  final int booksPaused;
  final int booksPending;
  final int totalNotes;
  final double averageRating;
  final int pagesThisMonth;
  final int currentStreak;
  final Map<String, int> booksByState;
  final Map<String, int> booksByMonth;
  final Map<String, int> topGenres;
  final List<MonthlyBooks> monthlyBooks;

  const StatsData({
    required this.totalBooks,
    required this.booksReading,
    required this.booksCompleted,
    required this.booksPaused,
    required this.booksPending,
    required this.totalNotes,
    required this.averageRating,
    required this.pagesThisMonth,
    required this.currentStreak,
    required this.booksByState,
    required this.booksByMonth,
    required this.topGenres,
    required this.monthlyBooks,
  });

  @override
  List<Object?> get props => [
    totalBooks,
    booksReading,
    booksCompleted,
    booksPaused,
    booksPending,
    totalNotes,
    averageRating,
    pagesThisMonth,
    currentStreak,
    booksByState,
    booksByMonth,
    topGenres,
    monthlyBooks,
  ];
}

class MonthlyBooks extends Equatable {
  final String month;
  final int count;

  const MonthlyBooks({required this.month, required this.count});

  @override
  List<Object?> get props => [month, count];
}
