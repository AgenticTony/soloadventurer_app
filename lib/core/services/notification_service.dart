import 'dart:typed_data';
import 'package:riverpod_annotation/riverpod_annotation.dart';

// Import for the implementation provider
import 'notification_service_impl.dart' show notificationServiceOverrideProvider;

part 'notification_service.g.dart';

/// Notification types for safety features
enum SafetyNotificationType {
  /// Reminder to complete a check-in
  checkInReminder,

  /// Alert that a check-in was missed
  checkInMissed,

  /// Emergency SOS has been triggered
  emergencySOS,

  /// Safety status has been updated
  safetyStatusUpdate,

  /// Location is being shared
  locationSharing,

  /// Location sharing has stopped
  locationSharingStopped,

  /// General safety alert
  generalAlert,

  /// Background sync or system operation (e.g., token refresh)
  backgroundSync,
}

/// Notification channel IDs
class NotificationChannels {
  /// Check-in reminders and notifications
  static const String checkIns = 'check_in_notifications';

  /// Emergency and SOS alerts
  static const String emergency = 'emergency_alerts';

  /// Location sharing updates
  static const String locationSharing = 'location_sharing';

  /// General safety notifications
  static const String general = 'general_safety';

  /// Background sync and system operations
  static const String backgroundSync = 'background_sync';
}

/// Configuration for safety notifications
class SafetyNotificationConfig {
  /// Default notification channel for check-ins
  static const String checkInChannelId = NotificationChannels.checkIns;
  static const String checkInChannelName = 'Check-in Reminders';
  static const String checkInChannelDescription =
      'Notifications for check-in reminders and status updates';

  /// Default notification channel for emergency alerts
  static const String emergencyChannelId = NotificationChannels.emergency;
  static const String emergencyChannelName = 'Emergency Alerts';
  static const String emergencyChannelDescription =
      'Critical emergency and SOS notifications';

  /// Default notification channel for location sharing
  static const String locationChannelId = NotificationChannels.locationSharing;
  static const String locationChannelName = 'Location Sharing';
  static const String locationChannelDescription =
      'Notifications about location sharing status';

  /// Default notification channel for general safety
  static const String generalChannelId = NotificationChannels.general;
  static const String generalChannelName = 'Safety Notifications';
  static const String generalChannelDescription =
      'General safety feature notifications';

  /// Notification icon for Android
  static const String notificationIcon = '@mipmap/ic_launcher';

  /// Default vibration pattern
  static final Int64List vibrationPattern =
      Int64List.fromList([0, 500, 200, 500]);

  /// Default notification importance for emergency
  static const NotificationImportance emergencyImportance =
      NotificationImportance.max;

  /// Default notification importance for check-ins
  static const NotificationImportance checkInImportance =
      NotificationImportance.high;

  /// Default notification importance for location sharing
  static const NotificationImportance locationImportance =
      NotificationImportance.defaultImportance;

  /// Default notification importance for general
  static const NotificationImportance generalImportance =
      NotificationImportance.defaultImportance;
}

/// Importance level for notifications
enum NotificationImportance {
  max,
  high,
  defaultImportance,
  low,
  min,
  none,
}

/// Result of a notification operation
class NotificationResult {
  /// Whether the operation was successful
  final bool success;

  /// ID of the scheduled notification (if applicable)
  final int? notificationId;

  /// Error message if operation failed
  final String? errorMessage;

  const NotificationResult({
    required this.success,
    this.notificationId,
    this.errorMessage,
  });

  /// Creates a successful result
  factory NotificationResult.success({int? notificationId}) {
    return NotificationResult(
      success: true,
      notificationId: notificationId,
    );
  }

  /// Creates a failure result
  factory NotificationResult.failure(String errorMessage) {
    return NotificationResult(
      success: false,
      errorMessage: errorMessage,
    );
  }

  @override
  String toString() {
    if (success) {
      return 'NotificationResult(success: true, id: $notificationId)';
    }
    return 'NotificationResult(success: false, error: $errorMessage)';
  }
}

/// Abstract interface for notification operations
abstract class NotificationService {
  /// Initializes the notification service
  ///
  /// Must be called before using any other notification methods.
  /// Requests necessary permissions from the user.
  Future<void> initialize();

  /// Checks if notification permissions are granted
  Future<bool> arePermissionsGranted();

  /// Requests notification permissions from the user
  ///
  /// Returns true if permissions are granted
  Future<bool> requestPermissions();

