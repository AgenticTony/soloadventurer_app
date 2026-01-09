import '../models/sync_error.dart';

/// Service for categorizing sync errors and providing user-friendly messages
abstract class SyncErrorCategorizer {
  /// Categorize an exception into a [SyncError]
  SyncError categorizeError({
    required Exception exception,
    String? entityType,
    String? entityId,
    String? operationType,
    int retryCount = 0,
    Map<String, dynamic>? details,
  });

  /// Get a user-friendly message for a given error type
  String getUserMessage(SyncErrorType type);

  /// Get an actionable suggestion for a given error type
  String getSuggestion(SyncErrorType type);

  /// Determine if an error is retryable based on its type
  bool isRetryable(SyncErrorType type);

  /// Get the severity level for a given error type
  SyncErrorSeverity getSeverity(SyncErrorType type);

  /// Categorize an HTTP status code into a [SyncErrorType]
  SyncErrorType categorizeStatusCode(int statusCode);

  /// Create a generic error for a given type
  SyncError createError({
    required SyncErrorType type,
    required String technicalMessage,
    String? code,
    int? statusCode,
    String? entityType,
    String? entityId,
    String? operationType,
    int retryCount = 0,
    Map<String, dynamic>? details,
  });
}

/// Implementation of [SyncErrorCategorizer]
class SyncErrorCategorizerImpl implements SyncErrorCategorizer {
  /// User-friendly messages for each error type
  static const Map<SyncErrorType, String> _userMessages = {
    SyncErrorType.network:
        'Network connection issue. Please check your internet connection.',
    SyncErrorType.authentication:
        'Authentication failed. Please sign in again.',
    SyncErrorType.server:
        'Server error. Our team has been notified.',
    SyncErrorType.validation:
        'Invalid data. Some information couldn\'t be validated.',
    SyncErrorType.conflict:
        'Sync conflict detected. This data was modified elsewhere.',
    SyncErrorType.timeout:
        'Request timed out. The server took too long to respond.',
    SyncErrorType.notFound:
        'Data not found. The item may have been deleted.',
    SyncErrorType.rateLimited:
        'Too many requests. Please wait a moment before trying again.',
    SyncErrorType.quotaExceeded:
        'Storage quota exceeded. Please free up some space.',
    SyncErrorType.unknown:
        'An unexpected error occurred.',
  };

  /// Actionable suggestions for each error type
  static const Map<SyncErrorType, String> _suggestions = {
    SyncErrorType.network:
        'Check your WiFi or mobile data connection and try again.',
    SyncErrorType.authentication:
        'Your session may have expired. Please sign out and sign back in.',
    SyncErrorType.server:
        'This is usually temporary. Please try again in a few minutes.',
    SyncErrorType.validation:
        'Please check your input and try again. Contact support if the issue persists.',
    SyncErrorType.conflict:
        'Please review the changes and choose which version to keep.',
    SyncErrorType.timeout:
        'The server may be busy. Your request will be retried automatically.',
    SyncErrorType.notFound:
        'Refresh your data to ensure you have the latest information.',
    SyncErrorType.rateLimited:
        'You\'re making requests too frequently. Please wait and try again later.',
    SyncErrorType.quotaExceeded:
        'Delete old trips or upgrade your account to increase storage.',
    SyncErrorType.unknown:
        'Please try again. If the problem persists, contact support.',
  };

  /// Whether each error type is retryable
  static const Map<SyncErrorType, bool> _retryable = {
    SyncErrorType.network: true,
    SyncErrorType.authentication: false,
    SyncErrorType.server: true,
    SyncErrorType.validation: false,
    SyncErrorType.conflict: false,
    SyncErrorType.timeout: true,
    SyncErrorType.notFound: false,
    SyncErrorType.rateLimited: true,
    SyncErrorType.quotaExceeded: false,
    SyncErrorType.unknown: true,
  };

  /// Severity levels for each error type
  static const Map<SyncErrorType, SyncErrorSeverity> _severities = {
    SyncErrorType.network: SyncErrorSeverity.medium,
    SyncErrorType.authentication: SyncErrorSeverity.high,
    SyncErrorType.server: SyncErrorSeverity.medium,
    SyncErrorType.validation: SyncErrorSeverity.high,
    SyncErrorType.conflict: SyncErrorSeverity.medium,
    SyncErrorType.timeout: SyncErrorSeverity.low,
    SyncErrorType.notFound: SyncErrorSeverity.high,
    SyncErrorType.rateLimited: SyncErrorSeverity.medium,
    SyncErrorType.quotaExceeded: SyncErrorSeverity.high,
    SyncErrorType.unknown: SyncErrorSeverity.medium,
  };

  @override
  SyncError categorizeError({
    required Exception exception,
    String? entityType,
    String? entityId,
    String? operationType,
    int retryCount = 0,
    Map<String, dynamic>? details,
  }) {
    return SyncError.fromException(
      exception: exception,
      entityType: entityType,
      entityId: entityId,
      operationType: operationType,
      retryCount: retryCount,
      details: details,
    );
  }

