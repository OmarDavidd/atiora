import 'package:equatable/equatable.dart';

class UserModel extends Equatable {
  final String id;
  final String email;

  const UserModel({required this.id, required this.email});

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(id: json['id'], email: json['email']);
  }

  Map<String, dynamic> toJson() => {'id': id, 'email': email};

  @override
  List<Object?> get props => [id, email];
}
