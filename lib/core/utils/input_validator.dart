import 'package:atiora/core/errors/app_exception.dart';

class InputValidator {
  static bool isValidEmail(String email) {
    if (email.isEmpty) return false;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  static bool isValidPassword(String password) {
    return password.length >= 6;
  }

  static void validateEmail(String email) {
    if (!isValidEmail(email)) {
      throw AppException.validation('Email no válido');
    }
  }

  static void validatePassword(String password) {
    if (!isValidPassword(password)) {
      throw AppException.validation(
        'La contraseña debe tener al menos 6 caracteres',
      );
    }
  }

  static void validateCredentials(String email, String password) {
    validateEmail(email);
    validatePassword(password);
  }
}
