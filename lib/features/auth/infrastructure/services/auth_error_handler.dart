import 'package:flutter/foundation.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';

/// Categories of authentication errors
///
/// These categories help determine the appropriate user feedback
/// and recovery actions for different error scenarios.
enum AuthErrorCategory {
  /// Network-related errors (no connection, timeout, etc.)
  network,

  /// Credential errors (wrong password, user not found, etc.)
  credentials,

  /// Token expiration errors (session expired, invalid token, etc.)
  expired,

  /// Rate limiting errors (too many attempts, etc.)
  rateLimit,

  /// Server-side errors (500, 503, etc.)
  server,

  /// Validation errors (invalid input, password requirements, etc.)
  validation,

  /// Unknown/uncategorized errors
  unknown,
}

/// Actionable recovery steps for authentication errors
///
/// Provides users with clear next steps to recover from errors.
class AuthErrorRecovery {
  /// The primary recovery action
  final String primaryAction;

  /// Optional secondary recovery action
  final String? secondaryAction;

  /// Whether the user can retry the operation immediately
  final bool canRetry;

  /// Suggested delay before retry (if applicable)
  final Duration? retryDelay;

  const AuthErrorRecovery({
    required this.primaryAction,
    this.secondaryAction,
    this.canRetry = true,
    this.retryDelay,
  });

  /// Creates a recovery action for retryable network errors
  factory AuthErrorRecovery.retryNetwork({Duration? delay}) {
    return AuthErrorRecovery(
      primaryAction: 'Check your internet connection and try again',
      canRetry: true,
      retryDelay: delay ?? const Duration(seconds: 5),
    );
  }

  /// Creates a recovery action for credential errors
  factory AuthErrorRecovery.fixCredentials() {
    return const AuthErrorRecovery(
      primaryAction: 'Check your email and password and try again',
      secondaryAction: 'Reset your password if you forgot it',
      canRetry: true,
    );
  }

  /// Creates a recovery action for expired session errors
  factory AuthErrorRecovery.reauthenticate() {
    return const AuthErrorRecovery(
      primaryAction: 'Please sign in again to continue',
      canRetry: true,
    );
  }

  /// Creates a recovery action for rate limit errors
  factory AuthErrorRecovery.waitAndRetry({required Duration waitTime}) {
    return AuthErrorRecovery(
      primaryAction:
          'Please wait ${_formatDuration(waitTime)} before trying again',
      canRetry: false,
      retryDelay: waitTime,
    );
  }

  /// Creates a recovery action for server errors
  factory AuthErrorRecovery.contactSupport() {
    return const AuthErrorRecovery(
      primaryAction: 'Please try again later',
      secondaryAction: 'If the problem persists, contact support',
      canRetry: true,
      retryDelay: Duration(seconds: 30),
    );
  }

  /// Creates a recovery action for validation errors
  factory AuthErrorRecovery.fixInput() {
    return const AuthErrorRecovery(
      primaryAction: 'Please check your input and try again',
      canRetry: true,
    );
  }

  /// Formats a Duration for display
  static String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours} hour${duration.inHours > 1 ? "s" : ""}';
    } else if (duration.inMinutes > 0) {
      return '${duration.inMinutes} minute${duration.inMinutes > 1 ? "s" : ""}';
    } else {
      return '${duration.inSeconds} second${duration.inSeconds > 1 ? "s" : ""}';
    }
  }

  @override
  String toString() {
    final buffer = StringBuffer(primaryAction);
    if (secondaryAction != null) {
      buffer.write('. $secondaryAction');
    }
    return buffer.toString();
  }
}

/// Result of handling an authentication error
///
/// Contains all information needed to display appropriate
/// user feedback and recovery options.
class AuthErrorInfo {
  /// The category of the error
  final AuthErrorCategory category;

  /// User-friendly error message
  final String userMessage;

  /// Suggested recovery actions
  final AuthErrorRecovery recovery;

  /// The original error code (for debugging)
  final String? errorCode;

  /// Whether the error is retryable
  final bool isRetryable;

  /// Technical details (for logging/debugging)
  final String? technicalDetails;

  const AuthErrorInfo({
    required this.category,
    required this.userMessage,
    required this.recovery,
    this.errorCode,
    required this.isRetryable,
    this.technicalDetails,
  });

  @override
  String toString() {
    return 'AuthErrorInfo{category: $category, userMessage: $userMessage, '
        'errorCode: $errorCode, isRetryable: $isRetryable}';
  }
}

