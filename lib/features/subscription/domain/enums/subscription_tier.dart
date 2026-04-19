/// Subscription tier levels available in the app.
///
/// Only Free and Explorer are active. Adventurer and VIP are displayed
/// as "Coming Soon" in the paywall and cannot be purchased yet.
enum SubscriptionTier {
  /// Free tier — limited features
  free,

  /// Explorer — $9.99/mo, core premium features
  explorer,

  /// Adventurer — future tier, not purchasable yet
  adventurer,

  /// VIP — future tier, not purchasable yet
  vip;

  /// Human-readable label for display
  String get label => switch (this) {
        free => 'Free',
        explorer => 'Explorer',
        adventurer => 'Adventurer',
        vip => 'VIP',
      };

  /// Monthly price as a string (e.g., "\$9.99/mo")
  String get priceLabel => switch (this) {
        free => 'Free',
        explorer => '\$9.99/mo',
        adventurer => '\$24.99/mo',
        vip => '\$49.99/mo',
      };

  /// Annual price as a string (e.g., "\$59.99/yr")
  String get annualPriceLabel => switch (this) {
        free => 'Free',
        explorer => '\$59.99/yr',
        adventurer => '\$149.99/yr',
        vip => '\$299.99/yr',
      };

  /// Numeric monthly price in USD
  double get price => switch (this) {
        free => 0,
        explorer => 9.99,
        adventurer => 24.99,
        vip => 49.99,
      };

  /// Numeric annual price in USD
  double get annualPrice => switch (this) {
        free => 0,
        explorer => 59.99,
        adventurer => 149.99,
        vip => 299.99,
      };

  /// Effective monthly cost when paying annually
  String get annualEffectiveMonthly => switch (this) {
        free => 'Free',
        explorer => '~\$5/mo',
        adventurer => '~\$12.50/mo',
        vip => '~\$25/mo',
      };

  /// Annual savings percentage
  String get annualSavingsLabel => switch (this) {
        free => '',
        explorer => 'Save 50%',
        adventurer => 'Save 50%',
        vip => 'Save 50%',
      };

  /// Whether this tier can be purchased right now
  bool get isActive => this == free || this == explorer;

  /// Whether this tier shows as "Coming Soon"
  bool get isComingSoon => this == adventurer || this == vip;

  /// Short description of what the tier includes
  String get description => switch (this) {
        free => 'Basic access to get started',
        explorer => 'Full experience for solo travelers',
        adventurer => 'Power user features (coming soon)',
        vip => 'Premium everything (coming soon)',
      };

  /// Features included in this tier
  List<String> get features => switch (this) {
        free => [
            '5 matches per day',
            'Basic messaging',
            'View profiles',
            'Journal entries',
          ],
        explorer => [
            'Unlimited matches',
            'See who likes you',
            'Read receipts',
            'Passport mode',
            'Priority support',
            'Verified badge',
          ],
        adventurer => [
            'Everything in Explorer',
            'Super Connects (5/mo)',
            'Profile boosts (2/mo)',
            'Advanced filters',
            'Travel matching AI',
          ],
        vip => [
            'Everything in Adventurer',
            'Unlimited Super Connects',
            'Unlimited boosts',
            'VIP badge',
            'Dedicated support',
          ],
      };

  /// Parse from a string value (e.g., from Supabase)
  static SubscriptionTier fromString(String? value) {
    if (value == null) return free;
    return SubscriptionTier.values.firstWhere(
      (t) => t.name.toLowerCase() == value.toLowerCase(),
      orElse: () => free,
    );
  }
}
