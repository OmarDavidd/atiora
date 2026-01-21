import 'package:equatable/equatable.dart';

class ProfileModel extends Equatable {
  final String id;
  final String userId;
  final String displayName;
  final int totalBooks;
  final List<String> booksRead;
  final String themePreference;
  final DateTime createdAt;
  final DateTime updatedAt;

  const ProfileModel({
    required this.id,
    required this.userId,
    required this.displayName,
    required this.totalBooks,
    required this.booksRead,
    required this.themePreference,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'user_id': userId,
    'display_name': displayName,
    'total_books': totalBooks,
    'books_read': booksRead,
    'theme_preference': themePreference,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory ProfileModel.fromJson(Map<String, dynamic> json) => ProfileModel(
    id: json['id'] as String,
    userId: json['user_id'] as String,
    displayName: json['display_name'] as String? ?? 'Usuario',
    totalBooks: json['total_books'] as int? ?? 0,
    booksRead: List<String>.from(json['books_read'] ?? []),
    themePreference: json['theme_preference'] as String? ?? 'system',
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  @override
  List<Object?> get props => [
    id,
    userId,
    displayName,
    totalBooks,
    booksRead,
    themePreference,
    createdAt,
    updatedAt,
  ];

  ProfileModel copyWith({
    String? id,
    String? userId,
    String? displayName,
    int? totalBooks,
    List<String>? booksRead,
    String? themePreference,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      totalBooks: totalBooks ?? this.totalBooks,
      booksRead: booksRead ?? this.booksRead,
      themePreference: themePreference ?? this.themePreference,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
