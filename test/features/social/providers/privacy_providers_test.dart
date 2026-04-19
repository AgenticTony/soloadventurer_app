import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/social/domain/entities/content_privacy_settings.dart';
import 'package:soloadventurer/features/social/domain/entities/privacy_settings.dart';
import 'package:soloadventurer/features/social/domain/enums/comment_permission.dart';
import 'package:soloadventurer/features/social/domain/enums/content_audience.dart';
import 'package:soloadventurer/features/social/domain/enums/profile_visibility.dart';

void main() {
  group('ContentPrivacySettings', () {
    group('defaults', () {
      test('has correct default values', () {
        const settings = ContentPrivacySettings();

        expect(settings.defaultPostAudience, ContentAudience.followers);
        expect(settings.allowCommentsFrom, CommentPermission.followers);
        expect(settings.allowReshares, isFalse);
        expect(settings.includeInDestinationFeed, isFalse);
      });
    });

    group('copyWith', () {
      test('creates new instance with updated defaultPostAudience', () {
        const original = ContentPrivacySettings();
        final updated = original.copyWith(
          defaultPostAudience: ContentAudience.public,
        );

        expect(updated.defaultPostAudience, ContentAudience.public);
        expect(updated.allowCommentsFrom, original.allowCommentsFrom);
        expect(updated.allowReshares, original.allowReshares);
        expect(
          updated.includeInDestinationFeed,
          original.includeInDestinationFeed,
        );
        // Original is unchanged
        expect(original.defaultPostAudience, ContentAudience.followers);
      });

      test('creates new instance with updated allowCommentsFrom', () {
        const original = ContentPrivacySettings();
        final updated = original.copyWith(
          allowCommentsFrom: CommentPermission.everyone,
        );

        expect(updated.allowCommentsFrom, CommentPermission.everyone);
        expect(updated.defaultPostAudience, original.defaultPostAudience);
      });

      test('creates new instance with updated allowReshares', () {
        const original = ContentPrivacySettings(allowReshares: false);
        final updated = original.copyWith(allowReshares: true);

        expect(updated.allowReshares, isTrue);
        expect(updated.defaultPostAudience, original.defaultPostAudience);
      });

      test('creates new instance with updated includeInDestinationFeed', () {
        const original = ContentPrivacySettings(includeInDestinationFeed: false);
        final updated = original.copyWith(includeInDestinationFeed: true);

        expect(updated.includeInDestinationFeed, isTrue);
      });

      test('returns identical instance when called with no arguments', () {
        const original = ContentPrivacySettings(
          defaultPostAudience: ContentAudience.public,
          allowCommentsFrom: CommentPermission.everyone,
          allowReshares: true,
          includeInDestinationFeed: true,
        );
        final copy = original.copyWith();

        expect(copy.defaultPostAudience, original.defaultPostAudience);
        expect(copy.allowCommentsFrom, original.allowCommentsFrom);
        expect(copy.allowReshares, original.allowReshares);
        expect(copy.includeInDestinationFeed, original.includeInDestinationFeed);
      });

      test('updates multiple fields at once', () {
        const original = ContentPrivacySettings();
        final updated = original.copyWith(
          defaultPostAudience: ContentAudience.community,
          allowCommentsFrom: CommentPermission.nobody,
          allowReshares: true,
          includeInDestinationFeed: true,
        );

        expect(updated.defaultPostAudience, ContentAudience.community);
        expect(updated.allowCommentsFrom, CommentPermission.nobody);
        expect(updated.allowReshares, isTrue);
        expect(updated.includeInDestinationFeed, isTrue);
      });
    });

    group('equality', () {
      test('equal when all fields match', () {
        const a = ContentPrivacySettings(
          defaultPostAudience: ContentAudience.followers,
          allowCommentsFrom: CommentPermission.followers,
          allowReshares: false,
          includeInDestinationFeed: false,
        );
        const b = ContentPrivacySettings(
          defaultPostAudience: ContentAudience.followers,
          allowCommentsFrom: CommentPermission.followers,
          allowReshares: false,
          includeInDestinationFeed: false,
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal when defaultPostAudience differs', () {
        const a = ContentPrivacySettings(
          defaultPostAudience: ContentAudience.followers,
        );
        const b = ContentPrivacySettings(
          defaultPostAudience: ContentAudience.public,
        );

        expect(a, isNot(equals(b)));
      });

      test('not equal when allowReshares differs', () {
        const a = ContentPrivacySettings(allowReshares: false);
        const b = ContentPrivacySettings(allowReshares: true);

        expect(a, isNot(equals(b)));
      });
    });
  });

  group('PrivacySettings', () {
    group('defaults', () {
      test('has correct default values', () {
        const settings = PrivacySettings();

        expect(settings.visibility, ProfileVisibility.community);
        expect(settings.minViewerAge, isNull);
        expect(settings.verifiedOnly, isFalse);
        expect(settings.genderFilter, isNull);
        expect(settings.showLocation, isTrue);
        expect(settings.discoverableByDestination, isTrue);
      });
    });

    group('copyWith', () {
      test('creates new instance with updated visibility', () {
        const original = PrivacySettings();
        final updated = original.copyWith(
          visibility: ProfileVisibility.public,
        );

        expect(updated.visibility, ProfileVisibility.public);
        expect(original.visibility, ProfileVisibility.community);
      });

      test('creates new instance with updated verifiedOnly', () {
        const original = PrivacySettings();
        final updated = original.copyWith(verifiedOnly: true);

        expect(updated.verifiedOnly, isTrue);
        expect(original.verifiedOnly, isFalse);
      });

      test('creates new instance with updated showLocation', () {
        const original = PrivacySettings(showLocation: true);
        final updated = original.copyWith(showLocation: false);

        expect(updated.showLocation, isFalse);
      });

      test('retains original values when called with no arguments', () {
        const original = PrivacySettings(
          visibility: ProfileVisibility.hidden,
          verifiedOnly: true,
          showLocation: false,
        );
        final copy = original.copyWith();

        expect(copy.visibility, original.visibility);
        expect(copy.verifiedOnly, original.verifiedOnly);
        expect(copy.showLocation, original.showLocation);
        expect(copy.discoverableByDestination, original.discoverableByDestination);
      });
    });

    group('equality', () {
      test('equal when all fields match', () {
        const a = PrivacySettings(
          visibility: ProfileVisibility.public,
          verifiedOnly: true,
          showLocation: false,
        );
        const b = PrivacySettings(
          visibility: ProfileVisibility.public,
          verifiedOnly: true,
          showLocation: false,
        );

        expect(a, equals(b));
        expect(a.hashCode, equals(b.hashCode));
      });

      test('not equal when visibility differs', () {
        const a = PrivacySettings(visibility: ProfileVisibility.community);
        const b = PrivacySettings(visibility: ProfileVisibility.public);

        expect(a, isNot(equals(b)));
      });
    });
  });
}
