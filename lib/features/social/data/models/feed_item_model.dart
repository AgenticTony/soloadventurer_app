import '../../domain/entities/feed_item.dart';

/// Data model for feed items,///
/// Maps the the Supabase `get_user_feed` RPC response columns
class FeedItemModel {
  /// Creates a new [FeedItemModel]
  const FeedItemModel({
    required this.id,
    required this.actorId,
    required this.actorUsername,
    this.actorAvatar,
    required this.verb,
    required this.objectId,
    required this.objectType,
    required this.createdAt,
  });

  final String id;
  final String actorId;
  final String actorUsername;
  final String? actorAvatar;
  final FeedVerb verb;
  final String objectId;
  final String objectType;
  final DateTime createdAt;

  /// Creates a [FeedItemModel] from a Supabase RPC response JSON map
  factory FeedItemModel.fromJson(Map<String, dynamic> json) {
    return FeedItemModel(
      id: json['feed_item_id'] as String? ?? '',
      actorId: json['actor_id'] as String? ?? '',
      actorUsername: json['actor_username'] as String? ?? '',
      actorAvatar: json['actor_avatar'] as String?,
      verb: FeedVerb.fromString(json['verb'] as String? ?? 'posted'),
      objectId: json['object_id'] as String? ?? '',
      objectType: json['object_type'] as String? ?? '',
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : DateTime.now(),
    );
  }

  /// Converts to a domain [FeedItem] entity
  FeedItem toEntity() {
    return FeedItem(
      id: id,
      actorId: actorId,
      actorUsername: actorUsername,
      actorAvatar: actorAvatar,
      verb: verb,
      objectId: objectId,
      objectType: objectType,
      createdAt: createdAt,
    );
  }
}
