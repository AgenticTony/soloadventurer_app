import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/core/utils/json_helpers.dart';
import '../models/feed_item_model.dart';

/// Abstract interface for feed remote data operations
abstract class FeedRemoteDataSource {
  /// Fetch paginated feed items via RPC
  Future<List<FeedItemModel>> getFeed({
    required int limit,
    DateTime? before,
  });

  /// Subscribe to realtime feed updates for the current user
  ///
  /// Returns a [RealtimeChannel] that should be subscribed after setup.
  RealtimeChannel subscribeToFeed(String userId);
}

/// Supabase implementation of [FeedRemoteDataSource]
class FeedRemoteDataSourceImpl implements FeedRemoteDataSource {
  final SupabaseClient _client;

  /// Creates a new [FeedRemoteDataSourceImpl]
  FeedRemoteDataSourceImpl({required SupabaseClient client}) : _client = client;

  @override
  Future<List<FeedItemModel>> getFeed({
    required int limit,
    DateTime? before,
  }) async {
    try {
      final params = <String, dynamic>{
        'p_limit': limit,
        if (before != null) 'p_before': before.toIso8601String(),
      };

      final response = await _client.rpc('get_user_feed', params: params);

      return (response as List)
          .map((json) =>
              FeedItemModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to get feed: ${e.message}',
        statusCode:
            JsonHelpers.parseIntOrDefault(e.code, defaultValue: 500),
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get feed: $e',
        statusCode: 500,
      );
    }
  }

  @override
  RealtimeChannel subscribeToFeed(String userId) {
    return _client
        .channel('feed:user:$userId')
        .onPostgresChanges(
          event: PostgresChangeEvent.insert,
          schema: 'public',
          table: 'feed_items',
          filter: PostgresChangeFilter(
            type: PostgresChangeFilterType.eq,
            column: 'owner_id',
            value: userId,
          ),
          callback: (payload) {
            // Realtime payloads are handled by the provider layer
          },
        );
  }
}
