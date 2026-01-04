# Location Picker Widget

A comprehensive Flutter widget for manually selecting or editing locations in journal entries with search, map integration, and current location support.

## Features

- ✅ **Search by name/address**: Type to search for any location worldwide
- ✅ **Interactive map preview**: See selected location on a Google Map
- ✅ **Current location button**: Quickly capture device GPS location
- ✅ **Edit mode**: Initialize with existing location data
- ✅ **Compact button variant**: Space-saving button with dialog picker
- ✅ **Automatic geocoding**: Convert addresses to coordinates and vice versa
- ✅ **Material Design 3**: Full theme integration with dark mode support
- ✅ **Comprehensive error handling**: User-friendly error messages
- ✅ **Provider integration**: Seamless integration with journal entry state

## Installation

The widget uses these dependencies (already in `pubspec.yaml`):

```yaml
dependencies:
  geolocator: ^13.0.2
  google_maps_flutter: ^2.6.0
  flutter_riverpod: ^2.5.1
```

Make sure to set up your Google Maps API key in `android/app/src/main/AndroidManifest.xml` and `ios/Runner/Info.plist`.

## Quick Start

### Basic Usage

```dart
import 'package:soloadventurer/features/journal/presentation/widgets/location_picker_widget.dart';

// In your widget tree
const LocationPickerWidget()
```

### With Initial Location (Edit Mode)

```dart
LocationPickerWidget(
  initialLocationName: 'Eiffel Tower, Paris',
  initialLatitude: 48.8584,
  initialLongitude: 2.2945,
)
```

### Compact Button Variant

```dart
LocationPickerButton(
  currentLocationName: 'Paris, France',
  label: 'Select Location',
)
```

## Widget Components

### LocationPickerWidget

The full-featured location picker widget.

#### Constructor

```dart
LocationPickerWidget({
  Key? key,
  String? initialLocationName,
  double? initialLatitude,
  double? initialLongitude,
  EdgeInsetsGeometry? padding,
})
```

#### Parameters

- **initialLocationName** (`String?`): Initial location name for edit mode
- **initialLatitude** (`double?`): Initial latitude coordinate
- **initialLongitude** (`double?`): Initial longitude coordinate
- **padding** (`EdgeInsetsGeometry?`): Custom padding for the widget container

#### Features

1. **Search Bar**: Type to search for locations by name or address
2. **Results List**: Shows matching locations with full addresses
3. **Current Location Button**: Capture device GPS location with one tap
4. **Mini Map Preview**: Interactive map showing selected location
5. **Location Details**: Display selected location info with coordinates
6. **Clear Button**: Remove selected location
7. **Error Handling**: User-friendly error messages with dismiss button

### LocationPickerButton

Compact inline button that opens the full picker in a bottom sheet.

#### Constructor

```dart
LocationPickerButton({
  Key? key,
  String? currentLocationName,
  String label = 'Select Location',
  IconData icon = Icons.edit_location,
})
```

#### Parameters

- **currentLocationName** (`String?`): Currently selected location name (if any)
- **label** (`String`): Button text when no location is selected
- **icon** (`IconData`): Icon to display on the button

## Usage Patterns

### Pattern 1: In Journal Entry Creation Form

```dart
class CreateJournalEntryScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('New Entry')),
      body: ListView(
        children: [
          TextFormField(
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 16),
          const LocationPickerWidget(),
          // ... other form fields
        ],
      ),
    );
  }
}
```

### Pattern 2: Editing Existing Entry

```dart
class EditJournalEntryScreen extends ConsumerWidget {
  final JournalEntry entry;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Edit Entry')),
      body: ListView(
        children: [
          TextFormField(
            initialValue: entry.title,
            decoration: const InputDecoration(labelText: 'Title'),
          ),
          const SizedBox(height: 16),
          LocationPickerWidget(
            initialLocationName: entry.locationName,
            initialLatitude: entry.latitude,
            initialLongitude: entry.longitude,
          ),
          // ... other form fields
        ],
      ),
    );
  }
}
```

