import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/safety_alert.dart';
import '../../domain/entities/trusted_contact.dart';
import '../providers/safety_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../core/services/location_service.dart';

/// Emergency SOS screen with prominent SOS button
///
/// Allows users to:
/// - Quickly trigger emergency SOS with a single tap
/// - See which trusted contacts will be notified
/// - Add optional message to provide context
/// - View current location that will be shared
/// - Cancel active emergency alerts
class EmergencySOSScreen extends ConsumerStatefulWidget {
  const EmergencySOSScreen({super.key});

  @override
  ConsumerState<EmergencySOSScreen> createState() => _EmergencySOSScreenState();
}

class _EmergencySOSScreenState extends ConsumerState<EmergencySOSScreen>
    with TickerProviderStateMixin {
  final _messageController = TextEditingController();
  SafetyAlertLocation? _currentLocation;
  bool _isLoadingLocation = false;
  String? _locationError;
  late AnimationController _pulseController;
  late AnimationController _countdownController;
  int _countdown = 3;
  bool _isCountingDown = false;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat();
    _countdownController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    _pulseController.dispose();
    _countdownController.dispose();
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
        accuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = SafetyAlertLocation(
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

  Future<void> _triggerSOS() async {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to trigger SOS'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    if (_currentLocation == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Waiting for location...'),
            backgroundColor: Colors.orange,
          ),
        );
      }
      return;
    }

    // Show confirmation dialog with countdown
    final confirmed = await _showCountdownDialog();
    if (!confirmed || !mounted) return;

    final notifier = ref.read(safetyNotifierProvider.notifier);

    try {
      await notifier.triggerEmergencySOS(
        userId: user.id,
        location: _currentLocation!,
        message: _messageController.text.trim().isEmpty
            ? null
            : _messageController.text.trim(),
        notifyContactIds: null, // Will notify all contacts with emergency alerts enabled
        batteryLevel: await ref.read(safetyNotifierProvider.notifier).getBatteryLevel(),
      );

      if (mounted) {
        // Show success dialog
        await _showSuccessDialog();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to trigger SOS: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<bool> _showCountdownDialog() async {
    setState(() {
      _isCountingDown = true;
      _countdown = 3;
    });

    _countdownController.reset();
    await _countdownController.forward();
    _countdownController.reset();

    setState(() {
      _isCountingDown = false;
    });

    // Show confirmation dialog
    return await showDialog<bool>(
          context: context,
          barrierDismissible: true,
          builder: (context) => AlertDialog(
            title: const Row(
              children: [
                Icon(Icons.warning, color: Colors.red),
                SizedBox(width: 8),
                Text('Confirm Emergency SOS'),
              ],
            ),
            content: const Text(
              'This will send an emergency alert with your location to all trusted contacts who receive emergency alerts.\n\nAre you sure?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('YES, SEND SOS'),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _showSuccessDialog() async {
    return showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: Colors.green, size: 64),
        title: const Text('SOS Sent!'),
        content: const Text(
          'Your emergency alert has been sent to your trusted contacts with your current location.\n\nStay safe!',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Optionally navigate back or stay to show status
            },
            style: FilledButton.styleFrom(
              backgroundColor: Colors.green,
              foregroundColor: Colors.white,
            ),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Future<void> _cancelAlert(SafetyAlert alert) async {
    final confirmed = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Cancel Emergency Alert?'),
            content: const Text(
              'This will cancel the emergency alert. Your contacts will be notified that it was a false alarm.\n\nAre you sure?',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('No, Keep Active'),
              ),
              FilledButton(
                onPressed: () => Navigator.of(context).pop(true),
                style: FilledButton.styleFrom(
                  backgroundColor: Colors.orange,
                ),
                child: const Text('Yes, Cancel Alert'),
              ),
            ],
          ),
        ) ??
        false;

    if (!confirmed) return;

    final notifier = ref.read(safetyNotifierProvider.notifier);
    await notifier.cancelAlert(alert.id);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Emergency alert cancelled'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safetyState = ref.watch(safetyNotifierProvider);
    final trustedContactsState = ref.watch(trustedContactsNotifierProvider);
    final isProcessing = safetyState.isProcessing;
    final hasActiveEmergency = safetyState.hasActiveEmergency;

    // Get contacts who will be notified
    final emergencyContacts = trustedContactsState.contacts
        .where((c) => c.receivesEmergencyAlerts)
        .toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Emergency SOS'),
        backgroundColor: hasActiveEmergency ? Colors.red.shade700 : null,
        foregroundColor: hasActiveEmergency ? Colors.white : null,
        actions: [
          if (hasActiveEmergency)
            IconButton(
              icon: const Icon(Icons.info_outline),
              onPressed: () => _showActiveAlertInfo(safetyState.activeAlerts.first),
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // Active emergency banner
            if (hasActiveEmergency) ...[
              _buildActiveEmergencyBanner(theme, safetyState.activeAlerts.first),
              const SizedBox(height: 24),
            ],

            // SOS Button
            _buildSOSButton(theme, isProcessing, hasActiveEmergency),
            const SizedBox(height: 32),

            // Warning text
            if (!hasActiveEmergency)
              Text(
                'Press to send emergency alert',
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.grey[600],
                  fontWeight: FontWeight.w500,
                ),
              ),
            const SizedBox(height: 32),

            // Location section
            _buildLocationCard(theme),
            const SizedBox(height: 24),

            // Contacts to notify section
            _buildContactsSection(theme, emergencyContacts),
            const SizedBox(height: 24),

            // Optional message section
            if (!hasActiveEmergency) _buildMessageSection(theme),

            // Active alerts section
            if (hasActiveEmergency) ...[
              const SizedBox(height: 24),
              _buildActiveAlertActions(theme, safetyState.activeAlerts.first),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildSOSButton(ThemeData theme, bool isProcessing, bool hasActiveEmergency) {
    return AnimatedBuilder(
      animation: _pulseController,
      builder: (context, child) {
        final pulseValue = _pulseController.value;
        final size = hasActiveEmergency ? 120.0 : 180.0;
        final color = hasActiveEmergency ? Colors.orange : Colors.red;

        return Transform.scale(
          scale: hasActiveEmergency ? 1.0 : (0.95 + 0.05 * pulseValue),
          child: GestureDetector(
            onTap: isProcessing || hasActiveEmergency ? null : _triggerSOS,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    color.withOpacity(0.3),
                    color,
                  ],
                ),
                boxShadow: [
                  BoxShadow(
                    color: color.withOpacity(0.5),
                    blurRadius: hasActiveEmergency ? 20 : 30,
                    spreadRadius: hasActiveEmergency ? 5 : 10,
                  ),
                  if (!hasActiveEmergency)
                    BoxShadow(
                      color: color.withOpacity(0.3),
                      blurRadius: 60 * pulseValue,
                      spreadRadius: 20 * pulseValue,
                    ),
                ],
              ),
              child: isProcessing
                  ? const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 4,
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          hasActiveEmergency ? 'ACTIVE' : 'SOS',
                          style: theme.textTheme.displayMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: hasActiveEmergency ? 32 : 48,
                          ),
                        ),
                        if (!hasActiveEmergency) ...[
                          const SizedBox(height: 4),
                          Text(
                            'Emergency',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: Colors.white.withOpacity(0.9),
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ],
                    ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildActiveEmergencyBanner(ThemeData theme, SafetyAlert alert) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.red.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.shade300, width: 2),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Icon(Icons.warning, color: Colors.red.shade700, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Emergency Alert Active',
                      style: theme.textTheme.titleLarge?.copyWith(
                        color: Colors.red.shade700,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Sent at ${_formatTime(alert.triggeredAt)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: Colors.red.shade600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (alert.message != null) ...[
            const SizedBox(height: 12),
            Text(
              alert.message!,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: Colors.red.shade800,
                fontStyle: FontStyle.italic,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildLocationCard(ThemeData theme) {
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
              Icon(Icons.location_off, color: theme.colorScheme.error, size: 32),
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
                onPressed: _getCurrentLocation,
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
                  'Location to Share',
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
                      color: theme.colorScheme.primary.withOpacity(0.1),
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
                    'Lat',
                    _currentLocation?.latitude.toStringAsFixed(6) ?? 'N/A',
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildCoordinateRow(
                    'Lng',
                    _currentLocation?.longitude.toStringAsFixed(6) ?? 'N/A',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: _getCurrentLocation,
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
                    color: theme.colorScheme.primary.withOpacity(0.1),
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
                    Icon(Icons.warning_amber, color: Colors.orange[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'No contacts will be notified. Add trusted contacts with emergency alerts enabled.',
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: Colors.orange[700],
                        ),
                      ),
                    ),
                  ],
                ),
              )
            else
              Column(
                children: contacts
                    .map((contact) => Padding(
                          padding: const EdgeInsets.symmetric(vertical: 4),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 16,
                                backgroundColor: theme.colorScheme.primary.withOpacity(0.1),
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
                              if (contact.phone != null)
                                Icon(Icons.phone, size: 16, color: Colors.grey[600]),
                            ],
                          ),
                        ))
                    .toList(),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageSection(ThemeData theme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 8),
          child: Text(
            'Message (Optional)',
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Let your contacts know what\'s happening',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _messageController,
          decoration: const InputDecoration(
            hintText: 'e.g., "I\'m in trouble, please help!"',
            border: OutlineInputBorder(),
            prefixIcon: Icon(Icons.message),
          ),
          maxLines: 3,
          textCapitalization: TextCapitalization.sentences,
        ),
      ],
    );
  }

  Widget _buildActiveAlertActions(ThemeData theme, SafetyAlert alert) {
    return Card(
      color: Colors.orange.shade50,
      shape: RoundedRectangleBorder(
        side: BorderSide(color: Colors.orange.shade300, width: 2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Emergency Actions',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.orange.shade700,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.icon(
              onPressed: () => _cancelAlert(alert),
              icon: const Icon(Icons.cancel),
              label: const Text('Cancel Emergency Alert'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.orange,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: () {
                ref.read(safetyNotifierProvider.notifier).markAsSafe(
                      message: 'I\'m safe now',
                    );
                ref.read(safetyNotifierProvider.notifier).resolveAlert(alert.id);
              },
              icon: const Icon(Icons.check_circle),
              label: const Text('Mark as Safe & Resolve'),
              style: OutlinedButton.styleFrom(
                foregroundColor: Colors.green,
                side: BorderSide(color: Colors.green.shade300),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showActiveAlertInfo(SafetyAlert alert) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.info, color: Colors.blue),
            SizedBox(width: 8),
            Text('Alert Details'),
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              _detailRow('Triggered', _formatDateTime(alert.triggeredAt)),
              _detailRow('Status', alert.status.name),
              if (alert.message != null) _detailRow('Message', alert.message!),
              _detailRow('Notified', '${alert.notifiedContactIds.length} contacts'),
              if (alert.acknowledgedByContactIds.isNotEmpty)
                _detailRow('Acknowledged by', '${alert.acknowledgedByContactIds.length} contacts'),
              if (alert.batteryLevel != null)
                _detailRow('Battery', '${alert.batteryLevel}%'),
              if (alert.location != null)
                _detailRow(
                  'Location',
                  '${alert.location!.latitude.toStringAsFixed(4)}, ${alert.location!.longitude.toStringAsFixed(4)}',
                ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              '$label:',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  String _formatTime(DateTime time) {
    final now = DateTime.now();
    final difference = now.difference(time);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String _formatDateTime(DateTime time) {
    return '${time.day}/${time.month}/${time.year} ${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
  }
}
