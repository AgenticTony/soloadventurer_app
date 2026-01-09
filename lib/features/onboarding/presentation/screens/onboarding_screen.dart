import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:soloadventurer/core/config/google_places_config.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/budget_range.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/date_range.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/destination.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/travel_interest.dart';
import 'package:soloadventurer/features/onboarding/presentation/notifiers/onboarding_notifier.dart';
import 'package:soloadventurer/features/onboarding/presentation/providers/onboarding_providers.dart';
import 'package:soloadventurer/features/onboarding/presentation/routes/onboarding_routes.dart';
import 'package:soloadventurer/features/onboarding/presentation/state/onboarding_state.dart';
import 'package:soloadventurer/features/onboarding/presentation/widgets/budget_selection_widget.dart';
import 'package:soloadventurer/features/onboarding/presentation/widgets/travel_interest_chip.dart';

/// Onboarding screen for collecting user preferences and generating a starter itinerary
///
/// Features:
/// - Collects user's name, destination, travel dates, interests, and budget
/// - Real-time form validation
/// - Google Places autocomplete for destination search
/// - Interactive interest selection with 5-interest limit
/// - Optional budget preference
/// - Loading and error states
/// - Navigates to success screen on successful itinerary generation
class OnboardingScreen extends ConsumerStatefulWidget {
  const OnboardingScreen({super.key});