### Pattern 3: Compact Inline Usage

```dart
Row(
  children: [
    Expanded(
      child: TextFormField(
        decoration: const InputDecoration(labelText: 'Title'),
      ),
    ),
    const SizedBox(width: 12),
    const LocationPickerButton(
      label: 'Add Location',
    ),
  ],
)
```

### Pattern 4: Monitoring State Changes

```dart
class LocationMonitor extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final creationState = ref.watch(journalEntryCreationProvider);

    return Column(
      children: [
        const LocationPickerWidget(),
        if (creationState.latitude != null)
          Text('Selected: ${creationState.locationName}'),
      ],
    );
  }
}
```

### Pattern 5: Validation Before Save

```dart
void saveEntry(BuildContext context, WidgetRef ref) {
  final creationState = ref.read(journalEntryCreationProvider);

  if (creationState.latitude == null) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Please select a location')),
    );
    return;
  }

  // Proceed with save
  // ...
}
```

## Provider Integration

The widget automatically integrates with `journalEntryCreationProvider` from Riverpod. When a location is selected:

```dart
ref.read(journalEntryCreationProvider.notifier).updateLocation(
  locationName: 'Paris, France',
  latitude: 48.8566,
  longitude: 2.3522,
  locationAccuracy: null,
)
```

To access the selected location in your code:

```dart
final creationState = ref.watch(journalEntryCreationProvider);

print('Location: ${creationState.locationName}');
print('Coordinates: ${creationState.latitude}, ${creationState.longitude}');
```

To clear the location:

```dart
ref.read(journalEntryCreationProvider.notifier).clearLocation();
```

## Geocoding Service

The widget uses `GeocodingService` for address/coordinate conversion:

```dart
import 'package:soloadventurer/utils/geocoding_service.dart';

// Search for locations
final geocodingService = GeocodingService.instance;
final results = await geocodingService.searchLocations('Eiffel Tower');

// Reverse geocoding
final address = await geocodingService.getAddressFromCoordinates(
  48.8584,
  2.2945,
);
print('Address: ${address?.fullAddress}');
```

## GeocodingResult Model

```dart
class GeocodingResult {
  final String name;              // Human-readable name
  final String? fullAddress;      // Complete address
  final double latitude;          // Latitude coordinate
  final double longitude;         // Longitude coordinate
  final String? locality;         // City
  final String? administrativeArea; // State/Province
  final String? country;          // Country
  final String? postalCode;       // ZIP/Postal code
  final String? street;           // Street address
}
```

## Customization

### Custom Padding

```dart
LocationPickerWidget(
  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
)
```

### Custom Button Style

```dart
LocationPickerButton(
  label: 'Add Location',
  icon: Icons.map,
  currentLocationName: 'Current Location',
)
```

### Custom Error Handling

The widget shows built-in error messages. To add custom handling:

```dart
final creationState = ref.watch(journalEntryCreationProvider);

if (creationState.error != null &&
    creationState.error!.contains('location')) {
  // Handle location-specific errors
  showCustomErrorDialog(context, creationState.error!);
}
```

## Styling and Theming

The widget follows Material Design 3 and automatically adapts to your app's theme:

- **Light/Dark Mode**: Automatic color scheme adaptation
- **Primary Color**: Used for selected state indicators
- **Surface Colors**: For containers and cards
- **Outline Colors**: For borders and unselected states

To customize colors, update your theme:

```dart
ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Colors.blue,
    // Widget will use these colors automatically
  ),
)
```

## Platform Requirements

### Android

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
<uses-permission android:name="android.permission.ACCESS_FINE_LOCATION" />
<uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION" />

<meta-data
  android:name="com.google.android.geo.API_KEY"
  android:value="YOUR_GOOGLE_MAPS_API_KEY"/>
