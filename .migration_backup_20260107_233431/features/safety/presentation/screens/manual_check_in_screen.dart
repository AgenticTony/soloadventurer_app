import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import 'package:soloadventurer/features/safety/presentation/notifiers/check_in_notifier.dart';
import 'package:soloadventurer/features/safety/presentation/notifiers/safety_notifier.dart';
import '../../domain/entities/check_in.dart';
import '../../domain/entities/safety_status.dart' as safety;
import '../providers/safety_providers.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Screen for manual check-in with current location and status
///
/// Allows users to:
/// - Check in with their current location
/// - Add an optional status message
/// - Optionally update their safety status (safe, need help, emergency)
/// - Choose which trusted contacts to notify
class ManualCheckInScreen extends ConsumerStatefulWidget {
  /// Optional check-in to complete (if completing an existing check-in)
  final CheckIn? existingCheckIn;

  const ManualCheckInScreen({
    super.key,
    this.existingCheckIn,
  });

  @override
  ConsumerState<ManualCheckInScreen> createState() => _ManualCheckInScreenState();
}

class _ManualCheckInScreenState extends ConsumerState<ManualCheckInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();

  safety.SafetyStatusType? _selectedStatus;
  bool _isLoadingLocation = false;
  String? _locationError;
  CheckInLocation? _currentLocation;

  @override
  void initState() {
    super.initState();
    // Get current location when screen initializes
    _getCurrentLocation();
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
        accuracy: LocationAccuracy.high,
      );

      setState(() {
        _currentLocation = CheckInLocation(
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

  Future<void> _submitCheckIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_currentLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Waiting for location...'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final user = ref.read(currentUserProvider);
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to check in'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final notifier = ref.read(checkInNotifierProvider.notifier);

    try {
      if (widget.existingCheckIn != null) {
        // Complete existing check-in
        final completedCheckIn = await notifier.completeCheckIn(
          checkInId: widget.existingCheckIn!.id,
          location: _currentLocation!,
          statusMessage: _messageController.text.trim().isEmpty
              ? null
              : _messageController.text.trim(),
        );

        if (mounted) {
          Navigator.of(context).pop(completedCheckIn);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Check-in completed successfully'),
              backgroundColor: Colors.green,
            ),
          );
        }
      } else {
        // Create new manual check-in
        final newCheckIn = CheckIn(
          id: const Uuid().v4(),
          userId: user.id,
          triggerType: CheckInTriggerType.manual,
          status: CheckInStatus.completed,
          completedAt: DateTime.now(),
          location: _currentLocation,
          statusMessage: _messageController.text.trim().isEmpty
              ? null
              : _messageController.text.trim(),
          notifyContactIds: [], // Will notify contacts based on their preferences
          createdAt: DateTime.now(),
        );

        final createdCheckIn = await notifier.createCheckIn(newCheckIn);

        // Optionally update safety status if selected
        if (_selectedStatus != null) {
          final safetyNotifier = ref.read(safetyNotifierProvider.notifier);
          await safetyNotifier.updateStatus(
            status: _selectedStatus!,
            message: _messageController.text.trim().isEmpty
                ? null
                : _messageController.text.trim(),
            location: safety.SafetyStatusLocation(
              latitude: _currentLocation!.latitude,
              longitude: _currentLocation!.longitude,
              accuracy: _currentLocation!.accuracy,
              altitude: _currentLocation!.altitude,
              timestamp: _currentLocation!.timestamp,
            ),
            checkInId: createdCheckIn.id,
          );
        }

        if (mounted) {
          Navigator.of(context).pop(createdCheckIn);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                _selectedStatus != null
                    ? 'Check-in completed and status updated'
                    : 'Check-in completed successfully',
              ),
              backgroundColor: Colors.green,
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to check in: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final safetyState = ref.watch(safetyNotifierProvider);
    final isSubmitting = safetyState.isProcessing;

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.existingCheckIn != null ? 'Complete Check-in' : 'Manual Check-in'),
        actions: [
          if (isSubmitting)
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
              onPressed: isSubmitting ? null : _submitCheckIn,
              icon: const Icon(Icons.check, color: Colors.white),
              tooltip: 'Check In',
            ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Location section
              _buildSectionHeader('Your Location'),
              const SizedBox(height: 16),
              _buildLocationCard(theme),
              const SizedBox(height: 24),

              // Status message section
              _buildSectionHeader('Status Message (Optional)'),
              const SizedBox(height: 8),
              Text(
                'Let your contacts know how you\'re doing',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'Enter a message (e.g., "Arrived safely at the hotel")',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.message),
                ),
                maxLines: 3,
                enabled: !isSubmitting,
              ),
              const SizedBox(height: 24),

              // Safety status section
              _buildSectionHeader('Safety Status (Optional)'),
              const SizedBox(height: 8),
              Text(
                'Update your current safety status',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              _buildStatusSelector(theme),
              const SizedBox(height: 32),

              // Submit button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (_isLoadingLocation || isSubmitting) ? null : _submitCheckIn,
                  icon: isSubmitting
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.check_circle),
                  label: Text(
                    isSubmitting
                        ? 'Checking In...'
                        : (widget.existingCheckIn != null ? 'Complete Check-in' : 'Check In Now'),
                    style: const TextStyle(fontSize: 16),
                  ),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
          ),
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

  Widget _buildLocationCard(ThemeData theme) {
    if (_isLoadingLocation) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              const CircularProgressIndicator(),
              const SizedBox(height: 16),
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
              Icon(
                Icons.location_off,
                size: 48,
                color: theme.colorScheme.error,
              ),
              const SizedBox(height: 12),
              Text(
                'Location Error',
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
              const SizedBox(height: 16),
              OutlinedButton.icon(
                onPressed: isSubmitting ? null : _getCurrentLocation,
                icon: const Icon(Icons.refresh),
                label: const Text('Try Again'),
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
                Icon(
                  Icons.location_on,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'Location Acquired',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
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
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 16,
                  color: Colors.grey[600],
                ),
                const SizedBox(width: 8),
                Text(
                  'Updated just now',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey[600],
                  ),
                ),
                const Spacer(),
                TextButton.icon(
                  onPressed: isSubmitting ? null : _getCurrentLocation,
                  icon: const Icon(Icons.refresh, size: 16),
                  label: const Text('Refresh'),
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                  ),
                ),
              ],
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

  Widget _buildStatusSelector(ThemeData theme) {
    return Column(
      children: [
        // No status (default)
        RadioListTile<safety.SafetyStatusType>(
          title: const Text('Just Check In'),
          subtitle: const Text('Complete check-in without updating status'),
          value: null,
          groupValue: _selectedStatus,
          onChanged: isSubmitting
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
        ),
        const Divider(height: 1),

        // Safe status
        RadioListTile<safety.SafetyStatusType>(
          title: const Row(
            children: [
              Icon(
                Icons.check_circle,
                color: Colors.green,
                size: 20,
              ),
              SizedBox(width: 8),
              Text('I\'m Safe'),
            ],
          ),
          subtitle: const Text('Let your contacts know you\'re okay'),
          value: safety.SafetyStatusType.safe,
          groupValue: _selectedStatus,
          onChanged: isSubmitting
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
        ),
        const Divider(height: 1),

        // Need help status
        RadioListTile<safety.SafetyStatusType>(
          title: const Row(
            children: [
              Icon(
                Icons.help,
                color: Colors.orange,
                size: 20,
              ),
              SizedBox(width: 8),
              Text('Need Help'),
            ],
          ),
          subtitle: const Text('You need assistance but it\'s not an emergency'),
          value: safety.SafetyStatusType.needHelp,
          groupValue: _selectedStatus,
          onChanged: isSubmitting
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
        ),
        const Divider(height: 1),

        // Emergency status
        RadioListTile<safety.SafetyStatusType>(
          title: const Row(
            children: [
              Icon(
                Icons.warning,
                color: Colors.red,
                size: 20,
              ),
              SizedBox(width: 8),
              Text('Emergency'),
            ],
          ),
          subtitle: const Text('You\'re in an emergency situation'),
          value: safety.SafetyStatusType.emergency,
          groupValue: _selectedStatus,
          onChanged: isSubmitting
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
        ),
      ],
    );
  }
}
