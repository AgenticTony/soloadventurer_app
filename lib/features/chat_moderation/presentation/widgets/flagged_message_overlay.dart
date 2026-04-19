import 'package:flutter/material.dart';
import '../../domain/entities/moderation_flag.dart';

/// Overlay widget shown on flagged messages.
///
/// Gives the recipient three options:
/// 1. View Anyway — reveals the message content
/// 2. Delete — removes the message from their view
/// 3. Report — reports to moderation team
class FlaggedMessageOverlay extends StatefulWidget {
  /// The moderation flag details
  final ModerationFlag flag;

  /// The message content (hidden until "View Anyway" is tapped)
  final String hiddenContent;

  /// Callback when user chooses to view the message
  final VoidCallback onViewAnyway;

  /// Callback when user chooses to delete the message
  final VoidCallback onDelete;

  /// Callback when user chooses to report the message
  final VoidCallback onReport;

  /// Creates a new [FlaggedMessageOverlay]
  const FlaggedMessageOverlay({
    super.key,
    required this.flag,
    required this.hiddenContent,
    required this.onViewAnyway,
    required this.onDelete,
    required this.onReport,
  });

  @override
  State<FlaggedMessageOverlay> createState() =>
      _FlaggedMessageOverlayState();
}

class _FlaggedMessageOverlayState extends State<FlaggedMessageOverlay> {
  bool _isRevealed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final category = widget.flag.category;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.orange.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.orange.withValues(alpha: 0.3),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Warning header
          Row(
            children: [
              Icon(Icons.warning_amber,
                  size: 16, color: Colors.orange.shade700),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  'This message may contain ${category.label.toLowerCase()}',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.orange.shade900,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),

          // Revealed content or placeholder
          if (_isRevealed) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.5),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                widget.hiddenContent,
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],

          const SizedBox(height: 8),

          // Action buttons
          Row(
            children: [
              if (!_isRevealed)
                Expanded(
                  child: TextButton.icon(
                    onPressed: () {
                      setState(() => _isRevealed = true);
                      widget.onViewAnyway();
                    },
                    icon: const Icon(Icons.visibility, size: 14),
                    label: const Text('View Anyway'),
                    style: TextButton.styleFrom(
                      foregroundColor: theme.colorScheme.onSurfaceVariant,
                      padding: const EdgeInsets.symmetric(vertical: 4),
                    ),
                  ),
                ),
              Expanded(
                child: TextButton.icon(
                  onPressed: widget.onDelete,
                  icon: const Icon(Icons.delete_outline, size: 14),
                  label: const Text('Delete'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
              ),
              Expanded(
                child: TextButton.icon(
                  onPressed: widget.onReport,
                  icon: const Icon(Icons.flag_outlined, size: 14),
                  label: const Text('Report'),
                  style: TextButton.styleFrom(
                    foregroundColor: theme.colorScheme.error,
                    padding: const EdgeInsets.symmetric(vertical: 4),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
