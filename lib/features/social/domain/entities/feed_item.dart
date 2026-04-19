import 'package:equatable/equatable.dart';

/// Types of actions that can appear in the feed
enum FeedVerb {
  /// User posted content (journal entry, photo, etc.)
  posted,

  /// User followed another user
  followed,

  /// User reacted to content
  reacted,

  /// User commented on content
  commented;

  /// Parse a [FeedVerb] from the string value
  static FeedVerb fromString(String value) {
    switch (value.toLowerCase()) {
      case 'posted':
        return FeedVerb.posted;
      case 'followed':
        return FeedVerb.followed;
      case 'reacted':
        return FeedVerb.reacted;
      case 'commented':
        return FeedVerb.commented;
      default:
        throw ArgumentError('Unknown FeedVerb: $value');
    }
  }
}

/// Extension to get string representation
extension FeedVerbExtension on FeedVerb {
  /// String representation for API serialization
  String get value {
    switch (this) {
      case FeedVerb.posted:
        return 'posted';
      case FeedVerb.followed:
        return 'followed';
      case FeedVerb.reacted:
        return'reacted';
      case FeedVerb.commented:
        return 'commented';
    }
  }
}

/// Represents a single item in the user's social feed
class FeedItem extends Equatable {
  /// Creates a new [FeedItem]
  const FeedItem({
    required this.id,
    required this.actorId,
    required this.actorUsername,
    this.actorAvatar,
    required this.verb,
    required this.objectId,
    required this.objectType,
    required this.createdAt,
  });

  /// Unique identifier for this feed item
  final String id;

  /// The user who performed the action
  final String actorId;

  /// Username of the actor
  final String actorUsername;

  /// Avatar URL of the actor (may be null)
  final String? actorAvatar;

  /// The type of action performed
  final FeedVerb verb;

  /// ID of the object being acted upon
  final String objectId;

  /// Type of the object (e.g., 'journal', 'trip', 'comment')
  final String objectType;

  /// When the action occurred
  final DateTime createdAt;

  @override
  List<Object?> get props => [
        id,
        actorId,
        actorUsername,
        actorAvatar,
        verb,
        objectId,
        objectType,
        createdAt,
      ];

  /// Creates a copy of this feed item with the given fields replaced
  FeedItem copyWith({
    String? id,
    String? actorId,
    String? actorUsername,
    String? actorAvatar,
    FeedVerb? verb,
    String? objectId,
    String? objectType,
    DateTime? createdAt,
  }) {
    return FeedItem(
      id: id ?? this.id,
      actorId: actorId ?? this.actorId,
      actorUsername: actorUsername ?? this.actorUsername,
      actorAvatar: actorAvatar ?? this.actorAvatar,
      verb: verb ?? this.verb,
      objectId: objectId ?? this.objectId,
      objectType: objectType ?? this.objectType,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
