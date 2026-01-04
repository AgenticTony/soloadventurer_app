import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/core/errors/app_error.dart';

/// Callback type for error action execution
typedef ErrorActionCallback = Future<void> Function(ErrorAction action);

/// Result of an error recovery action
class ErrorRecoveryResult {
  /// The action that was performed
  final ErrorAction action;

  /// Whether the recovery was successful
  final bool success;

  /// Result message
  final String? message;

  const ErrorRecoveryResult({
    required this.action,
    required this.success,
    this.message,
  });
}

/// Configuration for error handling behavior
class ErrorHandlerConfig {
  /// Whether to show error dialogs automatically
  final bool showAutoDialogs;

  /// Whether to log errors automatically
  final bool enableLogging;

  /// Maximum number of errors to keep in history
  final int maxHistorySize;

  /// Default actions to include for error types
  final Map<String, List<ErrorAction>> defaultActions;

  const ErrorHandlerConfig({
    this.showAutoDialogs = true,
    this.enableLogging = true,
    this.maxHistorySize = 100,
    this.defaultActions = const {},
  });
}

/// Centralized error handling service
class ErrorHandler {
  /// Singleton instance
  static final ErrorHandler _instance = ErrorHandler._internal();

  /// Factory constructor to return singleton
  factory ErrorHandler() => _instance;

  /// Private constructor
  ErrorHandler._internal() {
    _config = const ErrorHandlerConfig();
  }

  /// Configuration
  ErrorHandlerConfig _config;

  /// Error history
  final List<AppError> _errorHistory = [];

  /// Stream controller for error events
  final StreamController<AppError> _errorController =
      StreamController<AppError>.broadcast();

  /// Action callbacks
  final Map<ErrorAction, ErrorActionCallback> _actionCallbacks = {};

  /// Stream of errors
  Stream<AppError> get errorStream => _errorController.stream;

  /// Current configuration
  ErrorHandlerConfig get config => _config;

  /// Error history (unmodifiable)
  List<AppError> get history => List.unmodifiable(_errorHistory);

  /// Initialize error handler with configuration
  void initialize([ErrorHandlerConfig? config]) {
    if (config != null) {
      _config = config;
    }
    _registerDefaultCallbacks();
  }

  /// Handle an exception and convert to AppError
  AppError handleException(
    dynamic exception, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    AppError error;

    if (exception is AppException) {
      error = AppError.fromException(
        exception,
        stackTrace: stackTrace,
        context: context,
      );
    } else if (exception is Exception) {
      error = AppError.fromGenericException(
        exception as Exception,
        stackTrace: stackTrace,
        context: context,
      );
    } else if (exception is SocketException) {
      error = AppError.network(
        exception: exception,
        stackTrace: stackTrace,
        context: context,
      );
    } else if (exception is TimeoutException) {
      error = AppError.timeout(
        exception: exception,
        stackTrace: stackTrace,
        context: context,
      );
    } else {
      error = AppError(
        id: AppError._generateErrorId(),
        message: 'An unexpected error occurred. Please try again.',
        technicalMessage: exception?.toString(),
        code: 'unknown_error',
        severity: ErrorSeverity.error,
        availableActions: const [ErrorAction.retry, ErrorAction.report],
        primaryAction: ErrorAction.retry,
        exception: exception is Exception ? exception : null,
        stackTrace: stackTrace,
        context: context,
      );
    }

    return handleError(error);
  }

  /// Handle an AppError
  AppError handleError(AppError error) {
    // Add to history
    _addToHistory(error);

    // Log error
    if (_config.enableLogging) {
      _logError(error);
    }

    // Emit to stream
    _errorController.add(error);

    return error;
  }

  /// Register a callback for an error action
  void registerActionCallback(
    ErrorAction action,
    ErrorActionCallback callback,
  ) {
    _actionCallbacks[action] = callback;
  }

  /// Execute an error recovery action
  Future<ErrorRecoveryResult> executeAction(
    ErrorAction action, {
    AppError? error,
  }) async {
    try {
      final callback = _actionCallbacks[action];

      if (callback != null) {
        await callback(action);
        return ErrorRecoveryResult(
          action: action,
          success: true,
          message: 'Action completed successfully',
        );
      } else {
        return ErrorRecoveryResult(
          action: action,
          success: false,
          message: 'No callback registered for action: $action',
        );
      }
    } catch (e) {
      return ErrorRecoveryResult(
        action: action,
        success: false,
        message: 'Action failed: ${e.toString()}',
      );
    }
  }

