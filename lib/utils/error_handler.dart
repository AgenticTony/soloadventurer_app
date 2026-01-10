import 'package:flutter/foundation.dart';
import 'package:soloadventurer/features/core/infrastructure/monitoring/monitoring_service.dart';

/// Global error handler for catching and reporting unhandled exceptions
class GlobalErrorHandler {
  final MonitoringService _monitoringService;

  /// Creates a new GlobalErrorHandler
  ///
  /// [monitoringService] - The monitoring service to report errors to
  GlobalErrorHandler(this._monitoringService) {
    _initializeErrorHandling();
  }

  /// Initialize error handling for different types of errors
  void _initializeErrorHandling() {
    // Handle Flutter framework errors
    FlutterError.onError = _handleFlutterError;

    // Handle errors from the Dart runtime
    PlatformDispatcher.instance.onError = _handlePlatformError;

    // Handle errors from async code
    _setupZonedErrorHandling();
  }

  /// Handle Flutter framework errors
  void _handleFlutterError(FlutterErrorDetails details) {
    // Report to monitoring service
    _monitoringService.reportError(
      'FlutterError',
      details.exception,
      details.stack ?? StackTrace.current,
      context: {
        'library': details.library ?? 'unknown',
        'context': details.context?.toString() ?? 'unknown',
      },
    );

    // Forward to Flutter's default error handler in debug mode
    if (kDebugMode) {
      FlutterError.dumpErrorToConsole(details);
    }
  }

  /// Handle errors from the Dart runtime
  bool _handlePlatformError(Object error, StackTrace stack) {
    // Report to monitoring service
    _monitoringService.reportError(
      'PlatformError',
      error,
      stack,
    );

    // Return true to indicate the error was handled
    // This prevents the error from being reported to the zone
    return true;
  }

  /// Set up error handling for async code using zones
  void _setupZonedErrorHandling() {
    // This would wrap the entire app in a custom error zone
    // Typically done in main.dart

    // Example:
    // runZonedGuarded(
    //   () => runApp(MyApp()),
    //   (error, stackTrace) {
    //     _monitoringService.reportError(
    //       'ZoneError',
    //       error,
    //       stackTrace,
    //     );
    //   },
    // );
  }

  /// Report a caught exception
  /// Use this for exceptions that are caught but should still be reported
  void reportCaughtException(
    String errorType,
    dynamic error,
    StackTrace stackTrace, {
    Map<String, dynamic>? context,
  }) {
    _monitoringService.reportError(
      errorType,
      error,
      stackTrace,
      context: context,
    );
  }
}
