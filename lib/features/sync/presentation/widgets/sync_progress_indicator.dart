import 'package:flutter/material.dart';

/// Linear progress bar for sync operations
///
/// Features:
/// - Shows progress with percentage
/// - Customizable colors and height
/// - Optional label display
/// - Animated progress changes
/// - Indeterminate mode for unknown progress
class SyncProgressBar extends StatelessWidget {
  /// Progress value (0.0 to 1.0)
  final double? progress;

  /// Whether to show indeterminate progress
  final bool isIndeterminate;

  /// Height of the progress bar
  final double height;

  /// Custom color for the progress bar
  final Color? color;

  /// Background color of the progress track
  final Color? backgroundColor;

  /// Whether to show percentage label
  final bool showPercentage;

  /// Custom label text
  final String? label;

  /// Whether to show animation
  final bool animate;

  const SyncProgressBar({
    super.key,
    this.progress,
    this.isIndeterminate = false,
    this.height = 4,
    this.color,
    this.backgroundColor,
    this.showPercentage = false,
    this.label,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = color ?? theme.colorScheme.primary;
    final trackColor = backgroundColor ?? theme.colorScheme.surfaceVariant;

    Widget progressBar;

    if (isIndeterminate || progress == null) {
      progressBar = LinearProgressIndicator(
        backgroundColor: trackColor,
        color: progressColor,
        minHeight: height,
      );
    } else {
      final clampedProgress = progress!.clamp(0.0, 1.0);

      progressBar = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: clampedProgress),
        duration: animate ? const Duration(milliseconds: 300) : Duration.zero,
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return LinearProgressIndicator(
            value: value,
            backgroundColor: trackColor,
            color: progressColor,
            minHeight: height,
          );
        },
      );
    }

    if (showPercentage || label != null) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (label != null) ...[
            Text(
              label!,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 4),
          ],
          Row(
            children: [
              Expanded(child: progressBar),
              if (showPercentage && progress != null) ...[
                const SizedBox(width: 12),
                Text(
                  '${(progress! * 100).toInt()}%',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: progressColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ],
          ),
        ],
      );
    }

    return progressBar;
  }
}

/// Circular progress indicator for sync operations
///
/// Features:
/// - Shows progress with circular animation
/// - Customizable size and stroke width
/// - Optional centered text/percentage
/// - Indeterminate mode for unknown progress
class SyncCircularProgress extends StatelessWidget {
  /// Progress value (0.0 to 1.0)
  final double? progress;

  /// Whether to show indeterminate progress
  final bool isIndeterminate;

  /// Size of the circular indicator
  final double size;

  /// Stroke width of the progress ring
  final double strokeWidth;

  /// Custom color for the progress indicator
  final Color? color;

  /// Background color of the progress track
  final Color? backgroundColor;

  /// Widget to display in the center (e.g., percentage text)
  final Widget? center;

  const SyncCircularProgress({
    super.key,
    this.progress,
    this.isIndeterminate = false,
    this.size = 40,
    this.strokeWidth = 4,
    this.color,
    this.backgroundColor,
    this.center,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = color ?? theme.colorScheme.primary;
    final trackColor = backgroundColor ?? theme.colorScheme.surfaceContainerHighest;

    Widget progressIndicator;

    if (isIndeterminate || progress == null) {
      progressIndicator = SizedBox(
        width: size,
        height: size,
        child: CircularProgressIndicator(
          strokeWidth: strokeWidth,
          color: progressColor,
          backgroundColor: trackColor,
        ),
      );
    } else {
      final clampedProgress = progress!.clamp(0.0, 1.0);

      progressIndicator = TweenAnimationBuilder<double>(
        tween: Tween(begin: 0, end: clampedProgress),
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        builder: (context, value, child) {
          return SizedBox(
            width: size,
            height: size,
            child: Stack(
              alignment: Alignment.center,
              children: [
                // Background circle
                SizedBox(
                  width: size,
                  height: size,
                  child: CircularProgressIndicator(
                    value: 1,
                    strokeWidth: strokeWidth,
                    color: trackColor,
                    backgroundColor: Colors.transparent,
                  ),
                ),
                // Progress circle
                SizedBox(
                  width: size,
                  height: size,
                  child: CircularProgressIndicator(
                    value: value,
                    strokeWidth: strokeWidth,
                    color: progressColor,
                    backgroundColor: Colors.transparent,
                  ),
                ),
                // Center widget
                if (center != null) center!,
              ],
            ),
          );
        },
      );
    }

    return progressIndicator;
  }
}

/// Status card showing sync progress with details
///
/// Features:
/// - Shows current sync status with icon
/// - Displays progress bar with percentage
/// - Shows processed/total counts
/// - Optional error display
class SyncProgressCard extends StatelessWidget {
  /// Status title
  final String title;

  /// Status message or description
  final String? message;

  /// Progress value (0.0 to 1.0)
  final double? progress;

  /// Number of items processed
  final int processed;

  /// Total number of items to process
  final int total;

  /// Whether to show indeterminate progress
  final bool isIndeterminate;

  /// Error message if sync failed
  final String? error;

  /// Color for the progress indicator
  final Color? color;

  const SyncProgressCard({
    super.key,
    required this.title,
    this.message,
    this.progress,
    this.processed = 0,
    this.total = 0,
    this.isIndeterminate = false,
    this.error,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final progressColor = color ?? theme.colorScheme.primary;
    final hasError = error != null;

    return Card(
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: hasError
              ? theme.colorScheme.error
              : theme.colorScheme.outlineVariant,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Row(
              children: [
                Icon(
                  hasError ? Icons.error : Icons.sync,
                  color: hasError ? theme.colorScheme.error : progressColor,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),

            // Message
            if (message != null) ...[
              Text(
                message!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Progress bar
            if (!hasError)
              SyncProgressBar(
                progress: progress,
                isIndeterminate: isIndeterminate,
                showPercentage: !isIndeterminate && progress != null,
              ),

            // Count display
            if (!isIndeterminate && total > 0) ...[
              const SizedBox(height: 8),
              Text(
                '$processed of $total ${_pluralize('item', total)}',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],

            // Error message
            if (hasError) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.onErrorContainer,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        error!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onErrorContainer,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  String _pluralize(String word, int count) {
    return count == 1 ? word : '${word}s';
  }
}
