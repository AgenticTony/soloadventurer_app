import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/destination.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// A flow for adding a destination to an existing or new trip.
///
/// This widget provides a comprehensive multi-step flow that allows users to:
/// - Select an existing trip or create a new one
/// - Configure optional dates for the destination visit
/// - Add optional notes about the destination
/// - Confirm and add the destination to the trip itinerary
///
/// The flow handles authentication, validation, and provides clear
/// success/error feedback throughout the process.
///
/// Example usage:
/// ```dart
/// showModalBottomSheet(
///   context: context,
///   isScrollControlled: true,
///   builder: (context) => AddToTripFlow(
///     destination: destination,
///     onSuccess: (tripId, tripName) {
///       ScaffoldMessenger.of(context).showSnackBar(
///         SnackBar(content: Text('Added to $tripName')),
///       );
///     },
///   ),
/// );
/// ```
class AddToTripFlow extends ConsumerStatefulWidget {
  /// The destination to add to a trip
  final Destination destination;

  /// Callback when destination is successfully added to a trip
  final void Function(String tripId, String tripName)? onSuccess;

  /// Callback when the flow is cancelled
  final VoidCallback? onCancel;

  /// Whether to show dates selection step
  final bool showDatesSelection;

  /// Whether to show notes step
  final bool showNotesStep;

  const AddToTripFlow({
    super.key,
    required this.destination,
    this.onSuccess,
    this.onCancel,
    this.showDatesSelection = true,
    this.showNotesStep = true,
  });

  @override
  ConsumerState<AddToTripFlow> createState() => _AddToTripFlowState();
}

class _AddToTripFlowState extends ConsumerState<AddToTripFlow> {
  /// Current step in the flow (0: select trip, 1: dates, 2: notes, 3: confirm)
  int _currentStep = 0;

  /// Selected trip (null if creating new trip)
  String? _selectedTripId;

  /// New trip data (if creating new trip)
  String? _newTripTitle;
  String? _newTripDescription;

  /// Start date for the destination visit
  DateTime? _startDate;

  /// End date for the destination visit
  DateTime? _endDate;

  /// Notes about the destination in the trip
  String _notes = '';

  /// Loading state
  bool _isLoading = false;

  /// Error message
  String? _errorMessage;

  /// Mock user trips (will be replaced with real data in subtask 7.2)
  final List<Map<String, dynamic>> _mockUserTrips = [
    {
      'id': 'trip1',
      'title': 'Japan Adventure 2024',
      'description': 'Exploring Japan',
      'startDate': DateTime(2024, 3, 15),
      'endDate': DateTime(2024, 3, 30),
      'destination': 'Tokyo, Japan',
      'status': 'planned',
      'coverImageUrl': null,
    },
    {
      'id': 'trip2',
      'title': 'Solo Europe Trip',
      'description': 'Backpacking through Europe',
      'startDate': DateTime(2024, 6, 1),
      'endDate': DateTime(2024, 6, 21),
      'destination': 'Paris, France',
      'status': 'planned',
      'coverImageUrl': null,
    },
  ];

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authState = ref.watch(authNotifierProvider);

    // Check authentication
    if (!authState.isAuthenticated) {
      return _buildSignInPrompt(context, theme);
    }

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          // Handle bar
          _buildHandleBar(theme),

          // Header
          _buildHeader(theme),

          // Step content
          Expanded(
            child: _isLoading
                ? _buildLoadingState(theme)
                : _buildCurrentStep(context, theme),
          ),

          // Step indicator
          _buildStepIndicator(theme),

