import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'background_checkin_service.g.dart';

/// Configuration for background check-in operations
class BackgroundCheckInConfig {
  /// Unique identifier for the check-in monitoring task
  static const String monitoringTaskId = 'com.soloadventurer.checkin.monitoring';

  /// Task name for check-in monitoring
  static const String monitoringTaskName = 'checkInMonitoringTask';

  /// Interval for checking due check-ins (every 15 minutes)
  static const Duration monitoringInterval = Duration(minutes: 15);

  /// Network timeout for check-in operations
  static const Duration networkTimeout = Duration(seconds: 30);

  /// Battery level threshold for background operations
  static const int minBatteryLevel = 15;

  /// Time before deadline to send reminder (in minutes)
  static const int reminderMinutesBeforeDeadline = 15;

  /// Grace period after deadline before marking as missed (in minutes)
  static const int missedGracePeriodMinutes = 5;
}

/// Result of a background check-in operation
class BackgroundCheckInResult {
  /// Whether the operation was successful
  final bool success;

  /// Number of check-ins processed
  final int processedCount;

  /// Number of reminders sent
  final int remindersSent;

  /// Number of missed check-ins detected
  final int missedCheckIns;

  /// Error message if operation failed
  final String? errorMessage;

  const BackgroundCheckInResult({
    required this.success,
    this.processedCount = 0,
    this.remindersSent = 0,
    this.missedCheckIns = 0,
    this.errorMessage,
  });

  /// Creates a successful result
  factory BackgroundCheckInResult.success({
    int processedCount = 0,
    int remindersSent = 0,
    int missedCheckIns = 0,
  }) {
    return BackgroundCheckInResult(
      success: true,
      processedCount: processedCount,
      remindersSent: remindersSent,
      missedCheckIns: missedCheckIns,
    );
  }

  /// Creates a failure result
  factory BackgroundCheckInResult.failure(String errorMessage) {
    return BackgroundCheckInResult(
      success: false,
      errorMessage: errorMessage,
    );
  }

  @override
  String toString() {
    if (success) {
      return 'BackgroundCheckInResult(success: true, processed: $processedCount, '
          'reminders: $remindersSent, missed: $missedCheckIns)';
    }
    return 'BackgroundCheckInResult(success: false, error: $errorMessage)';
  }
}

/// Status of background check-in service
enum BackgroundCheckInServiceStatus {
  /// Service is initialized and running
  initialized,

  /// Service is stopped
  stopped,

  /// Service encountered an error
  error,
}

/// Abstract interface for background check-in operations
abstract class BackgroundCheckInService {
  /// Current status of the service
  BackgroundCheckInServiceStatus get status;

  /// Stream of status changes
  Stream<BackgroundCheckInServiceStatus> get onStatusChanged;

  /// Initializes the background check-in service
  ///
  /// Throws an exception if initialization fails
  Future<void> initialize();

  /// Schedules a one-time check-in reminder
  ///
  /// [checkInId] - The ID of the check-in to remind about
  /// [scheduledTime] - When to send the reminder
  /// Returns true if scheduling was successful
  Future<bool> scheduleCheckInReminder({
    required String checkInId,
    required DateTime scheduledTime,
  });

  /// Schedules monitoring for missed check-ins
  ///
  /// This is called periodically to check for:
  /// - Upcoming check-ins that need reminders
  /// - Overdue check-ins that should be marked as missed
  /// Returns true if scheduling was successful
  Future<bool> scheduleMissedCheckInMonitoring();

  /// Cancels a scheduled check-in reminder
  ///
  /// [checkInId] - The ID of the check-in to cancel
  Future<void> cancelCheckInReminder(String checkInId);

  /// Cancels all scheduled check-in reminders
  Future<void> cancelAllReminders();

  /// Stops the background check-in service
  Future<void> stop();

  /// Processes due check-ins (called by background task)
  ///
  /// This method is called by the workmanager callback to process
  /// check-ins that are due or overdue.
  Future<BackgroundCheckInResult> processDueCheckIns();

  /// Disposes any resources
  void dispose();
}

/// Provider for the background check-in service implementation
@riverpod
BackgroundCheckInService backgroundCheckInService(Ref ref) {
  throw UnimplementedError(
    'BackgroundCheckInService implementation not provided. '
    'Use backgroundCheckInServiceProvider from background_checkin_service_impl.dart',
  );
}
