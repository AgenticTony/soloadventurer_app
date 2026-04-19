import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:soloadventurer/l10n/app_localizations.dart';
import '../providers/subscription_providers.dart';
import '../../domain/enums/feature_gate.dart';

/// Utility class for checking feature gates and showing upgrade prompts.
///
/// All gates default to OPEN — nothing is blocked until
/// `subscriptionGatesActive` is set to true via feature flags.
///
/// Contextual copy is used for each gate — never generic "Upgrade to unlock."
class FeatureGateCheck {
  FeatureGateCheck._();

  /// Check if a feature is accessible for the current user.
  static bool canAccess(WidgetRef ref, FeatureGate gate) {
    return ref.read(canAccessFeatureProvider(gate));
  }

  /// Show a modal with contextual copy explaining why the feature is gated.
  static void showGateModal(BuildContext context, FeatureGate gate) {
    final theme = Theme.of(context);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            Icon(gate.showsLockIcon ? Icons.lock_outline : Icons.info_outline,
                color: theme.colorScheme.primary, size: 20),
            const SizedBox(width: 8),
            Expanded(child: Text(gate.label)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              gate.contextualCopy,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(Icons.verified_user_outlined,
                      size: 16, color: theme.colorScheme.primary),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      AppLocalizations.of(ctx)!.subGateIncluded,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: theme.colorScheme.primary,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(AppLocalizations.of(ctx)!.subGateMaybeLater),
          ),
          FilledButton(
            onPressed: () {
              Navigator.pop(ctx);
              context.push('/paywall');
            },
            child: Text(AppLocalizations.of(ctx)!.subGateCta),
          ),
        ],
      ),
    );
  }

  /// Convenience method: check gate and show modal if blocked.
  ///
  /// Returns true if the feature is accessible, false if blocked.
  static bool checkAndShow(
      BuildContext context, WidgetRef ref, FeatureGate gate) {
    if (canAccess(ref, gate)) return true;
    showGateModal(context, gate);
    return false;
  }
}
