import 'package:flutter/material.dart';
import 'package:soloadventurer/l10n/app_localizations.dart';

/// Safety banner shown at the top of chat conversations.
///
/// - ID Verified user: subtle "This traveler is ID Verified" badge
/// - All users: neutral safety reminder ("meet in public places")
/// - Never shows negative/alarming banners for non-ID-verified users
///
/// Banners are informational and reinforce Pro value without shaming
/// free users or implying non-ID-verified users are unsafe.
class ChatSafetyBanner extends StatelessWidget {
  /// Whether the other user in this conversation is ID Verified
  final bool isOtherUserIdVerified;

  /// Whether the banner has been dismissed by the user
  final bool isDismissed;

  /// Callback when user dismisses the banner
  final VoidCallback? onDismiss;

  /// Creates a new [ChatSafetyBanner]
  const ChatSafetyBanner({
    super.key,
    this.isOtherUserIdVerified = false,
    this.isDismissed = false,
    this.onDismiss,
  });

  @override
  Widget build(BuildContext context) {
    if (isDismissed) return const SizedBox.shrink();

    if (isOtherUserIdVerified) {
      return _VerifiedBanner(onDismiss: onDismiss);
    }
    return _SafetyReminderBanner(onDismiss: onDismiss);
  }
}

// ── Verified Banner ─────────────────────────────────────────────────────

class _VerifiedBanner extends StatelessWidget {
  final VoidCallback? onDismiss;

  const _VerifiedBanner({this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final gold = const Color(0xFFD4A74A);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: gold.withValues(alpha: 0.08),
        border: Border(
          bottom: BorderSide(
            color: gold.withValues(alpha: 0.15),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(Icons.shield_outlined, size: 16, color: gold),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.subChatVerifiedBanner,
              style: theme.textTheme.bodySmall?.copyWith(
                color: gold,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close,
                size: 14,
                color: gold.withValues(alpha: 0.6),
              ),
            ),
        ],
      ),
    );
  }
}

// ── Safety Reminder Banner (neutral, shown to all users) ────────────────

class _SafetyReminderBanner extends StatelessWidget {
  final VoidCallback? onDismiss;

  const _SafetyReminderBanner({this.onDismiss});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        border: Border(
          bottom: BorderSide(
            color: theme.colorScheme.outline.withValues(alpha: 0.06),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.info_outline,
            size: 14,
            color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.5),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              AppLocalizations.of(context)!.subChatSafetyReminder,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.6),
              ),
            ),
          ),
          if (onDismiss != null)
            GestureDetector(
              onTap: onDismiss,
              child: Icon(
                Icons.close,
                size: 14,
                color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.3),
              ),
            ),
        ],
      ),
    );
  }
}
