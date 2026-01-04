import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/journal/presentation/screens/journal_map_screen.dart';

/// Example usage of JournalMapScreen
///
/// This file demonstrates various ways to integrate and use the JournalMapScreen
/// in your application.

// ============================================================================
// Example 1: Basic Navigation to Global Map
// ============================================================================

class JournalMapExampleScreen extends StatelessWidget {
  const JournalMapExampleScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Map Examples'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _ExampleCard(
            title: 'Global Journal Map',
            description: 'View all journal entries with location data',
            icon: Icons.public,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const JournalMapScreen(),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _ExampleCard(
            title: 'Trip Journal Map',
            description: 'View locations for a specific trip',
            icon: Icons.flight_takeoff,
            onTap: () {
              // Replace with actual trip ID
              const tripId = 'your-trip-id';
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const JournalMapScreen(tripId: tripId),
                ),
              );
            },
          ),
          const SizedBox(height: 16),
          _ExampleCard(
            title: 'Full Map Demo',
            description: 'Complete integration with all features',
            icon: Icons.map,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const _FullMapDemoScreen(),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Example 2: Full Map Demo Screen with ProviderScope
// ============================================================================

class _FullMapDemoScreen extends ConsumerStatefulWidget {
  const _FullMapDemoScreen();

  @override
  ConsumerState<_FullMapDemoScreen> createState() => _FullMapDemoScreenState();
}

class _FullMapDemoScreenState extends ConsumerState<_FullMapDemoScreen> {
  @override
  Widget build(BuildContext context) {
    final mapState = ref.watch(journalMapProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Journal Map Demo'),
        actions: [
          // Favorites filter toggle
          IconButton(
            icon: Icon(
              mapState.showOnlyFavorites
                  ? Icons.favorite
                  : Icons.favorite_border,
            ),
            onPressed: () {
              ref.read(journalMapProvider.notifier).toggleFavoritesFilter();
            },
            tooltip: 'Toggle favorites filter',
          ),
          // Map options
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'refresh':
                  ref.read(journalMapProvider.notifier).refresh();
                  break;
                case 'center':
                  _centerOnAllMarkers();
                  break;
                case 'clear_selection':
                  ref.read(journalMapProvider.notifier).clearSelection();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'refresh',
                child: Row(
                  children: [
                    Icon(Icons.refresh),
                    SizedBox(width: 8),
                    Text('Refresh'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'center',
                child: Row(
                  children: [
                    Icon(Icons.center_focus_strong),
                    SizedBox(width: 8),
                    Text('Center on markers'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'clear_selection',
                child: Row(
                  children: [
                    Icon(Icons.clear),
                    SizedBox(width: 8),
                    Text('Clear selection'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          // Stats bar
          if (mapState.hasMarkers)
            Container(
              padding: const EdgeInsets.all(12),
              color: Theme.of(context).colorScheme.surfaceVariant,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _StatItem(
                    icon: Icons.location_on,
                    label: 'Locations',
                    value: mapState.markerCount.toString(),
                  ),
                  _StatItem(
                    icon: Icons.article,
                    label: 'Entries',
                    value: mapState.entryCount.toString(),
                  ),
                  if (mapState.showOnlyFavorites)
                    _StatItem(
                      icon: Icons.favorite,
                      label: 'Favorites',
                      value: mapState.markers
                          .where((m) => m.entry.isFavorite)
                          .length
                          .toString(),
                    ),
                ],
              ),
            ),

          // Map screen
          Expanded(
            child: const JournalMapScreen(),
          ),
        ],
      ),
    );
  }

  void _centerOnAllMarkers() {
    // This would be handled by the map controller in JournalMapScreen
    // The JournalMapScreen already has a "Center on all markers" button
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Use the center button in the app bar'),
        duration: Duration(seconds: 2),
      ),
    );
  }
}

// ============================================================================
// Example 3: Trip-Specific Map with Bottom Sheet
// ============================================================================

class TripMapExampleScreen extends ConsumerWidget {
  final String tripId;
  final String tripName;

  const TripMapExampleScreen({
    super.key,
    required this.tripId,
    required this.tripName,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tripMapState = ref.watch(journalTripMapProvider(tripId));

    return Scaffold(
      appBar: AppBar(
        title: Text('$tripName - Map'),
      ),
      body: Stack(
        children: [
          // Map view
          JournalMapScreen(tripId: tripId),

          // Bottom sheet with trip info
          if (tripMapState.hasMarkers)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surface,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(16),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.2),
                      blurRadius: 10,
                      offset: const Offset(0, -2),
                    ),
                  ],
                ),
                padding: const EdgeInsets.all(16),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.map),
                        const SizedBox(width: 8),
                        Text(
                          'Trip Locations',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const Spacer(),
                        Chip(
                          label: Text('${tripMapState.markerCount} locations'),
                          avatar: const Icon(Icons.location_on, size: 16),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tap on markers to view journal entries',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.grey,
                          ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================================
// Example 4: Map with Custom Bottom Navigation
// ============================================================================

class MainNavigationExample extends ConsumerStatefulWidget {
  const MainNavigationExample({super.key});

  @override
  ConsumerState<MainNavigationExample> createState() => _MainNavigationExampleState();
}

class _MainNavigationExampleState extends ConsumerState<MainNavigationExample> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const _HomePlaceholder(),
    const JournalMapScreen(),
    const _SettingsPlaceholder(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: NavigationBar(
        currentIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          NavigationDestination(
            icon: Icon(Icons.map),
            label: 'Map',
          ),
          NavigationDestination(
            icon: Icon(Icons.settings),
            label: 'Settings',
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// Helper Widgets
// ============================================================================

class _ExampleCard extends StatelessWidget {
  final String title;
  final String description;
  final IconData icon;
  final VoidCallback onTap;

  const _ExampleCard({
    required this.title,
    required this.description,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, size: 32),
        title: Text(title),
        subtitle: Text(description),
        trailing: const Icon(Icons.chevron_right),
        onTap: onTap,
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 20),
        const SizedBox(height: 4),
        Text(
          value,
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
        ),
        Text(
          label,
          style: Theme.of(context).textTheme.bodySmall,
        ),
      ],
    );
  }
}

class _HomePlaceholder extends StatelessWidget {
  const _HomePlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Home Screen'),
    );
  }
}

class _SettingsPlaceholder extends StatelessWidget {
  const _SettingsPlaceholder();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text('Settings Screen'),
    );
  }
}

// ============================================================================
// Example 5: Standalone Test with Mock Data
// ============================================================================

class JournalMapTestScreen extends StatelessWidget {
  const JournalMapTestScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Journal Map Test'),
        ),
        body: const JournalMapScreen(),
      ),
    );
  }
}

