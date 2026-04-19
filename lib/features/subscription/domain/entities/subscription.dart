import 'package:equatable/equatable.dart';
import '../enums/subscription_tier.dart';

/// Represents a user's current subscription state.
class Subscription extends Equatable {
  /// Unique ID for this subscription record
  final String? id;

  /// The user who owns this subscription
  final String userId;

  /// Current tier level
  final SubscriptionTier tier;

  /// Whether the user is in a free trial period
  final bool isTrialActive;

  /// When the trial started
  final DateTime? trialStartDate;

  /// When the trial ends (if active)
  final DateTime? trialEndDate;

  /// When the current billing period ends
  final DateTime? currentPeriodEnd;

  /// When the subscription was first created
  final DateTime? createdAt;

  /// Platform of purchase (e.g., 'apple', 'google', 'stripe', 'manual')
  final String? platform;

  /// Whether the subscription will auto-renew
  final bool autoRenew;

  /// The tier before cancellation — used for "Previously verified" status.
  /// When a user cancels Explorer, this stores their prior tier so the
  /// profile can show "Previously verified" instead of nothing.
  final SubscriptionTier? previousTier;

  /// Whether this user was previously a paid subscriber who cancelled.
  bool get wasPreviouslyPremium => previousTier != null && previousTier != SubscriptionTier.free;

  /// Creates a new [Subscription]
  const Subscription({
    this.id,
    required this.userId,
    this.tier = SubscriptionTier.free,
    this.isTrialActive = false,
    this.trialStartDate,
    this.trialEndDate,
    this.currentPeriodEnd,
    this.createdAt,
    this.platform,
    this.autoRenew = true,
    this.previousTier,
  });

  /// Whether the subscription is currently active (paid or trial)
  bool get isActive =>
      tier != SubscriptionTier.free || isTrialActive;

  /// Whether the user has premium access (paid or trialing)
  bool get isPremium =>
      tier == SubscriptionTier.explorer ||
      tier == SubscriptionTier.adventurer ||
      tier == SubscriptionTier.vip ||
      isTrialActive;

  /// Whether the free trial has expired
  bool get isTrialExpired =>
      trialEndDate != null && DateTime.now().isAfter(trialEndDate!);

  /// Days remaining in current billing period
  int? get daysRemaining {
    if (currentPeriodEnd == null) return null;
    final diff = currentPeriodEnd!.difference(DateTime.now()).inDays;
    return diff > 0 ? diff : 0;
  }

  /// Default free subscription for a new user
  factory Subscription.free({required String userId}) {
    return Subscription(
      userId: userId,
      tier: SubscriptionTier.free,
      createdAt: DateTime.now(),
    );
  }

  @override
  List<Object?> get props => [
        id,
        userId,
        tier,
        isTrialActive,
        trialStartDate,
        trialEndDate,
        currentPeriodEnd,
        createdAt,
        platform,
        autoRenew,
        previousTier,
      ];

  Subscription copyWith({
    String? id,
    String? userId,
    SubscriptionTier? tier,
    bool? isTrialActive,
    DateTime? trialStartDate,
    DateTime? trialEndDate,
    DateTime? currentPeriodEnd,
    DateTime? createdAt,
    String? platform,
    bool? autoRenew,
    SubscriptionTier? previousTier,
    bool clearPreviousTier = false,
  }) {
    return Subscription(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tier: tier ?? this.tier,
      isTrialActive: isTrialActive ?? this.isTrialActive,
      trialStartDate: trialStartDate ?? this.trialStartDate,
      trialEndDate: trialEndDate ?? this.trialEndDate,
      currentPeriodEnd: currentPeriodEnd ?? this.currentPeriodEnd,
      createdAt: createdAt ?? this.createdAt,
      platform: platform ?? this.platform,
      autoRenew: autoRenew ?? this.autoRenew,
      previousTier: clearPreviousTier ? null : (previousTier ?? this.previousTier),
    );
  }
}
