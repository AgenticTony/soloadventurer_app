import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/date_range.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/destination.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/travel_interest.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/place_activity.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation.dart';

part 'recommendation_request.freezed.dart';
part 'recommendation_request.g.dart';

/// Request for personalized recommendations
///
/// Contains all the context needed to generate relevant recommendations
/// including trip details, user interests, and preferences.
@freezed
class RecommendationRequest with _$RecommendationRequest {
  const RecommendationRequest._();

  /// Creates a recommendation request
  ///
  /// [itineraryId] ID of the itinerary to get recommendations for
  /// [destination] Trip destination
  /// [tripDates] Date range of the trip
  /// [interests] User's travel interests
  /// [hotelLocation] Optional accommodation location for distance calculations
  /// [budget] Optional budget preference
  /// [categories] Specific categories to include (null = all)
  /// [weatherPreference] Weather context preferences
  /// [maxDistance] Maximum distance from accommodation
  /// [limit] Maximum number of recommendations to return
  /// [excludeItineraryItems] Whether to exclude items already in itinerary
  const factory RecommendationRequest({
    required String itineraryId,
    required Destination destination,
    required DateRange tripDates,
    required Set<TravelInterest> interests,
    HotelLocation? hotelLocation,
    BudgetRange? budget,
    Set<RecommendationCategory>? categories,
    Set<WeatherContext>? weatherPreference,
    DistanceFromHotel? maxDistance,
    @Default(20) int limit,
    @Default(true) bool excludeItineraryItems,
  }) = _RecommendationRequest;

  /// Creates a RecommendationRequest from JSON
  factory RecommendationRequest.fromJson(Map<String, dynamic> json) =>
      _$RecommendationRequestFromJson(json);

  /// Validates that the request has all required data
  bool get isValid {
    return itineraryId.isNotEmpty &&
        destination.isValid &&
        tripDates.isValid &&
        interests.isNotEmpty;
  }

  /// Returns a display string for the interests
  String get interestsDisplay {
    if (interests.isEmpty) return 'All interests';
    if (interests.length <= 2) {
      return interests.map((i) => i.label).join(' & ');
    }
    return '${interests.first.label} +${interests.length - 1} more';
  }
}

/// Location of user's accommodation
@freezed
class HotelLocation with _$HotelLocation {
  const HotelLocation._();

  /// Creates a hotel location
  ///
  /// [name] Name of hotel/accommodation
  /// [address] Address
  /// [latitude] Latitude coordinate
  /// [longitude] Longitude coordinate
  const factory HotelLocation({
    required String name,
    String? address,
    required double latitude,
    required double longitude,
  }) = _HotelLocation;

  /// Creates HotelLocation from JSON
  factory HotelLocation.fromJson(Map<String, dynamic> json) =>
      _$HotelLocationFromJson(json);
}

/// Budget range for filtering recommendations
@freezed
class BudgetRange with _$BudgetRange {
  const BudgetRange._();

  /// Creates a budget range
  ///
  /// [min] Minimum amount (null = no minimum)
  /// [max] Maximum amount (null = no maximum)
  /// [currency] Currency code
  const factory BudgetRange({
    double? min,
    double? max,
    @Default('USD') String currency,
  }) = _BudgetRange;

  /// Creates BudgetRange from JSON
  factory BudgetRange.fromJson(Map<String, dynamic> json) =>
      _$BudgetRangeFromJson(json);

  /// Checks if a given amount is within this budget range
  bool contains(double amount) {
    if (min != null && amount < min!) return false;
    if (max != null && amount > max!) return false;
    return true;
  }

  /// Returns a display string for the budget
  String get display {
    final symbol = _currencySymbol;
    if (min != null && max != null) {
      return '$symbol${min!.toStringAsFixed(0)} - $symbol${max!.toStringAsFixed(0)}';
    } else if (min != null) {
      return 'From $symbol${min!.toStringAsFixed(0)}';
    } else if (max != null) {
      return 'Up to $symbol${max!.toStringAsFixed(0)}';
    }
    return 'Any budget';
  }

  String get _currencySymbol {
    switch (currency.toUpperCase()) {
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'USD':
      default:
        return '\$';
    }
  }
}

/// User feedback on a recommendation
enum RecommendationFeedback {
  /// This recommendation was helpful
  helpful,

  /// This recommendation was not helpful
  notHelpful,

  /// User is not interested in this type of activity
  notInterested,

  /// User has already done this
  alreadyDone,

  /// The recommendation information was inaccurate
  inaccurate,
}
