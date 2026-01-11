import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:latlong2/latlong.dart';

part 'destination.freezed.dart';
part 'destination.g.dart';

/// Represents a travel destination selected during onboarding
///
/// Contains information from Google Places API including location data,
/// place details, and metadata needed for itinerary generation.
@freezed
abstract class Destination with _$Destination {
  /// Creates a Destination with all required fields
  ///
  /// [placeId] Unique Google Places identifier
  /// [name] Name of the destination (e.g., "Paris, France")
  /// [description] Optional description of the destination
  /// [latitude] Geographic latitude coordinate (must be between -90 and 90)
  /// [longitude] Geographic longitude coordinate (must be between -180 and 180)
  /// [airportCode] IATA airport code (e.g., "CDG" for Paris)
  /// [country] Country name
  /// [city] City name
  /// [imageUrl] Optional URL to a representative image
  const factory Destination({
    required String placeId,
    required String name,
    String? description,
    required double latitude,
    required double longitude,
    String? airportCode,
    String? country,
    String? city,
    String? imageUrl,
  }) = _Destination;

  /// Creates a Destination from JSON
  factory Destination.fromJson(Map<String, dynamic> json) =>
      _$DestinationFromJson(json);

  /// Returns the geographic coordinates as a LatLng object
  ///
  /// Useful for mapping integration with google_maps_flutter or flutter_map.
  LatLng get coordinates => LatLng(latitude, longitude);

  /// Returns a formatted location string
  ///
  /// Examples:
  /// - "Paris, France" (if city and country are available)
  /// - "Paris" (if only city is available)
  /// - "France" (if only country is available)
  /// - name (fallback to the name field)
  String get formattedLocation {
    if (city != null && country != null) {
      return '$city, $country';
    } else if (city != null) {
      return city!;
    } else if (country != null) {
      return country!;
    }
    return name;
  }

  /// Validates that the destination has essential data
  ///
  /// Returns true if:
  /// - placeId is not empty
  /// - name is not empty
  /// - latitude is valid (between -90 and 90)
  /// - longitude is valid (between -180 and 180)
  bool get isValid {
    return placeId.isNotEmpty &&
        name.isNotEmpty &&
        latitude >= -90 &&
        latitude <= 90 &&
        longitude >= -180 &&
        longitude <= 180;
  }

  // Private constructor for freezed getters
  const Destination._();
}
