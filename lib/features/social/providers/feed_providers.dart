import 'dart:async';

import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../data/datasources/feed_remote_data_source.dart';
import '../data/models/feed_item_model.dart';
import '../data/repositories/feed_repository_impl.dart';
import '../domain/entities/feed_item.dart';
import '../domain/repositories/feed_repository.dart';
import '../domain/usecases/get_feed_usecase.dart';

part 'feed_providers.g.dart';

// ============================================================
// Data Source
// ============================================================

/// Provides the feed remote data source backed by Supabase
@Riverpod(keepAlive: true)
FeedRemoteDataSource feedRemoteDataSource(Ref ref) {
  return FeedRemoteDataSourceImpl(client: Supabase.instance.client);
}

// ============================================================
// Repository
// ============================================================

/// Provides the feed repository implementation
@Riverpod(keepAlive: true)
FeedRepository feedRepository(Ref ref) {
  return FeedRepositoryImpl(
    remoteDataSource: ref.read(feedRemoteDataSourceProvider),
  );
}

// ============================================================
// Use Cases
// ============================================================

/// Provides the get feed use case
@riverpod
GetFeedUseCase getFeedUseCase(Ref ref) =>
    GetFeedUseCase(ref.read(feedRepositoryProvider));

// ============================================================
// Feed AsyncNotifier with Realtime
// ============================================================

/// AsyncNotifier managing the social feed with pagination and realtime updates
///
/// - Initial load fetches 20 items via [get_user_feed] RPC
/// - [loadMore] appends the next page using cursor pagination
/// - [refresh] reloads from scratch
/// - Subscribes to Supabase Realtime on the `feed_items` table and
///   prepends new items as they arrive
@Riverpod(keepAlive: true)
class SocialFeed extends _$SocialFeed {
  RealtimeChannel? _channel;
  StreamSubscription<PostgresChangePayload>? _realtimeSub;

  @override
  Future<List<FeedItem>> build() async {
    // Initial load
    final items = await _fetchPage(limit: 20);

    // Set up realtime subscription
    _subscribeToRealtime();

    // Clean up on dispose
    ref.onDispose(() {
      _realtimeSub?.cancel();
      _channel?.unsubscribe();
    });

    return items;
  }

  /// Load more items, appending after the current list
  Future<void> loadMore() async {
    final currentItems = state.value;
    if (currentItems == null || currentItems.isEmpty) return;

    final before = currentItems.last.createdAt;
    final moreItems = await _fetchPage(limit: 20, before: before);

    if (moreItems.isEmpty) return;

    state = AsyncData([...currentItems, ...moreItems]);
  }

  /// Refresh the feed from scratch
  Future<void> refresh() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() => _fetchPage(limit: 20));
  }

  // ----------------------------------------------------------
  // Private helpers
  // ----------------------------------------------------------

  Future<List<FeedItem>> _fetchPage({
    required int limit,
    DateTime? before,
  }) async {
    final useCase = ref.read(getFeedUseCaseProvider);
    return useCase(limit: limit, before: before);
  }

  void _subscribeToRealtime() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) return;

    _channel = Supabase.instance.client
        .channel('feed:realtime:$userId')
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
            _onNewFeedItem(payload);
          },
        );

    _channel?.subscribe();
  }

  void _onNewFeedItem(PostgresChangePayload payload) {
    final currentItems = state.value;
    if (currentItems == null) return;

    final newRecord = payload.newRecord;
    if (newRecord.isEmpty) return;

    // Map the realtime row to a FeedItem via the model
    final model = FeedItemModel.fromJson(newRecord);
    final newItem = model.toEntity();

    // Avoid duplicates
    if (currentItems.any((item) => item.id == newItem.id)) return;

    // Prepend the new item
    state = AsyncData([newItem, ...currentItems]);
  }
}
