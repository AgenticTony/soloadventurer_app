import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

/// Use case for adding a comment to a journal entry
class AddCommentUseCase {
  final CommentRepository _repository;

  const AddCommentUseCase(this._repository);

  /// Execute: adds a comment and returns the created [Comment]
  Future<Comment> call({
    required String journalId,
    required String body,
    String? parentId,
  }) =>
      _repository.addComment(
        journalId: journalId,
        body: body,
        parentId: parentId,
      );
}
