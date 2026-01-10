import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/entities/check_in.dart';
import '../../domain/entities/trusted_contact.dart';
import '../providers/safety_providers.dart';
import '../state/trusted_contacts_state.dart';

/// Callback type for when a check-in is scheduled
typedef CheckInScheduledCallback = void Function({
  required CheckInTriggerType triggerType,
  DateTime? scheduledTime,
  DateTime? deadline,
  CheckInLocation? location,
  String? message,
  List<String>? notifyContactIds,
  String? tripId,
});

/// Reusable widget for scheduling check-ins
///
/// Features:
/// - Trigger type selector (scheduled time, location arrival, location departure)
/// - Date/time picker for scheduled check-ins
/// - Optional deadline configuration with default offset
/// - Location acquisition for location-based triggers
/// - Optional status message input
/// - Contact selector for choosing trusted contacts to notify
/// - Trip ID association (optional)
/// - Form validation and error handling
class CheckInScheduler extends ConsumerStatefulWidget {
  /// Optional initial trigger type
  final CheckInTriggerType? initialTriggerType;

  /// Optional initial scheduled time
  final DateTime? initialScheduledTime;

  /// Optional initial deadline
  final DateTime? initialDeadline;

  /// Default deadline duration after scheduled time (default: 1 hour)
  final Duration defaultDeadlineOffset;

  /// Whether to show the location input
  final bool showLocationInput;

  /// Whether to show the message input
  final bool showMessageInput;

  /// Whether to show the contact selector
  final bool showContactSelector;

  /// Whether to show the trip ID input
  final bool showTripIdInput;

  /// Optional trip ID to pre-fill
  final String? initialTripId;

  /// Callback when a check-in is scheduled successfully
  final CheckInScheduledCallback? onSchedule;

  /// Optional custom submit button label
  final String? submitButtonLabel;

  const CheckInScheduler({
    super.key,
    this.initialTriggerType,
    this.initialScheduledTime,
    this.initialDeadline,
    this.defaultDeadlineOffset = const Duration(hours: 1),
    this.showLocationInput = true,
    this.showMessageInput = true,
    this.showContactSelector = true,
    this.showTripIdInput = false,
    this.initialTripId,
    this.onSchedule,
    this.submitButtonLabel,
  });

  @override
  ConsumerState<CheckInScheduler> createState() => _CheckInSchedulerState();
}

class _CheckInSchedulerState extends ConsumerState<CheckInScheduler> {
  final _formKey = GlobalKey<FormState>();
  final _messageController = TextEditingController();
  final _tripIdController = TextEditingController();

  CheckInTriggerType? _selectedTriggerType;
  DateTime? _scheduledTime;
  DateTime? _deadline;
  CheckInLocation? _location;
  final List<String> _selectedContactIds = [];
  bool _isLoadingLocation = false;
  String? _locationError;
  bool _isCustomDeadline = false;

