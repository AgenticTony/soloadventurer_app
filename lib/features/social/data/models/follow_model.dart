import '../../domain/entities/follow.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';

/// Data model for follow relationships, mapping to/from Supabase JSON
class FollowModel {
  /// Creates a new [FollowModel]
  const FollowModel({
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

  /// Creates a [FollowModel] from a Supabase JSON map
  factory FollowModel.fromJson(Map<String, dynamic> json) {
    final followerId = json['follower_id'] as String?;
    final followingId = json['following_id'] as String?;

    if (followerId != null && followingId != null && followerId == followingId) {
      throw ValidationException(
        message: 'Self-follow is not allowed',
        errors: {'follower_id': ['Cannot follow yourself']},
      );
    }

    return FollowModel(
      id: json['id'] as String,
      followerId: followerId ?? '',
      followingId: followingId ?? '',
      status: FollowStatus.fromString(json['status'] as String? ?? 'pending'),
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts this model to a Supabase-compatible JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'follower_id': followerId,
      'following_id': followingId,
      'status': status.name,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates a [FollowModel] from a domain [Follow] entity
  factory FollowModel.fromEntity(Follow follow) {
    return FollowModel(
      id: follow.id,
      followerId: follow.followerId,
      followingId: follow.followingId,
      status: follow.status,
      createdAt: follow.createdAt,
      updatedAt: follow.updatedAt,
    );
  }

  /// Converts this model to a domain [Follow] entity
  Follow toEntity() {
    return Follow(
      id: id,
      followerId: followerId,
      followingId: followingId,
      status: status,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Creates a copy of this model with the given fields replaced
  FollowModel copyWith({
    String? id,
    String? followerId,
    String? followingId,
    FollowStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return FollowModel(
      id: id ?? this.id,
      followerId: followerId ?? this.followerId,
      followingId: followingId ?? this.followingId,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
