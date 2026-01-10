import 'package:equatable/equatable.dart';

/// Type of sync error
enum SyncErrorType {
  /// Network-related errors (no connection, timeout, DNS failure)
  network,

  /// Authentication errors (expired token, unauthorized, forbidden)
  authentication,

  /// Server errors (500, 502, 503, maintenance)
  server,

  /// Validation errors (invalid data, schema mismatch)
  validation,

  /// Conflict errors (concurrent edits, version mismatch)
  conflict,

  /// Timeout errors (request took too long)
  timeout,

  /// Not found errors (entity doesn't exist)
  notFound,

  /// Rate limiting errors (too many requests)
  rateLimited,

  /// Quota exceeded errors (storage limit reached)
  quotaExceeded,

  /// Unknown/uncategorized errors
  unknown,
}

/// Severity level of a sync error
enum SyncErrorSeverity {
  /// Low severity - temporary issue, will auto-retry
  low,

  /// Medium severity - may require user attention
  medium,

  /// High severity - requires immediate user action
  high,
}

/// Detailed information about a sync error with user-friendly messaging
class SyncError extends Equatable {
  /// Unique identifier for this error instance
  final String errorId;

  /// Type of error that occurred
  final SyncErrorType type;

  /// Severity level of the error
  final SyncErrorSeverity severity;

  /// Error code from the server (if available)
  final String? code;

  /// Technical error message (for debugging)
  final String technicalMessage;

  /// User-friendly error message
  final String userMessage;

  /// Actionable suggestion for resolving the error
  final String suggestion;

  /// HTTP status code (if applicable)
  final int? statusCode;

  /// Entity type being synced when error occurred
  final String? entityType;

  /// Entity ID being synced when error occurred
  final String? entityId;

  /// Operation being performed when error occurred
  final String? operationType;

  /// Number of retry attempts
  final int retryCount;

  /// Whether this error is retryable
  final bool isRetryable;

  /// When the error occurred
  final DateTime occurredAt;

  /// Stack trace or additional error details
  final Map<String, dynamic>? details;

  const SyncError({
    required this.errorId,
    required this.type,
    required this.severity,
    this.code,
    required this.technicalMessage,
    required this.userMessage,
    required this.suggestion,
    this.statusCode,
    this.entityType,
    this.entityId,
    this.operationType,
    this.retryCount = 0,
    this.isRetryable = true,
    required this.occurredAt,
    this.details,
  });

  /// Creates a copy with the given fields replaced
  SyncError copyWith({
    String? errorId,
    SyncErrorType? type,
    SyncErrorSeverity? severity,
    String? code,
    String? technicalMessage,
    String? userMessage,
    String? suggestion,
    int? statusCode,
    String? entityType,
    String? entityId,
    String? operationType,
    int? retryCount,
    bool? isRetryable,
    DateTime? occurredAt,
    Map<String, dynamic>? details,
  }) {
    return SyncError(
      errorId: errorId ?? this.errorId,
      type: type ?? this.type,
      severity: severity ?? this.severity,
      code: code ?? this.code,
      technicalMessage: technicalMessage ?? this.technicalMessage,
      userMessage: userMessage ?? this.userMessage,
      suggestion: suggestion ?? this.suggestion,
      statusCode: statusCode ?? this.statusCode,
      entityType: entityType ?? this.entityType,
      entityId: entityId ?? this.entityId,
      operationType: operationType ?? this.operationType,
      retryCount: retryCount ?? this.retryCount,
      isRetryable: isRetryable ?? this.isRetryable,
      occurredAt: occurredAt ?? this.occurredAt,
      details: details ?? this.details,
    );
  }

