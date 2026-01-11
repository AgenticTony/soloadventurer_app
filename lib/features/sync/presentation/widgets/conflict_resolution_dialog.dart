import 'package:flutter/material.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_info.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_resolution.dart';
import 'conflict_comparison_view.dart';

/// Dialog for resolving sync conflicts
///
/// Shows both versions of conflicted data with side-by-side comparison
/// and provides user choice controls for resolution.
class ConflictResolutionDialog extends StatelessWidget {
  /// The conflict information to resolve
  final ConflictInfo conflict;

  /// Callback when user chooses to keep local version
  final VoidCallback onKeepLocal;

  /// Callback when user chooses to keep remote version
  final VoidCallback onKeepRemote;

  /// Callback when user chooses to merge versions
  final VoidCallback onMerge;

  /// Whether merge option is available
  final bool canMerge;

  const ConflictResolutionDialog({
    super.key,
    required this.conflict,
    required this.onKeepLocal,
    required this.onKeepRemote,
    required this.onMerge,
    this.canMerge = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSmallScreen = MediaQuery.of(context).size.width < 600;

    return AlertDialog(
      title: Row(
        children: [
          Icon(
            _getConflictIcon(),
            color: _getSeverityColor(theme),
            size: 28,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Sync Conflict Detected',
              style: theme.textTheme.titleLarge,
            ),
          ),
        ],
      ),
      content: SizedBox(
        width: isSmallScreen ? double.maxFinite : 600,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Conflict description
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: _getSeverityColor(theme).withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: _getSeverityColor(theme).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: _getSeverityColor(theme),
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        conflict.description,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: _getSeverityColor(theme),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Entity information
              _buildEntityInfo(context, theme),
              const SizedBox(height: 16),

              // Side-by-side comparison
              ConflictComparisonView(
                conflict: conflict,
              ),
              const SizedBox(height: 16),

              // Severity indicator
              _buildSeverityIndicator(context, theme),
            ],
          ),
        ),
      ),
      actions: [
        // Cancel button
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Cancel'),
        ),

        // Action buttons
        if (canMerge)
          TextButton.icon(
            onPressed: onMerge,
            icon: const Icon(Icons.merge),
            label: const Text('Merge'),
          ),

        FilledButton.icon(
          onPressed: onKeepRemote,
          icon: const Icon(Icons.cloud_download),
          label: const Text('Keep Remote'),
          style: FilledButton.styleFrom(
            backgroundColor: theme.colorScheme.secondary,
          ),
        ),

        FilledButton.icon(
          onPressed: onKeepLocal,
          icon: const Icon(Icons.smartphone),
          label: const Text('Keep Local'),
        ),
      ],
    );
  }

  /// Builds entity information section
  Widget _buildEntityInfo(BuildContext context, ThemeData theme) {
    return Card(
      elevation: 0,
      color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Entity Information',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            _buildInfoRow(
              context,
              'Type',
              _formatEntityType(conflict.entityType),
              Icons.category,
            ),
            const SizedBox(height: 4),
            _buildInfoRow(
              context,
              'ID',
              conflict.entityId,
              Icons.tag,
            ),
            const SizedBox(height: 4),
            _buildInfoRow(
              context,
              'Conflict Type',
              _formatConflictType(conflict.conflictType),
              Icons.error_outline,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds an information row
  Widget _buildInfoRow(
    BuildContext context,
    String label,
    String value,
    IconData icon,
  ) {
    final theme = Theme.of(context);
    return Row(
      children: [
        Icon(
          icon,
          size: 16,
          color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
        ),
        const SizedBox(width: 8),
        Text(
          '$label:',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
          ),
        ),
        const SizedBox(width: 4),
        Text(
          value,
          style: theme.textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  /// Builds severity indicator
  Widget _buildSeverityIndicator(BuildContext context, ThemeData theme) {
    final color = _getSeverityColor(theme);
    final severityText = _formatSeverity(conflict.severity);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getSeverityIcon(),
            color: color,
            size: 16,
          ),
          const SizedBox(width: 6),
          Text(
            'Severity: $severityText',
            style: theme.textTheme.bodySmall?.copyWith(
              color: color,
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
    // Convert camelCase to Title Case
    return entityType
        .replaceAll(RegExp(r'(?<!^)(?=[A-Z])'), ' ')
        .split(' ')
        .map((word) => word[0].toUpperCase() + word.substring(1))
        .join(' ');
  }

  /// Formats conflict type for display
  String _formatConflictType(ConflictType type) {
    switch (type) {
      case ConflictType.versionConflict:
        return 'Version Conflict';
      case ConflictType.localNewer:
        return 'Local is Newer';
      case ConflictType.remoteNewer:
        return 'Remote is Newer';
      case ConflictType.diverged:
        return 'Diverged';
      case ConflictType.timestampConflict:
        return 'Timestamp Conflict';
    }
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

  /// Shows the conflict resolution dialog
  ///
  /// Returns [ManualResolutionChoice] if user made a choice, or null if cancelled
  static Future<ManualResolutionChoice?> show({
    required BuildContext context,
    required ConflictInfo conflict,
    bool canMerge = false,
  }) async {
    ManualResolutionChoice? choice;

    await showDialog(
      context: context,
      builder: (context) => ConflictResolutionDialog(
        conflict: conflict,
        canMerge: canMerge,
        onKeepLocal: () {
          choice = ManualResolutionChoice.keepLocal;
          Navigator.of(context).pop();
        },
        onKeepRemote: () {
          choice = ManualResolutionChoice.keepRemote;
          Navigator.of(context).pop();
        },
        onMerge: () {
          choice = ManualResolutionChoice.customMerge;
          Navigator.of(context).pop();
        },
      ),
    );

    return choice;
  }
}