  @override
  void initState() {
    super.initState();
    _selectedTriggerType =
        widget.initialTriggerType ?? CheckInTriggerType.scheduledTime;
    _scheduledTime = widget.initialScheduledTime;
    _deadline = widget.initialDeadline;
    if (widget.initialTripId != null) {
      _tripIdController.text = widget.initialTripId!;
    }

    // Auto-fetch location if location-based trigger is selected
    if (_selectedTriggerType == CheckInTriggerType.locationArrival ||
        _selectedTriggerType == CheckInTriggerType.locationDeparture) {
      _getCurrentLocation();
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _tripIdController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final trustedContactsState = ref.watch(trustedContactsProvider);

    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Trigger type selector
          _buildTriggerTypeSelector(context),
          const SizedBox(height: 16),

          // Date/time picker for scheduled time
          if (_selectedTriggerType == CheckInTriggerType.scheduledTime) ...[
            _buildScheduledTimePicker(context),
            const SizedBox(height: 16),
          ],

          // Location input for location-based triggers
          if (widget.showLocationInput &&
              (_selectedTriggerType == CheckInTriggerType.locationArrival ||
                  _selectedTriggerType ==
                      CheckInTriggerType.locationDeparture)) ...[
            _buildLocationInput(context),
            const SizedBox(height: 16),
          ],

          // Deadline configuration
          if (_selectedTriggerType == CheckInTriggerType.scheduledTime) ...[
            _buildDeadlineInput(context),
            const SizedBox(height: 16),
          ],

          // Message input
          if (widget.showMessageInput) ...[
            _buildMessageInput(context),
            const SizedBox(height: 16),
          ],

          // Contact selector
          if (widget.showContactSelector) ...[
            _buildContactSelector(context, trustedContactsState),
            const SizedBox(height: 16),
          ],

          // Trip ID input
          if (widget.showTripIdInput) ...[
            _buildTripIdInput(context),
            const SizedBox(height: 16),
          ],

          // Submit button
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: _isFormValid() ? _submitSchedule : null,
              icon: const Icon(Icons.schedule),
              label: Text(widget.submitButtonLabel ?? 'Schedule Check-in'),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds the trigger type selector
  Widget _buildTriggerTypeSelector(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Check-in Type',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        SegmentedButton<CheckInTriggerType>(
          segments: const [
            ButtonSegment(
              value: CheckInTriggerType.scheduledTime,
              label: Text('Scheduled'),
              icon: Icon(Icons.schedule),
            ),
            ButtonSegment(
              value: CheckInTriggerType.locationArrival,
              label: Text('Arrival'),
              icon: Icon(Icons.login),
            ),
            ButtonSegment(
              value: CheckInTriggerType.locationDeparture,
              label: Text('Departure'),
              icon: Icon(Icons.logout),
            ),
          ],
          selected: {_selectedTriggerType!},
          onSelectionChanged: (Set<CheckInTriggerType> selected) {
            setState(() {
              _selectedTriggerType = selected.first;
              // Auto-fetch location for location-based triggers
              if (_selectedTriggerType == CheckInTriggerType.locationArrival ||
                  _selectedTriggerType ==
                      CheckInTriggerType.locationDeparture) {
                _getCurrentLocation();
              }
            });
          },
        ),
      ],
    );
  }

  /// Builds the scheduled time picker
  Widget _buildScheduledTimePicker(BuildContext context) {
    final theme = Theme.of(context);

    return InkWell(
      onTap: () => _pickScheduledTime(context),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          border: Border.all(color: theme.colorScheme.outline),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.access_time,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Scheduled Time',
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _scheduledTime != null
                        ? '${_scheduledTime!.toString().split(' ')[0]} at ${_scheduledTime!.toString().split(' ')[1].substring(0, 5)}'
                        : 'Select date and time',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: _scheduledTime != null
                          ? theme.colorScheme.onSurface
                          : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_drop_down,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }

  /// Builds the location input section
  Widget _buildLocationInput(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Location',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            border: Border.all(color: theme.colorScheme.outline),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (_isLoadingLocation) ...[
                Row(
                  children: [
                    const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Getting location...',
                      style: theme.textTheme.bodyMedium,
                    ),
                  ],
                ),
              ] else if (_locationError != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.error_outline,
                      color: theme.colorScheme.error,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        _locationError!,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          color: theme.colorScheme.error,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _getCurrentLocation,
                      tooltip: 'Retry',
                    ),
                  ],
                ),
              ] else if (_location != null) ...[
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _location!.placeName ??
                                _location!.address ??
                                'Location acquired',
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          if (_location!.accuracy != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Accuracy: ±${_location!.accuracy!.toStringAsFixed(0)}m',
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.refresh),
                      onPressed: _getCurrentLocation,
                      tooltip: 'Refresh location',
                    ),
                  ],
                ),
              ] else ...[
                Row(
                  children: [
                    const Icon(
                      Icons.location_searching,
                      color: Colors.grey,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'Tap to get location',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the deadline input section
  Widget _buildDeadlineInput(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Deadline',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            TextButton(
              onPressed: () {
                setState(() {
                  _isCustomDeadline = !_isCustomDeadline;
                  if (!_isCustomDeadline && _scheduledTime != null) {
                    _deadline =
                        _scheduledTime!.add(widget.defaultDeadlineOffset);
                  }
                });
              },
              child: Text(_isCustomDeadline ? 'Use default' : 'Custom'),
            ),
          ],
        ),
        const SizedBox(height: 8),
        if (_isCustomDeadline)
          InkWell(
            onTap: () => _pickDeadline(context),
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: theme.colorScheme.outline),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.timer,
                    color: theme.colorScheme.secondary,
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Deadline',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: Colors.grey[600],
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _deadline != null
                              ? '${_deadline!.toString().split(' ')[0]} at ${_deadline!.toString().split(' ')[1].substring(0, 5)}'
                              : 'Select deadline',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: _deadline != null
                                ? theme.colorScheme.onSurface
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_drop_down,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border.all(color: theme.colorScheme.outline),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.timer,
                  color: theme.colorScheme.secondary,
                ),
                const SizedBox(width: 16),
                Text(
                  'Default: ${widget.defaultDeadlineOffset.inHours}h after scheduled time',
                  style: theme.textTheme.bodyMedium,
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Builds the message input field
  Widget _buildMessageInput(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: _messageController,
      maxLines: 3,
      decoration: const InputDecoration(
        labelText: 'Status Message (Optional)',
        hintText: 'Add a message for your trusted contacts...',
        border: OutlineInputBorder(),
      ),
    );
  }

  /// Builds the contact selector
  Widget _buildContactSelector(
      BuildContext context, TrustedContactsState state) {
    final theme = Theme.of(context);
    final contacts = state.contacts;

    if (contacts.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.info_outline,
              color: theme.colorScheme.primary,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'No trusted contacts available. Add contacts to notify them.',
                style: theme.textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Notify Contacts',
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: contacts.map((contact) {
            final isSelected = _selectedContactIds.contains(contact.id);
            return FilterChip(
              label: Text(contact.name),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  if (selected) {
                    _selectedContactIds.add(contact.id);
                  } else {
                    _selectedContactIds.remove(contact.id);
                  }
                });
              },
              avatar: CircleAvatar(
                radius: 12,
                child: Text(
                  contact.name.isNotEmpty ? contact.name[0].toUpperCase() : '?',
                  style: const TextStyle(fontSize: 10),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Builds the trip ID input field
  Widget _buildTripIdInput(BuildContext context) {
    final theme = Theme.of(context);

    return TextFormField(
      controller: _tripIdController,
      decoration: const InputDecoration(
        labelText: 'Trip ID (Optional)',
        hintText: 'Associate this check-in with a trip...',
        border: OutlineInputBorder(),
      ),
    );
  }

  /// Gets current location
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
        _locationError = e.toString();
        _isLoadingLocation = false;
      });
    }
  }

  /// Opens date/time picker for scheduled time
  Future<void> _pickScheduledTime(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _scheduledTime ?? now,
      firstDate: now,
      lastDate: now.add(const Duration(days: 365)),
    );

    if (picked != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_scheduledTime ?? now),
      );

      if (time != null) {
        setState(() {
          _scheduledTime = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
          // Auto-set deadline if not custom
          if (!_isCustomDeadline) {
            _deadline = _scheduledTime!.add(widget.defaultDeadlineOffset);
          }
        });
      }
    }
  }

  /// Opens date/time picker for deadline
  Future<void> _pickDeadline(BuildContext context) async {
    if (_scheduledTime == null) return;

    final picked = await showDatePicker(
      context: context,
      initialDate:
          _deadline ?? _scheduledTime!.add(widget.defaultDeadlineOffset),
      firstDate: _scheduledTime!,
      lastDate: _scheduledTime!.add(const Duration(days: 30)),
    );

    if (picked != null && mounted) {
      final time = await showTimePicker(
        context: context,
        initialTime: TimeOfDay.fromDateTime(_deadline ?? _scheduledTime!),
      );

      if (time != null) {
        setState(() {
          _deadline = DateTime(
            picked.year,
            picked.month,
            picked.day,
            time.hour,
            time.minute,
          );
        });
      }
    }
  }

  /// Validates if the form is ready to submit
  bool _isFormValid() {
    // Scheduled time required for scheduled check-ins
    if (_selectedTriggerType == CheckInTriggerType.scheduledTime &&
        _scheduledTime == null) {
      return false;
    }

    // Location required for location-based check-ins
    if ((_selectedTriggerType == CheckInTriggerType.locationArrival ||
            _selectedTriggerType == CheckInTriggerType.locationDeparture) &&
        _location == null) {
      return false;
    }

    // Deadline must be after scheduled time
    if (_scheduledTime != null && _deadline != null) {
      if (!_deadline!.isAfter(_scheduledTime!)) {
        return false;
      }
    }

    return true;
  }

  /// Submits the scheduled check-in
  void _submitSchedule() {
    if (!_isFormValid()) return;

    widget.onSchedule?.call(
      triggerType: _selectedTriggerType!,
      scheduledTime: _scheduledTime,
      deadline: _deadline,
      location: _location,
      message: _messageController.text.trim().isEmpty
          ? null
          : _messageController.text.trim(),
      notifyContactIds:
          _selectedContactIds.isEmpty ? null : _selectedContactIds,
      tripId: _tripIdController.text.trim().isEmpty
          ? null
          : _tripIdController.text.trim(),
    );
  }
}
