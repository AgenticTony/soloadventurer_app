import 'package:flutter/material.dart';
import '../../domain/entities/trusted_contact.dart';

/// Callback type for when a trusted contact card is tapped
typedef TrustedContactCardCallback = void Function(TrustedContact contact);

/// Widget for displaying individual trusted contact information
///
/// Shows contact details including:
/// - Avatar with initials
/// - Name and phone number
/// - Permission level chip
/// - Contact source (phone/community)
/// - Status indicators (location sharing, emergency alerts)
///
/// Can be used in lists or grids, with optional tap handling
class TrustedContactCard extends StatelessWidget {
  /// The trusted contact to display
  final TrustedContact contact;

  /// Optional callback when the card is tapped
  final TrustedContactCardCallback? onTap;

  /// Whether to show the status indicators
  final bool showStatusIndicators;

  /// Whether to show the source chip
  final bool showSourceChip;

  /// Whether to show a compact version (less padding, smaller fonts)
  final bool isCompact;

  const TrustedContactCard({
    super.key,
    required this.contact,
    this.onTap,
    this.showStatusIndicators = true,
    this.showSourceChip = true,
    this.isCompact = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      margin: isCompact
          ? const EdgeInsets.symmetric(horizontal: 8, vertical: 4)
          : const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap != null ? () => onTap!(contact) : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: EdgeInsets.all(isCompact ? 12.0 : 16.0),
          child: Row(
            children: [
              // Avatar
              _buildAvatar(context),
              const SizedBox(width: 16),

              // Contact info
              Expanded(
                child: _buildContactInfo(context),
              ),

              // Status indicators and actions
              if (showStatusIndicators) ...[
                const SizedBox(width: 8),
                _buildStatusIndicators(context),
              ],

              // Chevron if tappable
              if (onTap != null) ...[
                const SizedBox(width: 8),
                Icon(
                  Icons.chevron_right,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the contact avatar with initials
  Widget _buildAvatar(BuildContext context) {
    final theme = Theme.of(context);
    final size = isCompact ? 40.0 : 56.0;

    return CircleAvatar(
      radius: size / 2,
      backgroundColor: theme.colorScheme.primaryContainer,
      child: Text(
        contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
        style: theme.textTheme.titleLarge?.copyWith(
          color: theme.colorScheme.onPrimaryContainer,
          fontSize: isCompact ? 18 : null,
        ),
      ),
    );
  }

  /// Builds the main contact information section
  Widget _buildContactInfo(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Name
        Text(
          contact.name,
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: isCompact ? 15 : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 4),

        // Phone number
        Text(
          contact.phoneNumber,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: isCompact ? 13 : null,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),

        const SizedBox(height: 8),

        // Chips
        Wrap(
          spacing: 6,
          runSpacing: 4,
          children: [
            _buildPermissionChip(context),
            if (showSourceChip) _buildSourceChip(context),
          ],
        ),
      ],
    );
  }

  /// Builds the permission level chip with appropriate colors
  Widget _buildPermissionChip(BuildContext context) {
    final theme = Theme.of(context);

    String label;
    Color backgroundColor;
    Color foregroundColor;

    switch (contact.permission) {
      case ContactPermission.emergencyOnly:
        label = 'Emergency Only';
        backgroundColor = Colors.orange.withOpacity(0.1);
        foregroundColor = Colors.orange.shade700;
        break;
      case ContactPermission.checkIns:
        label = 'Check-ins';
        backgroundColor = Colors.blue.withOpacity(0.1);
        foregroundColor = Colors.blue.shade700;
        break;
      case ContactPermission.fullAccess:
        label = 'Full Access';
        backgroundColor = Colors.green.withOpacity(0.1);
        foregroundColor = Colors.green.shade700;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: foregroundColor.withOpacity(0.2),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getPermissionIcon(),
            size: isCompact ? 12 : 14,
            color: foregroundColor,
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              color: foregroundColor,
              fontWeight: FontWeight.w600,
              fontSize: isCompact ? 10 : 11,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the contact source chip
  Widget _buildSourceChip(BuildContext context) {
    final theme = Theme.of(context);

    final sourceLabel = contact.source == ContactSource.phone
        ? 'Phone'
        : 'Community';

    final sourceIcon = contact.source == ContactSource.phone
        ? Icons.contact_phone
        : Icons.group;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            sourceIcon,
            size: isCompact ? 12 : 14,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 4),
          Text(
            sourceLabel,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontSize: isCompact ? 10 : 11,
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the status indicators column
  Widget _buildStatusIndicators(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (contact.locationSharingEnabled)
          _StatusIndicator(
            icon: Icons.location_on,
            color: theme.colorScheme.primary,
            tooltip: 'Location sharing enabled',
            size: isCompact ? 18 : 20,
          ),
        if (contact.locationSharingEnabled &&
            contact.receivesEmergencyAlerts)
          const SizedBox(height: 4),
        if (contact.receivesEmergencyAlerts)
          _StatusIndicator(
            icon: Icons.notifications_active,
            color: theme.colorScheme.secondary,
            tooltip: 'Emergency alerts enabled',
            size: isCompact ? 18 : 20,
          ),
      ],
    );
  }

  /// Returns the appropriate icon for the permission level
  IconData _getPermissionIcon() {
    switch (contact.permission) {
      case ContactPermission.emergencyOnly:
        return Icons.warning_amber_rounded;
      case ContactPermission.checkIns:
        return Icons.check_circle_outline;
      case ContactPermission.fullAccess:
        return Icons.all_inclusive;
    }
  }
}

/// Status indicator icon widget for displaying contact features
class _StatusIndicator extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String tooltip;
  final double size;

  const _StatusIndicator({
    required this.icon,
    required this.color,
    required this.tooltip,
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Icon(
        icon,
        size: size,
        color: color,
      ),
    );
  }
}
