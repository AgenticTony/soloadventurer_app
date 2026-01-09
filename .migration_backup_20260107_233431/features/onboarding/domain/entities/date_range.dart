import 'package:freezed_annotation/freezed_annotation.dart';

part 'date_range.freezed.dart';
part 'date_range.g.dart';

/// Represents a date range for travel
///
/// Used in onboarding to specify when the user plans to travel.
/// Includes validation logic to ensure the end date is after the start date.
@freezed
abstract class DateRange with _$DateRange {
  const DateRange._();

  /// Creates a DateRange with start and end dates
  ///
  /// [start] The first day of the trip (inclusive)
  /// [end] The last day of the trip (inclusive)
  const factory DateRange({
    required DateTime start,
    required DateTime end,
  }) = _DateRange;

  /// Creates a DateRange from JSON
  factory DateRange.fromJson(Map<String, dynamic> json) =>
      _$DateRangeFromJson(json);

  /// Calculates the duration of the trip in days
  ///
  /// Returns the number of days between start and end, inclusive.
  /// For example, if start is May 11 and end is May 11, returns 1.
  /// If start is May 11 and end is May 18, returns 8.
  Duration get duration => end.difference(start);

  /// Returns the number of days in the trip (inclusive)
  ///
  /// Adds 1 to the duration in days to include both start and end dates.
  int get numberOfDays => duration.inDays + 1;

  /// Validates that the date range is logical
  ///
  /// Returns true if:
  /// - Start date is before or equal to end date
  /// - Start date is in the future (or today)
  bool get isValid {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final startDate = DateTime(start.year, start.month, start.day);

    return start.isBefore(end) && startDate.isAtSameMomentAs(today) || startDate.isAfter(today);
  }

  /// Returns a formatted string representation
  ///
  /// Example: "May 11 - May 18, 2026"
  String get formatted {
    final formatter = '${start.month}/${start.day}/${start.year}';
    final formatterEnd = '${end.month}/${end.day}/${end.year}';
    return '$formatter - $formatterEnd';
  }
}
