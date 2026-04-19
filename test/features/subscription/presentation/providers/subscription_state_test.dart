import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/subscription/presentation/providers/subscription_providers.dart';
import 'package:soloadventurer/features/subscription/domain/enums/subscription_tier.dart';

void main() {
  group('SubscriptionState', () {
    test('default state is free and idle', () {
      const state = SubscriptionState();
      expect(state.tier, SubscriptionTier.free);
      expect(state.isInProgress, isFalse);
      expect(state.isPremium, isFalse);
      expect(state.error, isNull);
      expect(state.isEligibleForTrial, isTrue);
    });

    test('copyWith updates specified fields', () {
      const original = SubscriptionState();
      final updated = original.copyWith(
        isInProgress: true,
        error: 'Something went wrong',
      );
      expect(updated.isInProgress, isTrue);
      expect(updated.error, 'Something went wrong');
      expect(updated.tier, SubscriptionTier.free); // preserved
    });

    test('copyWith clears error when null is passed', () {
      const state = SubscriptionState(error: 'old error');
      final cleared = state.copyWith(error: null);
      expect(cleared.error, isNull);
    });

    test('isPremium reflects subscription state', () {
      const freeState = SubscriptionState();
      expect(freeState.isPremium, isFalse);
    });

    test('tier getter returns subscription tier', () {
      const state = SubscriptionState();
      expect(state.tier, SubscriptionTier.free);
    });
  });
}
