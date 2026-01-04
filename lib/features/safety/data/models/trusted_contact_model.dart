import 'package:soloadventurer/features/safety/domain/entities/trusted_contact.dart';

/// Data layer representation of [TrustedContact] entity
class TrustedContactModel extends TrustedContact {
  const TrustedContactModel({
    required super.id,
    required super.userId,
    required super.name,
    required super.phoneNumber,
    super.email,
    required super.source,
    super.communityUserId,
    required super.permission,
    super.locationSharingEnabled = false,
    super.receivesCheckIns = true,
    super.receivesEmergencyAlerts = true,
    required super.addedAt,
    super.updatedAt,
    super.revokedAt,
    super.notes,
  });

  /// Creates a [TrustedContactModel] from JSON map
  factory TrustedContactModel.fromJson(Map<String, dynamic> json) {
    return TrustedContactModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      phoneNumber: json['phone_number'] as String,
      email: json['email'] as String?,
      source: _parseContactSource(json['source'] as String?),
      communityUserId: json['community_user_id'] as String?,
      permission: _parseContactPermission(json['permission'] as String?),
      locationSharingEnabled: json['location_sharing_enabled'] as bool? ?? false,
      receivesCheckIns: json['receives_check_ins'] as bool? ?? true,
      receivesEmergencyAlerts:
          json['receives_emergency_alerts'] as bool? ?? true,
      addedAt: DateTime.parse(json['added_at'] as String),
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
      revokedAt: json['revoked_at'] != null
          ? DateTime.parse(json['revoked_at'] as String)
          : null,
      notes: json['notes'] as String?,
    );
  }

  /// Converts this [TrustedContactModel] to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'phone_number': phoneNumber,
      'email': email,
      'source': _serializeContactSource(source),
      'community_user_id': communityUserId,
      'permission': _serializeContactPermission(permission),
      'location_sharing_enabled': locationSharingEnabled,
      'receives_check_ins': receivesCheckIns,
      'receives_emergency_alerts': receivesEmergencyAlerts,
      'added_at': addedAt.toIso8601String(),
      'updated_at': updatedAt?.toIso8601String(),
      'revoked_at': revokedAt?.toIso8601String(),
      'notes': notes,
    };
  }

  /// Creates a [TrustedContactModel] from a [TrustedContact] entity
  factory TrustedContactModel.fromEntity(TrustedContact contact) {
    return TrustedContactModel(
      id: contact.id,
      userId: contact.userId,
      name: contact.name,
      phoneNumber: contact.phoneNumber,
      email: contact.email,
      source: contact.source,
      communityUserId: contact.communityUserId,
      permission: contact.permission,
      locationSharingEnabled: contact.locationSharingEnabled,
      receivesCheckIns: contact.receivesCheckIns,
      receivesEmergencyAlerts: contact.receivesEmergencyAlerts,
      addedAt: contact.addedAt,
      updatedAt: contact.updatedAt,
      revokedAt: contact.revokedAt,
      notes: contact.notes,
    );
  }

  /// Converts this model to an entity
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

  static ContactSource _parseContactSource(String? value) {
    switch (value) {
      case 'phone':
        return ContactSource.phone;
      case 'community':
        return ContactSource.community;
      default:
        throw ArgumentError('Invalid ContactSource: $value');
    }
  }

  static String _serializeContactSource(ContactSource source) {
    switch (source) {
      case ContactSource.phone:
        return 'phone';
      case ContactSource.community:
        return 'community';
    }
  }

  static ContactPermission _parseContactPermission(String? value) {
    switch (value) {
      case 'emergency_only':
        return ContactPermission.emergencyOnly;
      case 'check_ins':
        return ContactPermission.checkIns;
      case 'full_access':
        return ContactPermission.fullAccess;
      default:
        throw ArgumentError('Invalid ContactPermission: $value');
    }
  }

  static String _serializeContactPermission(ContactPermission permission) {
    switch (permission) {
      case ContactPermission.emergencyOnly:
        return 'emergency_only';
      case ContactPermission.checkIns:
        return 'check_ins';
      case ContactPermission.fullAccess:
        return 'full_access';
    }
  }
}
