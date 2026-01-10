import '../entities/trusted_contact.dart';
import '../repositories/safety_repository.dart';

/// Use case for adding a new trusted contact
class AddTrustedContactUseCase {
  final SafetyRepository _repository;

  /// Creates a new [AddTrustedContactUseCase] with the given repository
  const AddTrustedContactUseCase(this._repository);

  /// Execute the use case to add a trusted contact
  ///
  /// Returns the created [TrustedContact] with generated ID and timestamps.
  Future<TrustedContact> call(TrustedContact contact) =>
      _repository.addTrustedContact(contact);
}
