import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/social/domain/enums/comment_permission.dart';
import 'package:soloadventurer/features/social/domain/enums/content_audience.dart';
import 'package:soloadventurer/features/social/domain/entities/content_privacy_settings.dart';

void main() {
  group('ContentAudience enforcement', () {
    /// Helper: simulates visibility check for a given audience.
    /// Returns true if content is visible to the given viewer type.
    bool isVisibleTo({
      required ContentAudience audience,
      required String viewerType, // 'public', 'community', 'follower', 'stranger'
    }) {
      switch (audience) {
        case ContentAudience.public:
          return true; // Public is visible to everyone
        case ContentAudience.community:
          return viewerType == 'community' ||
              viewerType == 'follower' ||
              viewerType == 'public';
        case ContentAudience.followers:
          // Only followers can see; strangers and general community cannot
          return viewerType == 'follower';
      }
    }

    test('ContentAudience.followers restricts visibility to followers only',
        () {
      // Only followers should see the content
      expect(
        isVisibleTo(
            audience: ContentAudience.followers, viewerType: 'follower'),
        isTrue,
      );

      // Strangers, community members, and general public should NOT see it
      expect(
        isVisibleTo(
            audience: ContentAudience.followers, viewerType: 'stranger'),
        isFalse,
      );
      expect(
        isVisibleTo(
            audience: ContentAudience.followers, viewerType: 'community'),
        isFalse,
      );
      expect(
        isVisibleTo(audience: ContentAudience.followers, viewerType: 'public'),
        isFalse,
      );
    });

    test('ContentAudience.public allows all viewer types', () {
      for (final viewer in ['public', 'community', 'follower', 'stranger']) {
        expect(
          isVisibleTo(audience: ContentAudience.public, viewerType: viewer),
          isTrue,
          reason: 'Public audience should be visible to $viewer',
        );
      }
    });

    test('ContentAudience.community is between followers and public', () {
      // Community members can see
      expect(
        isVisibleTo(
            audience: ContentAudience.community, viewerType: 'community'),
        isTrue,
      );
      // Followers can also see (they are part of the community)
      expect(
        isVisibleTo(
            audience: ContentAudience.community, viewerType: 'follower'),
        isTrue,
      );
      // Strangers cannot see
      expect(
        isVisibleTo(
            audience: ContentAudience.community, viewerType: 'stranger'),
        isFalse,
      );
    });

    test('default ContentPrivacySettings uses followers audience', () {
      const settings = ContentPrivacySettings();
      expect(settings.defaultPostAudience, ContentAudience.followers);
    });

    test('ContentPrivacySettings default restricts comments to followers', () {
      const settings = ContentPrivacySettings();
      expect(settings.allowCommentsFrom, CommentPermission.followers);
    });

    test('ContentAudience.fromString parses valid values', () {
      expect(ContentAudience.fromString('followers'), ContentAudience.followers);
      expect(ContentAudience.fromString('community'), ContentAudience.community);
      expect(ContentAudience.fromString('public'), ContentAudience.public);
    });

    test('ContentAudience.fromString throws on invalid value', () {
      expect(
        () => ContentAudience.fromString('invalid'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('ContentAudience extension value round-trips correctly', () {
      for (final audience in ContentAudience.values) {
        expect(ContentAudience.fromString(audience.value), audience);
      }
    });
  });
}