/// Centralized error handler for authentication errors
///
/// This service categorizes authentication errors and provides:
/// - User-friendly error messages
/// - Actionable recovery steps
/// - Error logging for debugging
/// - Consistent error handling across the app
///
/// Usage:
/// ```dart
/// final errorHandler = AuthErrorHandler();
/// final errorInfo = errorHandler.handleError(exception);
/// print(errorInfo.userMessage);
/// print(errorInfo.recovery.primaryAction);
/// ```
class AuthErrorHandler {
  /// Whether to log detailed error information
  final bool enableDetailedLogging;

  /// Creates a new [AuthErrorHandler]
  ///
  /// [enableDetailedLogging] controls whether technical details are logged
  /// (default: true for debug mode, false for release mode)
  const AuthErrorHandler({
    this.enableDetailedLogging = kDebugMode,
  });

  /// Handles an exception and returns structured error information
  ///
  /// This method:
  /// 1. Categorizes the error
  /// 2. Generates a user-friendly message
  /// 3. Provides recovery actions
  /// 4. Logs the error for debugging
  AuthErrorInfo handleError(Object exception) {
    // Log the error
    _logError(exception);

    // Handle AuthException
    if (exception is AuthException) {
      return _handleAuthException(exception);
    }

    // Handle network-related exceptions
    if (exception is NetworkTimeoutException ||
        exception is NetworkConnectivityException) {
      return _handleNetworkException(exception);
    }

    // Handle other AppException types
    if (exception is AppException) {
      return _handleAppException(exception);
    }

    // Handle unknown exceptions
    return _handleUnknownException(exception);
  }

