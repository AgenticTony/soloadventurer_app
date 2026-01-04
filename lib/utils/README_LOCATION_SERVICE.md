# Location Service

A comprehensive location service for capturing device location using the geolocator package. Provides automatic location capture for journal entries with permission handling and configuration options.

## Features

- ✅ Automatic location capture with configurable accuracy
- ✅ Permission handling and service availability checks
- ✅ Multiple predefined configurations (quick, precise, forTravelJournal)
- ✅ Last known location retrieval (cached, faster)
- ✅ Real-time location updates via Stream
- ✅ Distance calculations between coordinates
- ✅ Settings integration for permission management
- ✅ Comprehensive error handling with custom exceptions
- ✅ Battery-conscious configuration options

## Installation

The required dependencies are already included in `pubspec.yaml`:

```yaml
dependencies:
  geolocator: ^13.0.2
```

### Platform Setup

#### Android

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />
```

For Android 10+ (API 29+), also add:

```xml
<uses-permission android:name="android.permission.ACCESS_BACKGROUND_LOCATION" />
```

#### iOS

Add to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location when open to tag journal entries.</string>
<key>NSLocationAlwaysAndWhenInUseUsageDescription</key>
<string>This app needs access to location to tag journal entries even when in background.</string>
```

## Usage

### Basic Usage

```dart
import 'package:soloadventurer/utils/location_service.dart';

// Get the service instance
final locationService = LocationService.instance;

try {
  // Get current location
  final location = await locationService.getCurrentLocation();

  print('Location: ${location.latitude}, ${location.longitude}');
  print('Accuracy: ${location.accuracy}m');
} on LocationException catch (e) {
  print('Location error: ${e.message}');
}
```

### With Configuration

```dart
// Quick capture (medium accuracy, cached location acceptable)
final quickLocation = await locationService.getCurrentLocation(
  LocationCaptureConfig.quick,
);

// Precise capture (best accuracy, fresh location)
final preciseLocation = await locationService.getCurrentLocation(
  LocationCaptureConfig.precise,
);

// Travel journal capture (balanced for travel journal use)
final journalLocation = await locationService.getCurrentLocation(
  LocationCaptureConfig.forTravelJournal,
);
```

### Custom Configuration

```dart
final customLocation = await locationService.getCurrentLocation(
  LocationCaptureConfig(
    desiredAccuracy: LocationAccuracy.high,
    maxAge: Duration(minutes: 5),
    timeLimit: Duration(seconds: 15),
    distanceFilter: 10,
  ),
);
```

### Permission Handling

```dart
// Check if location service is enabled
final isEnabled = await locationService.isLocationServiceEnabled();
if (!isEnabled) {
  // Prompt user to enable location services
  await locationService.openLocationSettings();
}

// Check permission status
final permission = await locationService.checkPermission();
if (permission == LocationPermission.denied) {
  // Request permission
  permission = await locationService.requestPermission();
}

if (permission == LocationPermission.deniedForever) {
  // Guide user to app settings
  await locationService.openAppSettings();
}
```

### Last Known Location

For faster results when high accuracy isn't critical:

```dart
final lastKnown = await locationService.getLastKnownLocation();
if (lastKnown != null) {
  print('Last known location: ${lastKnown.latitude}, ${lastKnown.longitude}');
  print('Timestamp: ${lastKnown.timestamp}');
} else {
  print('No last known location available');
}
```

### Real-time Location Updates

```dart
// Subscribe to location updates
final subscription = locationService
    .getLocationUpdates(LocationCaptureConfig.forTravelJournal)
    .listen((location) {
  print('Location update: ${location.latitude}, ${location.longitude}');
});

// Cancel subscription when done
await subscription.cancel();
```

### Distance Calculations

