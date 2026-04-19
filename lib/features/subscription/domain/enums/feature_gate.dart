import 'subscription_tier.dart';

/// Features that can be gated behind subscription tiers.
///
/// Each gate defines what's required to access a feature.
/// The actual enforcement is controlled by feature flags — all gates
/// default to open so nothing is blocked until explicitly activated.
///
/// Contextual copy is travel-appropriate and safety-led, never generic
/// "Upgrade to unlock" messaging.
enum FeatureGate {
  // ── Connection & Discovery ──
  /// See who has sent connection requests (blurred grid)
  connectionRequests,

  /// Unlimited daily matches (free tier has a cap)
  unlimitedMatches,

  /// Change your location to match in other cities
  passportMode,

  /// Boost your profile visibility
  boost,

  /// See when messages have been read
  readReceipts,

  /// Send a guaranteed notification to another user
  superConnect,

  // ── Safety & Verification ──
  /// Filter to show only ID-verified travelers
  verifiedFilter,

  /// Guardian Pro: multiple emergency contacts + location sharing
  guardianPro,

  /// ID Verification via government ID
  idVerification,

  // ── Advanced Filtering ──
  /// Advanced filters: age, gender, language, travel dates
  advancedFilters,

  // ── Messaging ──
  /// Daily message cap enforcement (5/day free)
  dailyMessages;

  /// Human-readable label for display
  String get label => switch (this) {
        connectionRequests => 'See Who Wants to Connect',
        unlimitedMatches => 'Unlimited Matches',
        passportMode => 'Passport Mode',
        boost => 'Profile Boost',
        readReceipts => 'Read Receipts',
        superConnect => 'Super Connect',
        verifiedFilter => 'ID Verified-Only Filter',
        guardianPro => 'Guardian Pro',
        idVerification => 'ID Verification',
        advancedFilters => 'Advanced Filters',
        dailyMessages => 'Unlimited Messages',
      };

  /// Short description shown in paywall / gate modal
  String get description => switch (this) {
        connectionRequests =>
          'See everyone who wants to travel with you',
        unlimitedMatches =>
          'Match with unlimited people every day',
        passportMode =>
          'Change your location to match anywhere',
        boost =>
          'Get your profile seen by more people',
        readReceipts =>
          'Know when your messages have been read',
        superConnect =>
          'Send a guaranteed notification to someone',
        verifiedFilter =>
          'Connect only with ID-verified travelers',
        guardianPro =>
          'Add more emergency contacts and share your location',
        idVerification =>
          'Verify your government ID — show travelers you\'re the real deal',
        advancedFilters =>
          'Filter by age, language, and more',
        dailyMessages =>
          'Send more messages every day',
      };

  /// Contextual copy shown when this gate blocks a specific action.
  /// Each trigger has unique copy tied to the user's intent.
  String get contextualCopy => switch (this) {
        connectionRequests =>
          'See who wants to travel with you — start your free trial',
        unlimitedMatches =>
          'Connect with unlimited travelers — unlock with Explorer',
        passportMode =>
          'Match anywhere in the world — unlock with Explorer',
        boost =>
          'Get seen by more travelers nearby — coming soon',
        readReceipts =>
          'See when your messages are read — unlock with Explorer',
        superConnect =>
          'Send a guaranteed notification — unlock with Explorer',
        verifiedFilter =>
          'Connect only with ID-verified travelers — upgrade for peace of mind',
        guardianPro =>
          'Add more emergency contacts and share your location — unlock with Explorer',
        idVerification =>
          'Verify your government ID — show travelers you\'re the real deal. Included with Explorer.',
        advancedFilters =>
          'Filter by age, language, and more — unlock with Explorer',
        dailyMessages =>
          'You\'ve sent 5 messages today — keep connecting with Explorer',
      };

  /// Minimum tier required to access this feature
  SubscriptionTier get requiredTier => switch (this) {
        connectionRequests => SubscriptionTier.explorer,
        unlimitedMatches => SubscriptionTier.explorer,
        passportMode => SubscriptionTier.explorer,
        boost => SubscriptionTier.explorer,
        readReceipts => SubscriptionTier.explorer,
        superConnect => SubscriptionTier.explorer,
        verifiedFilter => SubscriptionTier.explorer,
        guardianPro => SubscriptionTier.explorer,
        idVerification => SubscriptionTier.explorer,
        advancedFilters => SubscriptionTier.explorer,
        dailyMessages => SubscriptionTier.explorer,
      };

  /// Icon representing this feature
  String get iconName => switch (this) {
        connectionRequests => 'people',
        unlimitedMatches => 'connect_without_contact',
        passportMode => 'flight',
        boost => 'rocket_launch',
        readReceipts => 'done_all',
        superConnect => 'bolt',
        verifiedFilter => 'verified',
        guardianPro => 'security',
        idVerification => 'badge',
        advancedFilters => 'tune',
        dailyMessages => 'chat',
      };

  /// Whether this feature shows a lock icon for free users
  bool get showsLockIcon => switch (this) {
        verifiedFilter => true,
        connectionRequests => true,
        dailyMessages => true,
        _ => false,
      };
}