  /// Shows an immediate notification
  ///
  /// [title] - The notification title
  /// [body] - The notification body text
  /// [type] - The type of notification (determines channel)
  /// [payload] - Optional payload data to attach to the notification
  /// Returns the notification ID
  Future<NotificationResult> showNotification({
    required String title,
    required String body,
    required SafetyNotificationType type,
    Map<String, dynamic>? payload,
  });

  /// Schedules a notification to be shown at a specific time
  ///
  /// [title] - The notification title
  /// [body] - The notification body text
  /// [scheduledTime] - When to show the notification
  /// [type] - The type of notification (determines channel)
  /// [payload] - Optional payload data to attach to the notification
  /// Returns the notification ID
  Future<NotificationResult> scheduleNotification({
    required String title,
    required String body,
    required DateTime scheduledTime,
    required SafetyNotificationType type,
    Map<String, dynamic>? payload,
  });

  /// Schedules a recurring notification
  ///
  /// [title] - The notification title
  /// [body] - The notification body text
  /// [interval] - How often to repeat the notification
  /// [type] - The type of notification (determines channel)
  /// [payload] - Optional payload data to attach to the notification
  /// Returns the notification ID
  Future<NotificationResult> scheduleRepeatingNotification({
    required String title,
    required String body,
    required Duration interval,
    required SafetyNotificationType type,
    Map<String, dynamic>? payload,
  });

  /// Cancels a specific notification
  ///
  /// [id] - The ID of the notification to cancel
  Future<void> cancelNotification(int id);

  /// Cancels all notifications
  Future<void> cancelAllNotifications();

  /// Cancels all notifications of a specific type
  ///
  /// [type] - The type of notifications to cancel
  Future<void> cancelNotificationsByType(SafetyNotificationType type);

  /// Shows a check-in reminder notification
  ///
  /// [checkInId] - The ID of the check-in
  /// [scheduledTime] - When the check-in is scheduled
  /// [deadline] - The deadline for completing the check-in
  Future<NotificationResult> showCheckInReminder({
    required String checkInId,
    required DateTime scheduledTime,
    required DateTime deadline,
  });

  /// Schedules a check-in reminder notification
  ///
  /// [checkInId] - The ID of the check-in
  /// [scheduledTime] - When to show the reminder
  /// [deadline] - The deadline for completing the check-in
  Future<NotificationResult> scheduleCheckInReminder({
    required String checkInId,
    required DateTime reminderTime,
    required DateTime deadline,
  });

  /// Shows a missed check-in alert
  ///
  /// [checkInId] - The ID of the missed check-in
  /// [lastKnownLocation] - Optional last known location description
  Future<NotificationResult> showMissedCheckInAlert({
    required String checkInId,
    String? lastKnownLocation,
  });

  /// Shows an emergency SOS notification
  ///
  /// [alertId] - The ID of the emergency alert
  /// [location] - Optional location description
  /// [message] - Optional message from the user
  Future<NotificationResult> showEmergencySOS({
    required String alertId,
    String? location,
    String? message,
  });

  /// Shows a safety status update notification
  ///
  /// [status] - The safety status (safe, need help, emergency)
  /// [message] - Optional status message
  Future<NotificationResult> showSafetyStatusUpdate({
    required String status,
    String? message,
  });

  /// Shows a location sharing notification
  ///
  /// [contactNames] - List of contact names receiving location
  Future<NotificationResult> showLocationSharingStarted({
    required List<String> contactNames,
  });

  /// Shows a location sharing stopped notification
  Future<NotificationResult> showLocationSharingStopped();

  /// Gets pending scheduled notifications
  Future<List<PendingNotification>> getPendingNotifications();

  /// Disposes any resources
  void dispose();
}

/// Represents a pending scheduled notification
class PendingNotification {
  /// ID of the notification
  final int id;

  /// Title of the notification
  final String title;

  /// Body of the notification
  final String body;

  /// When the notification is scheduled to be shown
  final DateTime scheduledTime;

  /// Type of notification
  final SafetyNotificationType type;

  /// Payload data
  final Map<String, dynamic>? payload;

  const PendingNotification({
    required this.id,
    required this.title,
    required this.body,
    required this.scheduledTime,
    required this.type,
    this.payload,
  });

  @override
  String toString() {
    return 'PendingNotification(id: $id, title: $title, scheduled: $scheduledTime)';
  }
}

/// Provider for the notification service implementation
///
/// This provider returns the actual implementation from notification_service_impl.dart.
/// The notificationServiceOverrideProvider handles the proper instantiation and disposal.
@riverpod
NotificationService notificationService(Ref ref) {
  return ref.watch(notificationServiceOverrideProvider);
}