  /// Handles AuthException instances
  AuthErrorInfo _handleAuthException(AuthException exception) {
    final code = exception.code?.toUpperCase() ?? '';

    switch (code) {
      // Network-related errors
      case 'NETWORK_ERROR':
      case 'NETWORK_CONNECTIVITY':
      case 'NETWORK_TIMEOUT':
      case 'CONNECTION_FAILED':
        return AuthErrorInfo(
          category: AuthErrorCategory.network,
          userMessage:
              'Unable to connect to the server. Please check your internet connection.',
          recovery: AuthErrorRecovery.retryNetwork(),
          errorCode: code,
          isRetryable: true,
          technicalDetails: 'Network error: ${exception.message}',
        );

      // Credential errors
      case 'INVALID_CREDENTIALS':
      case 'USER_NOT_FOUND':
      case 'NOT_AUTHORIZED':
      case 'INCORRECT_PASSWORD':
        return AuthErrorInfo(
          category: AuthErrorCategory.credentials,
          userMessage: _getCredentialErrorMessage(code),
          recovery: AuthErrorRecovery.fixCredentials(),
          errorCode: code,
          isRetryable: true,
          technicalDetails: 'Authentication failed: ${exception.message}',
        );

      case 'EMAIL_NOT_VERIFIED':
      case 'USER_NOT_CONFIRMED':
        return AuthErrorInfo(
          category: AuthErrorCategory.credentials,
          userMessage: 'Please verify your email address before signing in.',
          recovery: const AuthErrorRecovery(
            primaryAction: 'Check your email for a verification link',
            secondaryAction: 'Resend verification email if needed',
            canRetry: true,
          ),
          errorCode: code,
          isRetryable: true,
          technicalDetails: 'Email not verified: ${exception.message}',
        );

      case 'PASSWORD_RESET_REQUIRED':
        return AuthErrorInfo(
          category: AuthErrorCategory.credentials,
          userMessage: 'You need to reset your password before continuing.',
          recovery: const AuthErrorRecovery(
            primaryAction:
                'Reset your password using the "Forgot Password" option',
            canRetry: true,
          ),
          errorCode: code,
          isRetryable: true,
          technicalDetails: 'Password reset required: ${exception.message}',
        );

      // Token expiration errors
      case 'TOKEN_EXPIRED':
      case 'SESSION_EXPIRED':
      case 'REFRESH_FAILED':
      case 'INVALID_TOKEN':
        return AuthErrorInfo(
          category: AuthErrorCategory.expired,
          userMessage: 'Your session has expired. Please sign in again.',
          recovery: AuthErrorRecovery.reauthenticate(),
          errorCode: code,
          isRetryable: true,
          technicalDetails: 'Token expired: ${exception.message}',
        );

      // Rate limiting errors
      case 'RATE_LIMIT_EXCEEDED':
      case 'TOO_MANY_REQUESTS':
      case 'LIMIT_EXCEEDED':
        return AuthErrorInfo(
          category: AuthErrorCategory.rateLimit,
          userMessage: 'Too many attempts. Please wait before trying again.',
          recovery: AuthErrorRecovery.waitAndRetry(
            waitTime: const Duration(minutes: 15),
          ),
          errorCode: code,
          isRetryable: false,
          technicalDetails: 'Rate limit exceeded: ${exception.message}',
        );

      // Validation errors
      case 'INVALID_PASSWORD':
        return AuthErrorInfo(
          category: AuthErrorCategory.validation,
          userMessage: 'Password does not meet the requirements. '
              'Please use a stronger password with at least 8 characters, '
              'including uppercase, lowercase, numbers, and special characters.',
          recovery: const AuthErrorRecovery(
            primaryAction: 'Choose a stronger password and try again',
            canRetry: true,
          ),
          errorCode: code,
          isRetryable: true,
          technicalDetails: 'Invalid password: ${exception.message}',
        );

      case 'INVALID_CODE':
      case 'CODE_MISMATCH':
        return AuthErrorInfo(
          category: AuthErrorCategory.validation,
          userMessage: 'Invalid verification code. Please check and try again.',
          recovery: const AuthErrorRecovery(
            primaryAction: 'Enter the correct verification code',
            secondaryAction: 'Request a new code if needed',
            canRetry: true,
          ),
          errorCode: code,
          isRetryable: true,
          technicalDetails: 'Invalid code: ${exception.message}',
        );

      case 'EXPIRED_CODE':
        return AuthErrorInfo(
          category: AuthErrorCategory.validation,
          userMessage:
              'Verification code has expired. Please request a new code.',
          recovery: const AuthErrorRecovery(
            primaryAction: 'Request a new verification code',
            canRetry: true,
          ),
          errorCode: code,
          isRetryable: true,
          technicalDetails: 'Expired code: ${exception.message}',
        );

      case 'INVALID_PARAMETER':
      case 'INVALID_EMAIL':
      case 'WEAK_PASSWORD':
        return AuthErrorInfo(
          category: AuthErrorCategory.validation,
          userMessage:
              'Invalid input. Please check your information and try again.',
          recovery: AuthErrorRecovery.fixInput(),
          errorCode: code,
          isRetryable: true,
          technicalDetails: 'Validation failed: ${exception.message}',
        );

      case 'EMAIL_EXISTS':
      case 'ALIAS_EXISTS':
        return AuthErrorInfo(
          category: AuthErrorCategory.validation,
          userMessage: 'An account with this email already exists.',
          recovery: const AuthErrorRecovery(
            primaryAction: 'Sign in with your existing account',
            secondaryAction: 'Reset your password if you forgot it',
            canRetry: true,
          ),
          errorCode: code,
          isRetryable: true,
          technicalDetails: 'Email already exists: ${exception.message}',
        );

      // Server errors
      case 'INTERNAL_ERROR':
      case 'SERVER_ERROR':
      case 'SERVICE_UNAVAILABLE':
        return AuthErrorInfo(
          category: AuthErrorCategory.server,
          userMessage: 'A server error occurred. Please try again later.',
          recovery: AuthErrorRecovery.contactSupport(),
          errorCode: code,
          isRetryable: true,
          technicalDetails: 'Server error: ${exception.message}',
        );

      // Unknown error codes
      default:
        return _getUnknownErrorInfo(exception);
    }
  }

  /// Handles network exceptions
  AuthErrorInfo _handleNetworkException(Object exception) {
    final message = exception is NetworkTimeoutException
        ? 'The request timed out. Please check your connection and try again.'
        : 'No internet connection. Please check your network settings.';

    return AuthErrorInfo(
      category: AuthErrorCategory.network,
      userMessage: message,
      recovery: AuthErrorRecovery.retryNetwork(),
      errorCode: exception is AppException ? exception.code : 'NETWORK_ERROR',
      isRetryable: true,
      technicalDetails: 'Network exception: ${exception.toString()}',
    );
  }

