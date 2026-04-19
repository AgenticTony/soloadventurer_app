import '../entities/follow.dart';

/// Repository interface for follow-related operations
abstract class FollowRepository {
  /// Send a follow request to the target user
  Future<void> followUser(String targetId);

  /// Unfollow or cancel a follow request to the target user
  Future<void> unfollowUser(String targetId);

  /// Accept a pending follow request from a follower
  Future<void> acceptFollow(String followerId);

  /// Decline a pending follow request from a follower
  Future<void> declineFollow(String followerId);

  /// Get the list of accepted followers for the given user
  Future<List<Follow>> getFollowers(String userId);

  /// Get the list of users the given user is following
  Future<List<Follow>> getFollowing(String userId);

  /// Get pending follow requests for the current user
  Future<List<Follow>> getPendingRequests();

  /// Check if the current user is following the target user
  Future<bool> isFollowing(String targetId);
}
