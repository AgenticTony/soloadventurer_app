import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Feature flag keys used throughout the app.
///
/// These flags control which premium/subscription features are active.
/// All flags default to true (open) so nothing is blocked until explicitly
/// activated via the admin config.
enum FeatureFlagKey {
  /// Whether free tier caps on likes/matches are enforced
  freeTierCapsActive,

  /// Whether subscription-based feature gates are enforced
  subscriptionGatesActive,

  /// Whether premium features (boost, super connect, etc.) are live
  premiumFeaturesLive,

  /// Whether the blurred likes grid is active for free users
  blurredLikesActive,

  /// Whether AI message moderation is active
  aiModerationActive,

  /// Whether Share My Meetup is available
  shareMyMeetupActive,

  /// Whether verification is required to use matching
  verificationRequiredForMatching,

  /// Maximum likes per day for free users (when freeTierCapsActive is true)
  freeTierDailyLikeLimit,

  /// Maximum matches visible for free users (when freeTierCapsActive is true)
  freeTierMatchLimit,
}

/// Feature flag configuration with defaults.
///
/// All flags default to false/inactive — meaning features are OPEN.
/// This lets us ship everything open and activate limits later via
/// Supabase config or remote config without a new app release.
class FeatureFlags {
  /// Whether free tier caps are enforced
  final bool freeTierCapsActive;

  /// Whether subscription gates are enforced
  final bool subscriptionGatesActive;

  /// Whether premium features are live
  final bool premiumFeaturesLive;

  /// Whether blurred likes is active for free users
  final bool blurredLikesActive;

  /// Whether AI moderation is active
  final bool aiModerationActive;

  /// Whether Share My Meetup is available
  final bool shareMyMeetupActive;

  /// Whether verification is required for matching
  final bool verificationRequiredForMatching;

  /// Maximum likes per day for free tier
  final int freeTierDailyLikeLimit;

  /// Maximum matches visible for free tier
  final int freeTierMatchLimit;

  /// Maximum messages per day for free tier
  final int freeTierDailyMessageLimit;

  /// Kill switch — when true, all gates open immediately (< 60s rollback)
  final bool deactivateAllGates;

  /// Creates a new [FeatureFlags]
  const FeatureFlags({
    this.freeTierCapsActive = false,
    this.subscriptionGatesActive = false,
    this.premiumFeaturesLive = false,
    this.blurredLikesActive = false,
    this.aiModerationActive = false,
    this.shareMyMeetupActive = true,
    this.verificationRequiredForMatching = false,
    this.freeTierDailyLikeLimit = 100,
    this.freeTierMatchLimit = 50,
    this.freeTierDailyMessageLimit = 5,
    this.deactivateAllGates = false,
  });

  /// Get a flag value by key
  dynamic getFlag(FeatureFlagKey key) {
    switch (key) {
      case FeatureFlagKey.freeTierCapsActive:
        return freeTierCapsActive;
      case FeatureFlagKey.subscriptionGatesActive:
        return subscriptionGatesActive;
      case FeatureFlagKey.premiumFeaturesLive:
        return premiumFeaturesLive;
      case FeatureFlagKey.blurredLikesActive:
        return blurredLikesActive;
      case FeatureFlagKey.aiModerationActive:
        return aiModerationActive;
      case FeatureFlagKey.shareMyMeetupActive:
        return shareMyMeetupActive;
      case FeatureFlagKey.verificationRequiredForMatching:
        return verificationRequiredForMatching;
      case FeatureFlagKey.freeTierDailyLikeLimit:
        return freeTierDailyLikeLimit;
      case FeatureFlagKey.freeTierMatchLimit:
        return freeTierMatchLimit;
    }
  }

  /// Whether all gates should be opened (kill switch active)
  bool get allGatesDisabled => deactivateAllGates;
}

/// Provider for feature flags.
///
/// Currently uses local defaults. Can be upgraded to read from
/// Supabase `feature_flags` table or a remote config service.
///
/// All flags default to inactive/open — nothing is blocked.
final featureFlagsProvider = Provider<FeatureFlags>((ref) {
  // TODO: Upgrade to read from Supabase `feature_flags` table
  // Example:
  // final supabase = ref.read(supabaseServiceProvider);
  // final flags = await supabase.client.from('feature_flags').select().single();
  // return FeatureFlags.fromJson(flags);

  return const FeatureFlags();
});

/// Convenience provider to check if a specific feature gate is active.
///
/// Returns true if the gate is active AND subscription gates are enabled.
/// Returns false (gate open) if either condition is false.
final isFeatureGatedProvider = Provider.family<bool, FeatureFlagKey>((ref, key) {
  final flags = ref.watch(featureFlagsProvider);

  // If subscription gates aren't active at all, nothing is gated
  if (!flags.subscriptionGatesActive) return false;

  // Check the specific flag
  switch (key) {
    case FeatureFlagKey.freeTierCapsActive:
      return flags.freeTierCapsActive;
    case FeatureFlagKey.blurredLikesActive:
      return flags.blurredLikesActive;
    case FeatureFlagKey.premiumFeaturesLive:
      return flags.premiumFeaturesLive;
    case FeatureFlagKey.aiModerationActive:
      return flags.aiModerationActive;
    case FeatureFlagKey.shareMyMeetupActive:
      return false; // Share My Meetup is never gated
    case FeatureFlagKey.verificationRequiredForMatching:
      return flags.verificationRequiredForMatching;
    case FeatureFlagKey.subscriptionGatesActive:
      return flags.subscriptionGatesActive;
    case FeatureFlagKey.freeTierDailyLikeLimit:
      return flags.freeTierCapsActive;
    case FeatureFlagKey.freeTierMatchLimit:
      return flags.freeTierCapsActive;
  }
});
