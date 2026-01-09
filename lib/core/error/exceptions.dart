/// Types of authentication errors
enum AuthErrorType {
  invalidCredentials,
  userNotFound,
  userNotConfirmed,
  networkError,
  tokenExpired,
  invalidToken,
  unauthorized,
  unknown,
  mfaRequired,
  smsMfaRequired,
  newPasswordRequired,
  passwordResetRequired,
  emailNotVerified,
  limitExceeded,
  notAuthorized,
  invalidCode,
  codeExpired,
  invalidPassword,
  resetFailed,
  adminSetPasswordError,
  adminResetPasswordError
}

/// Base class for all exceptions in the app
abstract class AppException implements Exception {
  final String message;

  AppException(this.message);

  @override
  String toString() => message;
}

/// Exception thrown when there is a server error
class ServerException extends AppException {
  final int statusCode;

  ServerException({
    required String message,
    required this.statusCode,
  }) : super(message);
}

/// Exception thrown when there is an authentication error
class AuthException extends AppException {
  final AuthErrorType type;

  AuthException({
    required String message,
    required this.type,
  }) : super(message);
}

/// Exception thrown when there is a repository/data layer error
class RepositoryException extends AppException {
  RepositoryException(super.message);
}
