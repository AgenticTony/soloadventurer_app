import 'package:soloadventurer/features/journal/data/models/journal_entry_model.dart';
import 'package:soloadventurer/features/journal/data/models/media_item_model.dart';

/// Local data source interface for journal entries using SQLite
abstract class JournalLocalDataSource {
  /// Creates a new journal entry in local storage
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<JournalEntryModel> createEntry(JournalEntryModel entry);

  /// Updates an existing journal entry in local storage
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<JournalEntryModel> updateEntry(JournalEntryModel entry);

  /// Retrieves a journal entry by ID from local storage
  ///
  /// Throws [DatabaseException] if the operation fails
  /// Returns null if the entry is not found
  Future<JournalEntryModel?> getEntry(String entryId);

  /// Retrieves all journal entries from local storage
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<List<JournalEntryModel>> getEntries();

  /// Retrieves journal entries for a specific trip
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<List<JournalEntryModel>> getEntriesByTrip(String tripId);

  /// Retrieves journal entries within a date range
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<List<JournalEntryModel>> getEntriesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Searches journal entries by text content
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<List<JournalEntryModel>> searchEntries(String query);

  /// Retrieves all favorite journal entries
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<List<JournalEntryModel>> getFavoriteEntries();

  /// Retrieves journal entries that have location data
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<List<JournalEntryModel>> getEntriesWithLocation();

  /// Retrieves journal entries near a specific location
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<List<JournalEntryModel>> getEntriesNearLocation(
    double latitude,
    double longitude,
    double radiusKm,
  );

  /// Deletes a journal entry from local storage
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<void> deleteEntry(String entryId);

  /// Toggles the favorite status of a journal entry
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<JournalEntryModel> toggleFavorite(String entryId);

  /// Retrieves entries with a specific sync status
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<List<JournalEntryModel>> getEntriesBySyncStatus(String syncStatus);

  /// Updates the sync status of a journal entry
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<JournalEntryModel> updateSyncStatus(
    String entryId,
    String syncStatus,
  );

  // Media-related operations

  /// Adds a media item to local storage
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<MediaItemModel> addMedia(MediaItemModel media);

  /// Updates a media item in local storage
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<MediaItemModel> updateMedia(MediaItemModel media);

  /// Retrieves media items for a specific journal entry
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<List<MediaItemModel>> getMediaForEntry(String entryId);

  /// Deletes a media item from local storage
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<void> deleteMedia(String mediaId);

  /// Updates media upload progress
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<MediaItemModel> updateMediaUploadProgress(
    String mediaId,
    int progress,
  );

  /// Marks media upload as complete
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<MediaItemModel> completeMediaUpload(
    String mediaId,
    String storagePath,
  );

  /// Marks media upload as failed
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<MediaItemModel> failMediaUpload(
    String mediaId,
    String error,
  );

  /// Retrieves all media items with a specific sync status
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<List<MediaItemModel>> getMediaBySyncStatus(String syncStatus);

  /// Updates the sync status of a media item
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<MediaItemModel> updateMediaSyncStatus(
    String mediaId,
    String syncStatus,
  );

  // Tag-related operations

  /// Retrieves tag IDs for a specific journal entry
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<List<String>> getTagsForEntry(String entryId);

  /// Adds a tag to a journal entry
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<void> addTagToEntry(String entryId, String tagId);

  /// Removes a tag from a journal entry
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<void> removeTagFromEntry(String entryId, String tagId);

  /// Updates all tags for a journal entry
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<void> updateTagsForEntry(String entryId, List<String> tagIds);

  /// Clears all data from local storage
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<void> clearAll();
}