// ============================================================================
// Usage Instructions
// ============================================================================

/*
## Integration Examples

### 1. Basic Navigation (Simplest)

```dart
// Navigate to global map showing all entries
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
      tripId: 'your-trip-id',
    ),
  ),
);
```

### 2. As a Tab in Bottom Navigation

```dart
// In your main navigation widget
final List<Widget> _screens = [
  const HomeScreen(),
  const JournalMapScreen(), // Map as one of the tabs
  const ProfileScreen(),
];

// Use IndexedStack to preserve state
body: IndexedStack(
  index: _currentIndex,
  children: _screens,
),
```

### 3. With ProviderScope for Testing

```dart
ProviderScope(
  child: const JournalMapScreen(),
)
```

### 4. Accessing Map State

```dart
final mapState = ref.watch(journalMapProvider);

// Check if there are markers
if (mapState.hasMarkers) {
  print('Has ${mapState.markerCount} markers');
}

// Access selected entry
if (mapState.hasSelection) {
  final entry = mapState.selectedEntry;
  print('Selected: ${entry.title}');
}
```

### 5. Controlling Map Programmatically

```dart
final notifier = ref.read(journalMapProvider.notifier);

// Refresh data
await notifier.refresh();

// Toggle favorites filter
notifier.toggleFavoritesFilter();

// Clear selection
notifier.clearSelection();

// Load entries for specific trip
await notifier.loadEntriesForTrip(tripId);

// Find entries near a location
final nearbyEntries = notifier.findEntriesNearLocation(
  LatLng(37.7749, -122.4194),
  radiusKm: 10,
);
```

## Provider Setup

Make sure you have the following providers set up in your app:

```dart
// In your main.dart or provider configuration
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

final journalRemoteDataSourceProvider = Provider<JournalRemoteDataSourceImpl>((ref) {
  final client = ref.watch(supabaseClientProvider);
  return JournalRemoteDataSourceImpl(client: client);
});

final journalRepositoryProvider = Provider<JournalRepository>((ref) {
  final remoteDataSource = ref.watch(journalRemoteDataSourceProvider);
  return JournalRepositoryImpl(remoteDataSource: remoteDataSource);
});
```

## Permissions

Don't forget to add the necessary permissions for map rendering:

### Android (android/app/src/main/AndroidManifest.xml)
```xml
<uses-permission android:name="android.permission.INTERNET" />
```

### iOS (ios/Runner/Info.plist)
```xml
<key>NSAppTransportSecurity</key>
<dict>
    <key>NSAllowsArbitraryLoads</key>
    <true/>
</dict>
```

## Map Tiles

This implementation uses OpenStreetMap tiles by default, which are free and
don't require an API key. If you want to use a different tile provider,
you can modify the TileLayer in JournalMapScreen.
*/
