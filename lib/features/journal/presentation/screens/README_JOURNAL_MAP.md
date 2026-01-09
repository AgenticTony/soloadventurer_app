# Journal Map View

An interactive map display showing all journal entry locations with markers, clustering, and navigation features.

## Table of Contents

- [Overview](#overview)
- [Features](#features)
- [Installation](#installation)
- [Quick Start](#quick-start)
- [Usage Examples](#usage-examples)
- [API Reference](#api-reference)
- [Customization](#customization)
- [State Management](#state-management)
- [Error Handling](#error-handling)
- [Performance Considerations](#performance-considerations)
- [Testing](#testing)
- [Troubleshooting](#troubleshooting)

## Overview

The Journal Map View provides a complete interactive mapping solution for visualizing journal entry locations. Built with `flutter_map` and OpenStreetMap tiles, it offers an offline-capable, free mapping solution without requiring API keys.

### Key Components

- **JournalMapScreen**: Main screen displaying the interactive map
- **JournalMapProvider**: State management for map data and markers
- **JournalMapMarker**: Data model representing a journal entry on the map
- **JournalMapState**: Immutable state class for map view

## Features

✅ **Interactive Map Display**
- OpenStreetMap tiles (free, no API key required)
- Smooth zooming and panning
- Auto-centering on markers
- Configurable zoom levels

✅ **Marker System**
- Custom markers for each journal entry
- Favorite indicators on markers
- Selected state highlighting
- Marker count badges

✅ **Filtering Options**
- Filter by trip
- Filter by favorites
- Toggle filters dynamically

✅ **Selection & Navigation**
- Tap markers to view entry details
- Info cards for selected entries
- Direct navigation to full entry view
- Floating action button for quick access

✅ **Visual Enhancements**
- Polyline connections between markers (chronological)
- Marker shadows for depth
- Smooth animations
- Material Design 3 styling

✅ **State Management**
- Riverpod integration
- Reactive updates
- Loading and error states
- Empty state handling

## Installation

The Journal Map View relies on the following dependencies (already in `pubspec.yaml`):

```yaml
dependencies:
  flutter_map: ^8.1.0          # Map rendering
  latlong2: ^0.9.0             # Latitude/longitude handling
  flutter_riverpod: ^2.5.1     # State management
  supabase_flutter: ^2.0.0     # Backend data source
```

### Platform Configuration

#### Android

No special configuration required. Ensure internet permission is enabled in `android/app/src/main/AndroidManifest.xml`:

```xml
<uses-permission android:name="android.permission.INTERNET" />
```

#### iOS

No special configuration required. The map uses HTTP tiles, which may require App Transport Security exception in `ios/Runner/Info.plist`:

```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## Quick Start

### Basic Usage

```dart
import 'package:soloadventurer/features/journal/presentation/screens/journal_map_screen.dart';

// Navigate to global map (all entries)
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const JournalMapScreen(),
  ),
);

// Navigate to trip-specific map
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => const JournalMapScreen(
      tripId: 'trip-123',
    ),
  ),
);
```

### With ProviderScope

```dart
ProviderScope(
  child: const JournalMapScreen(),
)
```

### In Bottom Navigation

```dart
final List<Widget> _screens = [
  const HomeScreen(),
  const JournalMapScreen(),  // Map tab
  const ProfileScreen(),
];

body: IndexedStack(
  index: _currentIndex,
  children: _screens,
),
```

## Usage Examples

### Example 1: Basic Map Integration

```dart
class MyHomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('My App')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const JournalMapScreen(),
              ),
            );
          },
          child: const Text('View Journal Map'),
        ),
      ),
    );
  }
}
```

### Example 2: Trip-Specific Map

```dart
class TripDetailPage extends ConsumerWidget {
  final String tripId;

