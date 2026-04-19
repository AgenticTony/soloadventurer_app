import '../entities/subscription.dart';
import '../enums/subscription_tier.dart';

/// Repository interface for subscription operations.
///
/// Actual payment SDK integration (RevenueCat / Stripe) is deferred.
/// This interface allows swapping implementations later.
abstract class SubscriptionRepository {
  /// Get the current user's subscription status
  Future<Subscription> getCurrentSubscription();

  /// Check if the user has access to a specific tier or higher
  Future<bool> hasTier(SubscriptionTier tier);

  /// Start a free trial for the Explorer tier
  ///
  /// Returns the updated subscription.
  Future<Subscription> startFreeTrial();

  /// Purchase a subscription tier
  ///
  /// [tier] must be an active (purchasable) tier.
  /// Returns the updated subscription.
  Future<Subscription> purchaseTier(SubscriptionTier tier);

  /// Cancel the current subscription
  ///
  /// The user retains access until the end of the billing period.
  Future<Subscription> cancelSubscription();

  /// Restore purchases (e.g., after reinstall)
  Future<Subscription> restorePurchases();

  /// Check if the user is eligible for a free trial
  Future<bool> isEligibleForTrial();
}
