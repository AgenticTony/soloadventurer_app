import '../repositories/follow_repository.dart';

/// Use case for checking if the current user follows a target user
class IsFollowingUseCase {
  final FollowRepository _repository;

  /// Creates a new [IsFollowingUseCase] with the given repository
  const IsFollowingUseCase(this._repository);

  /// Execute the use case to check follow status
  Future<bool> call(String targetId) => _repository.isFollowing(targetId);
}
