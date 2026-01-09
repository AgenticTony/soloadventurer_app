import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

/// Use case for creating a user's profile
class CreateProfileUseCase {
  final ProfileRepository _repository;

  /// Creates a new [CreateProfileUseCase] with the given repository
  const CreateProfileUseCase(this._repository);

  /// Execute the use case with the given profile data
  /// Returns the created profile from the repository operation result
  Future<Profile> call(Profile profile) async {
    final result = await _repository.createProfile(profile);
    return result.data;
  }
}
