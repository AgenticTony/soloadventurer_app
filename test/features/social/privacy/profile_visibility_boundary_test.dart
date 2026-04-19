import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/social/domain/enums/profile_visibility.dart';
import 'package:soloadventurer/features/social/domain/entities/privacy_settings.dart';

void main() {
  group('ProfileVisibility boundary', () {
    /// Simulates whether a profile is discoverable given its visibility.
    bool isDiscoverable({
      required ProfileVisibility visibility,
      required String viewerType, // 'follower', 'community', 'stranger'
    }) {
      switch (visibility) {
        case ProfileVisibility.hidden:
          // Hidden profiles are only visible to approved followers
          return viewerType == 'follower';
        case ProfileVisibility.community:
          return viewerType == 'follower' || viewerType == 'community';
        case ProfileVisibility.public:
          return true; // Public profiles are discoverable by everyone
      }
    }

    test('hidden profiles are not discoverable by strangers', () {
      expect(
        isDiscoverable(
            visibility: ProfileVisibility.hidden, viewerType: 'stranger'),
        isFalse,
      );
    });

    test('hidden profiles are not discoverable by community members', () {
      expect(
        isDiscoverable(
            visibility: ProfileVisibility.hidden, viewerType: 'community'),
        isFalse,
      );
    });

    test('hidden profiles are visible to approved followers', () {
      expect(
        isDiscoverable(
            visibility: ProfileVisibility.hidden, viewerType: 'follower'),
        isTrue,
      );
    });

    test('public visibility allows discovery by all viewer types', () {
      for (final viewer in ['follower', 'community', 'stranger']) {
        expect(
          isDiscoverable(
              visibility: ProfileVisibility.public, viewerType: viewer),
          isTrue,
          reason: 'Public visibility should allow discovery by $viewer',
        );
      }
    });

    test('community visibility allows discovery by followers and community', () {
      expect(
        isDiscoverable(
            visibility: ProfileVisibility.community, viewerType: 'follower'),
        isTrue,
      );
      expect(
        isDiscoverable(
            visibility: ProfileVisibility.community, viewerType: 'community'),
        isTrue,
      );
      expect(
        isDiscoverable(
            visibility: ProfileVisibility.community, viewerType: 'stranger'),
        isFalse,
      );
    });

    test('default PrivacySettings uses community visibility', () {
      const settings = PrivacySettings();
      expect(settings.visibility, ProfileVisibility.community);
    });

    test('default PrivacySettings has discoverableByDestination = true', () {
      const settings = PrivacySettings();
      expect(settings.discoverableByDestination, isTrue);
    });

    test('default PrivacySettings has showLocation = true', () {
      const settings = PrivacySettings();
      expect(settings.showLocation, isTrue);
    });

    test('default PrivacySettings has verifiedOnly = false', () {
      const settings = PrivacySettings();
      expect(settings.verifiedOnly, isFalse);
    });

    test('ProfileVisibility.fromString parses valid values', () {
      expect(ProfileVisibility.fromString('hidden'), ProfileVisibility.hidden);
      expect(
          ProfileVisibility.fromString('community'), ProfileVisibility.community);
      expect(ProfileVisibility.fromString('public'), ProfileVisibility.public);
    });

    test('ProfileVisibility.fromString throws on invalid value', () {
      expect(
        () => ProfileVisibility.fromString('invalid'),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('ProfileVisibility extension value round-trips correctly', () {
      for (final visibility in ProfileVisibility.values) {
        expect(ProfileVisibility.fromString(visibility.value), visibility);
      }
    });
  });
}
