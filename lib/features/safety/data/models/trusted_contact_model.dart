import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:soloadventurer/features/safety/domain/entities/trusted_contact.dart';

part 'trusted_contact_model.freezed.dart';
part 'trusted_contact_model.g.dart';

/// Model for [TrustedContact] with JSON serialization
@freezed
class TrustedContactModel with _$TrustedContactModel {
  const TrustedContactModel._();

  const factory TrustedContactModel({
    required String id,
    required String userId,
    required String name,
    required String phoneNumber,
    String? email,
    required ContactSource source,
    String? communityUserId,
    required ContactPermission permission,
    @Default(false) bool locationSharingEnabled,
    @Default(true) bool receivesCheckIns,
    @Default(true) bool receivesEmergencyAlerts,
    required DateTime addedAt,
    DateTime? updatedAt,
    DateTime? revokedAt,
    String? notes,
  }) = _TrustedContactModel;

  factory TrustedContactModel.fromJson(Map<String, dynamic> json) =>
      _$TrustedContactModelFromJson(json);

  /// Convert from domain entity
  factory TrustedContactModel.fromEntity(TrustedContact entity) {
    return TrustedContactModel(
      id: entity.id,
      userId: entity.userId,
      name: entity.name,
      phoneNumber: entity.phoneNumber,
      email: entity.email,
      source: entity.source,
      communityUserId: entity.communityUserId,
      permission: entity.permission,
      locationSharingEnabled: entity.locationSharingEnabled,
      receivesCheckIns: entity.receivesCheckIns,
      receivesEmergencyAlerts: entity.receivesEmergencyAlerts,
      addedAt: entity.addedAt,
      updatedAt: entity.updatedAt,
      revokedAt: entity.revokedAt,
      notes: entity.notes,
    );
  }

  /// Convert to domain entity
  TrustedContact toEntity() {
    return TrustedContact(
      id: id,
      userId: userId,
      name: name,
      phoneNumber: phoneNumber,
      email: email,
      source: source,
      communityUserId: communityUserId,
      permission: permission,
      locationSharingEnabled: locationSharingEnabled,
      receivesCheckIns: receivesCheckIns,
      receivesEmergencyAlerts: receivesEmergencyAlerts,
      addedAt: addedAt,
      updatedAt: updatedAt,
      revokedAt: revokedAt,
      notes: notes,
    );
  }
}
