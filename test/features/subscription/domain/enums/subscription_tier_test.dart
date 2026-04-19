import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/subscription/domain/enums/subscription_tier.dart';

void main() {
  group('SubscriptionTier', () {
    test('has all four tiers', () {
      expect(SubscriptionTier.values.length, 4);
      expect(SubscriptionTier.values, contains(SubscriptionTier.free));
      expect(SubscriptionTier.values, contains(SubscriptionTier.explorer));
      expect(SubscriptionTier.values, contains(SubscriptionTier.adventurer));
      expect(SubscriptionTier.values, contains(SubscriptionTier.vip));
    });

    test('labels are correct', () {
      expect(SubscriptionTier.free.label, 'Free');
      expect(SubscriptionTier.explorer.label, 'Explorer');
      expect(SubscriptionTier.adventurer.label, 'Adventurer');
      expect(SubscriptionTier.vip.label, 'VIP');
    });

    test('monthly price labels are correct', () {
      expect(SubscriptionTier.free.priceLabel, 'Free');
      expect(SubscriptionTier.explorer.priceLabel, '\$9.99/mo');
      expect(SubscriptionTier.adventurer.priceLabel, '\$24.99/mo');
      expect(SubscriptionTier.vip.priceLabel, '\$49.99/mo');
    });

    test('annual price labels are correct', () {
      expect(SubscriptionTier.free.annualPriceLabel, 'Free');
      expect(SubscriptionTier.explorer.annualPriceLabel, '\$59.99/yr');
      expect(SubscriptionTier.adventurer.annualPriceLabel, '\$149.99/yr');
      expect(SubscriptionTier.vip.annualPriceLabel, '\$299.99/yr');
    });

    test('monthly prices are correct', () {
      expect(SubscriptionTier.free.price, 0);
      expect(SubscriptionTier.explorer.price, 9.99);
      expect(SubscriptionTier.adventurer.price, 24.99);
      expect(SubscriptionTier.vip.price, 49.99);
    });

    test('annual prices are correct', () {
      expect(SubscriptionTier.free.annualPrice, 0);
      expect(SubscriptionTier.explorer.annualPrice, 59.99);
      expect(SubscriptionTier.adventurer.annualPrice, 149.99);
      expect(SubscriptionTier.vip.annualPrice, 299.99);
    });

    test('annual effective monthly cost is correct', () {
      expect(SubscriptionTier.explorer.annualEffectiveMonthly, '~\$5/mo');
    });

    test('annual savings label exists for paid tiers', () {
      expect(SubscriptionTier.free.annualSavingsLabel, isEmpty);
      expect(SubscriptionTier.explorer.annualSavingsLabel, 'Save 50%');
    });

    test('annual pricing is cheaper than monthly (Apple requirement)', () {
      for (final tier in SubscriptionTier.values) {
        if (tier.price > 0) {
          expect(tier.annualPrice, lessThan(tier.price * 12),
              reason: '${tier.label} annual must be < 12x monthly');
        }
      }
    });

    test('only free and explorer are active', () {
      expect(SubscriptionTier.free.isActive, isTrue);
      expect(SubscriptionTier.explorer.isActive, isTrue);
      expect(SubscriptionTier.adventurer.isActive, isFalse);
      expect(SubscriptionTier.vip.isActive, isFalse);
    });

    test('adventurer and vip are coming soon', () {
      expect(SubscriptionTier.free.isComingSoon, isFalse);
      expect(SubscriptionTier.explorer.isComingSoon, isFalse);
      expect(SubscriptionTier.adventurer.isComingSoon, isTrue);
      expect(SubscriptionTier.vip.isComingSoon, isTrue);
    });

    test('fromString parses correctly', () {
      expect(SubscriptionTier.fromString('free'), SubscriptionTier.free);
      expect(
          SubscriptionTier.fromString('explorer'), SubscriptionTier.explorer);
      expect(
          SubscriptionTier.fromString('EXPLORER'), SubscriptionTier.explorer);
      expect(SubscriptionTier.fromString('adventurer'),
          SubscriptionTier.adventurer);
      expect(SubscriptionTier.fromString('vip'), SubscriptionTier.vip);
    });

    test('fromString returns free for null or unknown', () {
      expect(SubscriptionTier.fromString(null), SubscriptionTier.free);
      expect(SubscriptionTier.fromString('unknown'), SubscriptionTier.free);
      expect(SubscriptionTier.fromString(''), SubscriptionTier.free);
    });

    test('features are non-empty for all tiers', () {
      for (final tier in SubscriptionTier.values) {
        expect(tier.features, isNotEmpty,
            reason: '${tier.label} should have features');
      }
    });

    test('descriptions are non-empty', () {
      for (final tier in SubscriptionTier.values) {
        expect(tier.description, isNotEmpty);
      }
    });
  });
}
