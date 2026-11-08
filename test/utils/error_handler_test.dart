import 'package:atiora/core/errors/app_exception.dart';
import 'package:atiora/core/utils/error_handler.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('ErrorHandler', () {
    test('map returns friendly message per exception type', () {
      final authMessage = ErrorHandler.map(
        AppException.auth('Credenciales inválidas'),
      );
      expect(authMessage, 'Credenciales inválidas');

      final networkMessage = ErrorHandler.map(AppException.network('falló'));
      expect(networkMessage, 'Sin conexión. Intenta nuevamente.');

      final validationMessage = ErrorHandler.map(
        AppException.validation('Campo requerido'),
      );
      expect(validationMessage, 'Campo requerido');

      final cacheMessage = ErrorHandler.map(
        AppException.cache('No pudimos leer tus datos'),
      );
      expect(cacheMessage, 'No pudimos leer tus datos locales');

      final unknownMessage = ErrorHandler.map(
        AppException.unknown('Algo salió mal'),
      );
      expect(unknownMessage, 'Algo salió mal. Intenta de nuevo.');

      final unauthorizedMessage = ErrorHandler.map(
        AppException.unauthorized('No autorizado'),
      );
      expect(unauthorizedMessage, 'Inicia sesión para continuar');
    });
  });
}
