import 'package:soloadventurer/features/matching/domain/entities/matching_trip.dart';

/// Data layer representation of [MatchingTrip] entity
class TripModel extends MatchingTrip {
  /// Creates a new [TripModel] instance
  const TripModel({
    required super.id,
    required super.userId,
    required super.destinationName,
    required super.latitude,
    required super.longitude,
    super.locationPrecision,
    required super.startDate,
    required super.endDate,
    super.isActive,
    required super.createdAt,
    required super.updatedAt,
  });

  /// Creates a [TripModel] from JSON map (Supabase format)
  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      destinationName: json['destination_name'] as String,
      latitude: (json['location'] as Map<String, dynamic>)['coordinates'][1] as double,
      longitude: (json['location'] as Map<String, dynamic>)['coordinates'][0] as double,
      locationPrecision: _parseLocationPrecision(json['location_precision'] as String?),
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: DateTime.parse(json['end_date'] as String),
      isActive: json['is_active'] as bool? ?? true,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts this [TripModel] to JSON map (Supabase format)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'destination_name': destinationName,
      'location': {
        'type': 'Point',
        'coordinates': [longitude, latitude],
      },
      'location_precision': locationPrecision.name,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'is_active': isActive,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates a [TripModel] from a [MatchingTrip] entity
  factory TripModel.fromEntity(MatchingTrip trip) {
    return TripModel(
      id: trip.id,
      userId: trip.userId,
      destinationName: trip.destinationName,
      latitude: trip.latitude,
      longitude: trip.longitude,
      locationPrecision: trip.locationPrecision,
      startDate: trip.startDate,
      endDate: trip.endDate,
      isActive: trip.isActive,
      createdAt: trip.createdAt,
      updatedAt: trip.updatedAt,
    );
  }

  /// Converts to a map for local database storage (Drift)
  Map<String, dynamic> toLocalDbMap() {
    return {
      'id': id,
      'user_id': userId,
      'destination_name': destinationName,
      'latitude': latitude,
      'longitude': longitude,
      'location_precision': locationPrecision.name,
      'start_date': startDate.toIso8601String().split('T')[0],
      'end_date': endDate.toIso8601String().split('T')[0],
      'is_active': isActive ? 1 : 0,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates a [TripModel] from local database map (Drift)
  factory TripModel.fromLocalDbMap(Map<String, dynamic> map) {
    return TripModel(
      id: map['id'] as String,
      userId: map['user_id'] as String,
      destinationName: map['destination_name'] as String,
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      locationPrecision: _parseLocationPrecision(map['location_precision'] as String?),
      startDate: DateTime.parse(map['start_date'] as String),
      endDate: DateTime.parse(map['end_date'] as String),
      isActive: (map['is_active'] as int) == 1,
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Helper to parse location precision from string
  static LocationPrecision _parseLocationPrecision(String? value) {
    switch (value?.toLowerCase()) {
      case 'neighborhood':
        return LocationPrecision.neighborhood;
      case 'exact':
        return LocationPrecision.exact;
      case 'city':
      default:
        return LocationPrecision.city;
    }
  }
}
