import 'package:atiora/core/errors/app_exception.dart';

class ErrorHandler {
  static String handleAuthError(String message) {
    if (message.contains('invalid_credentials')) {
      return 'Credenciales inválidas. Verifica email/contraseña';
    } else if (message.contains('email_not_confirmed')) {
      return 'Confirma tu email antes de iniciar sesión';
    }
    return message;
  }

  static String map(AppException exception) {
    switch (exception.type) {
      case AppExceptionType.auth:
        return handleAuthError(exception.message);
      case AppExceptionType.unauthorized:
        return 'Inicia sesión para continuar';
      case AppExceptionType.network:
        return 'Sin conexión. Intenta nuevamente.';
      case AppExceptionType.validation:
        return exception.message;
      case AppExceptionType.cache:
        return 'No pudimos leer tus datos locales';
      case AppExceptionType.unknown:
        return 'Algo salió mal. Intenta de nuevo.';
    }
  }
}
