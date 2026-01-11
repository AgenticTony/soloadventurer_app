import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/date_range.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/destination.dart';
import 'itinerary_item.dart';

part 'itinerary.freezed.dart';
part 'itinerary.g.dart';

/// A complete travel itinerary with daily activities and logistics
///
/// Contains all the planned activities, accommodations, and travel details
/// for a trip. Can be a starter itinerary generated during onboarding or
/// a customized itinerary created by the user.
@freezed
abstract class Itinerary with _$Itinerary {
  /// Creates a complete itinerary
  ///
  /// [id] Unique identifier for this itinerary
  /// [name] Human-readable name (e.g., "Paris Trip ")
  /// [destination] Travel destination details
  /// [dateRange] Travel dates
  /// [items] List of all itinerary items across all days
  /// [isStarter] True if this is an auto-generated starter itinerary from onboarding
  /// [createdAt] When this itinerary was created
  /// [updatedAt] When this itinerary was last modified
  /// [userId] Optional user ID who owns this itinerary
  /// [coverImageUrl] Optional cover image URL
  const factory Itinerary({
    required String id,
    required String name,
    required Destination destination,
    required DateRange dateRange,
    required List<ItineraryItem> items,
    @Default(false) bool isStarter,
    required DateTime createdAt,
    DateTime? updatedAt,
    String? userId,
    String? coverImageUrl,
  }) = _Itinerary;

  /// Creates an Itinerary from JSON
  factory Itinerary.fromJson(Map<String, dynamic> json) =>
      _$ItineraryFromJson(json);

  /// Returns the number of days in the itinerary
  int get numberOfDays => dateRange.numberOfDays;

  /// Groups items by day
  ///
  /// Returns a map where keys are day numbers (-indexed) and values
  /// are lists of items for that day.
  Map<int, List<ItineraryItem>> get itemsByDay {
    final Map<int, List<ItineraryItem>> grouped = {};

    for (final item in items) {
      final dayNumber = _getDayNumber(item.time);
      grouped.putIfAbsent(dayNumber, () => []).add(item);
    }

    // Sort items within each day by time
    for (final dayItems in grouped.values) {
      dayItems.sort((a, b) => a.time.compareTo(b.time));
    }

    return grouped;
  }

  /// Returns items for a specific day (-indexed)
  List<ItineraryItem> getItemsForDay(int day) {
    return itemsByDay[day] ?? [];
  }

  /// Returns the day number (1-indexed) for a given datetime
  int _getDayNumber(DateTime dateTime) {
    final dayDiff = dateTime.difference(dateRange.start).inDays;
    return dayDiff + 1;
  }

  /// Returns a summary string for display
  ///
  /// Example: "Paris Trip - May 1-5, 2024 (5 days, 12 activities)"
  String get summary {
    final itemCount = items.length;
    final days = numberOfDays;
    return '$name - ${dateRange.formatted} ($days days, $itemCount activities)';
  }

  /// Validates that the itinerary has essential data
  ///
  /// Returns true if:
  /// - id is not empty
  /// - name is not empty
  /// - destination is valid
  /// - dateRange is valid
  /// - at least one item is planned
  bool get isValid {
    return id.isNotEmpty &&
        name.isNotEmpty &&
        destination.isValid &&
        dateRange.isValid &&
        items.isNotEmpty;
  }

  /// Returns completion percentage for the itinerary
  ///
  /// Calculates what percentage of items are marked as completed.
  double get completionPercentage {
    if (items.isEmpty) return 0.0;
    final completedCount = items.where((item) => item.isCompleted).length;
    return completedCount / items.length;
  }

  /// Returns the number of completed items
  int get completedItemsCount {
    return items.where((item) => item.isCompleted).length;
  }

  /// Returns the total number of items
  int get itemsCount {
    return items.length;
  }

  /// Returns true if all items are completed
  bool get isComplete {
    if (items.isEmpty) return false;
    return items.every((item) => item.isCompleted);
  }

  // Private constructor for freezed getters
  const Itinerary._();
}
