import 'package:flutter/material.dart';
import 'package:soloadventurer/features/social/domain/enums/verification_tier.dart';

/// Small badge widget showing a user's verification tier.
///
/// Displays a checkmark icon for emailVerified and a shield icon
/// for idVerified. Returns SizedBox.shrink() for unverified users.
class VerificationBadge extends StatelessWidget {
  /// The verification tier to display
  final VerificationTier tier;

  /// Optional size override (default: 16)
  final double size;

  /// Whether to show a background circle behind the icon
  final bool showBackground;

  /// Creates a new [VerificationBadge]
  const VerificationBadge({
    super.key,
    required this.tier,
    this.size = 16,
    this.showBackground = true,
  });

  @override
  Widget build(BuildContext context) {
    if (tier == VerificationTier.unverified) {
      return const SizedBox.shrink();
    }

    final color = tier == VerificationTier.idVerified
        ? Colors.green.shade600
        : Colors.blue.shade600;

    final icon = tier == VerificationTier.idVerified
        ? Icons.shield
        : Icons.verified;

    if (showBackground) {
      return Container(
        width: size + 4,
        height: size + 4,
        decoration: BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1.5),
        ),
        child: Icon(icon, size: size - 2, color: color),
      );
    }

    return Icon(icon, size: size, color: color);
  }
}

/// A larger verification status card for profile screens
class VerificationStatusCard extends StatelessWidget {
  /// The verification tier to display
  final VerificationTier tier;

  /// Optional callback when user taps to start verification
  final VoidCallback? onTapVerify;

  /// Creates a new [VerificationStatusCard]
  const VerificationStatusCard({
    super.key,
    required this.tier,
    this.onTapVerify,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: tier == VerificationTier.unverified
            ? theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.5)
            : Colors.green.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: tier == VerificationTier.unverified
              ? theme.colorScheme.outline.withValues(alpha: 0.2)
              : Colors.green.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (tier != VerificationTier.unverified) ...[
            Icon(
              tier == VerificationTier.idVerified ? Icons.shield : Icons.verified,
              size: 18,
              color: Colors.green.shade600,
            ),
            const SizedBox(width: 6),
            Text(
              tier == VerificationTier.idVerified
                  ? 'ID Verified'
                  : 'Photo Verified',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.green.shade700,
                fontWeight: FontWeight.w600,
              ),
            ),
          ] else ...[
            Icon(Icons.verified_outlined, size: 18, color: theme.colorScheme.onSurfaceVariant),
            const SizedBox(width: 6),
            Text(
              'Not Verified',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (onTapVerify != null) ...[
              const SizedBox(width: 4),
              InkWell(
                onTap: onTapVerify,
                child: Text(
                  'Verify Now',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ],
        ],
      ),
    );
  }
}
