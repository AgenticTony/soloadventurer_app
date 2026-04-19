import 'package:equatable/equatable.dart';

/// Status of a follow relationship
enum FollowStatus {
  /// The follow request is awaiting acceptance
  pending,

  /// The follow request has been accepted
  accepted;

  /// Parse a follow status from a string value
  static FollowStatus fromString(String value) {
    switch (value.toLowerCase()) {
      case 'pending':
        return FollowStatus.pending;
      case 'accepted':
        return FollowStatus.accepted;
      default:
        throw ArgumentError('Unknown FollowStatus: $value');
    }
  }
}

/// Represents a follow relationship between two users
class Follow extends Equatable {
  /// Creates a new [Follow]
  const Follow({
    required this.id,
    required this.followerId,
    required this.followingId,
    required this.status,
    required this.createdAt,
    required this.updatedAt,
  });

  /// The unique identifier of the follow relationship
  final String id;

  /// The user ID who initiated the follow
  final String followerId;

  /// The user ID who is being followed
  final String followingId;

  /// The current status of the follow relationship
  final FollowStatus status;

  /// When the follow relationship was created
  final DateTime createdAt;

  /// When the follow relationship was last updated
  final DateTime updatedAt;

  @override
  List<Object?> get props => [
        id,
        followerId,
        followingId,
        status,
        createdAt,
        updatedAt,
      ];

  /// Creates a copy of this follow with the given fields replaced with new values
  Follow copyWith({
    String? id,
    String? followerId,
    String? followingId,
    FollowStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Follow(
      id: id ?? this.id,
      followerId: followerId ?? this.followerId,
      followingId: followingId ?? this.followingId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
