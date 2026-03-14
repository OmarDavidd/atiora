import 'package:equatable/equatable.dart';

class AddBookDraft extends Equatable {
  final String title;
  final String author;
  final List<String> genres;
  final int totalPages;
  final int currentPage;
  final String? status;
  final int rating;

  const AddBookDraft({
    this.title = '',
    this.author = '',
    this.genres = const [],
    this.totalPages = 1,
    this.currentPage = 1,
    this.status,
    this.rating = 0,
  });

  factory AddBookDraft.fromJson(Map<String, dynamic> json) {
    return AddBookDraft(
      title: (json['title'] as String?)?.trim() ?? '',
      author: (json['author'] as String?)?.trim() ?? '',
      genres: List<String>.from(
        json['genre'] ?? json['genres'] ?? const <String>[],
      ),
      totalPages: json['totalPages'] as int? ?? 1,
      currentPage: json['currentPage'] as int? ?? 1,
      status: json['status'] as String?,
      rating: json['rating'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'title': title,
      'author': author,
      'genre': genres,
      'totalPages': totalPages,
      'currentPage': currentPage,
      'status': status,
      'rating': rating,
    };
  }

  AddBookDraft copyWith({
    String? title,
    String? author,
    List<String>? genres,
    int? totalPages,
    int? currentPage,
    String? status,
    int? rating,
  }) {
    return AddBookDraft(
      title: title ?? this.title,
      author: author ?? this.author,
      genres: genres ?? this.genres,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      status: status ?? this.status,
      rating: rating ?? this.rating,
    );
  }

  bool get hasContent {
    return title.trim().isNotEmpty ||
        author.trim().isNotEmpty ||
        genres.isNotEmpty ||
        totalPages != 1 ||
        currentPage != 1 ||
        (status?.isNotEmpty ?? false) ||
        rating != 0;
  }

  @override
  List<Object?> get props => [
    title,
    author,
    genres,
    totalPages,
    currentPage,
    status,
    rating,
  ];
}
