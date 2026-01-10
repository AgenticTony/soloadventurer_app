import '../entities/trusted_contact.dart';
import '../repositories/safety_repository.dart';

/// Use case for retrieving trusted contacts
class GetTrustedContactsUseCase {
  final SafetyRepository _repository;

  /// Creates a new [GetTrustedContactsUseCase] with the given repository
  const GetTrustedContactsUseCase(this._repository);

  /// Execute the use case to get all trusted contacts
  ///
  /// Returns a list of all trusted contacts for the current user,
  /// sorted by when they were added (most recent first).
  Future<List<TrustedContact>> call() => _repository.getTrustedContacts();

  /// Get a specific trusted contact by ID
  ///
  /// Returns the trusted contact with the given [contactId].
  /// Throws [Exception] if the contact is not found.
  Future<TrustedContact> getContactById(String contactId) =>
      _repository.getTrustedContact(contactId);
}