```

### iOS

Add to `ios/Runner/Info.plist`:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>This app needs access to location when in use.</string>
<key>NSLocationAlwaysUsageDescription</key>
<string>This app needs access to location always.</string>
```

Add Google Maps API key in `ios/Runner/AppDelegate.swift`:

```swift
GMSServices.provideAPIKey("YOUR_GOOGLE_MAPS_API_KEY")
```

## Error Handling

The widget handles these errors automatically:

1. **Network errors**: Shows message when offline
2. **Permission denied**: Prompts user to grant location permissions
3. **Service disabled**: Asks user to enable location services
4. **Search failed**: Shows error when geocoding fails
5. **Location timeout**: Handles timeout during location capture

All errors are shown in a dismissible error container within the widget.

## Accessibility

The widget includes:

- **Semantic labels**: Screen reader support for all interactive elements
- **Touch targets**: Minimum 48x48px touch targets for buttons
- **Color contrast**: Follows WCAG AA guidelines
- **Focus handling**: Proper focus management for keyboard navigation

## Performance Considerations

1. **Search Debouncing**: Searches are triggered on every keystroke (consider adding debouncing for slow networks)
2. **Map Loading**: Map is only created when location is selected
3. **Memory Management**: Controllers are properly disposed
4. **State Management**: Efficient Riverpod state updates

## Testing

### Example Test Data

```dart
final testLocations = [
  GeocodingResult(
    name: 'Eiffel Tower',
    fullAddress: 'Champ de Mars, 5 Avenue Anatole France, 75007 Paris, France',
    latitude: 48.8584,
    longitude: 2.2945,
    locality: 'Paris',
    administrativeArea: 'Île-de-France',
    country: 'France',
  ),
  // ... more test locations
];
```

### Mock Provider

```dart
final mockJournalEntryCreationProvider = StateNotifierProvider<
  JournalEntryCreationNotifier, JournalEntryCreationState>((ref) {
  return MockJournalEntryCreationNotifier();
});
```

## Troubleshooting

### Issue: Map not showing

**Solution**: Check that your Google Maps API key is properly configured and enabled for Maps SDK.

### Issue: Search not working

**Solution**: Verify geolocator permissions are granted and network connection is available.

### Issue: Location not updating

**Solution**: Ensure the provider is being watched/read correctly in your widget tree.

### Issue: Bottom sheet not closing

**Solution**: Make sure to call `Navigator.pop(context)` in your button handlers.

## Best Practices

1. **Always validate** location is set before saving journal entries
2. **Handle nulls** when accessing location data from provider
3. **Show loading states** when waiting for location capture
4. **Provide feedback** when location is successfully selected
5. **Test on real devices** for accurate GPS behavior
6. **Handle permissions** gracefully with clear user messages
7. **Use edit mode** when updating existing entries
8. **Consider offline** scenarios and provide fallback UI

## Examples

See `location_picker_widget_example.dart` for complete working examples:

1. Basic usage in a form
2. Edit mode with initial location
3. Compact button variant
4. State monitoring
5. Programmatic location setting
6. Integration with save flow

## Related Components

- **LocationCaptureWidget**: For automatic GPS location capture (subtask 4.1)
- **LocationService**: For device location operations
- **GeocodingService**: For address/coordinate conversion
- **JournalEntryCreationProvider**: For state management

## Future Enhancements

Potential improvements for future versions:

- [ ] Search debouncing for better performance
- [ ] Recent locations list
- [ ] Favorite locations
- [ ] Drag to select on map
- [ ] Search history
- [ ] Offline address caching
- [ ] Custom map styles
- [ ] Street view integration
- [ ] Place autocomplete API integration
- [ ] Location sharing features

## Support

For issues, questions, or contributions related to the location picker widget, please refer to the main project documentation.

## License

This component is part of the SoloAdventurer project and follows the same license terms.