          // Action buttons
          _buildActionButtons(theme),
        ],
      ),
    );
  }

  /// Build sign-in prompt for unauthenticated users
  Widget _buildSignInPrompt(BuildContext context, ThemeData theme) {
    return Container(
      padding: const EdgeInsets.all(24),
      height: MediaQuery.of(context).size.height * 0.5,
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.login,
            size: 64,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 24),
          Text(
            'Sign In Required',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'Please sign in to add destinations to your trips',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              Navigator.pop(context);
              // Navigate to sign-in screen
            },
            icon: const Icon(Icons.login),
            label: const Text('Sign In'),
          ),
          const SizedBox(height: 12),
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Build the handle bar at the top
  Widget _buildHandleBar(ThemeData theme) {
    return Center(
      child: Container(
        margin: const EdgeInsets.only(top: 12),
        width: 40,
        height: 4,
        decoration: BoxDecoration(
          color: theme.colorScheme.onSurfaceVariant.withOpacity(0.4),
          borderRadius: BorderRadius.circular(2),
        ),
      ),
    );
  }

  /// Build the header with destination info
  Widget _buildHeader(ThemeData theme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest,
              ),
              child: widget.destination.coverImageUrl != null
                  ? Image.network(
                      widget.destination.coverImageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(
                          Icons.place,
                          color: theme.colorScheme.onSurfaceVariant,
                        );
                      },
                    )
                  : Icon(
                      Icons.place,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add to Trip',
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  widget.destination.name,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: () {
              widget.onCancel?.call();
              Navigator.pop(context);
            },
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }

  /// Build the current step content
  Widget _buildCurrentStep(BuildContext context, ThemeData theme) {
    switch (_currentStep) {
      case 0:
        return _buildSelectTripStep(context, theme);
      case 1:
        if (widget.showDatesSelection) {
          return _buildDatesStep(context, theme);
        }
        _currentStep = 2;
        return _buildCurrentStep(context, theme);
      case 2:
        if (widget.showNotesStep) {
          return _buildNotesStep(context, theme);
        }
        _currentStep = 3;
        return _buildCurrentStep(context, theme);
      case 3:
        return _buildConfirmStep(context, theme);
      default:
        return const SizedBox.shrink();
    }
  }

  /// Build step 0: Select or create trip
  Widget _buildSelectTripStep(BuildContext context, ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Select a Trip',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 16),

        // Existing trips
        ...(_mockUserTrips.isEmpty
            ? [
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24),
                    child: Column(
                      children: [
                        Icon(
                          Icons.flight_takeoff,
                          size: 48,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'No trips yet',
                          style: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Create your first trip to get started',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ]
            : _mockUserTrips.map((trip) {
                final isSelected = _selectedTripId == trip['id'];
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  elevation: isSelected ? 4 : 1,
                  color: isSelected
                      ? theme.colorScheme.primaryContainer
                      : theme.colorScheme.surface,
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        _selectedTripId = isSelected ? null : trip['id'] as String;
                        _newTripTitle = null;
                        _newTripDescription = null;
                      });
                    },
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            isSelected
                                ? Icons.check_circle
                                : Icons.radio_button_unchecked,
                            color: isSelected
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  trip['title'] as String,
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  trip['destination'] as String,
                                  style: theme.textTheme.bodySmall?.copyWith(
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              })),

        const SizedBox(height: 16),

        // Create new trip option
        Card(
          margin: const EdgeInsets.only(bottom: 12),
          elevation: _newTripTitle != null ? 4 : 1,
          color: _newTripTitle != null
              ? theme.colorScheme.secondaryContainer
              : theme.colorScheme.surface,
          child: InkWell(
            onTap: () => _showCreateTripDialog(context, theme),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Icon(
                    _newTripTitle != null
                        ? Icons.check_circle
                        : Icons.add_circle_outline,
                    color: _newTripTitle != null
                        ? theme.colorScheme.secondary
                        : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _newTripTitle ?? 'Create New Trip',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        if (_newTripDescription != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            _newTripDescription!,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ] else ...[
                          const SizedBox(height: 4),
                          Text(
                            'Start planning a new adventure',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  Icon(
                    Icons.chevron_right,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ],
              ),
            ),
          ),
        ),

        // Error message
        if (_errorMessage != null)
          Padding(
            padding: const EdgeInsets.only(top: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: theme.colorScheme.errorContainer,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.error_outline,
                    color: theme.colorScheme.onErrorContainer,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: theme.textTheme.bodySmall?.copyWith(
                        color: theme.colorScheme.onErrorContainer,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  /// Build step 1: Select dates
  Widget _buildDatesStep(BuildContext context, ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'When would you like to visit?',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Optional - Select your travel dates',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),

        // Start date
        Card(
          child: ListTile(
            leading: Icon(
              Icons.calendar_today,
              color: theme.colorScheme.primary,
            ),
            title: const Text('Start Date'),
            subtitle: Text(
              _startDate == null
                  ? 'Not set'
                  : '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _selectStartDate(context),
          ),
        ),
        const SizedBox(height: 12),

        // End date
        Card(
          child: ListTile(
            leading: Icon(
              Icons.event,
              color: theme.colorScheme.primary,
            ),
            title: const Text('End Date'),
            subtitle: Text(
              _endDate == null
                  ? 'Not set'
                  : '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _selectEndDate(context),
          ),
        ),
        const SizedBox(height: 24),

        // Info card
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: theme.colorScheme.primaryContainer,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Row(
            children: [
              Icon(
                Icons.info_outline,
                color: theme.colorScheme.onPrimaryContainer,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'You can add dates later in your trip planning',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onPrimaryContainer,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build step 2: Add notes
  Widget _buildNotesStep(BuildContext context, ThemeData theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Text(
          'Add Notes',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Optional - Add personal notes about this destination',
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 24),

        // Notes text field
        TextField(
          decoration: InputDecoration(
            labelText: 'Your Notes',
            hintText: 'e.g., "Must visit the ancient temples", "Try local street food"',
            border: const OutlineInputBorder(),
            alignLabelWithHint: true,
          ),
          maxLines: 8,
          onChanged: (value) {
            setState(() {
              _notes = value;
            });
          },
          controller: TextEditingController(text: _notes),
        ),
        const SizedBox(height: 24),

        // Quick note suggestions
        Text(
          'Quick Add',
          style: theme.textTheme.labelMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            'Must-see attraction',
            'Try local cuisine',
            'Best photo spots',
            'Cultural experience',
          ].map((suggestion) {
            return ActionChip(
              label: Text(suggestion),
              onPressed: () {
                setState(() {
                  if (_notes.isEmpty) {
                    _notes = suggestion;
                  } else {
                    _notes = '$_notes\n$suggestion';
                  }
                });
              },
            );
          }).toList(),
        ),
      ],
    );
  }

  /// Build step 3: Confirmation
  Widget _buildConfirmStep(BuildContext context, ThemeData theme) {
    final tripTitle = _selectedTripId != null
        ? _mockUserTrips
            .firstWhere((trip) => trip['id'] == _selectedTripId)['title'] as String
        : _newTripTitle ?? 'New Trip';

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Success icon
        Center(
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.colorScheme.primaryContainer,
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.check,
              size: 48,
              color: theme.colorScheme.primary,
            ),
          ),
        ),
        const SizedBox(height: 24),

        // Title
        Center(
          child: Text(
            'Ready to Add',
            style: theme.textTheme.headlineSmall?.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text(
            'Please review before confirming',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        const SizedBox(height: 32),

        // Destination card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Destination',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Container(
                        width: 80,
                        height: 80,
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                        ),
                        child: widget.destination.coverImageUrl != null
                            ? Image.network(
                                widget.destination.coverImageUrl!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  return Icon(
                                    Icons.place,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  );
                                },
                              )
                            : Icon(
                                Icons.place,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.destination.name,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.destination.region ??
                                widget.destination.countryCode,
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Trip card
        Card(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Trip',
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    Icon(
                      _selectedTripId != null
                          ? Icons.flight_takeoff
                          : Icons.add_circle,
                      color: theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            tripTitle,
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          if (_selectedTripId == null &&
                              _newTripDescription != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              _newTripDescription!,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 16),

        // Dates (if set)
        if (_startDate != null || _endDate != null)
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Travel Dates',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      if (_startDate != null) ...[
                        Icon(
                          Icons.calendar_today,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_startDate!.year}-${_startDate!.month.toString().padLeft(2, '0')}-${_startDate!.day.toString().padLeft(2, '0')}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                      if (_startDate != null && _endDate != null)
                        const SizedBox(width: 12),
                      if (_endDate != null) ...[
                        Icon(
                          Icons.event,
                          size: 20,
                          color: theme.colorScheme.primary,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          '${_endDate!.year}-${_endDate!.month.toString().padLeft(2, '0')}-${_endDate!.day.toString().padLeft(2, '0')}',
                          style: theme.textTheme.bodyMedium,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),

        // Notes (if added)
        if (_notes.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Notes',
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _notes,
                    style: theme.textTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Build loading state
  Widget _buildLoadingState(ThemeData theme) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            'Adding destination...',
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }

  /// Build step indicator
  Widget _buildStepIndicator(ThemeData theme) {
    final totalSteps = _getTotalSteps();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(totalSteps, (index) {
          final isActive = index == _currentStep;
          final isCompleted = index < _currentStep;
          return Row(
            children: [
              // Step dot
              Container(
                width: isActive ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isCompleted
                      ? theme.colorScheme.primary
                      : isActive
                          ? theme.colorScheme.primary
                          : theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              // Step connector
              if (index < totalSteps - 1)
                Container(
                  width: 8,
                  height: 2,
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  color: isCompleted
                      ? theme.colorScheme.primary
                      : theme.colorScheme.onSurfaceVariant.withOpacity(0.3),
                ),
            ],
          );
        }),
      ),
    );
  }

  /// Build action buttons
  Widget _buildActionButtons(ThemeData theme) {
    final isFirstStep = _currentStep == 0;
    final isLastStep = _currentStep == _getTotalSteps() - 1;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: theme.shadowColor.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Back button
            if (!isFirstStep)
              Expanded(
                child: OutlinedButton(
                  onPressed: () {
                    setState(() {
                      _currentStep--;
                      _errorMessage = null;
                    });
                  },
                  child: const Text('Back'),
                ),
              ),
            if (!isFirstStep) const SizedBox(width: 12),

            // Next/Confirm button
            Expanded(
              flex: isFirstStep ? 1 : 2,
              child: ElevatedButton(
                onPressed: _canProceed() ? _handleNext : null,
                child: Text(isLastStep ? 'Confirm & Add' : 'Next'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Get total number of steps
  int _getTotalSteps() {
    int steps = 2; // Select trip + Confirm
    if (widget.showDatesSelection) steps++;
    if (widget.showNotesStep) steps++;
    return steps;
  }

  /// Check if user can proceed to next step
  bool _canProceed() {
    switch (_currentStep) {
      case 0:
        return _selectedTripId != null || _newTripTitle != null;
      case 1:
      case 2:
      case 3:
        return true;
      default:
        return false;
    }
  }

  /// Handle next button press
  void _handleNext() async {
    setState(() {
      _errorMessage = null;
    });

    // If on confirm step, execute the add operation
    if (_currentStep == _getTotalSteps() - 1) {
      await _executeAddToTrip();
    } else {
      setState(() {
        _currentStep++;
      });
    }
  }

  /// Show create trip dialog
  void _showCreateTripDialog(BuildContext context, ThemeData theme) {
    final titleController = TextEditingController(text: _newTripTitle);
    final descriptionController =
        TextEditingController(text: _newTripDescription);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create New Trip'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: titleController,
              decoration: const InputDecoration(
                labelText: 'Trip Title',
                hintText: 'e.g., Summer Adventure 2024',
                border: OutlineInputBorder(),
              ),
              autofocus: true,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: descriptionController,
              decoration: const InputDecoration(
                labelText: 'Description (Optional)',
                hintText: 'e.g., Exploring new destinations',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (titleController.text.trim().isEmpty) {
                setState(() {
                  _errorMessage = 'Please enter a trip title';
                });
                return;
              }
              setState(() {
                _newTripTitle = titleController.text.trim();
                _newTripDescription = descriptionController.text.trim();
                _selectedTripId = null;
                _errorMessage = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Create'),
          ),
        ],
      ),
    );
  }

  /// Select start date
  Future<void> _selectStartDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _startDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked;
        // Adjust end date if it's before start date
        if (_endDate != null && _endDate!.isBefore(_startDate!)) {
          _endDate = _startDate;
        }
      });
    }
  }

  /// Select end date
  Future<void> _selectEndDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _endDate ?? _startDate ?? DateTime.now(),
      firstDate: _startDate ?? DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (picked != null) {
      setState(() {
        _endDate = picked;
      });
    }
  }

  /// Execute add to trip operation
  Future<void> _executeAddToTrip() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      // TODO: Integrate with trip planning provider (subtask 7.2)
      // For now, simulate the operation
      await Future.delayed(const Duration(seconds: 1));

      // Prepare trip data
      final tripId = _selectedTripId ?? 'new_trip_${DateTime.now().millisecondsSinceEpoch}';
      final tripTitle = _selectedTripId != null
          ? _mockUserTrips
              .firstWhere((trip) => trip['id'] == _selectedTripId)['title'] as String
          : _newTripTitle!;

      // TODO: Call trip planning provider to add destination
      // await ref.read(addToTripProvider.notifier).addDestinationToTrip(
      //   tripId: tripId,
      //   destination: widget.destination,
      //   startDate: _startDate,
      //   endDate: _endDate,
      //   notes: _notes,
      // );

      // Success
      setState(() {
        _isLoading = false;
      });

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Expanded(
                  child: Text('Added "${widget.destination.name}" to $tripTitle'),
                ),
              ],
            ),
            backgroundColor: theme.colorScheme.primary,
            duration: const Duration(seconds: 3),
          ),
        );
      }

      // Call success callback
      widget.onSuccess?.call(tripId, tripTitle);

      // Close flow
      if (mounted) {
        Navigator.pop(context);
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Failed to add destination to trip. Please try again.';
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: ${e.toString()}'),
            backgroundColor: theme.colorScheme.error,
          ),
        );
      }
    }
  }
}
