import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/core/error/exceptions.dart';
import 'package:soloadventurer/features/journal/data/datasources/journal_remote_data_source.dart';
import 'package:soloadventurer/features/journal/data/models/journal_entry_model.dart';
import 'package:soloadventurer/features/journal/data/models/media_item_model.dart';
import 'package:soloadventurer/utils/performance/query_optimizer.dart';

/// Optimized implementation of [JournalRemoteDataSource] with field selection and caching
class JournalRemoteDataSourceOptimized implements JournalRemoteDataSource {
  final SupabaseClient _client;
  final QueryOptimizer _queryOptimizer;

  JournalRemoteDataSourceOptimized({
    required SupabaseClient client,
    QueryOptimizer? queryOptimizer,
  })  : _client = client,
        _queryOptimizer = queryOptimizer ?? QueryOptimizer();

  @override
  Future<JournalEntryModel> createEntry(JournalEntryModel entry) async {
    try {
      final response = await _client
          .from('journal_entries')
          .insert(entry.toJson())
          .select()
          .single();

      // Invalidate cache for this user's entries
      _invalidateEntriesCache();

      return JournalEntryModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to create journal entry: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to create journal entry: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<JournalEntryModel> getEntry(String entryId) async {
    try {
      final cacheKey = 'journal_entry_$entryId';

      final result = await _queryOptimizer.execute<JournalEntryModel>(
        cacheKey,
        () => _fetchEntry(entryId),
        ttl: const Duration(minutes: 10),
        fields: QueryFields.forDetail,
      );

      if (result.isError) {
        throw ServerException(
          message: result.error ?? 'Unknown error',
          statusCode: 500,
        );
      }

      return result.data!;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Failed to get journal entry: $e',
        statusCode: 500,
      );
    }
  }

  /// Fetch single entry from database
  Future<JournalEntryModel> _fetchEntry(String entryId) async {
    final response = await _client
        .from('journal_entries')
        .select(QueryFields.forDetail.toSelectString())
        .eq('id', entryId)
        .single();

    return JournalEntryModel.fromJson(response);
  }

  @override
  Future<List<JournalEntryModel>> getEntries() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const ServerException(
          message: 'User not authenticated',
          statusCode: 401,
        );
      }

      final cacheKey = 'journal_entries_user_$userId';

      final result = await _queryOptimizer.execute<List<JournalEntryModel>>(
        cacheKey,
        () => _fetchUserEntries(userId),
        ttl: const Duration(minutes: 2),
        fields: QueryFields.forList,
      );

      if (result.isError) {
        throw ServerException(
          message: result.error ?? 'Unknown error',
          statusCode: 500,
        );
      }

