import 'package:geolocator/geolocator.dart';
import '../core/errors/exceptions.dart' show LocationException;

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
    required this.timestamp,
    this.locationName,
  });

  /// Creates a [LocationData] from a [Position] object
  factory LocationData.fromPosition(Position position) {
    return LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      altitude: position.altitude,
      speed: position.speed,
      timestamp: position.timestamp,
    );
  }

  /// Creates a copy with updated fields
  LocationData copyWith({
    double? latitude,
    double? longitude,
    double? accuracy,
    double? altitude,
    double? speed,
    DateTime? timestamp,
    String? locationName,
  }) {
    return LocationData(
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      accuracy: accuracy ?? this.accuracy,
      altitude: altitude ?? this.altitude,
      speed: speed ?? this.speed,
      timestamp: timestamp ?? this.timestamp,
      locationName: locationName ?? this.locationName,
    );
  }

  /// Whether this location has acceptable accuracy
  bool hasAcceptableAccuracy({double maxAccuracy = 100}) {
    return accuracy <= maxAccuracy;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'latitude': latitude,
      'longitude': longitude,
      'accuracy': accuracy,
      'altitude': altitude,
      'speed': speed,
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
      timestamp: DateTime.parse(json['timestamp'] as String),
      locationName: json['locationName'] as String?,
    );
  }

  @override
  String toString() => 'LocationData(lat: $latitude, lng: $longitude, '
      'accuracy: ${accuracy.toStringAsFixed(1)}m, '
      'name: ${locationName ?? "N/A"})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is LocationData &&
          runtimeType == other.runtimeType &&
          latitude == other.latitude &&
          longitude == other.longitude;

  @override
  int get hashCode => latitude.hashCode ^ longitude.hashCode;
}

/// Configuration for location capture
class LocationCaptureConfig {
  /// Desired accuracy of the location fix
  final LocationAccuracy desiredAccuracy;

  /// Maximum age of cached location to accept (null = always get fresh location)
  final Duration? maxAge;

  /// Maximum time to wait for location fix
  final Duration timeLimit;

  /// Maximum distance in meters that location can move to trigger updates
  final double? distanceFilter;

  const LocationCaptureConfig({
    this.desiredAccuracy = LocationAccuracy.best,
    this.maxAge,
    this.timeLimit = const Duration(seconds: 10),
    this.distanceFilter,
  });

  /// Predefined configuration for travel journal entries
  static const forTravelJournal = LocationCaptureConfig(
    desiredAccuracy: LocationAccuracy.high,
    maxAge: Duration(minutes: 5),
    timeLimit: Duration(seconds: 15),
    distanceFilter: 10,
  );

  /// Predefined configuration for quick location capture
  static const quick = LocationCaptureConfig(
    desiredAccuracy: LocationAccuracy.medium,
    maxAge: Duration(minutes: 10),
    timeLimit: Duration(seconds: 5),
  );

  /// Predefined configuration for precise location
  static const precise = LocationCaptureConfig(
    desiredAccuracy: LocationAccuracy.best,
    maxAge: Duration(minutes: 1),
    timeLimit: Duration(seconds: 30),
  );
}

/// Service for capturing device location using geolocator
class LocationService {
  /// Singleton instance
  static LocationService? _instance;

  LocationService._();

  /// Get the singleton instance
  static LocationService get instance {
    _instance ??= LocationService._();
    return _instance!;
  }

  /// Check if location services are enabled
  Future<bool> isLocationServiceEnabled() async {
    try {
      return await Geolocator.isLocationServiceEnabled();
    } catch (e) {
      throw LocationException(message:
        'Failed to check location service status: ${e.toString()}',
      );
    }
  }

  /// Check location permission status
  Future<LocationPermission> checkPermission() async {
    try {
      return await Geolocator.checkPermission();
    } catch (e) {
      throw LocationException(message:
        'Failed to check location permission: ${e.toString()}',
      );
    }
  }

  /// Request location permission
  Future<LocationPermission> requestPermission() async {
    try {
      return await Geolocator.requestPermission();
    } catch (e) {
      throw LocationException(message:
        'Failed to request location permission: ${e.toString()}',
      );
    }
  }

  /// Ensure location permissions are granted and service is enabled
  /// Throws [LocationException] if permissions are denied or service is disabled
  Future<void> ensureLocationEnabled() async {
    // Check if location service is enabled
    final isEnabled = await isLocationServiceEnabled();
    if (!isEnabled) {
      throw const LocationException(
        message: 'Location services are disabled. Please enable them in settings.',
      );
    }

    // Check permission
    var permission = await checkPermission();
    if (permission == LocationPermission.denied) {
      // Request permission
      permission = await requestPermission();
      if (permission == LocationPermission.denied) {
        throw const LocationException(
          message: 'Location permissions are denied. Please grant permission in settings.',
        );
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw const LocationException(
        message: 'Location permissions are permanently denied. Please enable them in app settings.',
      );
    }
  }

  /// Get the current device location
  ///
  /// [config] - Configuration for location capture
  /// Returns [LocationData] with the captured location
  /// Throws [LocationException] if location cannot be determined
  Future<LocationData> getCurrentLocation([
    LocationCaptureConfig config = const LocationCaptureConfig(),
  ]) async {
    // Ensure permissions and service are enabled
    await ensureLocationEnabled();

    try {
      // Get current position
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: config.desiredAccuracy,
        timeLimit: config.timeLimit,
      );

      // Check if position is within max age
      final maxAge = config.maxAge;
      if (maxAge != null) {
        final age = DateTime.now().difference(position.timestamp);
        if (age > maxAge) {
          // Position is too old, get fresh location
          final freshPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: config.desiredAccuracy,
            timeLimit: config.timeLimit,
          );
          return LocationData.fromPosition(freshPosition);
        }
      }

      return LocationData.fromPosition(position);
    } on LocationException {
      rethrow;
    } catch (e) {
      throw LocationException(message:
        'Failed to get current location: ${e.toString()}',
      );
    }
  }

  /// Get the last known position (cached, faster but may be outdated)
  ///
  /// Returns [LocationData] if last position is available, null otherwise
  Future<LocationData?> getLastKnownLocation() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position == null) {
        return null;
      }
      return LocationData.fromPosition(position);
    } catch (e) {
      throw LocationException(message:
        'Failed to get last known location: ${e.toString()}',
      );
    }
  }

  /// Calculate distance between two coordinates in meters
  double distanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  /// Calculate distance between two location data objects in meters
  double distanceBetweenLocations(LocationData from, LocationData to) {
    return distanceBetween(
      from.latitude,
      from.longitude,
      to.latitude,
      to.longitude,
    );
  }

  /// Get location updates stream
  ///
  /// [config] - Configuration for location updates
  /// Returns a [Stream<LocationData>] that emits location updates
  Stream<LocationData> getLocationUpdates([
    LocationCaptureConfig config = const LocationCaptureConfig(),
  ]) {
    return Geolocator.getPositionStream(
      locationSettings: LocationSettings(
        accuracy: config.desiredAccuracy,
        distanceFilter: config.distanceFilter == null
            ? 100
            : config.distanceFilter!.toInt(),
        timeLimit: config.timeLimit,
      ),
    ).map((position) => LocationData.fromPosition(position));
  }

  /// Open app settings (useful when permission is denied forever)
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }

  /// Open location settings (useful when location service is disabled)
  Future<bool> openLocationSettings() async {
    return await Geolocator.openLocationSettings();
  }
}
