import '../repositories/follow_repository.dart';

/// Use case for declining a follow request from another user
class DeclineFollowUseCase {
  final FollowRepository _repository;

  /// Creates a new [DeclineFollowUseCase] with the given repository
  const DeclineFollowUseCase(this._repository);

  /// Execute the use case to decline a follow request
  Future<void> call(String followerId) =>
      _repository.declineFollow(followerId);
}
