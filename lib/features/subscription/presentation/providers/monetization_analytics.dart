import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/core/services/analytics_service.dart';
import 'package:soloadventurer/app/providers/analytics_provider.dart';
import '../../domain/enums/feature_gate.dart';
import '../../domain/enums/subscription_tier.dart';

/// Provider for monetization analytics tracking.
///
/// Tracks the full funnel: impression → trial → paid → retained (30/60/90 day).
final monetizationAnalyticsProvider =
    Provider<MonetizationAnalytics>((ref) {
  return MonetizationAnalytics(ref);
});

/// Analytics helper for the monetization funnel.
class MonetizationAnalytics {
  final Ref _ref;

  MonetizationAnalytics(this._ref);

  void _track(String event, {Map<String, dynamic>? props}) {
    _ref.read(analyticsServiceProvider).track(event, properties: props);
  }

  /// Track when the paywall is viewed.
  void paywallViewed({required String source}) {
    _track(AnalyticsEvents.paywallViewed, props: {'source': source});
  }

  /// Track when a CTA on the paywall is tapped.
  void paywallCtaTapped({required String tier, required String billingCycle}) {
    _track(AnalyticsEvents.paywallCtaTapped, props: {
      'tier': tier,
      'billing_cycle': billingCycle,
    });
  }

  /// Track when a free trial starts.
  void trialStarted({required SubscriptionTier tier}) {
    _track(AnalyticsEvents.trialStarted, props: {'tier': tier.name});
  }

  /// Track when a trial ends.
  void trialEnded({required SubscriptionTier tier, required bool converted}) {
    _track(AnalyticsEvents.trialEnded, props: {
      'tier': tier.name,
      'converted': converted,
    });
  }

  /// Track when a trial converts to paid.
  void trialConverted({required SubscriptionTier tier}) {
    _track(AnalyticsEvents.trialConverted, props: {'tier': tier.name});
  }

  /// Track when a subscription is started.
  void subscriptionStarted({
    required SubscriptionTier tier,
    required String billingCycle,
  }) {
    _track(AnalyticsEvents.subscriptionStarted, props: {
      'tier': tier.name,
      'billing_cycle': billingCycle,
    });
  }

  /// Track when a subscription is cancelled.
  void subscriptionCancelled({
    required SubscriptionTier previousTier,
    String? cancelReason,
  }) {
    _track(AnalyticsEvents.subscriptionCancelled, props: {
      'previous_tier': previousTier.name,
      if (cancelReason != null) 'cancel_reason': cancelReason,
    });
  }

  /// Track when a subscription renews.
  void subscriptionRenewed({required SubscriptionTier tier}) {
    _track(AnalyticsEvents.subscriptionRenewed, props: {'tier': tier.name});
  }

  /// Track when a feature gate blocks a user.
  void featureGateBlocked({
    required FeatureGate gate,
    required SubscriptionTier userTier,
  }) {
    _track(AnalyticsEvents.featureGateBlocked, props: {
      'gate': gate.name,
      'user_tier': userTier.name,
    });
  }

  /// Track when connection requests are viewed (blurred vs revealed).
  void connectionRequestsViewed({required bool isBlurred, required int count}) {
    _track(AnalyticsEvents.connectionRequestsViewed, props: {
      'is_blurred': isBlurred,
      'count': count,
    });
  }

  /// Track when the verified-only filter is toggled.
  void verifiedFilterToggled({
    required bool enabled,
    required SubscriptionTier userTier,
  }) {
    _track(AnalyticsEvents.verifiedFilterToggled, props: {
      'enabled': enabled,
      'user_tier': userTier.name,
    });
  }

  /// Track when a user hits the daily message cap.
  void dailyMessageCapReached({required int messageCount}) {
    _track(AnalyticsEvents.dailyMessageCapReached, props: {
      'message_count': messageCount,
    });
  }

  /// Track when a user taps "Notify me" on a Coming Soon tier.
  void notifyMeTapped({required SubscriptionTier tier}) {
    _track(AnalyticsEvents.notifyMeTapped, props: {'tier': tier.name});
  }
}