```dart
final locationService = LocationService.instance;

// Distance between coordinates
final distance = locationService.distanceBetween(
  37.7749, -122.4194, // San Francisco
  40.7128, -74.0060,  // New York
);
print('Distance: ${(distance / 1000).toStringAsFixed(2)} km');

// Distance between LocationData objects
final sf = LocationData(latitude: 37.7749, longitude: -122.4194, accuracy: 10, timestamp: DateTime.now());
final ny = LocationData(latitude: 40.7128, longitude: -74.0060, accuracy: 10, timestamp: DateTime.now());

final distance2 = locationService.distanceBetweenLocations(sf, ny);
```

### Integration with Journal Entry Creation

```dart
class JournalEntryCreationNotifier extends StateNotifier<...> {
  final LocationService _locationService = LocationService.instance;

  Future<void> captureCurrentLocation() async {
    try {
      state = state.copyWith(isCapturingLocation: true);

      // Get current location for journal entry
      final location = await _locationService.getCurrentLocation(
        LocationCaptureConfig.forTravelJournal,
      );

      // Update state with captured location
      state = state.copyWith(
        latitude: location.latitude,
        longitude: location.longitude,
        locationAccuracy: location.accuracy,
        isCapturingLocation: false,
      );
    } on LocationException catch (e) {
      state = state.copyWith(
        isCapturingLocation: false,
        error: 'Failed to capture location: ${e.message}',
      );
    }
  }

  Future<void> clearLocation() async {
    state = state.copyWith(
      latitude: null,
      longitude: null,
      locationAccuracy: null,
    );
  }
}
```

### UI Widget Example

```dart
class LocationCaptureButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creationState = ref.watch(journalEntryCreationProvider);

    return IconButton(
      icon: creationState.latitude != null
          ? Icon(Icons.location_on, color: Colors.green)
          : Icon(Icons.location_on_outlined),
      onPressed: () async {
        if (creationState.latitude != null) {
          // Clear location
          ref.read(journalEntryCreationProvider.notifier).clearLocation();
        } else {
          // Capture location
          await ref
              .read(journalEntryCreationProvider.notifier)
              .captureCurrentLocation();
        }
      },
      tooltip: creationState.latitude != null
          ? 'Remove location'
          : 'Add current location',
    );
  }
}
```

## API Reference

### LocationService

Singleton service for location operations.

#### Methods

- `Future<bool> isLocationServiceEnabled()` - Check if location services are enabled
- `Future<LocationPermission> checkPermission()` - Check location permission status
- `Future<LocationPermission> requestPermission()` - Request location permission
- `Future<void> ensureLocationEnabled()` - Ensure permissions granted and service enabled
- `Future<LocationData> getCurrentLocation([LocationCaptureConfig])` - Get current device location
- `Future<LocationData?> getLastKnownLocation()` - Get cached last known location
- `double distanceBetween(lat1, lng1, lat2, lng2)` - Calculate distance in meters
- `double distanceBetweenLocations(LocationData, LocationData)` - Calculate distance between locations
- `Stream<LocationData> getLocationUpdates([LocationCaptureConfig])` - Get location update stream
- `Future<bool> openAppSettings()` - Open app settings screen
- `Future<bool> openLocationSettings()` - Open device location settings

### LocationData

Data class representing captured location.

#### Properties

- `double latitude` - Latitude coordinate
- `double longitude` - Longitude coordinate
- `double accuracy` - Accuracy in meters
- `double? altitude` - Altitude in meters (optional)
- `double? speed` - Speed in m/s (optional)
- `DateTime timestamp` - When location was captured
- `String? locationName` - Human-readable name (optional, requires geocoding)

#### Methods

- `hasAcceptableAccuracy({double maxAccuracy})` - Check if location is accurate enough
- `copyWith(...)` - Create copy with updated fields
- `toJson()` / `fromJson()` - Serialization

### LocationCaptureConfig

Configuration for location capture.

#### Properties

