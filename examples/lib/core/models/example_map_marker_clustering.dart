import 'package:latlong2/latlong.dart';
import '../models/map_marker.dart';
import '../services/map_marker_clustering_service.dart';

/// Example 1: Basic Clustering
///
/// Demonstrates simple marker clustering with default parameters.
class Example1BasicClustering {
  void example() {
    // Create sample markers
    final markers = [
      const MapMarker(
        id: 'marker-1',
        position: LatLng(37.7749, -122.4194),
        title: 'Golden Gate Bridge',
        type: MarkerType.poi,
      ),
      const MapMarker(
        id: 'marker-2',
        position: LatLng(37.7750, -122.4195),
        title: 'Golden Gate Viewpoint',
        type: MarkerType.poi,
      ),
      const MapMarker(
        id: 'marker-3',
        position: LatLng(37.8080, -122.4177),
        title: 'Fisherman\'s Wharf',
        type: MarkerType.poi,
      ),
    ];

    // Cluster markers
    final service = MapMarkerClusteringService();
    final result = service.clusterMarkers(markers);

    // Display results
    print('Clusters: ${result.clusters.length}');
    print('Unclustered markers: ${result.unclusteredMarkers.length}');
    print('Efficiency: ${(result.efficiency * 100).toStringAsFixed(1)}%');
  }
}

/// Example 2: High-Density Area Clustering
///
/// Demonstrates clustering for areas with many close markers.
class Example2HighDensityClustering {
  void example() {
    // Generate 100 markers in a small area (simulating popular tourist area)
    final markers = List.generate(
      100,
      (i) => MapMarker(
        id: 'marker-$i',
        position: LatLng(
          37.7749 + (i % 10) * 0.0001, // Small latitudinal spread
          -122.4194 + (i ~/ 10) * 0.0001, // Small longitudinal spread
        ),
        title: 'Location $i',
        type: MarkerType.poi,
      ),
    );

    // Use high-density parameters
    final service = MapMarkerClusteringService(
      const ClusteringParams.highDensity(
        clusterRadius: 50,
        minClusterSize: 3,
      ),
    );

    final result = service.clusterMarkers(markers);

    print('High-density clustering results:');
    print('  Total markers: ${result.totalMarkers}');
    print('  Clusters formed: ${result.clusters.length}');
    print('  Average cluster size: ${result.statistics['avgClusterSize']}');
    print('  Largest cluster: ${result.statistics['maxClusterSize']} markers');
  }
}

/// Example 3: Zoom-Aware Clustering
///
/// Demonstrates automatic parameter adjustment based on zoom level.
class Example3ZoomAwareClustering {
  void example() {
    final service = MapMarkerClusteringService();

    // Simulate different zoom levels
    final zoomLevels = [5.0, 10.0, 15.0];

    for (final zoom in zoomLevels) {
      // Get parameters for this zoom level
      final params = ClusteringParams.forZoomLevel(zoom);
      service.updateParams(params);

      print('\nZoom level $zoom:');
      print('  Cluster radius: ${params.clusterRadius}m');
      print('  Min cluster size: ${params.minClusterSize}');
      print('  Max cluster size: ${params.maxClusterSize}');
      print('  Algorithm: ${params.algorithm.name}');
    }
  }
}

/// Example 4: Algorithm Comparison
///
/// Demonstrates performance differences between clustering algorithms.
class Example4AlgorithmComparison {
  void example() {
    // Generate 500 markers
    final markers = List.generate(
      500,
      (i) => MapMarker(
        id: 'marker-$i',
        position: LatLng(
          37.0 + (i % 100) * 0.01,
          -122.0 + (i ~/ 100) * 0.01,
        ),
        type: MarkerType.defaultType,
      ),
    );

    // Test distance-based clustering
    final distanceService = MapMarkerClusteringService(
      const ClusteringParams(
        algorithm: ClusteringAlgorithm.distance,
        clusterRadius: 80,
      ),
    );

    final stopwatch = Stopwatch()..start();
    final distanceResult = distanceService.clusterMarkers(markers);
    stopwatch.stop();

    print('Distance-based clustering:');
    print('  Time: ${stopwatch.elapsedMilliseconds}ms');
    print('  Clusters: ${distanceResult.clusters.length}');
    print(
        '  Efficiency: ${(distanceResult.efficiency * 100).toStringAsFixed(1)}%');

    // Test grid-based clustering
    final gridService = MapMarkerClusteringService(
      const ClusteringParams(
        algorithm: ClusteringAlgorithm.grid,
        gridCellSize: 100,
      ),
    );

    stopwatch
      ..reset()
      ..start();
    final gridResult = gridService.clusterMarkers(markers);
    stopwatch.stop();

    print('\nGrid-based clustering:');
    print('  Time: ${stopwatch.elapsedMilliseconds}ms');
    print('  Clusters: ${gridResult.clusters.length}');
    print('  Efficiency: ${(gridResult.efficiency * 100).toStringAsFixed(1)}%');
  }
}

