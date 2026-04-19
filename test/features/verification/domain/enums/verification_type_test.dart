import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/verification/domain/enums/verification_type.dart';

void main() {
  group('VerificationType', () {
    test('fromString parses valid values', () {
      expect(VerificationType.fromString('photo'), VerificationType.photo);
      expect(VerificationType.fromString('selfie'), VerificationType.photo);
      expect(VerificationType.fromString('government_id'), VerificationType.governmentId);
      expect(VerificationType.fromString('id'), VerificationType.governmentId);
      expect(VerificationType.fromString('governmentid'), VerificationType.governmentId);
    });

    test('fromString throws on unknown values', () {
      expect(() => VerificationType.fromString('unknown'), throwsArgumentError);
    });

    test('value serializes correctly', () {
      expect(VerificationType.photo.value, 'photo');
      expect(VerificationType.governmentId.value, 'government_id');
    });

    test('label returns human-readable names', () {
      expect(VerificationType.photo.label, 'Photo Verification');
      expect(VerificationType.governmentId.label, 'ID Verification');
    });

    test('round-trip serialization', () {
      for (final type in VerificationType.values) {
        expect(VerificationType.fromString(type.value), type);
      }
    });
  });
}
