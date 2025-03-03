/// Base class for all failures in the domain layer
abstract class Failure {
  /// Message describing the failure
  final String message;

  /// Creates a new [Failure] with the given message
  const Failure(this.message);
}

/// Represents a server failure
class ServerFailure extends Failure {
  /// HTTP status code
  final int? statusCode;

  /// Creates a new [ServerFailure] with the given message and status code
  const ServerFailure({
    required String message,
    this.statusCode,
  }) : super(message);
}

/// Represents a connection failure
class ConnectionFailure extends Failure {
  /// Creates a new [ConnectionFailure] with the given message
  const ConnectionFailure({
    required String message,
  }) : super(message);
}

/// Represents a cache failure
class CacheFailure extends Failure {
  /// Creates a new [CacheFailure] with the given message
  const CacheFailure({
    required String message,
  }) : super(message);
}

/// Represents an authentication failure
class AuthFailure extends Failure {
  /// Creates a new [AuthFailure] with the given message
  const AuthFailure({
    required String message,
  }) : super(message);
}

/// Represents a validation failure
class ValidationFailure extends Failure {
  /// Field that failed validation
  final String field;

  /// Creates a new [ValidationFailure] with the given message and field
  const ValidationFailure({
    required String message,
    required this.field,
  }) : super(message);
}

/// Represents an unexpected failure
class UnexpectedFailure extends Failure {
  /// Creates a new [UnexpectedFailure] with the given message
  const UnexpectedFailure({
    required String message,
  }) : super(message);
}
