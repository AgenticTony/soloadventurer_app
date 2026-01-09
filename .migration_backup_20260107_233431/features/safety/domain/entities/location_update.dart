import 'package:freezed_annotation/freezed_annotation.dart';

part 'location_update.freezed.dart';
part 'location_update.g.dart';

/// Status of location sharing
enum LocationSharingStatus {
  /// Location sharing is active
  active,
  /// Location sharing is paused
  paused,
  /// Location sharing has ended
  ended,
}

/// Represents a location update shared with trusted contacts
@freezed
class LocationUpdate with _$LocationUpdate {
  const LocationUpdate._();

  const factory LocationUpdate({
    /// Unique identifier for the location update
    required String id,

    /// User ID who is sharing their location
    required String userId,

    /// Latitude
    required double latitude,

    /// Longitude
    required double longitude,

    /// Accuracy of the location in meters
    double? accuracy,

    /// Altitude in meters
    double? altitude,

    /// Speed in m/s
    double? speed,

    /// Heading in degrees
    double? heading,

    /// Human-readable address
    String? address,

    /// Place name (if applicable)
    String? placeName,

    /// Status of location sharing
    required LocationSharingStatus sharingStatus,

    /// IDs of trusted contacts receiving this update
    required List<String> sharedWithContactIds,

    /// Battery level at time of update (0-100)
    int? batteryLevel,

    /// Whether this is an emergency location update
    @Default(false) bool isEmergency,

    /// Associated emergency/SOS alert ID (if applicable)
    String? emergencyAlertId,

    /// Associated check-in ID (if applicable)
    String? checkInId,

    /// Additional metadata
    Map<String, dynamic>? metadata,

    /// When this location update was created
    required DateTime createdAt,
  }) = _LocationUpdate;

  factory LocationUpdate.fromJson(Map<String, dynamic> json) =>
      _$LocationUpdateFromJson(json);
}
