import '../entities/follow.dart';
import '../repositories/follow_repository.dart';

/// Use case for retrieving pending follow requests for the current user
class GetPendingRequestsUseCase {
  final FollowRepository _repository;

  /// Creates a new [GetPendingRequestsUseCase] with the given repository
  const GetPendingRequestsUseCase(this._repository);

  /// Execute the use case to get pending follow requests
  Future<List<Follow>> call() => _repository.getPendingRequests();
}
