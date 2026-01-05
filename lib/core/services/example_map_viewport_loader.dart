import 'package:latlong2/latlong.dart';
import 'package:soloadventurer/core/models/map_marker.dart';
import 'package:soloadventurer/core/services/map_viewport_loader.dart';

/// Example usage of MapViewportLoader for viewport-based marker loading
///
/// This file demonstrates how to use the MapViewportLoader service
/// to efficiently load map markers based on viewport with buffering
/// and caching for optimal performance.
void main() {
  // Example 1: Basic usage
  example1BasicUsage();

  // Example 2: Custom buffer configuration
  example2CustomBuffer();

  // Example 3: Monitoring statistics
  example3Statistics();

  // Example 4: Cache management
  example4CacheManagement();

  // Example 5: Integration with clustering
  example5IntegrationWithClustering();
}

/// Example 1: Basic viewport loader usage
///
/// Demonstrates basic setup and viewport-based loading.
void example1BasicUsage() {
  print('=== Example 1: Basic Usage ===');

  // Create sample markers (1000 markers spread across San Francisco)
  final markers = _generateSampleMarkers(1000);

  // Create viewport loader with default settings
  final loader = MapViewportLoader(
    markers: markers,
    bufferRatio: 0.3, // 30% buffer around visible viewport
    debounceDelayMs: 200,
  );

  // Define initial viewport (San Francisco downtown)
  final initialBounds = LatLngBounds(
    const LatLng(37.77, -122.42),
    const LatLng(37.79, -122.40),
  );

  // Initialize loader with initial bounds
  loader.initialize(initialBounds).then((result) {
    print('Loaded ${result.visibleMarkers.length} visible markers');
    print('Preloaded ${result.preloadedMarkers.length} buffered markers');
    print('Total markers available: ${result.totalMarkers}');
    print('Load efficiency: ${result.statistics["loadEfficiency"]}');
  });

  // Simulate map movement
  Future.delayed(const Duration(milliseconds: 500), () {
    final newBounds = LatLngBounds(
      const LatLng(37.78, -122.41),
      const LatLng(37.80, -122.39),
    );

    loader.updateBounds(newBounds).then((result) {
      print('After pan: ${result.visibleMarkers.length} visible markers');
    });
  });

  // Clean up
  Future.delayed(const Duration(seconds: 2), () {
    loader.dispose();
  });
}

/// Example 2: Custom buffer configuration
///
/// Demonstrates different buffer ratios for different use cases.
void example2CustomBuffer() {
  print('\n=== Example 2: Custom Buffer Configuration ===');

  final markers = _generateSampleMarkers(1000);

  // High-density area (smaller buffer, more targeted loading)
  final highDensityLoader = MapViewportLoader(
    markers: markers,
    bufferRatio: 0.2, // 20% buffer for dense urban areas
    debounceDelayMs: 150, // Faster response for rapid panning
  );

  // Low-density area (larger buffer for smooth navigation)
  final lowDensityLoader = MapViewportLoader(
    markers: markers,
    bufferRatio: 0.5, // 50% buffer for sparse rural areas
    debounceDelayMs: 300, // Slower response, more batching
  );

  // Performance mode (balanced settings)
  final performanceLoader = MapViewportLoader(
    markers: markers,
    bufferRatio: 0.3, // 30% buffer (balanced)
    debounceDelayMs: 200,
    maxCacheSize: 15, // Larger cache for better performance
  );

  print('High density buffer: 20%');
  print('Low density buffer: 50%');
  print('Performance buffer: 30%');

  // Clean up
  highDensityLoader.dispose();
  lowDensityLoader.dispose();
  performanceLoader.dispose();
}

