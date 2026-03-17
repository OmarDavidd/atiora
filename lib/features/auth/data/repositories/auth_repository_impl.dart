import 'package:atiora/core/di/providers/auth_provider.dart';
import 'package:atiora/core/errors/app_exception.dart';
import 'package:atiora/data/models/user_model.dart';
import 'package:atiora/features/auth/domain/repositories/auth_repository.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthProvider _provider;

  AuthRepositoryImpl(this._provider);

  @override
  UserModel? get currentUser => _provider.currentUser != null
      ? UserModel(
          id: _provider.currentUser!.id,
          email: _provider.currentUser!.email ?? '',
          joinedAt: _provider.currentUser!.createdAt != null
              ? DateTime.tryParse(_provider.currentUser!.createdAt!)
              : null,
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
          email: response.user!.email ?? '',
          joinedAt: response.user!.createdAt != null
              ? DateTime.tryParse(response.user!.createdAt!)
              : null,
        );
        return user;
      }
      return null;
    } catch (e) {
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('invalid_credentials') ||
          errorMessage.contains('invalid login') ||
          errorMessage.contains('wrong password')) {
        throw AppException.auth('Credenciales inválidas');
      }
      if (errorMessage.contains('network') ||
          errorMessage.contains('connection')) {
        throw AppException.auth('Sin conexión a internet');
      }
      throw AppException.auth('Error al iniciar sesión');
    }
  }

  @override
  Future<UserModel?> signUp(String email, String password) async {
    try {
      final response = await _provider.signUp(email, password);

      if (response.user != null) {
        final user = UserModel(
          id: response.user!.id,
          email: response.user!.email ?? '',
          joinedAt: response.user!.createdAt != null
              ? DateTime.tryParse(response.user!.createdAt!)
              : null,
        );
        return user;
      }
      return null;
    } catch (e) {
      if (e is AppException) rethrow;
      final errorMessage = e.toString().toLowerCase();
      if (errorMessage.contains('user_already_exists') ||
          errorMessage.contains('already registered')) {
        throw AppException.auth('Este correo ya está registrado');
      }
      if (errorMessage.contains('network') ||
          errorMessage.contains('connection')) {
        throw AppException.auth('Sin conexión a internet');
      }
      throw AppException.auth('Error al registrar usuario');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _provider.signOut();
    } catch (e, stackTrace) {
      throw AppException.auth(
        'No pudimos cerrar sesión',
        cause: e,
        stackTrace: stackTrace,
      );
    }
  }
}
