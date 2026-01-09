/// Interface for logging service following clean architecture principles
abstract class LoggingService {
  /// Log a state transition with relevant metadata
  void logStateTransition({
    required String feature,
    required String fromState,
    required String toState,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  });

  /// Log an error with context
  void logError({
    required String feature,
    required String error,
    String? code,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  });

  /// Log an authentication event
  void logAuthEvent({
    required String event,
    required String status,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  });

  /// Log a token lifecycle event
  void logTokenEvent({
    required String event,
    required String status,
    Map<String, dynamic>? metadata,
    StackTrace? stackTrace,
  });

  /// Log token rotation events
  void logTokenRotation({
    required Object oldSession,
    required Object newSession,
    String? reason,
  });

  /// Log token blacklist events
  void logTokenBlacklist({
    required String token,
    required String reason,
    DateTime? expiryTime,
  });

  /// Log token refresh attempts
  void logTokenRefresh({
    required bool success,
    String? error,
    int attemptNumber = 1,
    Map<String, dynamic>? additionalInfo,
  });
}
