/// Base exception for all app-level errors.
class AppException implements Exception {
  final String message;
  final String? code;
  final StackTrace? stackTrace;

  const AppException({
    required this.message,
    this.code,
    this.stackTrace,
  });

  @override
  String toString() => 'AppException($code): $message';
}

/// Network/API error with HTTP status.
class ApiException extends AppException {
  final int? statusCode;
  final dynamic responseData;

  const ApiException({
    required super.message,
    this.statusCode,
    this.responseData,
    super.code,
    super.stackTrace,
  });

  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isServerError => statusCode != null && statusCode! >= 500;
  bool get isNetworkError => statusCode == null;

  @override
  String toString() =>
      'ApiException($statusCode): $message';
}

/// Auth-related errors.
class AuthException extends AppException {
  const AuthException({
    required super.message,
    super.code,
    super.stackTrace,
  });
}

/// Validation errors from form state.
class ValidationException extends AppException {
  final Map<String, String> fieldErrors;

  const ValidationException({
    required super.message,
    this.fieldErrors = const {},
    super.code,
  });
}
