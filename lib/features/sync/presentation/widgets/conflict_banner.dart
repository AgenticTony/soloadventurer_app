import 'package:flutter/material.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_info.dart';

/// Banner widget for displaying sync conflict alerts
///
/// Shows a dismissible banner with conflict summary and action button
class ConflictBanner extends StatelessWidget {
  /// The conflict information to display
  final ConflictInfo conflict;

  /// Callback when user taps to resolve
  final VoidCallback onResolve;

  /// Callback when banner is dismissed
  final VoidCallback? onDismiss;

  /// Whether the banner can be dismissed
  final bool isDismissible;

  const ConflictBanner({
    super.key,
    required this.conflict,
    required this.onResolve,
    this.onDismiss,
    this.isDismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final severityColor = _getSeverityColor(theme);

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: severityColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: severityColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: severityColor.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              _getConflictIcon(),
              color: severityColor,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Sync Conflict',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: severityColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  conflict.description,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // Actions
          Row(
            children: [
              // Resolve button
              FilledButton.tonal(
                onPressed: onResolve,
                style: FilledButton.styleFrom(
                  backgroundColor: severityColor.withValues(alpha: 0.2),
                  foregroundColor: severityColor,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                child: const Text('Resolve'),
              ),

              // Dismiss button
              if (isDismissible && onDismiss != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close),
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Gets icon based on conflict type
  IconData _getConflictIcon() {
    switch (conflict.conflictType) {
      case ConflictType.versionConflict:
        return Icons.sync_problem;
      case ConflictType.localNewer:
        return Icons.update;
      case ConflictType.remoteNewer:
        return Icons.cloud_sync;
      case ConflictType.diverged:
        return Icons.call_split;
      case ConflictType.timestampConflict:
        return Icons.access_time;
    }
  }

  /// Gets color based on severity
  Color _getSeverityColor(ThemeData theme) {
    switch (conflict.severity) {
      case ConflictSeverity.low:
        return Colors.orange;
      case ConflictSeverity.medium:
        return Colors.deepOrange;
      case ConflictSeverity.high:
        return theme.colorScheme.error;
    }
  }
}

/// Multiple conflicts banner
///
/// Shows a banner when multiple conflicts are detected
class MultipleConflictsBanner extends StatelessWidget {
  /// List of conflicts
  final List<ConflictInfo> conflicts;

  /// Callback when user taps to view all conflicts
  final VoidCallback onViewAll;

  /// Callback when banner is dismissed
  final VoidCallback? onDismiss;

  /// Whether the banner can be dismissed
  final bool isDismissible;

  const MultipleConflictsBanner({
    super.key,
    required this.conflicts,
    required this.onViewAll,
    this.onDismiss,
    this.isDismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final highestSeverity = _getHighestSeverity();

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            highestSeverity.withValues(alpha: 0.15),
            highestSeverity.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highestSeverity.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // Icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: highestSeverity.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              Icons.warning_amber,
              color: highestSeverity,
              size: 24,
            ),
          ),
          const SizedBox(width: 12),

          // Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${conflicts.length} Sync Conflict${conflicts.length > 1 ? 's' : ''}',
                  style: theme.textTheme.titleSmall?.copyWith(
                    color: highestSeverity,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  _getSummaryText(),
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          ),

          // Actions
          Row(
            children: [
              // View all button
              FilledButton.tonal(
                onPressed: onViewAll,
                style: FilledButton.styleFrom(
                  backgroundColor: highestSeverity.withValues(alpha: 0.2),
                  foregroundColor: highestSeverity,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                ),
                child: const Text('View All'),
              ),

              // Dismiss button
              if (isDismissible && onDismiss != null) ...[
                const SizedBox(width: 8),
                IconButton(
                  onPressed: onDismiss,
                  icon: const Icon(Icons.close),
                  color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ],
          ),
        ],
      ),
    );
  }

  /// Gets the highest severity color
  Color _getHighestSeverity() {
    // Return a default color - this will be overridden in build() where we have context
    if (conflicts.any((c) => c.severity == ConflictSeverity.high)) {
      return Colors.red;
    } else if (conflicts.any((c) => c.severity == ConflictSeverity.medium)) {
      return Colors.deepOrange;
    }
    return Colors.orange;
  }

  /// Gets summary text for conflicts
  String _getSummaryText() {
    final highSeverity =
        conflicts.where((c) => c.severity == ConflictSeverity.high).length;
    final mediumSeverity =
        conflicts.where((c) => c.severity == ConflictSeverity.medium).length;
    final lowSeverity =
        conflicts.where((c) => c.severity == ConflictSeverity.low).length;

    final parts = <String>[];
    if (highSeverity > 0) {
      parts.add('$highSeverity high');
    }
    if (mediumSeverity > 0) {
      parts.add('$mediumSeverity medium');
    }
    if (lowSeverity > 0) {
      parts.add('$lowSeverity low');
    }

    if (parts.isEmpty) {
      return 'Multiple conflicts need attention';
    }

    return '${parts.join(', ')} severity';
  }
}
