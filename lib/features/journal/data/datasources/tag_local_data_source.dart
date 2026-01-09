import 'package:soloadventurer/features/journal/data/models/tag_model.dart';

/// Local data source interface for tags using SQLite
abstract class TagLocalDataSource {
  /// Creates a new tag in local storage
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<TagModel> createTag(TagModel tag);

  /// Updates an existing tag in local storage
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<TagModel> updateTag(TagModel tag);

  /// Retrieves a tag by ID from local storage
  ///
  /// Throws [DatabaseException] if the operation fails
  /// Returns null if the tag is not found
  Future<TagModel?> getTag(String tagId);

  /// Retrieves all tags from local storage
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<List<TagModel>> getTags();

  /// Retrieves tags with a specific sync status
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<List<TagModel>> getTagsBySyncStatus(String syncStatus);

  /// Updates the sync status of a tag
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<TagModel> updateSyncStatus(String tagId, String syncStatus);

  /// Deletes a tag from local storage
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<void> deleteTag(String tagId);

  /// Increments the usage count of a tag
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<TagModel> incrementUsageCount(String tagId);

  /// Decrements the usage count of a tag
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<TagModel> decrementUsageCount(String tagId);

  /// Clears all tag data from local storage
  ///
  /// Throws [DatabaseException] if the operation fails
  Future<void> clearAll();
}
