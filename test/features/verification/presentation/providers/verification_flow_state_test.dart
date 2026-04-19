import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/verification/presentation/providers/verification_providers.dart';
import 'package:soloadventurer/features/social/domain/enums/verification_tier.dart';

void main() {
  group('VerificationFlowState', () {
    test('default state is unverified and idle', () {
      const state = VerificationFlowState();
      expect(state.currentTier, VerificationTier.unverified);
      expect(state.isInProgress, isFalse);
      expect(state.activeType, isNull);
      expect(state.activeRequest, isNull);
      expect(state.error, isNull);
      expect(state.history, isEmpty);
    });

    test('canStartVerification is true when unverified and idle', () {
      const state = VerificationFlowState();
      expect(state.canStartVerification, isTrue);
    });

    test('canStartVerification is false when in progress', () {
      const state = VerificationFlowState(isInProgress: true);
      expect(state.canStartVerification, isFalse);
    });

    test('canStartVerification is false when idVerified', () {
      const state = VerificationFlowState(
        currentTier: VerificationTier.idVerified,
      );
      expect(state.canStartVerification, isFalse);
    });

    test('canStartVerification is true when emailVerified', () {
      const state = VerificationFlowState(
        currentTier: VerificationTier.emailVerified,
      );
      expect(state.canStartVerification, isTrue);
    });

    test('canDoPhotoVerification is true only when unverified', () {
      expect(
        const VerificationFlowState(
          currentTier: VerificationTier.unverified,
        ).canDoPhotoVerification,
        isTrue,
      );
      expect(
        const VerificationFlowState(
          currentTier: VerificationTier.emailVerified,
        ).canDoPhotoVerification,
        isFalse,
      );
    });

    test('canDoIdVerification is true when unverified or emailVerified', () {
      expect(
        const VerificationFlowState(
          currentTier: VerificationTier.unverified,
        ).canDoIdVerification,
        isTrue,
      );
      expect(
        const VerificationFlowState(
          currentTier: VerificationTier.emailVerified,
        ).canDoIdVerification,
        isTrue,
      );
      expect(
        const VerificationFlowState(
          currentTier: VerificationTier.idVerified,
        ).canDoIdVerification,
        isFalse,
      );
    });

    test('copyWith updates specified fields', () {
      const original = VerificationFlowState();
      final updated = original.copyWith(
        currentTier: VerificationTier.emailVerified,
        isInProgress: true,
        error: null,
      );
      expect(updated.currentTier, VerificationTier.emailVerified);
      expect(updated.isInProgress, isTrue);
      expect(updated.error, isNull);
    });

    test('copyWith preserves unspecified fields', () {
      const original = VerificationFlowState(
        currentTier: VerificationTier.emailVerified,
        history: [],
      );
      final updated = original.copyWith(isInProgress: true);
      expect(updated.currentTier, VerificationTier.emailVerified);
      expect(updated.history, isEmpty);
    });
  });
}
