import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;
  final DateTime? joinedAt;

  const UserModel({required this.id, required this.email, this.joinedAt});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String,
      email: json['email'] as String,
      joinedAt: json['created_at'] != null
          ? DateTime.tryParse(json['created_at'] as String)
          : null,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'email': email,
    if (joinedAt != null) 'created_at': joinedAt!.toIso8601String(),
  };

  UserModel copyWith({String? id, String? email, DateTime? joinedAt}) {
    return UserModel(
      id: id ?? this.id,
      email: email ?? this.email,
      joinedAt: joinedAt ?? this.joinedAt,
    );
  }

  @override
  List<Object?> get props => [id, email, joinedAt];
}
