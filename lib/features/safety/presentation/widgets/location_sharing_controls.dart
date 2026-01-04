import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/trusted_contact.dart';
import '../providers/safety_providers.dart';

/// Callback type for when location sharing is toggled
typedef LocationSharingToggleCallback = void Function(
  List<String> contactIds,
  bool enabled,
);

/// Callback type for share now action
typedef ShareNowCallback = void Function(List<String> contactIds);

/// Callback type for stop sharing action
typedef StopSharingCallback = void Function(List<String> contactIds);

/// Reusable widget for controlling location sharing preferences
///
/// Features:
/// - Toggle location sharing for individual contacts
/// - Share location with selected contacts now
/// - Stop sharing location with selected contacts
/// - Shows current location sharing status for each contact
/// - Select all / deselect all functionality
/// - Filter contacts by permission level
/// - Display mode toggle (list/chip view)
///
/// Can be used in:
/// - Location sharing screen
/// - Trusted contacts screen
/// - Settings screen
/// - Check-in screens
///
/// Example usage:
/// ```dart
/// LocationSharingControls(
///   contacts: trustedContacts,
///   onShareNow: (contactIds) => shareLocation(contactIds),
///   onStopSharing: (contactIds) => stopSharing(contactIds),
///   onToggleSharing: (contactIds, enabled) => updatePreferences(contactIds, enabled),
/// )
/// ```
class LocationSharingControls extends ConsumerStatefulWidget {
  /// List of trusted contacts to control location sharing for
  final List<TrustedContact> contacts;

  /// Callback when user wants to share location now
  final ShareNowCallback? onShareNow;

  /// Callback when user wants to stop sharing
  final StopSharingCallback? onStopSharing;

  /// Callback when location sharing is toggled for contacts
  final LocationSharingToggleCallback? onToggleSharing;

  /// Whether to show the header section
  final bool showHeader;

  /// Whether to show action buttons
  final bool showActions;

  /// Whether to show select all/deselect all
  final bool showSelectAll;

  /// Display mode for the controls
  final LocationSharingDisplayMode displayMode;

  /// Optional custom title
  final String? title;

  /// Whether the widget is enabled (for loading/disabled states)
  final bool enabled;

  const LocationSharingControls({
    super.key,
    required this.contacts,
    this.onShareNow,
    this.onStopSharing,
    this.onToggleSharing,
    this.showHeader = true,
    this.showActions = true,
    this.showSelectAll = true,
    this.displayMode = LocationSharingDisplayMode.list,
    this.title,
    this.enabled = true,
  });

  @override
  ConsumerState<LocationSharingControls> createState() =>
      _LocationSharingControlsState();
}

