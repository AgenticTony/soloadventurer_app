import 'package:freezed_annotation/freezed_annotation.dart';
import 'travel_interest.dart';
import 'date_range.dart';
import 'budget_range.dart';
import 'destination.dart';

part 'onboarding_data.freezed.dart';
part 'onboarding_data.g.dart';

/// Complete onboarding data collected from the user
///
/// This entity contains all information collected during the onboarding flow,
/// including the user's name, destination, travel dates, interests, and budget.
/// It serves as input for generating a personalized starter itinerary.
@freezed
sealed class OnboardingData with _$OnboardingData {
  /// Creates complete onboarding data
  ///
  /// [name] The user's name for personalization
  /// [destination] Where the user plans to travel
  /// [dateRange] When the user plans to travel
  /// [interests] What activities the user is interested in
  /// [budget] Optional budget preference
  const factory OnboardingData({
    required String name,
    required Destination destination,
    required DateRange dateRange,
    required Set<TravelInterest> interests,
    BudgetRange? budget,
  }) = _OnboardingData;

  /// Creates OnboardingData from JSON
  factory OnboardingData.fromJson(Map<String, dynamic> json) =>
      _$OnboardingDataFromJson(json);

  /// Validates that all required fields are present and logical
  ///
  /// Returns true if:
  /// - Name is not empty
  /// - Destination is valid
  /// - Date range is valid
  /// - At least one interest is selected
  bool get isValid {
    return name.trim().isNotEmpty &&
        destination.isValid &&
        dateRange.isValid &&
        interests.isNotEmpty;
  }

  /// Returns a list of validation errors if any
  ///
  /// Returns empty list if data is valid, otherwise returns
  /// human-readable error messages describing what's missing or invalid.
  List<String> get validationErrors {
    final errors = <String>[];

    if (name.trim().isEmpty) {
      errors.add('Please enter your name');
    }

    if (!destination.isValid) {
      errors.add('Please select a valid destination');
    }

    if (!dateRange.isValid) {
      errors.add('Please select valid travel dates');
    }

    if (interests.isEmpty) {
      errors.add('Please select at least one interest');
    }

    if (interests.length > 5) {
      errors.add('Please select no more than 5 interests');
    }

    return errors;
  }

  /// Returns a summary string for display
  ///
  /// Example: "John's trip to Paris, France (May 11-18, 2026)"
  String get summary {
    final interestsStr = interests.map((i) => i.label).take(3).join(', ');
    final interestsSuffix =
        interests.length > 3 ? ' +${interests.length - 3} more' : '';
    return "$name's trip to ${destination.formattedLocation} "
        '(${dateRange.formatted}) - $interestsStr$interestsSuffix';
  }

  // Private constructor for freezed getters
  const OnboardingData._();
}
