import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/core/models/map_marker.dart';
import 'package:soloadventurer/features/travel/presentation/screens/trip_map_screen.dart';

/// Example 1: Basic Trip Map Screen with sample markers
///
/// This example demonstrates how to use the TripMapScreen with a simple
/// list of markers representing San Francisco tourist attractions.
class ExampleTripMapScreen extends StatelessWidget {
  const ExampleTripMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        tripMapMarkersProvider.overrideWithValue(_sfMarkers),
      ],
      child: const TripMapScreen(),
    );
  }

  /// Sample markers for San Francisco attractions
  static const List<MapMarker> _sfMarkers = [
    // Golden Gate Bridge area
    MapMarker(
      id: '1',
      lat: 37.8199,
      lng: -122.4783,
      type: MapMarkerType.poi,
      title: 'Golden Gate Bridge',
      description: 'Iconic suspension bridge',
    ),
    MapMarker(
      id: '2',
      lat: 37.8205,
      lng: -122.4790,
      type: MapMarkerType.activity,
      title: 'Golden Gate Viewpoint',
      description: 'Best photo spot',
    ),
    MapMarker(
      id: '3',
      lat: 37.8210,
      lng: -122.4800,
      type: MapMarkerType.activity,
      title: 'Bridge Walk',
      description: 'Walk across the bridge',
    ),

    // Fisherman's Wharf area
    MapMarker(
      id: '4',
      lat: 37.8080,
      lng: -122.4177,
      type: MapMarkerType.poi,
      title: 'Fisherman\'s Wharf',
      description: 'Historic waterfront district',
    ),
    MapMarker(
      id: '5',
      lat: 37.8085,
      lng: -122.4180,
      type: MapMarkerType.restaurant,
      title: 'Seafood Restaurant',
      description: 'Fresh clam chowder',
    ),
    MapMarker(
      id: '6',
      lat: 37.8090,
      lng: -122.4175,
      type: MapMarkerType.activity,
      title: 'Harbor Cruise',
      description: 'Bay boat tours',
    ),

    // Union Square area
    MapMarker(
      id: '7',
      lat: 37.7879,
      lng: -122.4074,
      type: MapMarkerType.poi,
      title: 'Union Square',
      description: 'Shopping district',
    ),
    MapMarker(
      id: '8',
      lat: 37.7880,
      lng: -122.4070,
      type: MapMarkerType.shopping,
      title: 'Department Store',
      description: 'Luxury shopping',
    ),
    MapMarker(
      id: '9',
      lat: 37.7885,
      lng: -122.4080,
      type: MapMarkerType.restaurant,
      title: 'Cafe',
      description: 'Coffee and pastries',
    ),

    // Chinatown area
    MapMarker(
      id: '10',
      lat: 37.7941,
      lng: -122.4078,
      type: MapMarkerType.poi,
      title: 'Chinatown',
      description: 'Historic neighborhood',
    ),
    MapMarker(
      id: '11',
      lat: 37.7945,
      lng: -122.4080,
      type: MapMarkerType.restaurant,
      title: 'Dim Sum Restaurant',
      description: 'Traditional Chinese cuisine',
    ),
    MapMarker(
      id: '12',
      lat: 37.7940,
      lng: -122.4075,
      type: MapMarkerType.activity,
      title: 'Temple Visit',
      description: 'Buddhist temple',
    ),
  ];
}

/// Example 2: High-density markers (NYC Manhattan)
///
/// This example demonstrates clustering with 100+ markers in a small area
/// to show the effectiveness of the clustering algorithm.
class ExampleHighDensityMapScreen extends StatelessWidget {
  const ExampleHighDensityMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        tripMapMarkersProvider.overrideWithValue(_generateNYCMarkers()),
      ],
      child: const TripMapScreen(),
    );
  }

  /// Generate 100+ markers for Manhattan
  static List<MapMarker> _generateNYCMarkers() {
    final markers = <MapMarker>[];
    final random = DateTime.now().millisecondsSinceEpoch;

    // Central Park area
    for (int i = 0; i < 50; i++) {
      final lat = 40.7829 + (random % 1000) / 100000.0;
      final lng = -73.9654 + (random % 1000) / 100000.0;
      markers.add(MapMarker(
        id: 'cp_$i',
        lat: lat,
        lng: lng,
        type: MapMarkerType.poi,
        title: 'Central Park Spot $i',
        description: 'Park attraction $i',
      ));
    }

    // Times Square area
    for (int i = 0; i < 50; i++) {
      final lat = 40.7580 + (random % 500) / 100000.0;
      final lng = -73.9855 + (random % 500) / 100000.0;
      markers.add(MapMarker(
        id: 'ts_$i',
        lat: lat,
        lng: lng,
        type: MapMarkerType.activity,
        title: 'Times Square $i',
        description: 'Entertainment venue $i',
      ));
    }

    return markers;
  }
}

