import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/l10n/app_localizations.dart';

/// Multi-signal trust display for user profiles.
///
/// Self-view shows all verification signals. Other-user view shows
/// only the ID Verified badge (if present). Never shows "Unverified"
/// or negative framing. Free users who passed photo check show no badge.
///
/// The ID Verified badge uses a reserved gold/teal accent color —
/// this is the premium visual signal and highest-ROI upgrade driver.
class TrustDisplaySection extends ConsumerWidget {
  /// Whether this is the user viewing their own profile
  final bool isSelfView;

  /// Whether the user has confirmed their email
  final bool isEmailConfirmed;

  /// Whether the user has passed the photo/liveness check
  final bool isPhotoChecked;

  /// Whether the user has completed government ID verification
  final bool isIdVerified;

  /// Whether the user was previously verified (cancelled subscription)
  final bool wasPreviouslyVerified;

  /// Profile completeness percentage (0-100)
  final int completenessPercent;

  /// Account creation date (for "New traveler" label)
  final DateTime? createdAt;

  /// Creates a new [TrustDisplaySection]
  const TrustDisplaySection({
    super.key,
    this.isSelfView = true,
    this.isEmailConfirmed = false,
    this.isPhotoChecked = false,
    this.isIdVerified = false,
    this.wasPreviouslyVerified = false,
    this.completenessPercent = 0,
    this.createdAt,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (isSelfView) {
      return _SelfViewTrustDisplay(
        isEmailConfirmed: isEmailConfirmed,
        isPhotoChecked: isPhotoChecked,
        isIdVerified: isIdVerified,
        wasPreviouslyVerified: wasPreviouslyVerified,
        completenessPercent: completenessPercent,
      );
    }
    return _OtherUserTrustDisplay(
      isIdVerified: isIdVerified,
      wasPreviouslyVerified: wasPreviouslyVerified,
      createdAt: createdAt,
    );
  }
}

// ── Self View ───────────────────────────────────────────────────────────

class _SelfViewTrustDisplay extends StatelessWidget {
  final bool isEmailConfirmed;
  final bool isPhotoChecked;
  final bool isIdVerified;
  final bool wasPreviouslyVerified;
  final int completenessPercent;

  const _SelfViewTrustDisplay({
    required this.isEmailConfirmed,
    required this.isPhotoChecked,
    required this.isIdVerified,
    required this.wasPreviouslyVerified,
    required this.completenessPercent,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = const Color(0xFFD4A74A);
    final teal = const Color(0xFF2D8B7A);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          AppLocalizations.of(context)!.subTrustTitle,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 12),

        // Signal rows
        _TrustSignalRow(
          icon: Icons.email_outlined,
          label: AppLocalizations.of(context)!.subSignalEmail,
          isComplete: isEmailConfirmed,
          completeColor: teal,
        ),
        _TrustSignalRow(
          icon: Icons.face_outlined,
          label: AppLocalizations.of(context)!.subSignalPhoto,
          isComplete: isPhotoChecked,
          completeColor: teal,
        ),
        _TrustSignalRow(
          icon: Icons.shield_outlined,
          label: AppLocalizations.of(context)!.subSignalIdVerified,
          isComplete: isIdVerified,
          completeColor: gold,
          isPremiumSignal: true,
          wasPreviouslyComplete: wasPreviouslyVerified && !isIdVerified,
        ),

        const SizedBox(height: 12),

        // Profile completeness bar
        _CompletenessBar(percent: completenessPercent),

        // Get ID Verified CTA (if not verified)
        if (!isIdVerified) ...[
          const SizedBox(height: 16),
          _GetVerifiedCta(gold: gold),
        ],
      ],
    );
  }
}

// ── Other User View ─────────────────────────────────────────────────────

class _OtherUserTrustDisplay extends StatelessWidget {
  final bool isIdVerified;
  final bool wasPreviouslyVerified;
  final DateTime? createdAt;

  const _OtherUserTrustDisplay({
    required this.isIdVerified,
    required this.wasPreviouslyVerified,
    required this.createdAt,
  });

