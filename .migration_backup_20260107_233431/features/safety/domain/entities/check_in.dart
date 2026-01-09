import 'package:freezed_annotation/freezed_annotation.dart';

part 'check_in.freezed.dart';
part 'check_in.g.dart';

/// Status of a check-in
enum CheckInStatus {
  /// Check-in is scheduled for the future
  scheduled,
  /// Check-in is currently active (waiting for user to check in)
  active,
  /// Check-in was completed successfully
  completed,
  /// Check-in was missed (user didn't check in on time)
  missed,
  /// Check-in was cancelled
  cancelled,
}

/// Type of check-in trigger
enum CheckInTriggerType {
  /// Manual check-in initiated by user
  manual,
  /// Scheduled check-in at a specific time
  scheduledTime,
  /// Location-based check-in when arriving at a location
  locationArrival,
  /// Location-based check-in when departing a location
  locationDeparture,
}

/// Represents a check-in (manual or scheduled)
@freezed
class CheckIn with _$CheckIn {
  const CheckIn._();

  const factory CheckIn({
    /// Unique identifier for the check-in
    required String id,

    /// User ID who created this check-in
    required String userId,

    /// Type of check-in trigger
    required CheckInTriggerType triggerType,

    /// Current status of the check-in
    required CheckInStatus status,

    /// Scheduled time for the check-in (null for manual)
    DateTime? scheduledTime,

    /// Deadline for completing the check-in
    DateTime? deadline,

    /// When the check-in was actually completed
    DateTime? completedAt,

    /// Location data at check-in time
    CheckInLocation? location,

    /// User's status message at check-in
    String? statusMessage,

    /// Associated trip ID (if check-in is part of a trip)
    String? tripId,

    /// IDs of trusted contacts to notify
    required List<String> notifyContactIds,

    /// Whether alert was sent to contacts for missed check-in
    @Default(false) bool alertSent,

    /// When alert was sent (if applicable)
    DateTime? alertSentAt,

    /// Additional metadata
    Map<String, dynamic>? metadata,

    /// When this check-in was created
    required DateTime createdAt,

    /// When this check-in was last updated
    DateTime? updatedAt,
  }) = _CheckIn;

  factory CheckIn.fromJson(Map<String, dynamic> json) =>
      _$CheckInFromJson(json);
}

/// Location data associated with a check-in
@freezed
class CheckInLocation with _$CheckInLocation {
  const CheckInLocation._();

  const factory CheckInLocation({
    /// Latitude
    required double latitude,

    /// Longitude
    required double longitude,

    /// Accuracy of the location in meters
    double? accuracy,

    /// Altitude in meters
    double? altitude,

    /// Human-readable address
    String? address,

    /// Place name (if applicable)
    String? placeName,

    /// When this location was recorded
    required DateTime timestamp,
  }) = _CheckInLocation;

  factory CheckInLocation.fromJson(Map<String, dynamic> json) =>
      _$CheckInLocationFromJson(json);
}
