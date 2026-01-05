// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trusted_contact.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TrustedContactImpl _$$TrustedContactImplFromJson(Map<String, dynamic> json) =>
    _$TrustedContactImpl(
      id: json['id'] as String,
      userId: json['userId'] as String,
      name: json['name'] as String,
      phoneNumber: json['phoneNumber'] as String,
      email: json['email'] as String?,
      source: $enumDecode(_$ContactSourceEnumMap, json['source']),
      communityUserId: json['communityUserId'] as String?,
      permission: $enumDecode(_$ContactPermissionEnumMap, json['permission']),
      locationSharingEnabled: json['locationSharingEnabled'] as bool? ?? false,
      receivesCheckIns: json['receivesCheckIns'] as bool? ?? true,
      receivesEmergencyAlerts: json['receivesEmergencyAlerts'] as bool? ?? true,
      addedAt: DateTime.parse(json['addedAt'] as String),
      updatedAt: json['updatedAt'] == null
          ? null
          : DateTime.parse(json['updatedAt'] as String),
      revokedAt: json['revokedAt'] == null
          ? null
          : DateTime.parse(json['revokedAt'] as String),
      notes: json['notes'] as String?,
    );

Map<String, dynamic> _$$TrustedContactImplToJson(
        _$TrustedContactImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'name': instance.name,
      'phoneNumber': instance.phoneNumber,
      'email': instance.email,
      'source': _$ContactSourceEnumMap[instance.source]!,
      'communityUserId': instance.communityUserId,
      'permission': _$ContactPermissionEnumMap[instance.permission]!,
      'locationSharingEnabled': instance.locationSharingEnabled,
      'receivesCheckIns': instance.receivesCheckIns,
      'receivesEmergencyAlerts': instance.receivesEmergencyAlerts,
      'addedAt': instance.addedAt.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
      'revokedAt': instance.revokedAt?.toIso8601String(),
      'notes': instance.notes,
    };

const _$ContactSourceEnumMap = {
  ContactSource.phone: 'phone',
  ContactSource.community: 'community',
};

const _$ContactPermissionEnumMap = {
  ContactPermission.emergencyOnly: 'emergencyOnly',
  ContactPermission.checkIns: 'checkIns',
  ContactPermission.fullAccess: 'fullAccess',
};
