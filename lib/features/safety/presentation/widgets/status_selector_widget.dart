import 'package:flutter/material.dart';
import '../../domain/entities/safety_status.dart' as safety;

/// Callback type for status selection changes
typedef StatusSelectedCallback = void Function(safety.SafetyStatusType status);

/// Reusable widget for selecting safety status
///
/// Features:
/// - Radio button selection for safety status (safe, need help, emergency)
/// - Color-coded icons and descriptions for each status
/// - Supports initial value, disabled state, and custom labels
/// - Optional wrapping in Card for consistent styling
/// - Follows Material Design guidelines with proper theming
///
/// Example usage:
/// ```dart
/// StatusSelectorWidget(
///   selectedStatus: _selectedStatus,
///   onStatusChanged: (status) => setState(() => _selectedStatus = status),
///   enabled: !isProcessing,
///   wrapInCard: true,
/// )
/// ```
class StatusSelectorWidget extends StatelessWidget {
  /// Currently selected status
  final safety.SafetyStatusType? selectedStatus;

  /// Callback when status is changed
  final StatusSelectedCallback? onStatusChanged;

  /// Whether the widget is enabled (for loading/disabled states)
  final bool enabled;

  /// Whether to wrap the widget in a Card
  final bool wrapInCard;

  /// Optional custom title for the selector section
  final String? title;

  /// Optional custom description/instructions
  final String? description;

  /// Whether to show dividers between options
  final bool showDividers;

  /// Visual density for the radio tiles
  final VisualDensity visualDensity;

  const StatusSelectorWidget({
    super.key,
    this.selectedStatus,
    this.onStatusChanged,
    this.enabled = true,
    this.wrapInCard = false,
    this.title,
    this.description,
    this.showDividers = true,
    this.visualDensity = VisualDensity.standard,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Optional title and description
        if (title != null) ...[
          _buildSectionHeader(context, title!),
          const SizedBox(height: 8),
        ],
        if (description != null) ...[
          Text(
            description!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Status options
        _buildStatusOptions(context),
      ],
    );

    if (wrapInCard) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: content,
        ),
      );
    }

    return content;
  }

  /// Builds section header with consistent styling
  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  /// Builds the status radio options
  Widget _buildStatusOptions(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Safe status
        _buildStatusRadioTile(
          context: context,
          status: safety.SafetyStatusType.safe,
          title: "I'm Safe",
          subtitle: 'Let your contacts know you\'re okay',
          icon: Icons.check_circle,
          color: Colors.green,
        ),
        if (showDividers) const Divider(height: 1),

        // Need help status
        _buildStatusRadioTile(
          context: context,
          status: safety.SafetyStatusType.needHelp,
          title: 'Need Help',
          subtitle: 'You need assistance but it\'s not an emergency',
          icon: Icons.help,
          color: Colors.orange,
        ),
        if (showDividers) const Divider(height: 1),

        // Emergency status
        _buildStatusRadioTile(
          context: context,
          status: safety.SafetyStatusType.emergency,
          title: 'Emergency',
          subtitle: 'You\'re in an emergency situation',
          icon: Icons.warning,
          color: Colors.red,
        ),
      ],
    );
  }

  /// Builds a single status radio tile
  Widget _buildStatusRadioTile({
    required BuildContext context,
    required safety.SafetyStatusType status,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
  }) {
    final theme = Theme.of(context);

    return RadioListTile<safety.SafetyStatusType>(
      title: Row(
        children: [
          Icon(
            icon,
            color: enabled ? color : color.withOpacity(0.5),
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      subtitle: Text(subtitle),
      value: status,
      groupValue: selectedStatus,
      onChanged: enabled
          ? (value) {
              if (value != null && onStatusChanged != null) {
                onStatusChanged!(value);
              }
            }
          : null,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      activeColor: color,
      visualDensity: visualDensity,
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return color;
        }
        if (states.contains(WidgetState.disabled)) {
          return color.withOpacity(0.38);
        }
        return null;
      }),
    );
  }
}

/// Compact version of status selector for inline usage
///
/// Uses a horizontal layout with smaller buttons for space-constrained UIs
class StatusSelectorCompact extends StatelessWidget {
  /// Currently selected status
  final safety.SafetyStatusType? selectedStatus;

  /// Callback when status is changed
  final StatusSelectedCallback? onStatusChanged;

  /// Whether the widget is enabled
  final bool enabled;

  /// Whether to show labels
  final bool showLabels;

