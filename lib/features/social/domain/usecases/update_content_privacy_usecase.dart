import '../entities/content_privacy_settings.dart';
import '../repositories/privacy_repository.dart';

/// Use case for updating the current user's content privacy settings
class UpdateContentPrivacyUseCase {
  final PrivacyRepository _repository;

  /// Creates a new [UpdateContentPrivacyUseCase]
  const UpdateContentPrivacyUseCase(this._repository);

  /// Execute the use case
  Future<void> call(ContentPrivacySettings settings) =>
      _repository.updateContentPrivacy(settings);
}