  @override
  String getUserMessage(SyncErrorType type) {
    return _userMessages[type] ??
        _userMessages[SyncErrorType.unknown]!;
  }

  @override
  String getSuggestion(SyncErrorType type) {
    return _suggestions[type] ??
        _suggestions[SyncErrorType.unknown]!;
  }

  @override
  bool isRetryable(SyncErrorType type) {
    return _retryable[type] ?? true;
  }

  @override
  SyncErrorSeverity getSeverity(SyncErrorType type) {
    return _severities[type] ??
        _severities[SyncErrorType.unknown]!;
  }

  @override
  SyncErrorType categorizeStatusCode(int statusCode) {
    switch (statusCode) {
      case 400:
        return SyncErrorType.validation;
      case 401:
      case 403:
        return SyncErrorType.authentication;
      case 404:
        return SyncErrorType.notFound;
      case 409:
        return SyncErrorType.conflict;
      case 422:
        return SyncErrorType.validation;
      case 429:
        return SyncErrorType.rateLimited;
      case 500:
      case 502:
      case 503:
      case 504:
        return SyncErrorType.server;
      case 507:
        return SyncErrorType.quotaExceeded;
      default:
        // Status codes in the 400 range are client errors (usually validation/auth)
        if (statusCode >= 400 && statusCode < 500) {
          return SyncErrorType.validation;
        }
        // Status codes in the 500 range are server errors
        if (statusCode >= 500 && statusCode < 600) {
          return SyncErrorType.server;
        }
        return SyncErrorType.unknown;
    }
  }

  @override
  SyncError createError({
    required SyncErrorType type,
    required String technicalMessage,
    String? code,
    int? statusCode,
    String? entityType,
    String? entityId,
    String? operationType,
    int retryCount = 0,
    Map<String, dynamic>? details,
  }) {
    final errorId = 'error_${DateTime.now().millisecondsSinceEpoch}';
    final userMessage = getUserMessage(type);
    final suggestion = getSuggestion(type);
    final severity = getSeverity(type);
    final isRetryableError = isRetryable(type);

    return SyncError(
      errorId: errorId,
      type: type,
      severity: severity,
      code: code,
      technicalMessage: technicalMessage,
      userMessage: userMessage,
      suggestion: suggestion,
      statusCode: statusCode,
      entityType: entityType,
      entityId: entityId,
      operationType: operationType,
      retryCount: retryCount,
      isRetryable: isRetryableError,
      occurredAt: DateTime.now(),
      details: details,
    );
  }

  /// Create a network error
  SyncError createNetworkError({
    required String technicalMessage,
    String? entityType,
    String? entityId,
    String? operationType,
    int retryCount = 0,
  }) {
    return createError(
      type: SyncErrorType.network,
      technicalMessage: technicalMessage,
      entityType: entityType,
      entityId: entityId,
      operationType: operationType,
      retryCount: retryCount,
    );
  }

  /// Create an authentication error
  SyncError createAuthenticationError({
    required String technicalMessage,
    int? statusCode,
    String? code,
    String? entityType,
    String? entityId,
    String? operationType,
  }) {
    return createError(
      type: SyncErrorType.authentication,
      technicalMessage: technicalMessage,
      statusCode: statusCode,
      code: code,
      entityType: entityType,
      entityId: entityId,
      operationType: operationType,
    );
  }

  /// Create a server error
  SyncError createServerError({
    required String technicalMessage,
    int? statusCode,
    String? entityType,
    String? entityId,
    String? operationType,
    int retryCount = 0,
  }) {
    return createError(
      type: SyncErrorType.server,
      technicalMessage: technicalMessage,
      statusCode: statusCode,
      entityType: entityType,
      entityId: entityId,
      operationType: operationType,
      retryCount: retryCount,
    );
  }

  /// Create a validation error
  SyncError createValidationError({
    required String technicalMessage,
    Map<String, dynamic>? validationErrors,
    String? entityType,
    String? entityId,
    String? operationType,
  }) {
    return createError(
      type: SyncErrorType.validation,
      technicalMessage: technicalMessage,
      statusCode: 422,
      entityType: entityType,
      entityId: entityId,
      operationType: operationType,
      details: validationErrors,
    );
  }

  /// Create a conflict error
  SyncError createConflictError({
    required String technicalMessage,
    String? entityType,
    String? entityId,
    String? operationType,
  }) {
    return createError(
      type: SyncErrorType.conflict,
      technicalMessage: technicalMessage,
      statusCode: 409,
      entityType: entityType,
      entityId: entityId,
      operationType: operationType,
    );
  }

  /// Create a timeout error
  SyncError createTimeoutError({
    required String technicalMessage,
    String? entityType,
    String? entityId,
    String? operationType,
    int retryCount = 0,
  }) {
    return createError(
      type: SyncErrorType.timeout,
      technicalMessage: technicalMessage,
      entityType: entityType,
      entityId: entityId,
      operationType: operationType,
      retryCount: retryCount,
    );
  }
}
