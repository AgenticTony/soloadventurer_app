import '../entities/comment.dart';

/// Repository interface for comment-related operations
abstract class CommentRepository {
  /// Get comments for a journal entry, ordered by creation date
  Future<List<Comment>> getComments(String journalId);

  /// Add a comment to a journal entry
  Future<Comment> addComment({
    required String journalId,
    required String body,
    String? parentId,
  });

  /// Soft delete a comment
  Future<void> deleteComment(String commentId);

  /// Get comment count for a journal entry
  Future<int> getCommentCount(String journalId);
}