class _LocationSharingControlsState
    extends ConsumerState<LocationSharingControls> {
  final Set<String> _selectedContactIds = {};

  /// Gets list of selected contact objects
  List<TrustedContact> get _selectedContacts {
    return widget.contacts
        .where((contact) => _selectedContactIds.contains(contact.id))
        .toList();
  }

  /// Gets list of contacts with location sharing enabled
  List<TrustedContact> get _contactsWithSharingEnabled {
    return widget.contacts
        .where((contact) => contact.locationSharingEnabled)
        .toList();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // Header section
        if (widget.showHeader) ...[
          _buildHeader(context),
          const SizedBox(height: 16),
        ],

        // Select all / deselect all
        if (widget.showSelectAll && widget.contacts.isNotEmpty) ...[
          _buildSelectAllRow(context),
          const SizedBox(height: 12),
        ],

        // Contacts list/chips
        if (widget.contacts.isEmpty) ...[
          _buildEmptyState(context),
        ] else ...[
          _buildContactsSection(context),
        ],

        // Action buttons
        if (widget.showActions) ...[
          const SizedBox(height: 16),
          _buildActionButtons(context),
        ],
      ],
    );
  }

  /// Builds the header section
  Widget _buildHeader(BuildContext context) {
    final theme = Theme.of(context);
    final sharingEnabledCount = _contactsWithSharingEnabled.length;

    return Row(
      children: [
        Icon(
          Icons.location_on,
          color: theme.colorScheme.primary,
          size: 24,
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.title ?? 'Location Sharing Controls',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (sharingEnabledCount > 0)
                Text(
                  '$sharingEnabledCount contact(s) receiving location updates',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the select all/deselect all row
  Widget _buildSelectAllRow(BuildContext context) {
    final theme = Theme.of(context);
    final allSelected = _selectedContactIds.length == widget.contacts.length;
    final someSelected = _selectedContactIds.isNotEmpty && !allSelected;

    return InkWell(
      onTap: widget.enabled
          ? () {
              setState(() {
                if (allSelected) {
                  _selectedContactIds.clear();
                } else {
                  _selectedContactIds.clear();
                  _selectedContactIds.addAll(
                    widget.contacts.map((c) => c.id),
                  );
                }
              });
            }
          : null,
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Checkbox(
              value: someSelected ? null : allSelected,
              onChanged: widget.enabled
                  ? (value) {
                      setState(() {
                        if (allSelected) {
                          _selectedContactIds.clear();
                        } else {
                          _selectedContactIds.clear();
                          _selectedContactIds.addAll(
                            widget.contacts.map((c) => c.id),
                          );
                        }
                      });
                    }
                  : null,
            ),
            Text(
              allSelected
                  ? 'Deselect All (${widget.contacts.length})'
                  : 'Select All (${widget.contacts.length})',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: widget.enabled
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withOpacity(0.38),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the contacts section based on display mode
  Widget _buildContactsSection(BuildContext context) {
    switch (widget.displayMode) {
      case LocationSharingDisplayMode.list:
        return _buildContactsList(context);
      case LocationSharingDisplayMode.chips:
        return _buildContactChips(context);
      case LocationSharingDisplayMode.compact:
        return _buildCompactList(context);
    }
  }

  /// Builds contacts in list view
  Widget _buildContactsList(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.contacts.length,
      separatorBuilder: (context, index) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final contact = widget.contacts[index];
        final isSelected = _selectedContactIds.contains(contact.id);
        return _ContactListTile(
          contact: contact,
          isSelected: isSelected,
          enabled: widget.enabled,
          onSelectionChanged: (selected) {
            setState(() {
              if (selected) {
                _selectedContactIds.add(contact.id);
              } else {
                _selectedContactIds.remove(contact.id);
              }
            });
          },
          onToggleSharing: (enabled) {
            if (widget.onToggleSharing != null) {
              widget.onToggleSharing!([contact.id], enabled);
            }
          },
        );
      },
    );
  }

  /// Builds contacts in compact list view
  Widget _buildCompactList(BuildContext context) {
    return ListView.separated(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: widget.contacts.length,
      separatorBuilder: (context, index) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final contact = widget.contacts[index];
        final isSelected = _selectedContactIds.contains(contact.id);
        return _ContactCompactTile(
          contact: contact,
          isSelected: isSelected,
          enabled: widget.enabled,
          onSelectionChanged: (selected) {
            setState(() {
              if (selected) {
                _selectedContactIds.add(contact.id);
              } else {
                _selectedContactIds.remove(contact.id);
              }
            });
          },
          onToggleSharing: (enabled) {
            if (widget.onToggleSharing != null) {
              widget.onToggleSharing!([contact.id], enabled);
            }
          },
        );
      },
    );
  }

  /// Builds contacts as filter chips
  Widget _buildContactChips(BuildContext context) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: widget.contacts.map((contact) {
        final isSelected = _selectedContactIds.contains(contact.id);
        return FilterChip(
          label: Text(contact.name),
          selected: isSelected,
          onSelected: widget.enabled
              ? (selected) {
                  setState(() {
                    if (selected) {
                      _selectedContactIds.add(contact.id);
                    } else {
                      _selectedContactIds.remove(contact.id);
                    }
                  });
                }
              : null,
          avatar: CircleAvatar(
            backgroundColor: contact.locationSharingEnabled
                ? Theme.of(context).colorScheme.primary
                : Colors.grey,
            child: Icon(
              contact.locationSharingEnabled
                  ? Icons.location_on
                  : Icons.location_off,
              size: 16,
              color: Colors.white,
            ),
          ),
          selectedColor: Theme.of(context).colorScheme.primaryContainer,
          checkmarkColor: Theme.of(context).colorScheme.onPrimaryContainer,
        );
      }).toList(),
    );
  }

  /// Builds empty state
  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          Icon(
            Icons.contacts_outline,
            size: 48,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 12),
          Text(
            'No Contacts Available',
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            'Add trusted contacts to control location sharing',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
          ),
        ],
      ),
    );
  }

  /// Builds action buttons section
  Widget _buildActionButtons(BuildContext context) {
    final theme = Theme.of(context);
    final hasSelected = _selectedContactIds.isNotEmpty;
    final selectedWithSharing = _selectedContacts
        .where((c) => c.locationSharingEnabled)
        .toList();

    return Row(
      children: [
        // Share now button
        Expanded(
          child: FilledButton.icon(
            onPressed: (widget.enabled && hasSelected && widget.onShareNow != null)
                ? () {
                    final contactIds = _selectedContactIds.toList();
                    widget.onShareNow!(contactIds);
                  }
                : null,
            icon: const Icon(Icons.share_location, size: 18),
            label: const Text('Share Now'),
            style: FilledButton.styleFrom(
              backgroundColor: theme.colorScheme.primary,
            ),
          ),
        ),
        if (selectedWithSharing.isNotEmpty) ...[
          const SizedBox(width: 12),
          // Stop sharing button
          Expanded(
            child: FilledButton.icon(
              onPressed: (widget.enabled &&
                      widget.onStopSharing != null)
                  ? () {
                      final contactIds =
                          selectedWithSharing.map((c) => c.id).toList();
                      widget.onStopSharing!(contactIds);
                    }
                  : null,
              icon: const Icon(Icons.stop_circle, size: 18),
              label: const Text('Stop'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange,
              ),
            ),
          ),
        ],
      ],
    );
  }
}

