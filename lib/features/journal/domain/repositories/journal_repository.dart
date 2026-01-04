import 'package:soloadventurer/features/journal/domain/entities/journal_entry.dart';
import 'package:soloadventurer/features/journal/domain/entities/media_item.dart';

/// Repository interface for journal entry operations
abstract class JournalRepository {
  /// Create a new journal entry
  Future<JournalEntry> createEntry(JournalEntry entry);

  /// Get a journal entry by ID
  Future<JournalEntry> getEntry(String entryId);

  /// Get all journal entries for the current user
  Future<List<JournalEntry>> getEntries();

  /// Get journal entries for a specific trip
  Future<List<JournalEntry>> getEntriesByTrip(String tripId);

  /// Get journal entries for a specific date range
  Future<List<JournalEntry>> getEntriesByDateRange(
    DateTime startDate,
    DateTime endDate,
  );

  /// Search journal entries by text
  Future<List<JournalEntry>> searchEntries(String query);

  /// Get favorite entries
  Future<List<JournalEntry>> getFavoriteEntries();

  /// Update an existing journal entry
  Future<JournalEntry> updateEntry(JournalEntry entry);

  /// Delete a journal entry
  Future<void> deleteEntry(String entryId);

  /// Toggle favorite status
  Future<JournalEntry> toggleFavorite(String entryId);

  /// Get entries with location data
  Future<List<JournalEntry>> getEntriesWithLocation();

  /// Get entries near a specific location
  Future<List<JournalEntry>> getEntriesNearLocation(
    double latitude,
    double longitude,
    double radiusKm,
  );

  // Media-related operations

  /// Add media item to an entry
  Future<MediaItem> addMedia(MediaItem media);

  /// Update media item
  Future<MediaItem> updateMedia(MediaItem media);

  /// Delete media item
  Future<void> deleteMedia(String mediaId);

  /// Get all media for an entry
  Future<List<MediaItem>> getMediaForEntry(String entryId);

  /// Get all media for a trip
  Future<List<MediaItem>> getMediaForTrip(String tripId);

  /// Update media upload progress
  Future<MediaItem> updateMediaUploadProgress(
    String mediaId,
    int progress,
  );

  /// Mark media upload as completed
  Future<MediaItem> completeMediaUpload(
    String mediaId,
    String storagePath,
  );

  /// Mark media upload as failed
  Future<MediaItem> failMediaUpload(
    String mediaId,
    String error,
  );

  // Tag-related operations

  /// Get all tags for a specific journal entry
  ///
  /// Throws [AppException] if retrieval fails
  Future<List<String>> getTagsForEntry(String entryId);

  /// Add a tag to a journal entry
  ///
  /// Throws [AppException] if operation fails
  Future<void> addTagToEntry(String entryId, String tagId);

  /// Remove a tag from a journal entry
  ///
  /// Throws [AppException] if operation fails
  Future<void> removeTagFromEntry(String entryId, String tagId);

  /// Update tags for a journal entry (replaces all existing tags)
  ///
  /// Throws [AppException] if operation fails
  Future<void> updateTagsForEntry(String entryId, List<String> tagIds);
}
