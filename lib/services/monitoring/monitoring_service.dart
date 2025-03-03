
/// Enum representing different categories of metrics to track
enum MetricCategory { network, ui, database, authentication, business, system }

/// Abstract class defining the monitoring service interface
/// This provides a consistent API for tracking operations, errors, and events
/// regardless of the underlying implementation (CloudWatch, Firebase, etc.)
abstract class MonitoringService {
  /// Track a timed operation with its duration
  ///
  /// [operationName] - The name of the operation being tracked
  /// [duration] - How long the operation took
  /// [category] - Optional category to group related metrics
  void trackOperation(String operationName, Duration duration,
      {MetricCategory? category});

  /// Report an error that occurred in the application
  ///
  /// [errorType] - Classification of the error (e.g., 'NetworkError', 'AuthError')
  /// [error] - The actual error object or message
  /// [stackTrace] - Stack trace for debugging
  /// [context] - Additional contextual information about the error
  void reportError(String errorType, dynamic error, StackTrace stackTrace,
      {Map<String, dynamic>? context});

  /// Track a discrete event that occurred in the application
  ///
  /// [eventName] - Name of the event being tracked
  /// [parameters] - Optional parameters providing additional context
  void trackEvent(String eventName, {Map<String, dynamic>? parameters});

  /// Start tracking a user session
  /// Called when the app is opened or a user logs in
  void startSession();

  /// End tracking of a user session
  /// Called when the app is closed or a user logs out
  void endSession();

  /// Set user identifier for the current session
  ///
  /// [userId] - The unique identifier for the current user
  void setUserId(String userId);

  /// Set additional user properties for segmentation
  ///
  /// [properties] - Map of user properties to set
  void setUserProperties(Map<String, dynamic> properties);
}
