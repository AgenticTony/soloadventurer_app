import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/feature_flags/feature_flag_provider.dart';

void main() {
  group('FeatureFlags', () {
    test('defaults have all gates open (inactive)', () {
      const flags = FeatureFlags();
      expect(flags.freeTierCapsActive, isFalse);
      expect(flags.subscriptionGatesActive, isFalse);
      expect(flags.premiumFeaturesLive, isFalse);
      expect(flags.blurredLikesActive, isFalse);
      expect(flags.aiModerationActive, isFalse);
      expect(flags.shareMyMeetupActive, isTrue);
      expect(flags.verificationRequiredForMatching, isFalse);
    });

    test('default limits are reasonable', () {
      const flags = FeatureFlags();
      expect(flags.freeTierDailyLikeLimit, 100);
      expect(flags.freeTierMatchLimit, 50);
    });

    test('getFlag returns correct values', () {
      const flags = FeatureFlags(
        freeTierCapsActive: true,
        blurredLikesActive: true,
        freeTierDailyLikeLimit: 50,
      );
      expect(flags.getFlag(FeatureFlagKey.freeTierCapsActive), isTrue);
      expect(flags.getFlag(FeatureFlagKey.blurredLikesActive), isTrue);
      expect(flags.getFlag(FeatureFlagKey.subscriptionGatesActive), isFalse);
      expect(flags.getFlag(FeatureFlagKey.freeTierDailyLikeLimit), 50);
    });
  });

  group('FeatureFlagProvider', () {
    test('provider returns default flags', () {
      final container = ProviderContainer();
      final flags = container.read(featureFlagsProvider);
      expect(flags.subscriptionGatesActive, isFalse);
      container.dispose();
    });

    test('isFeatureGated returns false when subscription gates inactive', () {
      final container = ProviderContainer();
      // All gates are open by default
      final gated = container.read(isFeatureGatedProvider(FeatureFlagKey.blurredLikesActive));
      expect(gated, isFalse);
      container.dispose();
    });

    test('isFeatureGated returns false for shareMyMeetup (never gated)', () {
      final container = ProviderContainer();
      final gated = container.read(isFeatureGatedProvider(FeatureFlagKey.shareMyMeetupActive));
      expect(gated, isFalse);
      container.dispose();
    });
  });
}