/// List tile for individual contact in location sharing controls
class _ContactListTile extends StatelessWidget {
  final TrustedContact contact;
  final bool isSelected;
  final bool enabled;
  final ValueChanged<bool> onSelectionChanged;
  final ValueChanged<bool> onToggleSharing;

  const _ContactListTile({
    required this.contact,
    required this.isSelected,
    required this.enabled,
    required this.onSelectionChanged,
    required this.onToggleSharing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return CheckboxListTile(
      value: isSelected,
      onChanged: enabled
          ? (value) {
              if (value != null) {
                onSelectionChanged(value);
              }
            }
          : null,
      title: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: theme.colorScheme.primaryContainer,
            child: Text(
              contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  contact.name,
                  style: theme.textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  contact.phoneNumber,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      secondary: Switch(
        value: contact.locationSharingEnabled,
        onChanged: enabled
            ? (value) {
                onToggleSharing(value);
              }
            : null,
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 16,
        vertical: 4,
      ),
    );
  }
}

/// Compact tile for individual contact
class _ContactCompactTile extends StatelessWidget {
  final TrustedContact contact;
  final bool isSelected;
  final bool enabled;
  final ValueChanged<bool> onSelectionChanged;
  final ValueChanged<bool> onToggleSharing;

  const _ContactCompactTile({
    required this.contact,
    required this.isSelected,
    required this.enabled,
    required this.onSelectionChanged,
    required this.onToggleSharing,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Card(
      child: InkWell(
        onTap: enabled
            ? () {
                onSelectionChanged(!isSelected);
              }
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Checkbox(
                value: isSelected,
                onChanged: enabled
                    ? (value) {
                        if (value != null) {
                          onSelectionChanged(value);
                        }
                      }
                    : null,
              ),
              const SizedBox(width: 8),
              CircleAvatar(
                radius: 16,
                backgroundColor: theme.colorScheme.primaryContainer,
                child: Text(
                  contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                  style: theme.textTheme.labelLarge?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      contact.name,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(
                          contact.locationSharingEnabled
                              ? Icons.location_on
                              : Icons.location_off,
                          size: 14,
                          color: contact.locationSharingEnabled
                              ? theme.colorScheme.primary
                              : Colors.grey,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          contact.locationSharingEnabled
                              ? 'Sharing enabled'
                              : 'Not sharing',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Switch(
                value: contact.locationSharingEnabled,
                onChanged: enabled
                    ? (value) {
                        onToggleSharing(value);
                      }
                    : null,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Display mode for location sharing controls
enum LocationSharingDisplayMode {
  /// Full list view with detailed info
  list,

  /// Chip-based selection view
  chips,

  /// Compact list view with less detail
  compact,
}

/// Simplified location sharing toggle widget for single contact
///
/// Shows just a switch for toggling location sharing with optional label
class LocationSharingToggle extends StatelessWidget {
  /// Contact to show toggle for
  final TrustedContact contact;

  /// Callback when toggle is changed
  final ValueChanged<bool>? onChanged;

  /// Whether the widget is enabled
  final bool enabled;

  /// Whether to show contact name
  final bool showName;

  /// Whether to wrap in a Card
  final bool wrapInCard;

  const LocationSharingToggle({
    super.key,
    required this.contact,
    this.onChanged,
    this.enabled = true,
    this.showName = true,
    this.wrapInCard = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final content = Row(
      children: [
        Icon(
          contact.locationSharingEnabled
              ? Icons.location_on
              : Icons.location_off,
          color: contact.locationSharingEnabled
              ? theme.colorScheme.primary
              : Colors.grey,
        ),
        if (showName) ...[
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Share location with ${contact.name}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: enabled
                    ? theme.colorScheme.onSurface
                    : theme.colorScheme.onSurface.withOpacity(0.38),
              ),
            ),
          ),
        ],
        Switch(
          value: contact.locationSharingEnabled,
          onChanged: enabled ? onChanged : null,
        ),
      ],
    );

    if (wrapInCard) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: content,
        ),
      );
    }

    return content;
  }
}

/// Quick location sharing button for sharing with all contacts
///
/// Provides a one-tap solution to share location with all eligible contacts
class QuickShareButton extends StatelessWidget {
  /// Callback to get list of contact IDs to share with
  final List<String> Function() getContactIds;

  /// Callback when button is pressed
  final VoidCallback? onShare;

  /// Whether sharing is in progress
  final bool isLoading;

  /// Number of contacts that will receive location
  final int contactCount;

  /// Button label
  final String label;

  /// Whether to show contact count
  final bool showCount;

  const QuickShareButton({
    super.key,
    required this.getContactIds,
    required this.contactCount,
    this.onShare,
    this.isLoading = false,
    this.label = 'Share Location',
    this.showCount = true,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final canShare = contactCount > 0 && !isLoading;

    return FilledButton.icon(
      onPressed: canShare ? onShare : null,
      icon: isLoading
          ? const SizedBox(
              width: 18,
              height: 18,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : const Icon(Icons.share_location, size: 18),
      label: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(label),
          if (showCount && contactCount > 0) ...[
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: Colors.white24,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                '$contactCount',
                style: const TextStyle(fontSize: 12),
              ),
            ),
          ],
        ],
      ),
      style: FilledButton.styleFrom(
        backgroundColor: theme.colorScheme.primary,
        disabledBackgroundColor: theme.colorScheme.surfaceContainerHighest,
      ),
    );
  }
}