/// Example 3: Multi-type markers (European city tour)
///
/// This example demonstrates markers of different types with appropriate icons.
class ExampleMultiTypeMapScreen extends StatelessWidget {
  const ExampleMultiTypeMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        tripMapMarkersProvider.overrideWithValue(_parisMarkers),
      ],
      child: const TripMapScreen(),
    );
  }

  /// Sample markers for Paris with different types
  static const List<MapMarker> _parisMarkers = [
    // Trip markers
    MapMarker(
      id: 'trip_1',
      lat: 48.8584,
      lng: 2.2945,
      type: MapMarkerType.trip,
      title: 'Paris Trip',
      description: '5-day Paris adventure',
    ),

    // Accommodation markers
    MapMarker(
      id: 'hotel_1',
      lat: 48.8566,
      lng: 2.3522,
      type: MapMarkerType.accommodation,
      title: 'Hotel Le Marais',
      description: 'Boutique hotel in historic district',
    ),
    MapMarker(
      id: 'hotel_2',
      lat: 48.8600,
      lng: 2.3400,
      type: MapMarkerType.accommodation,
      title: 'Airbnb Apartment',
      description: 'Charming studio near Louvre',
    ),

    // Restaurant markers
    MapMarker(
      id: 'rest_1',
      lat: 48.8560,
      lng: 2.3490,
      type: MapMarkerType.restaurant,
      title: 'Café de Flore',
      description: 'Historic Parisian café',
    ),
    MapMarker(
      id: 'rest_2',
      lat: 48.8590,
      lng: 2.3450,
      type: MapMarkerType.restaurant,
      title: 'Le Comptoir',
      description: 'Traditional bistro',
    ),

    // Transport markers
    MapMarker(
      id: 'trans_1',
      lat: 48.8580,
      lng: 2.3500,
      type: MapMarkerType.transport,
      title: 'Metro Station',
      description: 'Line 1 - Louvre-Rivoli',
    ),
    MapMarker(
      id: 'trans_2',
      lat: 48.8540,
      lng: 2.3450,
      type: MapMarkerType.transport,
      title: 'Bus Stop',
      description: 'Bus 69 - Eiffel Tower',
    ),

    // Activity markers
    MapMarker(
      id: 'act_1',
      lat: 48.8584,
      lng: 2.2945,
      type: MapMarkerType.activity,
      title: 'Eiffel Tower Visit',
      description: 'Skip-the-line tickets',
    ),
    MapMarker(
      id: 'act_2',
      lat: 48.8606,
      lng: 2.3376,
      type: MapMarkerType.activity,
      title: 'Louvre Museum',
      description: 'Guided tour',
    ),

    // Photo markers
    MapMarker(
      id: 'photo_1',
      lat: 48.8530,
      lng: 2.3499,
      type: MapMarkerType.photo,
      title: 'Seine River Photo',
      description: 'Sunset at Pont des Arts',
    ),

    // POI markers
    MapMarker(
      id: 'poi_1',
      lat: 48.8530,
      lng: 2.3499,
      type: MapMarkerType.poi,
      title: 'Notre-Dame Cathedral',
      description: 'Gothic masterpiece',
    ),
    MapMarker(
      id: 'poi_2',
      lat: 48.8867,
      lng: 2.3431,
      type: MapMarkerType.poi,
      title: 'Arc de Triomphe',
      description: 'Iconic monument',
    ),
  ];
}

/// Example 4: Performance test with 500 markers
///
/// This example tests the clustering performance with 500 markers
/// spread across a large geographic area.
class ExamplePerformanceTestMapScreen extends StatelessWidget {
  const ExamplePerformanceTestMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        tripMapMarkersProvider.overrideWithValue(_generate500Markers()),
      ],
      child: const TripMapScreen(),
    );
  }

  /// Generate 500 markers across the US
  static List<MapMarker> _generate500Markers() {
    final markers = <MapMarker>[];
    final random = DateTime.now().millisecondsSinceEpoch;

    // Generate markers across major US cities
    final cities = [
      {'name': 'New York', 'lat': 40.7128, 'lng': -74.0060},
      {'name': 'Los Angeles', 'lat': 34.0522, 'lng': -118.2437},
      {'name': 'Chicago', 'lat': 41.8781, 'lng': -87.6298},
      {'name': 'Houston', 'lat': 29.7604, 'lng': -95.3698},
      {'name': 'Phoenix', 'lat': 33.4484, 'lng': -112.0740},
      {'name': 'Philadelphia', 'lat': 39.9526, 'lng': -75.1652},
      {'name': 'San Antonio', 'lat': 29.4241, 'lng': -98.4936},
      {'name': 'San Diego', 'lat': 32.7157, 'lng': -117.1611},
      {'name': 'Dallas', 'lat': 32.7767, 'lng': -96.7970},
      {'name': 'San Jose', 'lat': 37.3382, 'lng': -121.8863},
    ];

    int markerId = 0;
    for (final city in cities) {
      final cityLat = city['lat'] as double;
      final cityLng = city['lng'] as double;
      final cityName = city['name'] as String;

      // Generate 50 markers per city
      for (int i = 0; i < 50; i++) {
        final lat = cityLat + (random % 2000 - 1000) / 100000.0;
        final lng = cityLng + (random % 2000 - 1000) / 100000.0;
        final type =
            MapMarkerType.values[markerId % MapMarkerType.values.length];

        markers.add(MapMarker(
          id: 'marker_$markerId',
          lat: lat,
          lng: lng,
          type: type,
          title: '$cityName Location $i',
          description: 'Point of interest in $cityName',
        ));

        markerId++;
      }
    }

    return markers;
  }
}

