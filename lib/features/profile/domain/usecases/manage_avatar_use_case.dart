import '../repositories/profile_repository.dart';

/// Use case for managing a user's profile avatar
class ManageAvatarUseCase {
  final ProfileRepository _repository;

  /// Creates a new [ManageAvatarUseCase] with the given repository
  const ManageAvatarUseCase(this._repository);

  /// Upload a new avatar for the user
  /// Returns the new avatar URL from the repository operation result
  Future<String> uploadAvatar(String userId, String filePath) async {
    final result = await _repository.uploadAvatar(userId, filePath);
    return result.data;
  }

  /// Remove the user's avatar
  Future<void> removeAvatar(String userId) => _repository.removeAvatar(userId);
}
