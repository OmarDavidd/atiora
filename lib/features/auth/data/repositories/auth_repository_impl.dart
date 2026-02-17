import 'package:atiora/core/di/providers/auth_provider.dart';
import 'package:atiora/data/models/user_model.dart';
import 'package:atiora/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthProvider _provider;

  AuthRepositoryImpl(this._provider);

  @override
  UserModel? get currentUser => _provider.currentUser != null
      ? UserModel(
          id: _provider.currentUser!.id,
          email: _provider.currentUser!.email!,
        )
      : null;

  @override
  bool get isLoggedIn => _provider.currentUser != null;

  @override
  Future<UserModel?> signIn(String email, String password) async {
    try {
      final response = await _provider.signIn(email, password);

      if (response.user != null) {
        final user = UserModel(
          id: response.user!.id,
          email: response.user!.email!,
        );
        return user;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<UserModel?> signUp(String email, String password) async {
    try {
      final response = await _provider.signUp(email, password);

      if (response.user != null) {
        final user = UserModel(
          id: response.user!.id,
          email: response.user!.email!,
        );
        return user;
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _provider.signOut();
    } catch (e) {
      rethrow;
    }
  }
}
