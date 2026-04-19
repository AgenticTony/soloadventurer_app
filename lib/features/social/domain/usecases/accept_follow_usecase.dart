import '../repositories/follow_repository.dart';

/// Use case for accepting a follow request from another user
class AcceptFollowUseCase {
  final FollowRepository _repository;

  /// Creates a new [AcceptFollowUseCase] with the given repository
  const AcceptFollowUseCase(this._repository);

  /// Execute the use case to accept a follow request
  Future<void> call(String followerId) => _repository.acceptFollow(followerId);
}
