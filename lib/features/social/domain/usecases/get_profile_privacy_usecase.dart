import '../entities/privacy_settings.dart';
import '../repositories/privacy_repository.dart';

/// Use case for retrieving the current user's profile privacy settings
class GetProfilePrivacyUseCase {
  final PrivacyRepository _repository;

  /// Creates a new [GetProfilePrivacyUseCase]
  const GetProfilePrivacyUseCase(this._repository);

  /// Execute the use case
  Future<PrivacySettings> call() => _repository.getProfilePrivacy();
}
