import '../entities/feed_item.dart';

/// Repository interface for feed-related operations
abstract class FeedRepository {
  /// Get the paginated feed for items for the current user
  ///
  /// [limit] - Maximum number of items to return
  /// [before] - Cursor for pagination; returns items created before this timestamp
  Future<List<FeedItem>> getFeed({int limit = 20, DateTime? before});
}
