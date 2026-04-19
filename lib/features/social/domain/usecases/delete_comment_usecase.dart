import '../repositories/comment_repository.dart';

/// Use case for soft-deleting a comment
class DeleteCommentUseCase {
  final CommentRepository _repository;

  const DeleteCommentUseCase(this._repository);

  /// Execute: soft-deletes the comment with the given ID
  Future<void> call(String commentId) =>
      _repository.deleteComment(commentId);
}
