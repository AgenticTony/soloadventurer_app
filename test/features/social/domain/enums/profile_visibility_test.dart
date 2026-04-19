import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/social/domain/enums/profile_visibility.dart';

void main() {
  group('ProfileVisibility', () {
    test('has exactly 3 values', () {
      expect(ProfileVisibility.values, hasLength(3));
    });

    group('fromString', () {
      test('returns hidden for "hidden"', () {
        expect(ProfileVisibility.fromString('hidden'), ProfileVisibility.hidden);
      });

      test('returns community for "community"', () {
        expect(ProfileVisibility.fromString('community'), ProfileVisibility.community);
      });

      test('returns public for "public"', () {
        expect(ProfileVisibility.fromString('public'), ProfileVisibility.public);
      });

      test('handles uppercase input', () {
        expect(ProfileVisibility.fromString('HIDDEN'), ProfileVisibility.hidden);
        expect(ProfileVisibility.fromString('Community'), ProfileVisibility.community);
        expect(ProfileVisibility.fromString('PUBLIC'), ProfileVisibility.public);
      });

      test('throws ArgumentError for unknown value', () {
        expect(() => ProfileVisibility.fromString('unknown'), throwsArgumentError);
      });

      test('throws ArgumentError for empty string', () {
        expect(() => ProfileVisibility.fromString(''), throwsArgumentError);
      });
    });

    group('value extension', () {
      test('round-trips through value and fromString', () {
        for (final visibility in ProfileVisibility.values) {
          expect(ProfileVisibility.fromString(visibility.value), visibility);
        }
      });

      test('hidden has value "hidden"', () {
        expect(ProfileVisibility.hidden.value, 'hidden');
      });

      test('community has value "community"', () {
        expect(ProfileVisibility.community.value, 'community');
      });

      test('public has value "public"', () {
        expect(ProfileVisibility.public.value, 'public');
      });
    });
  });
}
