/// Location accuracy levels for location requests
enum LocationAccuracy {
  /// Low accuracy (~3000m) - uses cell towers
  low,

  /// Balanced accuracy (~100m) - uses cell towers + WiFi
  balanced,

  /// High accuracy (~10m) - uses GPS
  high,

  /// Best accuracy available (~0m) - uses GPS + other sensors
  best,
}

/// Location permission status
enum LocationPermissionStatus {
  /// Permission has been granted
  granted,

  /// Permission has been denied
  denied,

  /// Permission has been permanently denied (user selected "Don't ask again")
  permanentlyDenied,
}

/// Result of a location capture operation
class LocationData {
  /// Latitude coordinate
  final double latitude;

  /// Longitude coordinate
  final double longitude;

  /// Accuracy of the location fix in meters
  final double accuracy;

  /// Altitude in meters (null if not available)
  final double? altitude;

  /// Speed in meters per second (null if not available)
  final double? speed;

  /// Heading in degrees (null if not available)
  final double? heading;

  /// Timestamp when location was captured
  final DateTime timestamp;

  /// Human-readable location name (optional, requires geocoding)
  final String? locationName;

  const LocationData({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.altitude,
    this.speed,
    this.heading,
    required this.timestamp,
    this.locationName,
  });

  /// Creates a copy with updated fields
  LocationData copyWith({
    double? latitude,
    double? longitude,
    double? accuracy,
    double? altitude,
    double? speed,
    double? heading,
    DateTime? timestamp,
    String? locationName,
  }) {
    return LocationData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      heading: heading ?? this.heading,
      timestamp: timestamp ?? this.timestamp,
      locationName: locationName ?? this.locationName,
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
      'heading': heading,
      'timestamp': timestamp.toIso8601String(),
      'locationName': locationName,
    };
  }

  /// Create from JSON
  factory LocationData.fromJson(Map<String, dynamic> json) {
    return LocationData(
      latitude: json['latitude'] as double,
      longitude: json['longitude'] as double,
      accuracy: json['accuracy'] as double,
      altitude: json['altitude'] as double?,
      speed: json['speed'] as double?,
      heading: json['heading'] as double?,
      timestamp: DateTime.parse(json['timestamp'] as String),
      locationName: json['locationName'] as String?,
    );
  }

  @override
  String toString() {
    return 'LocationData(lat: $latitude, lng: $longitude, accuracy: ${accuracy}m'
        '${locationName != null ? ', name: $locationName' : ''})';
  }
}

/// Abstract interface for location services
///
/// Defines the contract for location-related operations including
/// getting current location, tracking, and permission management.
abstract class LocationService {
  /// Stream of location updates
  Stream<LocationData> get onLocationChanged;

  /// Whether location tracking is currently active
  bool get isTrackingLocation;

  /// Get the current device location
  ///
  /// [accuracy] - Desired accuracy level (defaults to balanced)
  Future<LocationData> getCurrentLocation({
    LocationAccuracy accuracy = LocationAccuracy.balanced,
  });

  /// Get the last known location (cached, may be outdated)
  Future<LocationData?> getLastKnownLocation();

  /// Start continuous location updates
  ///
  /// [accuracy] - Desired accuracy level
  /// [distanceFilter] - Minimum distance between updates in meters
  Future<void> startLocationUpdates({
    LocationAccuracy accuracy = LocationAccuracy.balanced,
    int distanceFilter = 10,
  });

  /// Stop continuous location updates
  Future<void> stopLocationUpdates();

  /// Check if location services are enabled on the device
  Future<bool> isLocationServiceEnabled();

  /// Check the current location permission status
  Future<LocationPermissionStatus> checkPermission();

  /// Request location permission from the user
  Future<LocationPermissionStatus> requestPermission();

  /// Calculate distance between two coordinates in meters
  double distanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  );

  /// Dispose of resources
  void dispose();
}
