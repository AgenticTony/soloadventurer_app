import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/subscription/domain/entities/subscription.dart';
import 'package:soloadventurer/features/subscription/domain/enums/subscription_tier.dart';

void main() {
  group('Subscription', () {
    test('default constructor has free tier', () {
      const sub = Subscription(userId: 'user1');
      expect(sub.tier, SubscriptionTier.free);
      expect(sub.isTrialActive, isFalse);
      expect(sub.autoRenew, isTrue);
      expect(sub.isPremium, isFalse);
      expect(sub.previousTier, isNull);
      expect(sub.trialStartDate, isNull);
    });

    test('free factory creates free tier', () {
      final sub = Subscription.free(userId: 'user1');
      expect(sub.tier, SubscriptionTier.free);
      expect(sub.userId, 'user1');
      expect(sub.createdAt, isNotNull);
    });

    test('isPremium is true for explorer tier', () {
      final sub = Subscription(
        userId: 'user1',
        tier: SubscriptionTier.explorer,
        createdAt: DateTime.now(),
      );
      expect(sub.isPremium, isTrue);
    });

    test('isPremium is true when trial is active even on free tier', () {
      const sub = Subscription(
        userId: 'user1',
        isTrialActive: true,
      );
      expect(sub.tier, SubscriptionTier.free);
      expect(sub.isPremium, isTrue);
    });

    test('isPremium is false for free tier without trial', () {
      const sub = Subscription(userId: 'user1');
      expect(sub.isPremium, isFalse);
    });

    test('isActive is false for free without trial', () {
      const sub = Subscription(userId: 'user1');
      expect(sub.isActive, isFalse);
    });

    test('isActive is true for explorer', () {
      final sub = Subscription(
        userId: 'user1',
        tier: SubscriptionTier.explorer,
        createdAt: DateTime.now(),
      );
      expect(sub.isActive, isTrue);
    });

    test('isActive is true when trial is active', () {
      const sub = Subscription(
        userId: 'user1',
        isTrialActive: true,
      );
      expect(sub.isActive, isTrue);
    });

    test('isTrialExpired is true when past end date', () {
      final sub = Subscription(
        userId: 'user1',
        trialEndDate: DateTime.now().subtract(const Duration(days: 1)),
      );
      expect(sub.isTrialExpired, isTrue);
    });

    test('isTrialExpired is false when trial end is in the future', () {
      final sub = Subscription(
        userId: 'user1',
        trialEndDate: DateTime.now().add(const Duration(days: 6)),
      );
      expect(sub.isTrialExpired, isFalse);
    });

    test('isTrialExpired is false when no trial end date', () {
      const sub = Subscription(userId: 'user1');
      expect(sub.isTrialExpired, isFalse);
    });

    test('daysRemaining returns null when no period end', () {
      const sub = Subscription(userId: 'user1');
      expect(sub.daysRemaining, isNull);
    });

    test('daysRemaining returns positive days', () {
      final sub = Subscription(
        userId: 'user1',
        currentPeriodEnd: DateTime.now().add(const Duration(days: 15, hours: 1)),
      );
      expect(sub.daysRemaining, greaterThanOrEqualTo(14));
    });

    test('daysRemaining returns 0 when past end', () {
      final sub = Subscription(
        userId: 'user1',
        currentPeriodEnd: DateTime.now().subtract(const Duration(days: 2)),
      );
      expect(sub.daysRemaining, 0);
    });

    test('copyWith updates specified fields', () {
      const original = Subscription(userId: 'user1');
      final updated = original.copyWith(
        tier: SubscriptionTier.explorer,
        autoRenew: false,
      );
      expect(updated.tier, SubscriptionTier.explorer);
      expect(updated.autoRenew, isFalse);
      expect(updated.userId, 'user1');
    });

    test('equality works correctly', () {
      final now = DateTime(2026, 1, 1);
      final sub1 = Subscription(
        userId: 'user1',
        tier: SubscriptionTier.explorer,
        createdAt: now,
      );
      final sub2 = Subscription(
        userId: 'user1',
        tier: SubscriptionTier.explorer,
        createdAt: now,
      );
      expect(sub1, equals(sub2));
    });

    test('inequality for different tiers', () {
      final sub1 = Subscription(
        userId: 'user1',
        tier: SubscriptionTier.free,
        createdAt: DateTime(2026, 1, 1),
      );
      final sub2 = Subscription(
        userId: 'user1',
        tier: SubscriptionTier.explorer,
        createdAt: DateTime(2026, 1, 1),
      );
      expect(sub1, isNot(equals(sub2)));
    });

    // ── Sprint 6.6 new fields ──

    test('previousTier tracks cancelled subscription tier', () {
      final sub = Subscription(
        userId: 'user1',
        tier: SubscriptionTier.free,
        previousTier: SubscriptionTier.explorer,
      );
      expect(sub.previousTier, SubscriptionTier.explorer);
      expect(sub.wasPreviouslyPremium, isTrue);
    });

    test('wasPreviouslyPremium is false when previousTier is null', () {
      const sub = Subscription(userId: 'user1');
      expect(sub.wasPreviouslyPremium, isFalse);
    });

    test('wasPreviouslyPremium is false when previousTier is free', () {
      const sub = Subscription(
        userId: 'user1',
        previousTier: SubscriptionTier.free,
      );
      expect(sub.wasPreviouslyPremium, isFalse);
    });

    test('wasPreviouslyPremium is true for adventurer previous tier', () {
      const sub = Subscription(
        userId: 'user1',
        previousTier: SubscriptionTier.adventurer,
      );
      expect(sub.wasPreviouslyPremium, isTrue);
    });

    test('trialStartDate is stored and retrieved', () {
      final start = DateTime(2026, 4, 1);
      final sub = Subscription(
        userId: 'user1',
        trialStartDate: start,
        trialEndDate: start.add(const Duration(days: 7)),
        isTrialActive: true,
      );
      expect(sub.trialStartDate, start);
      expect(sub.trialEndDate, start.add(const Duration(days: 7)));
    });

    test('copyWith preserves previousTier', () {
      const original = Subscription(
        userId: 'user1',
        previousTier: SubscriptionTier.explorer,
      );
      final updated = original.copyWith(tier: SubscriptionTier.explorer);
      expect(updated.previousTier, SubscriptionTier.explorer);
    });

    test('copyWith clearPreviousTier removes previousTier', () {
      const original = Subscription(
        userId: 'user1',
        previousTier: SubscriptionTier.explorer,
      );
      final updated = original.copyWith(clearPreviousTier: true);
      expect(updated.previousTier, isNull);
    });

    test('cancellation degradation keeps previousTier', () {
      final explorer = Subscription(
        userId: 'user1',
        tier: SubscriptionTier.explorer,
        createdAt: DateTime.now(),
      );
      final cancelled = explorer.copyWith(
        tier: SubscriptionTier.free,
        isTrialActive: false,
        autoRenew: false,
        previousTier: explorer.tier,
      );
      expect(cancelled.tier, SubscriptionTier.free);
      expect(cancelled.previousTier, SubscriptionTier.explorer);
      expect(cancelled.wasPreviouslyPremium, isTrue);
      expect(cancelled.autoRenew, isFalse);
    });

    test('equality includes new fields', () {
      final now = DateTime(2026, 1, 1);
      final sub1 = Subscription(
        userId: 'user1',
        tier: SubscriptionTier.free,
        previousTier: SubscriptionTier.explorer,
        trialStartDate: now,
        createdAt: now,
      );
      final sub2 = Subscription(
        userId: 'user1',
        tier: SubscriptionTier.free,
        previousTier: SubscriptionTier.explorer,
        trialStartDate: now,
        createdAt: now,
      );
      expect(sub1, equals(sub2));
    });
  });
}
