/// Base exception class for all app exceptions
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final dynamic details;

  const AppException({required this.message, this.code, this.details});

  @override
  String toString() => 'AppException: $message${code != null ? ' (Code: $code)' : ''}';
}

/// Exception thrown when network request fails
class NetworkException extends AppException {
  const NetworkException({required super.message, super.code, super.details});
}

/// Exception thrown when server returns an error
class ServerException extends AppException {
  const ServerException({required super.message, super.code, super.details});
}

/// Exception thrown when authentication fails
class AuthException extends AppException {
  const AuthException({required super.message, super.code, super.details});
}

/// Exception thrown when validation fails
class ValidationException extends AppException {
  const ValidationException({required super.message, super.code, super.details});
}

/// Exception thrown when cache operations fail
class CacheException extends AppException {
  const CacheException({required super.message, super.code, super.details});
}

/// Exception thrown when permission is denied
class PermissionException extends AppException {
  const PermissionException({required super.message, super.code, super.details});
}

/// Exception thrown when resource is not found
class NotFoundException extends AppException {
  const NotFoundException({required super.message, super.code, super.details});
}

/// Exception thrown when operation times out
class TimeoutException extends AppException {
  const TimeoutException({required super.message, super.code, super.details});
}

/// Exception thrown for unknown/unexpected errors
class UnknownException extends AppException {
  const UnknownException({required super.message, super.code, super.details});
}
