import 'package:equatable/equatable.dart';

class BookModel extends Equatable {
  final String id;
  final String userId;
  final String title;
  final String? author;
  final List<String> genre;
  final int totalPages;
  final int currentPage;
  final String status;
  final double rating;
  final String? coverUrl;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? startedAt;
  final DateTime? finishedAt;
  final bool pendingSync;

  const BookModel({
    required this.id,
    required this.userId,
    required this.title,
    this.author,
    required this.genre,
    required this.totalPages,
    required this.currentPage,
    required this.status,
    required this.rating,
    this.coverUrl,
    required this.createdAt,
    required this.updatedAt,
    this.startedAt,
    this.finishedAt,
    this.pendingSync = false,
  });

  Map<String, dynamic> toRemoteJson() => {
    'title': title,
    'author': author,
    'genre': genre,
    'total_pages': totalPages,
    'current_page': currentPage,
    'status': status,
    'rating': rating,
    'cover_url': coverUrl,
    if (startedAt != null) 'started_at': startedAt!.toIso8601String(),
    if (finishedAt != null) 'finished_at': finishedAt!.toIso8601String(),
  };

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'title': title,
    'author': author,
    'genre': genre,
    'total_pages': totalPages,
    'current_page': currentPage,
    'status': status,
    'rating': rating,
    'cover_url': coverUrl,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
    if (startedAt != null) 'started_at': startedAt!.toIso8601String(),
    if (finishedAt != null) 'finished_at': finishedAt!.toIso8601String(),
    'pending_sync': pendingSync,
  };

  factory BookModel.fromJson(Map<String, dynamic> json) => BookModel(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    title: json['title'] as String,
    author: json['author'] as String?,
    genre: List<String>.from(json['genre'] ?? []),
    totalPages: json['total_pages'] as int? ?? 0,
    currentPage: json['current_page'] as int? ?? 0,
    status: json['status'] as String? ?? 'leyendo',
    rating: (json['rating'] as num?)?.toDouble() ?? 0.0,
    coverUrl: json['cover_url'] as String?,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
    startedAt: json['started_at'] != null
        ? DateTime.parse(json['started_at'])
        : null,
    finishedAt: json['finished_at'] != null
        ? DateTime.parse(json['finished_at'])
        : null,
    pendingSync: json['pending_sync'] as bool? ?? false,
  );

  @override
  List<Object?> get props => [
    id,
    userId,
    title,
    author,
    genre,
    totalPages,
    currentPage,
    status,
    rating,
    coverUrl,
    createdAt,
    updatedAt,
    startedAt,
    finishedAt,
    pendingSync,
  ];

  BookModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? author,
    List<String>? genre,
    int? totalPages,
    int? currentPage,
    String? status,
    double? rating,
    String? coverUrl,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? startedAt,
    DateTime? finishedAt,
    bool? pendingSync,
  }) {
    return BookModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      author: author ?? this.author,
      genre: genre ?? this.genre,
      totalPages: totalPages ?? this.totalPages,
      currentPage: currentPage ?? this.currentPage,
      status: status ?? this.status,
      rating: rating ?? this.rating,
      coverUrl: coverUrl ?? this.coverUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      startedAt: startedAt ?? this.startedAt,
      finishedAt: finishedAt ?? this.finishedAt,
      pendingSync: pendingSync ?? this.pendingSync,
    );
  }
}
