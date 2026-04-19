import '../../domain/entities/subscription.dart';
import '../../domain/enums/subscription_tier.dart';
import '../../domain/repositories/subscription_repository.dart';
import '../datasources/subscription_local_data_source.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Implementation of [SubscriptionRepository] using local storage.
///
/// Payment SDK integration (RevenueCat / Stripe) is deferred.
/// This implementation uses SharedPreferences for state and
/// Supabase for reading the user's profile subscription field.
class SubscriptionRepositoryImpl implements SubscriptionRepository {
  final SubscriptionLocalDataSource _localDataSource;

  /// Creates a new [SubscriptionRepositoryImpl]
  SubscriptionRepositoryImpl(this._localDataSource);

  @override
  Future<Subscription> getCurrentSubscription() async {
    final user = Supabase.instance.client.auth.currentUser;
    if (user == null) {
      return Subscription.free(userId: '');
    }

    // Try to read from Supabase profile first
    try {
      final profile = await Supabase.instance.client
          .from('profiles')
          .select('subscription_tier, subscription_created_at')
          .eq('id', user.id)
          .maybeSingle();

      if (profile != null && profile['subscription_tier'] != null) {
        final tier = SubscriptionTier.fromString(
          profile['subscription_tier'] as String?,
        );

        // Also check local data for trial status
        final localData = await _localDataSource.getSubscriptionData();
        final isTrialActive = localData['is_trial_active'] as bool? ?? false;
        final trialStartStr = localData['trial_start_date'] as String?;
        final trialEndStr = localData['trial_end_date'] as String?;
        final periodEndStr = localData['current_period_end'] as String?;
        final createdAtStr = profile['subscription_created_at'] as String? ??
            localData['created_at'] as String?;
        final previousTierStr = localData['previous_tier'] as String?;

        return Subscription(
          id: user.id,
          userId: user.id,
          tier: tier,
          isTrialActive: isTrialActive,
          trialStartDate:
              trialStartStr != null ? DateTime.parse(trialStartStr) : null,
          trialEndDate:
              trialEndStr != null ? DateTime.parse(trialEndStr) : null,
          currentPeriodEnd:
              periodEndStr != null ? DateTime.parse(periodEndStr) : null,
          createdAt: createdAtStr != null
              ? DateTime.parse(createdAtStr)
              : DateTime.now(),
          platform: localData['platform'] as String?,
          autoRenew: localData['auto_renew'] as bool? ?? true,
          previousTier: previousTierStr != null
              ? SubscriptionTier.fromString(previousTierStr)
              : null,
        );
      }
    } on Exception {
      // Fall through to local data
    }

    // Fall back to local data
    final data = await _localDataSource.getSubscriptionData();
    final previousTierStr = data['previous_tier'] as String?;
    return Subscription(
      userId: user.id,
      tier: SubscriptionTier.fromString(data['tier'] as String?),
      isTrialActive: data['is_trial_active'] as bool? ?? false,
      trialStartDate: data['trial_start_date'] != null
          ? DateTime.parse(data['trial_start_date'] as String)
          : null,
      trialEndDate: data['trial_end_date'] != null
          ? DateTime.parse(data['trial_end_date'] as String)
          : null,
      currentPeriodEnd: data['current_period_end'] != null
          ? DateTime.parse(data['current_period_end'] as String)
          : null,
      createdAt: data['created_at'] != null
          ? DateTime.parse(data['created_at'] as String)
          : DateTime.now(),
      platform: data['platform'] as String?,
      autoRenew: data['auto_renew'] as bool? ?? true,
      previousTier: previousTierStr != null
          ? SubscriptionTier.fromString(previousTierStr)
          : null,
    );
  }

  @override
  Future<bool> hasTier(SubscriptionTier tier) async {
    final sub = await getCurrentSubscription();
    return sub.tier.index >= tier.index;
  }

  @override
  Future<Subscription> startFreeTrial() async {
    final user = Supabase.instance.client.auth.currentUser;
    final userId = user?.id ?? '';

    final now = DateTime.now();
    final trialEnd = now.add(const Duration(days: 7));
    final periodEnd = now.add(const Duration(days: 30));

    // Save locally
    await _localDataSource.saveSubscriptionData({
      'tier': SubscriptionTier.explorer.name,
      'is_trial_active': true,
      'trial_start_date': now.toIso8601String(),
      'trial_end_date': trialEnd.toIso8601String(),
      'current_period_end': periodEnd.toIso8601String(),
      'created_at': now.toIso8601String(),
      'auto_renew': true,
      'platform': 'trial',
    });
    await _localDataSource.markTrialUsed();

    // Update Supabase profile
    if (user != null) {
      try {
        await Supabase.instance.client.from('profiles').update({
          'subscription_tier': SubscriptionTier.explorer.name,
          'subscription_created_at': now.toIso8601String(),
        }).eq('id', userId);
      } on Exception {
        // Non-critical — local state is source of truth for now
      }
    }

    return Subscription(
      id: userId,
      userId: userId,
      tier: SubscriptionTier.explorer,
      isTrialActive: true,
      trialStartDate: now,
      trialEndDate: trialEnd,
      currentPeriodEnd: periodEnd,
      createdAt: now,
      platform: 'trial',
      autoRenew: true,
    );
  }

  @override
  Future<Subscription> purchaseTier(SubscriptionTier tier) async {
    if (!tier.isActive) {
      throw ArgumentError('Cannot purchase ${tier.label} — not yet available');
    }

    final user = Supabase.instance.client.auth.currentUser;
    final userId = user?.id ?? '';
    final now = DateTime.now();
    final periodEnd = now.add(const Duration(days: 30));

    await _localDataSource.saveSubscriptionData({
      'tier': tier.name,
      'is_trial_active': false,
      'current_period_end': periodEnd.toIso8601String(),
      'created_at': now.toIso8601String(),
      'auto_renew': true,
      'platform': 'mock',
    });

    if (user != null) {
      try {
        await Supabase.instance.client.from('profiles').update({
          'subscription_tier': tier.name,
          'subscription_created_at': now.toIso8601String(),
        }).eq('id', userId);
      } on Exception {
        // Non-critical
      }
    }

    return Subscription(
      id: userId,
      userId: userId,
      tier: tier,
      isTrialActive: false,
      currentPeriodEnd: periodEnd,
      createdAt: now,
      platform: 'mock',
      autoRenew: true,
    );
  }

  @override
  Future<Subscription> cancelSubscription() async {
    final current = await getCurrentSubscription();

    await _localDataSource.saveSubscriptionData({
      'tier': SubscriptionTier.free.name,
      'is_trial_active': false,
      'auto_renew': false,
      'previous_tier': current.tier.name,
    });

    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      try {
        await Supabase.instance.client.from('profiles').update({
          'subscription_tier': SubscriptionTier.free.name,
        }).eq('id', user.id);
      } on Exception {
        // Non-critical
      }
    }

    return current.copyWith(
      tier: SubscriptionTier.free,
      isTrialActive: false,
      autoRenew: false,
      previousTier: current.tier,
    );
  }

  @override
  Future<Subscription> restorePurchases() async {
    // In mock mode, just return current state
    return getCurrentSubscription();
  }

  @override
  Future<bool> isEligibleForTrial() async {
    return !(await _localDataSource.hasUsedTrial());
  }
}
