import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/social/domain/enums/content_audience.dart';

void main() {
  group('ContentAudience', () {
    test('has exactly 3 values', () {
      expect(ContentAudience.values, hasLength(3));
    });

    group('fromString', () {
      test('returns followers for "followers"', () {
        expect(ContentAudience.fromString('followers'), ContentAudience.followers);
      });

      test('returns community for "community"', () {
        expect(ContentAudience.fromString('community'), ContentAudience.community);
      });

      test('returns public for "public"', () {
        expect(ContentAudience.fromString('public'), ContentAudience.public);
      });

      test('handles uppercase input', () {
        expect(ContentAudience.fromString('Followers'), ContentAudience.followers);
        expect(ContentAudience.fromString('COMMUNITY'), ContentAudience.community);
        expect(ContentAudience.fromString('Public'), ContentAudience.public);
      });

      test('throws ArgumentError for unknown value', () {
        expect(() => ContentAudience.fromString('unknown'), throwsArgumentError);
      });

      test('throws ArgumentError for empty string', () {
        expect(() => ContentAudience.fromString(''), throwsArgumentError);
      });
    });

    group('value extension', () {
      test('round-trips through value and fromString', () {
        for (final audience in ContentAudience.values) {
          expect(ContentAudience.fromString(audience.value), audience);
        }
      });

      test('followers has value "followers"', () {
        expect(ContentAudience.followers.value, 'followers');
      });

      test('community has value "community"', () {
        expect(ContentAudience.community.value, 'community');
      });

      test('public has value "public"', () {
        expect(ContentAudience.public.value, 'public');
      });
    });
  });
}
