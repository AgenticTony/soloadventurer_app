import 'auth_error_type.dart';

/// Authentication exception that uses typed error categories
///
/// This exception class provides type-safe error handling for authentication
/// failures, making it easier to handle different error scenarios appropriately
/// in the UI and domain layers.
///
/// ## Usage
///
/// ```dart
/// throw AuthException(
///   message: 'Invalid email or password',
///   type: AuthErrorType.invalidCredentials,
/// );
/// ```
///
/// ## Handling Errors
///
/// ```dart
/// try {
///   await authRepository.signIn(email, password);
/// } on AuthException catch (e) {
///   switch (e.type) {
///     case AuthErrorType.invalidCredentials:
///       showSnackBar('Invalid credentials');
///       break;
///     case AuthErrorType.network:
///       showSnackBar('Check your internet connection');
///       break;
///     default:
///       showSnackBar('An error occurred');
///   }
/// }
/// ```
class AuthException implements Exception {
  /// Human-readable error message
  final String message;

  /// Type of authentication error
  final AuthErrorType type;

  /// Creates a new [AuthException] with the given [message] and [type]
  const AuthException({
    required this.message,
    required this.type,
  });

  @override
  String toString() => 'AuthException($type): $message';
}
