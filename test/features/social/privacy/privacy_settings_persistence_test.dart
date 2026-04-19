import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/social/domain/enums/comment_permission.dart';
import 'package:soloadventurer/features/social/domain/enums/content_audience.dart';
import 'package:soloadventurer/features/social/domain/enums/profile_visibility.dart';
import 'package:soloadventurer/features/social/domain/entities/content_privacy_settings.dart';
import 'package:soloadventurer/features/social/domain/entities/privacy_settings.dart';

void main() {
  group('ContentPrivacySettings persistence', () {
    test('copyWith preserves unchanged fields', () {
      const original = ContentPrivacySettings(
        defaultPostAudience: ContentAudience.followers,
        allowCommentsFrom: CommentPermission.followers,
        allowReshares: false,
        includeInDestinationFeed: false,
      );

      final updated = original.copyWith(
        allowReshares: true,
      );

      // Changed field
      expect(updated.allowReshares, isTrue);

      // Preserved fields
      expect(updated.defaultPostAudience, ContentAudience.followers);
      expect(updated.allowCommentsFrom, CommentPermission.followers);
      expect(updated.includeInDestinationFeed, isFalse);
    });

    test('copyWith with no arguments returns identical object', () {
      const original = ContentPrivacySettings(
        defaultPostAudience: ContentAudience.community,
        allowCommentsFrom: CommentPermission.everyone,
        allowReshares: true,
        includeInDestinationFeed: true,
      );

      final copy = original.copyWith();

      expect(copy, equals(original));
      expect(copy.defaultPostAudience, ContentAudience.community);
      expect(copy.allowCommentsFrom, CommentPermission.everyone);
      expect(copy.allowReshares, isTrue);
      expect(copy.includeInDestinationFeed, isTrue);
    });

    test('equality works correctly after updates', () {
      const settings1 = ContentPrivacySettings(
        defaultPostAudience: ContentAudience.public,
        allowCommentsFrom: CommentPermission.everyone,
      );
      const settings2 = ContentPrivacySettings(
        defaultPostAudience: ContentAudience.public,
        allowCommentsFrom: CommentPermission.everyone,
      );
      const settings3 = ContentPrivacySettings(
        defaultPostAudience: ContentAudience.followers,
        allowCommentsFrom: CommentPermission.everyone,
      );

      // Same values should be equal
      expect(settings1, equals(settings2));
      expect(settings1.hashCode, equals(settings2.hashCode));

      // Different values should NOT be equal
      expect(settings1, isNot(equals(settings3)));
    });

    test('default constructor provides expected defaults', () {
      const settings = ContentPrivacySettings();

      expect(settings.defaultPostAudience, ContentAudience.followers);
      expect(settings.allowCommentsFrom, CommentPermission.followers);
      expect(settings.allowReshares, isFalse);
      expect(settings.includeInDestinationFeed, isFalse);
    });

    test('copyWith can update all fields at once', () {
      const original = ContentPrivacySettings();
      final updated = original.copyWith(
        defaultPostAudience: ContentAudience.public,
        allowCommentsFrom: CommentPermission.nobody,
        allowReshares: true,
        includeInDestinationFeed: true,
      );

      expect(updated.defaultPostAudience, ContentAudience.public);
      expect(updated.allowCommentsFrom, CommentPermission.nobody);
      expect(updated.allowReshares, isTrue);
      expect(updated.includeInDestinationFeed, isTrue);
    });
  });

  group('PrivacySettings persistence', () {
    test('copyWith preserves unchanged fields', () {
      const original = PrivacySettings(
        visibility: ProfileVisibility.community,
        minViewerAge: 18,
        verifiedOnly: false,
        showLocation: true,
        discoverableByDestination: true,
      );

      final updated = original.copyWith(
        visibility: ProfileVisibility.hidden,
      );

      // Changed field
      expect(updated.visibility, ProfileVisibility.hidden);

      // Preserved fields
      expect(updated.minViewerAge, 18);
      expect(updated.verifiedOnly, isFalse);
      expect(updated.showLocation, isTrue);
      expect(updated.discoverableByDestination, isTrue);
    });

    test('copyWith with no arguments returns identical object', () {
      const original = PrivacySettings(
        visibility: ProfileVisibility.public,
        minViewerAge: 21,
        verifiedOnly: true,
        genderFilter: ['male'],
        showLocation: false,
        discoverableByDestination: false,
      );

      final copy = original.copyWith();

      expect(copy, equals(original));
      expect(copy.visibility, ProfileVisibility.public);
      expect(copy.minViewerAge, 21);
      expect(copy.verifiedOnly, isTrue);
      expect(copy.genderFilter, ['male']);
      expect(copy.showLocation, isFalse);
      expect(copy.discoverableByDestination, isFalse);
    });

    test('equality works correctly after updates', () {
      const settings1 = PrivacySettings(
        visibility: ProfileVisibility.public,
        showLocation: true,
      );
      const settings2 = PrivacySettings(
        visibility: ProfileVisibility.public,
        showLocation: true,
      );
      const settings3 = PrivacySettings(
        visibility: ProfileVisibility.public,
        showLocation: false,
      );

      // Same values should be equal
      expect(settings1, equals(settings2));
      expect(settings1.hashCode, equals(settings2.hashCode));

      // Different values should NOT be equal
      expect(settings1, isNot(equals(settings3)));
    });

    test('default constructor provides expected defaults', () {
      const settings = PrivacySettings();

      expect(settings.visibility, ProfileVisibility.community);
      expect(settings.minViewerAge, isNull);
      expect(settings.verifiedOnly, isFalse);
      expect(settings.genderFilter, isNull);
      expect(settings.showLocation, isTrue);
      expect(settings.discoverableByDestination, isTrue);
    });

    test('copyWith can update all fields at once', () {
      const original = PrivacySettings();
      final updated = original.copyWith(
        visibility: ProfileVisibility.hidden,
        minViewerAge: 25,
        verifiedOnly: true,
        genderFilter: ['female'],
        showLocation: false,
        discoverableByDestination: false,
      );

      expect(updated.visibility, ProfileVisibility.hidden);
      expect(updated.minViewerAge, 25);
      expect(updated.verifiedOnly, isTrue);
      expect(updated.genderFilter, ['female']);
      expect(updated.showLocation, isFalse);
      expect(updated.discoverableByDestination, isFalse);
    });
  });
}
