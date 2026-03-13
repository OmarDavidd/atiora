import 'package:flutter_test/flutter_test.dart';
import 'package:atiora/core/utils/error_handler.dart';

void main() {
  group('ErrorHandler', () {
    group('handleAuthError', () {
      test('should return friendly message for invalid_credentials', () {
        const message = 'invalid_credentials';
        final result = ErrorHandler.handleAuthError(message);

        expect(result, 'Credenciales inválidas. Verifica email/contraseña');
      });

      test('should return friendly message for email_not_confirmed', () {
        const message = 'email_not_confirmed';
        final result = ErrorHandler.handleAuthError(message);

        expect(result, 'Confirma tu email antes de iniciar sesión');
      });

      test('should return original message for unknown errors', () {
        const message = 'Some unknown error occurred';
        final result = ErrorHandler.handleAuthError(message);

        expect(result, message);
      });

      test('should return original message for empty string', () {
        const message = '';
        final result = ErrorHandler.handleAuthError(message);

        expect(result, '');
      });

      test('should handle messages containing error codes', () {
        const message = 'Error: invalid_credentials - try again';
        final result = ErrorHandler.handleAuthError(message);

        expect(result, 'Credenciales inválidas. Verifica email/contraseña');
      });
    });
  });
}
