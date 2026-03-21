import 'package:atiora/core/errors/app_exception.dart';

class ErrorHandler {
  static String map(AppException exception) {
    switch (exception.type) {
      case AppExceptionType.auth:
        return exception.message;
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
