import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/core/utils/json_helpers.dart';
import '../models/follow_model.dart';

/// Abstract interface for follow-related remote data operations
abstract class FollowRemoteDataSource {
  /// Create a new follow relationship
  Future<FollowModel> createFollow({
    required String followerId,
    required String followingId,
  });

  /// Delete a follow relationship
  Future<void> deleteFollow({
    required String followerId,
    required String followingId,
  });

  /// Update the status of a follow relationship
  Future<void> updateFollowStatus({
    required String followerId,
    required String followingId,
    required String status,
  });

  /// Get accepted followers for a user
  Future<List<FollowModel>> getFollowers(String userId);

  /// Get accepted following for a user
  Future<List<FollowModel>> getFollowing(String userId);

  /// Get pending follow requests for a user
  Future<List<FollowModel>> getPendingRequests(String userId);

  /// Check if a follow relationship exists between two users
  Future<bool> checkIsFollowing({
    required String followerId,
    required String followingId,
  });
}

/// Supabase implementation of [FollowRemoteDataSource]
class FollowRemoteDataSourceImpl implements FollowRemoteDataSource {
  final SupabaseClient _client;

  /// Creates a new [FollowRemoteDataSourceImpl] with the given Supabase client
  FollowRemoteDataSourceImpl({required SupabaseClient client}) : _client = client;

  @override
  Future<FollowModel> createFollow({
    required String followerId,
    required String followingId,
  }) async {
    try {
      final response = await _client
          .from('follows')
          .insert({
            'follower_id': followerId,
            'following_id': followingId,
            'status': 'pending',
          })
          .select()
          .single();

      return FollowModel.fromJson(response);
    } on PostgrestException catch (e) {
      if (e.code == '23505') {
        throw const ConflictException(
          message: 'Follow relationship already exists',
        );
      }
      throw ServerException(
        message: 'Failed to create follow: ${e.message}',
        statusCode: JsonHelpers.parseIntOrDefault(e.code, defaultValue: 500),
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to create follow: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> deleteFollow({
    required String followerId,
    required String followingId,
  }) async {
    try {
      await _client
          .from('follows')
          .delete()
          .match({
            'follower_id': followerId,
            'following_id': followingId,
          });
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to delete follow: ${e.message}',
        statusCode: JsonHelpers.parseIntOrDefault(e.code, defaultValue: 500),
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to delete follow: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<void> updateFollowStatus({
    required String followerId,
    required String followingId,
    required String status,
  }) async {
    try {
      await _client
          .from('follows')
          .update({
            'status': status,
            'updated_at': DateTime.now().toUtc().toIso8601String(),
          })
          .eq('follower_id', followerId)
          .eq('following_id', followingId);
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to update follow status: ${e.message}',
        statusCode: JsonHelpers.parseIntOrDefault(e.code, defaultValue: 500),
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to update follow status: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<FollowModel>> getFollowers(String userId) async {
    try {
      final response = await _client
          .from('follows')
          .select()
          .eq('following_id', userId)
          .eq('status', 'accepted')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => FollowModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to get followers: ${e.message}',
        statusCode: JsonHelpers.parseIntOrDefault(e.code, defaultValue: 500),
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get followers: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<FollowModel>> getFollowing(String userId) async {
    try {
      final response = await _client
          .from('follows')
          .select()
          .eq('follower_id', userId)
          .eq('status', 'accepted')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => FollowModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to get following: ${e.message}',
        statusCode: JsonHelpers.parseIntOrDefault(e.code, defaultValue: 500),
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get following: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<List<FollowModel>> getPendingRequests(String userId) async {
    try {
      final response = await _client
          .from('follows')
          .select()
          .eq('following_id', userId)
          .eq('status', 'pending')
          .order('created_at', ascending: false);

      return (response as List)
          .map((json) => FollowModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to get pending requests: ${e.message}',
        statusCode: JsonHelpers.parseIntOrDefault(e.code, defaultValue: 500),
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to get pending requests: $e',
        statusCode: 500,
      );
    }
  }

  @override
  Future<bool> checkIsFollowing({
    required String followerId,
    required String followingId,
  }) async {
    try {
      final response = await _client
          .from('follows')
          .select('id')
          .eq('follower_id', followerId)
          .eq('following_id', followingId)
          .eq('status', 'accepted')
          .maybeSingle();

      return response != null;
    } on PostgrestException catch (e) {
      throw ServerException(
        message: 'Failed to check follow status: ${e.message}',
        statusCode: JsonHelpers.parseIntOrDefault(e.code, defaultValue: 500),
      );
    } catch (e) {
      throw ServerException(
        message: 'Failed to check follow status: $e',
        statusCode: 500,
      );
    }
  }
}
