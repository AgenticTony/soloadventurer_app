import '../repositories/safety_repository.dart';

/// Use case for removing a trusted contact
class RemoveTrustedContactUseCase {
  final SafetyRepository _repository;

  /// Creates a new [RemoveTrustedContactUseCase] with the given repository
  const RemoveTrustedContactUseCase(this._repository);

  /// Execute the use case to remove a trusted contact
  ///
  /// Removes the trusted contact with the given [contactId] from the user's
  /// trusted contacts list. This action cannot be undone.
  Future<void> call(String contactId) =>
      _repository.removeTrustedContact(contactId);
}
