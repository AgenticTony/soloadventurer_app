import '../repositories/profile_repository.dart';

/// Use case for managing profile avatars
class ManageAvatarUseCase {
  final ProfileRepository _repository;

  /// Creates a new [ManageAvatarUseCase] with the given repository
  const ManageAvatarUseCase(this._repository);

  /// Upload a new avatar for the user
  Future<String> uploadAvatar(String userId, String filePath) =>
      _repository.uploadAvatar(userId, filePath);

  /// Remove the user's current avatar
  Future<void> removeAvatar(String userId) => _repository.removeAvatar(userId);
}
