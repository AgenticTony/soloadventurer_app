import 'package:freezed_annotation/freezed_annotation.dart';

part 'trusted_contact.freezed.dart';
part 'trusted_contact.g.dart';

/// Source of the trusted contact (phone contacts or app community)
enum ContactSource {
  phone,
  community,
}

/// Permission level for trusted contacts
enum ContactPermission {
  /// Can only receive alerts during emergencies
  emergencyOnly,
  /// Can receive check-ins and emergency alerts
  checkIns,
  /// Can receive check-ins, emergency alerts, and location updates
  fullAccess,
}

/// Represents a trusted emergency contact
@freezed
class TrustedContact with _$TrustedContact {
  const TrustedContact._();

  const factory TrustedContact({
    /// Unique identifier for the trusted contact
    required String id,

    /// User ID who owns this trusted contact
    required String userId,

    /// Contact's name
    required String name,

    /// Contact's phone number
    required String phoneNumber,

    /// Contact's email (optional)
    String? email,

    /// Source of the contact (phone or community)
    required ContactSource source,

    /// Community user ID if from community source
    String? communityUserId,

    /// Permission level for this contact
    required ContactPermission permission,

    /// Whether location sharing is currently active with this contact
    @Default(false) bool locationSharingEnabled,

    /// Whether this contact receives check-in notifications
    @Default(true) bool receivesCheckIns,

    /// Whether this contact receives emergency alerts
    @Default(true) bool receivesEmergencyAlerts,

    /// When this contact was added
    required DateTime addedAt,

    /// When this contact was last updated
    DateTime? updatedAt,

    /// When this trusted contact relationship was revoked (if applicable)
    DateTime? revokedAt,

    /// Notes about this contact
    String? notes,
  }) = _TrustedContact;

  factory TrustedContact.fromJson(Map<String, dynamic> json) =>
      _$TrustedContactFromJson(json);
}
