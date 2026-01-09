import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/safety/presentation/notifiers/location_sharing_notifier.dart';
import 'package:soloadventurer/features/safety/presentation/notifiers/trusted_contacts_notifier.dart';
import '../../../../core/services/location_service.dart';
import '../../domain/entities/location_update.dart';
import '../../domain/entities/trusted_contact.dart';
import '../providers/safety_providers.dart';

/// Screen to display and manage active location shares
/// Shows list of active location shares with options to stop sharing
class LocationSharingScreen extends ConsumerStatefulWidget {
  const LocationSharingScreen({super.key});

  @override
  ConsumerState<LocationSharingScreen> createState() =>
      _LocationSharingScreenState();
}

class _LocationSharingScreenState
    extends ConsumerState<LocationSharingScreen> {
  @override
  void initState() {
    super.initState();
    // Load active location shares when screen initializes
    Future.microtask(() {
      ref.read(locationSharingNotifierProvider.notifier).loadActiveShares();
    });
  }

  @override
  Widget build(BuildContext context) {
    final locationSharingAsync = ref.watch(locationSharingNotifierProvider);
    final trustedContactsAsync = ref.watch(trustedContactsNotifierProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Location Sharing'),
        actions: [
          // Info button to explain location sharing
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () => _showInfoDialog(context),
          ),
        ],
      ),
      body: locationSharingAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(),
        ),
        error: (error, stack) => _buildErrorWidget(context, error.toString()),
        data: (locationData) {
          return trustedContactsAsync.when(
            loading: () => const Center(
              child: CircularProgressIndicator(),
            ),
            error: (error, stack) => _buildErrorWidget(context, error.toString()),
            data: (trustedContacts) {
              final activeShares = locationData.activeShares;
              final latestLocation = locationData.latestLocation;

              if (activeShares.isEmpty && latestLocation == null) {
                return _buildEmptyState(context);
              }

              return SingleChildScrollView(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Current location card (if latest location available)
                    if (latestLocation != null) ...[
                      _buildCurrentLocationCard(context, latestLocation, trustedContacts),
                      const SizedBox(height: 24),
                    ],

                    // Active shares header
                    Text(
                      'Active Location Shares',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 12),

                    // Active shares list
                    if (activeShares.isEmpty)
                      _buildEmptyState(context)
                    else
                      ListView.separated(
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        itemCount: activeShares.length,
                        separatorBuilder: (context, index) => const SizedBox(height: 12),
                        itemBuilder: (context, index) {
                          final share = activeShares[index];
                          return _buildLocationShareCard(
                            context,
                            share,
                            trustedContacts,
                          );
                        },
                      ),

                    // Stop all sharing button (if there are active shares)
                    if (activeShares.isNotEmpty) ...[
                      const SizedBox(height: 24),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () => _confirmStopAllSharing(context, activeShares),
                          icon: const Icon(Icons.stop_circle),
                          label: const Text('Stop All Location Sharing'),
                          style: FilledButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 16),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showShareOptions(context),
        icon: const Icon(Icons.share_location),
        label: const Text('Share Location'),
      ),
    );
  }

  Widget _buildCurrentLocationCard(
    BuildContext context,
    LocationUpdate latestLocation,
    List<TrustedContact> trustedContacts,
  ) {
    final theme = Theme.of(context);
    final contactNames = _getContactNames(
      latestLocation.sharedWithContactIds,
      trustedContacts,
    );

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: latestLocation.isEmergency
              ? [Colors.red.shade400, Colors.red.shade600]
              : [theme.colorScheme.primary, theme.colorScheme.secondary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                latestLocation.isEmergency
                    ? Icons.emergency
                    : Icons.my_location,
                color: Colors.white,
              ),
              const SizedBox(width: 8),
              Text(
                latestLocation.isEmergency
                    ? 'Emergency Location'
                    : 'Current Location',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.location_on,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  latestLocation.placeName ??
                      latestLocation.address ??
                      '${latestLocation.latitude.toStringAsFixed(4)}, ${latestLocation.longitude.toStringAsFixed(4)}',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          if (latestLocation.accuracy != null) ...[
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(
                  Icons.gps_fixed,
                  color: Colors.white70,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  'Accuracy: ±${latestLocation.accuracy!.toStringAsFixed(0)}m',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ],
          const SizedBox(height: 12),
          Row(
            children: [
              const Icon(
                Icons.people,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'Sharing with ${contactNames.isEmpty ? latestLocation.sharedWithContactIds.length : contactNames.length} contact(s)',
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Updated ${_formatTimestamp(latestLocation.createdAt)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.white70,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLocationShareCard(
    BuildContext context,
    LocationUpdate share,
    List<TrustedContact> trustedContacts,
  ) {
    final theme = Theme.of(context);
    final contactNames = _getContactNames(
      share.sharedWithContactIds,
      trustedContacts,
    );

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: share.isEmergency
            ? BorderSide(color: Colors.red.shade300, width: 2)
            : BorderSide.none,
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _viewLocationDetails(context, share, trustedContacts),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    share.isEmergency ? Icons.emergency : Icons.share_location,
                    color: share.isEmergency ? Colors.red : theme.colorScheme.primary,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          share.placeName ??
                              share.address ??
                              'Shared Location',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formatTimestamp(share.createdAt),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (share.isEmergency)
                    _buildStatusChip(context, 'Emergency', Colors.red)
                  else
                    _buildStatusChip(
                      context,
                      _getStatusLabel(share.sharingStatus),
                      _getStatusColor(share.sharingStatus),
                    ),
                ],
              ),
              if (share.accuracy != null) ...[
                const SizedBox(height: 12),
                Row(
                  children: [
                    Icon(
                      Icons.gps_fixed,
                      size: 16,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'Accuracy: ±${share.accuracy!.toStringAsFixed(0)}m',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
              const SizedBox(height: 12),
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 16,
                    color: Colors.grey[600],
                  ),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      _formatContactNames(contactNames),
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  TextButton.icon(
                    onPressed: () =>
                        _viewLocationDetails(context, share, trustedContacts),
                    icon: const Icon(Icons.visibility, size: 18),
                    label: const Text('View'),
                  ),
                  const SizedBox(width: 8),
                  FilledButton.icon(
                    onPressed: () => _confirmStopSharing(
                          context,
                          share,
                          trustedContacts,
                        ),
                    icon: const Icon(Icons.stop, size: 18),
                    label: const Text('Stop'),
                    style: FilledButton.styleFrom(
                      backgroundColor: Colors.orange,
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

  Widget _buildStatusChip(BuildContext context, String label, Color color) {
    return Chip(
      label: Text(
        label,
        style: const TextStyle(fontSize: 12),
      ),
      backgroundColor: color.withOpacity(0.1),
      side: BorderSide(color: color),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.location_off,
            size: 64,
            color: Theme.of(context).colorScheme.primary.withOpacity(0.5),
          ),
          const SizedBox(height: 16),
          Text(
            'No Active Location Sharing',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            'Share your location with trusted contacts to keep them informed',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Colors.grey,
                ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => _showShareOptions(context),
            icon: const Icon(Icons.share_location),
            label: const Text('Share Your Location'),
          ),
        ],
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
              'Error Loading Location Shares',
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
                    .read(locationSharingNotifierProvider.notifier)
                    .loadActiveShares();
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
          ],
        ),
      ),
    );
  }

  void _showShareOptions(BuildContext context) {
    final trustedContactsAsync = ref.read(trustedContactsNotifierProvider);

    trustedContactsAsync.when(
      loading: () => _showLoadingDialog(context),
      error: (error, stack) => _showErrorDialog(context, error.toString()),
      data: (trustedContacts) {
        final contactsWithSharing = trustedContacts
            .where((contact) => contact.locationSharingEnabled)
            .toList();

        if (contactsWithSharing.isEmpty) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('No Contacts Available'),
              content: const Text(
                'You don\'t have any trusted contacts with location sharing enabled. Go to Trusted Contacts to enable location sharing for your contacts.',
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
          return;
        }

        showModalBottomSheet(
          context: context,
          builder: (context) => SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ListTile(
                  leading: const Icon(Icons.my_location),
                  title: const Text('Share with All Contacts'),
                  subtitle: Text(
                    'Share with ${contactsWithSharing.length} contact(s)',
                  ),
                  onTap: () {
                    Navigator.of(context).pop();
                    _shareWithAllContacts(context, contactsWithSharing);
                  },
                ),
                ...contactsWithSharing.map((contact) => ListTile(
                      leading: CircleAvatar(
                        child: Text(
                          contact.name.isNotEmpty
                              ? contact.name[0].toUpperCase()
                              : '?',
                        ),
                      ),
                      title: Text(contact.name),
                      subtitle: Text(contact.phoneNumber),
                      onTap: () {
                        Navigator.of(context).pop();
                        _shareWithContact(context, contact);
                      },
                    )),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showLoadingDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(),
      ),
    );
  }

  void _showErrorDialog(BuildContext context, String error) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(error),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _shareWithContact(
    BuildContext context,
    TrustedContact contact,
  ) async {
    try {
      final locationService = ref.read(locationServiceProvider);
      final location = await locationService.getCurrentLocation(
        accuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      await ref
          .read(locationSharingNotifierProvider.notifier)
          .shareWithContact(
            latitude: location.latitude,
            longitude: location.longitude,
            contactId: contact.id,
            accuracy: location.accuracy,
            altitude: location.altitude,
            speed: location.speed,
            heading: location.heading,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Now sharing location with ${contact.name}'),
          action: SnackBarAction(
            label: 'View',
            onPressed: () {
              // Navigate to location sharing screen (already there)
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing location: ${e.toString()}'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _shareWithContact(context, contact),
          ),
        ),
      );
    }
  }

  void _shareWithAllContacts(
    BuildContext context,
    List<TrustedContact> contacts,
  ) async {
    try {
      final locationService = ref.read(locationServiceProvider);
      final location = await locationService.getCurrentLocation(
        accuracy: LocationAccuracy.high,
      );

      if (!mounted) return;

      final contactIds = contacts.map((c) => c.id).toList();

      await ref
          .read(locationSharingNotifierProvider.notifier)
          .shareLocation(
            latitude: location.latitude,
            longitude: location.longitude,
            shareWithContactIds: contactIds,
            accuracy: location.accuracy,
            altitude: location.altitude,
            speed: location.speed,
            heading: location.heading,
          );

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Now sharing location with ${contacts.length} contact(s)'),
          action: SnackBarAction(
            label: 'View',
            onPressed: () {
              // Navigate to location sharing screen (already there)
            },
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error sharing location: ${e.toString()}'),
          action: SnackBarAction(
            label: 'Retry',
            onPressed: () => _shareWithAllContacts(context, contacts),
          ),
        ),
      );
    }
  }

  void _confirmStopSharing(
    BuildContext context,
    LocationUpdate share,
    List<TrustedContact> trustedContacts,
  ) {
    final contactNames = _getContactNames(
      share.sharedWithContactIds,
      trustedContacts,
    );
    final namesText = contactNames.isEmpty
        ? '${share.sharedWithContactIds.length} contact(s)'
        : contactNames.join(', ');

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stop Location Sharing'),
        content: Text(
          'Stop sharing location with $namesText?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _stopSharing(context, share.sharedWithContactIds, contactNames);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Stop Sharing'),
          ),
        ],
      ),
    );
  }

  void _confirmStopAllSharing(
    BuildContext context,
    List<LocationUpdate> activeShares,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Stop All Location Sharing'),
        content: const Text(
          'Are you sure you want to stop all location sharing? Your trusted contacts will no longer receive your location updates.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              _stopAllSharing(context);
            },
            style: TextButton.styleFrom(
              foregroundColor: Theme.of(context).colorScheme.error,
            ),
            child: const Text('Stop All'),
          ),
        ],
      ),
    );
  }

  void _stopSharing(
    BuildContext context,
    List<String> contactIds,
    List<String> contactNames,
  ) {
    ref
        .read(locationSharingNotifierProvider.notifier)
        .stopSharing(contactIds);

    final namesText = contactNames.isEmpty
        ? '${contactIds.length} contact(s)'
        : contactNames.join(', ');

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Stopped sharing location with $namesText'),
        action: SnackBarAction(
          label: 'UNDO',
          onPressed: () {
            // TODO: Implement undo functionality
          },
        ),
      ),
    );
  }

  void _stopAllSharing(BuildContext context) {
    ref.read(locationSharingNotifierProvider.notifier).stopAllSharing();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Stopped all location sharing'),
      ),
    );
  }

  void _viewLocationDetails(
    BuildContext context,
    LocationUpdate share,
    List<TrustedContact> trustedContacts,
  ) {
    showModalBottomSheet(
      context: context,
      builder: (context) => _LocationDetailsSheet(
        share: share,
        trustedContacts: trustedContacts,
      ),
    );
  }

  void _showInfoDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('About Location Sharing'),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Share your real-time location with trusted contacts so they can track your safety during adventures.',
                style: TextStyle(fontSize: 14),
              ),
              SizedBox(height: 16),
              Text(
                'Location sharing is:',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              SizedBox(height: 8),
              Text(
                '• Privacy-first: You control who sees your location',
                style: TextStyle(fontSize: 13),
              ),
              Text(
                '• Battery-efficient: Uses minimal power',
                style: TextStyle(fontSize: 13),
              ),
              Text(
                '• Real-time: Contacts get updates as you move',
                style: TextStyle(fontSize: 13),
              ),
              Text(
                '• Emergency-ready: Can be triggered during emergencies',
                style: TextStyle(fontSize: 13),
              ),
              SizedBox(height: 16),
              Text(
                'You can start or stop location sharing at any time. Emergency SOS automatically shares your location with all contacts.',
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

  List<String> _getContactNames(
    List<String> contactIds,
    List<TrustedContact> trustedContacts,
  ) {
    return contactIds
        .map((id) => trustedContacts.firstWhere(
              (contact) => contact.id == id,
              orElse: () => TrustedContact(
                id: id,
                userId: '',
                name: 'Unknown Contact',
                phoneNumber: '',
                addedAt: DateTime.now(),
              ),
            ))
        .map((contact) => contact.name)
        .toList();
  }

  String _formatContactNames(List<String> names) {
    if (names.isEmpty) return 'No contacts';
    if (names.length == 1) return names[0];
    if (names.length == 2) return '${names[0]} and ${names[1]}';
    return '${names[0]}, ${names[1]} and ${names.length - 2} more';
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String _getStatusLabel(LocationSharingStatus status) {
    switch (status) {
      case LocationSharingStatus.active:
        return 'Active';
      case LocationSharingStatus.paused:
        return 'Paused';
      case LocationSharingStatus.ended:
        return 'Ended';
    }
  }

  Color _getStatusColor(LocationSharingStatus status) {
    switch (status) {
      case LocationSharingStatus.active:
        return Colors.green;
      case LocationSharingStatus.paused:
        return Colors.orange;
      case LocationSharingStatus.ended:
        return Colors.grey;
    }
  }
}

/// Bottom sheet widget for displaying location details
class _LocationDetailsSheet extends StatelessWidget {
  final LocationUpdate share;
  final List<TrustedContact> trustedContacts;

  const _LocationDetailsSheet({
    required this.share,
    required this.trustedContacts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contactNames = _getContactNames();

    return Container(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                share.isEmergency ? Icons.emergency : Icons.share_location,
                color: share.isEmergency
                    ? Colors.red
                    : theme.colorScheme.primary,
                size: 32,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      share.isEmergency
                          ? 'Emergency Location Share'
                          : 'Location Share',
                      style: theme.textTheme.titleLarge,
                    ),
                    Text(
                      _formatTimestamp(share.createdAt),
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(height: 32),
          _DetailRow(
            icon: Icons.location_on,
            label: 'Location',
            value: share.placeName ??
                share.address ??
                '${share.latitude.toStringAsFixed(6)}, ${share.longitude.toStringAsFixed(6)}',
          ),
          if (share.accuracy != null) ...[
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.gps_fixed,
              label: 'Accuracy',
              value: '±${share.accuracy!.toStringAsFixed(0)} meters',
            ),
          ],
          if (share.altitude != null) ...[
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.terrain,
              label: 'Altitude',
              value: '${share.altitude!.toStringAsFixed(0)} meters',
            ),
          ],
          if (share.speed != null && share.speed! > 0) ...[
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.speed,
              label: 'Speed',
              value: '${(share.speed! * 3.6).toStringAsFixed(1)} km/h',
            ),
          ],
          if (share.batteryLevel != null) ...[
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.battery_full,
              label: 'Battery',
              value: '${share.batteryLevel}%',
            ),
          ],
          const SizedBox(height: 16),
          _DetailRow(
            icon: Icons.status,
            label: 'Status',
            value: _getStatusLabel(share.sharingStatus),
          ),
          const SizedBox(height: 16),
          _DetailRow(
            icon: Icons.people,
            label: 'Shared With',
            value: contactNames.isEmpty
                ? '${share.sharedWithContactIds.length} contact(s)'
                : contactNames.join(', '),
          ),
          if (share.isEmergency) ...[
            const SizedBox(height: 16),
            const _DetailRow(
              icon: Icons.emergency,
              label: 'Type',
              value: 'Emergency Share',
              valueColor: Colors.red,
            ),
          ],
          if (share.checkInId != null) ...[
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.check_circle,
              label: 'Check-in ID',
              value: share.checkInId!,
            ),
          ],
          if (share.emergencyAlertId != null) ...[
            const SizedBox(height: 16),
            _DetailRow(
              icon: Icons.alert,
              label: 'Emergency Alert ID',
              value: share.emergencyAlertId!,
            ),
          ],
        ],
      ),
    );
  }

  List<String> _getContactNames() {
    return share.sharedWithContactIds
        .map((id) => trustedContacts.firstWhere(
              (contact) => contact.id == id,
              orElse: () => TrustedContact(
                id: id,
                userId: '',
                name: 'Unknown Contact',
                phoneNumber: '',
                addedAt: DateTime.now(),
              ),
            ))
        .map((contact) => contact.name)
        .toList();
  }

  String _formatTimestamp(DateTime timestamp) {
    return '${timestamp.toString().split(' ')[0]} at ${timestamp.toString().split(' ')[1].substring(0, 5)}';
  }

  String _getStatusLabel(LocationSharingStatus status) {
    switch (status) {
      case LocationSharingStatus.active:
        return 'Active';
      case LocationSharingStatus.paused:
        return 'Paused';
      case LocationSharingStatus.ended:
        return 'Ended';
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
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
