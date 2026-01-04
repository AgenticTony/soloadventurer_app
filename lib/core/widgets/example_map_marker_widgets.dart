import 'package:flutter/material.dart';
import 'package:soloadventurer/core/widgets/widgets.dart';
import 'package:soloadventurer/core/models/map_marker.dart';
import 'package:latlong2/latlong.dart';

/// Example 1: Basic marker display
class ExampleBasicMarker extends StatelessWidget {
  const ExampleBasicMarker({super.key});

  @override
  Widget build(BuildContext context) {
    final marker = MapMarker(
      id: 'marker-1',
      position: const LatLng(37.7749, -122.4194),
      title: 'San Francisco',
      type: MarkerType.trip,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Basic Marker')),
      body: Center(
        child: MapMarkerWidget(
          marker: marker,
          size: 50,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Marker tapped!')),
            );
          },
        ),
      ),
    );
  }
}

/// Example 2: Marker with title
class ExampleMarkerWithTitle extends StatelessWidget {
  const ExampleMarkerWithTitle({super.key});

  @override
  Widget build(BuildContext context) {
    final marker = MapMarker(
      id: 'marker-2',
      position: const LatLng(37.7749, -122.4194),
      title: 'Golden Gate Bridge',
      description: 'Famous suspension bridge',
      type: MarkerType.poi,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Marker with Title')),
      body: Center(
        child: MapMarkerWidget(
          marker: marker,
          size: 60,
          showTitle: true,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('${marker.title} tapped!')),
            );
          },
        ),
      ),
    );
  }
}

/// Example 3: Different marker types
class ExampleMarkerTypes extends StatelessWidget {
  const ExampleMarkerTypes({super.key});