  const TripDetailPage({required this.tripId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text('Trip Details')),
      body: Column(
        children: [
          // Other trip content
          ElevatedButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JournalMapScreen(tripId: tripId),
                ),
              );
            },
            child: const Text('View Trip Map'),
          ),
        ],
      ),
    );
  }
}
```

### Example 3: Accessing Map State

```dart
class MapStatsWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mapState = ref.watch(journalMapProvider);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Locations: ${mapState.markerCount}'),
            Text('Entries: ${mapState.entryCount}'),
            if (mapState.hasSelection)
              Text('Selected: ${mapState.selectedEntry?.title}'),
          ],
        ),
      ),
    );
  }
}
```

### Example 4: Programmatic Control

```dart
class MapControlExample extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(journalMapProvider.notifier);

    return Scaffold(
      body: const JournalMapScreen(),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Refresh map data
          notifier.refresh();

          // Or toggle favorites
          notifier.toggleFavoritesFilter();

          // Or clear selection
          notifier.clearSelection();
        },
        child: const Icon(Icons.refresh),
      ),
    );
  }
}
```

### Example 5: Finding Nearby Entries

```dart
class NearbyEntriesFinder extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(journalMapProvider.notifier);

    return ElevatedButton(
      onPressed: () {
        // San Francisco coordinates
        final sfLocation = LatLng(37.7749, -122.4194);

        // Find entries within 10km
        final nearbyEntries = notifier.findEntriesNearLocation(
          sfLocation,
          radiusKm: 10,
        );

        print('Found ${nearbyEntries.length} nearby entries');
      },
      child: const Text('Find Nearby Entries'),
    );
  }
}
```

## API Reference

### JournalMapScreen

Main screen component for displaying the interactive map.

#### Constructor

```dart
const JournalMapScreen({
  Key? key,
  String? tripId,  // Optional: Filter by trip ID
})
```

#### Parameters

- `tripId` (String?, optional): If provided, only shows entries from this trip

#### Example

```dart
// Global map
const JournalMapScreen()

// Trip map
const JournalMapScreen(tripId: 'trip-123')
```

### JournalMapProvider

State management provider for map data and interactions.

#### State Properties

```dart
class JournalMapState {
  List<JournalEntry> entries;          // All loaded entries
  List<JournalMapMarker> markers;      // Map markers
  JournalEntry? selectedEntry;         // Currently selected entry
  LatLng? centerPosition;              // Map center
  double zoomLevel;                    // Map zoom level
  bool isLoading;                      // Loading state
  String? error;                       // Error message
  String? tripIdFilter;                // Trip filter
  bool showOnlyFavorites;              // Favorites filter
}
```

#### Computed Properties

- `hasMarkers`: True if there are markers to display
- `markerCount`: Number of markers
- `entryCount`: Number of entries
- `isInitialLoading`: True if loading with no data yet
- `hasSelection`: True if an entry is selected

#### Notifier Methods

```dart
class JournalMapNotifier {
  // Data loading
  Future<void> loadEntries();
  Future<void> loadEntriesForTrip(String tripId);
  Future<void> refresh();

  // Selection
  void selectEntry(JournalEntry entry);
  void clearSelection();

  // Map control
  void updateCenter(LatLng position, {double? zoomLevel});
  void updateZoom(double zoomLevel);

  // Filtering
  void toggleFavoritesFilter();
  void clearTripFilter();

  // Utilities
  void clearError();
  List<JournalEntry> findEntriesNearLocation(
    LatLng position, {
    double radiusKm: 10,
  });
  JournalMapMarker? getMarkerForEntry(String entryId);
}
```

#### Providers

```dart
// Global provider (all entries)
final journalMapProvider = StateNotifierProvider<JournalMapNotifier, JournalMapState>(...)