- `LocationAccuracy desiredAccuracy` - Desired accuracy (best, high, medium, low, lowest)
- `Duration? maxAge` - Maximum age of cached location to accept
- `Duration timeLimit` - Maximum time to wait for location fix
- `double? distanceFilter` - Minimum distance to trigger updates
- `bool forceAndroidLocationManager` - Use Android location manager instead of Fused Location Provider

#### Predefined Configurations

- `LocationCaptureConfig.forTravelJournal` - Balanced for travel journal use (high accuracy, 5min cache)
- `LocationCaptureConfig.quick` - Fast capture with medium accuracy (10min cache)
- `LocationCaptureConfig.precise` - Highest accuracy (1min cache)

## Error Handling

The service throws `LocationException` for various error scenarios:

```dart
try {
  final location = await LocationService.instance.getCurrentLocation();
} on LocationException catch (e) {
  if (e.message.contains('disabled')) {
    // Location service is disabled
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Location Disabled'),
        content: Text('Please enable location services in settings.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              await LocationService.instance.openLocationSettings();
              Navigator.pop(context);
            },
            child: Text('Open Settings'),
          ),
        ],
      ),
    );
  } else if (e.message.contains('denied')) {
    // Permission denied
    showSnackBar('Location permission is required to tag journal entries.');
  } else {
    // Other error
    showSnackBar('Failed to get location: ${e.message}');
  }
}
```

## Best Practices

1. **Always handle permissions** - Check and request permissions before capturing location
2. **Use appropriate accuracy** - Higher accuracy uses more battery; use `forTravelJournal` for most cases
3. **Handle timeouts** - The service respects `timeLimit`; handle potential timeouts gracefully
4. **Consider cached location** - Use `getLastKnownLocation()` when speed is more important than accuracy
5. **Provide feedback** - Show loading indicators while capturing location
6. **Respect user privacy** - Always explain why location is needed and provide option to remove it
7. **Handle service disabled** - Guide users to settings when location service is disabled
8. **Clean up streams** - Always cancel location update streams when done

## Performance Considerations

- **Battery usage**: High accuracy location captures use more battery
- **Time**: `getCurrentLocation()` can take 5-30 seconds depending on conditions
- **Accuracy vs Speed**: Use cached locations (`maxAge`) when acceptable
- **Background updates**: Use `distanceFilter` to reduce update frequency

## Platform Limitations

### Android
- Background location requires additional permission (Android 10+)
- Some devices may not support high accuracy location
- Fused Location Provider is used by default (more accurate, less battery)

### iOS
- Background location usage requires "When in Use" or "Always" permission
- Significant location changes available even when app is suspended
- Accuracy may be reduced in background to preserve battery

## Troubleshooting

### Permission denied forever
- User must manually enable permission in app settings
- Use `openAppSettings()` to guide them

### Location service disabled
- User must enable location services in device settings
- Use `openLocationSettings()` to guide them

### Always returns null
- Ensure location permissions are granted
- Check if location service is enabled
- Try outdoors or near a window for better GPS signal

### Poor accuracy
- Increase `timeLimit` to allow more time for GPS fix
- Request higher `desiredAccuracy`
- Try again after moving to a location with better GPS signal

## Future Enhancements

- [ ] Add geocoding (coordinates → address) using geocoding package
- [ ] Add reverse geocoding for place names
- [ ] Add location name suggestions/autocomplete
- [ ] Support for picking location on a map
- [ ] Background location updates for trip tracking
- [ ] Location history and analytics

## Related Components

- **Journal Entry Creation** - Uses location data to tag entries
- **Location Picker Widget** - Manual location selection (future)
- **Media Items** - May capture location from EXIF data (Phase 4.3)

## Contributing

When adding location features:
1. Always handle permissions and service availability
2. Provide clear error messages to users
3. Respect user privacy and battery life
4. Follow existing error handling patterns
5. Update this README with new examples

## License

Part of the SoloAdventurer travel journal feature.
