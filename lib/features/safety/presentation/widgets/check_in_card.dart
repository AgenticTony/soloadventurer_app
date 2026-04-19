import 'package:flutter/material.dart';
import '../../domain/entities/check_in.dart';

/// Callback type for when a check-in card is tapped
typedef CheckInCardCallback = void Function(CheckIn checkIn);

/// Reusable widget for displaying check-in information in a card
///
/// Features:
/// - Displays check-in type, time, status, message, and location
/// - Shows status chip with color coding
/// - Indicates due soon and overdue check-ins with visual cues
/// - Supports tap action and optional action buttons
/// - Configurable display modes (compact vs full)
class CheckInCard extends StatelessWidget {
  /// The check-in to display
  final CheckIn checkIn;

  /// Optional callback when the card is tapped
  final CheckInCardCallback? onTap;

  /// Whether to show the action buttons (View, Complete)
  final bool showActions;

  /// Whether to show the status chip
  final bool showStatusChip;

  /// Whether to show the location information
  final bool showLocation;

  /// Whether to show the status message
  final bool showMessage;

  /// Optional callback for the "View" button
  final CheckInCardCallback? onView;

  /// Optional callback for the "Complete" button
  final CheckInCardCallback? onComplete;

  const CheckInCard({
    super.key,
    required this.checkIn,
    this.onTap,
    this.showActions = true,
    this.showStatusChip = true,
    this.showLocation = true,
    this.showMessage = true,
    this.onView,
    this.onComplete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDueSoon = _isDueSoon(checkIn);
    final isOverdue = _isOverdue(checkIn);

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isOverdue
            ? BorderSide(color: Colors.red.shade300, width: 2)
            : isDueSoon
                ? BorderSide(color: Colors.orange.shade300, width: 2)
                : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap != null ? () => onTap!(checkIn) : null,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with icon, title, time, and status chip
              Row(
                children: [
                  Icon(
                    _getCheckInIcon(checkIn.triggerType),
                    color: _getStatusColor(context, checkIn),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getCheckInTitle(checkIn),
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatCheckInTime(checkIn),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (showStatusChip) _buildStatusChip(context),
                ],
              ),

              // Status message (if exists and enabled)
              if (showMessage && checkIn.statusMessage != null) ...[
                const SizedBox(height: 12),
                Text(
                  checkIn.statusMessage!,
                  style: theme.textTheme.bodyMedium,
                ),
              ],

              // Location (if exists and enabled)
              if (showLocation && checkIn.location != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        checkIn.location!.placeName ??
                            checkIn.location!.address ??
                            '${checkIn.location!.latitude.toStringAsFixed(4)}, ${checkIn.location!.longitude.toStringAsFixed(4)}',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],

              // Action buttons
              if (showActions) ...[
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    TextButton.icon(
                      onPressed: onView != null
                          ? () => onView!(checkIn)
                          : (onTap != null ? () => onTap!(checkIn) : null),
                      icon: const Icon(Icons.visibility, size: 18),
                      label: const Text('View'),
                    ),
                    if (checkIn.status == CheckInStatus.scheduled ||
                        checkIn.status == CheckInStatus.active) ...[
                      const SizedBox(width: 8),
                      FilledButton.icon(
                        onPressed: onComplete != null
                            ? () => onComplete!(checkIn)
                            : null,
                        icon: const Icon(Icons.check, size: 18),
                        label: const Text('Complete'),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the status chip with appropriate colors
  Widget _buildStatusChip(BuildContext context) {
    final label = _getStatusLabel(checkIn.status);
    final color = _getStatusColorForChip(checkIn.status);

    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: color.withValues(alpha: 0.1),
      side: BorderSide(color: color),
    );
  }

  /// Checks if the check-in is due soon (within 1 hour)
  bool _isDueSoon(CheckIn checkIn) {
    final deadline = checkIn.deadline ?? checkIn.scheduledTime;
    if (deadline == null) return false;
    return deadline.isBefore(DateTime.now().add(const Duration(hours: 1)));
  }

  /// Checks if the check-in is overdue
  bool _isOverdue(CheckIn checkIn) {
    final deadline = checkIn.deadline ?? checkIn.scheduledTime;
    if (deadline == null) return false;
    return deadline.isBefore(DateTime.now());
  }

  /// Formats the check-in time for display
  String _formatCheckInTime(CheckIn checkIn) {
    final scheduledTime = checkIn.scheduledTime;

    if (scheduledTime == null) return 'No time set';

    final now = DateTime.now();
    final difference = scheduledTime.difference(now);

    if (difference.inMinutes < 1) {
      return 'Due now';
    } else if (difference.inMinutes < 60) {
      return 'Due in ${difference.inMinutes} minutes';
    } else if (difference.inHours < 24) {
      return 'Due in ${difference.inHours} hours';
    } else {
      final date = scheduledTime.toString().split(' ')[0];
      final time = scheduledTime.toString().split(' ')[1].substring(0, 5);
      return 'Due on $date at $time';
    }
  }

  /// Gets the title for the check-in based on trigger type
  String _getCheckInTitle(CheckIn checkIn) {
    switch (checkIn.triggerType) {
      case CheckInTriggerType.manual:
        return 'Manual Check-in';
      case CheckInTriggerType.scheduledTime:
        return 'Scheduled Check-in';
      case CheckInTriggerType.locationArrival:
        return 'Arrival Check-in';
      case CheckInTriggerType.locationDeparture:
        return 'Departure Check-in';
    }
  }

  /// Gets the icon for the check-in based on trigger type
  IconData _getCheckInIcon(CheckInTriggerType triggerType) {
    switch (triggerType) {
      case CheckInTriggerType.manual:
        return Icons.check_circle;
      case CheckInTriggerType.scheduledTime:
        return Icons.schedule;
      case CheckInTriggerType.locationArrival:
        return Icons.login;
      case CheckInTriggerType.locationDeparture:
        return Icons.logout;
    }
  }

  /// Gets the status color for the check-in
  Color _getStatusColor(BuildContext context, CheckIn checkIn) {
    if (_isOverdue(checkIn)) return Colors.red;
    if (_isDueSoon(checkIn)) return Colors.orange;
    return Theme.of(context).colorScheme.primary;
  }

  /// Gets the color for the status chip
  Color _getStatusColorForChip(CheckInStatus status) {
    switch (status) {
      case CheckInStatus.scheduled:
        return Colors.blue;
      case CheckInStatus.active:
        return Colors.green;
      case CheckInStatus.completed:
        return Colors.grey;
      case CheckInStatus.missed:
        return Colors.red;
      case CheckInStatus.cancelled:
        return Colors.grey;
    }
  }

  /// Gets the label for the check-in status
  String _getStatusLabel(CheckInStatus status) {
    switch (status) {
      case CheckInStatus.scheduled:
        return 'Scheduled';
      case CheckInStatus.active:
        return 'Active';
      case CheckInStatus.completed:
        return 'Completed';
      case CheckInStatus.missed:
        return 'Missed';
      case CheckInStatus.cancelled:
        return 'Cancelled';
    }
  }
}
