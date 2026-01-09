import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/budget_range.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/date_range.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/destination.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/onboarding_data.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/travel_interest.dart';
import 'package:soloadventurer/features/onboarding/domain/usecases/generate_starter_itinerary.dart';
import 'package:soloadventurer/features/onboarding/presentation/state/onboarding_state.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary.dart';

part 'onboarding_notifier.g.dart';

/// Notifier for managing onboarding form state
///
/// Handles the onboarding flow from form input through itinerary generation.
/// Uses a freezed state union type to represent the different states of
/// the onboarding process.
@riverpod
class OnboardingNotifier extends _$OnboardingNotifier {
  /// Initialize the onboarding flow with empty form data
  @override
  OnboardingState build() {
    return const OnboardingState.initial();
  }

  /// Update the onboarding data as the user fills out the form
  ///
  /// [data] The current onboarding data from the form
  void updateFormData(OnboardingData data) {
    state = OnboardingState.inProgress(
      data: data,
      isValid: data.isValid,
      validationErrors: data.validationErrors,
    );
  }

  /// Update the user's name
  ///
  /// [name] The user's name
  void updateName(String name) {
    final currentData = _getCurrentData();
    final updatedData = currentData.copyWith(name: name);
    updateFormData(updatedData);
  }

  /// Update the destination
  ///
  /// [destination] The selected destination
  void updateDestination(Destination destination) {
    final currentData = _getCurrentData();
    final updatedData = currentData.copyWith(destination: destination);
    updateFormData(updatedData);
  }

  /// Update the date range
  ///
  /// [dateRange] The selected travel dates
  void updateDateRange(DateRange dateRange) {
    final currentData = _getCurrentData();
    final updatedData = currentData.copyWith(dateRange: dateRange);
    updateFormData(updatedData);
  }

  /// Update the selected interests
  ///
  /// [interests] The set of selected travel interests
  void updateInterests(Set<TravelInterest> interests) {
    final currentData = _getCurrentData();
    final updatedData = currentData.copyWith(interests: interests);
    updateFormData(updatedData);
  }

  /// Add or remove a single interest
  ///
  /// [interest] The interest to toggle
  void toggleInterest(TravelInterest interest) {
    final currentData = _getCurrentData();
    final currentInterests = currentData.interests;

    Set<TravelInterest> updatedInterests;
    if (currentInterests.contains(interest)) {
      updatedInterests = currentInterests.where((i) => i != interest).toSet();
    } else {
      // Limit to 5 interests
      if (currentInterests.length >= 5) {
        return;
      }
      updatedInterests = {...currentInterests, interest};
    }

    final updatedData = currentData.copyWith(interests: updatedInterests);
    updateFormData(updatedData);
  }

  /// Update the budget range
  ///
  /// [budget] The selected budget preference (optional)
  void updateBudget(BudgetRange? budget) {
    final currentData = _getCurrentData();
    final updatedData = currentData.copyWith(budget: budget);
    updateFormData(updatedData);
  }

  /// Validate the current form data
  ///
  /// Returns true if the data is valid, false otherwise.
  /// Updates the state with validation errors.
  bool validateForm() {
    final currentData = _getCurrentData();
    final isValid = currentData.isValid;
    final errors = currentData.validationErrors;

    state = OnboardingState.inProgress(
      data: currentData,
      isValid: isValid,
      validationErrors: errors,
    );

    return isValid;
  }

  /// Submit the onboarding form and generate the itinerary
  ///
  /// Validates the form data first, then calls the use case to generate
  /// the starter itinerary. Updates state through the submission process.
  Future<void> submitForm(GenerateStarterItinerary generateItinerary) async {
    final currentData = _getCurrentData();

    // Validate before submitting
    if (!currentData.isValid) {
      state = OnboardingState.inProgress(
        data: currentData,
        isValid: false,
        validationErrors: currentData.validationErrors,
      );
      return;
    }

    // Update to submitting state
    state = OnboardingState.submitting(data: currentData);

    try {
      // Call the use case to generate the itinerary
      final itineraryJson = await generateItinerary(currentData);

      // Convert JSON to Itinerary object
      final itinerary = Itinerary.fromJson(itineraryJson);

      // Update to success state
      state = OnboardingState.success(
        data: currentData,
        itinerary: itinerary,
      );
    } on ValidationException catch (e) {
      state = OnboardingState.error(
        data: currentData,
        message: e.message,
        details: e.errors.values.expand((e) => e).join(', '),
      );
    } on ServerException catch (e) {
      state = OnboardingState.error(
        data: currentData,
        message: e.message,
        details: e.code ?? 'server_error',
      );
    } on NetworkConnectivityException catch (e) {
      state = OnboardingState.error(
        data: currentData,
        message: 'Network connection required. Please check your internet.',
        details: e.message,
      );
    } on CacheException catch (e) {
      state = OnboardingState.error(
        data: currentData,
        message: 'Unable to save your itinerary. Please try again.',
        details: e.message,
      );
    } on AppException catch (e) {
      state = OnboardingState.error(
        data: currentData,
        message: 'Something went wrong. Please try again.',
        details: e.message,
      );
    } catch (e) {
      state = OnboardingState.error(
        data: currentData,
        message: 'An unexpected error occurred',
        details: e.toString(),
      );
    }
  }

  /// Reset the onboarding flow to initial state
  void reset() {
    state = const OnboardingState.initial();
  }

  /// Get the current onboarding data, or return empty data if in initial state
  OnboardingData _getCurrentData() {
    return switch (state) {
      OnboardingInitial() => OnboardingData(
          name: '',
          destination: const Destination(
            placeId: '',
            name: '',
            latitude: 0,
            longitude: 0,
          ),
          dateRange: DateRange(
            start: DateTime.now(),
            end: DateTime.now().add(const Duration(days: 7)),
          ),
          interests: {},
        ),
      OnboardingInProgress(:final data) => data,
      OnboardingSubmitting(:final data) => data,
      OnboardingSuccess(:final data) => data,
      OnboardingError(:final data) => data,
    };
  }
}