  @override
  Widget build(BuildContext context) {
    final markers = [
      MapMarker(
        id: 'trip',
        position: const LatLng(0, 0),
        title: 'Trip',
        type: MarkerType.trip,
      ),
      MapMarker(
        id: 'activity',
        position: const LatLng(0, 0),
        title: 'Activity',
        type: MarkerType.activity,
      ),
      MapMarker(
        id: 'photo',
        position: const LatLng(0, 0),
        title: 'Photo',
        type: MarkerType.photo,
      ),
      MapMarker(
        id: 'accommodation',
        position: const LatLng(0, 0),
        title: 'Hotel',
        type: MarkerType.accommodation,
      ),
      MapMarker(
        id: 'restaurant',
        position: const LatLng(0, 0),
        title: 'Restaurant',
        type: MarkerType.restaurant,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Marker Types')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 3,
          mainAxisSpacing: 16,
          crossAxisSpacing: 16,
        ),
        itemCount: markers.length,
        itemBuilder: (context, index) {
          return Column(
            children: [
              MapMarkerWidget(
                marker: markers[index],
                showTitle: true,
              ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
}

/// Example 4: Basic cluster display
class ExampleBasicCluster extends StatelessWidget {
  const ExampleBasicCluster({super.key});

  @override
  Widget build(BuildContext context) {
    final cluster = MapCluster(
      id: 'cluster-1',
      position: const LatLng(37.7749, -122.4194),
      markerCount: 25,
      markerIds: List.generate(25, (i) => 'marker-$i'),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Basic Cluster')),
      body: Center(
        child: MapClusterWidget(
          cluster: cluster,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Cluster with ${cluster.markerCount} markers tapped!')),
            );
          },
        ),
      ),
    );
  }
}

/// Example 5: Different cluster sizes
class ExampleClusterSizes extends StatelessWidget {
  const ExampleClusterSizes({super.key});

  @override
  Widget build(BuildContext context) {
    final clusters = [
      MapCluster(
        id: 'small',
        position: const LatLng(0, 0),
        markerCount: 5,
        markerIds: ['1', '2', '3', '4', '5'],
      ),
      MapCluster(
        id: 'medium',
        position: const LatLng(0, 0),
        markerCount: 45,
        markerIds: List.generate(45, (i) => '$i'),
      ),
      MapCluster(
        id: 'large',
        position: const LatLng(0, 0),
        markerCount: 150,
        markerIds: List.generate(150, (i) => '$i'),
      ),
      MapCluster(
        id: 'xlarge',
        position: const LatLng(0, 0),
        markerCount: 500,
        markerIds: List.generate(500, (i) => '$i'),
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Cluster Sizes')),
      body: GridView.builder(
        padding: const EdgeInsets.all(16),
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          mainAxisSpacing: 24,
          crossAxisSpacing: 24,
        ),
        itemCount: clusters.length,
        itemBuilder: (context, index) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              MapClusterWidget(
                cluster: clusters[index],
                onTap: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Cluster: ${clusters[index].markerCount} markers'),
                    ),
                  );
                },
              ),
              const SizedBox(height: 8),
              Text(
                '${clusters[index].markerCount} markers',
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Example 6: Cluster with type indicators
class ExampleClusterWithTypes extends StatelessWidget {
  const ExampleClusterWithTypes({super.key});

  @override
  Widget build(BuildContext context) {
    final cluster = MapCluster(
      id: 'cluster-1',
      position: const LatLng(37.7749, -122.4194),
      markerCount: 15,
      markerIds: List.generate(15, (i) => 'marker-$i'),
      markerTypes: [
        MarkerType.trip,
        MarkerType.activity,
        MarkerType.photo,
        MarkerType.restaurant,
      ],
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Cluster with Types')),
      body: Center(
        child: MapClusterWithTypesWidget(
          cluster: cluster,
          showTypeIcons: true,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  'Cluster: ${cluster.markerCount} markers, ${cluster.markerTypes.length} types',
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

/// Example 7: Convenience constructors
class ExampleConvenienceConstructors extends StatelessWidget {
  const ExampleConvenienceConstructors({super.key});

  @override
  Widget build(BuildContext context) {
    final marker = MapMarker(
      id: 'trip-1',
      position: const LatLng(37.7749, -122.4194),
      title: 'Trip to Paris',
      type: MarkerType.trip,
    );

    final cluster = MapCluster(
      id: 'cluster-1',
      position: const LatLng(37.7749, -122.4194),
      markerCount: 25,
      markerIds: List.generate(25, (i) => 'marker-$i'),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Convenience Constructors')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Small Marker:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            MapMarkerWidget.small(marker: marker),
            const SizedBox(height: 24),
            const Text('Large Marker with Title:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            MapMarkerWidget.large(marker: marker, onTap: () {}),
            const SizedBox(height: 24),
            const Text('Small Cluster:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            MapClusterWidget.small(cluster: cluster),
            const SizedBox(height: 24),
            const Text('Large Cluster:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            MapClusterWidget.large(cluster: cluster),
          ],
        ),
      ),
    );
  }
}

/// Example 8: Custom styled cluster
class ExampleCustomStyledCluster extends StatelessWidget {
  const ExampleCustomStyledCluster({super.key});

  @override
  Widget build(BuildContext context) {
    final cluster = MapCluster(
      id: 'cluster-1',
      position: const LatLng(37.7749, -122.4194),
      markerCount: 100,
      markerIds: List.generate(100, (i) => 'marker-$i'),
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Custom Styled Cluster')),
      body: Center(
        child: MapClusterWidget.withColor(
          cluster: cluster,
          color: Colors.deepPurple,
          baseSize: 70,
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Custom cluster tapped!')),
            );
          },
        ),
      ),
    );
  }
}

/// Example app with all examples
class MapMarkerWidgetsExampleApp extends StatelessWidget {
  const MapMarkerWidgetsExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Map Marker Widgets Examples',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const ExamplesHome(),
    );
  }
}

class ExamplesHome extends StatelessWidget {
  const ExamplesHome({super.key});

  @override
  Widget build(BuildContext context) {
    final examples = [
      ('Basic Marker', const ExampleBasicMarker()),
      ('Marker with Title', const ExampleMarkerWithTitle()),
      ('Marker Types', const ExampleMarkerTypes()),
      ('Basic Cluster', const ExampleBasicCluster()),
      ('Cluster Sizes', const ExampleClusterSizes()),
      ('Cluster with Types', const ExampleClusterWithTypes()),
      ('Convenience Constructors', const ExampleConvenienceConstructors()),
      ('Custom Styled Cluster', const ExampleCustomStyledCluster()),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Map Marker Widgets Examples'),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: examples.length,
        itemBuilder: (context, index) {
          final (title, screen) = examples[index];
          return Card(
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              title: Text(title),
              trailing: const Icon(Icons.arrow_forward_ios),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => screen),
                );
              },
            ),
          );
        },
      ),
    );
  }
}