  @override
  ConsumerState<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends ConsumerState<OnboardingScreen> {
  // Form key for validation
  final _formKey = GlobalKey<FormState>();

  // Text editing controllers
  final _nameController = TextEditingController();
  final _destinationController = TextEditingController();

  // Selected values
  Destination? _selectedDestination;
  DateRange? _selectedDateRange;
  final Set<TravelInterest> _selectedInterests = {};
  BudgetRange? _selectedBudget;

  // Validation state
  String? _nameError;
  String? _destinationError;
  String? _dateRangeError;
  String? _interestsError;

  @override
  void initState() {
    super.initState();
    // Initialize with default date range (next 7 days)
    final now = DateTime.now();
    _selectedDateRange = DateRange(
      start: now,
      end: now.add(const Duration(days: 7)),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _destinationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch for state changes to get isSubmitting status
    final state = ref.watch(onboardingNotifierProvider);
    final isSubmitting = state.isSubmitting;

    // Listen for state changes
    ref.listen<OnboardingState>(onboardingNotifierProvider, (previous, next) {
      switch (next) {
        case OnboardingInitial():
        case OnboardingInProgress():
        case OnboardingSubmitting():
          break;
        case OnboardingSuccess(data: _, :final itinerary):
          // Navigate to success screen using named route
          Navigator.of(context).pushReplacementNamed(
            OnboardingRoutes.starterItinerary,
            arguments: {'itinerary': itinerary},
          );
          break;
        case OnboardingError(:final message):
          // Show error snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(message),
              backgroundColor: Colors.red,
              action: SnackBarAction(
                label: 'Dismiss',
                textColor: Colors.white,
                onPressed: () {
                  ScaffoldMessenger.of(context).hideCurrentSnackBar();
                },
              ),
            ),
          );
          break;
      }
    });

    return Scaffold(
      appBar: AppBar(
        title: const Text('Plan Your Solo Adventure'),
        elevation: 0,
      ),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome message
              _buildWelcomeHeader(context),

              const SizedBox(height: 24),

              // Name field
              _buildNameField(context),

              const SizedBox(height: 16),

              // Destination field
              _buildDestinationField(context),

              const SizedBox(height: 16),

              // Date range field
              _buildDateRangeField(context),

              const SizedBox(height: 24),

              // Interests section
              _buildInterestsSection(context),

              const SizedBox(height: 24),

              // Budget section
              _buildBudgetSection(context),

              const SizedBox(height: 32),

              // Submit button
              _buildSubmitButton(context, isSubmitting),

              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the welcome header section
  Widget _buildWelcomeHeader(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          "Let's plan your solo adventure! ✈️",
          style: theme.textTheme.headlineSmall?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          'Tell us about your trip and we\'ll create a personalized starter itinerary for you.',
          style: theme.textTheme.bodyMedium?.copyWith(
            color: Colors.grey[600],
          ),
        ),
      ],
    );
  }

  /// Builds the name input field
  Widget _buildNameField(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Your Name',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        TextFormField(
          controller: _nameController,
          decoration: InputDecoration(
            hintText: 'Enter your name',
            prefixIcon: const Icon(Icons.person),
            errorText: _nameError,
            filled: true,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          enabled: !ref.watch(isOnboardingSubmittingProvider),
          onChanged: (value) {
            setState(() {
              _nameError = null;
            });
            ref.read(onboardingNotifierProvider.notifier).updateName(value);
          },
        ),
      ],
    );
  }

  /// Builds the destination search field with Google Places autocomplete
  Widget _buildDestinationField(BuildContext context) {
    final theme = Theme.of(context);
    final apiKey = GooglePlacesConfig.apiKey;
    final isSubmitting = ref.watch(isOnboardingSubmittingProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Where are you going?',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        if (apiKey.isNotEmpty)
          Container(
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border.all(
                color: _destinationError != null
                    ? theme.colorScheme.error
                    : theme.colorScheme.outline,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Stack(
              children: [
                GooglePlaceAutoCompleteTextField(
                  textEditingController: _destinationController,
                  googleAPIKey: apiKey,
                  itemBuilder: (context, index, Prediction prediction) {
                    return ListTile(
                      leading: const Icon(Icons.place),
                      title: Text(prediction.description ?? ''),
                      subtitle:
                          prediction.structuredFormatting?.secondaryText != null
                              ? Text(
                                  prediction
                                      .structuredFormatting!.secondaryText!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                )
                              : null,
                    );
                  },
                  itemClick: (Prediction prediction) {
                    _destinationController.text = prediction.description ?? '';
                    setState(() {
                      _selectedDestination = Destination(
                        placeId: prediction.placeId ?? '',
                        name: prediction.structuredFormatting?.mainText ??
                            prediction.description ??
                            '',
                        latitude: 0, // Will be fetched from place details
                        longitude: 0,
                      );
                      _destinationError = null;
                    });
                    ref
                        .read(onboardingNotifierProvider.notifier)
                        .updateDestination(_selectedDestination!);
                  },
                ),
                if (_selectedDestination != null)
                  Positioned(
                    right: 8,
                    top: 8,
                    bottom: 8,
                    child: IconButton(
                      icon: const Icon(Icons.clear),
                      onPressed: isSubmitting
                          ? null
                          : () {
                              setState(() {
                                _destinationController.clear();
                                _selectedDestination = null;
                              });
                            },
                    ),
                  ),
              ],
            ),
          )
        else
          // Fallback if API key not configured
          TextFormField(
            controller: _destinationController,
            decoration: InputDecoration(
              hintText: 'Enter destination (API key not configured)',
              prefixIcon: const Icon(Icons.place),
              errorText: _destinationError,
              filled: true,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            enabled: false,
          ),
      ],
    );
  }

  /// Builds the date range selection field
  Widget _buildDateRangeField(BuildContext context) {
    final theme = Theme.of(context);
    final startDate = _selectedDateRange?.start;
    final endDate = _selectedDateRange?.end;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'When are you traveling?',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        InkWell(
          onTap: !ref.watch(isOnboardingSubmittingProvider)
              ? () => _selectDateRange(context)
              : null,
          borderRadius: BorderRadius.circular(12),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: theme.colorScheme.surface,
              border: Border.all(
                color: _dateRangeError != null
                    ? theme.colorScheme.error
                    : theme.colorScheme.outline.withValues(alpha: 0.5),
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.calendar_today),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    startDate != null && endDate != null
                        ? '${_formatDate(startDate)} - ${_formatDate(endDate)}'
                        : 'Select travel dates',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: (startDate == null || endDate == null)
                          ? Colors.grey[600]
                          : null,
                    ),
                  ),
                ),
                const Icon(Icons.arrow_drop_down),
              ],
            ),
          ),
        ),
        if (_dateRangeError != null)
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8),
            child: Text(
              _dateRangeError!,
              style: TextStyle(
                color: theme.colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  /// Builds the interests selection section
  Widget _buildInterestsSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'What interests you?',
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: theme.colorScheme.primary,
              ),
            ),
            Text(
              '${_selectedInterests.length}/5 selected',
              style: theme.textTheme.bodySmall?.copyWith(
                color: _selectedInterests.length == 5
                    ? Colors.green
                    : Colors.grey[600],
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Text(
          'Select up to 5 interests to personalize your itinerary',
          style: theme.textTheme.bodySmall?.copyWith(
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 12),
        TravelInterestGrid(
          availableInterests: TravelInterest.values.toSet(),
          selectedInterests: _selectedInterests,
          onToggle: (interest, selected) {
            setState(() {
              if (selected) {
                _selectedInterests.add(interest);
              } else {
                _selectedInterests.remove(interest);
              }
              _interestsError = null;
            });
            ref
                .read(onboardingNotifierProvider.notifier)
                .updateInterests(_selectedInterests);
          },
          enabled: !ref.watch(isOnboardingSubmittingProvider),
          useCompactChips: false,
          crossAxisCount: 2,
        ),
        if (_interestsError != null)
          Padding(
            padding: const EdgeInsets.only(left: 4, top: 8),
            child: Text(
              _interestsError!,
              style: TextStyle(
                color: theme.colorScheme.error,
                fontSize: 12,
              ),
            ),
          ),
      ],
    );
  }

  /// Builds the budget selection section
  Widget _buildBudgetSection(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Budget Preference (Optional)',
          style: theme.textTheme.titleMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 8),
        BudgetSelectionCompact(
          selectedBudget: _selectedBudget,
          onBudgetChanged: (budget) {
            setState(() {
              _selectedBudget = budget;
            });
            ref.read(onboardingNotifierProvider.notifier).updateBudget(budget);
          },
          isRequired: false,
          showSkipOption: true,
        ),
      ],
    );
  }

  /// Builds the submit button
  Widget _buildSubmitButton(BuildContext context, bool isSubmitting) {
    final isValid = _isFormValid();

    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        onPressed: isSubmitting || !isValid ? null : () => _submitForm(context),
        style: FilledButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isSubmitting
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Get My Free Trip Plan',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
      ),
    );
  }

  /// Opens date range picker dialog
  Future<void> _selectDateRange(BuildContext context) async {
    final now = DateTime.now();
    final initialDateRange = _selectedDateRange;
    final picked = await showDateRangePicker(
      context: context,
      firstDate: now,
      lastDate: DateTime(now.year + 2),
      initialDateRange: DateTimeRange(
        start: initialDateRange?.start ?? now,
        end: initialDateRange?.end ?? now.add(const Duration(days: 7)),
      ),
      saveText: 'Select',
    );

    if (picked != null) {
      setState(() {
        _selectedDateRange = DateRange(
          start: picked.start,
          end: picked.end,
        );
        _dateRangeError = null;
      });
      ref
          .read(onboardingNotifierProvider.notifier)
          .updateDateRange(_selectedDateRange!);
    }
  }

  /// Validates the form
  bool _isFormValid() {
    bool isValid = true;

    // Validate name
    if (_nameController.text.trim().isEmpty) {
      _nameError = 'Please enter your name';
      isValid = false;
    } else {
      _nameError = null;
    }

    // Validate destination
    if (_selectedDestination == null) {
      _destinationError = 'Please select a destination';
      isValid = false;
    } else {
      _destinationError = null;
    }

    // Validate date range
    if (_selectedDateRange == null || !_selectedDateRange!.isValid) {
      _dateRangeError = 'Please select valid travel dates';
      isValid = false;
    } else {
      _dateRangeError = null;
    }

    // Validate interests
    if (_selectedInterests.isEmpty) {
      _interestsError = 'Please select at least one interest';
      isValid = false;
    } else if (_selectedInterests.length > 5) {
      _interestsError = 'Please select no more than 5 interests';
      isValid = false;
    } else {
      _interestsError = null;
    }

    if (isValid) {
      setState(() {}); // Clear errors
    }

    return isValid;
  }

  /// Submits the form and generates itinerary
  void _submitForm(BuildContext context) {
    if (!_isFormValid()) {
      // Scroll to first error
      // For simplicity, just show a snackbar
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please fix the errors before submitting'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Generate itinerary
    ref.read(onboardingNotifierProvider.notifier).submitForm(
          ref.read(generateStarterItineraryProvider),
        );
  }

  /// Formats a date for display
  String _formatDate(DateTime date) {
    return '${date.month}/${date.day}/${date.year}';
  }
}

/// Shows date range picker (using package:syncfusion_flutter_datepicker or similar)
/// For now, this is a placeholder. In production, you'd use a proper date range picker.
Future<DateTimeRange?> showDateRangePicker({
  required BuildContext context,
  required DateTime firstDate,
  required DateTime lastDate,
  required DateTimeRange initialDateRange,
  required String saveText,
}) async {
  // This is a simplified implementation
  // In production, you'd use showDatePicker twice or a dedicated date range picker package

  // For now, return the initial range (placeholder)
  // TODO: Implement proper date range picker
  return initialDateRange;
}
