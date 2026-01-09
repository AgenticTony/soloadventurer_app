import 'package:flutter/material.dart';

/// Badge widget for displaying pending sync operation count
///
/// Features:
/// - Shows count in circular badge
/// - Hides when count is 0 (optional)
/// - Customizable colors and size
/// - Supports custom child widget
/// - Animated count changes
class SyncStatusBadge extends StatelessWidget {
  /// Number of pending operations
  final int count;

  /// Badge size
  final double size;

  /// Whether to hide badge when count is 0
  final bool hideWhenZero;

  /// Custom color for the badge
  final Color? color;

  /// Custom text color for the count
  final Color? textColor;

  /// Child widget to display badge on (typically an icon)
  final Widget? child;

  /// Position offset for the badge
  final Offset offset;

  const SyncStatusBadge({
    super.key,
    required this.count,
    this.size = 18,
    this.hideWhenZero = false,
    this.color,
    this.textColor,
    this.child,
    this.offset = const Offset(-4, 4),
  });

  @override
  Widget build(BuildContext context) {
    // Hide badge if count is 0 and hideWhenZero is true
    if (hideWhenZero && count == 0) {
      return child ?? const SizedBox.shrink();
    }

    // If no child provided, just show the badge
    if (child == null) {
      return _buildBadge(context);
    }

    // Show badge positioned on child
    return Stack(
      clipBehavior: Clip.none,
      children: [
        child!,
        Positioned(
          right: offset.dx,
          top: offset.dy,
          child: _buildBadge(context),
        ),
      ],
    );
  }

  Widget _buildBadge(BuildContext context) {
    final theme = Theme.of(context);
    final badgeColor = color ?? theme.colorScheme.error;
    final badgeTextColor = textColor ?? theme.colorScheme.onError;

    // Determine display text
    final displayText = _getDisplayText();

    // Calculate badge size based on text length
    final badgeWidth = _calculateBadgeWidth(displayText);

    return Container(
      width: badgeWidth,
      height: size,
      decoration: BoxDecoration(
        color: badgeColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: theme.colorScheme.surface,
          width: 1.5,
        ),
      ),
      child: Center(
        child: Text(
          displayText,
          style: theme.textTheme.labelSmall?.copyWith(
            color: badgeTextColor,
            fontSize: _calculateFontSize(displayText),
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  /// Get the text to display in the badge
  String _getDisplayText() {
    if (count > 99) {
      return '99+';
    }
    return count.toString();
  }

  /// Calculate badge width based on text length
  double _calculateBadgeWidth(String text) {
    final baseWidth = size;
    if (text.length == 1) {
      return baseWidth;
    } else if (text.length == 2) {
      return baseWidth + 4;
    } else if (text.length == 3) {
      return baseWidth + 8;
    }
    return baseWidth + 12;
  }

  /// Calculate font size based on text length
  double _calculateFontSize(String text) {
    if (text.length <= 2) {
      return size * 0.5;
    } else if (text.length == 3) {
      return size * 0.4;
    }
    return size * 0.35;
  }
}

/// Badge widget for displaying sync status with optional count
///
/// Combines status indicator with count badge
class SyncStatusBadgeWithIndicator extends StatelessWidget {
  /// Number of pending operations
  final int count;

  /// Badge size
  final double size;

  /// Whether to hide badge when count is 0
  final bool hideWhenZero;

  /// Custom color for the badge
  final Color? color;

  const SyncStatusBadgeWithIndicator({
    super.key,
    required this.count,
    this.size = 18,
    this.hideWhenZero = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final badgeColor = color ?? theme.colorScheme.error;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: badgeColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: badgeColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (count > 0) ...[
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: badgeColor,
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(
                  count > 99 ? '99+' : count.toString(),
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onError,
                    fontSize: size * 0.5,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            count == 1 ? '1 pending item' : '$count pending items',
            style: theme.textTheme.bodySmall?.copyWith(
              color: badgeColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
