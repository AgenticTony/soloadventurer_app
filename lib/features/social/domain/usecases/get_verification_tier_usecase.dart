import '../enums/verification_tier.dart';
import '../repositories/privacy_repository.dart';

/// Use case for retrieving the current user's verification tier
class GetVerificationTierUseCase {
  final PrivacyRepository _repository;

  /// Creates a new [GetVerificationTierUseCase]
  const GetVerificationTierUseCase(this._repository);

  /// Execute the use case
  Future<VerificationTier> call() => _repository.getVerificationTier();
}