/// Example 5: Trip Markers
///
/// Demonstrates clustering trip destinations from the Trip model.
class Example5TripMarkers {
  void example(List<Map<String, dynamic>> tripsData) {
    // Convert trip data to markers
    final tripMarkers = tripsData
        .where((trip) => trip['latitude'] != null && trip['longitude'] != null)
        .map((trip) => MapMarker.fromTrip(
              tripId: trip['id'],
              title: trip['title'],
              latitude: trip['latitude'],
              longitude: trip['longitude'],
              description: trip['destination'],
              color: 0xFF2196F3, // Blue for trips
            ))
        .toList();

    // Cluster with trip-specific parameters
    final service = MapMarkerClusteringService(
      const ClusteringParams(
        clusterRadius: 100,
        minClusterSize: 2,
        useWeightedCenter: true, // Better for varying importance
      ),
    );

    final result = service.clusterMarkers(tripMarkers);

    print('Trip clustering:');
    print('  Total trips: ${tripMarkers.length}');
    print('  Clusters: ${result.clusters.length}');
    print('  Single markers: ${result.unclusteredMarkers.length}');

    // Analyze cluster composition
    for (final cluster in result.clusters) {
      if (cluster.containsType(MarkerType.trip)) {
        print(
            '  Cluster ${cluster.id}: ${cluster.countByType(MarkerType.trip)} trips');
      }
    }
  }
}

/// Example 6: Activity Markers
///
/// Demonstrates clustering activity locations.
class Example6ActivityMarkers {
  void example(List<Map<String, dynamic>> activitiesData) {
    // Convert activity data to markers
    final activityMarkers = activitiesData
        .where((activity) =>
            activity['latitude'] != null && activity['longitude'] != null)
        .map((activity) => MapMarker.fromActivity(
              activityId: activity['id'],
              title: activity['title'],
              latitude: activity['latitude'],
              longitude: activity['longitude'],
              description: activity['locationName'],
            ))
        .toList();

    // Cluster with activity-specific parameters
    final service = MapMarkerClusteringService(
      const ClusteringParams(
        clusterRadius: 60, // Smaller radius for activities
        minClusterSize: 2,
        algorithm: ClusteringAlgorithm.distance,
      ),
    );

    final result = service.clusterMarkers(activityMarkers);

    print('Activity clustering:');
    print('  Total activities: ${activityMarkers.length}');
    print('  Efficiency: ${(result.efficiency * 100).toStringAsFixed(1)}%');
  }
}

/// Example 7: Bounds-Based Clustering
///
/// Demonstrates clustering only visible markers on map.
class Example7BoundsBasedClustering {
  void example(List<MapMarker> allMarkers) {
    final service = MapMarkerClusteringService();

    // Define visible area (e.g., San Francisco Bay Area)
    final bounds = LatLngBounds(
      southwest: const LatLng(37.4, -122.5),
      northeast: const LatLng(37.8, -122.0),
    );

    // Cluster only markers within bounds
    final result = service.clusterMarkersInBounds(allMarkers, bounds);

    print('Visible area clustering:');
    print('  Total markers: ${allMarkers.length}');
    print(
        '  Markers in bounds: ${result.clusters.length + result.unclusteredMarkers.length}');
    print(
        '  Rendered items: ${result.clusters.length + result.unclusteredMarkers.length}');
    print(
        '  Performance improvement: ${((1.0 - (result.clusters.length + result.unclusteredMarkers.length) / allMarkers.length) * 100).toStringAsFixed(1)}%');
  }
}

