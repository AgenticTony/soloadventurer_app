import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/social/domain/enums/comment_permission.dart';
import 'package:soloadventurer/features/social/domain/enums/content_audience.dart';
import 'package:soloadventurer/features/social/domain/entities/content_privacy_settings.dart';

void main() {
  group('ContentPrivacySettings', () {
    test('default values are correct', () {
      const settings = ContentPrivacySettings();

      expect(settings.defaultPostAudience, ContentAudience.followers);
      expect(settings.allowCommentsFrom, CommentPermission.followers);
      expect(settings.allowReshares, isFalse);
      expect(settings.includeInDestinationFeed, isFalse);
    });

    test('constructs with custom values', () {
      const settings = ContentPrivacySettings(
        defaultPostAudience: ContentAudience.public,
        allowCommentsFrom: CommentPermission.everyone,
        allowReshares: true,
        includeInDestinationFeed: true,
      );

      expect(settings.defaultPostAudience, ContentAudience.public);
      expect(settings.allowCommentsFrom, CommentPermission.everyone);
      expect(settings.allowReshares, isTrue);
      expect(settings.includeInDestinationFeed, isTrue);
    });

    group('copyWith', () {
      const original = ContentPrivacySettings();

      test('copies defaultPostAudience', () {
        final copied = original.copyWith(
          defaultPostAudience: ContentAudience.community,
        );
        expect(copied.defaultPostAudience, ContentAudience.community);
        expect(copied.allowCommentsFrom, original.allowCommentsFrom);
      });

      test('copies allowCommentsFrom', () {
        final copied = original.copyWith(
          allowCommentsFrom: CommentPermission.everyone,
        );
        expect(copied.allowCommentsFrom, CommentPermission.everyone);
      });

      test('copies allowReshares', () {
        final copied = original.copyWith(allowReshares: true);
        expect(copied.allowReshares, isTrue);
      });

      test('copies includeInDestinationFeed', () {
        final copied = original.copyWith(includeInDestinationFeed: true);
        expect(copied.includeInDestinationFeed, isTrue);
      });

      test('retains original values when no arguments given', () {
        final copied = original.copyWith();

        expect(copied.defaultPostAudience, original.defaultPostAudience);
        expect(copied.allowCommentsFrom, original.allowCommentsFrom);
        expect(copied.allowReshares, original.allowReshares);
        expect(copied.includeInDestinationFeed, original.includeInDestinationFeed);
      });
    });

    group('equality', () {
      test('equal when all props match', () {
        const a = ContentPrivacySettings();
        const b = ContentPrivacySettings();
        expect(a, equals(b));
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

      test('not equal when allowCommentsFrom differs', () {
        const a = ContentPrivacySettings(
          allowCommentsFrom: CommentPermission.followers,
        );
        const b = ContentPrivacySettings(
          allowCommentsFrom: CommentPermission.everyone,
        );
        expect(a, isNot(equals(b)));
      });

      test('not equal when allowReshares differs', () {
        const a = ContentPrivacySettings(allowReshares: false);
        const b = ContentPrivacySettings(allowReshares: true);
        expect(a, isNot(equals(b)));
      });

      test('not equal when includeInDestinationFeed differs', () {
        const a = ContentPrivacySettings(includeInDestinationFeed: false);
        const b = ContentPrivacySettings(includeInDestinationFeed: true);
        expect(a, isNot(equals(b)));
      });
    });
  });
}
