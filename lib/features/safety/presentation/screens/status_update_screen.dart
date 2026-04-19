import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/safety_status.dart' as safety;
import '../../domain/entities/trusted_contact.dart';
import '../providers/safety_providers.dart';
import '../../../auth/presentation/providers/auth_notifier_provider.dart';
import '../../../../core/services/location_service.dart' as core;

/// Screen for updating safety status
///
/// Allows users to:
/// - Update their current safety status (safe, need help, emergency)
/// - Add an optional message describing their situation
/// - Share their current location with trusted contacts
/// - See which contacts will be notified
class StatusUpdateScreen extends ConsumerStatefulWidget {
  const StatusUpdateScreen({super.key});

  @override
  ConsumerState<StatusUpdateScreen> createState() => _StatusUpdateScreenState();
}

class _StatusUpdateScreenState extends ConsumerState<StatusUpdateScreen> {
  final _messageController = TextEditingController();

  safety.SafetyStatusType? _selectedStatus;
  safety.SafetyStatusLocation? _currentLocation;
  bool _isLoadingLocation = false;
  String? _locationError;
  bool _shareLocation = true;

  @override
  void initState() {
    super.initState();
    // Initialize with current status
    _selectedStatus = null; // Will be loaded when state is available

    // Get current location if location sharing is enabled
    if (_shareLocation) {
      _getCurrentLocation();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
      _locationError = null;
    });

