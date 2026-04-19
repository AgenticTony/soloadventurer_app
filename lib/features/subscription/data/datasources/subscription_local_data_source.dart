import 'package:shared_preferences/shared_preferences.dart';

/// Local data source for subscription state.
///
/// Uses SharedPreferences for now. In production, this will be
/// replaced by RevenueCat / Stripe SDK calls.
class SubscriptionLocalDataSource {
  static const _keyTier = 'subscription_tier';
  static const _keyTrialActive = 'subscription_trial_active';
  static const _keyTrialStartDate = 'subscription_trial_start';
  static const _keyTrialEndDate = 'subscription_trial_end';
  static const _keyPeriodEnd = 'subscription_period_end';
  static const _keyCreatedAt = 'subscription_created_at';
  static const _keyAutoRenew = 'subscription_auto_renew';
  static const _keyPlatform = 'subscription_platform';
  static const _keyTrialUsed = 'subscription_trial_used';
  static const _keyPreviousTier = 'subscription_previous_tier';
  static const _keyBillingCycle = 'subscription_billing_cycle';

  /// Get stored subscription data as a map
  Future<Map<String, dynamic>> getSubscriptionData() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'tier': prefs.getString(_keyTier) ?? 'free',
      'is_trial_active': prefs.getBool(_keyTrialActive) ?? false,
      'trial_start_date': prefs.getString(_keyTrialStartDate),
      'trial_end_date': prefs.getString(_keyTrialEndDate),
      'current_period_end': prefs.getString(_keyPeriodEnd),
      'created_at': prefs.getString(_keyCreatedAt),
      'auto_renew': prefs.getBool(_keyAutoRenew) ?? true,
      'platform': prefs.getString(_keyPlatform),
      'trial_used': prefs.getBool(_keyTrialUsed) ?? false,
      'previous_tier': prefs.getString(_keyPreviousTier),
      'billing_cycle': prefs.getString(_keyBillingCycle) ?? 'monthly',
    };
  }

  /// Save subscription data locally
  Future<void> saveSubscriptionData(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    if (data['tier'] != null) {
      await prefs.setString(_keyTier, data['tier'] as String);
    }
    if (data['is_trial_active'] != null) {
      await prefs.setBool(_keyTrialActive, data['is_trial_active'] as bool);
    }
    if (data['trial_start_date'] != null) {
      await prefs.setString(
          _keyTrialStartDate, data['trial_start_date'] as String);
    }
    if (data['trial_end_date'] != null) {
      await prefs.setString(_keyTrialEndDate, data['trial_end_date'] as String);
    }
    if (data['current_period_end'] != null) {
      await prefs.setString(
          _keyPeriodEnd, data['current_period_end'] as String);
    }
    if (data['created_at'] != null) {
      await prefs.setString(_keyCreatedAt, data['created_at'] as String);
    }
    if (data['auto_renew'] != null) {
      await prefs.setBool(_keyAutoRenew, data['auto_renew'] as bool);
    }
    if (data['platform'] != null) {
      await prefs.setString(_keyPlatform, data['platform'] as String);
    }
    if (data['trial_used'] != null) {
      await prefs.setBool(_keyTrialUsed, data['trial_used'] as bool);
    }
    if (data['previous_tier'] != null) {
      await prefs.setString(_keyPreviousTier, data['previous_tier'] as String);
    }
    if (data['billing_cycle'] != null) {
      await prefs.setString(_keyBillingCycle, data['billing_cycle'] as String);
    }
  }

  /// Check if user has already used their free trial
  Future<bool> hasUsedTrial() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_keyTrialUsed) ?? false;
  }

  /// Mark trial as used
  Future<void> markTrialUsed() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_keyTrialUsed, true);
  }

  /// Clear all subscription data (for testing / reset)
  Future<void> clearSubscriptionData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyTier);
    await prefs.remove(_keyTrialActive);
    await prefs.remove(_keyTrialStartDate);
    await prefs.remove(_keyTrialEndDate);
    await prefs.remove(_keyPeriodEnd);
    await prefs.remove(_keyCreatedAt);
    await prefs.remove(_keyAutoRenew);
    await prefs.remove(_keyPlatform);
    await prefs.remove(_keyPreviousTier);
    await prefs.remove(_keyBillingCycle);
    // Don't clear trial_used — they already used it
  }
}
