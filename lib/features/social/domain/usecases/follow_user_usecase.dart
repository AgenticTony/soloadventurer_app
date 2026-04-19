import '../repositories/follow_repository.dart';

/// Use case for sending a follow request to another user
class FollowUserUseCase {
  final FollowRepository _repository;

  /// Creates a new [FollowUserUseCase] with the given repository
  const FollowUserUseCase(this._repository);

  /// Execute the use case to follow the target user
  Future<void> call(String targetId) => _repository.followUser(targetId);
}
