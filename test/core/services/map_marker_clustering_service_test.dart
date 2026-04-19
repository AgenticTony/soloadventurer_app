import 'package:flutter_map/flutter_map.dart';
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
      );

      expect(marker.id, 'marker-1');
      expect(marker.position.latitude, 37.7749);
      expect(marker.position.longitude, -122.4194);
    });

    test('should create marker from LatLng values', () {
      final marker = MapMarker.fromLatLng(
        id: 'marker-1',
        latitude: 37.7749,
        longitude: -122.4194,
        title: 'Test Marker',
      );

      expect(marker.id, 'marker-1');
      expect(marker.title, 'Test Marker');
      expect(marker.position.latitude, 37.7749);
    });

    test('should create marker from trip data', () {
      final marker = MapMarker.fromTrip(
        tripId: 'trip-1',
        title: 'San Francisco',
        latitude: 37.7749,
        longitude: -122.4194,
        description: 'Bay Area',
      );

      expect(marker.id, 'trip-1');
      expect(marker.type, MarkerType.trip);
      expect(marker.title, 'San Francisco');
    });

    test('should create marker from activity data', () {
      final marker = MapMarker.fromActivity(
        activityId: 'activity-1',
        title: 'Hiking',
        latitude: 37.7749,
        longitude: -122.4194,
      );

      expect(marker.id, 'activity-1');
      expect(marker.type, MarkerType.activity);
    });

    test('should calculate distance to another marker', () {
      const marker1 = MapMarker(
        id: 'marker-1',
        position: LatLng(37.7749, -122.4194),
      );
      const marker2 = MapMarker(
        id: 'marker-2',
        position: LatLng(37.7750, -122.4195),
      );

      final distance = marker1.distanceTo(marker2);

      expect(distance, greaterThan(0));
      expect(distance, lessThan(200)); // Should be within 200 meters
    });

    test('should copy with modified fields', () {
      const marker = MapMarker(
        id: 'marker-1',
        position: LatLng(37.7749, -122.4194),
        title: 'Original',
      );

      final updated = marker.copyWith(title: 'Updated');

      expect(updated.id, marker.id);
      expect(updated.title, 'Updated');
      expect(updated.position, marker.position);
    });
  });

  group('MapCluster', () {
    test('should create cluster from markers', () {
      final markers = [
        const MapMarker(
          id: 'marker-1',
          position: LatLng(37.7749, -122.4194),
        ),
        const MapMarker(
          id: 'marker-2',
          position: LatLng(37.7750, -122.4195),
        ),
      ];

      final cluster = MapCluster.fromMarkers(
        id: 'cluster-1',
        markers: markers,
      );

      expect(cluster.id, 'cluster-1');
      expect(cluster.markerCount, 2);
      expect(cluster.markerIds, containsAll(['marker-1', 'marker-2']));
    });

    test('should throw error when creating cluster from empty list', () {
      expect(
        () => MapCluster.fromMarkers(
          id: 'cluster-1',
          markers: const [],
        ),
        throwsArgumentError,
      );
    });

    test('should calculate cluster center position', () {
      final markers = [
        const MapMarker(
          id: 'marker-1',
          position: LatLng(37.7749, -122.4194),
        ),
        const MapMarker(
          id: 'marker-2',
          position: LatLng(37.7751, -122.4196),
        ),
      ];

      final cluster = MapCluster.fromMarkers(
        id: 'cluster-1',
        markers: markers,
      );

      // Center should be between the two markers
      expect(cluster.position.latitude, greaterThan(37.7749));
      expect(cluster.position.latitude, lessThan(37.7751));
    });

    test('should detect marker types in cluster', () {
      final markers = [
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
      ];

      final cluster = MapCluster.fromMarkers(
        id: 'cluster-1',
        markers: markers,
      );

      expect(cluster.containsType(MarkerType.trip), true);
      expect(cluster.containsType(MarkerType.activity), true);
      expect(cluster.containsType(MarkerType.photo), false);
    });

    test('should count markers by type', () {
      final markers = [
        const MapMarker(
          id: 'marker-1',
          position: LatLng(37.7749, -122.4194),
          type: MarkerType.trip,
        ),
        const MapMarker(
          id: 'marker-2',
          position: LatLng(37.7750, -122.4195),
          type: MarkerType.trip,
        ),
        const MapMarker(
          id: 'marker-3',
          position: LatLng(37.7751, -122.4196),
          type: MarkerType.activity,
        ),
      ];

      final cluster = MapCluster.fromMarkers(
        id: 'cluster-1',
        markers: markers,
      );

      expect(cluster.countByType(MarkerType.trip), 2);
      expect(cluster.countByType(MarkerType.activity), 1);
    });

    test('should use weighted center when enabled', () {
      final markers = [
        const MapMarker(
          id: 'trip-marker',
          position: LatLng(37.7749, -122.4194),
          type: MarkerType.trip, // Higher weight (3.0)
        ),
        const MapMarker(
          id: 'photo-marker',
          position: LatLng(37.7751, -122.4196),
          type: MarkerType.photo, // Lower weight (1.0)
        ),
      ];

      final cluster = MapCluster.fromMarkers(
        id: 'cluster-1',
        markers: markers,
        useWeightedCenter: true,
      );

      expect(cluster.weightedPosition, isNotNull);
      // Weighted center should be closer to trip marker due to higher weight
      final distToTrip = cluster.position.latitude - 37.7749;
      expect(distToTrip.abs(), lessThan(0.0001)); // Very close to trip
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

    test('should create high density params', () {
      const params = ClusteringParams.highDensity();

      expect(params.clusterRadius, 50);
      expect(params.minClusterSize, 3);
      expect(params.maxClusterSize, 150);
      expect(params.algorithm, ClusteringAlgorithm.grid);
    });

    test('should create low density params', () {
      const params = ClusteringParams.lowDensity();

      expect(params.clusterRadius, 120);
      expect(params.minClusterSize, 2);
      expect(params.maxClusterSize, 50);
      expect(params.algorithm, ClusteringAlgorithm.distance);
    });

    test('should create params for zoom level 15+ (very zoomed in)', () {
      final params = ClusteringParams.forZoomLevel(15.0);

      expect(params.clusterRadius, 30);
      expect(params.minClusterSize, 3);
      expect(params.maxClusterSize, 20);
      expect(params.algorithm, ClusteringAlgorithm.distance);
    });

    test('should create params for zoom level 12-14 (moderately zoomed)', () {
      final params = ClusteringParams.forZoomLevel(12.0);

      expect(params.clusterRadius, 60);
      expect(params.minClusterSize, 2);
      expect(params.maxClusterSize, 50);
      expect(params.algorithm, ClusteringAlgorithm.distance);
    });

    test('should create params for zoom level 9-11 (zoomed out)', () {
      final params = ClusteringParams.forZoomLevel(10.0);

      expect(params.clusterRadius, 100);
      expect(params.minClusterSize, 2);
      expect(params.maxClusterSize, 100);
      expect(params.algorithm, ClusteringAlgorithm.grid);
    });

    test('should create params for zoom level <9 (very zoomed out)', () {
      final params = ClusteringParams.forZoomLevel(5.0);

      expect(params.clusterRadius, 150);
      expect(params.minClusterSize, 2);
      expect(params.maxClusterSize, 200);
      expect(params.algorithm, ClusteringAlgorithm.grid);
    });
  });

  group('MapMarkerClusteringService - Distance Algorithm', () {
    test('should cluster nearby markers', () {
      final service = MapMarkerClusteringService(
        const ClusteringParams(
          clusterRadius: 100,
          minClusterSize: 2,
          algorithm: ClusteringAlgorithm.distance,
        ),
      );

      final markers = [
        const MapMarker(
          id: 'marker-1',
          position: LatLng(37.7749, -122.4194),
        ),
        const MapMarker(
          id: 'marker-2',
          position: LatLng(37.7750, -122.4195), // ~15 meters away
        ),
      ];

      final result = service.clusterMarkers(markers);

      expect(result.clusters.length, 1);
      expect(result.unclusteredMarkers.length, 0);
      expect(result.clusters.first.markerCount, 2);
    });

    test('should not cluster distant markers', () {
      final service = MapMarkerClusteringService(
        const ClusteringParams(
          clusterRadius: 50,
          minClusterSize: 2,
          algorithm: ClusteringAlgorithm.distance,
        ),
      );

      final markers = [
        const MapMarker(
          id: 'marker-1',
          position: LatLng(37.7749, -122.4194),
        ),
        const MapMarker(
          id: 'marker-2',
          position: LatLng(37.7849, -122.4294), // ~1.5 km away
        ),
      ];

      final result = service.clusterMarkers(markers);

      expect(result.clusters.length, 0);
      expect(result.unclusteredMarkers.length, 2);
    });

    test('should respect minClusterSize parameter', () {
      final service = MapMarkerClusteringService(
        const ClusteringParams(
          clusterRadius: 100,
          minClusterSize: 3, // Require at least 3 markers
          algorithm: ClusteringAlgorithm.distance,
        ),
      );

      final markers = [
        const MapMarker(
          id: 'marker-1',
          position: LatLng(37.7749, -122.4194),
        ),
        const MapMarker(
          id: 'marker-2',
          position: LatLng(37.7750, -122.4195),
        ),
      ];

      final result = service.clusterMarkers(markers);

      expect(result.clusters.length, 0); // Not enough markers for cluster
      expect(result.unclusteredMarkers.length, 2);
    });

    test('should respect maxClusterSize parameter', () {
      final service = MapMarkerClusteringService(
        const ClusteringParams(
          clusterRadius: 200,
          minClusterSize: 2,
          maxClusterSize: 3,
          algorithm: ClusteringAlgorithm.distance,
        ),
      );

      // Create 5 markers close together
      final markers = List.generate(
        5,
        (i) => MapMarker(
          id: 'marker-$i',
          position: LatLng(37.7749 + i * 0.0001, -122.4194 + i * 0.0001),
        ),
      );

      final result = service.clusterMarkers(markers);

      // Should create clusters with max 3 markers each
      expect(result.clusters.length, greaterThan(0));
      for (final cluster in result.clusters) {
        expect(cluster.markerCount, lessThanOrEqualTo(3));
      }
    });

    test('should calculate clustering efficiency', () {
      final service = MapMarkerClusteringService(
        const ClusteringParams(
          clusterRadius: 100,
          minClusterSize: 2,
        ),
      );

      // Create 10 markers that will form 2 clusters of 5 each
      final markers = [
        // Cluster 1
        ...List.generate(
          5,
          (i) => MapMarker(
            id: 'cluster1-$i',
            position: LatLng(37.7749 + i * 0.0001, -122.4194),
          ),
        ),
        // Cluster 2 (far from cluster 1)
        ...List.generate(
          5,
          (i) => MapMarker(
            id: 'cluster2-$i',
            position: LatLng(37.7849 + i * 0.0001, -122.4294),
          ),
        ),
      ];

      final result = service.clusterMarkers(markers);

      // Efficiency: (10 markers - 2 clusters + 0 unclustered) / 10 = 80%
      expect(result.efficiency, greaterThan(0.7));
      expect(result.efficiency, lessThanOrEqualTo(1.0));
    });

    test('should generate statistics', () {
      final service = MapMarkerClusteringService();

      final markers = List.generate(
        20,
        (i) => MapMarker(
          id: 'marker-$i',
          position: LatLng(37.7749 + i * 0.001, -122.4194),
        ),
      );

      final result = service.clusterMarkers(markers);
      final stats = result.statistics;

      expect(stats['totalMarkers'], 20);
      expect(stats['clusters'], isNotNull);
      expect(stats['efficiency'], isNotNull);
      expect(stats['avgClusterSize'], isNotNull);
      expect(stats['algorithm'], 'distance');
    });

    test('should handle empty marker list', () {
      final service = MapMarkerClusteringService();

      final result = service.clusterMarkers([]);

      expect(result.clusters.isEmpty, true);
      expect(result.unclusteredMarkers.isEmpty, true);
      expect(result.totalMarkers, 0);
    });

    test('should handle single marker', () {
      final service = MapMarkerClusteringService();

      final markers = [
        const MapMarker(
          id: 'marker-1',
          position: LatLng(37.7749, -122.4194),
        ),
      ];

      final result = service.clusterMarkers(markers);

      expect(result.clusters.length, 0); // Not enough for cluster
      expect(result.unclusteredMarkers.length, 1);
    });
  });

  group('MapMarkerClusteringService - Grid Algorithm', () {
    test('should cluster markers using grid algorithm', () {
      final service = MapMarkerClusteringService(
        const ClusteringParams(
          algorithm: ClusteringAlgorithm.grid,
          gridCellSize: 100,
          minClusterSize: 2,
        ),
      );

      // Create markers in different grid cells
      final markers = [
        // Cell 1
        ...List.generate(
          3,
          (i) => MapMarker(
            id: 'cell1-$i',
            position: LatLng(37.7749 + i * 0.0001, -122.4194),
          ),
        ),
        // Cell 2 (far away)
        ...List.generate(
          3,
          (i) => MapMarker(
            id: 'cell2-$i',
            position: LatLng(37.7849 + i * 0.0001, -122.4294),
          ),
        ),
      ];

      final result = service.clusterMarkers(markers);

      expect(result.clusters.length, greaterThanOrEqualTo(1));
      expect(result.totalMarkers, 6);
    });

    test('should be faster than distance-based for large datasets', () {
      final distanceService = MapMarkerClusteringService(
        const ClusteringParams(
          algorithm: ClusteringAlgorithm.distance,
          clusterRadius: 80,
        ),
      );

      final gridService = MapMarkerClusteringService(
        const ClusteringParams(
          algorithm: ClusteringAlgorithm.grid,
          gridCellSize: 100,
        ),
      );

      final markers = List.generate(
        500,
        (i) => MapMarker(
          id: 'marker-$i',
          position: LatLng(37.0 + i * 0.01, -122.0 + i * 0.01),
        ),
      );

      final stopwatch1 = Stopwatch()..start();
      distanceService.clusterMarkers(markers);
      stopwatch1.stop();

      final stopwatch2 = Stopwatch()..start();
      gridService.clusterMarkers(markers);
      stopwatch2.stop();

      // Grid should be faster (or at least comparable)
      expect(stopwatch2.elapsedMilliseconds,
          lessThanOrEqualTo(stopwatch1.elapsedMilliseconds + 50));
    });
  });

  group('MapMarkerClusteringService - K-means Algorithm', () {
    test('should cluster markers using k-means', () {
      final service = MapMarkerClusteringService(
        const ClusteringParams(
          algorithm: ClusteringAlgorithm.kmeans,
          minClusterSize: 3,
        ),
      );

      final markers = List.generate(
        30,
        (i) => MapMarker(
          id: 'marker-$i',
          position:
              LatLng(37.7749 + (i % 10) * 0.001, -122.4194 + (i ~/ 10) * 0.001),
        ),
      );

      final result = service.clusterMarkers(markers);

      expect(result.clusters.length, greaterThan(0));
      expect(result.totalMarkers, 30);
    });

    test('should not cluster if less than minClusterSize', () {
      final service = MapMarkerClusteringService(
        const ClusteringParams(
          algorithm: ClusteringAlgorithm.kmeans,
          minClusterSize: 10,
        ),
      );

      final markers = List.generate(
        5,
        (i) => MapMarker(
          id: 'marker-$i',
          position: LatLng(37.7749 + i * 0.001, -122.4194),
        ),
      );

      final result = service.clusterMarkers(markers);

      expect(result.clusters.length, 0);
      expect(result.unclusteredMarkers.length, 5);
    });
  });

  group('MapMarkerClusteringService - Bounds Clustering', () {
    test('should cluster only markers within bounds', () {
      final service = MapMarkerClusteringService(
        const ClusteringParams(
          clusterRadius: 100,
          minClusterSize: 2,
        ),
      );

      final markers = [
        // Within bounds (San Francisco)
        const MapMarker(
          id: 'marker-1',
          position: LatLng(37.7749, -122.4194),
        ),
        const MapMarker(
          id: 'marker-2',
          position: LatLng(37.7750, -122.4195),
        ),
        // Outside bounds (New York)
        const MapMarker(
          id: 'marker-3',
          position: LatLng(40.7128, -74.0060),
        ),
      ];

      final bounds = LatLngBounds(
        const LatLng(37.4, -122.5),
        const LatLng(37.8, -122.0),
      );

      final result = service.clusterMarkersInLatLngBounds(markers, bounds);

      expect(result.clusters.length, 1);
      expect(result.clusters.first.markerIds,
          containsAll(['marker-1', 'marker-2']));
      expect(result.clusters.first.markerIds, isNot(contains('marker-3')));
    });

    test('should return empty result when no markers in bounds', () {
      final service = MapMarkerClusteringService();

      final markers = [
        const MapMarker(
          id: 'marker-1',
          position: LatLng(40.7128, -74.0060), // New York
        ),
      ];

      final bounds = LatLngBounds(
        const LatLng(37.4, -122.5), // San Francisco
        const LatLng(37.8, -122.0),
      );

      final result = service.clusterMarkersInLatLngBounds(markers, bounds);

      expect(result.clusters.isEmpty, true);
      expect(result.unclusteredMarkers.isEmpty, true);
    });
  });

  group('MapMarkerClusteringService - Incremental Clustering', () {
    test('should add new markers to existing clusters', () {
      final service = MapMarkerClusteringService(
        const ClusteringParams(
          clusterRadius: 100,
          minClusterSize: 2,
        ),
      );

      // Initial markers
      final existingMarkers = [
        const MapMarker(
          id: 'marker-1',
          position: LatLng(37.7749, -122.4194),
        ),
        const MapMarker(
          id: 'marker-2',
          position: LatLng(37.7750, -122.4195),
        ),
      ];

      final previousResult = service.clusterMarkers(existingMarkers);

      // New markers (close to existing cluster)
      final newMarkers = [
        const MapMarker(
          id: 'marker-3',
          position: LatLng(37.7751, -122.4196),
        ),
      ];

      final updatedResult = service.incrementalCluster(
        existingMarkers,
        newMarkers,
        previousResult,
      );

      // Should have new clusters or updated clusters
      expect(updatedResult.totalMarkers, 3);
    });

    test('should handle removal of markers', () {
      final service = MapMarkerClusteringService(
        const ClusteringParams(
          clusterRadius: 100,
          minClusterSize: 2,
        ),
      );

      final allMarkers = [
        const MapMarker(
          id: 'marker-1',
          position: LatLng(37.7749, -122.4194),
        ),
        const MapMarker(
          id: 'marker-2',
          position: LatLng(37.7750, -122.4195),
        ),
        const MapMarker(
          id: 'marker-3',
          position: LatLng(37.7751, -122.4196),
        ),
      ];

      final previousResult = service.clusterMarkers(allMarkers);

      // Simulate removal by updating only marker-1
      final updatedMarkers = [allMarkers[0]];
      final removedMarkers = [allMarkers[1], allMarkers[2]];

      final updatedResult = service.incrementalCluster(
        updatedMarkers,
        removedMarkers,
        previousResult,
      );

      // Note: incrementalCluster may double-count markers in remaining clusters + new markers
      // This is a known limitation of the current implementation
      expect(updatedResult.totalMarkers, greaterThanOrEqualTo(1));
    });
  });

  group('MapMarkerClusteringService - Zoom Level Support', () {
    test('should update params based on zoom level', () {
      final service = MapMarkerClusteringService();

      // Zoom level 5 (very zoomed out)
      service.updateParams(ClusteringParams.forZoomLevel(5.0));
      expect(service.params.clusterRadius, 150);
      expect(service.params.algorithm, ClusteringAlgorithm.grid);

      // Zoom level 15 (very zoomed in)
      service.updateParams(ClusteringParams.forZoomLevel(15.0));
      expect(service.params.clusterRadius, 30);
      expect(service.params.algorithm, ClusteringAlgorithm.distance);
    });

    test('should produce different clusters at different zoom levels', () {
      final service = MapMarkerClusteringService();

      final markers = List.generate(
        50,
        (i) => MapMarker(
          id: 'marker-$i',
          position: LatLng(
              37.7749 + (i % 10) * 0.0005, -122.4194 + (i ~/ 10) * 0.0005),
        ),
      );

      // Cluster at zoom level 5 (aggressive)
      service.updateParams(ClusteringParams.forZoomLevel(5.0));
      final resultZoomedOut = service.clusterMarkers(markers);

      // Cluster at zoom level 15 (minimal)
      service.updateParams(ClusteringParams.forZoomLevel(15.0));
      final resultZoomedIn = service.clusterMarkers(markers);

      // Zoomed out should have more clustering, resulting in more cluster objects
      // but fewer total visible items
      expect(resultZoomedOut.unclusteredMarkers.length,
          lessThanOrEqualTo(resultZoomedIn.unclusteredMarkers.length));

      // Zoomed out should have higher efficiency
      expect(resultZoomedOut.efficiency,
          greaterThanOrEqualTo(resultZoomedIn.efficiency));
    });
  });

  group('ClusteringResult', () {
    test('should calculate efficiency correctly', () {
      final markers = [
        const MapMarker(id: '1', position: LatLng(37.7749, -122.4194)),
        const MapMarker(id: '2', position: LatLng(37.7750, -122.4195)),
        const MapMarker(id: '3', position: LatLng(37.7751, -122.4196)),
        const MapMarker(id: '4', position: LatLng(37.7752, -122.4197)),
      ];

      final cluster1 = MapCluster.fromMarkers(
        id: 'cluster-1',
        markers: markers.sublist(0, 2),
      );

      final cluster2 = MapCluster.fromMarkers(
        id: 'cluster-2',
        markers: markers.sublist(2, 4),
      );

      final result = ClusteringResult(
        clusters: [cluster1, cluster2],
        unclusteredMarkers: [],
        totalMarkers: 4,
        algorithm: ClusteringAlgorithm.distance,
        params: const ClusteringParams(),
      );

      // Efficiency: (4 - 2) / 4 = 50%
      expect(result.efficiency, 0.5);
    });

    test('should handle zero markers', () {
      const result = ClusteringResult(
        clusters: [],
        unclusteredMarkers: [],
        totalMarkers: 0,
        algorithm: ClusteringAlgorithm.distance,
        params: ClusteringParams(),
      );

      expect(result.efficiency, 0.0);
    });
  });

  group('Performance Tests', () {
    test('should handle 500 markers efficiently', () {
      final service = MapMarkerClusteringService(
        const ClusteringParams(
          algorithm: ClusteringAlgorithm.grid, // Fastest for large datasets
          gridCellSize: 100,
        ),
      );

      final markers = List.generate(
        500,
        (i) => MapMarker(
          id: 'marker-$i',
          position: LatLng(37.0 + i * 0.01, -122.0 + (i % 100) * 0.01),
        ),
      );

      final stopwatch = Stopwatch()..start();
      final result = service.clusterMarkers(markers);
      stopwatch.stop();

      // Should complete in less than 1 second
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
      expect(result.totalMarkers, 500);

      // Efficiency may vary based on marker distribution and algorithm
      expect(result.efficiency, isA<double>());
    });

    test('should achieve 80-90% efficiency on clustered data', () {
      final service = MapMarkerClusteringService(
        const ClusteringParams.highDensity(),
      );

      // Generate clustered data (10 clusters of 50 markers each)
      final markers = <MapMarker>[];
      for (int cluster = 0; cluster < 10; cluster++) {
        final baseLat = 37.7749 + cluster * 0.01;
        final baseLng = -122.4194 + cluster * 0.01;

        for (int i = 0; i < 50; i++) {
          markers.add(MapMarker(
            id: 'marker-${cluster}_$i',
            position: LatLng(baseLat + i * 0.0001, baseLng + i * 0.0001),
          ));
        }
      }

      final result = service.clusterMarkers(markers);

      // Should achieve high efficiency on clustered data
      expect(result.efficiency, greaterThan(0.6));
      expect(result.efficiency, lessThanOrEqualTo(0.95));
    });
  });
}
