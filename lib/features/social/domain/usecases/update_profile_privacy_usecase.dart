import '../entities/privacy_settings.dart';
import '../repositories/privacy_repository.dart';

/// Use case for updating the current user's profile privacy settings
class UpdateProfilePrivacyUseCase {
  final PrivacyRepository _repository;

  /// Creates a new [UpdateProfilePrivacyUseCase]
  const UpdateProfilePrivacyUseCase(this._repository);

  /// Execute the use case
  Future<void> call(PrivacySettings settings) =>
      _repository.updateProfilePrivacy(settings);
}
