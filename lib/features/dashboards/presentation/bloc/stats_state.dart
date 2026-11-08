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
  final bool isGlobal;

  const StatsLoaded(this.stats, {this.isGlobal = false});

  @override
  List<Object?> get props => [stats, isGlobal];
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
  final int booksCompletedThisMonth;
  final int booksPaused;
  final int booksPending;
  final int totalNotes;
  final int notesThisMonth;
  final double averageRating;
  final int pagesThisMonth;
  final int currentStreak;
  final int globalStreak;
  final Map<String, int> booksByState;
  final Map<String, int> booksByMonth;
  final Map<String, int> topGenres;
  final List<MonthlyBooks> monthlyBooks;
  final int totalPagesRead;
  final int totalBooksRead;
  final double globalAverageRating;

  const StatsData({
    required this.totalBooks,
    required this.booksReading,
    required this.booksCompleted,
    required this.booksCompletedThisMonth,
    required this.booksPaused,
    required this.booksPending,
    required this.totalNotes,
    required this.notesThisMonth,
    required this.averageRating,
    required this.pagesThisMonth,
    required this.currentStreak,
    required this.globalStreak,
    required this.booksByState,
    required this.booksByMonth,
    required this.topGenres,
    required this.monthlyBooks,
    required this.totalPagesRead,
    required this.totalBooksRead,
    required this.globalAverageRating,
  });

  @override
  List<Object?> get props => [
    totalBooks,
    booksReading,
    booksCompleted,
    booksCompletedThisMonth,
    booksPaused,
    booksPending,
    totalNotes,
    notesThisMonth,
    averageRating,
    pagesThisMonth,
    currentStreak,
    globalStreak,
    booksByState,
    booksByMonth,
    topGenres,
    monthlyBooks,
    totalPagesRead,
    totalBooksRead,
    globalAverageRating,
  ];
}

class MonthlyBooks extends Equatable {
  final String month;
  final int count;

  const MonthlyBooks({required this.month, required this.count});

  @override
  List<Object?> get props => [month, count];
}
