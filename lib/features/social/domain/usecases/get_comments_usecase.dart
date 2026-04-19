import '../entities/comment.dart';
import '../repositories/comment_repository.dart';

/// Use case for fetching comments for a journal entry
class GetCommentsUseCase {
  final CommentRepository _repository;

  const GetCommentsUseCase(this._repository);

  /// Execute: returns list of comments for the given journal
  Future<List<Comment>> call(String journalId) =>
      _repository.getComments(journalId);
}
