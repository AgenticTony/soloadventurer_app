import '../entities/follow.dart';
import '../repositories/follow_repository.dart';

/// Use case for retrieving users that a given user is following
class GetFollowingUseCase {
  final FollowRepository _repository;

  /// Creates a new [GetFollowingUseCase] with the given repository
  const GetFollowingUseCase(this._repository);

  /// Execute the use case to get users being followed
  Future<List<Follow>> call(String userId) => _repository.getFollowing(userId);
}
