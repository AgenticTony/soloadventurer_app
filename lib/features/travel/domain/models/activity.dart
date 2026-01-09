import 'package:freezed_annotation/freezed_annotation.dart';

part 'activity.freezed.dart';
part 'activity.g.dart';

/// Category of travel activity
enum ActivityCategory {
  /// Dining and food-related activities
  food,

  /// Transportation and travel between locations
  transport,

  /// Accommodation and lodging
  accommodation,

  /// Entertainment and recreational activities
  activity,

  /// Sightseeing and tourist attractions
  sightseeing,

  /// Shopping and markets
  shopping,

  /// Other activities
  other,
}

/// Activity model representing a planned or completed activity during a trip
///
/// Activities are individual events, tasks, or locations that are part of
/// a larger trip itinerary. Examples include restaurant reservations, museum
/// visits, transportation bookings, etc.
@freezed
class Activity with _$Activity {
  const factory Activity({
    /// Unique identifier for the activity
    required String id,

    /// ID of the trip this activity belongs to
    required String tripId,

    /// ID of the user who created this activity
    required String userId,

    /// Activity title or name
    required String title,

    /// Detailed description of the activity
    String? description,

    /// Category of the activity
    required ActivityCategory category,

    /// Location name (e.g., restaurant name, museum name)
    String? locationName,

    /// Physical address
    String? address,

    /// Latitude coordinate
    double? latitude,

    /// Longitude coordinate
    double? longitude,

    /// Scheduled start date and time
    DateTime? startDateTime,

    /// Scheduled end date and time
    DateTime? endDateTime,

    /// Estimated cost for this activity
    double? estimatedCost,

    /// Actual cost (if completed)
    double? actualCost,

    /// Currency code for costs (e.g., USD, EUR)
    String? currency,

    /// Booking confirmation code or reference number
    String? confirmationNumber,

    /// Website URL related to this activity
    String? websiteUrl,

    /// Phone number for reservations
    String? phoneNumber,

    /// Activity notes or special instructions
    String? notes,

    /// Whether this activity is completed
    @Default(false) bool isCompleted,

    /// Whether this activity is a high priority
    @Default(false) isPriority,

    /// List of photo IDs associated with this activity
    List<String>? photoIds,

    /// Tags for organizing and filtering activities
    List<String>? tags,

    /// Date and time when the activity was created
    required DateTime createdAt,

    /// Date and time when the activity was last updated
    required DateTime updatedAt,
  }) = _Activity;

  factory Activity.fromJson(Map<String, dynamic> json) =>
      _$ActivityFromJson(json);

  const Activity._();

  /// Whether this activity has geographic coordinates
  bool get hasLocation => latitude != null && longitude != null;

  /// Whether this activity has scheduled time
  bool get hasScheduledTime => startDateTime != null;

  /// Whether this activity has cost information
  bool get hasCostInfo => estimatedCost != null || actualCost != null;

  /// Duration of the activity (if both start and end times are set)
  Duration? get duration {
    if (startDateTime == null || endDateTime == null) return null;
    return endDateTime!.difference(startDateTime!);
  }
}
