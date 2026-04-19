import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/datasources/subscription_local_data_source.dart';
import '../../data/repositories/subscription_repository_impl.dart';
import '../../domain/entities/subscription.dart';
import '../../domain/enums/feature_gate.dart';
import '../../domain/enums/subscription_tier.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../../../../features/feature_flags/feature_flag_provider.dart';

/// Billing cycle selection
enum BillingCycle { monthly, annual }

/// State for the subscription flow
class SubscriptionState {
  /// Current subscription
  final Subscription subscription;

  /// Whether an operation is in progress
  final bool isInProgress;

  /// Error message if something went wrong
  final String? error;

  /// Whether user is eligible for a free trial
  final bool isEligibleForTrial;

  /// Selected billing cycle on the paywall
  final BillingCycle selectedBillingCycle;

  /// Creates a new [SubscriptionState]
  const SubscriptionState({
    this.subscription = const Subscription(userId: ''),
    this.isInProgress = false,
    this.error,
    this.isEligibleForTrial = true,
    this.selectedBillingCycle = BillingCycle.monthly,
  });

  /// Current tier shortcut
  SubscriptionTier get tier => subscription.tier;

  /// Whether the user has premium access
  bool get isPremium => subscription.isPremium;

  /// Whether the user was previously premium (cancelled)
  bool get wasPreviouslyPremium => subscription.wasPreviouslyPremium;

  /// Copy with
  SubscriptionState copyWith({
    Subscription? subscription,
    bool? isInProgress,
    String? error,
    bool? isEligibleForTrial,
    BillingCycle? selectedBillingCycle,
  }) {
    return SubscriptionState(
      subscription: subscription ?? this.subscription,
      isInProgress: isInProgress ?? this.isInProgress,
      error: error,
      isEligibleForTrial: isEligibleForTrial ?? this.isEligibleForTrial,
      selectedBillingCycle:
          selectedBillingCycle ?? this.selectedBillingCycle,
    );
  }
}

/// Notifier managing subscription state.
///
/// Uses Riverpod 3.x Notifier pattern (NOT StateNotifier).
class SubscriptionNotifier extends Notifier<SubscriptionState> {
  @override
  SubscriptionState build() {
    // Load current subscription on init
    Future.microtask(() => _loadSubscription());
    return const SubscriptionState();
  }

  Future<void> _loadSubscription() async {
    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      final sub = await repo.getCurrentSubscription();
      final eligible = await repo.isEligibleForTrial();
      state = state.copyWith(
        subscription: sub,
        isEligibleForTrial: eligible,
      );
    } on Exception {
      // Keep default free state
    }
  }

  /// Start a free trial for Explorer
  Future<void> startFreeTrial() async {
    state = state.copyWith(isInProgress: true, error: null);
    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      final sub = await repo.startFreeTrial();
      state = state.copyWith(
        subscription: sub,
        isInProgress: false,
        isEligibleForTrial: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isInProgress: false,
        error: 'Failed to start trial: $e',
      );
    }
  }

  /// Purchase a subscription tier
  Future<void> purchaseTier(SubscriptionTier tier) async {
    state = state.copyWith(isInProgress: true, error: null);
    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      final sub = await repo.purchaseTier(tier);
      state = state.copyWith(
        subscription: sub,
        isInProgress: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isInProgress: false,
        error: 'Purchase failed: $e',
      );
    }
  }

  /// Cancel current subscription
  Future<void> cancelSubscription() async {
    state = state.copyWith(isInProgress: true, error: null);
    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      final sub = await repo.cancelSubscription();
      state = state.copyWith(
        subscription: sub,
        isInProgress: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isInProgress: false,
        error: 'Cancellation failed: $e',
      );
    }
  }

  /// Restore purchases
  Future<void> restorePurchases() async {
    state = state.copyWith(isInProgress: true, error: null);
    try {
      final repo = ref.read(subscriptionRepositoryProvider);
      final sub = await repo.restorePurchases();
      state = state.copyWith(
        subscription: sub,
        isInProgress: false,
      );
    } on Exception catch (e) {
      state = state.copyWith(
        isInProgress: false,
        error: 'Restore failed: $e',
      );
    }
  }

  /// Clear any error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Toggle billing cycle on the paywall
  void setBillingCycle(BillingCycle cycle) {
    state = state.copyWith(selectedBillingCycle: cycle);
  }

  /// Refresh subscription from source
  Future<void> refresh() async {
    await _loadSubscription();
  }
}

/// Provider for the subscription local data source
final subscriptionLocalDataSourceProvider =
    Provider<SubscriptionLocalDataSource>((ref) {
  return SubscriptionLocalDataSource();
});

/// Provider for the subscription repository
final subscriptionRepositoryProvider =
    Provider<SubscriptionRepository>((ref) {
  return SubscriptionRepositoryImpl(
    ref.read(subscriptionLocalDataSourceProvider),
  );
});

/// Provider for subscription state
final subscriptionProvider =
    NotifierProvider<SubscriptionNotifier, SubscriptionState>(
  SubscriptionNotifier.new,
);

/// Provider that checks if a feature gate blocks access.
///
/// Returns true if the user CAN access the feature (not blocked).
/// Returns false if the user is blocked (needs to upgrade).
///
/// All gates default to open (returns true) when subscription gates
/// are inactive via feature flags, or when the kill switch is active.
final canAccessFeatureProvider = Provider.family<bool, FeatureGate>((ref, gate) {
  // Kill switch: open all gates immediately
  final flags = ref.watch(featureFlagsProvider);
  if (flags.allGatesDisabled) return true;

  // Check if subscription gates are active at all
  if (!flags.subscriptionGatesActive) return true;

  // Check user's tier against required tier
  final state = ref.watch(subscriptionProvider);
  return state.tier.index >= gate.requiredTier.index;
});

/// Provider for the current subscription tier
final currentTierProvider = Provider<SubscriptionTier>((ref) {
  return ref.watch(subscriptionProvider).tier;
});