  /// Handles generic AppException instances
  AuthErrorInfo _handleAppException(AppException exception) {
    final code = exception.code?.toUpperCase() ?? '';

    // Map HTTP status codes to categories
    if (code == 'UNAUTHORIZED' || code == 'FORBIDDEN') {
      return AuthErrorInfo(
        category: AuthErrorCategory.credentials,
        userMessage: 'You are not authorized to perform this action.',
        recovery: AuthErrorRecovery.reauthenticate(),
        errorCode: code,
        isRetryable: true,
        technicalDetails: 'Unauthorized: ${exception.message}',
      );
    }

    if (code == 'NOT_FOUND') {
      return AuthErrorInfo(
        category: AuthErrorCategory.server,
        userMessage: 'The requested resource was not found.',
        recovery: AuthErrorRecovery.contactSupport(),
        errorCode: code,
        isRetryable: true,
        technicalDetails: 'Not found: ${exception.message}',
      );
    }

    if (code == 'SERVER_ERROR' || code.startsWith('5')) {
      return AuthErrorInfo(
        category: AuthErrorCategory.server,
        userMessage: 'A server error occurred. Please try again later.',
        recovery: AuthErrorRecovery.contactSupport(),
        errorCode: code,
        isRetryable: true,
        technicalDetails: 'Server error ($code): ${exception.message}',
      );
    }

    // Default to unknown error
    return _getUnknownErrorInfo(exception);
  }

  /// Handles unknown exceptions
  AuthErrorInfo _handleUnknownException(Object exception) {
    return AuthErrorInfo(
      category: AuthErrorCategory.unknown,
      userMessage: 'An unexpected error occurred. Please try again.',
      recovery: AuthErrorRecovery.contactSupport(),
      errorCode: 'UNKNOWN_ERROR',
      isRetryable: true,
      technicalDetails: 'Unknown exception: ${exception.toString()}',
    );
  }

  /// Gets a user-friendly message for credential errors
  String _getCredentialErrorMessage(String code) {
    switch (code) {
      case 'USER_NOT_FOUND':
        return 'No account found with this email address.';
      case 'NOT_AUTHORIZED':
      case 'INVALID_CREDENTIALS':
      case 'INCORRECT_PASSWORD':
        return 'Incorrect email or password. Please try again.';
      default:
        return 'Authentication failed. Please check your credentials.';
    }
  }

  /// Gets error info for unknown error codes
  AuthErrorInfo _getUnknownErrorInfo(AppException exception) {
    // Check if message contains common patterns
    final message = exception.message.toLowerCase();

    if (message.contains('network') || message.contains('connection')) {
      return AuthErrorInfo(
        category: AuthErrorCategory.network,
        userMessage:
            'Unable to connect to the server. Please check your internet connection.',
        recovery: AuthErrorRecovery.retryNetwork(),
        errorCode: exception.code,
        isRetryable: true,
        technicalDetails: 'Network-related error: ${exception.message}',
      );
    }

    if (message.contains('expire') ||
        message.contains('token') ||
        message.contains('session')) {
      return AuthErrorInfo(
        category: AuthErrorCategory.expired,
        userMessage: 'Your session has expired. Please sign in again.',
        recovery: AuthErrorRecovery.reauthenticate(),
        errorCode: exception.code,
        isRetryable: true,
        technicalDetails: 'Token/session error: ${exception.message}',
      );
    }

    // Default unknown error
    return AuthErrorInfo(
      category: AuthErrorCategory.unknown,
      userMessage: 'An unexpected error occurred. Please try again.',
      recovery: AuthErrorRecovery.contactSupport(),
      errorCode: exception.code ?? 'UNKNOWN',
      isRetryable: true,
      technicalDetails: 'Unknown error: ${exception.message}',
    );
  }

  /// Logs an error for debugging
  void _logError(Object exception) {
    if (!enableDetailedLogging) {
      return;
    }

    if (exception is AuthException) {
    } else if (exception is AppException) {
    } else {
    }

    // Log stack trace for non-AuthException errors
    if (exception is! AuthException && exception is! AppException) {
    }
  }

  /// Checks if an error is retryable
  ///
  /// This is a convenience method that returns true if the error
  /// can be retried immediately or after a delay.
  bool isRetryable(Object exception) {
    final errorInfo = handleError(exception);
    return errorInfo.isRetryable;
  }

  /// Checks if an error should trigger a token refresh
  ///
  /// Returns true for token/expiration related errors.
  bool shouldRefreshToken(Object exception) {
    final errorInfo = handleError(exception);
    return errorInfo.category == AuthErrorCategory.expired;
  }

  /// Checks if an error is a credential error
  ///
  /// Returns true for authentication/credential related errors.
  bool isCredentialError(Object exception) {
    final errorInfo = handleError(exception);
    return errorInfo.category == AuthErrorCategory.credentials;
  }

  /// Checks if an error is a network error
  ///
  /// Returns true for network/connectivity related errors.
  bool isNetworkError(Object exception) {
    final errorInfo = handleError(exception);
    return errorInfo.category == AuthErrorCategory.network;
  }
}
