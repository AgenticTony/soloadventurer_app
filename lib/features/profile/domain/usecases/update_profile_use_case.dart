import '../entities/profile.dart';
import '../repositories/profile_repository.dart';

/// Use case for updating a user's profile
class UpdateProfileUseCase {
  final ProfileRepository _repository;

  /// Creates a new [UpdateProfileUseCase] with the given repository
  const UpdateProfileUseCase(this._repository);

  /// Execute the use case with the given profile data
  /// Returns the updated profile from the repository operation result
  Future<Profile> call(Profile profile) async {
    final result = await _repository.updateProfile(profile);
    return result.data;
  }

  /// Update specific profile fields
  /// Returns the updated profile from the repository operation result
  Future<Profile> updateFields(
      String userId, Map<String, dynamic> fields) async {
    final result = await _repository.updateProfileFields(userId, fields);
    return result.data;
  }

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
