import 'package:freezed_annotation/freezed_annotation.dart';

part 'safety_status.freezed.dart';
part 'safety_status.g.dart';

/// Current safety status of the user
enum SafetyStatusType {
  /// User is safe
  safe,
  /// User needs help but it's not an emergency
  needHelp,
  /// User is in an emergency situation
  emergency,
  /// Unknown status
  unknown,
}

/// Represents the user's current safety status
@freezed
class SafetyStatus with _$SafetyStatus {
  const factory SafetyStatus({
    /// Unique identifier for the safety status
    required String id,

    /// User ID
    required String userId,

    /// Current safety status
    required SafetyStatusType status,

    /// Optional message describing the status
    String? message,

    /// Location associated with this status
    SafetyStatusLocation? location,

    /// Battery level at time of status update (0-100)
    int? batteryLevel,

    /// When this status was set
    required DateTime timestamp,

    /// When this status was last updated
    DateTime? updatedAt,

    /// Associated safety alert ID (if status was set via alert)
    String? safetyAlertId,

    /// Associated check-in ID (if status was set via check-in)
    String? checkInId,

    /// Additional metadata
    Map<String, dynamic>? metadata,
  }) = _SafetyStatus;

  factory SafetyStatus.fromJson(Map<String, dynamic> json) =>
      _$SafetyStatusFromJson(json);
}

/// Location data associated with a safety status
@freezed
class SafetyStatusLocation with _$SafetyStatusLocation {
  const factory SafetyStatusLocation({
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
  }) = _SafetyStatusLocation;

  factory SafetyStatusLocation.fromJson(Map<String, dynamic> json) =>
      _$SafetyStatusLocationFromJson(json);
}
