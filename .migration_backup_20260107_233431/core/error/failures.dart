library;

/// Failure classes using Dart 3 sealed classes
///
/// This implementation uses native Dart 3 sealed classes instead of freezed
/// to avoid build_runner circular dependency issues. Sealed classes enable
/// exhaustive pattern matching with the switch statement.
///
/// ## Usage
///
/// ```dart
/// final failure = Failure.server(message: 'Internal server error', statusCode: 500);
///
/// // Pattern matching
/// switch (failure) {
///   case ServerFailure():
///     print('Server error: ${failure.message}');
///     break;
///   case NetworkFailure():
///     print('Network error: ${failure.message}');
///     break;
///   // ... all cases must be handled (exhaustive)
/// }
///
/// // Using extension methods
/// if (failure.requiresLogout) {
///   // Clear auth state
/// }
///
/// String userMessage = failure.userMessage;
/// ```
///
/// Base sealed class for all failures in the domain layer
///
/// The `sealed` modifier ensures all subclasses are known at compile time
/// and defined in the same library, enabling exhaustive pattern matching.
sealed class Failure {
  /// Message describing the failure
  final String message;

  /// Creates a new [Failure] with the given message
  const Failure(this.message);

  /// Server failure (4xx, 5xx errors)
  ///
  /// Use this when the server returns an HTTP error status code.
  factory Failure.server({
    required String message,
    int? statusCode,
    dynamic error,
  }) = ServerFailure;

  /// Network failure (no connection, timeout)
  ///
  /// Use this when network connectivity is unavailable or times out.
  factory Failure.network({
    required String message,
    dynamic error,
  }) = NetworkFailure;

  /// Cache failure (local storage issues)
  ///
  /// Use this when local cache or database operations fail.
  factory Failure.cache({
    required String message,
    dynamic error,
  }) = CacheFailure;

  /// Authentication failure (login, token issues)
  ///
  /// Use this when authentication or authorization fails.
  factory Failure.auth({
    required String message,
    dynamic error,
  }) = AuthFailure;

  /// Validation failure (invalid input)
  ///
  /// Use this when user input fails validation rules.
  factory Failure.validation({
    required String message,
    Map<String, String>? fieldErrors,
  }) = ValidationFailure;

  /// Not found failure (resource doesn't exist)
  ///
  /// Use this when a requested resource cannot be found.
  factory Failure.notFound({
    required String message,
    String? resourceType,
  }) = NotFoundFailure;

  /// Permission denied failure
  ///
  /// Use this when the user lacks required permissions.
  factory Failure.permissionDenied({
    required String message,
    String? permission,
  }) = PermissionDeniedFailure;

  /// Unknown/unexpected failure
  ///
  /// Use this as a catch-all for unexpected errors.
  factory Failure.unknown({
    String? message,
    dynamic error,
  }) = UnknownFailure;

  @override
  String toString() => message;
}

/// Server failure (4xx, 5xx errors)
///
/// Represents HTTP errors returned by the server, such as:
/// - 400 Bad Request
/// - 401 Unauthorized
/// - 403 Forbidden
/// - 404 Not Found
/// - 500 Internal Server Error
/// - 503 Service Unavailable
final class ServerFailure extends Failure {
  /// HTTP status code
  final int? statusCode;

  /// Underlying error object
  final dynamic error;

  /// Creates a new [ServerFailure]
  const ServerFailure({
    required String message,
    this.statusCode,
    this.error,
  }) : super(message);
}

/// Network failure (no connection, timeout)
///
/// Represents network connectivity issues:
/// - No internet connection
/// - DNS resolution failures
/// - Connection timeouts
/// - Network unreachable
final class NetworkFailure extends Failure {
  /// Underlying error object
  final dynamic error;

  /// Creates a new [NetworkFailure]
  const NetworkFailure({
    required String message,
    this.error,
  }) : super(message);
}

/// Cache failure (local storage issues)
///
/// Represents local storage failures:
/// - Database errors
/// - File system errors
/// - Serialization/deserialization failures
/// - Cache miss when data was expected
final class CacheFailure extends Failure {
  /// Underlying error object
  final dynamic error;

  /// Creates a new [CacheFailure]
  const CacheFailure({
    required String message,
    this.error,
  }) : super(message);
}

/// Authentication failure (login, token issues)
///
/// Represents authentication and authorization failures:
/// - Invalid credentials
/// - Expired access token
/// - Invalid refresh token
/// - Session expired
/// - Account locked/disabled
final class AuthFailure extends Failure {
  /// Underlying error object
  final dynamic error;

  /// Creates a new [AuthFailure]
  const AuthFailure({
    required String message,
    this.error,
  }) : super(message);
}

/// Validation failure (invalid input)
///
/// Represents input validation failures:
/// - Required field missing
/// - Invalid email format
/// - Password too weak
/// - Invalid date format
final class ValidationFailure extends Failure {
  /// Map of field names to error messages
  final Map<String, String>? fieldErrors;

  /// Creates a new [ValidationFailure]
  const ValidationFailure({
    required String message,
    this.fieldErrors,
  }) : super(message);
}

/// Not found failure (resource doesn't exist)
///
/// Represents missing resource errors:
/// - User not found
/// - Trip not found
/// - Journal entry not found
/// - Configuration missing
final class NotFoundFailure extends Failure {
  /// Type of resource that was not found
  final String? resourceType;

  /// Creates a new [NotFoundFailure]
  const NotFoundFailure({
    required String message,
    this.resourceType,
  }) : super(message);
}

/// Permission denied failure
///
/// Represents authorization failures:
/// - Insufficient permissions
/// - Resource access denied
/// - Action not allowed for current user
/// - Admin-only access required
final class PermissionDeniedFailure extends Failure {
  /// The permission that was denied
  final String? permission;

