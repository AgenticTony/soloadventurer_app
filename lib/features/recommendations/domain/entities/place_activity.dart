import 'package:freezed_annotation/freezed_annotation.dart';

part 'place_activity.freezed.dart';
part 'place_activity.g.dart';

/// A place or activity that can be recommended to travelers
///
/// Represents attractions, restaurants, activities, or experiences
/// at a destination. Contains rich metadata for personalization.
@freezed
class PlaceActivity with _$PlaceActivity {
  const PlaceActivity._();

  /// Creates a place activity with all details
  ///
  /// [id] Unique identifier for this place
  /// [name] Name of the place/activity
  /// [category] Type of place (attraction, restaurant, activity, etc.)
  /// [description] Detailed description
  /// [location] Address/location text
  /// [latitude] Latitude coordinate
  /// [longitude] Longitude coordinate
  /// [rating] Average user rating (0-5)
  /// [reviewCount] Number of reviews
  /// [priceLevel] Price tier ($, $$, $$$, $$$$)
  /// [cost] Estimated cost in local currency
  /// [estimatedDuration] How long to spend here
  /// [images] URLs to photos
  /// [tags] Descriptive tags (solo_friendly, indoor, outdoor, etc.)
  /// [localTips] Tips from locals
  /// [bookingUrl] URL for advance booking
  /// [requiresBooking] Whether advance booking is required
  /// [openingHours] Operating hours
  const factory PlaceActivity({
    required String id,
    required String name,
    required RecommendationCategory category,
    String? description,
    String? location,
    double? latitude,
    double? longitude,
    @Default(0.0) double rating,
    @Default(0) int reviewCount,
    String? priceLevel,
    double? cost,
    Duration? estimatedDuration,
    @Default(<String>[]) List<String> images,
    @Default(<String>[]) List<String> tags,
    @Default(<String>[]) List<String> localTips,
    String? bookingUrl,
    @Default(false) bool requiresBooking,
    String? openingHours,
  }) = _PlaceActivity;

  /// Creates a PlaceActivity from JSON
  factory PlaceActivity.fromJson(Map<String, dynamic> json) =>
      _$PlaceActivityFromJson(json);

  /// Returns true if this is an indoor activity
  bool get isIndoor =>
      tags.contains('indoor') ||
      category == RecommendationCategory.culture ||
      category == RecommendationCategory.entertainment;

  /// Returns true if this is an outdoor activity
  bool get isOutdoor =>
      tags.contains('outdoor') || category == RecommendationCategory.adventure;

  /// Returns true if this is a major tourist attraction
  bool get isMajorTouristAttraction => rating >= 4.5 && reviewCount > 1000;

  /// Checks if this place is open during the given date range
  ///
  /// This is a simplified check - in production, would use actual opening hours
  bool isOpenDuring(DateTimeRange dateRange) {
    // If no opening hours specified, assume always open
    if (openingHours == null) return true;

    // Basic check - in production would parse actual hours
    return true;
  }

  /// Returns a display-friendly category name
  String get categoryDisplayName {
    switch (category) {
      case RecommendationCategory.food:
        return 'Food & Dining';
      case RecommendationCategory.attraction:
        return 'Attraction';
      case RecommendationCategory.activity:
        return 'Activity';
      case RecommendationCategory.entertainment:
        return 'Entertainment';
      case RecommendationCategory.shopping:
        return 'Shopping';
      case RecommendationCategory.wellness:
        return 'Wellness';
      case RecommendationCategory.culture:
        return 'Culture';
      case RecommendationCategory.adventure:
        return 'Adventure';
    }
  }
}

/// Categories of places/activities for recommendations
enum RecommendationCategory {
  food,
  attraction,
  activity,
  entertainment,
  shopping,
  wellness,
  culture,
  adventure,
}

/// A simple date range for checking availability
class DateTimeRange {
  final DateTime start;
  final DateTime end;

  const DateTimeRange({required this.start, required this.end});

  Duration get duration => end.difference(start);
}