  /// Creates a SyncError from an exception
  factory SyncError.fromException({
    required Exception exception,
    String? entityType,
    String? entityId,
    String? operationType,
    int retryCount = 0,
    Map<String, dynamic>? details,
  }) {
    final errorId = 'error_${DateTime.now().millisecondsSinceEpoch}';
    final occurredAt = DateTime.now();

    // Handle known exception types
    if (exception.toString().contains('Network') ||
        exception.toString().contains('SocketException') ||
        exception.toString().contains('HttpException')) {
      return SyncError(
        errorId: errorId,
        type: SyncErrorType.network,
        severity: SyncErrorSeverity.medium,
        technicalMessage: exception.toString(),
        userMessage:
            'Network connection issue. Please check your internet connection.',
        suggestion: 'Check your WiFi or mobile data connection and try again.',
        entityType: entityType,
        entityId: entityId,
        operationType: operationType,
        retryCount: retryCount,
        isRetryable: true,
        occurredAt: occurredAt,
        details: details,
      );
    }

    if (exception.toString().contains('Timeout') ||
        exception.toString().contains('timeout')) {
      return SyncError(
        errorId: errorId,
        type: SyncErrorType.timeout,
        severity: SyncErrorSeverity.low,
        technicalMessage: exception.toString(),
        userMessage: 'Request timed out. The server took too long to respond.',
        suggestion:
            'The server may be busy. Your request will be retried automatically.',
        entityType: entityType,
        entityId: entityId,
        operationType: operationType,
        retryCount: retryCount,
        isRetryable: true,
        occurredAt: occurredAt,
        details: details,
      );
    }

    if (exception.toString().contains('Unauthorized') ||
        exception.toString().contains('401')) {
      return SyncError(
        errorId: errorId,
        type: SyncErrorType.authentication,
        severity: SyncErrorSeverity.high,
        technicalMessage: exception.toString(),
        userMessage: 'Authentication failed. Please sign in again.',
        suggestion:
            'Your session may have expired. Please sign out and sign back in.',
        statusCode: 401,
        entityType: entityType,
        entityId: entityId,
        operationType: operationType,
        retryCount: retryCount,
        isRetryable: false,
        occurredAt: occurredAt,
        details: details,
      );
    }

    if (exception.toString().contains('Forbidden') ||
        exception.toString().contains('403')) {
      return SyncError(
        errorId: errorId,
        type: SyncErrorType.authentication,
        severity: SyncErrorSeverity.high,
        technicalMessage: exception.toString(),
        userMessage:
            'Access denied. You don\'t have permission to perform this action.',
        suggestion: 'If you believe this is an error, please contact support.',
        statusCode: 403,
        entityType: entityType,
        entityId: entityId,
        operationType: operationType,
        retryCount: retryCount,
        isRetryable: false,
        occurredAt: occurredAt,
        details: details,
      );
    }

    if (exception.toString().contains('NotFound') ||
        exception.toString().contains('404')) {
      return SyncError(
        errorId: errorId,
        type: SyncErrorType.notFound,
        severity: SyncErrorSeverity.high,
        technicalMessage: exception.toString(),
        userMessage:
            'Data not found. The item you\'re trying to sync may have been deleted.',
        suggestion:
            'Refresh your data to ensure you have the latest information.',
        statusCode: 404,
        entityType: entityType,
        entityId: entityId,
        operationType: operationType,
        retryCount: retryCount,
        isRetryable: false,
        occurredAt: occurredAt,
        details: details,
      );
    }

    if (exception.toString().contains('Conflict') ||
        exception.toString().contains('409')) {
      return SyncError(
        errorId: errorId,
        type: SyncErrorType.conflict,
        severity: SyncErrorSeverity.medium,
        technicalMessage: exception.toString(),
        userMessage:
            'Sync conflict detected. This data was modified elsewhere.',
        suggestion:
            'Please review the changes and choose which version to keep.',
        statusCode: 409,
        entityType: entityType,
        entityId: entityId,
        operationType: operationType,
        retryCount: retryCount,
        isRetryable: false,
        occurredAt: occurredAt,
        details: details,
      );
    }

    if (exception.toString().contains('Validation') ||
        exception.toString().contains('422')) {
      return SyncError(
        errorId: errorId,
        type: SyncErrorType.validation,
        severity: SyncErrorSeverity.high,
        technicalMessage: exception.toString(),
        userMessage: 'Invalid data. Some information couldn\'t be validated.',
        suggestion:
            'Please check your input and try again. Contact support if the issue persists.',
        statusCode: 422,
        entityType: entityType,
        entityId: entityId,
        operationType: operationType,
        retryCount: retryCount,
        isRetryable: false,
        occurredAt: occurredAt,
        details: details,
      );
    }

    if (exception.toString().contains('429')) {
      return SyncError(
        errorId: errorId,
        type: SyncErrorType.rateLimited,
        severity: SyncErrorSeverity.medium,
        technicalMessage: exception.toString(),
        userMessage:
            'Too many requests. Please wait a moment before trying again.',
        suggestion:
            'You\'re making requests too frequently. Please wait and try again later.',
        statusCode: 429,
        entityType: entityType,
        entityId: entityId,
        operationType: operationType,
        retryCount: retryCount,
        isRetryable: true,
        occurredAt: occurredAt,
        details: details,
      );
    }

    if (exception.toString().contains('507') ||
        exception.toString().contains('quota')) {
      return SyncError(
        errorId: errorId,
        type: SyncErrorType.quotaExceeded,
        severity: SyncErrorSeverity.high,
        technicalMessage: exception.toString(),
        userMessage: 'Storage quota exceeded. Please free up some space.',
        suggestion:
            'Delete old trips or upgrade your account to increase storage.',
        statusCode: 507,
        entityType: entityType,
        entityId: entityId,
        operationType: operationType,
        retryCount: retryCount,
        isRetryable: false,
        occurredAt: occurredAt,
        details: details,
      );
    }

    if (exception.toString().contains('500') ||
        exception.toString().contains('502') ||
        exception.toString().contains('503')) {
      return SyncError(
        errorId: errorId,
        type: SyncErrorType.server,
        severity: SyncErrorSeverity.medium,
        technicalMessage: exception.toString(),
        userMessage: 'Server error. Our team has been notified.',
        suggestion:
            'This is usually temporary. Please try again in a few minutes.',
        entityType: entityType,
        entityId: entityId,
        operationType: operationType,
        retryCount: retryCount,
        isRetryable: true,
        occurredAt: occurredAt,
        details: details,
      );
    }

    // Default to unknown error
    return SyncError(
      errorId: errorId,
      type: SyncErrorType.unknown,
      severity: SyncErrorSeverity.medium,
      technicalMessage: exception.toString(),
      userMessage: 'An unexpected error occurred.',
      suggestion: 'Please try again. If the problem persists, contact support.',
      entityType: entityType,
      entityId: entityId,
      operationType: operationType,
      retryCount: retryCount,
      isRetryable: true,
      occurredAt: occurredAt,
      details: details,
    );
  }

