import 'package:soloadventurer/features/safety/domain/entities/location_update.dart';

/// Data layer representation of [LocationUpdate] entity
class LocationUpdateModel extends LocationUpdate {
  const LocationUpdateModel({
    required super.id,
    required super.userId,
    required super.latitude,
    required super.longitude,
    super.accuracy,
    super.altitude,
    super.speed,
    super.heading,
    super.address,
    super.placeName,
    required super.sharingStatus,
    required super.sharedWithContactIds,
    super.batteryLevel,
    super.isEmergency = false,
    super.emergencyAlertId,
    super.checkInId,
    super.metadata,
    required super.createdAt,
  });

  /// Creates a [LocationUpdateModel] from JSON map
  factory LocationUpdateModel.fromJson(Map<String, dynamic> json) {
    return LocationUpdateModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      accuracy: json['accuracy'] as double?,
      altitude: json['altitude'] as double?,
      speed: json['speed'] as double?,
      heading: json['heading'] as double?,
      address: json['address'] as String?,
      placeName: json['place_name'] as String?,
      sharingStatus: _parseSharingStatus(json['sharing_status'] as String),
      sharedWithContactIds:
          (json['shared_with_contact_ids'] as List<dynamic>).cast<String>(),
      batteryLevel: json['battery_level'] as int?,
      isEmergency: json['is_emergency'] as bool? ?? false,
      emergencyAlertId: json['emergency_alert_id'] as String?,
      checkInId: json['check_in_id'] as String?,
      metadata: json['metadata'] as Map<String, dynamic>?,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts this [LocationUpdateModel] to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'heading': heading,
      'address': address,
      'place_name': placeName,
      'sharing_status': _serializeSharingStatus(sharingStatus),
      'shared_with_contact_ids': sharedWithContactIds,
      'battery_level': batteryLevel,
      'is_emergency': isEmergency,
      'emergency_alert_id': emergencyAlertId,
      'check_in_id': checkInId,
      'metadata': metadata,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a [LocationUpdateModel] from a [LocationUpdate] entity
  factory LocationUpdateModel.fromEntity(LocationUpdate update) {
    return LocationUpdateModel(
      id: update.id,
      userId: update.userId,
      latitude: update.latitude,
      longitude: update.longitude,
      accuracy: update.accuracy,
      altitude: update.altitude,
      speed: update.speed,
      heading: update.heading,
      address: update.address,
      placeName: update.placeName,
      sharingStatus: update.sharingStatus,
      sharedWithContactIds: update.sharedWithContactIds,
      batteryLevel: update.batteryLevel,
      isEmergency: update.isEmergency,
      emergencyAlertId: update.emergencyAlertId,
      checkInId: update.checkInId,
      metadata: update.metadata,
      createdAt: update.createdAt,
    );
  }

  /// Converts this model to an entity
  LocationUpdate toEntity() {
    return LocationUpdate(
      id: id,
      userId: userId,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      altitude: altitude,
      speed: speed,
      heading: heading,
      address: address,
      placeName: placeName,
      sharingStatus: sharingStatus,
      sharedWithContactIds: sharedWithContactIds,
      batteryLevel: batteryLevel,
      isEmergency: isEmergency,
      emergencyAlertId: emergencyAlertId,
      checkInId: checkInId,
      metadata: metadata,
      createdAt: createdAt,
    );
  }

  static LocationSharingStatus _parseSharingStatus(String value) {
    switch (value) {
      case 'active':
        return LocationSharingStatus.active;
      case 'paused':
        return LocationSharingStatus.paused;
      case 'ended':
        return LocationSharingStatus.ended;
      default:
        throw ArgumentError('Invalid LocationSharingStatus: $value');
    }
  }

  static String _serializeSharingStatus(LocationSharingStatus status) {
    switch (status) {
      case LocationSharingStatus.active:
        return 'active';
      case LocationSharingStatus.paused:
        return 'paused';
      case LocationSharingStatus.ended:
        return 'ended';
    }
  }
}
