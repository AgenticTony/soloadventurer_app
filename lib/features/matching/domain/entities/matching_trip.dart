import 'package:equatable/equatable.dart';

/// MatchingTrip entity representing a user's travel plans for matching purposes
/// 
/// This is separate from the journal Trip entity to avoid conflicts.
/// The matching trip focuses on location and dates for finding travel companions.
class MatchingTrip extends Equatable {
  /// Unique identifier for the trip
  final String id;

  /// User ID who owns this trip
  final String userId;

  /// Human-readable destination name (e.g., "Paris, France")
  final String destinationName;

  /// Latitude of the destination
  final double latitude;

  /// Longitude of the destination
  final double longitude;

  /// Location precision level
  final LocationPrecision locationPrecision;

  /// Start date of the trip
  final DateTime startDate;

  /// End date of the trip
  final DateTime endDate;

  /// Whether the trip is currently active
  final bool isActive;

  /// When the trip was created
  final DateTime createdAt;

  /// When the trip was last updated
  final DateTime updatedAt;

  /// Creates a new [MatchingTrip] instance
  const MatchingTrip({
    required this.id,
    required this.userId,
    required this.destinationName,
    required this.latitude,
    required this.longitude,
    this.locationPrecision = LocationPrecision.city,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        destinationName,
        latitude,
        longitude,
        locationPrecision,
        startDate,
        endDate,
        isActive,
        createdAt,
        updatedAt,
      ];

  /// Creates a copy of this trip with the given fields replaced with new values
  MatchingTrip copyWith({
    String? id,
    String? userId,
    String? destinationName,
    double? latitude,
    double? longitude,
    LocationPrecision? locationPrecision,
    DateTime? startDate,
    DateTime? endDate,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MatchingTrip(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      destinationName: destinationName ?? this.destinationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationPrecision: locationPrecision ?? this.locationPrecision,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Duration of the trip in days
  int get durationInDays => endDate.difference(startDate).inDays + 1;

  /// Whether the trip is currently happening
  bool get isCurrentTrip {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    return (start.isBefore(today) || start.isAtSameMomentAs(today)) &&
        (end.isAfter(today) || end.isAtSameMomentAs(today));
  }

  /// Whether the trip is in the future
  bool get isFutureTrip {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final start = DateTime(startDate.year, startDate.month, startDate.day);
    return start.isAfter(today);
  }

  /// Whether the trip is in the past
  bool get isPastTrip {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final end = DateTime(endDate.year, endDate.month, endDate.day);
    return end.isBefore(today);
  }

  /// Creates an empty trip
  factory MatchingTrip.empty() {
    final now = DateTime.now();
    return MatchingTrip(
      id: '',
      userId: '',
      destinationName: '',
      latitude: 0.0,
      longitude: 0.0,
      startDate: now,
      endDate: now,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Whether this trip is empty
  bool get isEmpty => id.isEmpty;

  /// Whether this trip is not empty
  bool get isNotEmpty => !isEmpty;

  @override
  String toString() {
    return 'MatchingTrip{id: $id, destination: $destinationName, dates: $startDate to $endDate, active: $isActive}';
  }
}

/// Location precision levels for privacy control
enum LocationPrecision {
  /// City-level only (default)
  city,

  /// Neighborhood-level
  neighborhood,

  /// Exact location
  exact,
}
