import '../entities/trusted_contact.dart';
import '../repositories/safety_repository.dart';

/// Use case for updating an existing trusted contact
class UpdateTrustedContactUseCase {
  final SafetyRepository _repository;

  /// Creates a new [UpdateTrustedContactUseCase] with the given repository
  const UpdateTrustedContactUseCase(this._repository);

  /// Execute the use case to update a trusted contact
  ///
  /// Updates the trusted contact with new information. The contact must exist
  /// and the [contact.id] must match an existing trusted contact.
  /// Returns the updated [TrustedContact].
  Future<TrustedContact> call(TrustedContact contact) =>
      _repository.updateTrustedContact(contact);

  /// Update location sharing permission for a contact
  ///
  /// Enables or disables location sharing with the specified contact.
  Future<void> updateLocationSharing({
    required String contactId,
    required bool enabled,
  }) =>
      _repository.updateLocationSharingPermission(
        contactId: contactId,
        enabled: enabled,
      );

  /// Update notification preferences for a contact
  ///
  /// Controls whether the contact receives check-ins and/or emergency alerts.
  Future<void> updateNotificationPreferences({
    required String contactId,
    required bool receivesCheckIns,
    required bool receivesEmergencyAlerts,
  }) =>
      _repository.updateContactNotificationPreferences(
        contactId: contactId,
        receivesCheckIns: receivesCheckIns,
        receivesEmergencyAlerts: receivesEmergencyAlerts,
      );
}
