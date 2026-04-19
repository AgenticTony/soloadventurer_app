import 'package:geolocator/geolocator.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';

/// Result of a location capture operation
class LocationCaptureResult {
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

  const LocationCaptureResult({
    required this.latitude,
    required this.longitude,
    required this.accuracy,
    this.altitude,
    this.speed,
    required this.timestamp,
    this.locationName,
  });

  /// Creates a [LocationCaptureResult] from a [Position] object
  factory LocationCaptureResult.fromPosition(Position position) {
    return LocationCaptureResult(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      altitude: position.altitude,
      speed: position.speed,
      timestamp: position.timestamp,
    );
  }

  /// Whether this location has acceptable accuracy
  bool hasAcceptableAccuracy({double maxAccuracy = 100}) {
    return accuracy <= maxAccuracy;
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() => {
        'latitude': latitude,
        'longitude': longitude,
        'accuracy': accuracy,
        'altitude': altitude,
        'speed': speed,
        'timestamp': timestamp.toIso8601String(),
        'locationName': locationName,
      };
}

/// Configuration for location capture
class LocationCaptureConfig {
  /// Desired accuracy level
  final LocationAccuracy desiredAccuracy;

  /// Maximum age of cached location
  final Duration? maxAge;

  /// Timeout for location request
  final Duration? timeLimit;

  /// Distance filter for updates (meters)
  final double? distanceFilter;

  const LocationCaptureConfig({
    this.desiredAccuracy = LocationAccuracy.best,
    this.maxAge,
    this.timeLimit,
    this.distanceFilter,
  });

  /// Preset: travel journal (high accuracy, reasonable timeout)
  static const forTravelJournal = LocationCaptureConfig(
    desiredAccuracy: LocationAccuracy.high,
    timeLimit: Duration(seconds: 15),
    maxAge: Duration(minutes: 5),
  );

  /// Preset: quick check-in (lower accuracy, fast)
  static const forQuickCheckIn = LocationCaptureConfig(
    desiredAccuracy: LocationAccuracy.medium,
    timeLimit: Duration(seconds: 10),
  );

  /// Preset: precise location
  static const precise = LocationCaptureConfig(
    desiredAccuracy: LocationAccuracy.best,
    maxAge: Duration(minutes: 1),
    timeLimit: Duration(seconds: 30),
  );
}

/// Concrete location service for journal location capture
///
/// Wraps geolocator to provide a simple API for capturing locations
/// in the journal feature. Uses singleton pattern for convenience.
class LocationCaptureService {
  /// Singleton instance
  static LocationCaptureService? _instance;

  LocationCaptureService._();

  /// Get the singleton instance
  static LocationCaptureService get instance {
    _instance ??= LocationCaptureService._();
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
  Future<void> ensureLocationEnabled() async {
    final isEnabled = await isLocationServiceEnabled();
    if (!isEnabled) {
      throw const LocationException(
        message: 'Location services are disabled. Please enable them in settings.',
      );
    }

    var permission = await checkPermission();
    if (permission == LocationPermission.denied) {
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
  Future<LocationCaptureResult> getCurrentLocation([
    LocationCaptureConfig config = const LocationCaptureConfig(),
  ]) async {
    await ensureLocationEnabled();

    try {
      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: config.desiredAccuracy,
        timeLimit: config.timeLimit,
      );

      final maxAge = config.maxAge;
      if (maxAge != null) {
        final age = DateTime.now().difference(position.timestamp);
        if (age > maxAge) {
          final freshPosition = await Geolocator.getCurrentPosition(
            desiredAccuracy: config.desiredAccuracy,
            timeLimit: config.timeLimit,
          );
          return LocationCaptureResult.fromPosition(freshPosition);
        }
      }

      return LocationCaptureResult.fromPosition(position);
    } on LocationException {
      rethrow;
    } catch (e) {
      throw LocationException(message:
        'Failed to get current location: ${e.toString()}',
      );
    }
  }

  /// Get the last known position (cached, faster but may be outdated)
  Future<LocationCaptureResult?> getLastKnownLocation() async {
    try {
      final position = await Geolocator.getLastKnownPosition();
      if (position == null) return null;
      return LocationCaptureResult.fromPosition(position);
    } catch (e) {
      throw LocationException(message:
        'Failed to get last known location: ${e.toString()}',
      );
    }
  }

  /// Open app settings
  Future<bool> openAppSettings() async {
    return await Geolocator.openAppSettings();
  }
}