/// Example 8: Incremental Clustering
///
/// Demonstrates efficient updates for real-time marker changes.
class Example8IncrementalClustering {
  void example() {
    final service = MapMarkerClusteringService();

    // Initial markers
    var markers = List.generate(
      50,
      (i) => MapMarker(
        id: 'marker-$i',
        position: LatLng(37.7 + i * 0.001, -122.4 + i * 0.001),
        type: MarkerType.poi,
      ),
    );

    // Initial clustering
    var previousResult = service.clusterMarkers(markers);

    print('Initial clustering:');
    print('  Clusters: ${previousResult.clusters.length}');

    // Simulate adding new markers
    final newMarkers = [
      const MapMarker(
        id: 'marker-50',
        position: LatLng(37.750, -122.450),
        type: MarkerType.poi,
      ),
      const MapMarker(
        id: 'marker-51',
        position: LatLng(37.751, -122.451),
        type: MarkerType.poi,
      ),
    ];

    // Incremental update (faster than reclustering all markers)
    final updatedResult = service.incrementalCluster(
      markers,
      newMarkers,
      previousResult,
    );

    markers.addAll(newMarkers);

    print('\nAfter adding 2 new markers:');
    print('  Clusters: ${updatedResult.clusters.length}');
    print(
        '  Used incremental clustering: more efficient than reclustering all ${markers.length} markers');
  }
}

/// Example 9: Mixed Marker Types
///
/// Demonstrates clustering different types of markers together.
class Example9MixedMarkerTypes {
  void example() {
    final markers = [
      // Trip markers
      const MapMarker(
        id: 'trip-1',
        position: LatLng(37.7749, -122.4194),
        title: 'San Francisco Trip',
        type: MarkerType.trip,
      ),
      // Activity markers
      const MapMarker(
        id: 'activity-1',
        position: LatLng(37.7750, -122.4195),
        title: 'Golden Gate Visit',
        type: MarkerType.activity,
      ),
      // Photo markers
      const MapMarker(
        id: 'photo-1',
        position: LatLng(37.7751, -122.4196),
        title: 'Photo at Golden Gate',
        type: MarkerType.photo,
      ),
      // Restaurant markers
      const MapMarker(
        id: 'restaurant-1',
        position: LatLng(37.7752, -122.4197),
        title: 'Seafood Restaurant',
        type: MarkerType.restaurant,
      ),
    ];

    final service = MapMarkerClusteringService();
    final result = service.clusterMarkers(markers);

    print('Mixed marker types clustering:');
    for (final cluster in result.clusters) {
      print('  Cluster ${cluster.id}:');
      print('    Total markers: ${cluster.markerCount}');
      print('    Trips: ${cluster.countByType(MarkerType.trip)}');
      print('    Activities: ${cluster.countByType(MarkerType.activity)}');
      print('    Photos: ${cluster.countByType(MarkerType.photo)}');
      print('    Restaurants: ${cluster.countByType(MarkerType.restaurant)}');
    }
  }
}

/// Example 10: Custom Clustering Parameters
///
/// Demonstrates fine-tuning clustering parameters.
class Example10CustomParameters {
  void example() {
    final markers = List.generate(
      200,
      (i) => MapMarker(
        id: 'marker-$i',
        position: LatLng(
          37.7 + (i % 20) * 0.001,
          -122.4 + (i ~/ 20) * 0.001,
        ),
        type: MarkerType.poi,
      ),
    );

    // Custom parameters for specific use case
    const customParams = ClusteringParams(
      clusterRadius: 75, // Between markers
      minClusterSize: 3, // Require at least 3 markers
      maxClusterSize: 40, // Limit cluster size
      useWeightedCenter: true, // Better visual center
      algorithm: ClusteringAlgorithm.distance,
      gridCellSize: 120, // If switching to grid
      kmeansMaxIterations: 15, // If using K-means
    );

    final service = MapMarkerClusteringService(customParams);
    final result = service.clusterMarkers(markers);

    print('Custom parameter clustering:');
    print('  Parameters: $customParams');
    print('  Statistics: ${result.statistics}');
  }
}

/// Main example runner
class MapMarkerClusteringExamples {
  void runAllExamples() {
    print('=== Map Marker Clustering Examples ===\n');

    Example1BasicClustering().example();
    print('\n${'-' * 50}\n');

    Example2HighDensityClustering().example();
    print('\n${'-' * 50}\n');

    Example3ZoomAwareClustering().example();
    print('\n${'-' * 50}\n');

    Example4AlgorithmComparison().example();
    print('\n${'-' * 50}\n');

    Example7BoundsBasedClustering().example(
      List.generate(
          100,
          (i) => MapMarker(
                id: 'marker-$i',
                position: LatLng(37.6 + i * 0.002, -122.4 + i * 0.001),
                type: MarkerType.poi,
              )),
    );
    print('\n${'-' * 50}\n');

    Example8IncrementalClustering().example();
    print('\n${'-' * 50}\n');

    Example9MixedMarkerTypes().example();
    print('\n${'-' * 50}\n');

    Example10CustomParameters().example();
  }
}
