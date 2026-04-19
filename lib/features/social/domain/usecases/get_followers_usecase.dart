import '../entities/follow.dart';
import '../repositories/follow_repository.dart';

/// Use case for retrieving a user's followers
class GetFollowersUseCase {
  final FollowRepository _repository;

  /// Creates a new [GetFollowersUseCase] with the given repository
  const GetFollowersUseCase(this._repository);

  /// Execute the use case to get followers of a user
  Future<List<Follow>> call(String userId) => _repository.getFollowers(userId);
}
