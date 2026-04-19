import 'dart:async';
import 'package:geolocator/geolocator.dart' as geo
    show
        Geolocator,
        LocationAccuracy,
        LocationPermission,
        LocationSettings,
        Position;
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'location_service.dart'
    show
        LocationAccuracy,
        LocationData,
        LocationPermissionStatus,
        LocationService;

part 'location_service_impl.g.dart';

/// Implementation of [LocationService] using geolocator
class LocationServiceImpl implements LocationService {
  final StreamController<LocationData> _locationController =
      StreamController<LocationData>.broadcast();

  bool _isTracking = false;
  StreamSubscription<geo.Position>? _positionSubscription;

  @override
  Stream<LocationData> get onLocationChanged => _locationController.stream;

  @override
  bool get isTrackingLocation => _isTracking;

  @override
  Future<LocationData> getCurrentLocation({
    LocationAccuracy accuracy = LocationAccuracy.balanced,
  }) async {
    // Check if location services are enabled
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceException(
        'Location services are disabled. Please enable them in settings.',
      );
    }

    // Check permissions
    final permission = await checkPermission();
    if (permission == LocationPermissionStatus.denied) {
      final requestedPermission = await requestPermission();
      if (requestedPermission != LocationPermissionStatus.granted) {
        throw LocationPermissionException(
          'Location permissions are denied. Please grant permission in settings.',
        );
      }
    } else if (permission == LocationPermissionStatus.permanentlyDenied) {
      throw LocationPermissionException(
        'Location permissions are permanently denied. Please enable them in app settings.',
      );
    }

    // Get location with desired accuracy
    final locationSettings = _getLocationSettings(accuracy);

    try {
      final position = await geo.Geolocator.getCurrentPosition(
        locationSettings: locationSettings,
      );

      return _convertPositionToLocationData(position);
    } catch (e) {
      throw LocationServiceException(
        'Failed to get current location: ${e.toString()}',
      );
    }
  }

  @override
  Future<LocationData?> getLastKnownLocation() async {
    try {
      final position = await geo.Geolocator.getLastKnownPosition();
      if (position == null) {
        return null;
      }
      return _convertPositionToLocationData(position);
    } catch (e) {
      // Return null if unable to get last known location
      return null;
    }
  }

  @override
  Future<void> startLocationUpdates({
    LocationAccuracy accuracy = LocationAccuracy.balanced,
    int distanceFilter = 10,
  }) async {
    if (_isTracking) {
      throw LocationServiceException(
        'Location updates are already active. Call stopLocationUpdates() first.',
      );
    }

    // Check if location services are enabled
    final serviceEnabled = await isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw LocationServiceException(
        'Location services are disabled. Please enable them in settings.',
      );
    }

    // Check permissions
    final permission = await checkPermission();
    if (permission == LocationPermissionStatus.denied) {
      final requestedPermission = await requestPermission();
      if (requestedPermission != LocationPermissionStatus.granted) {
        throw LocationPermissionException(
          'Location permissions are denied. Please grant permission in settings.',
        );
      }
    } else if (permission == LocationPermissionStatus.permanentlyDenied) {
      throw LocationPermissionException(
        'Location permissions are permanently denied. Please enable them in app settings.',
      );
    }

    // Configure location settings for battery efficiency
    final locationSettings = geo.LocationSettings(
      accuracy: _mapAccuracy(accuracy),
      distanceFilter: distanceFilter,
      timeLimit: const Duration(seconds: 30), // Timeout for getting location
    );

    // Start listening to position updates
    _positionSubscription = geo.Geolocator.getPositionStream(
      locationSettings: locationSettings,
    ).listen(
      (geo.Position position) {
        final locationData = _convertPositionToLocationData(position);
        _locationController.add(locationData);
      },
      onError: (error) {
        _locationController.addError(
          LocationServiceException(
              'Location update error: ${error.toString()}'),
        );
      },
    );

    _isTracking = true;
  }

  @override
  Future<void> stopLocationUpdates() async {
    await _positionSubscription?.cancel();
    _positionSubscription = null;
    _isTracking = false;
  }

  @override
  Future<bool> isLocationServiceEnabled() async {
    return await geo.Geolocator.isLocationServiceEnabled();
  }

  @override
  Future<LocationPermissionStatus> checkPermission() async {
    final permission = await geo.Geolocator.checkPermission();
    return _mapPermissionStatus(permission);
  }

  @override
  Future<LocationPermissionStatus> requestPermission() async {
    final permission = await geo.Geolocator.requestPermission();
    return _mapPermissionStatus(permission);
  }

  @override
  double distanceBetween(
    double startLatitude,
    double startLongitude,
    double endLatitude,
    double endLongitude,
  ) {
    return geo.Geolocator.distanceBetween(
      startLatitude,
      startLongitude,
      endLatitude,
      endLongitude,
    );
  }

  @override
  void dispose() {
    stopLocationUpdates();
    _locationController.close();
  }

  /// Maps our [LocationAccuracy] to geolocator's [LocationAccuracy]
  geo.LocationAccuracy _mapAccuracy(LocationAccuracy accuracy) {
    switch (accuracy) {
      case LocationAccuracy.low:
        return geo.LocationAccuracy.low;
      case LocationAccuracy.balanced:
        return geo.LocationAccuracy.medium;
      case LocationAccuracy.high:
        return geo.LocationAccuracy.high;
      case LocationAccuracy.best:
        return geo.LocationAccuracy.bestForNavigation;
    }
  }

  /// Creates location settings based on desired accuracy
  geo.LocationSettings _getLocationSettings(LocationAccuracy accuracy) {
    return geo.LocationSettings(
      accuracy: _mapAccuracy(accuracy),
      distanceFilter: 0, // Get exact location for single request
      timeLimit: const Duration(seconds: 30),
    );
  }

  /// Converts geolocator Position to our LocationData
  LocationData _convertPositionToLocationData(geo.Position position) {
    return LocationData(
      latitude: position.latitude,
      longitude: position.longitude,
      accuracy: position.accuracy,
      altitude: position.altitude,
      speed: position.speed,
      heading: position.heading,
      timestamp: position.timestamp,
    );
  }

  /// Maps geolocator permission status to our LocationPermissionStatus
  LocationPermissionStatus _mapPermissionStatus(
    geo.LocationPermission permission,
  ) {
    switch (permission) {
      case geo.LocationPermission.always:
      case geo.LocationPermission.whileInUse:
        return LocationPermissionStatus.granted;
      case geo.LocationPermission.denied:
        return LocationPermissionStatus.denied;
      case geo.LocationPermission.deniedForever:
        return LocationPermissionStatus.permanentlyDenied;
      case geo.LocationPermission.unableToDetermine:
        return LocationPermissionStatus.denied;
    }
  }
}

/// Exception thrown when location service operations fail
class LocationServiceException implements Exception {
  final String message;

  LocationServiceException(this.message);

  @override
  String toString() => 'LocationServiceException: $message';
}

/// Exception thrown when location permissions are not granted
class LocationPermissionException implements Exception {
  final String message;

  LocationPermissionException(this.message);

  @override
  String toString() => 'LocationPermissionException: $message';
}

/// Provider for LocationServiceImpl
@riverpod
LocationService locationServiceImpl(Ref ref) {
  final service = LocationServiceImpl();

  // Dispose the service when the provider is disposed
  ref.onDispose(() => service.dispose());

  return service;
}

/// Provider override for LocationService interface
@riverpod
LocationService locationServiceOverride(Ref ref) {
  return ref.watch(locationServiceImplProvider);
}
