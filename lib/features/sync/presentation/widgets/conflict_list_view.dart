import 'package:flutter/material.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_info.dart';

/// Widget for displaying a list of sync conflicts
///
/// Shows each conflict in a card format with severity indicators
/// and provides access to detailed resolution dialog.
class ConflictListView extends StatelessWidget {
  /// List of conflicts to display
  final List<ConflictInfo> conflicts;

  /// Callback when a conflict is selected
  final Function(ConflictInfo) onConflictSelected;

  /// Callback when user chooses to resolve all conflicts automatically
  final VoidCallback? onAutoResolve;

  /// Whether conflicts can be auto-resolved
  final bool canAutoResolve;

  const ConflictListView({
    super.key,
    required this.conflicts,
    required this.onConflictSelected,
    this.onAutoResolve,
    this.canAutoResolve = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (conflicts.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle_outline,
                size: 64,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(height: 16),
              Text(
                'No Conflicts',
                style: theme.textTheme.titleLarge,
              ),
              const SizedBox(height: 8),
              Text(
                'All your data is in sync',
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              Icon(
                Icons.warning_amber,
                color: _getHighestSeverityColor(theme),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  '${conflicts.length} Conflict${conflicts.length > 1 ? 's' : ''} Detected',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              if (canAutoResolve && onAutoResolve != null)
                FilledButton.tonalIcon(
                  onPressed: onAutoResolve,
                  icon: const Icon(Icons.auto_fix_high),
                  label: const Text('Auto-Resolve'),
                ),
            ],
          ),
        ),

        // Conflict list
        ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: conflicts.length,
          separatorBuilder: (context, index) => const SizedBox(height: 8),
          itemBuilder: (context, index) {
            final conflict = conflicts[index];
            return _ConflictCard(
              conflict: conflict,
              onTap: () => onConflictSelected(conflict),
            );
          },
        ),
      ],
    );
  }

  /// Gets color for highest severity conflict
  Color _getHighestSeverityColor(ThemeData theme) {
    if (conflicts.any((c) => c.severity == ConflictSeverity.high)) {
      return theme.colorScheme.error;
    } else if (conflicts.any((c) => c.severity == ConflictSeverity.medium)) {
      return Colors.deepOrange;
    }
    return Colors.orange;
  }
}

/// Card widget for a single conflict
class _ConflictCard extends StatelessWidget {
  final ConflictInfo conflict;
  final VoidCallback onTap;

  const _ConflictCard({
    required this.conflict,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final severityColor = _getSeverityColor(theme);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row
              Row(
                children: [
                  Icon(
                    _getConflictIcon(),
                    color: severityColor,
                    size: 24,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _formatEntityType(conflict.entityType),
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          conflict.description,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurface.withValues(alpha:0.4),
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Details
              Row(
                children: [
                  _buildDetailChip(
                    context,
                    icon: Icons.numbers,
                    label:
                        'v${conflict.localVersion.version} / v${conflict.remoteVersion.version}',
                  ),
                  const SizedBox(width: 8),
                  _buildDetailChip(
                    context,
                    icon: _getSeverityIcon(),
                    label: _formatSeverity(conflict.severity),
                    color: severityColor,
                  ),
                ],
              ),
              const SizedBox(height: 12),

              // Timestamps
              Row(
                children: [
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha:0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Local: ${_formatRelativeTime(conflict.localVersion.lastModified)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Icon(
                    Icons.cloud,
                    size: 16,
                    color: theme.colorScheme.onSurface.withValues(alpha:0.5),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Remote: ${_formatRelativeTime(conflict.remoteVersion.lastModified)}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurface.withValues(alpha:0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds a detail chip
  Widget _buildDetailChip(
    BuildContext context, {
    required IconData icon,
    required String label,
    Color? color,
  }) {
    final theme = Theme.of(context);
    final chipColor = color ?? theme.colorScheme.onSurface.withValues(alpha:0.6);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: chipColor.withValues(alpha:0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: chipColor.withValues(alpha:0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: chipColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: chipColor,
              fontWeight: FontWeight.w500,
            ),
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

  /// Gets icon based on severity
  IconData _getSeverityIcon() {
    switch (conflict.severity) {
      case ConflictSeverity.low:
        return Icons.warning;
      case ConflictSeverity.medium:
        return Icons.error;
      case ConflictSeverity.high:
        return Icons.dangerous;
    }
  }

  /// Formats entity type for display
  String _formatEntityType(String entityType) {
    return entityType
        .replaceAll(RegExp(r'(?<!^)(?=[A-Z])'), ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Formats severity for display
  String _formatSeverity(ConflictSeverity severity) {
    switch (severity) {
      case ConflictSeverity.low:
        return 'Low';
      case ConflictSeverity.medium:
        return 'Medium';
      case ConflictSeverity.high:
        return 'High';
    }
  }

  /// Formats relative time
  String _formatRelativeTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inSeconds < 60) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${dateTime.day}/${dateTime.month}/${dateTime.year}';
    }
  }
}