      return result.data!;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Failed to get journal entries: $e',
        statusCode: 500,
      );
    }
  }

  /// Fetch user entries with field selection
  Future<List<JournalEntryModel>> _fetchUserEntries(String userId) async {
    final response = await _client
        .from('journal_entries')
        .select(QueryFields.forList.toSelectString())
        .eq('user_id', userId)
        .order('entry_date', ascending: false);

    return (response as List)
        .map((json) => JournalEntryModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<JournalEntryModel>> getEntriesByTrip(String tripId) async {
    try {
      final cacheKey = 'journal_entries_trip_$tripId';

      final result = await _queryOptimizer.execute<List<JournalEntryModel>>(
        cacheKey,
        () => _fetchTripEntries(tripId),
        ttl: const Duration(minutes: 5),
        fields: QueryFields.forList,
      );

      if (result.isError) {
        throw ServerException(
          message: result.error ?? 'Unknown error',
          statusCode: 500,
        );
      }

      return result.data!;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Failed to get entries for trip: $e',
        statusCode: 500,
      );
    }
  }

  /// Fetch trip entries
  Future<List<JournalEntryModel>> _fetchTripEntries(String tripId) async {
    final response = await _client
        .from('journal_entries')
        .select(QueryFields.forList.toSelectString())
        .eq('trip_id', tripId)
        .order('entry_date', ascending: false);

    return (response as List)
        .map((json) => JournalEntryModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<JournalEntryModel>> getEntriesByDateRange(
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const ServerException(
          message: 'User not authenticated',
          statusCode: 401,
        );
      }

      final cacheKey = 'journal_entries_date_${startDate.toIso8601String()}_${endDate.toIso8601String()}';

      final result = await _queryOptimizer.execute<List<JournalEntryModel>>(
        cacheKey,
        () => _fetchDateRangeEntries(userId, startDate, endDate),
        ttl: const Duration(minutes: 3),
        fields: QueryFields.forList,
      );

      if (result.isError) {
        throw ServerException(
          message: result.error ?? 'Unknown error',
          statusCode: 500,
        );
      }

      return result.data!;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Failed to get entries by date range: $e',
        statusCode: 500,
      );
    }
  }

  /// Fetch entries by date range
  Future<List<JournalEntryModel>> _fetchDateRangeEntries(
    String userId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    final response = await _client
        .from('journal_entries')
        .select(QueryFields.forList.toSelectString())
        .eq('user_id', userId)
        .gte('entry_date', startDate.toIso8601String())
        .lte('entry_date', endDate.toIso8601String())
        .order('entry_date', ascending: false);

    return (response as List)
        .map((json) => JournalEntryModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<JournalEntryModel>> searchEntries(String query) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const ServerException(
          message: 'User not authenticated',
          statusCode: 401,
        );
      }

      // Don't cache search results as they vary frequently
      final response = await _client
          .from('journal_entries')
          .select(QueryFields.forCard.toSelectString())
          .eq('user_id', userId)
          .textSearch('title', query)
          .order('entry_date', ascending: false)
          .limit(50); // Limit search results

      return (response as List)
          .map((json) => JournalEntryModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to search entries: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to search entries: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<JournalEntryModel>> getFavoriteEntries() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const ServerException(
          message: 'User not authenticated',
          statusCode: 401,
        );
      }

      final cacheKey = 'journal_entries_favorites_$userId';

      final result = await _queryOptimizer.execute<List<JournalEntryModel>>(
        cacheKey,
        () => _fetchFavoriteEntries(userId),
        ttl: const Duration(minutes: 5),
        fields: QueryFields.forCard,
      );

      if (result.isError) {
        throw ServerException(
          message: result.error ?? 'Unknown error',
          statusCode: 500,
        );
      }

      return result.data!;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Failed to get favorite entries: $e',
        statusCode: 500,
      );
    }
  }

  /// Fetch favorite entries
  Future<List<JournalEntryModel>> _fetchFavoriteEntries(String userId) async {
    final response = await _client
        .from('journal_entries')
        .select(QueryFields.forCard.toSelectString())
        .eq('user_id', userId)
        .eq('is_favorite', true)
        .order('entry_date', ascending: false);

    return (response as List)
        .map((json) => JournalEntryModel.fromJson(json))
        .toList();
  }

  @override
  Future<JournalEntryModel> updateEntry(JournalEntryModel entry) async {
    try {
      final response = await _client
          .from('journal_entries')
          .update(entry.toJson())
          .eq('id', entry.id)
          .select()
          .single();

      // Invalidate relevant caches
      _invalidateEntryCaches(entry.id);

      return JournalEntryModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to update journal entry: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to update journal entry: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> deleteEntry(String entryId) async {
    try {
      await _client.from('journal_entries').delete().eq('id', entryId);

      // Invalidate relevant caches
      _invalidateEntryCaches(entryId);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to delete journal entry: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to delete journal entry: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<JournalEntryModel> toggleFavorite(String entryId) async {
    try {
      // First get the current entry
      final currentEntry = await getEntry(entryId);

      // Toggle the favorite status
      final updatedEntry = currentEntry.copyWith(
        isFavorite: !currentEntry.isFavorite,
      );

      // Update the entry
      return await updateEntry(updatedEntry);
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Failed to toggle favorite: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<JournalEntryModel>> getEntriesWithLocation() async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const ServerException(
          message: 'User not authenticated',
          statusCode: 401,
        );
      }

      final cacheKey = 'journal_entries_location_$userId';

      final result = await _queryOptimizer.execute<List<JournalEntryModel>>(
        cacheKey,
        () => _fetchEntriesWithLocation(userId),
        ttl: const Duration(minutes: 5),
        fields: QueryFields.forCard,
      );

      if (result.isError) {
        throw ServerException(
          message: result.error ?? 'Unknown error',
          statusCode: 500,
        );
      }

      return result.data!;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Failed to get entries with location: $e',
        statusCode: 500,
      );
    }
  }

  /// Fetch entries with location data
  Future<List<JournalEntryModel>> _fetchEntriesWithLocation(String userId) async {
    final response = await _client
        .from('journal_entries')
        .select(QueryFields.forCard.toSelectString())
        .eq('user_id', userId)
        .not('latitude', 'is', null)
        .not('longitude', 'is', null)
        .order('entry_date', ascending: false);

    return (response as List)
        .map((json) => JournalEntryModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<JournalEntryModel>> getEntriesNearLocation(
    double latitude,
    double longitude,
    double radiusKm,
  ) async {
    try {
      final userId = _client.auth.currentUser?.id;
      if (userId == null) {
        throw const ServerException(
          message: 'User not authenticated',
          statusCode: 401,
        );
      }

      // Don't cache location-based queries as they're highly dynamic
      final response = await _client.rpc(
        'get_entries_near_location',
        params: {
          'user_id': userId,
          'lat': latitude,
          'lng': longitude,
          'radius_km': radiusKm,
        },
      );

      return (response as List)
          .map((json) => JournalEntryModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to get entries near location: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get entries near location: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<MediaItemModel> addMedia(MediaItemModel media) async {
    try {
      final response = await _client
          .from('media_items')
          .insert(media.toJson())
          .select()
          .single();

      return MediaItemModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to add media: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to add media: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<MediaItemModel> updateMedia(MediaItemModel media) async {
    try {
      final response = await _client
          .from('media_items')
          .update(media.toJson())
          .eq('id', media.id)
          .select()
          .single();

      return MediaItemModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to update media: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to update media: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> deleteMedia(String mediaId) async {
    try {
      await _client.from('media_items').delete().eq('id', mediaId);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to delete media: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to delete media: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<MediaItemModel>> getMediaForEntry(String entryId) async {
    try {
      final cacheKey = 'media_entry_$entryId';

      final result = await _queryOptimizer.execute<List<MediaItemModel>>(
        cacheKey,
        () => _fetchEntryMedia(entryId),
        ttl: const Duration(minutes: 10),
      );

      if (result.isError) {
        throw ServerException(
          message: result.error ?? 'Unknown error',
          statusCode: 500,
        );
      }

      return result.data!;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Failed to get media for entry: $e',
        statusCode: 500,
      );
    }
  }

  /// Fetch media for entry
  Future<List<MediaItemModel>> _fetchEntryMedia(String entryId) async {
    final response = await _client
        .from('media_items')
        .select()
        .eq('journal_entry_id', entryId)
        .order('order_index', ascending: true);

    return (response as List)
        .map((json) => MediaItemModel.fromJson(json))
        .toList();
  }

  @override
  Future<List<MediaItemModel>> getMediaForTrip(String tripId) async {
    try {
      final cacheKey = 'media_trip_$tripId';

      final result = await _queryOptimizer.execute<List<MediaItemModel>>(
        cacheKey,
        () => _fetchTripMedia(tripId),
        ttl: const Duration(minutes: 5),
      );

      if (result.isError) {
        throw ServerException(
          message: result.error ?? 'Unknown error',
          statusCode: 500,
        );
      }

      return result.data!;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Failed to get media for trip: $e',
        statusCode: 500,
      );
    }
  }

  /// Fetch media for trip
  Future<List<MediaItemModel>> _fetchTripMedia(String tripId) async {
    // Get all entry IDs for the trip first
    final entriesResponse = await _client
        .from('journal_entries')
        .select('id')
        .eq('trip_id', tripId);

    final entryIds = (entriesResponse as List).map((e) => e['id'] as String).toList();

    if (entryIds.isEmpty) {
      return [];
    }

    // Get all media for those entries
    final response = await _client
        .from('media_items')
        .select()
        .in_('journal_entry_id', entryIds)
        .order('created_at', ascending: false);

    return (response as List)
        .map((json) => MediaItemModel.fromJson(json))
        .toList();
  }

  @override
  Future<MediaItemModel> updateMediaUploadProgress(
    String mediaId,
    int progress,
  ) async {
    try {
      final response = await _client
          .from('media_items')
          .update({
            'upload_progress': progress,
            'upload_status': progress >= 100 ? 'completed' : 'uploading',
          })
          .eq('id', mediaId)
          .select()
          .single();

      return MediaItemModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to update upload progress: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to update upload progress: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<MediaItemModel> completeMediaUpload(
    String mediaId,
    String storagePath,
  ) async {
    try {
      final response = await _client
          .from('media_items')
          .update({
            'storage_path': storagePath,
            'upload_status': 'completed',
            'upload_progress': 100,
            'sync_status': 'synced',
          })
          .eq('id', mediaId)
          .select()
          .single();

      return MediaItemModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to complete upload: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to complete upload: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<MediaItemModel> failMediaUpload(
    String mediaId,
    String error,
  ) async {
    try {
      final response = await _client
          .from('media_items')
          .update({
            'upload_status': 'failed',
            'sync_status': 'pending',
          })
          .eq('id', mediaId)
          .select()
          .single();

      return MediaItemModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to mark upload as failed: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to mark upload as failed: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<String>> getTagsForEntry(String entryId) async {
    try {
      final cacheKey = 'tags_entry_$entryId';

      final result = await _queryOptimizer.execute<List<String>>(
        cacheKey,
        () => _fetchEntryTags(entryId),
        ttl: const Duration(minutes: 10),
      );

      if (result.isError) {
        throw ServerException(
          message: result.error ?? 'Unknown error',
          statusCode: 500,
        );
      }

      return result.data!;
    } on ServerException {
      rethrow;
    } catch (e) {
      throw ServerException(
        message: 'Failed to get tags for entry: $e',
        statusCode: 500,
      );
    }
  }

  /// Fetch tags for entry
  Future<List<String>> _fetchEntryTags(String entryId) async {
    final response = await _client
        .from('journal_tags')
        .select('tag_id')
        .eq('journal_entry_id', entryId);

    return (response as List).map((e) => e['tag_id'] as String).toList();
  }

  @override
  Future<void> addTagToEntry(String entryId, String tagId) async {
    try {
      await _client.from('journal_tags').insert({
        'journal_entry_id': entryId,
        'tag_id': tagId,
      });

      // Invalidate tags cache for this entry
      _queryOptimizer.invalidate('tags_entry_$entryId');
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to add tag to entry: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to add tag to entry: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> removeTagFromEntry(String entryId, String tagId) async {
    try {
      await _client
          .from('journal_tags')
          .delete()
          .eq('journal_entry_id', entryId)
          .eq('tag_id', tagId);

      // Invalidate tags cache for this entry
      _queryOptimizer.invalidate('tags_entry_$entryId');
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to remove tag from entry: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to remove tag from entry: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> updateTagsForEntry(String entryId, List<String> tagIds) async {
    try {
      // Delete all existing tags for the entry
      await _client
          .from('journal_tags')
          .delete()
          .eq('journal_entry_id', entryId);

      // Add new tags
      if (tagIds.isNotEmpty) {
        final inserts = tagIds.map((tagId) => {
          'journal_entry_id': entryId,
          'tag_id': tagId,
        }).toList();

        await _client.from('journal_tags').insert(inserts);
      }

      // Invalidate tags cache for this entry
      _queryOptimizer.invalidate('tags_entry_$entryId');
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to update tags for entry: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to update tags for entry: $e',
        statusCode: 500,
      );
    }
  }

  /// Invalidate all entries cache
  void _invalidateEntriesCache() {
    final userId = _client.auth.currentUser?.id;
    if (userId != null) {
      _queryOptimizer.invalidate('journal_entries_user_$userId');
    }
  }

  /// Invalidate caches related to a specific entry
  void _invalidateEntryCaches(String entryId) {
    _queryOptimizer.invalidateMultiple([
      'journal_entry_$entryId',
      'media_entry_$entryId',
      'tags_entry_$entryId',
    ]);
    _invalidateEntriesCache();
  }
}
