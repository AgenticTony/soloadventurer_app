import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import '../../domain/entities/follow.dart';
import '../../domain/repositories/follow_repository.dart';
import '../datasources/follow_remote_data_source.dart';

/// Implementation of [FollowRepository] using Supabase
class FollowRepositoryImpl implements FollowRepository {
  final FollowRemoteDataSource _remoteDataSource;

  /// Creates a new [FollowRepositoryImpl] with the given remote data source
  FollowRepositoryImpl({required FollowRemoteDataSource remoteDataSource})
      : _remoteDataSource = remoteDataSource;

  /// Get the current authenticated user's ID
  /// Throws [UnauthorizedException] if no user is authenticated
  String _requireCurrentUserId() {
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId == null) {
      throw const UnauthorizedException(
        message: 'User must be authenticated to perform follow operations',
      );
    }
    return userId;
  }

  @override
  Future<void> followUser(String targetId) async {
    final currentUserId = _requireCurrentUserId();
    if (currentUserId == targetId) {
      throw ValidationException(
        message: 'Cannot follow yourself',
        errors: {'target_id': ['Self-follow is not allowed']},
      );
    }
    await _remoteDataSource.createFollow(
      followerId: currentUserId,
      followingId: targetId,
    );
  }

  @override
  Future<void> unfollowUser(String targetId) async {
    final currentUserId = _requireCurrentUserId();
    await _remoteDataSource.deleteFollow(
      followerId: currentUserId,
      followingId: targetId,
    );
  }

  @override
  Future<void> acceptFollow(String followerId) async {
    final currentUserId = _requireCurrentUserId();
    await _remoteDataSource.updateFollowStatus(
      followerId: followerId,
      followingId: currentUserId,
      status: 'accepted',
    );
  }

  @override
  Future<void> declineFollow(String followerId) async {
    final currentUserId = _requireCurrentUserId();
    await _remoteDataSource.deleteFollow(
      followerId: followerId,
      followingId: currentUserId,
    );
  }

  @override
  Future<List<Follow>> getFollowers(String userId) async {
    final models = await _remoteDataSource.getFollowers(userId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Follow>> getFollowing(String userId) async {
    final models = await _remoteDataSource.getFollowing(userId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<List<Follow>> getPendingRequests() async {
    final currentUserId = _requireCurrentUserId();
    final models = await _remoteDataSource.getPendingRequests(currentUserId);
    return models.map((model) => model.toEntity()).toList();
  }

  @override
  Future<bool> isFollowing(String targetId) async {
    final currentUserId = _requireCurrentUserId();
    return _remoteDataSource.checkIsFollowing(
      followerId: currentUserId,
      followingId: targetId,
    );
  }
}
