import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/core/utils/json_helpers.dart';
import '../../domain/entities/reaction.dart';
import '../models/reaction_model.dart';

/// Abstract interface for reaction-related remote data operations
abstract class ReactionRemoteDataSource {
  /// Get all reactions for a target
  Future<List<ReactionModel>> getReactions(
    String targetId,
    ReactionTargetType targetType,
  );

  /// Add a reaction
  Future<ReactionModel> addReaction({
    required String userId,
    required String targetId,
    required ReactionTargetType targetType,
    required ReactionType reaction,
  });

  /// Remove a reaction
  Future<void> removeReaction({
    required String userId,
    required String targetId,
    required ReactionTargetType targetType,
  });

  /// Check if user has reacted
  Future<ReactionModel?> getUserReaction({
    required String userId,
    required String targetId,
    required ReactionTargetType targetType,
  });
}

/// Supabase implementation of [ReactionRemoteDataSource]
class ReactionRemoteDataSourceImpl implements ReactionRemoteDataSource {
  final SupabaseClient _client;

  ReactionRemoteDataSourceImpl({required SupabaseClient client}) : _client = client;

  @override
  Future<List<ReactionModel>> getReactions(
    String targetId,
    ReactionTargetType targetType,
  ) async {
    try {
      final response = await _client
          .from('reactions')
          .select()
          .eq('target_id', targetId)
          .eq('target_type', targetType.name);

      return (response as List)
          .map((json) => ReactionModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to get reactions: ${e.message}',
        statusCode: JsonHelpers.parseIntOrDefault(e.code, defaultValue: 500),
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get reactions: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ReactionModel> addReaction({
    required String userId,
    required String targetId,
    required ReactionTargetType targetType,
    required ReactionType reaction,
  }) async {
    try {
      final response = await _client
          .from('reactions')
          .insert({
            'user_id': userId,
            'target_id': targetId,
            'target_type': targetType.name,
            'reaction': reaction.name,
          })
          .select()
          .single();
      return ReactionModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to add reaction: ${e.message}',
        statusCode: JsonHelpers.parseIntOrDefault(e.code, defaultValue: 500),
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to add reaction: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> removeReaction({
    required String userId,
    required String targetId,
    required ReactionTargetType targetType,
  }) async {
    try {
      await _client
          .from('reactions')
          .delete()
          .eq('user_id', userId)
          .eq('target_id', targetId)
          .eq('target_type', targetType.name);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to remove reaction: ${e.message}',
        statusCode: JsonHelpers.parseIntOrDefault(e.code, defaultValue: 500),
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to remove reaction: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<ReactionModel?> getUserReaction({
    required String userId,
    required String targetId,
    required ReactionTargetType targetType,
  }) async {
    try {
      final response = await _client
          .from('reactions')
          .select()
          .eq('user_id', userId)
          .eq('target_id', targetId)
          .eq('target_type', targetType.name)
          .maybeSingle();
      if (response == null) return null;
      return ReactionModel.fromJson(response);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to get user reaction: ${e.message}',
        statusCode: JsonHelpers.parseIntOrDefault(e.code, defaultValue: 500),
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get user reaction: $e',
        statusCode: 500,
      );
    }
  }
}
