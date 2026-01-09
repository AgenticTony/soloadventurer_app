import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/safety/domain/entities/check_in.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_alert.dart';
import 'package:soloadventurer/features/safety/domain/entities/trusted_contact.dart';

part 'missed_checkin_detector.g.dart';

/// Configuration for missed check-in detection
class MissedCheckInConfig {
  /// Grace period after deadline before marking as missed (in minutes)
  static const int gracePeriodMinutes = 5;

  /// Maximum number of recent location updates to check
  static const int maxRecentLocations = 5;

  /// Whether to include location in alerts by default
  static const bool includeLocationInAlerts = true;

  /// Default message for missed check-in alerts
  static const String defaultAlertMessage =
      'has missed a scheduled check-in and may need assistance';

  /// Maximum age of location data to use in alerts (in hours)
  static const int maxLocationAgeHours = 24;
}

/// Result of a missed check-in detection operation
class MissedCheckInDetectionResult {
  /// Whether the operation was successful
  final bool success;

  /// Number of check-ins processed
  final int processedCount;

  /// Number of missed check-ins detected
  final int missedCheckInsDetected;

  /// Number of alerts sent
  final int alertsSent;

  /// IDs of check-ins that were marked as missed
  final List<String> missedCheckInIds;

  /// Error message if operation failed
  final String? errorMessage;

  const MissedCheckInDetectionResult({
    required this.success,
    this.processedCount = 0,
    this.missedCheckInsDetected = 0,
    this.alertsSent = 0,
    this.missedCheckInIds = const [],
    this.errorMessage,
  });

  /// Creates a successful result
  factory MissedCheckInDetectionResult.success({
    int processedCount = 0,
    int missedCheckInsDetected = 0,
    int alertsSent = 0,
    List<String> missedCheckInIds = const [],
  }) {
    return MissedCheckInDetectionResult(
      success: true,
      processedCount: processedCount,
      missedCheckInsDetected: missedCheckInsDetected,
      alertsSent: alertsSent,
      missedCheckInIds: missedCheckInIds,
    );
  }

  /// Creates a failure result
  factory MissedCheckInDetectionResult.failure(String errorMessage) {
    return MissedCheckInDetectionResult(
      success: false,
      errorMessage: errorMessage,
    );
  }

  @override
  String toString() {
    if (success) {
      return 'MissedCheckInDetectionResult(success: true, processed: $processedCount, '
          'missed: $missedCheckInsDetected, alerts: $alertsSent)';
    }
    return 'MissedCheckInDetectionResult(success: false, error: $errorMessage)';
  }
}

/// Exception thrown when missed check-in detection fails
class MissedCheckInDetectionException implements Exception {
  final String message;

  MissedCheckInDetectionException(this.message);

  @override
  String toString() => 'MissedCheckInDetectionException: $message';
}

/// Status of the missed check-in detector service
enum MissedCheckInDetectorStatus {
  /// Service is initialized and running
  initialized,

  /// Service is currently checking for missed check-ins
  checking,

  /// Service is stopped
  stopped,

  /// Service encountered an error
  error,
}

/// Abstract interface for missed check-in detection
abstract class MissedCheckInDetector {
  /// Current status of the detector
  MissedCheckInDetectorStatus get status;

  /// Stream of status changes
  Stream<MissedCheckInDetectorStatus> get onStatusChanged;

  /// Initializes the detector
  ///
  /// Must be called before using any other methods.
  Future<void> initialize();

  /// Checks for missed check-ins and triggers alerts
  ///
  /// This method should be called periodically (e.g., every 15 minutes)
  /// to check for check-ins that have passed their deadline.
  Future<MissedCheckInDetectionResult> checkForMissedCheckIns();

  /// Checks a specific check-in to see if it's missed
  ///
  /// [checkIn] - The check-in to check
  /// Returns true if the check-in is considered missed
  bool isCheckInMissed(CheckIn checkIn);

  /// Manually triggers a missed check-in alert
  ///
  /// [checkIn] - The check-in that was missed
  /// [trustedContacts] - List of trusted contacts to notify
  /// Returns the created safety alert
  Future<SafetyAlert> triggerMissedCheckInAlert({
    required CheckIn checkIn,
    required List<TrustedContact> trustedContacts,
  });

  /// Disposes any resources
  void dispose();
}

/// Provider for the missed check-in detector implementation
@riverpod
MissedCheckInDetector missedCheckInDetector(Ref ref) {
  throw UnimplementedError(
    'MissedCheckInDetector implementation not provided. '
    'Use missedCheckInDetectorProvider from missed_checkin_detector_impl.dart',
  );
}
