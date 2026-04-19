import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import '../../domain/entities/comment.dart';
import '../../domain/repositories/comment_repository.dart';
import '../datasources/comment_remote_data_source.dart';

/// Implementation of [CommentRepository] using Supabase
class CommentRepositoryImpl implements CommentRepository {
  final CommentRemoteDataSource _remoteDataSource;

  CommentRepositoryImpl({required CommentRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  String _requireCurrentUserId() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      throw const UnauthorizedException(
        message: 'User must be authenticated to comment',
      );
    }
    return userId;
  }

  @override
  Future<List<Comment>> getComments(String journalId) async {
    final models = await _remoteDataSource.getComments(journalId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<Comment> addComment({
    required String journalId,
    required String body,
    String? parentId,
  }) async {
    final userId = _requireCurrentUserId();
    final model = await _remoteDataSource.addComment(
      journalId: journalId,
      authorId: userId,
      body: body,
      parentId: parentId,
    );
    return model.toEntity();
  }

  @override
  Future<void> deleteComment(String commentId) async {
    _requireCurrentUserId();
    await _remoteDataSource.deleteComment(commentId);
  }

  @override
  Future<int> getCommentCount(String journalId) =>
      _remoteDataSource.getCommentCount(journalId);
}
