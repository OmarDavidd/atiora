enum AppExceptionType {
  auth,
  unauthorized,
  network,
  validation,
  cache,
  unknown,
}

class AppException implements Exception {
  final AppExceptionType type;
  final String message;
  final Object? cause;
  final StackTrace? stackTrace;

  const AppException({
    required this.type,
    required this.message,
    this.cause,
    this.stackTrace,
  });

  factory AppException.auth(
    String message, {
    Object? cause,
    StackTrace? stackTrace,
  }) => AppException(
    type: AppExceptionType.auth,
    message: message,
    cause: cause,
    stackTrace: stackTrace,
  );

  factory AppException.unauthorized(
    String message, {
    Object? cause,
    StackTrace? stackTrace,
  }) => AppException(
    type: AppExceptionType.unauthorized,
    message: message,
    cause: cause,
    stackTrace: stackTrace,
  );

  factory AppException.network(
    String message, {
    Object? cause,
    StackTrace? stackTrace,
  }) => AppException(
    type: AppExceptionType.network,
    message: message,
    cause: cause,
    stackTrace: stackTrace,
  );

  factory AppException.validation(
    String message, {
    Object? cause,
    StackTrace? stackTrace,
  }) => AppException(
    type: AppExceptionType.validation,
    message: message,
    cause: cause,
    stackTrace: stackTrace,
  );

  factory AppException.cache(
    String message, {
    Object? cause,
    StackTrace? stackTrace,
  }) => AppException(
    type: AppExceptionType.cache,
    message: message,
    cause: cause,
    stackTrace: stackTrace,
  );

  factory AppException.unknown(
    String message, {
    Object? cause,
    StackTrace? stackTrace,
  }) => AppException(
    type: AppExceptionType.unknown,
    message: message,
    cause: cause,
    stackTrace: stackTrace,
  );
}
