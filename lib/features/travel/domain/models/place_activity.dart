import 'package:freezed_annotation/freezed_annotation.dart';

part 'place_activity.freezed.dart';
part 'place_activity.g.dart';

/// An activity or attraction that can be added to an itinerary
///
/// Represents a place/activity that can be suggested to users
/// based on their interests, location, and weather conditions.
@freezed
class PlaceActivity with _$PlaceActivity {

  /// Creates a place activity
  ///
  /// The [id] parameter is a unique identifier (e.g., Google Place ID).
  /// The [name] parameter is the name of the place/activity.
  /// The [description] parameter describes the activity.
  /// The [category] parameter is the type of activity (e.g., 'museum', 'restaurant').
  /// The [address] parameter is the location address.
  /// The [latitude] and [longitude] parameters are coordinates.
  /// The [rating] parameter is the average rating (0-5).
  /// The [reviewCount] parameter is the number of reviews.
  /// The [isIndoor] parameter indicates if this is an indoor activity.
  /// The [estimatedDuration] parameter is typical visit duration.
  /// The [recommendedTime] parameter is the best time to visit (optional).
  /// The [cost] parameter is the estimated cost (optional).
  /// The [bookingUrl] parameter is a URL for booking (optional).
  /// The [photoUrl] parameter is a URL for a photo (optional).
  const factory PlaceActivity({
    required String id,
    required String name,
    required String description,
    required String category,
    String? address,
    double? latitude,
    double? longitude,
    @Default(0.0) double rating,
    @Default(0) int reviewCount,
    @Default(false) bool isIndoor,
    int? estimatedDuration, // in minutes
    String? recommendedTime,
    double? cost,
    String? bookingUrl,
    String? photoUrl,
  }) = _PlaceActivity;

  /// Creates a PlaceActivity from JSON
  factory PlaceActivity.fromJson(Map<String, dynamic> json) =>
      _$PlaceActivityFromJson(json);

  /// Returns true if this is a highly-rated activity
  bool get isHighlyRated => rating >= 4.0;

  /// Returns true if this is a popular activity
  bool get isPopular => reviewCount >= 100;

  /// Returns a formatted rating string
  String get formattedRating => '${rating.toStringAsFixed(1)} ⭐';

  /// Returns the cost as a formatted string
  String? get formattedCost {
    if (cost == null) return null;
    if (cost == 0) return 'Free';
    return '\$${cost!.toStringAsFixed(2)}';
  }

  // Private constructor for freezed getters
  const PlaceActivity._();
}

/// Travel interest category
///
/// Defines the types of activities a user is interested in.
enum TravelInterest {
  art('Art & Culture'),
  food('Food & Cuisine'),
  history('Historical Sites'),
  nature('Nature & Outdoors'),
  adventure('Adventure & Sports'),
  relaxation('Relaxation & Wellness'),
  shopping('Shopping'),
  nightlife('Nightlife & Entertainment'),
  music('Music & Concerts'),
  architecture('Architecture');

  final String label;
  const TravelInterest(this.label);
}

/// Peak hours information for a place
///
/// Contains information about when a place is busiest.
@freezed
class PeakHours with _$PeakHours {
  const factory PeakHours({
    required List<int> hours, // Hours that are peak (0-23)
    required String dayOfWeek, // Day this applies to (or 'daily')
    int? currentHour, // Current hour for comparison
  }) = _PeakHours;

  /// Empty peak hours (no data available)
  static const empty = PeakHours(hours: [], dayOfWeek: 'daily');

  /// Returns true if the given hour is a peak hour
  bool isPeakHour(int hour) => hours.contains(hour);
}
