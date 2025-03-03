import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

/// Use case for updating a user's profile
class UpdateProfileUseCase {
  final ProfileRepository _repository;

  /// Creates a new [UpdateProfileUseCase] with the given repository
  const UpdateProfileUseCase(this._repository);

  /// Execute the use case with the given profile data
  Future<Profile> call(Profile profile) => _repository.updateProfile(profile);

  /// Update specific fields of the profile
  Future<Profile> updateFields(String userId, Map<String, dynamic> fields) =>
      _repository.updateProfileFields(userId, fields);

  /// Update profile preferences
  Future<void> updatePreferences(
          String userId, Map<String, dynamic> preferences) =>
      _repository.updatePreferences(userId, preferences);

  /// Update profile interests
  Future<void> updateInterests(String userId, List<String> interests) =>
      _repository.updateInterests(userId, interests);

  /// Toggle profile visibility
  Future<void> toggleVisibility(String userId, bool isPublic) =>
      _repository.toggleProfileVisibility(userId, isPublic);
}
