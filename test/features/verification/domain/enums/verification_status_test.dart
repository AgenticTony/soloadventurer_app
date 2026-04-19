import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/verification/domain/enums/verification_status.dart';

void main() {
  group('VerificationStatus', () {
    test('fromString parses valid values', () {
      expect(VerificationStatus.fromString('pending'), VerificationStatus.pending);
      expect(VerificationStatus.fromString('processing'), VerificationStatus.processing);
      expect(VerificationStatus.fromString('verified'), VerificationStatus.verified);
      expect(VerificationStatus.fromString('approved'), VerificationStatus.verified);
      expect(VerificationStatus.fromString('failed'), VerificationStatus.failed);
      expect(VerificationStatus.fromString('rejected'), VerificationStatus.failed);
      expect(VerificationStatus.fromString('expired'), VerificationStatus.expired);
    });

    test('fromString throws on unknown values', () {
      expect(() => VerificationStatus.fromString('unknown'), throwsArgumentError);
    });

    test('value serializes correctly', () {
      expect(VerificationStatus.pending.value, 'pending');
      expect(VerificationStatus.processing.value, 'processing');
      expect(VerificationStatus.verified.value, 'verified');
      expect(VerificationStatus.failed.value, 'failed');
      expect(VerificationStatus.expired.value, 'expired');
    });

    test('isTerminal identifies terminal states', () {
      expect(VerificationStatus.pending.isTerminal, isFalse);
      expect(VerificationStatus.processing.isTerminal, isFalse);
      expect(VerificationStatus.verified.isTerminal, isTrue);
      expect(VerificationStatus.failed.isTerminal, isTrue);
      expect(VerificationStatus.expired.isTerminal, isTrue);
    });

    test('canRetry identifies retryable states', () {
      expect(VerificationStatus.pending.canRetry, isFalse);
      expect(VerificationStatus.processing.canRetry, isFalse);
      expect(VerificationStatus.verified.canRetry, isFalse);
      expect(VerificationStatus.failed.canRetry, isTrue);
      expect(VerificationStatus.expired.canRetry, isTrue);
    });

    test('round-trip serialization', () {
      for (final status in VerificationStatus.values) {
        expect(VerificationStatus.fromString(status.value), status);
      }
    });
  });
}
