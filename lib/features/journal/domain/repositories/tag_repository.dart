import 'package:soloadventurer/core/failures/failures.dart';
import 'package:soloadventurer/features/journal/domain/entities/tag.dart';
import 'package:fpdart/fpdart.dart';

/// Repository interface for tag operations
abstract class TagRepository {
  /// Creates a new tag
  ///
  /// Returns the created tag with server-generated ID
  /// Throws [AppException] if creation fails
  Future<Either<Failure, Tag>> createTag(Tag tag);

  /// Gets a tag by ID
  ///
  /// Throws [AppException] if tag not found or retrieval fails
  Future<Either<Failure, Tag>> getTag(String tagId);

  /// Gets all tags for the current user
  ///
  /// Throws [AppException] if retrieval fails
  Future<Either<Failure, List<Tag>>> getTags();

  /// Gets tags for a specific journal entry
  ///
  /// Throws [AppException] if retrieval fails
  Future<Either<Failure, List<Tag>>> getTagsForEntry(String entryId);

  /// Updates an existing tag
  ///
  /// Returns the updated tag
  /// Throws [AppException] if update fails
  Future<Either<Failure, Tag>> updateTag(Tag tag);

  /// Deletes a tag
  ///
  /// Throws [AppException] if deletion fails
  Future<Either<Failure, void>> deleteTag(String tagId);

  /// Adds a tag to a journal entry
  ///
  /// Throws [AppException] if operation fails
  Future<Either<Failure, void>> addTagToEntry(String entryId, String tagId);

  /// Removes a tag from a journal entry
  ///
  /// Throws [AppException] if operation fails
  Future<Either<Failure, void>> removeTagFromEntry(
    String entryId,
    String tagId,
  );

  /// Updates tags for a journal entry (replaces all existing tags)
  ///
  /// Throws [AppException] if operation fails
  Future<Either<Failure, void>> updateTagsForEntry(
    String entryId,
    List<String> tagIds,
  );

  /// Gets popular tags (sorted by usage count)
  ///
  /// Throws [AppException] if retrieval fails
  Future<Either<Failure, List<Tag>>> getPopularTags({int limit});

  /// Searches tags by name
  ///
  /// Throws [AppException] if retrieval fails
  Future<Either<Failure, List<Tag>>> searchTags(String query);
}
