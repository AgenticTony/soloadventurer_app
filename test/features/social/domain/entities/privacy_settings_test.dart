import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/social/domain/entities/privacy_settings.dart';
import 'package:soloadventurer/features/social/domain/enums/profile_visibility.dart';

void main() {
  group('PrivacySettings', () {
    test('default values are correct', () {
      const settings = PrivacySettings();

      expect(settings.visibility, ProfileVisibility.community);
      expect(settings.minViewerAge, isNull);
      expect(settings.verifiedOnly, isFalse);
      expect(settings.genderFilter, isNull);
      expect(settings.showLocation, isTrue);
      expect(settings.discoverableByDestination, isTrue);
    });

    test('constructs with custom values', () {
      const settings = PrivacySettings(
        visibility: ProfileVisibility.public,
        minViewerAge: 18,
        verifiedOnly: true,
        genderFilter: ['male', 'female'],
        showLocation: false,
        discoverableByDestination: false,
      );

      expect(settings.visibility, ProfileVisibility.public);
      expect(settings.minViewerAge, 18);
      expect(settings.verifiedOnly, isTrue);
      expect(settings.genderFilter, ['male', 'female']);
      expect(settings.showLocation, isFalse);
      expect(settings.discoverableByDestination, isFalse);
    });

    group('copyWith', () {
      const original = PrivacySettings(
        visibility: ProfileVisibility.community,
        verifiedOnly: false,
        showLocation: true,
      );

      test('copies visibility', () {
        final copied = original.copyWith(
          visibility: ProfileVisibility.hidden,
        );
        expect(copied.visibility, ProfileVisibility.hidden);
        expect(copied.verifiedOnly, original.verifiedOnly);
      });

      test('copies minViewerAge', () {
        final copied = original.copyWith(minViewerAge: 21);
        expect(copied.minViewerAge, 21);
      });

      test('copies verifiedOnly', () {
        final copied = original.copyWith(verifiedOnly: true);
        expect(copied.verifiedOnly, isTrue);
      });

      test('copies genderFilter', () {
        final copied = original.copyWith(genderFilter: ['nonbinary']);
        expect(copied.genderFilter, ['nonbinary']);
      });

      test('copies showLocation', () {
        final copied = original.copyWith(showLocation: false);
        expect(copied.showLocation, isFalse);
      });

      test('copies discoverableByDestination', () {
        final copied = original.copyWith(discoverableByDestination: false);
        expect(copied.discoverableByDestination, isFalse);
      });

      test('retains original values when no arguments given', () {
        final copied = original.copyWith();

        expect(copied.visibility, original.visibility);
        expect(copied.minViewerAge, original.minViewerAge);
        expect(copied.verifiedOnly, original.verifiedOnly);
        expect(copied.genderFilter, original.genderFilter);
        expect(copied.showLocation, original.showLocation);
        expect(copied.discoverableByDestination, original.discoverableByDestination);
      });
    });

    group('equality', () {
      test('equal when all props match', () {
        const a = PrivacySettings();
        const b = PrivacySettings();
        expect(a, equals(b));
      });

      test('not equal when visibility differs', () {
        const a = PrivacySettings(visibility: ProfileVisibility.community);
        const b = PrivacySettings(visibility: ProfileVisibility.public);
        expect(a, isNot(equals(b)));
      });

      test('not equal when minViewerAge differs', () {
        const a = PrivacySettings(minViewerAge: 18);
        const b = PrivacySettings(minViewerAge: 21);
        expect(a, isNot(equals(b)));
      });

      test('not equal when verifiedOnly differs', () {
        const a = PrivacySettings(verifiedOnly: false);
        const b = PrivacySettings(verifiedOnly: true);
        expect(a, isNot(equals(b)));
      });

      test('not equal when showLocation differs', () {
        const a = PrivacySettings(showLocation: true);
        const b = PrivacySettings(showLocation: false);
        expect(a, isNot(equals(b)));
      });

      test('not equal when discoverableByDestination differs', () {
        const a = PrivacySettings(discoverableByDestination: true);
        const b = PrivacySettings(discoverableByDestination: false);
        expect(a, isNot(equals(b)));
      });
    });
  });
}