  /// Time since error occurred
  Duration get age => DateTime.now().difference(occurredAt);

  /// Whether this error should trigger a user notification
  bool get shouldNotify => severity == SyncErrorSeverity.high;

  @override
  List<Object?> get props => [
        errorId,
        type,
        severity,
        code,
        technicalMessage,
        userMessage,
        suggestion,
        statusCode,
        entityType,
        entityId,
        operationType,
        retryCount,
        isRetryable,
        occurredAt,
        details,
      ];

  @override
  String toString() =>
      'SyncError(errorId: $errorId, type: $type, severity: $severity, '
      'userMessage: $userMessage, occurredAt: $occurredAt)';

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'errorId': errorId,
      'type': type.name,
      'severity': severity.name,
      'code': code,
      'technicalMessage': technicalMessage,
      'userMessage': userMessage,
      'suggestion': suggestion,
      'statusCode': statusCode,
      'entityType': entityType,
      'entityId': entityId,
      'operationType': operationType,
      'retryCount': retryCount,
      'isRetryable': isRetryable,
      'occurredAt': occurredAt.toIso8601String(),
      'details': details,
    };
  }

  /// Create from JSON
  factory SyncError.fromJson(Map<String, dynamic> json) {
    return SyncError(
      errorId: json['errorId'] as String,
      type: SyncErrorType.values.firstWhere((e) => e.name == json['type']),
      severity: SyncErrorSeverity.values
          .firstWhere((e) => e.name == json['severity']),
      code: json['code'] as String?,
      technicalMessage: json['technicalMessage'] as String,
      userMessage: json['userMessage'] as String,
      suggestion: json['suggestion'] as String,
      statusCode: json['statusCode'] as int?,
      entityType: json['entityType'] as String?,
      entityId: json['entityId'] as String?,
      operationType: json['operationType'] as String?,
      retryCount: json['retryCount'] as int? ?? 0,
      isRetryable: json['isRetryable'] as bool? ?? true,
      occurredAt: DateTime.parse(json['occurredAt'] as String),
      details: json['details'] as Map<String, dynamic>?,
    );
  }
}

/// Result of a sync operation with error information
class SyncErrorResult extends Equatable {
  /// Whether the operation was successful
  final bool isSuccess;

  /// Error that occurred (if any)
  final SyncError? error;

  /// Number of operations that succeeded
  final int successCount;

  /// Number of operations that failed
  final int failureCount;

  /// Total number of operations
  final int totalCount;

  const SyncErrorResult({
    required this.isSuccess,
    this.error,
    required this.successCount,
    required this.failureCount,
    required this.totalCount,
  });

  /// Creates a successful result
  factory SyncErrorResult.success({
    int successCount = 1,
    int totalCount = 1,
  }) {
    return SyncErrorResult(
      isSuccess: true,
      successCount: successCount,
      failureCount: 0,
      totalCount: totalCount,
    );
  }

  /// Creates a failed result with an error
  factory SyncErrorResult.failure({
    required SyncError error,
    int failureCount = 1,
    int totalCount = 1,
  }) {
    return SyncErrorResult(
      isSuccess: false,
      error: error,
      successCount: 0,
      failureCount: failureCount,
      totalCount: totalCount,
    );
  }

  /// Creates a partial result (some successes, some failures)
  factory SyncErrorResult.partial({
    required SyncError error,
    required int successCount,
    required int failureCount,
    required int totalCount,
  }) {
    return SyncErrorResult(
      isSuccess: false,
      error: error,
      successCount: successCount,
      failureCount: failureCount,
      totalCount: totalCount,
    );
  }

  /// Whether this result represents a partial failure
  bool get isPartial => successCount > 0 && failureCount > 0;

  /// Success rate as a percentage
  double get successRate =>
      totalCount > 0 ? (successCount / totalCount) * 100 : 0;

  @override
  List<Object?> get props => [
        isSuccess,
        error,
        successCount,
        failureCount,
        totalCount,
      ];

  @override
  String toString() =>
      'SyncErrorResult(isSuccess: $isSuccess, successCount: $successCount, '
      'failureCount: $failureCount, totalCount: $totalCount)';
}
