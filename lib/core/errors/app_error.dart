import 'package:soloadventurer/core/errors/exceptions.dart';

/// Severity level of an error
enum ErrorSeverity {
  /// Informational message, not an error
  info,

  /// Warning that something might be wrong
  warning,

  /// Error that prevents an action
  error,

  /// Critical error that requires immediate attention
  critical,
}

/// Available recovery actions for an error
enum ErrorAction {
  /// Retry the failed operation
  retry,

  /// Cancel the operation
  cancel,

  /// Dismiss the error message
  dismiss,

  /// Report the error to support
  report,

  /// Log out and log back in
  reauthenticate,

  /// Check network connection
  checkConnection,

  /// Free up storage space
  freeStorage,

  /// Update the app
  updateApp,

  /// Contact customer support
  contactSupport,

  /// View detailed error information
  viewDetails,

  /// Clear cache and retry
  clearCache,
}

/// Represents an application error with user-friendly information
class AppError {
  /// Unique identifier for this error instance
  final String id;

  /// User-friendly error message
  final String message;

  /// Detailed technical message (for debugging/reporting)
  final String? technicalMessage;

  /// Error code for categorization
  final String? code;

  /// Severity of the error
  final ErrorSeverity severity;

  /// Available recovery actions
  final List<ErrorAction> availableActions;

  /// Primary suggested action
  final ErrorAction? primaryAction;

  /// Link to documentation or help
  final String? helpUrl;

  /// Whether the error is recoverable
  final bool isRecoverable;

  /// Underlying exception
  final Exception? exception;

  /// Stack trace
  final StackTrace? stackTrace;

  /// Timestamp when error occurred
  final DateTime timestamp;

  /// Additional context data
  final Map<String, dynamic>? context;

  const AppError({
    required this.id,
    required this.message,
    this.technicalMessage,
    this.code,
    required this.severity,
    this.availableActions = const [],
    this.primaryAction,
    this.helpUrl,
    this.isRecoverable = true,
    this.exception,
    this.stackTrace,
    DateTime? timestamp,
    this.context,
  }) : timestamp = timestamp ?? const DateTime.now();

