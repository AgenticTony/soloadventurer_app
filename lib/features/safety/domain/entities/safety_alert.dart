import 'package:freezed_annotation/freezed_annotation.dart';

part 'safety_alert.freezed.dart';
part 'safety_alert.g.dart';

/// Type of safety alert
enum SafetyAlertType {
  /// Emergency SOS button pressed
  emergencySOS,
  /// User updated status to need help
  needHelp,
  /// User updated status to emergency
  emergency,
  /// Check-in was missed
  missedCheckIn,
  /// Location sharing triggered
  locationUpdate,
  /// User manually checked in as safe
  safe,
}

/// Status of a safety alert
enum SafetyAlertStatus {
  /// Alert was sent but not yet acknowledged
  sent,
  /// Alert has been acknowledged by at least one contact
  acknowledged,
  /// Alert has been resolved (user is safe)
  resolved,
  /// Alert was cancelled (false alarm)
  cancelled,
}

/// Represents a safety alert sent to trusted contacts
@freezed
class SafetyAlert with _$SafetyAlert {
  const factory SafetyAlert({
    /// Unique identifier for the safety alert
    required String id,

    /// User ID who triggered the alert
    required String userId,

    /// Type of safety alert
    required SafetyAlertType type,

    /// Current status of the alert
    required SafetyAlertStatus status,

    /// User's safety status message
    String? message,

    /// Location data at time of alert
    SafetyAlertLocation? location,

    /// IDs of trusted contacts who were notified
    required List<String> notifiedContactIds,

    /// IDs of trusted contacts who acknowledged the alert
    required List<String> acknowledgedByContactIds,

    /// When the alert was triggered
    required DateTime triggeredAt,

    /// When the alert was first acknowledged
    DateTime? firstAcknowledgedAt,

    /// When the alert was resolved
    DateTime? resolvedAt,

    /// When the alert was cancelled
    DateTime? cancelledAt,

    /// Battery level at time of alert (0-100)
    int? batteryLevel,

    /// Associated check-in ID (if alert is for missed check-in)
    String? checkInId,

    /// Associated trip ID (if applicable)
    String? tripId,

    /// Additional metadata
    Map<String, dynamic>? metadata,

    /// When this safety alert was created
    required DateTime createdAt,

    /// When this safety alert was last updated
    DateTime? updatedAt,
  }) = _SafetyAlert;

  factory SafetyAlert.fromJson(Map<String, dynamic> json) =>
      _$SafetyAlertFromJson(json);
}

/// Location data associated with a safety alert
@freezed
class SafetyAlertLocation with _$SafetyAlertLocation {
  const factory SafetyAlertLocation({
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

    /// Google Maps URL
    String? mapsUrl,
  }) = _SafetyAlertLocation;

  factory SafetyAlertLocation.fromJson(Map<String, dynamic> json) =>
      _$SafetyAlertLocationFromJson(json);
}
