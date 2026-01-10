import 'package:geolocator/geolocator.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';

/// Result of a geocoding search operation
class GeocodingResult {
  /// Human-readable location name
  final String name;

  /// Full address
  final String? fullAddress;

  /// Latitude coordinate
  final double latitude;

  /// Longitude coordinate
  final double longitude;

  /// Locality (city)
  final String? locality;

  /// Administrative area (state/province)
  final String? administrativeArea;

  /// Country
  final String? country;

  /// Postal code
  final String? postalCode;

  /// Street name and number
  final String? street;

  const GeocodingResult({
    required this.name,
    this.fullAddress,
    required this.latitude,
    required this.longitude,
    this.locality,
    this.administrativeArea,
    this.country,
    this.postalCode,
    this.street,
  });

  /// Creates a [GeocodingResult] from a [Placemark] and coordinates
  factory GeocodingResult.fromPlacemark(
    Placemark placemark,
    double latitude,
    double longitude,
  ) {
    // Build the full address
    final parts = <String>[
      if (placemark.street != null) placemark.street!,
      if (placemark.subLocality != null) placemark.subLocality!,
      if (placemark.locality != null) placemark.locality!,
      if (placemark.administrativeArea != null) placemark.administrativeArea!,
      if (placemark.postalCode != null) placemark.postalCode!,
      if (placemark.country != null) placemark.country!,
    ];

    final fullAddress = parts.isNotEmpty ? parts.join(', ') : null;

    // Determine the display name (prefer specific location over general)
    final name = placemark.name ??
        placemark.street ??
        placemark.locality ??
        placemark.administrativeArea ??
        placemark.country ??
        'Unknown Location';

    return GeocodingResult(
      name: name,
      fullAddress: fullAddress,
      latitude: latitude,
      longitude: longitude,
      locality: placemark.locality,
      administrativeArea: placemark.administrativeArea,
      country: placemark.country,
      postalCode: placemark.postalCode,
      street: placemark.street,
    );
  }

  /// Create a copy with updated fields
  GeocodingResult copyWith({
    String? name,
    String? fullAddress,
    double? latitude,
    double? longitude,
    String? locality,
    String? administrativeArea,
    String? country,
    String? postalCode,
    String? street,
  }) {
    return GeocodingResult(
      name: name ?? this.name,
      fullAddress: fullAddress ?? this.fullAddress,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locality: locality ?? this.locality,
      administrativeArea: administrativeArea ?? this.administrativeArea,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      street: street ?? this.street,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'fullAddress': fullAddress,
      'latitude': latitude,
      'longitude': longitude,
      'locality': locality,
      'administrativeArea': administrativeArea,
      'country': country,
      'postalCode': postalCode,
      'street': street,
    };
  }

  /// Create from JSON
  factory GeocodingResult.fromJson(Map<String, dynamic> json) {
    return GeocodingResult(
      name: json['name'] as String,
      fullAddress: json['fullAddress'] as String?,
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      locality: json['locality'] as String?,
      administrativeArea: json['administrativeArea'] as String?,
      country: json['country'] as String?,
      postalCode: json['postalCode'] as String?,
      street: json['street'] as String?,
    );
  }

  @override
  String toString() =>
      'GeocodingResult(name: $name, lat: $latitude, lng: $longitude)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GeocodingResult &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}

/// Service for geocoding operations (converting between addresses and coordinates)
class GeocodingService {
  /// Singleton instance
  static GeocodingService? _instance;

  GeocodingService._();

  /// Get the singleton instance
  static GeocodingService get instance {
    _instance ??= GeocodingService._();
    return _instance!;
  }

  /// Search for locations by address string
  ///
  /// [address] - The address to search for
  /// [limit] - Maximum number of results to return (default: 5)
  /// Returns a list of [GeocodingResult] matching the search query
  Future<List<GeocodingResult>> searchLocations(
    String address, {
    int limit = 5,
  }) async {
    if (address.trim().isEmpty) {
      return [];
    }

    try {
      // Use geolocator's locationFromAddress method
      final locations = await Geolocator.locationFromAddress(
        address,
      );

      if (locations.isEmpty) {
        return [];
      }

      // Now get placemarks for each location
      final results = <GeocodingResult>[];

      for (final location in locations.take(limit)) {
        try {
          final placemarks = await Geolocator.placemarkFromCoordinates(
            location.latitude,
            location.longitude,
          );

          if (placemarks.isNotEmpty) {
            results.add(GeocodingResult.fromPlacemark(
              placemarks.first,
              location.latitude,
              location.longitude,
            ));
          } else {
            // Fallback: create result without placemark
            results.add(GeocodingResult(
              name: address,
              latitude: location.latitude,
              longitude: location.longitude,
            ));
          }
        } catch (e) {
          // If reverse geocoding fails, create basic result
          results.add(GeocodingResult(
            name: address,
            latitude: location.latitude,
            longitude: location.longitude,
          ));
        }
      }

      return results;
    } catch (e) {
      throw const GeocodingException(
        'Failed to search for locations. Please check your connection and try again.',
      );
    }
  }

  /// Get address from coordinates (reverse geocoding)
  ///
  /// [latitude] - Latitude coordinate
  /// [longitude] - Longitude coordinate
  /// Returns a [GeocodingResult] with address information
  Future<GeocodingResult?> getAddressFromCoordinates(
    double latitude,
    double longitude,
  ) async {
    try {
      final placemarks = await Geolocator.placemarkFromCoordinates(
        latitude,
        longitude,
      );

      if (placemarks.isEmpty) {
        return null;
      }

      return GeocodingResult.fromPlacemark(
        placemarks.first,
        latitude,
        longitude,
      );
    } catch (e) {
      throw const GeocodingException(
        'Failed to get address from coordinates. Please try again.',
      );
    }
  }

  /// Get address from a position object
  ///
  /// [position] - The position object
  /// Returns a [GeocodingResult] with address information
  Future<GeocodingResult?> getAddressFromPosition(Position position) async {
    return getAddressFromCoordinates(
      position.latitude,
      position.longitude,
    );
  }
}
