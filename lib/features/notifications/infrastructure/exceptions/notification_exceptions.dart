import 'package:soloadventurer/core/errors/exceptions.dart' as core;

/// Base exception for notification-related errors
class NotificationException extends core.AppException {
  final dynamic originalError;
  final StackTrace? stackTrace;

  const NotificationException({
    required super.message,
    this.originalError,
    this.stackTrace,
  });
}

/// Exception thrown when notification cache operations fail
class NotificationCacheException extends NotificationException {
  const NotificationCacheException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() =>
      'NotificationCacheException: $message${originalError != null ? ' (caused by $originalError)' : ''}';
}

/// Exception thrown when a requested notification is not found
class NotificationNotFoundException extends NotificationException {
  const NotificationNotFoundException({
    required String notificationId,
    super.originalError,
    super.stackTrace,
  }) : super(
          message: 'Notification with ID "$notificationId" not found',
        );
}

/// Exception thrown when notification preferences operations fail
class NotificationPreferencesException extends NotificationException {
  const NotificationPreferencesException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });

  @override
  String toString() =>
      'NotificationPreferencesException: $message${originalError != null ? ' (caused by $originalError)' : ''}';
}

/// Exception thrown when notification scheduling fails
class NotificationSchedulingFailedException extends NotificationException {
  const NotificationSchedulingFailedException({
    required super.message,
    super.originalError,
    super.stackTrace,
  });
}

/// Exception thrown when notification permission is denied
class NotificationPermissionDeniedException extends NotificationException {
  const NotificationPermissionDeniedException({
    super.message = 'Notification permission denied',
    super.originalError,
    super.stackTrace,
  });
}