  const StatusSelectorCompact({
    super.key,
    this.selectedStatus,
    this.onStatusChanged,
    this.enabled = true,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildCompactButton(
          context: context,
          status: safety.SafetyStatusType.safe,
          icon: Icons.check_circle,
          label: 'Safe',
          color: Colors.green,
        ),
        _buildCompactButton(
          context: context,
          status: safety.SafetyStatusType.needHelp,
          icon: Icons.help,
          label: 'Help',
          color: Colors.orange,
        ),
        _buildCompactButton(
          context: context,
          status: safety.SafetyStatusType.emergency,
          icon: Icons.warning,
          label: 'Emergency',
          color: Colors.red,
        ),
      ],
    );
  }

  Widget _buildCompactButton({
    required BuildContext context,
    required safety.SafetyStatusType status,
    required IconData icon,
    required String label,
    required Color color,
  }) {
    final isSelected = selectedStatus == status;
    final theme = Theme.of(context);

    return InkWell(
      onTap: enabled
          ? () {
              if (onStatusChanged != null) {
                onStatusChanged!(status);
              }
            }
          : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? color.withOpacity(0.15)
              : color.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected
                ? color
                : color.withOpacity(0.3),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: enabled ? color : color.withOpacity(0.5),
              size: 24,
            ),
            if (showLabels) ...[
              const SizedBox(height: 4),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: enabled ? color : color.withOpacity(0.5),
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Dropdown-style status selector for inline usage in forms
///
/// Uses a SegmentedButton or similar control for status selection
class StatusSelectorDropdown extends StatelessWidget {
  /// Currently selected status
  final safety.SafetyStatusType? selectedStatus;

  /// Callback when status is changed
  final StatusSelectedCallback? onStatusChanged;

  /// Whether the widget is enabled
  final bool enabled;

  const StatusSelectorDropdown({
    super.key,
    this.selectedStatus,
    this.onStatusChanged,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SegmentedButton<safety.SafetyStatusType>(
      segments: const [
        ButtonSegment(
          value: safety.SafetyStatusType.safe,
          label: Text('Safe'),
          icon: Icon(Icons.check_circle, size: 18),
        ),
        ButtonSegment(
          value: safety.SafetyStatusType.needHelp,
          label: Text('Need Help'),
          icon: Icon(Icons.help, size: 18),
        ),
        ButtonSegment(
          value: safety.SafetyStatusType.emergency,
          label: Text('Emergency'),
          icon: Icon(Icons.warning, size: 18),
        ),
      ],
      selected: selectedStatus != null
          ? {selectedStatus!}
          : {},
      onSelectionChanged: enabled
          ? (Set<safety.SafetyStatusType> newSelection) {
              if (newSelection.isNotEmpty && onStatusChanged != null) {
                onStatusChanged!(newSelection.first);
              }
            }
          : null,
      enabled: enabled,
      style: ButtonStyle(
        backgroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            final status = selectedStatus;
            if (status == safety.SafetyStatusType.safe) {
              return Colors.green.withOpacity(0.15);
            } else if (status == safety.SafetyStatusType.needHelp) {
              return Colors.orange.withOpacity(0.15);
            } else if (status == safety.SafetyStatusType.emergency) {
              return Colors.red.withOpacity(0.15);
            }
          }
          return null;
        }),
        foregroundColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            final status = selectedStatus;
            if (status == safety.SafetyStatusType.safe) {
              return Colors.green.shade700;
            } else if (status == safety.SafetyStatusType.needHelp) {
              return Colors.orange.shade700;
            } else if (status == safety.SafetyStatusType.emergency) {
              return Colors.red.shade700;
            }
          }
          return theme.colorScheme.onSurface;
        }),
      ),
    );
  }
}

/// Display widget for showing selected status (non-interactive)
///
/// Used in cards, lists, and detail views to display status
class StatusDisplayWidget extends StatelessWidget {
  /// Status to display
  final safety.SafetyStatusType status;

  /// Display style
  final StatusDisplayStyle style;

  /// Optional custom label
  final String? customLabel;

  /// Size of the indicator (for icon style)
  final double size;

  const StatusDisplayWidget({
    super.key,
    required this.status,
    this.style = StatusDisplayStyle.chip,
    this.customLabel,
    this.size = 24,
  });

  @override
  Widget build(BuildContext context) {
    final color = _getStatusColor();
    final icon = _getStatusIcon();
    final label = customLabel ?? _getStatusLabel();

    switch (style) {
      case StatusDisplayStyle.chip:
        return _buildChip(color, label);
      case StatusDisplayStyle.icon:
        return _buildIcon(color, icon);
      case StatusDisplayStyle.iconWithLabel:
        return _buildIconWithLabel(color, icon, label);
      case StatusDisplayStyle.badge:
        return _buildBadge(color, icon, label);
    }
  }

  Widget _buildChip(Color color, String label) {
    return Chip(
      avatar: Icon(
        _getStatusIcon(),
        size: 18,
        color: color,
      ),
      label: Text(
        label,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w600,
          fontSize: 12,
        ),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color),
      visualDensity: VisualDensity.compact,
    );
  }

  Widget _buildIcon(Color color, IconData icon) {
    return Icon(
      icon,
      size: size,
      color: color,
    );
  }

  Widget _buildIconWithLabel(Color color, IconData icon, String label) {
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

  Widget _buildBadge(Color color, IconData icon, String label) {
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
            icon,
            size: size * 0.7,
            color: Colors.white,
          ),
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
      ),
    );
  }

  Color _getStatusColor() {
    switch (status) {
      case safety.SafetyStatusType.safe:
        return Colors.green;
      case safety.SafetyStatusType.needHelp:
        return Colors.orange;
      case safety.SafetyStatusType.emergency:
        return Colors.red;
      case safety.SafetyStatusType.unknown:
        return Colors.grey;
    }
  }

  IconData _getStatusIcon() {
    switch (status) {
      case safety.SafetyStatusType.safe:
        return Icons.check_circle;
      case safety.SafetyStatusType.needHelp:
        return Icons.help;
      case safety.SafetyStatusType.emergency:
        return Icons.warning;
      case safety.SafetyStatusType.unknown:
        return Icons.help_outline;
    }
  }

  String _getStatusLabel() {
    switch (status) {
      case safety.SafetyStatusType.safe:
        return "I'm Safe";
      case safety.SafetyStatusType.needHelp:
        return 'Need Help';
      case safety.SafetyStatusType.emergency:
        return 'Emergency';
      case safety.SafetyStatusType.unknown:
        return 'Unknown';
    }
  }
}

/// Display style for status display widget
enum StatusDisplayStyle {
  /// Chip with icon and label
  chip,
  /// Icon only
  icon,
  /// Icon with label (horizontal row)
  iconWithLabel,
  /// Badge style with solid background
  badge,
}
