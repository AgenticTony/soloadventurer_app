import 'package:flutter_test/flutter_test.dart';
import 'package:latlong2/latlong.dart';
import 'package:soloadventurer/core/models/map_marker.dart';
import 'package:soloadventurer/core/services/map_marker_clustering_service.dart';

void main() {
  group('MapMarker', () {
    test('should create marker with required fields', () {
      const marker = MapMarker(
        id: 'marker-1',
        position: LatLng(37.7749, -122.4194),
        title: 'Test Marker',
      );

      expect(marker.id, 'marker-1');
      expect(marker.position.latitude, 37.7749);
      expect(marker.position.longitude, -122.4194);
      expect(marker.title, 'Test Marker');
    });

    test('should create marker from lat/lng values', () {
      final marker = MapMarker.fromLatLng(
        id: 'marker-1',
        latitude: 37.7749,
        longitude: -122.4194,
        title: 'San Francisco',
      );

      expect(marker.position.latitude, 37.7749);
      expect(marker.position.longitude, -122.4194);
      expect(marker.title, 'San Francisco');
    });

    test('should create marker from trip data', () {
      final marker = MapMarker.fromTrip(
        tripId: 'trip-123',
        title: 'Paris Trip',
        latitude: 48.8566,
        longitude: 2.3522,
        description: 'City of Lights',
        color: 0xFF2196F3,
      );

      expect(marker.id, 'trip-123');
      expect(marker.type, MarkerType.trip);
      expect(marker.title, 'Paris Trip');
      expect(marker.description, 'City of Lights');
      expect(marker.color, 0xFF2196F3);
    });

    test('should throw on invalid trip coordinates', () {
      expect(
        () => MapMarker.fromTrip(
          tripId: 'trip-1',
          title: 'Invalid Trip',
          latitude: null,
          longitude: null,
        ),
        throwsAssertionError,
      );
    });

    test('should create marker from activity data', () {
      final marker = MapMarker.fromActivity(
        activityId: 'activity-456',
        title: 'Museum Visit',
        latitude: 51.5074,
        longitude: -0.1278,
        description: 'British Museum',
      );

      expect(marker.id, 'activity-456');
      expect(marker.type, MarkerType.activity);
      expect(marker.title, 'Museum Visit');
    });

    test('should calculate distance between markers', () {
      const marker1 = MapMarker(
        id: 'marker-1',
        position: LatLng(37.7749, -122.4194),
      );

      const marker2 = MapMarker(
        id: 'marker-2',
        position: LatLng(37.7750, -122.4195),
      );

      final distance = marker1.distanceTo(marker2);

      // Distance should be approximately 15 meters
      expect(distance, greaterThan(10));
      expect(distance, lessThan(20));
    });

    test('should copy marker with modified fields', () {
      const marker = MapMarker(
        id: 'marker-1',
        position: LatLng(37.7749, -122.4194),
        title: 'Original Title',
      );

      final copied = marker.copyWith(title: 'Updated Title');

      expect(copied.id, marker.id);
      expect(copied.position, marker.position);
      expect(copied.title, 'Updated Title');
    });

    test('should implement equality correctly', () {
      const marker1 = MapMarker(
        id: 'marker-1',
        position: LatLng(37.7749, -122.4194),
        title: 'Test',
      );

      const marker2 = MapMarker(
        id: 'marker-1',
        position: LatLng(37.7749, -122.4194),
        title: 'Test',
      );

      const marker3 = MapMarker(
        id: 'marker-2',
        position: LatLng(37.7749, -122.4194),
        title: 'Test',
      );

      expect(marker1, equals(marker2));
      expect(marker1, isNot(equals(marker3)));
    });
  });

  group('MapCluster', () {
    late List<MapMarker> testMarkers;

    setUp(() {
      testMarkers = [
        const MapMarker(
          id: 'marker-1',
          position: LatLng(37.7749, -122.4194),
          type: MarkerType.trip,
        ),
        const MapMarker(
          id: 'marker-2',
          position: LatLng(37.7750, -122.4195),
          type: MarkerType.activity,
        ),
        const MapMarker(
          id: 'marker-3',
          position: LatLng(37.7751, -122.4196),
          type: MarkerType.photo,
        ),
      ];
    });

    test('should create cluster from markers', () {
      final cluster = MapCluster.fromMarkers(
        id: 'cluster-1',
        markers: testMarkers,
      );

      expect(cluster.id, 'cluster-1');
      expect(cluster.markerCount, 3);
      expect(cluster.markerIds, ['marker-1', 'marker-2', 'marker-3']);
      expect(cluster.markerTypes, contains(MarkerType.trip));
      expect(cluster.markerTypes, contains(MarkerType.activity));
      expect(cluster.markerTypes, contains(MarkerType.photo));
    });

    test('should throw on empty marker list', () {
      expect(
        () => MapCluster.fromMarkers(
          id: 'cluster-1',
          markers: const [],
        ),
        throwsAssertionError,
      );
    });

    test('should calculate cluster center correctly', () {
      final cluster = MapCluster.fromMarkers(
        id: 'cluster-1',
        markers: testMarkers,
      );

      // Center should be average of all positions
      const expectedLat = (37.7749 + 37.7750 + 37.7751) / 3;
      const expectedLng = (-122.4194 + -122.4195 + -122.4196) / 3;

      expect(
        cluster.position.latitude,
        closeTo(expectedLat, 0.0001),
      );
      expect(
        cluster.position.longitude,
        closeTo(expectedLng, 0.0001),
      );
    });

    test('should check if cluster contains marker type', () {
      final cluster = MapCluster.fromMarkers(
        id: 'cluster-1',
        markers: testMarkers,
      );

      expect(cluster.containsType(MarkerType.trip), true);
      expect(cluster.containsType(MarkerType.restaurant), false);
    });

    test('should count markers by type', () {
      final cluster = MapCluster.fromMarkers(
        id: 'cluster-1',
        markers: testMarkers,
      );

      expect(cluster.countByType(MarkerType.trip), 1);
      expect(cluster.countByType(MarkerType.activity), 1);
      expect(cluster.countByType(MarkerType.photo), 1);
      expect(cluster.countByType(MarkerType.restaurant), 0);
    });

    test('should implement equality correctly', () {
      final cluster1 = MapCluster.fromMarkers(
        id: 'cluster-1',
        markers: testMarkers,
      );

      final cluster2 = MapCluster.fromMarkers(
        id: 'cluster-1',
        markers: testMarkers,
      );

      final cluster3 = MapCluster.fromMarkers(
        id: 'cluster-2',
        markers: testMarkers,
      );

      expect(cluster1, equals(cluster2));
      expect(cluster1, isNot(equals(cluster3)));
    });
  });

  group('MapMarkerClusteringService', () {
    test('should cluster nearby markers with distance algorithm', () {
      final markers = [
        const MapMarker(
          id: 'marker-1',
          position: LatLng(37.7749, -122.4194),
        ),
        const MapMarker(
          id: 'marker-2',
          position: LatLng(37.7750, -122.4195), // ~15m away
        ),
        const MapMarker(
          id: 'marker-3',
          position: LatLng(37.8000, -122.4000), // Far away
        ),
      ];

      final service = MapMarkerClusteringService(
        const ClusteringParams(
          clusterRadius: 50, // 50 meters
          minClusterSize: 2,
        ),
      );

      final result = service.clusterMarkers(markers);

      expect(result.totalMarkers, 3);
      expect(result.clusters.length, 1); // One cluster with 2 markers
      expect(result.unclusteredMarkers.length, 1); // One single marker
      expect(result.clusters.first.markerCount, 2);
    });

    test('should use grid-based clustering when specified', () {
      final markers = List.generate(
        100,
        (i) => MapMarker(
          id: 'marker-$i',
          position: LatLng(
            37.7 + (i % 10) * 0.001,
            -122.4 + (i ~/ 10) * 0.001,
          ),
        ),
      );

      final service = MapMarkerClusteringService(
        const ClusteringParams(
          algorithm: ClusteringAlgorithm.grid,
          gridCellSize: 100,
          minClusterSize: 2,
        ),
      );

      final result = service.clusterMarkers(markers);

      expect(result.totalMarkers, 100);
      expect(result.algorithm, ClusteringAlgorithm.grid);
      expect(result.efficiency, greaterThan(0.5)); // At least 50% reduction
    });

    test('should handle empty marker list', () {
      final service = MapMarkerClusteringService();
      final result = service.clusterMarkers([]);

      expect(result.totalMarkers, 0);
      expect(result.clusters.isEmpty, true);
      expect(result.unclusteredMarkers.isEmpty, true);
      expect(result.efficiency, 0.0);
    });

    test('should not cluster if markers are too far apart', () {
      final markers = [
        const MapMarker(
          id: 'marker-1',
          position: LatLng(37.7749, -122.4194),
        ),
        const MapMarker(
          id: 'marker-2',
          position: LatLng(37.9000, -122.5000), // Very far
        ),
      ];

      final service = MapMarkerClusteringService(
        const ClusteringParams(
          clusterRadius: 50,
          minClusterSize: 2,
        ),
      );

      final result = service.clusterMarkers(markers);

      expect(result.clusters.length, 0);
      expect(result.unclusteredMarkers.length, 2);
    });

    test('should respect max cluster size', () {
      // Create many markers at the same location
      final markers = List.generate(
        150,
        (i) => MapMarker(
          id: 'marker-$i',
          position: const LatLng(37.7749, -122.4194),
        ),
      );

      final service = MapMarkerClusteringService(
        const ClusteringParams(
          clusterRadius: 50,
          minClusterSize: 2,
          maxClusterSize: 100,
        ),
      );

      final result = service.clusterMarkers(markers);

      // Should have multiple clusters to respect max size
      final totalInClusters =
          result.clusters.fold<int>(0, (sum, c) => sum + c.markerCount);

      expect(totalInClusters + result.unclusteredMarkers.length, 150);

      for (final cluster in result.clusters) {
        expect(cluster.markerCount, lessThanOrEqualTo(100));
      }
    });

    test('should calculate clustering efficiency correctly', () {
      final markers = List.generate(
        100,
        (i) => MapMarker(
          id: 'marker-$i',
          position: LatLng(37.7 + i * 0.0001, -122.4 + i * 0.0001),
        ),
      );

      final service = MapMarkerClusteringService();
      final result = service.clusterMarkers(markers);

      final renderedCount =
          result.clusters.length + result.unclusteredMarkers.length;
      final expectedEfficiency = 1.0 - (renderedCount / markers.length);

      expect(result.efficiency, closeTo(expectedEfficiency, 0.01));
      expect(result.efficiency, greaterThan(0)); // Should have some efficiency
    });

    test('should generate correct statistics', () {
      final markers = List.generate(
        50,
        (i) => MapMarker(
          id: 'marker-$i',
          position: LatLng(37.7 + (i % 5) * 0.0001, -122.4 + (i ~/ 5) * 0.0001),
        ),
      );

      final service = MapMarkerClusteringService();
      final result = service.clusterMarkers(markers);

      final stats = result.statistics;

      expect(stats['totalMarkers'], 50);
      expect(stats['clusters'], result.clusters.length);
      expect(stats['unclusteredMarkers'], result.unclusteredMarkers.length);
      expect(stats['efficiency'], result.efficiency);
      expect(stats.containsKey('avgClusterSize'), true);
      expect(stats.containsKey('maxClusterSize'), true);
    });

    test('should cluster only markers within bounds', () {
      final markers = [
        const MapMarker(
          id: 'marker-1',
          position: LatLng(37.7749, -122.4194), // In bounds
        ),
        const MapMarker(
          id: 'marker-2',
          position: LatLng(37.7750, -122.4195), // In bounds
        ),
        const MapMarker(
          id: 'marker-3',
          position: LatLng(40.7128, -74.0060), // New York (out of bounds)
        ),
      ];

      final service = MapMarkerClusteringService();

      final bounds = LatLngBounds(
        southwest: const LatLng(37.7, -122.5),
        northeast: const LatLng(37.8, -122.3),
      );

      final result = service.clusterMarkersInBounds(markers, bounds);

      // Should only process markers within bounds
      expect(result.totalMarkers, 2);
      expect(result.clusters.length + result.unclusteredMarkers.length,
          lessThanOrEqualTo(2));
    });

    test('should update parameters correctly', () {
      final service = MapMarkerClusteringService();

      expect(service.params.clusterRadius, 80);

      service.updateParams(const ClusteringParams(clusterRadius: 100));

      expect(service.params.clusterRadius, 100);
    });

    test('should create params for different zoom levels', () {
      final veryZoomedIn = ClusteringParams.forZoomLevel(16);
      expect(veryZoomedIn.clusterRadius, lessThan(50));

      final moderateZoom = ClusteringParams.forZoomLevel(12);
      expect(moderateZoom.clusterRadius, greaterThan(40));
      expect(moderateZoom.clusterRadius, lessThan(80));

      final zoomedOut = ClusteringParams.forZoomLevel(8);
      expect(zoomedOut.clusterRadius, greaterThan(80));
    });

    test('should handle incremental clustering', () {
      final service = MapMarkerClusteringService();

      // Initial markers
      final initialMarkers = [
        const MapMarker(
          id: 'marker-1',
          position: LatLng(37.7749, -122.4194),
        ),
        const MapMarker(
          id: 'marker-2',
          position: LatLng(37.7750, -122.4195),
        ),
      ];

      final previousResult = service.clusterMarkers(initialMarkers);

      // Add new marker near existing cluster
      final newMarkers = [
        const MapMarker(
          id: 'marker-3',
          position: LatLng(37.7751, -122.4196),
        ),
      ];

      final updatedResult = service.incrementalCluster(
        initialMarkers,
        newMarkers,
        previousResult,
      );

      expect(updatedResult.totalMarkers, 3);
      expect(
        updatedResult.clusters.length + updatedResult.unclusteredMarkers.length,
        lessThanOrEqualTo(3),
      );
    });

    test('should use weighted center when enabled', () {
      final markers = [
        const MapMarker(
          id: 'marker-1',
          position: LatLng(37.7749, -122.4194),
          type: MarkerType.trip, // Higher weight
        ),
        const MapMarker(
          id: 'marker-2',
          position: LatLng(37.7750, -122.4195),
          type: MarkerType.photo, // Lower weight
        ),
      ];

      final clusterWeighted = MapCluster.fromMarkers(
        id: 'cluster-1',
        markers: markers,
        useWeightedCenter: true,
      );

      final clusterUnweighted = MapCluster.fromMarkers(
        id: 'cluster-2',
        markers: markers,
        useWeightedCenter: false,
      );

      // Weighted center should be closer to the trip marker
      expect(clusterWeighted.weightedPosition, isNotNull);
      expect(clusterUnweighted.weightedPosition, isNull);
    });
  });

  group('ClusteringParams', () {
    test('should create default params', () {
      const params = ClusteringParams();

      expect(params.clusterRadius, 80);
      expect(params.minClusterSize, 2);
      expect(params.maxClusterSize, 100);
      expect(params.useWeightedCenter, true);
      expect(params.algorithm, ClusteringAlgorithm.distance);
    });

    test('should create high-density params', () {
      const params = ClusteringParams.highDensity();

      expect(params.clusterRadius, 50);
      expect(params.minClusterSize, 3);
      expect(params.maxClusterSize, 150);
      expect(params.algorithm, ClusteringAlgorithm.grid);
    });

    test('should create low-density params', () {
      const params = ClusteringParams.lowDensity();

      expect(params.clusterRadius, 120);
      expect(params.minClusterSize, 2);
      expect(params.maxClusterSize, 50);
      expect(params.algorithm, ClusteringAlgorithm.distance);
    });

    test('should create zoom-appropriate params', () {
      final params15 = ClusteringParams.forZoomLevel(15);
      expect(params15.clusterRadius, lessThan(50));

      final params12 = ClusteringParams.forZoomLevel(12);
      expect(params12.clusterRadius, greaterThan(40));
      expect(params12.clusterRadius, lessThan(80));

      final params9 = ClusteringParams.forZoomLevel(9);
      expect(params9.clusterRadius, greaterThan(80));

      final params5 = ClusteringParams.forZoomLevel(5);
      expect(params5.clusterRadius, greaterThan(100));
    });
  });
}
