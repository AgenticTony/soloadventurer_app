import '../repositories/profile_repository.dart';

/// Use case for deleting a user's profile
class DeleteProfileUseCase {
  final ProfileRepository _repository;

  /// Creates a new [DeleteProfileUseCase] with the given repository
  const DeleteProfileUseCase(this._repository);

  /// Execute the use case to delete the profile for the given user ID
  Future<void> call(String userId) => _repository.deleteProfile(userId);

  /// Check if a profile exists before attempting deletion
  Future<bool> profileExists(String userId) =>
      _repository.profileExists(userId);
}
