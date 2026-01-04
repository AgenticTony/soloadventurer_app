import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/check_in.dart';
import '../../domain/entities/trusted_contact.dart';
import '../providers/safety_providers.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../../../core/services/location_service.dart';

/// Screen for scheduling automatic check-ins
///
/// Allows users to:
/// - Schedule check-ins at specific times
/// - Set location-based triggers (arrival/departure)
/// - Configure deadlines for check-ins
/// - Add status messages
/// - Choose which contacts to notify
class ScheduleCheckInScreen extends ConsumerStatefulWidget {
  /// Optional trip ID to associate the check-in with
  final String? tripId;

  const ScheduleCheckInScreen({
    super.key,
    this.tripId,
  });

  @override
  ConsumerState<ScheduleCheckInScreen> createState() =>
      _ScheduleCheckInScreenState();
}

class _ScheduleCheckInScreenState extends ConsumerState<ScheduleCheckInScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _deadlineNotesController = TextEditingController();

  CheckInTriggerType _selectedTriggerType = CheckInTriggerType.scheduledTime;
  DateTime? _scheduledTime;
  DateTime? _deadline;
  CheckInLocation? _location;
  List<String> _selectedContactIds = [];
  bool _isLoadingLocation = false;
  bool _useCustomDeadline = false;

  @override
  void dispose() {
    _messageController.dispose();
    _deadlineNotesController.dispose();
    super.dispose();
  }

  Future<void> _getCurrentLocation() async {
    setState(() {
      _isLoadingLocation = true;
    });

    try {
      final locationService = ref.read(locationServiceProvider);
      final locationData = await locationService.getCurrentLocation(
        accuracy: LocationAccuracy.high,
      );

      setState(() {
        _location = CheckInLocation(
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
        _isLoadingLocation = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to get location: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _selectScheduledTime() async {
    final now = DateTime.now();
    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _scheduledTime ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (selectedDate == null) return;

    if (!mounted) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_scheduledTime ?? now),
    );

    if (selectedTime == null) return;

    setState(() {
      _scheduledTime = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );

      // Auto-set deadline to 1 hour after scheduled time if not using custom deadline
      if (!_useCustomDeadline) {
        _deadline = _scheduledTime!.add(const Duration(hours: 1));
      }
    });
  }

  Future<void> _selectDeadline() async {
    if (_scheduledTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select scheduled time first'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final selectedDate = await showDatePicker(
      context: context,
      initialDate: _deadline ?? _scheduledTime!.add(const Duration(hours: 1)),
      firstDate: _scheduledTime!,
      lastDate: _scheduledTime!.add(const Duration(days: 30)),
    );

    if (selectedDate == null) return;

    if (!mounted) return;

    final selectedTime = await showTimePicker(
      context: context,
      initialTime: TimeOfDay.fromDateTime(_deadline ?? _scheduledTime!.add(const Duration(hours: 1))),
    );

    if (selectedTime == null) return;

    setState(() {
      _deadline = DateTime(
        selectedDate.year,
        selectedDate.month,
        selectedDate.day,
        selectedTime.hour,
        selectedTime.minute,
      );
    });
  }

  Future<void> _scheduleCheckIn() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (_scheduledTime == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select a scheduled time'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (_selectedTriggerType == CheckInTriggerType.locationArrival ||
        _selectedTriggerType == CheckInTriggerType.locationDeparture) {
      if (_location == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please set a location for location-based check-ins'),
            backgroundColor: Colors.orange,
          ),
        );
        return;
      }
    }

    final user = ref.read(currentUserProvider);
    if (user == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You must be logged in to schedule check-ins'),
            backgroundColor: Colors.red,
          ),
        );
      }
      return;
    }

    final notifier = ref.read(checkInNotifierProvider.notifier);

    try {
      await notifier.scheduleCheckIn(
        userId: user.id,
        scheduledTime: _scheduledTime!,
        deadline: _deadline,
        location: _location,
        statusMessage: _messageController.text.trim().isEmpty
            ? null
            : _messageController.text.trim(),
        notifyContactIds: _selectedContactIds.isEmpty ? null : _selectedContactIds,
        tripId: widget.tripId,
        triggerType: _selectedTriggerType,
      );

      if (mounted) {
        Navigator.of(context).pop();
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              _selectedTriggerType == CheckInTriggerType.scheduledTime
                  ? 'Check-in scheduled for ${_formatDateTime(_scheduledTime!)}'
                  : 'Location-based check-in scheduled',
            ),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to schedule check-in: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  String _formatDateTime(DateTime dateTime) {
    return '${dateTime.toString().split(' ')[0]} at ${dateTime.toString().split(' ')[1].substring(0, 5)}';
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final contactsState = ref.watch(trustedContactsNotifierProvider);
    final checkInState = ref.watch(checkInNotifierProvider);
    final isScheduling = checkInState.isCreating;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schedule Check-in'),
        actions: [
          if (isScheduling)
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
              onPressed: isScheduling ? null : _scheduleCheckIn,
              icon: const Icon(Icons.check, color: Colors.white),
              tooltip: 'Schedule',
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
              // Trigger type section
              _buildSectionHeader('Check-in Trigger'),
              const SizedBox(height: 16),
              _buildTriggerTypeSelector(theme),
              const SizedBox(height: 24),

              // Scheduled time section (for time-based triggers)
              if (_selectedTriggerType == CheckInTriggerType.scheduledTime) ...[
                _buildSectionHeader('Scheduled Time'),
                const SizedBox(height: 16),
                _buildScheduledTimeCard(theme),
                const SizedBox(height: 16),
                _buildDeadlineCard(theme),
                const SizedBox(height: 24),
              ],

              // Location section (for location-based triggers)
              if (_selectedTriggerType == CheckInTriggerType.locationArrival ||
                  _selectedTriggerType == CheckInTriggerType.locationDeparture) ...[
                _buildSectionHeader('Location'),
                const SizedBox(height: 16),
                _buildLocationCard(theme),
                const SizedBox(height: 24),
              ],

              // Status message section
              _buildSectionHeader('Status Message (Optional)'),
              const SizedBox(height: 8),
              Text(
                'Add a message to include with your check-in',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _messageController,
                decoration: const InputDecoration(
                  hintText: 'e.g., "Check-in during hike"',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.message),
                ),
                maxLines: 3,
                enabled: !isScheduling,
              ),
              const SizedBox(height: 24),

              // Contacts to notify section
              _buildSectionHeader('Notify Contacts (Optional)'),
              const SizedBox(height: 8),
              Text(
                'Select which trusted contacts to notify',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 16),
              _buildContactsSelector(theme, contactsState.contacts),
              const SizedBox(height: 32),

              // Schedule button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: (_isLoadingLocation || isScheduling) ? null : _scheduleCheckIn,
                  icon: isScheduling
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white,
                          ),
                        )
                      : const Icon(Icons.schedule),
                  label: Text(
                    isScheduling ? 'Scheduling...' : 'Schedule Check-in',
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

  Widget _buildTriggerTypeSelector(ThemeData theme) {
    return Card(
      child: Column(
        children: [
          RadioListTile<CheckInTriggerType>(
            title: const Row(
              children: [
                Icon(Icons.schedule, size: 20),
                SizedBox(width: 8),
                Text('Scheduled Time'),
              ],
            ),
            subtitle: const Text('Check in at a specific date and time'),
            value: CheckInTriggerType.scheduledTime,
            groupValue: _selectedTriggerType,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedTriggerType = value;
                });
              }
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          ),
          const Divider(height: 1),
          RadioListTile<CheckInTriggerType>(
            title: const Row(
              children: [
                Icon(Icons.login, size: 20),
                SizedBox(width: 8),
                Text('Location Arrival'),
              ],
            ),
            subtitle: const Text('Check in when you arrive at a location'),
            value: CheckInTriggerType.locationArrival,
            groupValue: _selectedTriggerType,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedTriggerType = value;
                });
              }
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          ),
          const Divider(height: 1),
          RadioListTile<CheckInTriggerType>(
            title: const Row(
              children: [
                Icon(Icons.logout, size: 20),
                SizedBox(width: 8),
                Text('Location Departure'),
              ],
            ),
            subtitle: const Text('Check in when you leave a location'),
            value: CheckInTriggerType.locationDeparture,
            groupValue: _selectedTriggerType,
            onChanged: (value) {
              if (value != null) {
                setState(() {
                  _selectedTriggerType = value;
                });
              }
            },
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          ),
        ],
      ),
    );
  }

  Widget _buildScheduledTimeCard(ThemeData theme) {
    return Card(
      child: ListTile(
        leading: Icon(Icons.access_time, color: theme.colorScheme.primary),
        title: Text(
          _scheduledTime == null
              ? 'Select Date & Time'
              : _formatDateTime(_scheduledTime!),
          style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: _scheduledTime == null ? null : FontWeight.bold,
              ),
        ),
        trailing: const Icon(Icons.arrow_forward_ios, size: 16),
        onTap: () => _selectScheduledTime(),
      ),
    );
  }

  Widget _buildDeadlineCard(ThemeData theme) {
    return Card(
      child: Column(
        children: [
          SwitchListTile(
            title: const Text('Set Custom Deadline'),
            subtitle: const Text('Set a deadline after the scheduled time'),
            value: _useCustomDeadline,
            onChanged: (value) {
              setState(() {
                _useCustomDeadline = value;
                if (!value) {
                  // Reset to default 1 hour deadline
                  _deadline = _scheduledTime?.add(const Duration(hours: 1));
                }
              });
            },
          ),
          if (_useCustomDeadline) ...[
            const Divider(height: 1),
            ListTile(
              leading: Icon(Icons.timer_outlined, color: theme.colorScheme.primary),
              title: Text(
                _deadline == null
                    ? 'Select Deadline'
                    : 'Deadline: ${_formatDateTime(_deadline!)}',
                style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: _deadline == null ? null : FontWeight.bold,
                    ),
              ),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () => _selectDeadline(),
            ),
          ] else if (_deadline != null) ...[
            const Divider(height: 1),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                children: [
                  Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Default deadline: ${_formatDateTime(_deadline!)}',
                      style: theme.textTheme.bodySmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                    ),
                  ),
                ],
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

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  _location == null ? Icons.location_off : Icons.location_on,
                  color: _location == null
                      ? Colors.grey
                      : theme.colorScheme.primary,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _location == null
                        ? 'No Location Set'
                        : 'Location: ${_location!.latitude.toStringAsFixed(4)}, ${_location!.longitude.toStringAsFixed(4)}',
                    style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: _location == null ? null : FontWeight.bold,
                        ),
                  ),
                ),
              ],
            ),
            if (_location != null) ...[
              const SizedBox(height: 8),
              Row(
                children: [
                  Icon(
                    Icons.check_circle,
                    size: 16,
                    color: Colors.green,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Accuracy: ±${_location!.accuracy?.toStringAsFixed(0) ?? 'N/A'}m',
                    style: theme.textTheme.bodySmall,
                  ),
                ],
              ),
            ],
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: isScheduling ? null : _getCurrentLocation,
                    icon: const Icon(Icons.my_location),
                    label: const Text('Use Current Location'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildContactsSelector(ThemeData theme, List<TrustedContact> contacts) {
    if (contacts.isEmpty) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Icon(
                Icons.people_outline,
                size: 48,
                color: Colors.grey,
              ),
              const SizedBox(height: 12),
              Text(
                'No Trusted Contacts',
                style: theme.textTheme.titleMedium,
              ),
              const SizedBox(height: 8),
              Text(
                'Add trusted contacts to notify them about check-ins',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                      color: Colors.grey[600],
                    ),
              ),
            ],
          ),
        ),
      );
    }

    return Card(
      child: Column(
        children: contacts.map((contact) {
          final isSelected = _selectedContactIds.contains(contact.id);
          return CheckboxListTile(
            title: Text(contact.name),
            subtitle: Text(contact.phoneNumber),
            secondary: CircleAvatar(
              child: Text(
                contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
              ),
            ),
            value: isSelected,
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  _selectedContactIds.add(contact.id);
                } else {
                  _selectedContactIds.remove(contact.id);
                }
              });
            },
          );
        }).toList(),
      ),
    );
  }
}
