import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/core/error/exceptions.dart';
import 'package:soloadventurer/features/journal/data/datasources/journal_remote_data_source.dart';
import 'package:soloadventurer/features/journal/data/models/journal_entry_model.dart';
import 'package:soloadventurer/features/journal/data/models/media_item_model.dart';

/// Implementation of [JournalRemoteDataSource] using Supabase
class JournalRemoteDataSourceImpl implements JournalRemoteDataSource {
  final SupabaseClient _client;

  JournalRemoteDataSourceImpl({required SupabaseClient client})
      : _client = client;

  @override
  Future<JournalEntryModel> createEntry(JournalEntryModel entry) async {
    try {
      final response = await _client
          .from('journal_entries')
          .insert(entry.toJson())
          .select()
          .single();

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
      final response = await _client
          .from('journal_entries')
          .select()
          .eq('id', entryId)
          .single();

      return JournalEntryModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == '404' || e.code == 'PGRST116') {
        throw const ServerException(
          message: 'Journal entry not found',
          statusCode: 404,
        );
      }
      throw ServerException(
        message: 'Failed to get journal entry: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get journal entry: $e',
        statusCode: 500,
      );
    }
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

      final response = await _client
          .from('journal_entries')
          .select()
          .eq('user_id', userId)
          .order('entry_date', ascending: false);

      return (response as List)
          .map((json) => JournalEntryModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to get journal entries: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get journal entries: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<JournalEntryModel>> getEntriesByTrip(String tripId) async {
    try {
      final response = await _client
          .from('journal_entries')
          .select()
          .eq('trip_id', tripId)
          .order('entry_date', ascending: false);

      return (response as List)
          .map((json) => JournalEntryModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to get entries for trip: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get entries for trip: $e',
        statusCode: 500,
      );
    }
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

      final response = await _client
          .from('journal_entries')
          .select()
          .eq('user_id', userId)
          .gte('entry_date', startDate.toIso8601String())
          .lte('entry_date', endDate.toIso8601String())
          .order('entry_date', ascending: false);

      return (response as List)
          .map((json) => JournalEntryModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to get entries by date range: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get entries by date range: $e',
        statusCode: 500,
      );
    }
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

      final response = await _client
          .from('journal_entries')
          .select()
          .eq('user_id', userId)
          .textSearch('title', query)
          .order('entry_date', ascending: false);

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

      final response = await _client
          .from('journal_entries')
          .select()
          .eq('user_id', userId)
          .eq('is_favorite', true)
          .order('entry_date', ascending: false);

      return (response as List)
          .map((json) => JournalEntryModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to get favorite entries: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get favorite entries: $e',
        statusCode: 500,
      );
    }
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

      final response = await _client
          .from('journal_entries')
          .select()
          .eq('user_id', userId)
          .not('latitude', 'is', null)
          .not('longitude', 'is', null)
          .order('entry_date', ascending: false);

      return (response as List)
          .map((json) => JournalEntryModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to get entries with location: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get entries with location: $e',
        statusCode: 500,
      );
    }
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
      final response = await _client
          .from('media_items')
          .select()
          .eq('journal_entry_id', entryId)
          .order('order_index', ascending: true);

      return (response as List)
          .map((json) => MediaItemModel.fromJson(json))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to get media for entry: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get media for entry: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<MediaItemModel>> getMediaForTrip(String tripId) async {
    try {
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
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to get media for trip: ${e.message}',
        statusCode: e.code ?? 500,
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get media for trip: $e',
        statusCode: 500,
      );
    }
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
}
