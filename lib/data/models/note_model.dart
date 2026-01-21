import 'package:equatable/equatable.dart';

class NoteModel extends Equatable {
  final String id;
  final String bookId;
  final String userId;
  final String noteType;
  final String content;
  final int? pageNumber;
  final DateTime createdAt;
  final DateTime updatedAt;

  const NoteModel({
    required this.id,
    required this.bookId,
    required this.userId,
    required this.noteType,
    required this.content,
    this.pageNumber,
    required this.createdAt,
    required this.updatedAt,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'book_id': bookId,
    'user_id': userId,
    'note_type': noteType,
    'content': content,
    'page_number': pageNumber,
    'created_at': createdAt.toIso8601String(),
    'updated_at': updatedAt.toIso8601String(),
  };

  factory NoteModel.fromJson(Map<String, dynamic> json) => NoteModel(
    id: json['id'] as String,
    bookId: json['book_id'] as String,
    userId: json['user_id'] as String,
    noteType: json['note_type'] as String? ?? 'resumen',
    content: json['content'] as String,
    pageNumber: json['page_number'] as int?,
    createdAt: DateTime.parse(json['created_at'] as String),
    updatedAt: DateTime.parse(json['updated_at'] as String),
  );

  @override
  List<Object?> get props => [
    id,
    bookId,
    userId,
    noteType,
    content,
    pageNumber,
    createdAt,
    updatedAt,
  ];

  NoteModel copyWith({
    String? id,
    String? bookId,
    String? userId,
    String? noteType,
    String? content,
    int? pageNumber,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return NoteModel(
      id: id ?? this.id,
      bookId: bookId ?? this.bookId,
      userId: userId ?? this.userId,
      noteType: noteType ?? this.noteType,
      content: content ?? this.content,
      pageNumber: pageNumber ?? this.pageNumber,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
