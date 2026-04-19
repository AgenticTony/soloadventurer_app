import '../../domain/entities/content_privacy_settings.dart';
import '../../domain/enums/content_audience.dart';
import '../../domain/enums/comment_permission.dart';

/// Data model for content privacy settings, mapping to/from Supabase JSON
class ContentPrivacySettingsModel {
  /// Creates a new [ContentPrivacySettingsModel]
  const ContentPrivacySettingsModel({
    required this.userId,
    required this.defaultPostAudience,
    required this.allowCommentsFrom,
    required this.allowReshares,
    required this.includeInDestinationFeed,
  });

  /// The user ID these settings belong to
  final String userId;

  /// Default audience for new posts
  final ContentAudience defaultPostAudience;

  /// Who can comment on posts
  final CommentPermission allowCommentsFrom;

  /// Whether resharing is allowed
  final bool allowReshares;

  /// Whether posts appear in destination feeds
  final bool includeInDestinationFeed;

  /// Creates a [ContentPrivacySettingsModel] from Supabase JSON
  factory ContentPrivacySettingsModel.fromJson(Map<String, dynamic> json) {
    return ContentPrivacySettingsModel(
      userId: json['user_id'] as String? ?? '',
      defaultPostAudience: ContentAudience.fromString(
        json['default_post_audience'] as String? ?? 'followers',
      ),
      allowCommentsFrom: CommentPermission.fromString(
        json['allow_comments_from'] as String? ?? 'followers',
      ),
      allowReshares: json['allow_reshares'] as bool? ?? false,
      includeInDestinationFeed:
          json['include_in_destination_feed'] as bool? ?? false,
    );
  }

  /// Converts to Supabase JSON map
  Map<String, dynamic> toJson() {
    return {
      'user_id': userId,
      'default_post_audience': defaultPostAudience.value,
      'allow_comments_from': allowCommentsFrom.value,
      'allow_reshares': allowReshares,
      'include_in_destination_feed': includeInDestinationFeed,
    };
  }

  /// Converts to a domain [ContentPrivacySettings] entity
  ContentPrivacySettings toEntity() {
    return ContentPrivacySettings(
      defaultPostAudience: defaultPostAudience,
      allowCommentsFrom: allowCommentsFrom,
      allowReshares: allowReshares,
      includeInDestinationFeed: includeInDestinationFeed,
    );
  }

  /// Creates from a domain [ContentPrivacySettings] entity
  factory ContentPrivacySettingsModel.fromEntity(
    String userId,
    ContentPrivacySettings entity,
  ) {
    return ContentPrivacySettingsModel(
      userId: userId,
      defaultPostAudience: entity.defaultPostAudience,
      allowCommentsFrom: entity.allowCommentsFrom,
      allowReshares: entity.allowReshares,
      includeInDestinationFeed: entity.includeInDestinationFeed,
    );
  }
}
