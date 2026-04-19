import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/core/utils/json_helpers.dart';
import '../models/comment_model.dart';

/// Abstract interface for comment-related remote data operations
abstract class CommentRemoteDataSource {
  /// Fetch comments for a journal entry, ordered by creation date
  Future<List<CommentModel>> getComments(String journalId);

  /// Insert a new comment and return the created row with author profile join
  Future<CommentModel> addComment({
    required String journalId,
    required String authorId,
    required String body,
    String? parentId,
  });

  /// Soft-delete a comment by setting deleted_at
  Future<void> deleteComment(String commentId);

  /// Get comment count for a journal entry
  Future<int> getCommentCount(String journalId);
}

/// Supabase implementation of [CommentRemoteDataSource]
class CommentRemoteDataSourceImpl implements CommentRemoteDataSource {
  final SupabaseClient _client;

  CommentRemoteDataSourceImpl({required SupabaseClient client}) : _client = client;

  @override
  Future<List<CommentModel>> getComments(String journalId) async {
    try {
      final response = await _client
          .from('comments')
          .select('''
            id, journal_id, author_id, parent_id, body, deleted_at,
            created_at, updated_at,
            profiles!inner(display_name as author_name, avatar_url as author_avatar_url)
          ''')
          .eq('journal_id', journalId)
          .isFilter('deleted_at', null)
          .order('created_at', ascending: true);

      return (response as List)
          .map((json) => CommentModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to get comments: ${e.message}',
        statusCode: JsonHelpers.parseIntOrDefault(e.code, defaultValue: 500),
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get comments: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<CommentModel> addComment({
    required String journalId,
    required String authorId,
    required String body,
    String? parentId,
  }) async {
    try {
      final insertData = <String, dynamic>{
        'journal_id': journalId,
        'author_id': authorId,
        'body': body,
      };
      if (parentId != null) {
        insertData['parent_id'] = parentId;
      }

      final response = await _client
          .from('comments')
          .insert(insertData)
          .select('''
            id, journal_id, author_id, parent_id, body, deleted_at,
            created_at, updated_at,
            profiles!inner(display_name as author_name, avatar_url as author_avatar_url)
          ''')
          .single();
      return CommentModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to add comment: ${e.message}',
        statusCode: JsonHelpers.parseIntOrDefault(e.code, defaultValue: 500),
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to add comment: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> deleteComment(String commentId) async {
    try {
      await _client
          .from('comments')
          .update({'deleted_at': DateTime.now().toUtc().toIso8601String()})
          .eq('id', commentId);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to delete comment: ${e.message}',
        statusCode: JsonHelpers.parseIntOrDefault(e.code, defaultValue: 500),
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to delete comment: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<int> getCommentCount(String journalId) async {
    try {
      final response = await _client
          .from('comments')
          .select('id')
          .eq('journal_id', journalId)
          .isFilter('deleted_at', null);
      return (response as List).length;
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to get comment count: ${e.message}',
        statusCode: JsonHelpers.parseIntOrDefault(e.code, defaultValue: 500),
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get comment count: $e',
        statusCode: 500,
      );
    }
  }
}
