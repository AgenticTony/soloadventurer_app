import '../entities/content_privacy_settings.dart';
import '../repositories/privacy_repository.dart';

/// Use case for retrieving the current user's content privacy settings
class GetContentPrivacyUseCase {
  final PrivacyRepository _repository;

  /// Creates a new [GetContentPrivacyUseCase]
  const GetContentPrivacyUseCase(this._repository);

  /// Execute the use case
  Future<ContentPrivacySettings> call() => _repository.getContentPrivacy();
}
