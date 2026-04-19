import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloadventurer/l10n/app_localizations.dart';
import '../providers/subscription_providers.dart';
import '../../domain/enums/subscription_tier.dart';

/// Screen for managing the current subscription.
///
/// Shows current plan details, billing info, and options to
/// change or cancel the subscription. Cancellation is frictionless:
/// single confirmation, optional exit survey, no dark patterns.
class SubscriptionManagementScreen extends ConsumerStatefulWidget {
  /// Route name for navigation
  static const routeName = '/subscription/manage';

  /// Creates a new [SubscriptionManagementScreen]
  const SubscriptionManagementScreen({super.key});

  @override
  ConsumerState<SubscriptionManagementScreen> createState() =>
      _SubscriptionManagementScreenState();
}

class _SubscriptionManagementScreenState
    extends ConsumerState<SubscriptionManagementScreen> {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final state = ref.watch(subscriptionProvider);
    final sub = state.subscription;
    final tier = sub.tier;

    ref.listen<SubscriptionState>(subscriptionProvider, (prev, next) {
      if (next.error != null && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: theme.colorScheme.error,
          ),
        );
        ref.read(subscriptionProvider.notifier).clearError();
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: Text(AppLocalizations.of(context)!.subManageTitle),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildCurrentPlanCard(context, tier, sub),
            const SizedBox(height: 24),
            _buildBillingInfo(context, sub, state),
            const SizedBox(height: 24),
            _buildFeatureList(context, tier),
            const SizedBox(height: 32),
            _buildActions(context, state, tier),
          ],
        ),
      ),
    );
  }

  Widget _buildCurrentPlanCard(
      BuildContext context, SubscriptionTier tier, sub) {
    final theme = Theme.of(context);
    final isPremium = tier != SubscriptionTier.free;
    final gold = const Color(0xFFD4A74A);

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: isPremium
            ? LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  gold.withValues(alpha: 0.15),
                  gold.withValues(alpha: 0.1),
                ],
              )
            : null,
        color: isPremium
            ? null
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border.all(
          color: isPremium
              ? gold.withValues(alpha: 0.3)
              : theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        children: [
          Icon(
            isPremium ? Icons.explore : Icons.person_outline,
            size: 48,
            color: isPremium
                ? gold
                : theme.colorScheme.onSurface.withValues(alpha: 0.4),
          ),
          const SizedBox(height: 12),
          Text(
            tier.label,
            style: theme.textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            tier.priceLabel,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          if (sub.isTrialActive) ...[
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: gold.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                AppLocalizations.of(context)!.subFreeTrialActive,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: gold,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
          if (sub.wasPreviouslyPremium && tier == SubscriptionTier.free) ...[
            const SizedBox(height: 8),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Text(
                AppLocalizations.of(context)!.subPreviouslyVerified,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBillingInfo(
      BuildContext context, sub, SubscriptionState state) {

    return _buildSection(
      context,
      title: AppLocalizations.of(context)!.subBilling,
      children: [
        _buildInfoRow(
          context,
          AppLocalizations.of(context)!.subStatus,
          sub.isPremium
              ? AppLocalizations.of(context)!.subStatusActive
              : AppLocalizations.of(context)!.subStatusFree,
        ),
        if (sub.currentPeriodEnd != null)
          _buildInfoRow(
            context,
            AppLocalizations.of(context)!.subNextRenewal,
            _formatDate(sub.currentPeriodEnd!),
          ),
        if (sub.isTrialActive && sub.trialEndDate != null)
          _buildInfoRow(
            context,
            AppLocalizations.of(context)!.subTrialEnds,
            _formatDate(sub.trialEndDate!),
          ),
        if (sub.trialStartDate != null)
          _buildInfoRow(
            context,
            AppLocalizations.of(context)!.subTrialStarted,
            _formatDate(sub.trialStartDate!),
          ),
        _buildInfoRow(
          context,
          AppLocalizations.of(context)!.subBillingCycle,
          state.selectedBillingCycle == BillingCycle.annual
              ? AppLocalizations.of(context)!.subAnnual
              : AppLocalizations.of(context)!.subMonthly,
        ),
        _buildInfoRow(
          context,
          AppLocalizations.of(context)!.subAutoRenew,
          sub.autoRenew
              ? AppLocalizations.of(context)!.subOn
              : AppLocalizations.of(context)!.subOff,
        ),
        if (sub.platform != null)
          _buildInfoRow(
            context,
            AppLocalizations.of(context)!.subPlatform,
            sub.platform!,
          ),
        _buildInfoRow(
          context,
          AppLocalizations.of(context)!.subPrice,
          state.selectedBillingCycle == BillingCycle.annual
              ? SubscriptionTier.explorer.annualPriceLabel
              : SubscriptionTier.explorer.priceLabel,
        ),
      ],
    );
  }

  Widget _buildFeatureList(BuildContext context, SubscriptionTier tier) {
    final theme = Theme.of(context);
    return _buildSection(
      context,
      title: AppLocalizations.of(context)!.subIncludedFeatures,
      children: tier.features
          .map((f) => Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        size: 16, color: theme.colorScheme.primary),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        f,
                        style: theme.textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ))
          .toList(),
    );
  }

  Widget _buildActions(
      BuildContext context, SubscriptionState state, SubscriptionTier tier) {
    final theme = Theme.of(context);
    final isPremium = tier != SubscriptionTier.free;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!isPremium) ...[
          ElevatedButton(
            onPressed: state.isInProgress
                ? null
                : () => context.push('/paywall'),
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.subGetVerifiedCta),
          ),
        ] else ...[
          OutlinedButton(
            onPressed: state.isInProgress
                ? null
                : () => context.push('/paywall'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: Text(AppLocalizations.of(context)!.subChangePlan),
          ),
          const SizedBox(height: 12),
          OutlinedButton(
            onPressed: state.isInProgress ? null : _showCancelDialog,
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 14),
              foregroundColor: theme.colorScheme.error,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            child: state.isInProgress
                ? const SizedBox(
                    height: 18,
                    width: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(AppLocalizations.of(context)!.subCancelSubscription),
          ),
        ],
        const SizedBox(height: 16),
        TextButton(
          onPressed: state.isInProgress
              ? null
              : () async {
                  await ref
                      .read(subscriptionProvider.notifier)
                      .restorePurchases();
                  if (!context.mounted) return;
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(AppLocalizations.of(context)!.subPurchasesRestored),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                },
          child: Text(AppLocalizations.of(context)!.subRestorePurchases),
        ),
      ],
    );
  }

  Widget _buildSection(BuildContext context,
      {required String title, required List<Widget> children}) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Text(
            title,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color:
                theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.2),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildInfoRow(BuildContext context, String label, String value) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }

  void _showCancelDialog() {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(AppLocalizations.of(context)!.subCancelTitle),
        content: Text(
          AppLocalizations.of(context)!.subCancelBody,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(context)!.subKeepSubscription),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showExitSurvey();
            },
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
            ),
            child: Text(AppLocalizations.of(context)!.subContinueToCancel),
          ),
        ],
      ),
    );
  }

  void _showExitSurvey() {
    final theme = Theme.of(context);
    final reasons = [
      AppLocalizations.of(context)!.subCancelReasonExpensive,
      AppLocalizations.of(context)!.subCancelReasonNotUsing,
      AppLocalizations.of(context)!.subCancelReasonAlternative,
      AppLocalizations.of(context)!.subCancelReasonPrivacy,
      AppLocalizations.of(context)!.subCancelReasonTechnical,
    ];
    String? selectedReason;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setState) => AlertDialog(
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16)),
          title: Text(AppLocalizations.of(context)!.subExitSurveyTitle),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                AppLocalizations.of(context)!.subExitSurveyOptional,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              RadioGroup<String>(
                groupValue: selectedReason,
                onChanged: (v) => setState(() => selectedReason = v),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: reasons
                      .map((reason) => RadioListTile<String>(
                            title: Text(reason),
                            value: reason,
                            contentPadding: EdgeInsets.zero,
                            dense: true,
                          ))
                      .toList(),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(ctx);
                // Cancel without survey answer
                ref
                    .read(subscriptionProvider.notifier)
                    .cancelSubscription();
              },
              child: Text(AppLocalizations.of(context)!.subSkip),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(ctx);
                ref
                    .read(subscriptionProvider.notifier)
                    .cancelSubscription();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                        AppLocalizations.of(context)!.subCancelledConfirmation),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              },
              style: FilledButton.styleFrom(
                backgroundColor: theme.colorScheme.error,
              ),
              child: Text(AppLocalizations.of(context)!.subConfirmCancel),
            ),
          ],
        ),
      ),
    );
  }
}
