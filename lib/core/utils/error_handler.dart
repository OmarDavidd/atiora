class ErrorHandler {
  static String handleAuthError(String message) {
    if (message.contains('invalid_credentials')) {
      return 'Credenciales inválidas. Verifica email/contraseña';
    } else if (message.contains('email_not_confirmed')) {
      return 'Confirma tu email antes de iniciar sesión';
    }
    return message;
  }
}
