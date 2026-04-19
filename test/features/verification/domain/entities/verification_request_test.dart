import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/verification/domain/entities/verification_request.dart';
import 'package:soloadventurer/features/verification/domain/enums/verification_status.dart';
import 'package:soloadventurer/features/verification/domain/enums/verification_type.dart';

void main() {
  group('VerificationRequest', () {
    final now = DateTime(2026, 1, 15);

    VerificationRequest createRequest({
      String id = 'req-1',
      String userId = 'user-1',
      VerificationType type = VerificationType.photo,
      VerificationStatus status = VerificationStatus.pending,
      String? imageUrl,
      String? documentFrontUrl,
      String? documentBackUrl,
      String? providerRef,
      String? failureReason,
      DateTime? createdAt,
      DateTime? updatedAt,
      DateTime? expiresAt,
    }) {
      return VerificationRequest(
        id: id,
        userId: userId,
        type: type,
        status: status,
        imageUrl: imageUrl,
        documentFrontUrl: documentFrontUrl,
        documentBackUrl: documentBackUrl,
        providerRef: providerRef,
        failureReason: failureReason,
        createdAt: createdAt ?? now,
        updatedAt: updatedAt,
        expiresAt: expiresAt,
      );
    }

    test('constructs with required fields', () {
      final request = createRequest();
      expect(request.id, 'req-1');
      expect(request.userId, 'user-1');
      expect(request.type, VerificationType.photo);
      expect(request.status, VerificationStatus.pending);
      expect(request.imageUrl, isNull);
      expect(request.createdAt, now);
    });

    test('constructs with all fields', () {
      final request = createRequest(
        imageUrl: 'https://example.com/selfie.jpg',
        documentFrontUrl: 'https://example.com/id-front.jpg',
        documentBackUrl: 'https://example.com/id-back.jpg',
        providerRef: 'onfido-123',
        failureReason: null,
        updatedAt: now.add(const Duration(hours: 1)),
        expiresAt: now.add(const Duration(days: 90)),
      );
      expect(request.imageUrl, 'https://example.com/selfie.jpg');
      expect(request.documentFrontUrl, 'https://example.com/id-front.jpg');
      expect(request.documentBackUrl, 'https://example.com/id-back.jpg');
      expect(request.providerRef, 'onfido-123');
    });

    test('copyWith updates fields', () {
      final original = createRequest();
      final updated = original.copyWith(
        status: VerificationStatus.verified,
        failureReason: null,
      );
      expect(updated.status, VerificationStatus.verified);
      expect(updated.id, original.id);
      expect(updated.userId, original.userId);
    });

    test('copyWith preserves unchanged fields', () {
      final original = createRequest(imageUrl: 'https://example.com/photo.jpg');
      final updated = original.copyWith(status: VerificationStatus.processing);
      expect(updated.imageUrl, 'https://example.com/photo.jpg');
    });

    test('equality works correctly', () {
      final request1 = createRequest();
      final request2 = createRequest();
      expect(request1, equals(request2));
    });

    test('inequality works correctly', () {
      final request1 = createRequest(status: VerificationStatus.pending);
      final request2 = createRequest(status: VerificationStatus.verified);
      expect(request1, isNot(equals(request2)));
    });

    test('props contains all fields', () {
      final request = createRequest();
      expect(request.props.length, 12);
    });
  });
}