/// Example 5: Custom map configuration
///
/// This example shows how to customize the TripMapScreen behavior
/// by modifying the clustering manager initialization.
class ExampleCustomConfigMapScreen extends StatefulWidget {
  const ExampleCustomConfigMapScreen({super.key});

  @override
  State<ExampleCustomConfigMapScreen> createState() =>
      _ExampleCustomConfigMapScreenState();
}

class _ExampleCustomConfigMapScreenState
    extends State<ExampleCustomConfigMapScreen> {
  // This would normally be in TripMapScreen, but shown here for demonstration
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        tripMapMarkersProvider
            .overrideWithValue(ExampleTripMapScreen._sfMarkers),
      ],
      child: const TripMapScreen(),
    );
  }
}

/// Example 6: Integration with Trip data
///
/// This example demonstrates how to convert Trip domain models
/// into map markers for display on the map.
class ExampleTripIntegrationMapScreen extends StatelessWidget {
  const ExampleTripIntegrationMapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      overrides: [
        tripMapMarkersProvider.overrideWithValue(_convertTripsToMarkers()),
      ],
      child: const TripMapScreen(),
    );
  }

  /// Convert Trip domain models to MapMarker objects
  static List<MapMarker> _convertTripsToMarkers() {
    // In a real implementation, you would fetch trips from a repository
    // and convert them to markers using the MapMarker.fromTrip() factory

    final trips = [
      {
        'id': 'trip_1',
        'title': 'San Francisco Adventure',
        'destination': 'San Francisco, CA',
        'lat': 37.7749,
        'lng': -122.4194,
        'startDate': '2026-06-01',
        'endDate': '2026-06-07',
      },
      {
        'id': 'trip_2',
        'title': 'New York City Break',
        'destination': 'New York, NY',
        'lat': 40.7128,
        'lng': -74.0060,
        'startDate': '2026-07-15',
        'endDate': '2026-07-20',
      },
      {
        'id': 'trip_3',
        'title': 'Grand Canyon Trip',
        'destination': 'Grand Canyon, AZ',
        'lat': 36.1069,
        'lng': -112.1129,
        'startDate': '2026-08-01',
        'endDate': '2026-08-05',
      },
    ];

    return trips.map((trip) {
      return MapMarker(
        id: trip['id'] as String,
        lat: trip['lat'] as double,
        lng: trip['lng'] as double,
        type: MapMarkerType.trip,
        title: trip['title'] as String,
        description: trip['destination'] as String,
        metadata: {
          'startDate': trip['startDate'],
          'endDate': trip['endDate'],
        },
      );
    }).toList();
  }
}

/// Example app demonstrating all TripMapScreen examples
///
/// Run this example app to see all the different map configurations
/// and use cases in action.
class ExampleTripMapApp extends StatelessWidget {
  const ExampleTripMapApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Trip Map Examples',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ExampleHomeScreen(),
    );
  }
}

/// Home screen with navigation to all examples
class ExampleHomeScreen extends StatelessWidget {
  const ExampleHomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trip Map Examples'),
      ),
      body: ListView(
        children: [
          _ExampleTile(
            title: 'Basic Trip Map',
            subtitle: 'San Francisco attractions',
            builder: (_) => const ExampleTripMapScreen(),
          ),
          _ExampleTile(
            title: 'High Density Map',
            subtitle: '100+ markers in Manhattan',
            builder: (_) => const ExampleHighDensityMapScreen(),
          ),
          _ExampleTile(
            title: 'Multi-Type Map',
            subtitle: 'Paris with all marker types',
            builder: (_) => const ExampleMultiTypeMapScreen(),
          ),
          _ExampleTile(
            title: 'Performance Test',
            subtitle: '500 markers across US',
            builder: (_) => const ExamplePerformanceTestMapScreen(),
          ),
          _ExampleTile(
            title: 'Trip Integration',
            subtitle: 'Convert trips to markers',
            builder: (_) => const ExampleTripIntegrationMapScreen(),
          ),
        ],
      ),
    );
  }
}

/// Helper widget for example list tiles
class _ExampleTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final WidgetBuilder builder;

  const _ExampleTile({
    required this.title,
    required this.subtitle,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.map),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: builder),
        );
      },
    );
  }
}
