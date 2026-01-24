import 'package:atiora/data/models/user_model.dart';

abstract class AuthRepository {
  Future<UserModel?> signUp(String email, String password);
  Future<UserModel?> signIn(String email, String password);
  Future<void> signOut();
  UserModel? get currentUser;
  bool get isLoggedIn;
}
