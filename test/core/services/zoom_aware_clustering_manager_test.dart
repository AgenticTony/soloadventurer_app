import 'package:flutter_map/flutter_map.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:soloadventurer/core/models/map_marker.dart';
import 'package:soloadventurer/core/services/map_marker_clustering_service.dart';
import 'package:soloadventurer/core/services/zoom_aware_clustering_manager.dart';

void main() {
  group('ZoomAwareClusteringManager', () {
    test('should initialize with default parameters', () {
      final markers = [
        const MapMarker(
          id: 'marker-1',
          position: LatLng(37.7749, -122.4194),
        ),
      ];

      final manager = ZoomAwareClusteringManager(
        markers: markers,
        initialZoom: 12.0,
      );

      expect(manager.currentZoom, 12.0);
      expect(manager.currentResult, isNull);
    });

    test('should perform initial clustering', () async {
      final markers = List.generate(
        20,
        (i) => MapMarker(
          id: 'marker-$i',
          position: LatLng(37.7749 + i * 0.001, -122.4194),
        ),
      );

      final manager = ZoomAwareClusteringManager(
        markers: markers,
        initialZoom: 12.0,
      );

      final result = await manager.initialize();

      expect(result.clusters.length + result.unclusteredMarkers.length,
          greaterThan(0));
      expect(manager.currentResult, isNotNull);
    });

    test('should update clustering parameters when zoom changes', () async {
      final markers = List.generate(
        50,
        (i) => MapMarker(
          id: 'marker-$i',
          position: LatLng(37.7749 + i * 0.0005, -122.4194),
        ),
      );

      final manager = ZoomAwareClusteringManager(
        markers: markers,
        initialZoom: 10.0,
      );

      await manager.initialize();

      // Get params at zoom 10
      final paramsZoom10 = manager.currentParams;
      expect(paramsZoom10.clusterRadius, 100);

      // Update to zoom 15
      manager.updateZoomLevel(15.0);
      await manager.waitForClusterUpdate();

      // Wait for debounce to complete
      await Future.delayed(const Duration(milliseconds: 400));

      // Get params at zoom 15
      final paramsZoom15 = manager.currentParams;
      expect(paramsZoom15.clusterRadius, 30);
    });

    test('should produce different clusters at different zoom levels',
        () async {
      final markers = List.generate(
        100,
        (i) => MapMarker(
          id: 'marker-$i',
          position: LatLng(
              37.7749 + (i % 20) * 0.0005, -122.4194 + (i ~/ 20) * 0.0005),
        ),
      );

      final manager = ZoomAwareClusteringManager(
        markers: markers,
        initialZoom: 5.0, // Very zoomed out
      );

      // Cluster at zoom 5
      await manager.initialize();
      final resultZoom5 = manager.currentResult!;

      // Zoom in to 15
      manager.updateZoomLevel(15.0);
      await manager.waitForClusterUpdate();
      final resultZoom15 = manager.currentResult!;

      // Zoomed out should have clusters, zoomed in should have fewer clusters or more individual markers
      expect(resultZoom5.unclusteredMarkers.length,
          lessThanOrEqualTo(resultZoom15.unclusteredMarkers.length));

      // Zoomed out should have higher efficiency
      expect(resultZoom5.efficiency,
          greaterThanOrEqualTo(resultZoom15.efficiency));
    });

    test('should debounce re-clustering', () async {
      final markers = List.generate(
        50,
        (i) => MapMarker(
          id: 'marker-$i',
          position: LatLng(37.7749 + i * 0.001, -122.4194),
        ),
      );

      final manager = ZoomAwareClusteringManager(
        markers: markers,
        initialZoom: 12.0,
        debounceDelayMs: 100, // Short delay for testing
      );

      await manager.initialize();

      // Rapid zoom changes
      manager.updateZoomLevel(13.0);
      manager.updateZoomLevel(14.0);
      manager.updateZoomLevel(15.0);

      // Wait for debounce
      await Future.delayed(const Duration(milliseconds: 150));

      // Should only re-cluster once at final zoom level
      expect(manager.currentZoom, 15.0);
      expect(manager.currentParams.clusterRadius, 30); // Params for zoom 15
    });

    test('should support bounds-based clustering', () async {
      final markers = [
        // San Francisco markers
        ...List.generate(
          10,
          (i) => MapMarker(
            id: 'sf-$i',
            position: LatLng(37.7749 + i * 0.001, -122.4194),
          ),
        ),
        // New York markers (far away)
        ...List.generate(
          10,
          (i) => MapMarker(
            id: 'ny-$i',
            position: LatLng(40.7128 + i * 0.001, -74.0060),
          ),
        ),
      ];

      final manager = ZoomAwareClusteringManager(
        markers: markers,
        initialZoom: 12.0,
        useLatLngBoundsBasedClustering: true,
      );

      await manager.initialize();

      // Set bounds to only include San Francisco
      final sfBounds = LatLngBounds(
        const LatLng(37.4, -122.5),
        const LatLng(37.8, -122.0),
      );

      manager.updateMapLatLngBounds(sfBounds);
      await manager.waitForClusterUpdate();

      final result = manager.currentResult!;
      final allMarkerIds = [
        ...result.clusters.expand((c) => c.markerIds),
        ...result.unclusteredMarkers.map((m) => m.id),
      ];

      // Should only include SF markers
      expect(allMarkerIds, isNot(anyElement(matches(r'^ny-'))));
      expect(allMarkerIds, anyElement(matches(r'^sf-')));
    });

    test('should update markers and re-cluster', () async {
      final manager = ZoomAwareClusteringManager(
        markers: [],
        initialZoom: 12.0,
      );

      await manager.initialize();

      // Add markers
      final markers = List.generate(
        20,
        (i) => MapMarker(
          id: 'marker-$i',
          position: LatLng(37.7749 + i * 0.001, -122.4194),
        ),
      );

      manager.updateMarkers(markers, forceRecluster: true);

      expect(manager.currentResult, isNotNull);
      expect(manager.currentResult!.totalMarkers, 20);
    });

    test('should add markers incrementally', () async {
      final initialMarkers = List.generate(
        10,
        (i) => MapMarker(
          id: 'marker-$i',
          position: LatLng(37.7749 + i * 0.001, -122.4194),
        ),
      );

      final manager = ZoomAwareClusteringManager(
        markers: initialMarkers,
        initialZoom: 12.0,
      );

      await manager.initialize();

// ignore: unused_local_variable
      final initialClusterCount = manager.currentResult!.clusters.length;

      // Add more markers
      final newMarkers = List.generate(
        5,
        (i) => MapMarker(
          id: 'new-marker-$i',
          position: LatLng(37.7749 + i * 0.0005, -122.4195),
        ),
      );

      manager.addMarkers(newMarkers);
      await Future.delayed(const Duration(milliseconds: 50));

      expect(manager.currentResult!.totalMarkers, 15);
    });

    test('should remove markers', () async {
      final markers = List.generate(
        20,
        (i) => MapMarker(
          id: 'marker-$i',
          position: LatLng(37.7749 + i * 0.001, -122.4194),
        ),
      );

      final manager = ZoomAwareClusteringManager(
        markers: markers,
        initialZoom: 12.0,
      );

      await manager.initialize();

      // Remove some markers
      manager.removeMarkers(['marker-0', 'marker-1', 'marker-2']);

      expect(manager.currentResult!.totalMarkers, 17);
    });

    test('should emit clustering results on stream', () async {
      final markers = List.generate(
        20,
        (i) => MapMarker(
          id: 'marker-$i',
          position: LatLng(37.7749 + i * 0.001, -122.4194),
        ),
      );

      final manager = ZoomAwareClusteringManager(
        markers: markers,
        initialZoom: 12.0,
      );

      final results = <ClusteringResult>[];
      final subscription = manager.resultStream.listen(results.add);

      await manager.initialize();
      manager.updateZoomLevel(15.0);
      await manager.waitForClusterUpdate();

      // Should receive initial clustering + zoom update
      expect(results.length, greaterThanOrEqualTo(2));

      await subscription.cancel();
    });

    test('should maintain history for undo', () async {
      final markers = List.generate(
        30,
        (i) => MapMarker(
          id: 'marker-$i',
          position: LatLng(37.7749 + i * 0.001, -122.4194),
        ),
      );

      final manager = ZoomAwareClusteringManager(
        markers: markers,
        initialZoom: 12.0,
        maxHistorySize: 5,
      );

      await manager.initialize();

      // Make several zoom changes
      manager.updateZoomLevel(13.0);
      await manager.waitForClusterUpdate();

      manager.updateZoomLevel(14.0);
      await manager.waitForClusterUpdate();

      manager.updateZoomLevel(15.0);
      await manager.waitForClusterUpdate();

      final stats = manager.statistics;
      expect(stats['historySize'], greaterThan(0));
      expect(stats['historySize'], lessThanOrEqualTo(5));
    });

    test('should provide statistics', () async {
      final markers = List.generate(
        50,
        (i) => MapMarker(
          id: 'marker-$i',
          position: LatLng(37.7749 + i * 0.0005, -122.4194),
        ),
      );

      final manager = ZoomAwareClusteringManager(
        markers: markers,
        initialZoom: 12.0,
      );

      await manager.initialize();

      final stats = manager.statistics;

      expect(stats['currentZoom'], 12.0);
      expect(stats['totalMarkers'], 50);
      expect(stats['clusters'], isNotNull);
      expect(stats['efficiency'], isNotNull);
      expect(stats['algorithm'], 'distance'); // Default for zoom 12
      expect(stats['usingLatLngBoundsBasedClustering'], false);
    });

    test('should create high-density configuration', () {
      final markers = [
        const MapMarker(id: '1', position: LatLng(37.7749, -122.4194)),
      ];

      final manager = ClusteringManagerFactories.forHighDensity(
        markers: markers,
        initialZoom: 14.0,
        useLatLngBoundsBasedClustering: true,
      );

      expect(manager.currentParams.clusterRadius, 50);
      expect(manager.currentParams.minClusterSize, 3);
    });

    test('should create low-density configuration', () {
      final markers = [
        const MapMarker(id: '1', position: LatLng(37.7749, -122.4194)),
      ];

      final manager = ClusteringManagerFactories.forLowDensity(
        markers: markers,
        initialZoom: 10.0,
      );

      expect(manager.currentParams.clusterRadius, 120);
      expect(manager.currentParams.minClusterSize, 2);
    });

    test('should create performance-optimized configuration', () {
      final markers = [
        const MapMarker(id: '1', position: LatLng(37.7749, -122.4194)),
      ];

      final manager = ClusteringManagerFactories.forPerformance(
        markers: markers,
        initialZoom: 10.0,
      );

      expect(manager.currentParams.algorithm, ClusteringAlgorithm.grid);
    });

    test('should handle empty marker list', () async {
      final manager = ZoomAwareClusteringManager(
        markers: [],
        initialZoom: 12.0,
      );

      final result = await manager.initialize();

      expect(result.clusters.isEmpty, true);
      expect(result.unclusteredMarkers.isEmpty, true);
      expect(result.totalMarkers, 0);
    });

    test('should not re-cluster when zoom does not change', () async {
      final markers = List.generate(
        20,
        (i) => MapMarker(
          id: 'marker-$i',
          position: LatLng(37.7749 + i * 0.001, -122.4194),
        ),
      );

      final manager = ZoomAwareClusteringManager(
        markers: markers,
        initialZoom: 12.0,
      );

      await manager.initialize();
      final initialResult = manager.currentResult;

      // Update to same zoom level
      manager.updateZoomLevel(12.0);
      await manager.waitForClusterUpdate();

      // Result should be the same
      expect(manager.currentResult, same(initialResult));
    });

    test('should force re-cluster when requested', () async {
      final markers = List.generate(
        20,
        (i) => MapMarker(
          id: 'marker-$i',
          position: LatLng(37.7749 + i * 0.001, -122.4194),
        ),
      );

      final manager = ZoomAwareClusteringManager(
        markers: markers,
        initialZoom: 12.0,
      );

      await manager.initialize();

      // Force re-cluster at same zoom
      manager.updateZoomLevel(12.0, force: true);
      await manager.waitForClusterUpdate();

      // Should still re-cluster
      expect(manager.currentResult, isNotNull);
    });

    test('should handle rapid zoom changes efficiently', () async {
      final markers = List.generate(
        100,
        (i) => MapMarker(
          id: 'marker-$i',
          position: LatLng(
              37.7749 + (i % 20) * 0.0005, -122.4194 + (i ~/ 20) * 0.0005),
        ),
      );

      final manager = ZoomAwareClusteringManager(
        markers: markers,
        initialZoom: 10.0,
        debounceDelayMs: 50, // Very short delay
      );

      await manager.initialize();

      final stopwatch = Stopwatch()..start();

      // Simulate rapid zoom changes
      for (double zoom = 10.0; zoom <= 15.0; zoom += 0.5) {
        manager.updateZoomLevel(zoom);
      }

      // Wait for final clustering
      await manager.waitForClusterUpdate();
      stopwatch.stop();

      // Should complete quickly (debouncing prevents excessive work)
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    test('should dispose properly', () {
      final markers = [
        const MapMarker(id: '1', position: LatLng(37.7749, -122.4194)),
      ];

      final manager = ZoomAwareClusteringManager(
        markers: markers,
        initialZoom: 12.0,
      );

      // Should not throw
      expect(() => manager.dispose(), returnsNormally);
    });
  });

  group('ZoomAwareClusteringManager Integration', () {
    test('should work with real-world scenario', () async {
      // Simulate San Francisco tourist attractions
      final markers = [
        // Golden Gate Park area
        ...List.generate(
          20,
          (i) => MapMarker(
            id: 'ggp-$i',
            position: LatLng(37.7694 + i * 0.0002, -122.4862),
            type: MarkerType.poi,
          ),
        ),
        // Fisherman's Wharf area
        ...List.generate(
          15,
          (i) => MapMarker(
            id: 'fw-$i',
            position: LatLng(37.8080 + i * 0.0002, -122.4177),
            type: MarkerType.poi,
          ),
        ),
        // Union Square area
        ...List.generate(
          10,
          (i) => MapMarker(
            id: 'us-$i',
            position: LatLng(37.7879 + i * 0.0002, -122.4074),
            type: MarkerType.poi,
          ),
        ),
      ];

      final manager = ZoomAwareClusteringManager(
        markers: markers,
        initialZoom: 12.0,
        useLatLngBoundsBasedClustering: true,
      );

      await manager.initialize();

      // Zoom out - should see fewer, larger clusters
      manager.updateZoomLevel(10.0);
      await manager.waitForClusterUpdate();
      final resultZoom10 = manager.currentResult!;

      // Zoom in - should see more clusters and individual markers
      manager.updateZoomLevel(15.0);
      await manager.waitForClusterUpdate();
      final resultZoom15 = manager.currentResult!;

      // Zoomed out should have higher clustering efficiency
      expect(resultZoom10.efficiency, greaterThan(resultZoom15.efficiency));

      // Both should show all markers
      expect(resultZoom10.totalMarkers, 45);
      expect(resultZoom15.totalMarkers, 45);
    });
  });
}