/// Example 3: Monitoring statistics
///
/// Demonstrates tracking performance metrics.
void example3Statistics() {
  print('\n=== Example 3: Statistics Monitoring ===');

  final markers = _generateSampleMarkers(1000);
  final loader = MapViewportLoader(
    markers: markers,
    bufferRatio: 0.3,
    debounceDelayMs: 200,
  );

  final bounds = LatLngBounds(
    const LatLng(37.77, -122.42),
    const LatLng(37.79, -122.40),
  );

  // Perform multiple viewport changes
  loader.initialize(bounds).then((_) {
    // Make several viewport updates
    for (int i = 0; i < 5; i++) {
      final offset = i * 0.01;
      final newBounds = LatLngBounds(
        LatLng(37.77 + offset, -122.42 + offset),
        LatLng(37.79 + offset, -122.40 + offset),
      );
      loader.updateBounds(newBounds, force: true);
    }

    // Check statistics
    Future.delayed(const Duration(milliseconds: 500), () {
      final stats = loader.statistics;
      print('Total loads: ${stats['totalLoads']}');
      print('Cache hits: ${stats['cacheHits']}');
      print('Cache misses: ${stats['cacheMisses']}');
      print('Cache hit rate: ${stats['cacheHitRate']}');
      print('Current cache size: ${stats['cacheSize']}');
      print('Loaded markers: ${stats['loadedMarkers']}');
      print('Load efficiency: ${stats['loadEfficiency']}');

      loader.dispose();
    });
  });
}

/// Example 4: Cache management
///
/// Demonstrates cache operations for optimal performance.
void example4CacheManagement() {
  print('\n=== Example 4: Cache Management ===');

  final markers = _generateSampleMarkers(1000);
  final loader = MapViewportLoader(
    markers: markers,
    bufferRatio: 0.3,
    maxCacheSize: 10,
  );

  final bounds = LatLngBounds(
    const LatLng(37.77, -122.42),
    const LatLng(37.79, -122.40),
  );

  loader.initialize(bounds).then((_) {
    // Load multiple viewports to populate cache
    for (int i = 0; i < 5; i++) {
      final offset = i * 0.02;
      final newBounds = LatLngBounds(
        LatLng(37.77 + offset, -122.42 + offset),
        LatLng(37.79 + offset, -122.40 + offset),
      );
      loader.updateBounds(newBounds, force: true);
    }

    Future.delayed(const Duration(milliseconds: 300), () {
      final stats = loader.statistics;
      print('Cache size before clear: ${stats['cacheSize']}');
      print('Cache hit rate: ${stats['cacheHitRate']}');

      // Clear cache
      loader.clearCache();

      final statsAfter = loader.statistics;
      print('Cache size after clear: ${statsAfter['cacheSize']}');
      print('Total loads reset: ${statsAfter['totalLoads']}');

      loader.dispose();
    });
  });
}

/// Example 5: Integration with clustering
///
/// Demonstrates using viewport loader with clustering manager.
void example5IntegrationWithClustering() {
  print('\n=== Example 5: Integration with Clustering ===');

  final markers = _generateSampleMarkers(1000);
  final loader = MapViewportLoader(
    markers: markers,
    bufferRatio: 0.3,
    debounceDelayMs: 200,
  );

  final bounds = LatLngBounds(
    const LatLng(37.77, -122.42),
    const LatLng(37.79, -122.40),
  );

  // Initialize and listen to viewport updates
  loader.resultStream.listen((viewportResult) {
    // Update clustering with loaded markers
    final loadedMarkers = viewportResult.allMarkers;

    print('Viewport update received:');
    print('  Visible: ${viewportResult.visibleMarkers.length}');
    print('  Preloaded: ${viewportResult.preloadedMarkers.length}');
    print('  Total for clustering: ${loadedMarkers.length}');

    // Here you would update your clustering manager:
    // clusteringManager.updateMarkers(loadedMarkers, forceRecluster: true);
  });

  loader.initialize(bounds).then((result) {
    print('Initial load complete');
    print('Efficiency: ${result.statistics["loadEfficiency"]}');
  });

  // Clean up
  Future.delayed(const Duration(seconds: 1), () {
    loader.dispose();
  });
}

/// Helper: Generate sample markers for demonstration
List<MapMarker> _generateSampleMarkers(int count) {
  final markers = <MapMarker>[];
  final random = DateTime.now().millisecondsSinceEpoch;

  // San Francisco bay area bounds
  const double minLat = 37.70;
  const double maxLat = 37.80;
  const double minLng = -122.50;
  const double maxLng = -122.35;

  for (int i = 0; i < count; i++) {
    final lat = minLat + (maxLat - minLat) * (i % 100) / 100;
    final lng = minLng + (maxLng - minLng) * ((i / 100) % 100) / 100;

    markers.add(MapMarker(
      id: 'marker_$i',
      position: LatLng(lat, lng),
      title: 'Marker $i',
      description: 'Sample marker $i',
      type: MarkerType.values[i % MarkerType.values.length],
    ));
  }

  return markers;
}
