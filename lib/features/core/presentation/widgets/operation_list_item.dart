import 'package:flutter/material.dart';
import '../../../core/services/operation_queue.dart';
import '../../../../app/theme/app_theme.dart';

/// Widget that displays a single operation in a card format
class OperationListItem extends StatelessWidget {
  /// The operation to display
  final QueueableOperation operation;

  /// Whether this operation is in the failed state
  final bool isFailed;

  /// Callback when retry button is pressed (only for failed operations)
  final VoidCallback? onRetry;

  /// Callback when delete/remove button is pressed
  final VoidCallback? onRemove;

  /// Creates a new [OperationListItem]
  const OperationListItem({
    super.key,
    required this.operation,
    this.isFailed = false,
    this.onRetry,
    this.onRemove,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header: Type and Status
            Row(
              children: [
                _buildOperationTypeIcon(),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _getOperationTitle(),
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        operation.type,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: colorScheme.onSurface.withValues(alpha: 0.6),
                        ),
                      ),
                    ],
                  ),
                ),
                _buildStatusChip(context),
              ],
            ),
            const SizedBox(height: 12),

            // Operation Details
            _buildOperationDetails(context),
            const SizedBox(height: 12),

            // Retry Metadata (if attempted)
            if (operation.attemptCount > 0) ...[
              _buildRetryMetadata(context),
              const SizedBox(height: 12),
            ],

            // Error Message (for failed operations)
            if (isFailed && operation.lastError != null) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.errorColor.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.errorColor.withValues(alpha: 0.3),
                  ),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.error_outline,
                      color: AppTheme.errorColor,
                      size: 20,
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        operation.lastError!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: AppTheme.errorColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
            ],

            // Action Buttons
            if (isFailed || onRemove != null)
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  if (isFailed && onRetry != null)
                    ElevatedButton.icon(
                      onPressed: onRetry,
                      icon: const Icon(Icons.refresh, size: 18),
                      label: const Text('Retry'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: colorScheme.primary,
                        foregroundColor: colorScheme.onPrimary,
                      ),
                    ),
                  if (onRemove != null) ...[
                    if (isFailed && onRetry != null) const SizedBox(width: 8),
                    TextButton.icon(
                      onPressed: onRemove,
                      icon: const Icon(Icons.delete_outline, size: 18),
                      label: const Text('Remove'),
                      style: TextButton.styleFrom(
                        foregroundColor: colorScheme.error,
                      ),
                    ),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// Build icon based on operation type
  Widget _buildOperationTypeIcon() {
    IconData iconData;
    Color iconColor;

    switch (operation.type) {
      case 'trip_planning':
        iconData = Icons.flight_takeoff;
        iconColor = Colors.blue;
        break;
      case 'travel_note':
        iconData = Icons.note;
        iconColor = Colors.green;
        break;
      case 'location_update':
        iconData = Icons.location_on;
        iconColor = Colors.orange;
        break;
      default:
        iconData = Icons.pending_actions;
        iconColor = Colors.grey;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }

  /// Build status chip
  Widget _buildStatusChip(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    String label;
    Color backgroundColor;
    Color textColor;

    if (isFailed) {
      label = 'Failed';
      backgroundColor = AppTheme.errorColor.withValues(alpha: 0.1);
      textColor = AppTheme.errorColor;
    } else if (operation.attemptCount > 0) {
      label = 'Retrying';
      backgroundColor = Colors.orange.withValues(alpha: 0.1);
      textColor = Colors.orange;
    } else {
      label = 'Pending';
      backgroundColor = Colors.blue.withValues(alpha: 0.1);
      textColor = Colors.blue;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          color: textColor,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Build operation details based on type
  Widget _buildOperationDetails(BuildContext context) {
    final theme = Theme.of(context);

    // Extract details from the operation
    final details = _getOperationDetails();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: details.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 100,
                child: Text(
                  '${entry.key}:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurface.withValues(alpha: 0.6),
                  ),
                ),
              ),
              Expanded(
                child: Text(
                  entry.value,
                  style: theme.textTheme.bodySmall,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  /// Build retry metadata section
  Widget _buildRetryMetadata(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: colorScheme.surfaceContainerHighest.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(
            Icons.history,
            size: 16,
            color: colorScheme.onSurface.withValues(alpha: 0.6),
          ),
          const SizedBox(width: 8),
          Text(
            'Attempt ${operation.attemptCount} of ${operation.maxRetries}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: colorScheme.onSurface.withValues(alpha: 0.8),
            ),
          ),
          if (operation.lastAttempt != null) ...[
            const SizedBox(width: 16),
            Icon(
              Icons.access_time,
              size: 16,
              color: colorScheme.onSurface.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                _formatDateTime(operation.lastAttempt!),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: colorScheme.onSurface.withValues(alpha: 0.6),
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Get a human-readable title for the operation
  String _getOperationTitle() {
    switch (operation.type) {
      case 'trip_planning':
        return 'Trip Planning';
      case 'travel_note':
        return 'Travel Note';
      case 'location_update':
        return 'Location Update';
      default:
        return 'Operation';
    }
  }

  /// Get operation details as a map
  Map<String, String> _getOperationDetails() {
    final details = <String, String>{};

    // Common fields
    details['ID'] = operation.id.substring(0, 8);
    details['Priority'] = _getPriorityLabel(operation.priority);
    details['Created'] = _formatDateTime(operation.createdAt ?? DateTime.now());
    details['Requires Network'] = operation.requiresNetwork ? 'Yes' : 'No';

    // Type-specific details
    if (operation.type == 'trip_planning') {
      final json = operation.toJson();
      if (json.containsKey('planningType')) {
        details['Type'] = _formatEnum(json['planningType'].toString());
      }
      if (json.containsKey('tripId')) {
        details['Trip ID'] = json['tripId'].toString().substring(0, 8);
      }
    }

    return details;
  }

  /// Get priority label
  String _getPriorityLabel(int priority) {
    if (priority >= 1000) return 'Critical';
    if (priority >= 100) return 'High';
    if (priority >= 10) return 'Normal';
    return 'Low';
  }

  /// Format enum value for display
  String _formatEnum(String enumValue) {
    // Remove enum class name and convert to title case
    final parts = enumValue.split('.');
    if (parts.length > 1) {
      return parts.last
          .replaceAll('_', ' ')
          .split(' ')
          .map((word) => word[0].toUpperCase() + word.substring(1))
          .join(' ');
    }
    return enumValue;
  }

  /// Format date time for display
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inMinutes < 1) {
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