  @override
  Widget build(BuildContext context) {
    // Show ID Verified badge if verified
    if (isIdVerified) {
      return const _IdVerifiedBadge();
    }

    // Show "Previously verified" for cancelled subscribers
    if (wasPreviouslyVerified) {
      return _PreviouslyVerifiedLabel();
    }

    // Check if new traveler (< 7 days)
    if (createdAt != null) {
      final daysSinceCreation = DateTime.now().difference(createdAt!).inDays;
      if (daysSinceCreation < 7) {
        return _NewTravelerLabel();
      }
    }

    // No badge shown — never show "Unverified"
    return const SizedBox.shrink();
  }
}

// ── Signal Row ──────────────────────────────────────────────────────────

class _TrustSignalRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isComplete;
  final Color completeColor;
  final bool isPremiumSignal;
  final bool wasPreviouslyComplete;

  const _TrustSignalRow({
    required this.icon,
    required this.label,
    required this.isComplete,
    required this.completeColor,
    this.isPremiumSignal = false,
    this.wasPreviouslyComplete = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            isComplete ? icon : Icons.circle_outlined,
            size: 18,
            color: isComplete
                ? completeColor
                : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              label,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isComplete
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                fontWeight: isPremiumSignal && isComplete
                    ? FontWeight.w700
                    : FontWeight.normal,
              ),
            ),
          ),
          if (isComplete)
            Icon(Icons.check_circle, size: 16, color: completeColor),
          if (wasPreviouslyComplete && !isComplete)
            Text(
              AppLocalizations.of(context)!.subPreviouslyVerifiedSignal,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
                fontStyle: FontStyle.italic,
              ),
            ),
        ],
      ),
    );
  }
}

// ── Completeness Bar ────────────────────────────────────────────────────

class _CompletenessBar extends StatelessWidget {
  final int percent;

  const _CompletenessBar({required this.percent});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              AppLocalizations.of(context)!.subProfileCompleteness,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            Text(
              '$percent%',
              style: theme.textTheme.labelSmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: percent / 100,
            backgroundColor: theme.colorScheme.surfaceContainerHighest,
            valueColor: AlwaysStoppedAnimation<Color>(
              percent >= 80
                  ? theme.colorScheme.primary
                  : percent >= 50
                      ? Colors.amber
                      : theme.colorScheme.error.withValues(alpha: 0.7),
            ),
            minHeight: 6,
          ),
        ),
      ],
    );
  }
}

// ── Get ID Verified CTA ─────────────────────────────────────────────────

class _GetVerifiedCta extends StatelessWidget {
  final Color gold;

  const _GetVerifiedCta({required this.gold});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            gold.withValues(alpha: 0.1),
            const Color(0xFF2D8B7A).withValues(alpha: 0.08),
          ],
        ),
        border: Border.all(color: gold.withValues(alpha: 0.25)),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [gold, const Color(0xFF2D8B7A)],
                  ),
                ),
                child: const Icon(
                  Icons.shield_outlined,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      AppLocalizations.of(context)!.subGetVerifiedCtaTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        color: gold,
                      ),
                    ),
                    Text(
                      AppLocalizations.of(context)!.subExplorer,
                      style: theme.textTheme.labelSmall?.copyWith(
                        color: gold.withValues(alpha: 0.7),
                      ),
                    ),
                  ],
                ),
              ),
              Icon(Icons.arrow_forward_ios, size: 16, color: gold),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            AppLocalizations.of(context)!.subGetVerifiedCtaDesc,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}

// ── ID Verified Badge (for other-user profiles) ─────────────────────────

class _IdVerifiedBadge extends StatelessWidget {
  const _IdVerifiedBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = const Color(0xFFD4A74A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: gold.withValues(alpha: 0.1),
        border: Border.all(color: gold.withValues(alpha: 0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.shield_outlined, size: 14, color: gold),
          const SizedBox(width: 6),
          Text(
            AppLocalizations.of(context)!.subSignalIdVerified,
            style: theme.textTheme.labelSmall?.copyWith(
              color: gold,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

// ── Previously Verified Label ────────────────────────────────────────────

class _PreviouslyVerifiedLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      ),
      child: Text(
        AppLocalizations.of(context)!.subPreviouslyVerifiedSignal,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }
}

// ── New Traveler Label ──────────────────────────────────────────────────

class _NewTravelerLabel extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.3),
      ),
      child: Text(
        AppLocalizations.of(context)!.subNewTraveler,
        style: theme.textTheme.labelSmall?.copyWith(
          color: theme.colorScheme.onSurfaceVariant,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}
