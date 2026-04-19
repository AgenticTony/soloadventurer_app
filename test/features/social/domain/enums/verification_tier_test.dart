import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/social/domain/enums/verification_tier.dart';

void main() {
  group('VerificationTier', () {
    test('has exactly 3 values', () {
      expect(VerificationTier.values, hasLength(3));
    });

    group('fromString', () {
      test('returns unverified for "unverified"', () {
        expect(VerificationTier.fromString('unverified'), VerificationTier.unverified);
      });

      test('returns emailVerified for "email"', () {
        expect(VerificationTier.fromString('email'), VerificationTier.emailVerified);
      });

      test('returns emailVerified for "email_verified"', () {
        expect(VerificationTier.fromString('email_verified'), VerificationTier.emailVerified);
      });

      test('returns idVerified for "id_verified"', () {
        expect(VerificationTier.fromString('id_verified'), VerificationTier.idVerified);
      });

      test('handles uppercase input', () {
        expect(VerificationTier.fromString('UNVERIFIED'), VerificationTier.unverified);
        expect(VerificationTier.fromString('EMAIL'), VerificationTier.emailVerified);
        expect(VerificationTier.fromString('ID_VERIFIED'), VerificationTier.idVerified);
      });

      test('throws ArgumentError for unknown value', () {
        expect(() => VerificationTier.fromString('unknown'), throwsArgumentError);
      });

      test('throws ArgumentError for empty string', () {
        expect(() => VerificationTier.fromString(''), throwsArgumentError);
      });
    });

    group('value extension', () {
      test('unverified has value "unverified"', () {
        expect(VerificationTier.unverified.value, 'unverified');
      });

      test('emailVerified has value "email"', () {
        expect(VerificationTier.emailVerified.value, 'email');
      });

      test('idVerified has value "id_verified"', () {
        expect(VerificationTier.idVerified.value, 'id_verified');
      });

      test('value is parseable back via fromString', () {
        // unverified and id_verified round-trip directly
        expect(VerificationTier.fromString(VerificationTier.unverified.value),
            VerificationTier.unverified);
        expect(VerificationTier.fromString(VerificationTier.idVerified.value),
            VerificationTier.idVerified);
        // emailVerified.value is "email" which maps back correctly
        expect(VerificationTier.fromString(VerificationTier.emailVerified.value),
            VerificationTier.emailVerified);
      });
    });
  });
}