  /// Creates an [AppError] from an [AppException]
  factory AppError.fromException(
    AppException exception, {
    String? id,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    final errorId = id ?? _generateErrorId();

    return AppError(
      id: errorId,
      message: _getUserMessage(exception),
      technicalMessage: exception.message,
      code: exception.code,
      severity: _getSeverity(exception),
      availableActions: _getAvailableActions(exception),
      primaryAction: _getPrimaryAction(exception),
      isRecoverable: _isRecoverable(exception),
      exception: exception,
      stackTrace: stackTrace,
      context: context,
    );
  }

  /// Creates an [AppError] from a generic [Exception]
  factory AppError.fromGenericException(
    Exception exception, {
    String? id,
    String? message,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    final errorId = id ?? _generateErrorId();

    return AppError(
      id: errorId,
      message: message ?? 'An unexpected error occurred. Please try again.',
      technicalMessage: exception.toString(),
      code: 'unknown_error',
      severity: ErrorSeverity.error,
      availableActions: const [ErrorAction.retry, ErrorAction.report],
      primaryAction: ErrorAction.retry,
      exception: exception,
      stackTrace: stackTrace,
      context: context,
    );
  }

  /// Creates a network error
  factory AppError.network({
    String? id,
    String? message,
    Exception? exception,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      id: id ?? _generateErrorId(),
      message: message ??
          'Unable to connect. Please check your internet connection.',
      technicalMessage: exception?.toString(),
      code: 'network_error',
      severity: ErrorSeverity.error,
      availableActions: const [
        ErrorAction.retry,
        ErrorAction.checkConnection,
        ErrorAction.dismiss,
      ],
      primaryAction: ErrorAction.retry,
      exception: exception,
      stackTrace: stackTrace,
      context: context,
    );
  }

  /// Creates a timeout error
  factory AppError.timeout({
    String? id,
    String? message,
    Exception? exception,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      id: id ?? _generateErrorId(),
      message: message ?? 'Request timed out. Please try again.',
      technicalMessage: exception?.toString(),
      code: 'timeout',
      severity: ErrorSeverity.warning,
      availableActions: const [ErrorAction.retry, ErrorAction.dismiss],
      primaryAction: ErrorAction.retry,
      exception: exception,
      stackTrace: stackTrace,
      context: context,
    );
  }

  /// Creates an authentication error
  factory AppError.auth({
    String? id,
    String? message,
    Exception? exception,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      id: id ?? _generateErrorId(),
      message: message ?? 'Your session has expired. Please log in again.',
      technicalMessage: exception?.toString(),
      code: 'auth_error',
      severity: ErrorSeverity.error,
      availableActions: const [
        ErrorAction.reauthenticate,
        ErrorAction.dismiss,
      ],
      primaryAction: ErrorAction.reauthenticate,
      exception: exception,
      stackTrace: stackTrace,
      context: context,
    );
  }

  /// Creates a storage error
  factory AppError.storage({
    String? id,
    String? message,
    Exception? exception,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      id: id ?? _generateErrorId(),
      message:
          message ?? 'Not enough storage space. Please free up some space.',
      technicalMessage: exception?.toString(),
      code: 'storage_error',
      severity: ErrorSeverity.error,
      availableActions: const [
        ErrorAction.freeStorage,
        ErrorAction.dismiss,
      ],
      primaryAction: ErrorAction.freeStorage,
      exception: exception,
      stackTrace: stackTrace,
      context: context,
    );
  }

  /// Creates a validation error
  factory AppError.validation({
    String? id,
    required String message,
    Map<String, List<String>>? errors,
    Exception? exception,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      id: id ?? _generateErrorId(),
      message: message,
      technicalMessage: errors?.toString(),
      code: 'validation_error',
      severity: ErrorSeverity.warning,
      availableActions: const [ErrorAction.dismiss],
      primaryAction: ErrorAction.dismiss,
      isRecoverable: true,
      exception: exception,
      stackTrace: stackTrace,
      context: {...?context, 'validationErrors': errors},
    );
  }

  /// Creates a not found error
  factory AppError.notFound({
    String? id,
    String? message,
    Exception? exception,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      id: id ?? _generateErrorId(),
      message: message ?? 'The requested resource was not found.',
      technicalMessage: exception?.toString(),
      code: 'not_found',
      severity: ErrorSeverity.warning,
      availableActions: const [ErrorAction.dismiss],
      primaryAction: ErrorAction.dismiss,
      exception: exception,
      stackTrace: stackTrace,
      context: context,
    );
  }

  /// Creates a server error
  factory AppError.server({
    String? id,
    String? message,
    Exception? exception,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      id: id ?? _generateErrorId(),
      message: message ?? 'Server error. Please try again later.',
      technicalMessage: exception?.toString(),
      code: 'server_error',
      severity: ErrorSeverity.error,
      availableActions: const [
        ErrorAction.retry,
        ErrorAction.dismiss,
        ErrorAction.report,
      ],
      primaryAction: ErrorAction.retry,
      exception: exception,
      stackTrace: stackTrace,
      context: context,
    );
  }

  /// Creates a media compression error
  factory AppError.mediaCompression({
    String? id,
    String? message,
    Exception? exception,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      id: id ?? _generateErrorId(),
      message:
          message ?? 'Failed to compress media. The file may be corrupted.',
      technicalMessage: exception?.toString(),
      code: 'media_compression',
      severity: ErrorSeverity.error,
      availableActions: const [ErrorAction.retry, ErrorAction.dismiss],
      primaryAction: ErrorAction.retry,
      exception: exception,
      stackTrace: stackTrace,
      context: context,
    );
  }

  /// Creates a location error
  factory AppError.location({
    String? id,
    String? message,
    Exception? exception,
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      id: id ?? _generateErrorId(),
      message: message ??
          'Unable to get your location. Please check location permissions.',
      technicalMessage: exception?.toString(),
      code: 'location_error',
      severity: ErrorSeverity.warning,
      availableActions: const [
        ErrorAction.retry,
        ErrorAction.dismiss,
      ],
      primaryAction: ErrorAction.retry,
      exception: exception,
      stackTrace: stackTrace,
      context: context,
    );
  }

  /// Returns whether the error has a specific action available
  bool hasAction(ErrorAction action) => availableActions.contains(action);

  /// Returns a formatted string for logging
  String toLogString() {
    return '''AppError {
  id: $id,
  code: $code,
  message: $message,
  technicalMessage: $technicalMessage,
  severity: $severity,
  isRecoverable: $isRecoverable,
  availableActions: $availableActions,
  timestamp: $timestamp,
  context: $context
}''';
  }

  /// Copy with method
  AppError copyWith({
    String? id,
    String? message,
    String? technicalMessage,
    String? code,
    ErrorSeverity? severity,
    List<ErrorAction>? availableActions,
    ErrorAction? primaryAction,
    String? helpUrl,
    bool? isRecoverable,
    Exception? exception,
    StackTrace? stackTrace,
    DateTime? timestamp,
    Map<String, dynamic>? context,
  }) {
    return AppError(
      id: id ?? this.id,
      message: message ?? this.message,
      technicalMessage: technicalMessage ?? this.technicalMessage,
      code: code ?? this.code,
      severity: severity ?? this.severity,
      availableActions: availableActions ?? this.availableActions,
      primaryAction: primaryAction ?? this.primaryAction,
      helpUrl: helpUrl ?? this.helpUrl,
      isRecoverable: isRecoverable ?? this.isRecoverable,
      exception: exception ?? this.exception,
      stackTrace: stackTrace ?? this.stackTrace,
      timestamp: timestamp ?? this.timestamp,
      context: context ?? this.context,
    );
  }

  /// Generate a unique error ID
  static String _generateErrorId() {
    return 'err_${DateTime.now().millisecondsSinceEpoch}_$hashCode';
  }

  /// Get user-friendly message from exception
  static String _getUserMessage(AppException exception) {
    switch (exception.runtimeType) {
      case NetworkTimeoutException:
        return 'Request timed out. Please check your connection and try again.';
      case NetworkConnectivityException:
        return 'No internet connection. Please check your network settings.';
      case UnauthorizedException:
        return 'Your session has expired. Please log in again.';
      case ForbiddenException:
        return 'You don\'t have permission to perform this action.';
      case NotFoundException:
        return 'The requested resource was not found.';
      case ServerException:
        return 'Server error. Please try again later.';
      case ValidationException:
        return exception.message;
      case CacheException:
        return 'Cache error. Please try clearing the app cache.';
      case MediaCompressionException:
        return 'Failed to process media file. It may be corrupted or in an unsupported format.';
      case LocationException:
        return 'Unable to get location. Please check your permissions.';
      case GeocodingException:
        return 'Unable to find location. Please try a different search.';
      case ExifException:
        return 'Unable to read photo metadata.';
      case DatabaseException:
        return 'Database error. Please try again.';
      default:
        return exception.message.isNotEmpty
            ? exception.message
            : 'An unexpected error occurred. Please try again.';
    }
  }

  /// Get severity from exception
  static ErrorSeverity _getSeverity(AppException exception) {
    switch (exception.runtimeType) {
      case ValidationException:
      case LocationException:
      case NetworkTimeoutException:
        return ErrorSeverity.warning;
      case UnauthorizedException:
      case ForbiddenException:
      case ServerException:
        return ErrorSeverity.error;
      case DatabaseException:
      case MediaCompressionException:
        return ErrorSeverity.error;
      default:
        return ErrorSeverity.error;
    }
  }

  /// Get available actions from exception
  static List<ErrorAction> _getAvailableActions(AppException exception) {
    switch (exception.runtimeType) {
      case NetworkTimeoutException:
      case NetworkConnectivityException:
        return [
          ErrorAction.retry,
          ErrorAction.checkConnection,
          ErrorAction.dismiss
        ];
      case UnauthorizedException:
        return [ErrorAction.reauthenticate, ErrorAction.dismiss];
      case ForbiddenException:
        return [ErrorAction.dismiss];
      case NotFoundException:
        return [ErrorAction.dismiss];
      case ServerException:
        return [ErrorAction.retry, ErrorAction.dismiss, ErrorAction.report];
      case ValidationException:
        return [ErrorAction.dismiss];
      case CacheException:
        return [ErrorAction.clearCache, ErrorAction.retry, ErrorAction.dismiss];
      case MediaCompressionException:
        return [ErrorAction.retry, ErrorAction.dismiss];
      case LocationException:
        return [ErrorAction.retry, ErrorAction.dismiss];
      default:
        return [ErrorAction.retry, ErrorAction.dismiss, ErrorAction.report];
    }
  }

  /// Get primary action from exception
  static ErrorAction? _getPrimaryAction(AppException exception) {
    switch (exception.runtimeType) {
      case NetworkTimeoutException:
      case NetworkConnectivityException:
        return ErrorAction.retry;
      case UnauthorizedException:
        return ErrorAction.reauthenticate;
      case ServerException:
      case CacheException:
      case MediaCompressionException:
        return ErrorAction.retry;
      default:
        return ErrorAction.dismiss;
    }
  }

  /// Check if exception is recoverable
  static bool _isRecoverable(AppException exception) {
    switch (exception.runtimeType) {
      case ForbiddenException:
      case NotFoundException:
        return false;
      default:
        return true;
    }
  }

  @override
  String toString() => toLogString();
}
