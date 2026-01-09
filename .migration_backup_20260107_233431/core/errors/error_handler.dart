import 'package:flutter/foundation.dart';
import 'package:soloadventurer/core/errors/app_exception.dart';

/// Global error handler for the application
class ErrorHandler {
  static bool _isInitialized = false;

  /// Initialize the error handler
  static void initialize() {
    if (_isInitialized) return;

    // Set up Flutter error handling
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      reportError('Flutter error', details.exception, details.stack);
    };

    _isInitialized = true;
  }

  /// Report an error to the error tracking service
  static void reportError(
      String message, dynamic error, StackTrace? stackTrace) {
    if (error is AppException) {
      // Handle known application exceptions
      _handleAppException(error);
    } else {
      // Handle unknown errors
      _handleUnknownError(message, error, stackTrace);
    }
  }

  /// Handle known application exceptions
  static void _handleAppException(AppException exception) {
    if (kDebugMode) {
      print('AppException: ${exception.message}');
      print('Type: ${exception.runtimeType}');
    }

    // TODO: Send to error tracking service (e.g., Sentry, Firebase Crashlytics)
  }

  /// Handle unknown errors
  static void _handleUnknownError(
    String message,
    dynamic error,
    StackTrace? stackTrace,
  ) {
    if (kDebugMode) {
      print('Error: $message');
      print('Details: $error');
      if (stackTrace != null) print('StackTrace: $stackTrace');
    }

    // TODO: Send to error tracking service (e.g., Sentry, Firebase Crashlytics)
  }
}
