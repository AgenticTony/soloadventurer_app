import 'package:equatable/equatable.dart';
import '../enums/content_audience.dart';
import '../enums/comment_permission.dart';

/// Content privacy settings controlling default audience and interactions
class ContentPrivacySettings extends Equatable {
  /// Creates a new [ContentPrivacySettings]
  const ContentPrivacySettings({
    this.defaultPostAudience = ContentAudience.followers,
    this.allowCommentsFrom = CommentPermission.followers,
    this.allowReshares = false,
    this.includeInDestinationFeed = false,
  });

  /// Default audience for new posts
  final ContentAudience defaultPostAudience;

  /// Who can comment on posts
  final CommentPermission allowCommentsFrom;

  /// Whether others can reshare this user's content
  final bool allowReshares;

  /// Whether posts appear in destination feeds
  final bool includeInDestinationFeed;

  @override
  List<Object?> get props => [
        defaultPostAudience,
        allowCommentsFrom,
        allowReshares,
        includeInDestinationFeed,
      ];

  /// Creates a copy with the given fields replaced
  ContentPrivacySettings copyWith({
    ContentAudience? defaultPostAudience,
    CommentPermission? allowCommentsFrom,
    bool? allowReshares,
    bool? includeInDestinationFeed,
  }) {
    return ContentPrivacySettings(
      defaultPostAudience: defaultPostAudience ?? this.defaultPostAudience,
      allowCommentsFrom: allowCommentsFrom ?? this.allowCommentsFrom,
      allowReshares: allowReshares ?? this.allowReshares,
      includeInDestinationFeed:
          includeInDestinationFeed ?? this.includeInDestinationFeed,
    );
  }
}
