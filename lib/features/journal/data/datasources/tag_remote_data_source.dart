import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/journal/data/models/tag_model.dart';

/// Remote data source interface for tag operations
abstract class TagRemoteDataSource {
  /// Creates a new tag
  ///
  /// Throws [ServerException] if creation fails
  Future<TagModel> createTag(TagModel tag);

  /// Gets a tag by ID
  ///
  /// Throws [ServerException] if tag not found or retrieval fails
  Future<TagModel> getTag(String tagId);

  /// Gets all tags for the current user
  ///
  /// Throws [ServerException] if retrieval fails
  Future<List<TagModel>> getTags();

  /// Gets tags for a specific journal entry
  ///
  /// Throws [ServerException] if retrieval fails
  Future<List<TagModel>> getTagsForEntry(String entryId);

  /// Updates an existing tag
  ///
  /// Throws [ServerException] if update fails
  Future<TagModel> updateTag(TagModel tag);

  /// Deletes a tag
  ///
  /// Throws [ServerException] if deletion fails
  Future<void> deleteTag(String tagId);

  /// Adds a tag to a journal entry
  ///
  /// Throws [ServerException] if operation fails
  Future<void> addTagToEntry(String entryId, String tagId);

  /// Removes a tag from a journal entry
  ///
  /// Throws [ServerException] if operation fails
  Future<void> removeTagFromEntry(String entryId, String tagId);

  /// Updates tags for a journal entry (replaces all existing tags)
  ///
  /// Throws [ServerException] if operation fails
  Future<void> updateTagsForEntry(String entryId, List<String> tagIds);

  /// Gets popular tags (sorted by usage count)
  ///
  /// Throws [ServerException] if retrieval fails
  Future<List<TagModel>> getPopularTags({int limit = 20});

  /// Searches tags by name
  ///
  /// Throws [ServerException] if retrieval fails
  Future<List<TagModel>> searchTags(String query);
}
