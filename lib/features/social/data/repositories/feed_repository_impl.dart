import '../../domain/entities/feed_item.dart';
import '../../domain/repositories/feed_repository.dart';
import '../datasources/feed_remote_data_source.dart';

/// Implementation of [FeedRepository] using remote data source
class FeedRepositoryImpl implements FeedRepository {
  final FeedRemoteDataSource _remoteDataSource;

  /// Creates a new [FeedRepositoryImpl]
  FeedRepositoryImpl({required FeedRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  @override
  Future<List<FeedItem>> getFeed({
    int limit = 20,
    DateTime? before,
  }) async {
    final models = await _remoteDataSource.getFeed(
      limit: limit,
      before: before,
    );
    return models.map((model) => model.toEntity()).toList();
  }
}