  /// Creates a new [PermissionDeniedFailure]
  const PermissionDeniedFailure({
    required String message,
    this.permission,
  }) : super(message);
}

/// Unknown/unexpected failure
///
/// Represents unexpected errors that don't fit other categories:
/// - Uncaught exceptions
/// - Unexpected null values
/// - Unknown error states
final class UnknownFailure extends Failure {
  /// Underlying error object
  final dynamic error;

  /// Creates a new [UnknownFailure]
  const UnknownFailure({
    String? message,
    this.error,
  }) : super(message ?? 'An unknown error occurred');
}

// ============================================================================
// EXTENSION METHODS
// ============================================================================

/// Extension on [Failure] providing common utility methods
extension FailureExtensions on Failure {
  /// Whether this failure requires the user to be logged out
  ///
  /// Returns `true` for auth failures that indicate the user's session
  /// is invalid or expired and they should be logged out.
  bool get requiresLogout {
    return switch (this) {
      AuthFailure() => true,
      _ => false,
    };
  }

  /// Whether this failure is recoverable (user can retry)
  ///
  /// Returns `true` for failures that are transient and can be retried:
  /// - Network failures (connection might come back)
  /// - Server failures with 5xx status codes (server might recover)
  /// - Cache failures (can retry with fresh data)
  ///
  /// Returns `false` for permanent failures:
  /// - Validation failures (user needs to fix input)
  /// - Not found failures (resource doesn't exist)
  /// - Permission denied failures (user lacks access)
  /// - Auth failures (require re-authentication, use `requiresLogout` instead)
  /// - 4xx server errors (client error, won't be fixed by retrying)
  bool get isRecoverable {
    return switch (this) {
      NetworkFailure() => true,
      CacheFailure() => true,
      ServerFailure(statusCode: final code) => code != null && code >= 500,
      AuthFailure() => false, // Requires re-auth, not simple retry
      ValidationFailure() => false,
      NotFoundFailure() => false,
      PermissionDeniedFailure() => false,
      UnknownFailure() => false,
    };
  }

  /// A user-friendly message suitable for display in the UI
  ///
  /// This provides a more user-friendly version of the error message
  /// that can be shown to end users.
  String get userMessage {
    return switch (this) {
      NetworkFailure() => 'Please check your internet connection and try again.',
      CacheFailure() => 'There was a problem loading your data. Please try again.',
      AuthFailure() => 'Your session has expired. Please log in again.',
      ValidationFailure() => message,
      NotFoundFailure() => 'The requested information could not be found.',
      PermissionDeniedFailure() => 'You do not have permission to perform this action.',
      ServerFailure(statusCode: final code)
          when code != null && code >= 500 =>
        'The server is experiencing issues. Please try again later.',
      ServerFailure() => 'There was a problem communicating with the server.',
      UnknownFailure() => 'An unexpected error occurred. Please try again.',
    };
  }
}

// ============================================================================
// RESULT TYPE (OPTIONAL)
// ============================================================================

/// A Result type that can either be [Ok] (success) or [Err] (failure)
///
/// This is a type-safe alternative to throwing exceptions, inspired by
/// the Result pattern and Rust's Result type. It forces callers to
/// handle both success and failure cases explicitly.
///
/// See: https://docs.flutter.dev/app-architecture/design-patterns/result
///
/// ## Usage
///
/// ```dart
/// Future<Result<User>> getUser(String id) async {
///   try {
///     final user = await apiClient.getUser(id);
///     return Result.ok(user);
///   } on NetworkException catch (e) {
///     return Result.err(Failure.network(message: 'Network error', error: e));
///   }
/// }
///
/// // Consuming the result
/// final result = await getUser('123');
/// switch (result) {
///   case Ok(value: final user):
///     print('Got user: ${user.name}');
///     break;
///   case Err(error: final failure):
///     print('Error: ${failure.userMessage}');
///     break;
/// }
/// ```
sealed class Result<T> {
  const Result();

  /// Creates a successful result containing [value]
  factory Result.ok(T value) = Ok<T>;

  /// Creates a failure result containing [error]
  factory Result.err(Failure error) = Err<T>;

  /// Returns true if this is a successful result
  bool get isOk => this is Ok<T>;

  /// Returns true if this is a failure result
  bool get isErr => this is Err<T>;
}

/// Represents a successful result containing a value of type [T]
final class Ok<T> extends Result<T> {
  /// The successful value
  final T value;

  const Ok(this.value);

  @override
  String toString() => 'Ok<$T>($value)';
}

/// Represents a failed result containing a [Failure]
final class Err<T> extends Result<T> {
  /// The failure
  final Failure error;

  const Err(this.error);

  @override
  String toString() => 'Err<$T>(${error.message})';
}

/// Extension on [Result] providing common utility methods
extension ResultExtensions<T> on Result<T> {
  /// Returns the value if this is [Ok], or null if this is [Err]
  T? get valueOrNull => switch (this) {
        Ok(value: final v) => v,
        Err() => null,
      };

  /// Returns the error if this is [Err], or null if this is [Ok]
  Failure? get errorOrNull => switch (this) {
        Ok() => null,
        Err(error: final e) => e,
      };

  /// Transforms the value using [fn] if this is [Ok]
  ///
  /// Returns [Err] unchanged if this is a failure.
  Result<U> map<U>(U Function(T value) fn) {
    return switch (this) {
      Ok(value: final v) => Result.ok(fn(v)),
      Err(error: final e) => Result.err(e),
    };
  }

  /// Returns [value] if this is [Err], or the original [Ok] value
  Result<T> orElse(T Function(Failure error) value) {
    return switch (this) {
      Ok() => this,
      Err(error: final e) => Result.ok(value(e)),
    };
  }
}
