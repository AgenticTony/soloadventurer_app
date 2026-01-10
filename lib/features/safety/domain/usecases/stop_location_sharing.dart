import '../repositories/safety_repository.dart';

/// Use case for stopping location sharing with trusted contacts
class StopLocationSharingUseCase {
  final SafetyRepository _repository;

  /// Creates a new [StopLocationSharingUseCase] with the given repository
  const StopLocationSharingUseCase(this._repository);

  /// Execute the use case to stop sharing location with specific contacts
  ///
  /// Stops location sharing only for the contacts specified in [contactIds].
  /// Other active location shares will continue.
  Future<void> call(List<String> contactIds) =>
      _repository.stopLocationSharing(contactIds);

  /// Stop sharing location with a single contact
  ///
  /// Convenience method for stopping location sharing with a single contact.
  Future<void> stopWithContact(String contactId) =>
      _repository.stopLocationSharing([contactId]);

  /// Stop all location sharing
  ///
  /// Stops location sharing with all trusted contacts.
  /// This will end all active location shares.
  Future<void> stopAll() => _repository.stopAllLocationSharing();
}
