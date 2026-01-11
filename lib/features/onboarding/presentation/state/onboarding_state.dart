import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/onboarding_data.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary.dart';

part 'onboarding_state.freezed.dart';

/// Onboarding form state
///
/// Manages the state of the onboarding form including user input,
/// validation status, and the generated itinerary result.
///
/// This is a sealed union type that represents all possible states
/// of the onboarding flow. Use pattern matching with the `when` method
/// to handle each state appropriately.
@freezed
sealed class OnboardingState with _$OnboardingState {
  /// Initial state - form is empty and not submitted
  const factory OnboardingState.initial() = OnboardingInitial;

  /// Form is being filled out - contains partial user input
  const factory OnboardingState.inProgress({
    /// The current onboarding data being filled
    required OnboardingData data,

    /// Whether the current data passes validation
    @Default(false) bool isValid,

    /// Validation errors for the current data
    @Default(<String>[]) List<String> validationErrors,
  }) = OnboardingInProgress;

  /// Form has been submitted and itinerary is being generated
  const factory OnboardingState.submitting({
    /// The data that was submitted
    required OnboardingData data,
  }) = OnboardingSubmitting;

  /// Itinerary was successfully generated
  const factory OnboardingState.success({
    /// The data that was submitted
    required OnboardingData data,

    /// The generated itinerary
    required Itinerary itinerary,
  }) = OnboardingSuccess;

  /// An error occurred during itinerary generation
  const factory OnboardingState.error({
    /// The data that was submitted
    required OnboardingData data,

    /// The error message
    required String message,

    /// Optional error details
    String? details,
  }) = OnboardingError;

  /// Whether the form is in initial state
  bool get isInitial => this is OnboardingInitial;

  /// Whether the form is being filled out
  bool get isInProgress => this is OnboardingInProgress;

  /// Whether the form is being submitted
  bool get isSubmitting => this is OnboardingSubmitting;

  /// Whether the submission was successful
  bool get isSuccess => this is OnboardingSuccess;

  /// Whether there's an error
  bool get isError => this is OnboardingError;

  /// Gets the current data if available
  OnboardingData? get data => switch (this) {
        OnboardingInitial() => null,
        OnboardingInProgress(:final data) => data,
        OnboardingSubmitting(:final data) => data,
        OnboardingSuccess(:final data) => data,
        OnboardingError(:final data) => data,
      };

  /// Gets the generated itinerary if successful
  Itinerary? get itinerary => switch (this) {
        OnboardingSuccess(:final itinerary) => itinerary,
        _ => null,
      };

  // Private constructor for freezed getters
  const OnboardingState._();
}
