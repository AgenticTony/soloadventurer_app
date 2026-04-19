import '../repositories/follow_repository.dart';

/// Use case for unfollowing another user
class UnfollowUserUseCase {
  final FollowRepository _repository;

  /// Creates a new [UnfollowUserUseCase] with the given repository
  const UnfollowUserUseCase(this._repository);

  /// Execute the use case to unfollow the target user
  Future<void> call(String targetId) => _repository.unfollowUser(targetId);
}
