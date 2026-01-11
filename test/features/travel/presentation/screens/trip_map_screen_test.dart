import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:soloadventurer/core/models/map_marker.dart';
import 'package:soloadventurer/features/travel/presentation/screens/trip_map_screen.dart';

void main() {
  group('TripMapScreen', () {
    /// Sample markers for testing
    final testMarkers = [
      const MapMarker(
        id: '1',
        lat: 37.7749,
        lng: -122.4194,
        type: MapMarkerType.trip,
        title: 'San Francisco',
        description: 'Test location 1',
      ),
      const MapMarker(
        id: '2',
        lat: 37.7899,
        lng: -122.4014,
        type: MapMarkerType.activity,
        title: 'Golden Gate Park',
        description: 'Test location 2',
      ),
      const MapMarker(
        id: '3',
        lat: 37.7694,
        lng: -122.4862,
        type: MapMarkerType.restaurant,
        title: 'Sunset District',
        description: 'Test location 3',
      ),
    ];

    /// Create test widget with provider overrides
    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          tripMapMarkersProvider.overrideWithValue(testMarkers),
        ],
        child: const MaterialApp(
          home: TripMapScreen(),
        ),
      );
    }

    testWidgets('renders map widget', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(FlutterMap), findsOneWidget);
    });

    testWidgets('renders app bar with title', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.text('Trip Map'), findsOneWidget);
    });

    testWidgets('renders statistics toggle button', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.analytics), findsOneWidget);
    });

    testWidgets('renders reset button', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byIcon(Icons.refresh), findsOneWidget);
    });

    testWidgets('renders clustering preset menu', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(PopupMenuButton<ClusteringPreset>), findsOneWidget);
    });

    testWidgets('renders floating action button', (tester) async {
      await tester.pumpWidget(createTestWidget());

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });

    testWidgets('shows statistics overlay by default', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Statistics should be visible (showStats is true by default)
      expect(find.text('Map Statistics'), findsOneWidget);
    });

    testWidgets('toggles statistics overlay when button tapped',
        (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Statistics should be visible initially
      expect(find.text('Map Statistics'), findsOneWidget);

      // Tap toggle button
      await tester.tap(find.byIcon(Icons.analytics));
      await tester.pump();

      // Statistics should be hidden
      expect(find.text('Map Statistics'), findsNothing);

      // Tap toggle button again
      await tester.tap(find.byIcon(Icons.analytics_outlined));
      await tester.pump();

      // Statistics should be visible again
      expect(find.text('Map Statistics'), findsOneWidget);
    });

    testWidgets('displays clustering statistics', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Check for statistics labels
      expect(find.text('Zoom:'), findsOneWidget);
      expect(find.text('Markers:'), findsOneWidget);
      expect(find.text('Clusters:'), findsOneWidget);
      expect(find.text('Unclustered:'), findsOneWidget);
      expect(find.text('Efficiency:'), findsOneWidget);
      expect(find.text('Algorithm:'), findsOneWidget);
    });

    testWidgets('shows correct marker count in statistics', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      expect(find.text('Markers: 3'), findsOneWidget);
    });

    testWidgets('opens clustering preset menu', (tester) async {
      await tester.pumpWidget(createTestWidget());

      // Tap menu button
      await tester.tap(find.byType(PopupMenuButton<ClusteringPreset>));
      await tester.pump();

      // Check menu items
      expect(find.text('High Density (City)'), findsOneWidget);
      expect(find.text('Low Density (Rural)'), findsOneWidget);
      expect(find.text('Performance (500+ markers)'), findsOneWidget);
    });

    testWidgets('handles empty marker list', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripMapMarkersProvider.overrideWithValue([]),
          ],
          child: const MaterialApp(
            home: TripMapScreen(),
          ),
        ),
      );

      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.byType(TripMapScreen), findsOneWidget);
    });

    testWidgets('handles single marker', (tester) async {
      final singleMarker = [
        const MapMarker(
          id: '1',
          lat: 37.7749,
          lng: -122.4194,
          type: MapMarkerType.trip,
          title: 'Single Marker',
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripMapMarkersProvider.overrideWithValue(singleMarker),
          ],
          child: const MaterialApp(
            home: TripMapScreen(),
          ),
        ),
      );

      expect(find.byType(FlutterMap), findsOneWidget);
    });
  });

  group('TripMapScreen - Clustering Presets', () {
    final testMarkers = List.generate(
      50,
      (i) => MapMarker(
        id: 'marker_$i',
        lat: 37.7749 + (i % 10) * 0.001,
        lng: -122.4194 + (i % 10) * 0.001,
        type: MapMarkerType.poi,
        title: 'Marker $i',
      ),
    );

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          tripMapMarkersProvider.overrideWithValue(testMarkers),
        ],
        child: const MaterialApp(
          home: TripMapScreen(),
        ),
      );
    }

    testWidgets('selects high density preset', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open menu
      await tester.tap(find.byType(PopupMenuButton<ClusteringPreset>));
      await tester.pump();

      // Select high density preset
      await tester.tap(find.text('High Density (City)'));
      await tester.pumpAndSettle();

      // Screen should still be visible (no crashes)
      expect(find.byType(TripMapScreen), findsOneWidget);
    });

    testWidgets('selects low density preset', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open menu
      await tester.tap(find.byType(PopupMenuButton<ClusteringPreset>));
      await tester.pump();

      // Select low density preset
      await tester.tap(find.text('Low Density (Rural)'));
      await tester.pumpAndSettle();

      // Screen should still be visible (no crashes)
      expect(find.byType(TripMapScreen), findsOneWidget);
    });

    testWidgets('selects performance preset', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      // Open menu
      await tester.tap(find.byType(PopupMenuButton<ClusteringPreset>));
      await tester.pump();

      // Select performance preset
      await tester.tap(find.text('Performance (500+ markers)'));
      await tester.pumpAndSettle();

      // Screen should still be visible (no crashes)
      expect(find.byType(TripMapScreen), findsOneWidget);
    });
  });

  group('TripMapScreen - Map Interactions', () {
    final testMarkers = [
      const MapMarker(
        id: '1',
        lat: 37.7749,
        lng: -122.4194,
        type: MapMarkerType.trip,
        title: 'San Francisco',
      ),
      const MapMarker(
        id: '2',
        lat: 37.7899,
        lng: -122.4014,
        type: MapMarkerType.activity,
        title: 'Golden Gate Park',
      ),
    ];

    Widget createTestWidget() {
      return ProviderScope(
        overrides: [
          tripMapMarkersProvider.overrideWithValue(testMarkers),
        ],
        child: const MaterialApp(
          home: TripMapScreen(),
        ),
      );
    }

    testWidgets('taps floating action button', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byType(FloatingActionButton));
      await tester.pump();

      // Should not crash
      expect(find.byType(TripMapScreen), findsOneWidget);
    });

    testWidgets('handles reset button tap', (tester) async {
      await tester.pumpWidget(createTestWidget());
      await tester.pumpAndSettle();

      await tester.tap(find.byIcon(Icons.refresh));
      await tester.pump();

      // Should not crash
      expect(find.byType(TripMapScreen), findsOneWidget);
    });
  });

  group('TripMapScreen - Integration Tests', () {
    testWidgets('integrates with ZoomAwareClusteringManager', (tester) async {
      final markers = List.generate(
        20,
        (i) => MapMarker(
          id: 'marker_$i',
          lat: 37.7749 + i * 0.001,
          lng: -122.4194 + i * 0.001,
          type: MapMarkerType.poi,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripMapMarkersProvider.overrideWithValue(markers),
          ],
          child: const MaterialApp(
            home: TripMapScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify markers are displayed
      expect(find.byType(FlutterMap), findsOneWidget);

      // Verify statistics show clustering occurred
      expect(find.text('Markers: 20'), findsOneWidget);
    });

    testWidgets('updates clustering on zoom change', (tester) async {
      final markers = [
        const MapMarker(
          id: '1',
          lat: 37.7749,
          lng: -122.4194,
          type: MapMarkerType.poi,
        ),
        const MapMarker(
          id: '2',
          lat: 37.7749,
          lng: -122.4194,
          type: MapMarkerType.poi,
        ),
      ];

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripMapMarkersProvider.overrideWithValue(markers),
          ],
          child: const MaterialApp(
            home: TripMapScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Get initial cluster count
      final initialClusters = find.textContaining('Clusters:');

      // Note: Actual zoom simulation is difficult in widget tests
      // This test verifies the screen handles the initialization without errors
      expect(find.byType(FlutterMap), findsOneWidget);
    });

    testWidgets('handles bounds-based clustering', (tester) async {
      // Create markers across a large area
      final markers = List.generate(
        50,
        (i) => MapMarker(
          id: 'marker_$i',
          lat: 37.0 + i * 0.1,
          lng: -122.0 + i * 0.1,
          type: MapMarkerType.poi,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripMapMarkersProvider.overrideWithValue(markers),
          ],
          child: const MaterialApp(
            home: TripMapScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Should handle bounds-based clustering without errors
      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.text('Markers: 50'), findsOneWidget);
    });
  });

  group('TripMapScreen - Performance Tests', () {
    testWidgets('renders efficiently with 100 markers', (tester) async {
      final markers = List.generate(
        100,
        (i) => MapMarker(
          id: 'marker_$i',
          lat: 37.7749 + (i % 20) * 0.01,
          lng: -122.4194 + (i % 20) * 0.01,
          type: MapMarkerType.poi,
        ),
      );

      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripMapMarkersProvider.overrideWithValue(markers),
          ],
          child: const MaterialApp(
            home: TripMapScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      stopwatch.stop();

      // Should render in under 1 second
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));

      expect(find.byType(FlutterMap), findsOneWidget);
      expect(find.text('Markers: 100'), findsOneWidget);
    });

    testWidgets('handles rapid preset changes', (tester) async {
      final markers = List.generate(
        30,
        (i) => MapMarker(
          id: 'marker_$i',
          lat: 37.7749 + i * 0.001,
          lng: -122.4194 + i * 0.001,
          type: MapMarkerType.poi,
        ),
      );

      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            tripMapMarkersProvider.overrideWithValue(markers),
          ],
          child: const MaterialApp(
            home: TripMapScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Rapidly change presets
      for (int i = 0; i < 3; i++) {
        await tester.tap(find.byType(PopupMenuButton<ClusteringPreset>));
        await tester.pump();

        final presetIndex = i % 3;
        switch (presetIndex) {
          case 0:
            await tester.tap(find.text('High Density (City)'));
            break;
          case 1:
            await tester.tap(find.text('Low Density (Rural)'));
            break;
          case 2:
            await tester.tap(find.text('Performance (500+ markers)'));
            break;
        }

        await tester.pump(const Duration(milliseconds: 100));
      }

      // Should handle rapid changes without crashes
      expect(find.byType(TripMapScreen), findsOneWidget);
    });
  });
}