// Trip-specific provider
final journalTripMapProvider = StateNotifierProvider.family<JournalMapNotifier, JournalMapState, String>(...)
```

### JournalMapMarker

Data model representing a journal entry on the map.

#### Properties

```dart
class JournalMapMarker {
  JournalEntry entry;      // The journal entry
  LatLng position;         // Latitude/longitude
  String label;            // Display label
}
```

#### Factory Constructor

```dart
JournalMapMarker.fromEntry(JournalEntry entry)
```

#### Methods

```dart
double distanceTo(LatLng point)  // Distance in meters
```

## Customization

### Changing Map Tiles

Replace OpenStreetMap with your preferred tile provider in `JournalMapScreen`:

```dart
TileLayer(
  urlTemplate: 'https://your-tile-provider/{z}/{x}/{y}.png',
  userAgentPackageName: 'com.yourapp.app',
  maxZoom: 19,
)
```

### Custom Marker Styles

Modify the marker widget in `_buildMarkers()`:

```dart
Container(
  decoration: BoxDecoration(
    color: yourCustomColor,
    shape: BoxShape.circle,  // or BoxShape.rectangle
    border: Border.all(
      color: yourBorderColor,
      width: yourBorderWidth,
    ),
  ),
  child: yourCustomIcon,
)
```

### Adjusting Polyline Style

Modify the polyline in `_buildMap()`:

```dart
Polyline(
  points: mapState.markers
      .map((marker) => marker.position)
      .toList(),
  strokeWidth: 3.0,        // Line thickness
  color: Colors.yourColor.withOpacity(0.5),  // Line color
  pattern: const StrokePattern.dashed(),  // Optional: dashed line
)
```

### Zoom Level Ranges

Adjust zoom limits in map options:

```dart
MapOptions(
  initialZoom: mapState.zoomLevel,
  minZoom: 2.0,   // Minimum zoom (furthest out)
  maxZoom: 18.0,  // Maximum zoom (closest in)
)
```

## State Management

### Provider Setup

The map uses Riverpod for state management. Ensure your app is wrapped with `ProviderScope`:

```dart
void main() {
  runApp(
    ProviderScope(
      child: const MyApp(),
    ),
  );
}
```

### Watching State

```dart
// Read state (read-only)
final mapState = ref.watch(journalMapProvider);

// Read notifier (for actions)
final notifier = ref.read(journalMapProvider.notifier);
```

### Provider Selection

```dart
// Use global provider for all entries
final globalState = ref.watch(journalMapProvider);

// Use trip provider for specific trip
final tripState = ref.watch(journalTripMapProvider(tripId));
```

## Error Handling

The map screen includes comprehensive error handling:

### Error States

- **Network Errors**: Displays error message with retry button
- **No Data**: Shows empty state with helpful message
- **Permission Errors**: Handled by location service

### Handling Errors

```dart
final mapState = ref.watch(journalMapProvider);

if (mapState.error != null) {
  // Error occurred
  return Text('Error: ${mapState.error}');
}

if (mapState.isLoading) {
  // Loading state
  return CircularProgressIndicator();
}

if (!mapState.hasMarkers) {
  // No data
  return Text('No locations to display');
}

// Normal state
return JournalMapScreen();
```

### Clearing Errors

```dart
ref.read(journalMapProvider.notifier).clearError();
```

## Performance Considerations

### Optimizing Performance

1. **Limit Markers**: For large datasets, consider clustering or pagination
2. **Lazy Loading**: Entries are loaded on-demand from the repository
3. **Efficient Rebuilds**: Riverpod ensures only affected widgets rebuild
4. **Map Caching**: flutter_map caches tiles automatically

### Memory Management

- Map controller is disposed in `dispose()` method
- Markers are created once and reused
- Large entry lists are handled efficiently by Riverpod

### Recommended Limits

- **Small**: < 100 markers (optimal performance)
- **Medium**: 100-500 markers (good performance)
- **Large**: 500-1000 markers (consider clustering)
- **Very Large**: > 1000 markers (implement clustering/pagination)

## Testing

### Widget Test Example

```dart
testWidgets('JournalMapScreen displays markers', (WidgetTester tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: const MaterialApp(
        home: JournalMapScreen(),
      ),
    ),
  );

  // Wait for loading
  await tester.pumpAndSettle();

  // Verify map is displayed
  expect(find.byType(FlutterMap), findsOneWidget);
});
```

### Mock Provider for Testing

```dart
final mockMapProvider = StateNotifierProvider<JournalMapNotifier, JournalMapState>((ref) {
  return JournalMapNotifier(mockRepository);
});

