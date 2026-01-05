import 'dart:typed_data';
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'location_service.g.dart';

/// Accuracy level for location tracking
enum LocationAccuracy {
  /// Lowest accuracy, lowest battery usage (~3km)
  low,

  /// Balanced accuracy and battery usage (~100m)
  balanced,

  /// High accuracy, moderate battery usage (~10m)
  high,

  /// Best possible accuracy, high battery usage (~0m)
  best,
}

/// Result of a location request
class LocationData {
  /// Latitude in degrees
  final double latitude;

  /// Longitude in degrees
  final double longitude;

  /// Accuracy of the location in meters
  final double? accuracy;

  /// Altitude in meters above sea level
  final double? altitude;

  /// Speed in meters per second
  final double? speed;

  /// Heading in degrees (0-360)
  final double? heading;

  /// Timestamp when location was recorded
  final DateTime timestamp;

  const LocationData({
    required this.latitude,
    required this.longitude,
    this.accuracy,
    this.altitude,
    this.speed,
    this.heading,
    required this.timestamp,
  });

  /// Creates LocationData from a map
  factory LocationData.fromMap(Map<String, dynamic> map) {
    return LocationData(
      latitude: map['latitude'] as double,
      longitude: map['longitude'] as double,
      accuracy: map['accuracy'] as double?,
      altitude: map['altitude'] as double?,
      speed: map['speed'] as double?,
      heading: map['heading'] as double?,
      timestamp: DateTime.fromMillisecondsSinceEpoch(
        map['timestamp'] as int? ?? DateTime.now().millisecondsSinceEpoch,
      ),
    );
  }

  /// Converts LocationData to a map
  Map<String, dynamic> toMap() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'heading': heading,
      'timestamp': timestamp.millisecondsSinceEpoch,
    };
  }

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lng: $longitude, accuracy: $accuracy)';
  }
}

/// Permission status for location services
enum LocationPermissionStatus {
  /// Permission is granted
  granted,

  /// Permission is denied
  denied,

  /// Permission is denied permanently (user selected "Don't ask again")
  permanentlyDenied,

  /// Permission is restricted (e.g., parental controls)
  restricted,
}

/// Abstract interface for location operations
abstract class LocationService {
  /// Stream of location updates
  Stream<LocationData> get onLocationChanged;

  /// Gets the current location once
  ///
  /// [accuracy] - The desired accuracy level (default: balanced)
  /// Returns the current location or throws an exception if unable to get location
  Future<LocationData> getCurrentLocation({
    LocationAccuracy accuracy = LocationAccuracy.balanced,
  });

  /// Gets the last known cached location (faster, may be outdated)
  ///
  /// Returns the last known location or null if no location is cached
  Future<LocationData?> getLastKnownLocation();

  /// Starts continuous location updates with specified accuracy
  ///
  /// [accuracy] - The desired accuracy level (default: balanced for battery efficiency)
  /// [distanceFilter] - Minimum distance between updates in meters (default: 10)
  /// Throws an exception if location updates are already active
  Future<void> startLocationUpdates({
    LocationAccuracy accuracy = LocationAccuracy.balanced,
    int distanceFilter = 10,
  });

  /// Stops continuous location updates
  Future<void> stopLocationUpdates();

  /// Checks if location updates are currently active
  bool get isTrackingLocation;

  /// Checks if location services are enabled on the device
  Future<bool> isLocationServiceEnabled();

  /// Checks the current location permission status
  Future<LocationPermissionStatus> checkPermission();

  /// Requests location permission
  ///
  /// Returns the permission status after requesting
  Future<LocationPermissionStatus> requestPermission();

  /// Calculates distance between two coordinates in meters
  double distanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  );

  /// Disposes any resources (closes streams, etc.)
  void dispose();
}

/// Provider for the location service implementation
@riverpod
LocationService locationService(LocationServiceRef ref) {
  throw UnimplementedError(
    'LocationService implementation not provided. '
    'Use locationServiceProvider from location_service_impl.dart',
  );
}
