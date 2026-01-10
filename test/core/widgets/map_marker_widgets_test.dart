import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/core/widgets/map_marker_widgets.dart';
import 'package:soloadventurer/core/models/map_marker.dart';
import 'package:latlong2/latlong.dart';

void main() {
  group('MapMarkerWidget', () {
    testWidgets('renders marker with default size', (tester) async {
      const marker = MapMarker(
        id: 'test-marker',
        position: LatLng(37.7749, -122.4194),
        type: MarkerType.trip,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MapMarkerWidget(marker: marker),
          ),
        ),
      );

      expect(find.byType(MapMarkerWidget), findsOneWidget);
      expect(find.byType(Container), findsWidgets);
    });

    testWidgets('renders marker with custom size', (tester) async {
      const marker = MapMarker(
        id: 'test-marker',
        position: LatLng(0, 0),
        type: MarkerType.activity,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MapMarkerWidget(marker: marker, size: 60.0),
          ),
        ),
      );

      final container = tester.widget<Container>(
        find.descendant(
          of: find.byType(MapMarkerWidget),
          matching: find.byType(Container).first,
        ),
      );

      expect(container.constraints?.minWidth, 60.0);
      expect(container.constraints?.minHeight, 60.0);
    });

    testWidgets('renders marker with title when showTitle is true',
        (tester) async {
      const marker = MapMarker(
        id: 'test-marker',
        position: LatLng(0, 0),
        title: 'San Francisco',
        type: MarkerType.trip,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MapMarkerWidget(marker: marker, showTitle: true),
          ),
        ),
      );

      expect(find.text('San Francisco'), findsOneWidget);
    });

    testWidgets('does not render title when showTitle is false',
        (tester) async {
      const marker = MapMarker(
        id: 'test-marker',
        position: LatLng(0, 0),
        title: 'San Francisco',
        type: MarkerType.trip,
      );

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MapMarkerWidget(marker: marker, showTitle: false),
          ),
        ),
      );

      expect(find.text('San Francisco'), findsNothing);
    });

    testWidgets('calls onTap callback when tapped', (tester) async {
      bool tapped = false;
      const marker = MapMarker(
        id: 'test-marker',
        position: LatLng(0, 0),
        type: MarkerType.poi,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapMarkerWidget(
              marker: marker,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(MapMarkerWidget));
      expect(tapped, isTrue);
    });

    testWidgets('renders correct icon for each marker type', (tester) async {
      final markerTypes = [
        MarkerType.trip,
        MarkerType.activity,
        MarkerType.photo,
        MarkerType.accommodation,
        MarkerType.restaurant,
        MarkerType.transport,
        MarkerType.poi,
      ];

      for (final type in markerTypes) {
        final marker = MapMarker(
          id: 'test-$type',
          position: const LatLng(0, 0),
          type: type,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MapMarkerWidget(marker: marker),
            ),
          ),
        );

        expect(find.byType(Icon), findsOneWidget);
        expect(find.byType(MapMarkerWidget), findsOneWidget);
      }
    });

    testWidgets('small convenience constructor renders small marker',
        (tester) async {
      const marker = MapMarker(
        id: 'test-marker',
        position: LatLng(0, 0),
        type: MarkerType.trip,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapMarkerWidget.small(marker: marker),
          ),
        ),
      );

      expect(find.byType(MapMarkerWidget), findsOneWidget);
    });

    testWidgets('large convenience constructor renders large marker',
        (tester) async {
      const marker = MapMarker(
        id: 'test-marker',
        position: LatLng(0, 0),
        title: 'Large Marker',
        type: MarkerType.activity,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapMarkerWidget.large(
              marker: marker,
              onTap: () {},
              showTitle: true,
            ),
          ),
        ),
      );

      expect(find.byType(MapMarkerWidget), findsOneWidget);
      expect(find.text('Large Marker'), findsOneWidget);
    });
  });

  group('MapClusterWidget', () {
    testWidgets('renders cluster with marker count', (tester) async {
      final cluster = MapCluster(
        id: 'test-cluster',
        position: const LatLng(0, 0),
        markerCount: 25,
        markerIds: List.generate(25, (i) => 'marker-$i'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapClusterWidget(cluster: cluster),
          ),
        ),
      );

      expect(find.byType(MapClusterWidget), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
    });

    testWidgets('abbreviates count when abbreviateCount is true',
        (tester) async {
      final cluster = MapCluster(
        id: 'test-cluster',
        position: const LatLng(0, 0),
        markerCount: 1500,
        markerIds: List.generate(1500, (i) => 'marker-$i'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapClusterWidget(
              cluster: cluster,
              abbreviateCount: true,
            ),
          ),
        ),
      );

      expect(find.text('1.5k'), findsOneWidget);
    });

    testWidgets('does not abbreviate count when abbreviateCount is false',
        (tester) async {
      final cluster = MapCluster(
        id: 'test-cluster',
        position: const LatLng(0, 0),
        markerCount: 1500,
        markerIds: List.generate(1500, (i) => 'marker-$i'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapClusterWidget(
              cluster: cluster,
              abbreviateCount: false,
            ),
          ),
        ),
      );

      expect(find.text('1500'), findsOneWidget);
      expect(find.text('1.5k'), findsNothing);
    });

    testWidgets('calls onTap callback when tapped', (tester) async {
      bool tapped = false;
      final cluster = MapCluster(
        id: 'test-cluster',
        position: const LatLng(0, 0),
        markerCount: 10,
        markerIds: List.generate(10, (i) => 'marker-$i'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapClusterWidget(
              cluster: cluster,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(MapClusterWidget));
      expect(tapped, isTrue);
    });

    testWidgets('renders with custom color', (tester) async {
      final cluster = MapCluster(
        id: 'test-cluster',
        position: const LatLng(0, 0),
        markerCount: 50,
        markerIds: List.generate(50, (i) => 'marker-$i'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapClusterWidget.withColor(
              cluster: cluster,
              color: Colors.purple,
            ),
          ),
        ),
      );

      expect(find.byType(MapClusterWidget), findsOneWidget);
    });

    testWidgets('small convenience constructor renders small cluster',
        (tester) async {
      const cluster = MapCluster(
        id: 'test-cluster',
        position: LatLng(0, 0),
        markerCount: 5,
        markerIds: ['1', '2', '3', '4', '5'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapClusterWidget.small(cluster: cluster),
          ),
        ),
      );

      expect(find.byType(MapClusterWidget), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
    });

    testWidgets('large convenience constructor renders large cluster',
        (tester) async {
      final cluster = MapCluster(
        id: 'test-cluster',
        position: const LatLng(0, 0),
        markerCount: 100,
        markerIds: List.generate(100, (i) => 'marker-$i'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapClusterWidget.large(cluster: cluster),
          ),
        ),
      );

      expect(find.byType(MapClusterWidget), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('animates when animate is true', (tester) async {
      final cluster = MapCluster(
        id: 'test-cluster',
        position: const LatLng(0, 0),
        markerCount: 25,
        markerIds: List.generate(25, (i) => 'marker-$i'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapClusterWidget(
              cluster: cluster,
              animate: true,
            ),
          ),
        ),
      );

      // Trigger animation
      await tester.pump();

      expect(find.byType(MapClusterWidget), findsOneWidget);
    });

    testWidgets('does not animate when animate is false', (tester) async {
      final cluster = MapCluster(
        id: 'test-cluster',
        position: const LatLng(0, 0),
        markerCount: 25,
        markerIds: List.generate(25, (i) => 'marker-$i'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapClusterWidget(
              cluster: cluster,
              animate: false,
            ),
          ),
        ),
      );

      expect(find.byType(MapClusterWidget), findsOneWidget);
    });
  });

  group('ClusterTypeIcons', () {
    testWidgets('renders icons for each marker type', (tester) async {
      final cluster = MapCluster(
        id: 'test-cluster',
        position: const LatLng(0, 0),
        markerCount: 10,
        markerIds: List.generate(10, (i) => 'marker-$i'),
        markerTypes: const [
          MarkerType.trip,
          MarkerType.activity,
          MarkerType.photo,
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClusterTypeIcons(cluster: cluster),
          ),
        ),
      );

      expect(find.byType(ClusterTypeIcons), findsOneWidget);
      expect(find.byType(Icon), findsNWidgets(3));
    });

    testWidgets('limits icons to maxIcons', (tester) async {
      final cluster = MapCluster(
        id: 'test-cluster',
        position: const LatLng(0, 0),
        markerCount: 10,
        markerIds: List.generate(10, (i) => 'marker-$i'),
        markerTypes: const [
          MarkerType.trip,
          MarkerType.activity,
          MarkerType.photo,
          MarkerType.accommodation,
          MarkerType.restaurant,
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClusterTypeIcons(
              cluster: cluster,
              maxIcons: 3,
            ),
          ),
        ),
      );

      // Should show 3 type icons + 1 overflow indicator
      expect(find.byType(Icon), findsNWidgets(3));
      expect(find.text('+2'), findsOneWidget);
    });

    testWidgets('renders nothing when markerTypes is empty', (tester) async {
      final cluster = MapCluster(
        id: 'test-cluster',
        position: const LatLng(0, 0),
        markerCount: 10,
        markerIds: List.generate(10, (i) => 'marker-$i'),
        markerTypes: const [],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ClusterTypeIcons(cluster: cluster),
          ),
        ),
      );

      expect(find.byType(SizedBox), findsOneWidget);
    });
  });

  group('MapClusterWithTypesWidget', () {
    testWidgets('renders cluster with type icons when showTypeIcons is true',
        (tester) async {
      final cluster = MapCluster(
        id: 'test-cluster',
        position: const LatLng(0, 0),
        markerCount: 15,
        markerIds: List.generate(15, (i) => 'marker-$i'),
        markerTypes: const [
          MarkerType.trip,
          MarkerType.activity,
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapClusterWithTypesWidget(
              cluster: cluster,
              showTypeIcons: true,
            ),
          ),
        ),
      );

      expect(find.byType(MapClusterWithTypesWidget), findsOneWidget);
      expect(find.byType(MapClusterWidget), findsOneWidget);
      expect(find.byType(ClusterTypeIcons), findsOneWidget);
    });

    testWidgets(
        'renders cluster without type icons when showTypeIcons is false',
        (tester) async {
      final cluster = MapCluster(
        id: 'test-cluster',
        position: const LatLng(0, 0),
        markerCount: 15,
        markerIds: List.generate(15, (i) => 'marker-$i'),
        markerTypes: const [
          MarkerType.trip,
          MarkerType.activity,
        ],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapClusterWithTypesWidget(
              cluster: cluster,
              showTypeIcons: false,
            ),
          ),
        ),
      );

      expect(find.byType(MapClusterWithTypesWidget), findsOneWidget);
      expect(find.byType(MapClusterWidget), findsOneWidget);
      expect(find.byType(ClusterTypeIcons), findsNothing);
    });

    testWidgets('calls onTap callback when tapped', (tester) async {
      bool tapped = false;
      final cluster = MapCluster(
        id: 'test-cluster',
        position: const LatLng(0, 0),
        markerCount: 15,
        markerIds: List.generate(15, (i) => 'marker-$i'),
        markerTypes: const [MarkerType.trip],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MapClusterWithTypesWidget(
              cluster: cluster,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(MapClusterWidget));
      expect(tapped, isTrue);
    });
  });

  group('Integration Tests', () {
    testWidgets('MapMarkerWidget with all marker types', (tester) async {
      const markerTypes = MarkerType.values;

      for (final type in markerTypes) {
        final marker = MapMarker(
          id: 'test-$type',
          position: const LatLng(0, 0),
          type: type,
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MapMarkerWidget(marker: marker),
            ),
          ),
        );

        expect(find.byType(MapMarkerWidget), findsOneWidget);
      }
    });

    testWidgets('MapClusterWidget with various cluster sizes', (tester) async {
      final clusterSizes = [5, 25, 100, 500, 1500];

      for (final size in clusterSizes) {
        final cluster = MapCluster(
          id: 'test-cluster-$size',
          position: const LatLng(0, 0),
          markerCount: size,
          markerIds: List.generate(size, (i) => 'marker-$i'),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: MapClusterWidget(cluster: cluster),
            ),
          ),
        );

        expect(find.byType(MapClusterWidget), findsOneWidget);
      }
    });

    testWidgets('Mixed markers and clusters', (tester) async {
      const marker = MapMarker(
        id: 'single-marker',
        position: LatLng(0, 0),
        type: MarkerType.trip,
      );

      final cluster = MapCluster(
        id: 'test-cluster',
        position: const LatLng(0, 0),
        markerCount: 25,
        markerIds: List.generate(25, (i) => 'marker-$i'),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Column(
              children: [
                const MapMarkerWidget(marker: marker),
                MapClusterWidget(cluster: cluster),
              ],
            ),
          ),
        ),
      );

      expect(find.byType(MapMarkerWidget), findsOneWidget);
      expect(find.byType(MapClusterWidget), findsOneWidget);
    });
  });

  group('Performance Tests', () {
    testWidgets('renders 50 marker widgets efficiently', (tester) async {
      final markers = List.generate(
        50,
        (i) => MapMarker(
          id: 'marker-$i',
          position: LatLng(37.7749 + i * 0.01, -122.4194 + i * 0.01),
          type: MarkerType.values[i % MarkerType.values.length],
        ),
      );

      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: markers.length,
              itemBuilder: (context, index) {
                return MapMarkerWidget(marker: markers[index]);
              },
            ),
          ),
        ),
      );

      stopwatch.stop();

      expect(find.byType(MapMarkerWidget), findsNWidgets(50));
      // Should render in less than 1 second
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    testWidgets('renders 30 cluster widgets efficiently', (tester) async {
      final clusters = List.generate(
        30,
        (i) => MapCluster(
          id: 'cluster-$i',
          position: const LatLng(37.7749 + i * 0.1, -122.4194 + i * 0.1),
          markerCount: (i + 1) * 10,
          markerIds: List.generate((i + 1) * 10, (j) => 'marker-$j'),
        ),
      );

      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
              ),
              itemCount: clusters.length,
              itemBuilder: (context, index) {
                return MapClusterWidget(cluster: clusters[index]);
              },
            ),
          ),
        ),
      );

      stopwatch.stop();

      expect(find.byType(MapClusterWidget), findsNWidgets(30));
      // Should render in less than 1 second
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
  });
}
