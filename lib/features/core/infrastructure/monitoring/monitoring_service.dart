
/// Interface for monitoring services
abstract class MonitoringService {
  /// Log an error with optional stack trace and context
  Future<void> logError(
    dynamic error, {
    StackTrace? stackTrace,
    Map<String, dynamic>? context,
  });

  /// Log a warning message with optional context
  Future<void> logWarning(
    String message, {
    Map<String, dynamic>? context,
  });

  /// Log an info message with optional context
  Future<void> logInfo(
    String message, {
    Map<String, dynamic>? context,
  });

  /// Log a debug message with optional context
  Future<void> logDebug(
    String message, {
    Map<String, dynamic>? context,
  });

  /// Record a metric with a value and optional dimensions
  Future<void> recordMetric(
    String metricName,
    double value, {
    Map<String, String>? dimensions,
  });

  /// Start a timer for performance tracking
  void startTimer(String operationName);

  /// Stop a timer and record the duration
  Future<void> stopTimer(String operationName);

  /// Record a custom event
  Future<void> recordEvent(
    String eventName, {
    Map<String, dynamic>? attributes,
  });
}
