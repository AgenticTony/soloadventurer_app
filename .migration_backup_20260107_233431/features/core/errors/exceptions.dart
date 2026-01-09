/// Base class for all application exceptions
abstract class AppException implements Exception {
  final String message;
  final String code;

  const AppException(this.message, {required this.code});

  @override
  String toString() => 'AppException($code): $message';
}

/// Authentication related exceptions
class AuthException extends AppException {
  const AuthException(super.message, {required super.code});
}

/// Network related exceptions
class NetworkException extends AppException {
  const NetworkException(super.message, {required super.code});
}

/// Storage related exceptions
class StorageException extends AppException {
  const StorageException(super.message, {required super.code});
}

/// Data related exceptions
class DataException extends AppException {
  const DataException(super.message, {required super.code});
}

/// Permission related exceptions
class PermissionException extends AppException {
  const PermissionException(super.message, {required super.code});
}

/// Configuration related exceptions
class ConfigurationException extends AppException {
  const ConfigurationException(super.message, {required super.code});
}

/// Validation related exceptions
class ValidationException extends AppException {
  const ValidationException(super.message, {required super.code});
}

/// Business logic related exceptions
class BusinessException extends AppException {
  const BusinessException(super.message, {required super.code});
}
