import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:soloadventurer/features/safety/domain/entities/location_update.dart';

part 'location_update_model.freezed.dart';
part 'location_update_model.g.dart';

/// Model for [LocationUpdate] with JSON serialization
@freezed
class LocationUpdateModel with _$LocationUpdateModel {

  const factory LocationUpdateModel({
    required String id,
    required String userId,
    required double latitude,
    required double longitude,
    double? accuracy,
    double? altitude,
    String? address,
    String? placeName,
    int? batteryLevel,
    required LocationSharingStatus sharingStatus,
    required List<String> sharedWithContactIds,
    @Default(false) bool emergency,
    String? checkInId,
    String? alertId,
    String? tripId,
    DateTime? expiresAt,
    required DateTime createdAt,
    DateTime? updatedAt,
  }) = _LocationUpdateModel;

  factory LocationUpdateModel.fromJson(Map<String, dynamic> json) =>
      _$LocationUpdateModelFromJson(json);

  /// Convert from domain entity
  factory LocationUpdateModel.fromEntity(LocationUpdate entity) {
    return LocationUpdateModel(
      id: entity.id,
      userId: entity.userId,
      latitude: entity.latitude,
      longitude: entity.longitude,
      accuracy: entity.accuracy,
      altitude: entity.altitude,
      address: entity.address,
      placeName: entity.placeName,
      batteryLevel: entity.batteryLevel,
      sharingStatus: entity.sharingStatus,
      sharedWithContactIds: entity.sharedWithContactIds,
      emergency: entity.isEmergency,
      checkInId: entity.checkInId,
      alertId: entity.emergencyAlertId,
      tripId: null, // Not in entity
      expiresAt: null, // Not in entity
      createdAt: entity.createdAt,
      updatedAt: null, // Not in entity
    );
  }

  /// Convert to domain entity
  LocationUpdate toEntity() {
    return LocationUpdate(
      id: id,
      userId: userId,
      latitude: latitude,
      longitude: longitude,
      accuracy: accuracy,
      altitude: altitude,
      address: address,
      placeName: placeName,
      batteryLevel: batteryLevel,
      sharingStatus: sharingStatus,
      sharedWithContactIds: sharedWithContactIds,
      isEmergency: emergency,
      checkInId: checkInId,
      emergencyAlertId: alertId,
      createdAt: createdAt,
    );
  }
}
