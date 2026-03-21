import 'package:atiora/core/di/providers/auth_provider.dart';
import 'package:atiora/core/errors/app_exception.dart';
import 'package:atiora/data/models/user_model.dart';
import 'package:atiora/features/auth/domain/repositories/auth_repository.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthProvider _provider;

  AuthRepositoryImpl(this._provider);

  @override
  UserModel? get currentUser {
    final user = _provider.currentUser;
    if (user == null) return null;
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      joinedAt: DateTime.tryParse(user.createdAt),
    );
  }

  @override
  bool get isLoggedIn => _provider.currentUser != null;

  @override
  Future<UserModel?> signIn(String email, String password) async {
    try {
      final response = await _provider.signIn(email, password);
      if (response.user != null) {
        return _toUserModel(response.user!);
      }
      return null;
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      throw AppException.auth('Error al iniciar sesión');
    }
  }

  @override
  Future<UserModel?> signUp(String email, String password) async {
    try {
      final response = await _provider.signUp(email, password);
      if (response.user != null) {
        return _toUserModel(response.user!);
      }
      return null;
    } on AuthException catch (e) {
      throw _mapAuthException(e);
    } catch (e) {
      if (e is AppException) rethrow;
      throw AppException.auth('Error al registrar usuario');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _provider.signOut();
    } catch (e) {
      throw AppException.auth('No pudimos cerrar sesión', cause: e);
    }
  }

  UserModel _toUserModel(User user) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      joinedAt: DateTime.tryParse(user.createdAt),
    );
  }

  AppException _mapAuthException(AuthException e) {
    final statusCode = e.statusCode;
    if (statusCode == '400' || statusCode == '401') {
      return AppException.auth('Credenciales inválidas');
    }
    if (statusCode == '422') {
      return AppException.validation('Email o contraseña no válidos');
    }
    if (statusCode == '429') {
      return AppException.auth('Demasiados intentos. Intenta más tarde');
    }
    if (e.message.contains('already registered') ||
        e.message.contains('user_already_exists')) {
      return AppException.auth('Este correo ya está registrado');
    }
    if (e.message.contains('Email not confirmed')) {
      return AppException.auth('Confirma tu email antes de iniciar sesión');
    }
    return AppException.auth('Error de autenticación');
  }
}