  /// Get errors by severity
  List<AppError> getErrorsBySeverity(ErrorSeverity severity) {
    return _errorHistory.where((e) => e.severity == severity).toList();
  }

  /// Get errors by code
  List<AppError> getErrorsByCode(String code) {
    return _errorHistory.where((e) => e.code == code).toList();
  }

  /// Get errors in a time range
  List<AppError> getErrorsInTimeRange(DateTime start, DateTime end) {
    return _errorHistory.where((e) {
      return e.timestamp.isAfter(start) && e.timestamp.isBefore(end);
    }).toList();
  }

  /// Clear error history
  void clearHistory() {
    _errorHistory.clear();
  }

  /// Clear errors by severity
  void clearErrorsBySeverity(ErrorSeverity severity) {
    _errorHistory.removeWhere((e) => e.severity == severity);
  }

  /// Get error statistics
  Map<String, dynamic> getStatistics() {
    final stats = <String, dynamic>{};

    // Total errors
    stats['total'] = _errorHistory.length;

    // By severity
    for (final severity in ErrorSeverity.values) {
      stats[severity.name] = getErrorsBySeverity(severity).length;
    }

    // By code
    final codeCounts = <String, int>{};
    for (final error in _errorHistory) {
      final code = error.code ?? 'unknown';
      codeCounts[code] = (codeCounts[code] ?? 0) + 1;
    }
    stats['byCode'] = codeCounts;

    // Recoverable vs non-recoverable
    stats['recoverable'] =
        _errorHistory.where((e) => e.isRecoverable).length;
    stats['nonRecoverable'] =
        _errorHistory.where((e) => !e.isRecoverable).length;

    return stats;
  }

  /// Dispose resources
  void dispose() {
    _errorController.close();
  }

  /// Add error to history
  void _addToHistory(AppError error) {
    _errorHistory.add(error);

    // Trim history if needed
    while (_errorHistory.length > _config.maxHistorySize) {
      _errorHistory.removeAt(0);
    }
  }

  /// Log error
  void _logError(AppError error) {
    if (kDebugMode) {
      print('[ErrorHandler] ${error.toLogString()}');
    }
  }

  /// Register default action callbacks
  void _registerDefaultCallbacks() {
    // Default implementations for common actions
    // These can be overridden by the app layer
  }

  /// Create a human-readable summary for reporting
  String createErrorReport([AppError? error]) {
    if (error != null) {
      return '''Error Report - ${error.id}
Time: ${error.timestamp.toIso8601String()}
Code: ${error.code ?? 'N/A'}
Severity: ${error.severity.name}
Message: ${error.message}

Technical Details:
${error.technicalMessage ?? 'N/A'}

Context:
${error.context?.toString() ?? 'N/A'}
''';
    }

    // Full statistics report
    final stats = getStatistics();
    final buffer = StringBuffer();
    buffer.writeln('Error Handler Statistics Report');
    buffer.writeln('Generated: ${DateTime.now().toIso8601String()}');
    buffer.writeln('');
    buffer.writeln('Total Errors: ${stats['total']}');

    buffer.writeln('\nBy Severity:');
    for (final severity in ErrorSeverity.values) {
      buffer.writeln('  ${severity.name}: ${stats[severity.name]}');
    }

    buffer.writeln('\nBy Code:');
    final codeCounts = stats['byCode'] as Map<String, int>;
    final sortedCodes = codeCounts.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    for (final entry in sortedCodes) {
      buffer.writeln('  ${entry.key}: ${entry.value}');
    }

    buffer.writeln('\nRecoverability:');
    buffer.writeln('  Recoverable: ${stats['recoverable']}');
    buffer.writeln('  Non-Recoverable: ${stats['nonRecoverable']}');

    return buffer.toString();
  }

  /// Export error history as JSON
  String exportErrorsAsJson() {
    final errorsJson = _errorHistory.map((e) => {
      'id': e.id,
      'message': e.message,
      'technicalMessage': e.technicalMessage,
      'code': e.code,
      'severity': e.severity.name,
      'availableActions': e.availableActions.map((a) => a.name).toList(),
      'primaryAction': e.primaryAction?.name,
      'isRecoverable': e.isRecoverable,
      'timestamp': e.timestamp.toIso8601String(),
      'context': e.context,
    }).toList();

    return errorsJson.toString();
  }
}

/// Extension to provide easy access to ErrorHandler
extension ErrorHandlerExtension on dynamic {
  /// Convert to AppError using global ErrorHandler
  AppError toAppError({
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  }) {
    return ErrorHandler().handleException(
      this,
      stackTrace: stackTrace,
      context: context,
    );
  }
}
