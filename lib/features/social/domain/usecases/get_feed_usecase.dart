import '../repositories/feed_repository.dart';
import '../entities/feed_item.dart';

/// Use case for retrieving the paginated feed
class GetFeedUseCase {
  final FeedRepository _repository;

  /// Creates a new [GetFeedUseCase] with the given repository
  const GetFeedUseCase(this._repository);

  /// Execute the use case with pagination parameters
  Future<List<FeedItem>> call({
    int limit = 20,
    DateTime? before,
  }) {
    return _repository.getFeed(limit: limit, before: before);
  }
}