test('Loads entries correctly', () async {
  final notifier = mockMapProvider.notifier;
  await notifier.loadEntries();

  expect(notifier.state.hasMarkers, true);
});
```

## Troubleshooting

### Common Issues

#### Map Not Displaying

**Problem**: Blank screen or map tiles not loading

**Solutions**:
- Check internet connection
- Verify OpenStreetMap tile URL is accessible
- Ensure `flutter_map` and `latlong2` dependencies are installed
- Run `flutter pub get`

#### Markers Not Appearing

**Problem**: Map shows but no markers

**Solutions**:
- Verify entries have location data (latitude/longitude)
- Check database for entries with `hasLocation == true`
- Ensure journal repository is returning data
- Check console for error messages

#### Performance Issues

**Problem**: Map is slow or laggy

**Solutions**:
- Reduce number of markers (filter by trip or favorites)
- Implement marker clustering
- Lower max zoom level
- Test on actual device (emulator may be slower)

#### Build Errors

**Problem**: Compilation errors after adding map screen

**Solutions**:
- Run `flutter pub get`
- Clean build: `flutter clean && flutter pub get`
- Check for conflicting dependency versions
- Ensure all imports are correct

### Debug Mode

Enable verbose logging for debugging:

```dart
// In JournalMapNotifier
Future<void> loadEntries() async {
  debugPrint('Loading entries...');
  state = state.copyWith(isLoading: true);

  try {
    final entries = await _repository.getEntriesWithLocation();
    debugPrint('Loaded ${entries.length} entries');
    // ...
  } catch (e) {
    debugPrint('Error loading entries: $e');
    // ...
  }
}
```

### Getting Help

If you encounter issues:

1. Check the [flutter_map documentation](https://docs.fleaflet.dev/)
2. Review OpenStreetMap tile server status
3. Check Supabase connection and data
4. Enable debug logging to trace issues
5. Verify all dependencies are up to date

## Integration with Other Features

### Trip Detail Screen

Add a map button to trip detail:

```dart
// In TripDetailScreen
Card(
  child: ListTile(
    leading: const Icon(Icons.map),
    title: const Text('View on Map'),
    trailing: const Icon(Icons.chevron_right),
    onTap: () {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => JournalMapScreen(tripId: trip.id),
        ),
      );
    },
  ),
)
```

### Bottom Navigation

Add map as a tab:

```dart
NavigationBar(
  destinations: [
    NavigationDestination(icon: Icon(Icons.home), label: 'Home'),
    NavigationDestination(icon: Icon(Icons.map), label: 'Map'),
    NavigationDestination(icon: Icon(Icons.person), label: 'Profile'),
  ],
)
```

### Search Integration

Show search results on map:

```dart
final results = await ref.read(journalSearchProvider.notifier).search(query);

// Navigate to map with filtered results
Navigator.push(
  context,
  MaterialPageRoute(
    builder: (context) => JournalMapScreen.fromEntries(results),
  ),
);
```

## Future Enhancements

Potential features for future iterations:

- [ ] Marker clustering for large datasets
- [ ] Custom map styles (dark mode, satellite, etc.)
- [ ] Heatmap view for location density
- [ ] Offline map caching
- [ ] Route planning between entries
- [ ] Geofencing for location reminders
- [ ] Animated route playback
- [ ] Photo thumbnails on markers
- [ ] Custom marker icons by mood/activity
- [ ] Export map as image

## Related Components

- **JournalEntryDetailScreen**: View full entry when marker tapped
- **TripDetailScreen**: Trip-specific map view
- **LocationPickerWidget**: Manual location selection
- **LocationService**: Automatic location capture
- **JournalRepository**: Data source for entries

## License

This component is part of the SoloAdventurer application.