    try {
      final locationService = ref.read(locationServiceProvider);
      final locationData = await locationService.getCurrentLocation(
        accuracy: core.LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = safety.SafetyStatusLocation(
          latitude: locationData.latitude,
          longitude: locationData.longitude,
          accuracy: locationData.accuracy,
          altitude: locationData.altitude,
          timestamp: locationData.timestamp,
        );
        _isLoadingLocation = false;
      });
    } catch (e) {
      setState(() {
        _locationError = e.toString();
        _isLoadingLocation = false;
      });
    }
  }

  Future<void> _updateStatus() async {
    if (_selectedStatus == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a status'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final user = ref.read(authProvider).value?.user;
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to update status'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (_shareLocation &&
        _currentLocation == null &&
        _locationError != null &&
        _locationError!.isNotEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Waiting for location...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final notifier = ref.read(safetyProvider.notifier);

    try {
      await notifier.updateSafetyStatus(
        status: _selectedStatus!,
        message: _messageController.text.trim().isEmpty
            ? null
            : _messageController.text.trim(),
        location: _shareLocation ? _currentLocation : null,
        batteryLevel: await notifier.getBatteryLevel(),
      );

      if (mounted) {
        // Show success dialog
        await _showSuccessDialog();
        // Optionally navigate back
        if (mounted) {
          Navigator.of(context).pop();
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update status: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showSuccessDialog() async {
    final statusText = _getStatusDisplayText(_selectedStatus!);
    final statusColor = _getStatusColor(_selectedStatus!);

    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: Icon(
          _getStatusIcon(_selectedStatus!),
          color: statusColor,
          size: 64,
        ),
        title: const Text('Status Updated!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: statusColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                statusText,
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: statusColor,
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your trusted contacts have been notified.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
        actions: [
          FilledButton(
            onPressed: () => Navigator.of(context).pop(),
            style: FilledButton.styleFrom(
              backgroundColor: statusColor,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  IconData _getStatusIcon(safety.SafetyStatusType status) {
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

  Color _getStatusColor(safety.SafetyStatusType status) {
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

  String _getStatusDisplayText(safety.SafetyStatusType status) {
    switch (status) {
      case safety.SafetyStatusType.safe:
        return "You're Safe";
      case safety.SafetyStatusType.needHelp:
        return 'Need Help';
      case safety.SafetyStatusType.emergency:
        return 'Emergency';
      case safety.SafetyStatusType.unknown:
        return 'Unknown';
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safetyState = ref.watch(safetyProvider);
    final contactsState = ref.watch(trustedContactsProvider);
    final isProcessing = safetyState.isLoading;

    // Get contacts who will be notified (all contacts for status updates)
    final contactsToNotify = contactsState.value?.contacts ?? [];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Update Status'),
        actions: [
          if (isProcessing)
            const Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: Colors.white,
                  ),
                ),
              ),
            )
          else
            IconButton(
              onPressed: isProcessing ? null : _updateStatus,
              icon: const Icon(Icons.check, color: Colors.white),
              tooltip: 'Update Status',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Current status display
            if (safetyState.value?.currentStatus != null) ...[
              _buildCurrentStatusCard(theme, safetyState.value!.currentStatus!),
              const SizedBox(height: 24),
            ],

            // Status selection section
            _buildSectionHeader('Select Your Status'),
            const SizedBox(height: 8),
            Text(
              'Choose your current safety status',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            _buildStatusSelector(theme, isProcessing),
            const SizedBox(height: 24),

            // Location section
            _buildSectionHeader('Location'),
            const SizedBox(height: 8),
            Row(
              children: [
                Switch(
                  value: _shareLocation,
                  onChanged: isProcessing
                      ? null
                      : (value) {
                          setState(() {
                            _shareLocation = value;
                            if (value && _currentLocation == null) {
                              _getCurrentLocation();
                            }
                          });
                        },
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Share your location',
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        'Let your contacts know where you are',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            if (_shareLocation) ...[
              const SizedBox(height: 16),
              _buildLocationCard(theme, isProcessing),
            ],
            const SizedBox(height: 24),

            // Message section
            _buildSectionHeader('Message (Optional)'),
            const SizedBox(height: 8),
            Text(
              'Add more details about your situation',
              style: theme.textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'e.g., "I\'m at the hotel, everything is fine"',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.message),
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
              enabled: !isProcessing,
            ),
            const SizedBox(height: 24),

            // Contacts to notify section
            _buildSectionHeader('Contacts to Notify'),
            const SizedBox(height: 12),
            _buildContactsSection(theme, contactsToNotify),
            const SizedBox(height: 32),

            // Submit button
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: (isProcessing || _selectedStatus == null)
                    ? null
                    : _updateStatus,
                icon: isProcessing
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.white,
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                  isProcessing ? 'Updating...' : 'Update Status',
                  style: const TextStyle(fontSize: 16),
                ),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: _selectedStatus != null
                      ? _getStatusColor(_selectedStatus!)
                      : null,
                ),
              ),
            ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 8),
      child: Text(
        title,
        style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.primary,
            ),
      ),
    );
  }

  Widget _buildCurrentStatusCard(ThemeData theme, safety.SafetyStatus status) {
    final statusColor = _getStatusColor(status.status);
    final statusText = _getStatusDisplayText(status.status);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                _getStatusIcon(status.status),
                color: statusColor,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                'Current Status',
                style: theme.textTheme.titleSmall?.copyWith(
                  color: Colors.grey[700],
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            statusText,
            style: theme.textTheme.headlineSmall?.copyWith(
              color: statusColor,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (status.message != null) ...[
            const SizedBox(height: 8),
            Text(
              status.message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.grey[700],
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            'Updated ${_formatTimeAgo(status.timestamp)}',
            style: theme.textTheme.bodySmall?.copyWith(
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusSelector(ThemeData theme, bool isProcessing) {
    return Column(
      children: [
        // Safe status
        _buildStatusRadioTile(
          theme: theme,
          status: safety.SafetyStatusType.safe,
          title: 'I\'m Safe',
          subtitle: 'Let your contacts know you\'re okay',
          icon: Icons.check_circle,
          color: Colors.green,
          isProcessing: isProcessing,
        ),
        const Divider(height: 1),

        // Need help status
        _buildStatusRadioTile(
          theme: theme,
          status: safety.SafetyStatusType.needHelp,
          title: 'Need Help',
          subtitle: 'You need assistance but it\'s not an emergency',
          icon: Icons.help,
          color: Colors.orange,
          isProcessing: isProcessing,
        ),
        const Divider(height: 1),

        // Emergency status
        _buildStatusRadioTile(
          theme: theme,
          status: safety.SafetyStatusType.emergency,
          title: 'Emergency',
          subtitle: 'You\'re in an emergency situation',
          icon: Icons.warning,
          color: Colors.red,
          isProcessing: isProcessing,
        ),
      ],
    );
  }

  Widget _buildStatusRadioTile({
    required ThemeData theme,
    required safety.SafetyStatusType status,
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required bool isProcessing,
  }) {
    return RadioListTile<safety.SafetyStatusType>(
      title: Row(
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(width: 8),
          Text(title),
        ],
      ),
      subtitle: Text(subtitle),
      groupValue: _selectedStatus,
      value: status,
      onChanged: isProcessing
          ? null
          : (value) {
              setState(() {
                _selectedStatus = value;
              });
            },
      contentPadding: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 4,
      ),
      activeColor: color,
    );
  }

  Widget _buildLocationCard(ThemeData theme, bool isProcessing) {
    if (_isLoadingLocation) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
              const SizedBox(width: 16),
              Text(
                'Getting your location...',
                style: theme.textTheme.bodyMedium,
              ),
            ],
          ),
        ),
      );
    }

    if (_locationError != null) {
      return Card(
        borderOnForeground: true,
        shape: RoundedRectangleBorder(
          side: BorderSide(color: theme.colorScheme.error),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(Icons.location_off,
                  color: theme.colorScheme.error, size: 32),
              const SizedBox(height: 8),
              Text(
                'Location Unavailable',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _locationError!,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall,
              ),
              const SizedBox(height: 12),
              TextButton.icon(
                onPressed: isProcessing ? null : _getCurrentLocation,
                icon: const Icon(Icons.refresh),
                label: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.location_on, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Your Location',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                if (_currentLocation?.accuracy != null)
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '±${_currentLocation!.accuracy!.toStringAsFixed(0)}m',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.primary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildCoordinateRow(
                    'Latitude',
                    _currentLocation?.latitude.toStringAsFixed(6) ?? 'N/A',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCoordinateRow(
                    'Longitude',
                    _currentLocation?.longitude.toStringAsFixed(6) ?? 'N/A',
                  ),
                ),
              ],
            ),
            if (_currentLocation?.altitude != null) ...[
              const SizedBox(height: 8),
              _buildCoordinateRow(
                'Altitude',
                '${_currentLocation!.altitude!.toStringAsFixed(1)}m',
              ),
            ],
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: isProcessing ? null : _getCurrentLocation,
              icon: const Icon(Icons.refresh, size: 16),
              label: const Text('Refresh Location'),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoordinateRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Colors.grey[600],
              ),
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
                fontFamily: 'monospace',
              ),
        ),
      ],
    );
  }

  Widget _buildContactsSection(ThemeData theme, List<TrustedContact> contacts) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.people, color: theme.colorScheme.primary),
                const SizedBox(width: 12),
                Text(
                  'Will Notify',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    '${contacts.length} ${contacts.length == 1 ? 'Contact' : 'Contacts'}',
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (contacts.isEmpty)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No trusted contacts yet. Add contacts to notify them about your status.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.blue[700],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else if (contacts.length <= 5)
              Column(
                children: contacts
                    .map((contact) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: theme.colorScheme.primary
                                    .withValues(alpha: 0.1),
                                child: Text(
                                  contact.name.isNotEmpty
                                      ? contact.name[0].toUpperCase()
                                      : '?',
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.primary,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Text(
                                  contact.name,
                                  style: theme.textTheme.bodyMedium,
                                ),
                              ),
                              if (contact.phoneNumber.isNotEmpty)
                                Icon(Icons.phone,
                                    size: 16, color: Colors.grey[600]),
                            ],
                          ),
                        ))
                    .toList(),
              )
            else
              Column(
                children: [
                  ...contacts.take(3).map((contact) => Padding(
                        padding: const EdgeInsets.symmetric(vertical: 4),
                        child: Row(
                          children: [
                            CircleAvatar(
                              radius: 16,
                              backgroundColor: theme.colorScheme.primary
                                  .withValues(alpha: 0.1),
                              child: Text(
                                contact.name.isNotEmpty
                                    ? contact.name[0].toUpperCase()
                                    : '?',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                contact.name,
                                style: theme.textTheme.bodyMedium,
                              ),
                            ),
                          ],
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: Text(
                      'and ${contacts.length - 3} more contacts',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${time.day}/${time.month}/${time.year}';
    }
  }
}
