import 'package:flutter/material.dart';
import '../../domain/entities/check_in.dart';

/// Reusable widget for displaying check-in status
///
/// Features:
/// - Displays status as chip, icon, or circular indicator
/// - Color-coded based on status type
/// - Configurable sizes and styles
/// - Optional labels and tooltips
class CheckInStatusIndicator extends StatelessWidget {
  /// The check-in status to display
  final CheckInStatus status;

  /// Display style for the indicator
  final CheckInStatusIndicatorStyle style;

  /// Optional custom label (overrides default)
  final String? customLabel;

  /// Size of the indicator (for icon and circular styles)
  final double size;

  /// Whether to show a label alongside the indicator
  final bool showLabel;

  /// Optional tooltip message
  final String? tooltip;

  const CheckInStatusIndicator({
    super.key,
    required this.status,
    this.style = CheckInStatusIndicatorStyle.chip,
    this.customLabel,
    this.size = 24,
    this.showLabel = false,
    this.tooltip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final color = _getStatusColor();
    final label = customLabel ?? _getStatusLabel();

    Widget indicator;

    switch (style) {
      case CheckInStatusIndicatorStyle.chip:
        indicator = _buildChip(color, label);
        break;
      case CheckInStatusIndicatorStyle.icon:
        indicator = _buildIcon(color, label);
        break;
      case CheckInStatusIndicatorStyle.circular:
        indicator = _buildCircularIndicator(color);
        break;
      case CheckInStatusIndicatorStyle.badge:
        indicator = _buildBadge(color, label);
        break;
    }

    if (tooltip != null) {
      return Tooltip(
        message: tooltip!,
        child: indicator,
      );
    }

    return indicator;
  }

  /// Builds a chip-style indicator
  Widget _buildChip(Color color, String label) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color),
      visualDensity: VisualDensity.compact,
    );
  }

  /// Builds an icon-style indicator
  Widget _buildIcon(Color color, String label) {
    final icon = _getStatusIcon();

    if (showLabel) {
      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: size,
            color: color,
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );
    }

    return Icon(
      icon,
      size: size,
      color: color,
    );
  }

  /// Builds a circular-style indicator
  Widget _buildCircularIndicator(Color color) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: color,
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 2,
        ),
      ),
      child: Center(
        child: Icon(
          _getStatusIcon(),
          size: size * 0.6,
          color: Colors.white,
        ),
      ),
    );
  }

  /// Builds a badge-style indicator
  Widget _buildBadge(Color color, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(),
            size: size * 0.7,
            color: Colors.white,
          ),
          if (showLabel) ...[
            const SizedBox(width: 6),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w600,
                fontSize: 12,
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Gets the color for the status
  Color _getStatusColor() {
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

  /// Gets the icon for the status
  IconData _getStatusIcon() {
    switch (status) {
      case CheckInStatus.scheduled:
        return Icons.schedule;
      case CheckInStatus.active:
        return Icons.play_circle_filled;
      case CheckInStatus.completed:
        return Icons.check_circle;
      case CheckInStatus.missed:
        return Icons.error;
      case CheckInStatus.cancelled:
        return Icons.cancel;
    }
  }

  /// Gets the label for the status
  String _getStatusLabel() {
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

/// Display style for the status indicator
enum CheckInStatusIndicatorStyle {
  /// Chip style with border and background
  chip,
  /// Icon style with optional label
  icon,
  /// Circular indicator with icon inside
  circular,
  /// Badge style with solid background
  badge,
}

/// Widget for displaying check-in status with additional context
///
/// Shows more detailed information including due time, deadline info
class CheckInStatusDisplay extends StatelessWidget {
  /// The check-in to display status for
  final CheckIn checkIn;

  /// Whether to show the time until due/deadline
  final bool showTimeUntil;

  /// Whether to show the scheduled time
  final bool showScheduledTime;

  /// Display style for the status indicator
  final CheckInStatusIndicatorStyle indicatorStyle;

  const CheckInStatusDisplay({
    super.key,
    required this.checkIn,
    this.showTimeUntil = true,
    this.showScheduledTime = false,
    this.indicatorStyle = CheckInStatusIndicatorStyle.chip,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Status indicator
        CheckInStatusIndicator(
          status: checkIn.status,
          style: indicatorStyle,
          showLabel: true,
        ),

        // Additional time information
        if (showTimeUntil && _shouldShowTimeUntil()) ...[
          const SizedBox(height: 8),
          _buildTimeUntilInfo(context),
        ],

        if (showScheduledTime && checkIn.scheduledTime != null) ...[
          const SizedBox(height: 4),
          Text(
            'Scheduled: ${_formatDateTime(checkIn.scheduledTime!)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTimeUntilInfo(BuildContext context) {
    final theme = Theme.of(context);
    final deadline = checkIn.deadline ?? checkIn.scheduledTime;

    if (deadline == null) return const SizedBox.shrink();

    final now = DateTime.now();
    final difference = deadline.difference(now);

    String timeText;
    Color textColor;

    if (difference.isNegative) {
      final overdueDuration = now.difference(deadline);
      timeText = 'Overdue by ${_formatDuration(overdueDuration)}';
      textColor = Colors.red;
    } else if (difference.inMinutes < 60) {
      timeText = 'Due in ${difference.inMinutes} min';
      textColor = difference.inMinutes < 15 ? Colors.red : Colors.orange;
    } else if (difference.inHours < 24) {
      timeText = 'Due in ${difference.inHours} hour${difference.inHours > 1 ? "s" : ""}';
      textColor = Colors.orange;
    } else {
      timeText = 'Due in ${difference.inDays} day${difference.inDays > 1 ? "s" : ""}';
      textColor = theme.colorScheme.primary;
    }

    return Text(
      timeText,
      style: theme.textTheme.bodyMedium?.copyWith(
        color: textColor,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  bool _shouldShowTimeUntil() {
    return checkIn.status == CheckInStatus.scheduled ||
        checkIn.status == CheckInStatus.active;
  }

  String _formatDateTime(DateTime dateTime) {
    final date = dateTime.toString().split(' ')[0];
    final time = dateTime.toString().split(' ')[1].substring(0, 5);
    return '$date $time';
  }

  String _formatDuration(Duration duration) {
    if (duration.inHours > 0) {
      return '${duration.inHours}h ${duration.inMinutes % 60}m';
    }
    return '${duration.inMinutes}m';
  }
}
