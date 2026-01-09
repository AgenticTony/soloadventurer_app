import 'package:soloadventurer/core/error/exceptions.dart';
import 'package:soloadventurer/features/journal/data/models/journal_entry_model.dart';
import 'package:soloadventurer/features/journal/data/models/media_item_model.dart';

/// Remote data source interface for journal operations
abstract class JournalRemoteDataSource {
  /// Create a new journal entry
  Future<JournalEntryModel> createEntry(JournalEntryModel entry);

  /// Get a journal entry by ID
  Future<JournalEntryModel> getEntry(String entryId);

  /// Get all journal entries for the current user
  Future<List<JournalEntryModel>> getEntries();

  /// Get journal entries for a specific trip
  Future<List<JournalEntryModel>> getEntriesByTrip(String tripId);

  /// Get journal entries for a specific date range
  Future<List<JournalEntryModel>> getEntriesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Search journal entries by text
  Future<List<JournalEntryModel>> searchEntries(String query);

  /// Get favorite entries
  Future<List<JournalEntryModel>> getFavoriteEntries();

  /// Update an existing journal entry
  Future<JournalEntryModel> updateEntry(JournalEntryModel entry);

  /// Delete a journal entry
  Future<void> deleteEntry(String entryId);

  /// Toggle favorite status
  Future<JournalEntryModel> toggleFavorite(String entryId);

  /// Get entries with location data
  Future<List<JournalEntryModel>> getEntriesWithLocation();

  /// Get entries near a specific location
  Future<List<JournalEntryModel>> getEntriesNearLocation(
    double latitude,
    double longitude,
    double radiusKm,
  );

  /// Add media item to an entry
  Future<MediaItemModel> addMedia(MediaItemModel media);

  /// Update media item
  Future<MediaItemModel> updateMedia(MediaItemModel media);

  /// Delete media item
  Future<void> deleteMedia(String mediaId);

  /// Get all media for an entry
  Future<List<MediaItemModel>> getMediaForEntry(String entryId);

  /// Get all media for a trip
  Future<List<MediaItemModel>> getMediaForTrip(String tripId);

  /// Update media upload progress
  Future<MediaItemModel> updateMediaUploadProgress(
    String mediaId,
    int progress,
  );

  /// Mark media upload as completed
  Future<MediaItemModel> completeMediaUpload(
    String mediaId,
    String storagePath,
  );

  /// Mark media upload as failed
  Future<MediaItemModel> failMediaUpload(
    String mediaId,
    String error,
  );

  // Tag-related operations

  /// Get all tags for a specific journal entry
  ///
  /// Throws [ServerException] if retrieval fails
  Future<List<String>> getTagsForEntry(String entryId);

  /// Add a tag to a journal entry
  ///
  /// Throws [ServerException] if operation fails
  Future<void> addTagToEntry(String entryId, String tagId);

  /// Remove a tag from a journal entry
  ///
  /// Throws [ServerException] if operation fails
  Future<void> removeTagFromEntry(String entryId, String tagId);

  /// Update tags for a journal entry (replaces all existing tags)
  ///
  /// Throws [ServerException] if operation fails
  Future<void> updateTagsForEntry(String entryId, List<String> tagIds);
}
