import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/travel_interest.dart';

part 'recommendation.freezed.dart';
part 'recommendation.g.dart';

/// A personalized recommendation with rich metadata and reasoning
///
/// Unlike the basic Recommendation class in core/services, this includes
/// personalization metadata, scoring details, and transparent reasoning.
@freezed
class PersonalizedRecommendation with _$PersonalizedRecommendation {
  const PersonalizedRecommendation._();

  /// Creates a personalized recommendation
  ///
  /// [id] Unique identifier for this recommendation
  /// [activity] The place/activity being recommended
  /// [metadata] Personalization metadata (timing, weather, distance, etc.)
  /// [reasoning] Human-readable explanation of why this was recommended
  /// [relevanceScore] How well this matches user preferences (0-100)
  /// [source] Where this recommendation came from
  /// [isSaved] Whether user saved this for later
  /// [isAddedToItinerary] Whether user added this to their itinerary
  const factory PersonalizedRecommendation({
    required String id,
    required PlaceActivity activity,
    required RecommendationMetadata metadata,
    required String reasoning,
    @Default(0.0) double relevanceScore,
    @Default(RecommendationSource.personalized) RecommendationSource source,
    @Default(false) bool isSaved,
    @Default(false) bool isAddedToItinerary,
  }) = _PersonalizedRecommendation;

  /// Returns the score color based on relevance
  ScoreColor get scoreColor {
    if (relevanceScore >= 80) return ScoreColor.excellent;
    if (relevanceScore >= 60) return ScoreColor.good;
    if (relevanceScore >= 40) return ScoreColor.fair;
    return ScoreColor.poor;
  }
}

/// Color categories for relevance scores
enum ScoreColor {
  excellent,
  good,
  fair,
  poor,
}

/// Metadata about why and when to recommend something
@freezed
class RecommendationMetadata with _$RecommendationMetadata {
  const RecommendationMetadata._();

  /// Creates recommendation metadata
  ///
  /// [matchedInterests] Which user interests this matches
  /// [suggestedDate] Best date to visit during trip
  /// [suggestedTime] Best time of day to visit
  /// [distance] How far from user's accommodation
  /// [weather] Weather context for this recommendation
  /// [crowdLevel] Expected crowd level
  /// [estimatedCost] How much this will cost
  /// [estimatedDuration] How long to spend here
  /// [bookingUrl] Where to book if needed
  /// [requiresAdvanceBooking] Whether booking ahead is necessary
  /// [isIndoor] Whether this is an indoor activity
  const factory RecommendationMetadata({
    required Set<TravelInterest> matchedInterests,
    required DateTime suggestedDate,
    required TimeOfDay suggestedTime,
    required DistanceFromHotel distance,
    required WeatherContext weather,
    required CrowdLevel crowdLevel,
    Money? estimatedCost,
    @Default(Duration.zero) Duration estimatedDuration,
    String? bookingUrl,
    @Default(false) bool requiresAdvanceBooking,
    @Default(false) bool isIndoor,
  }) = _RecommendationMetadata;

  /// Creates RecommendationMetadata from JSON
  factory RecommendationMetadata.fromJson(Map<String, dynamic> json) =>
      _$RecommendationMetadataFromJson(json);
}

/// Time of day for a suggestion
@freezed
class TimeOfDay with _$TimeOfDay {
  const TimeOfDay._();

  /// Creates a time of day
  ///
  /// [hour] Hour (0-23)
  /// [minute] Minute (0-59)
  const factory TimeOfDay({
    required int hour,
    @Default(0) int minute,
  }) = _TimeOfDay;

  /// Creates TimeOfDay from JSON
  factory TimeOfDay.fromJson(Map<String, dynamic> json) =>
      _$TimeOfDayFromJson(json);

  /// Returns formatted time string (e.g., "9:00 AM")
  String get formatted {
    final period = hour >= 12 ? 'PM' : 'AM';
    final displayHour = hour > 12 ? hour - 12 : (hour == 0 ? 12 : hour);
    final displayMinute = minute.toString().padLeft(2, '0');
    return '$displayHour:$displayMinute $period';
  }

  /// Converts to DateTime
  DateTime toDateTime(DateTime date) {
    return DateTime(date.year, date.month, date.day, hour, minute);
  }
}

/// Represents a monetary amount
@freezed
class Money with _$Money {
  const Money._();

  /// Creates a money value
  ///
  /// [amount] The numeric amount
  /// [currency] Currency code (e.g., "USD", "EUR")
  const factory Money({
    required double amount,
    @Default('USD') String currency,
  }) = _Money;

  /// Creates Money from JSON
  factory Money.fromJson(Map<String, dynamic> json) =>
      _$MoneyFromJson(json);

  /// Returns formatted string (e.g., "€20.00")
  String get formatted {
    final symbol = _currencySymbol;
    return '$symbol${amount.toStringAsFixed(2)}';
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

/// Source of a recommendation
enum RecommendationSource {
  /// AI-generated based on user profile and preferences
  personalized,

  /// "Travelers like you also enjoyed" - collaborative filtering
  collaborative,

  /// Popular right now at destination
  trending,

  /// Local tips/expert curated
  local,

  /// Based on current location/time
  contextual,
}

/// Distance category from accommodation
enum DistanceFromHotel {
  /// Walking distance (< 1 km)
  walking,

  /// Short trip (1-5 km)
  shortTrip,

  /// Medium trip (5-15 km)
  mediumTrip,

  /// Far (> 15 km)
  far,
}

/// Weather context for a recommendation
enum WeatherContext {
  /// Works well in any weather
  anyWeather,

  /// Indoor activity (good for bad weather)
  indoor,

  /// Best in good weather
  outdoor,

  /// Better in specific weather conditions
  weatherDependent,
}

/// Expected crowd level
enum CrowdLevel {
  /// Not crowded
  low,

  /// Moderate crowds
  medium,

  /// Expect crowds
  high,

  /// Very crowded
  peak,
}
