import 'package:flutter/material.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_status.dart';

/// Icon widget displaying sync status with appropriate colors and animations
///
/// Features:
/// - State-based color coding (green=success, red=failed, blue=syncing, orange=pending, gray=idle)
/// - Animated spinning icon during sync
/// - Optional size customization
/// - Optional label display
/// - Accessibility support
class SyncOperationStatusIcon extends StatelessWidget {
  /// Current sync status
  final SyncOperationStatus status;

  /// Icon size
  final double size;

  /// Whether to show a label next to the icon
  final bool showLabel;

  /// Custom label text (overrides default status text)
  final String? customLabel;

  /// Whether to use a background circle
  final bool withBackground;

  const SyncOperationStatusIcon({
    super.key,
    required this.status,
    this.size = 24,
    this.showLabel = false,
    this.customLabel,
    this.withBackground = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (showLabel) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildIcon(theme),
          if (showLabel) ...[
            const SizedBox(width: 8),
            Text(
              customLabel ?? status.displayName,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: _getStatusColor(theme),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ],
      );
    }

    return _buildIcon(theme);
  }

  Widget _buildIcon(ThemeData theme) {
    final color = _getStatusColor(theme);
    final iconData = _getIconData();

    if (withBackground) {
      return Container(
        width: size + 16,
        height: size + 16,
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          shape: BoxShape.circle,
        ),
        child: Center(
          child: _buildIconContent(color, iconData),
        ),
      );
    }

    return _buildIconContent(color, iconData);
  }

  Widget _buildIconContent(Color color, IconData iconData) {
    if (status == SyncOperationStatus.syncing) {
      // Animated spinning icon for syncing state
      return SizedBox(
        width: size,
        height: size,
        child: TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: const Duration(seconds: 1),
          builder: (context, value, child) {
            return Transform.rotate(
              angle: value * 3.14159 * 2,
              child: Icon(
                iconData,
                color: color,
                size: size,
              ),
            );
          },
          onEnd: () {
            // Animation loops infinitely by rebuilding
            if (status == SyncOperationStatus.syncing) {
              (context as Element).markNeedsBuild();
            }
          },
        ),
      );
    }

    return Icon(
      iconData,
      color: color,
      size: size,
    );
  }

  /// Get color based on sync status
  Color _getStatusColor(ThemeData theme) {
    switch (status) {
      case SyncOperationStatus.idle:
        return theme.colorScheme.onSurfaceVariant;
      case SyncOperationStatus.syncing:
        return theme.colorScheme.primary;
      case SyncOperationStatus.success:
        return const Color(0xFF4CAF50); // Green
      case SyncOperationStatus.failed:
        return theme.colorScheme.error;
      case SyncOperationStatus.pending:
        return const Color(0xFFFF9800); // Orange
    }
  }

  /// Get icon data based on sync status
  IconData _getIconData() {
    switch (status) {
      case SyncOperationStatus.idle:
        return Icons.sync;
      case SyncOperationStatus.syncing:
        return Icons.sync;
      case SyncOperationStatus.success:
        return Icons.check_circle;
      case SyncOperationStatus.failed:
        return Icons.error;
      case SyncOperationStatus.pending:
        return Icons.schedule;
    }
  }
}

/// Small circular indicator for sync status
///
/// Shows a colored dot with optional pulsing animation for syncing state
class SyncOperationStatusIndicator extends StatelessWidget {
  /// Current sync status
  final SyncOperationStatus status;

  /// Indicator size (diameter)
  final double size;

  /// Whether to show pulsing animation when syncing
  final bool animateWhenSyncing;

  const SyncOperationStatusIndicator({
    super.key,
    required this.status,
    this.size = 12,
    this.animateWhenSyncing = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getStatusColor(theme);

    if (animateWhenSyncing && status == SyncOperationStatus.syncing) {
      return _buildPulsingIndicator(color);
    }

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
      ),
    );
  }

  Widget _buildPulsingIndicator(Color color) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0.5, end: 1.0),
      duration: const Duration(milliseconds: 800),
      curve: Curves.easeInOut,
      builder: (context, value, child) {
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: color.withOpacity(value * 0.5),
                blurRadius: size * value,
                spreadRadius: size * 0.2 * value,
              ),
            ],
          ),
        );
      },
      onEnd: () {
        // Animation loops
        if (status == SyncOperationStatus.syncing) {
          (context as Element).markNeedsBuild();
        }
      },
    );
  }

  Color _getStatusColor(ThemeData theme) {
    switch (status) {
      case SyncOperationStatus.idle:
        return theme.colorScheme.onSurfaceVariant;
      case SyncOperationStatus.syncing:
        return theme.colorScheme.primary;
      case SyncOperationStatus.success:
        return const Color(0xFF4CAF50); // Green
      case SyncOperationStatus.failed:
        return theme.colorScheme.error;
      case SyncOperationStatus.pending:
        return const Color(0xFFFF9800); // Orange
    }
  }
}
