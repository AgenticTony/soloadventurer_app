import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/safety/presentation/notifiers/trusted_contacts_notifier.dart';
import '../../domain/entities/trusted_contact.dart';
import '../providers/safety_providers.dart';
import 'add_edit_trusted_contact_screen.dart';

/// Screen to display and manage trusted contacts
/// Shows list of contacts with options to add, edit, or remove them
class TrustedContactsScreen extends ConsumerStatefulWidget {
  const TrustedContactsScreen({super.key});

  @override
  ConsumerState<TrustedContactsScreen> createState() =>
      _TrustedContactsScreenState();
}

class _TrustedContactsScreenState extends ConsumerState<TrustedContactsScreen> {
  @override
  void initState() {
    super.initState();
    // Load contacts when screen initializes
    Future.microtask(() {
      ref.read(trustedContactsNotifierProvider.notifier).loadContacts();
    });
  }

  @override
  Widget build(BuildContext context) {
    final contactsAsync = ref.watch(trustedContactsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Trusted Contacts'),
        actions: [
          // Info button to explain trusted contacts
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: contactsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => _buildErrorWidget(context, error.toString()),
        data: (contacts) {
          if (contacts.isEmpty) {
            return _buildEmptyState(context);
          }

          return RefreshIndicator(
            onRefresh: () async {
              await ref
                  .read(trustedContactsNotifierProvider.notifier)
                  .loadContacts();
            },
            child: ListView.separated(
              itemCount: contacts.length,
              padding: const EdgeInsets.symmetric(vertical: 8),
              separatorBuilder: (context, index) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final contact = contacts[index];
                return _buildContactTile(context, contact);
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToAddContact(context),
        icon: const Icon(Icons.add),
        label: const Text('Add Contact'),
      ),
    );
  }

  Widget _buildContactTile(
    BuildContext context,
    TrustedContact contact,
  ) {
    final theme = Theme.of(context);

    return ListTile(
      leading: CircleAvatar(
        child: Text(
          contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
          style: theme.textTheme.titleLarge,
        ),
      ),
      title: Text(
        contact.name,
        style: theme.textTheme.titleMedium,
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(contact.phoneNumber),
          const SizedBox(height: 4),
          Wrap(
            spacing: 4,
            children: [
              _buildPermissionChip(context, contact.permission),
              if (contact.source == ContactSource.phone)
                _buildSourceChip(context, 'Phone'),
              if (contact.source == ContactSource.community)
                _buildSourceChip(context, 'Community'),
            ],
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (contact.locationSharingEnabled)
            Icon(
              Icons.location_on,
              size: 20,
              color: theme.colorScheme.primary,
            ),
          if (contact.receivesEmergencyAlerts)
            Icon(
              Icons.notifications_active,
              size: 20,
              color: theme.colorScheme.secondary,
            ),
          PopupMenuButton<String>(
            onSelected: (value) => _handleMenuAction(context, value, contact),
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('Edit'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'toggle_location',
                child: Row(
                  children: [
                    Icon(Icons.location_on),
                    SizedBox(width: 8),
                    Text('Toggle Location Sharing'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'toggle_emergency',
                child: Row(
                  children: [
                    Icon(Icons.notifications_active),
                    SizedBox(width: 8),
                    Text('Toggle Emergency Alerts'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete, color: Colors.red),
                    SizedBox(width: 8),
                    Text('Remove', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      onTap: () => _viewContactDetails(context, contact),
    );
  }

  Widget _buildPermissionChip(BuildContext context, ContactPermission permission) {
    String label;
    Color color;

    switch (permission) {
      case ContactPermission.emergencyOnly:
        label = 'Emergency Only';
        color = Colors.orange;
        break;
      case ContactPermission.checkIns:
        label = 'Check-ins';
        color = Colors.blue;
        break;
      case ContactPermission.fullAccess:
        label = 'Full Access';
        color = Colors.green;
        break;
    }

    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 10),
      ),
      backgroundColor: color.withOpacity(0.1),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildSourceChip(BuildContext context, String source) {
    return Chip(
      label: Text(
        source,
        style: const TextStyle(fontSize: 10),
      ),
      backgroundColor: Colors.grey.withOpacity(0.1),
      padding: EdgeInsets.zero,
      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
            ),
            const SizedBox(height: 16),
            Text(
              'No Trusted Contacts Yet',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Add trusted contacts who will receive your location and safety alerts',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _navigateToAddContact(context),
              icon: const Icon(Icons.add),
              label: const Text('Add Your First Contact'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text(
              'Error Loading Contacts',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              error,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                ref
                    .read(trustedContactsNotifierProvider.notifier)
                    .loadContacts();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  void _handleMenuAction(
    BuildContext context,
    String action,
    TrustedContact contact,
  ) {
    switch (action) {
      case 'edit':
        _navigateToEditContact(context, contact);
        break;
      case 'toggle_location':
        _toggleLocationSharing(contact);
        break;
      case 'toggle_emergency':
        _toggleEmergencyAlerts(contact);
        break;
      case 'delete':
        _confirmDeleteContact(context, contact);
        break;
    }
  }

  void _navigateToAddContact(BuildContext context) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => const AddEditTrustedContactScreen(),
      ),
    );
  }

  void _navigateToEditContact(BuildContext context, TrustedContact contact) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => AddEditTrustedContactScreen(
          contact: contact,
        ),
      ),
    );
  }

  void _viewContactDetails(BuildContext context, TrustedContact contact) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ContactDetailsSheet(contact: contact),
    );
  }

  void _toggleLocationSharing(TrustedContact contact) {
    ref
        .read(trustedContactsNotifierProvider.notifier)
        .updateLocationSharing(contact.id, !contact.locationSharingEnabled);
  }

  void _toggleEmergencyAlerts(TrustedContact contact) {
    ref
        .read(trustedContactsNotifierProvider.notifier)
        .updateEmergencyAlerts(contact.id, !contact.receivesEmergencyAlerts);
  }

  void _confirmDeleteContact(BuildContext context, TrustedContact contact) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Trusted Contact'),
        content: Text(
          'Are you sure you want to remove ${contact.name} from your trusted contacts?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _removeContact(contact);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  void _removeContact(TrustedContact contact) {
    ref
        .read(trustedContactsNotifierProvider.notifier)
        .removeContact(contact.id);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${contact.name} removed from trusted contacts'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            // TODO: Implement undo functionality
          },
        ),
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Trusted Contacts'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Trusted contacts are people who will receive your safety alerts and location updates during emergencies.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              Text(
                'Permission Levels:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                '• Emergency Only: Only receives alerts during emergencies',
                style: TextStyle(fontSize: 13),
              ),
              Text(
                '• Check-ins: Receives check-in notifications and emergencies',
                style: TextStyle(fontSize: 13),
              ),
              Text(
                '• Full Access: Receives everything including location sharing',
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 16),
              Text(
                'You can add contacts from your phone or the SoloAdventurer community.',
                style: TextStyle(fontSize: 14),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Got it'),
          ),
        ],
      ),
    );
  }
}

/// Bottom sheet widget for displaying contact details
class _ContactDetailsSheet extends StatelessWidget {
  final TrustedContact contact;

  const _ContactDetailsSheet({required this.contact});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 30,
                child: Text(
                  contact.name.isNotEmpty
                      ? contact.name[0].toUpperCase()
                      : '?',
                  style: theme.textTheme.headlineMedium,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      contact.name,
                      style: theme.textTheme.titleLarge,
                    ),
                    if (contact.email != null)
                      Text(
                        contact.email!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: Colors.grey,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          _DetailRow(
            icon: Icons.phone,
            label: 'Phone',
            value: contact.phoneNumber,
          ),
          if (contact.email != null) ...[
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.email,
              label: 'Email',
              value: contact.email!,
            ),
          ],
          const SizedBox(height: 16),
          _DetailRow(
            icon: Icons.source,
            label: 'Source',
            value: contact.source == ContactSource.phone
                ? 'Phone Contact'
                : 'Community Member',
          ),
          const SizedBox(height: 16),
          _DetailRow(
            icon: Icons.security,
            label: 'Permission',
            value: _getPermissionLabel(contact.permission),
          ),
          const SizedBox(height: 16),
          _DetailRow(
            icon: Icons.location_on,
            label: 'Location Sharing',
            value: contact.locationSharingEnabled ? 'Enabled' : 'Disabled',
            valueColor: contact.locationSharingEnabled ? Colors.green : Colors.grey,
          ),
          const SizedBox(height: 16),
          _DetailRow(
            icon: Icons.notifications,
            label: 'Emergency Alerts',
            value: contact.receivesEmergencyAlerts ? 'Enabled' : 'Disabled',
            valueColor:
            contact.receivesEmergencyAlerts ? Colors.green : Colors.grey,
          ),
          const SizedBox(height: 16),
          _DetailRow(
            icon: Icons.check_circle,
            label: 'Check-in Notifications',
            value: contact.receivesCheckIns ? 'Enabled' : 'Disabled',
            valueColor: contact.receivesCheckIns ? Colors.green : Colors.grey,
          ),
          if (contact.notes != null && contact.notes!.isNotEmpty) ...[
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.note,
              label: 'Notes',
              value: contact.notes!,
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Added on ${contact.addedAt.toLocal().toString().split(' ')[0]}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }

  String _getPermissionLabel(ContactPermission permission) {
    switch (permission) {
      case ContactPermission.emergencyOnly:
        return 'Emergency Only';
      case ContactPermission.checkIns:
        return 'Check-ins';
      case ContactPermission.fullAccess:
        return 'Full Access';
    }
  }
}

/// Helper widget for displaying detail rows
class _DetailRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow({
    required this.icon,
    required this.label,
    required this.value,
    this.valueColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.grey[600]),
        const SizedBox(width: 12),
        Text(
          '$label:',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            value,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: valueColor ?? theme.colorScheme.onSurface,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ],
    );
  }
}
