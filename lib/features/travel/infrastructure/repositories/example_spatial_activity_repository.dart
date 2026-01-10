import 'package:supabase_flutter/supabase_flutter.dart';
import 'spatial_activity_repository.dart';

/// Example usage of SpatialActivityRepository for efficient map marker querying
///
/// This file demonstrates how to use the SpatialActivityRepository to:
/// 1. Query activities within map bounds
/// 2. Use viewport caching for performance
/// 3. Implement debounced queries for reactive map updates
/// 4. Limit markers for clustering performance
///
/// Setup:
/// ```dart
/// final spatialRepo = SpatialActivityRepository(
///   supabaseClient: supabase.client,
///   maxMarkers: 1000,
///   debounceDelayMs: 200,
///   cacheSize: 10,
///   cacheTtl: Duration(minutes: 5),
/// );
/// ```
///
/// Note: This is example code. Do not call these functions directly.
/// Adapt them to your specific use case.
class ExampleSpatialActivityRepository {
  /// Example 1: Basic spatial query for activities within bounds
  ///
  /// Use this for one-time queries or when the user explicitly
  /// requests to view a specific area.
  static Future<void> example1_BasicSpatialQuery(
    SpatialActivityRepository spatialRepo,
  ) async {
    // Define viewport bounds (e.g., San Francisco area)
    final bounds = LatLngBounds(
      south: 37.70,
      west: -122.50,
      north: 37.80,
      east: -122.35,
    );

    // Query activities within bounds
    final result = await spatialRepo.getActivitiesInBounds(
      bounds: bounds,
      userId: 'user123',
      tripId: 'trip456', // optional, filters to specific trip
    );

    // Access activities
    print('Activities in bounds: ${result.activities.length}');
    print('Total activities with location: ${result.totalActivities}');
    print('Is from cache: ${result.isFromCache}');
    print('Is limited (truncated): ${result.isLimited}');

    // Convert to map markers for clustering
    final markers = result.markers;
    print('Markers for clustering: ${markers.length}');
  }

  /// Example 2: Debounced spatial query for reactive map updates
  ///
  /// Use this for real-time map updates during pan/zoom.
  /// The query is debounced to avoid excessive database calls.
  static Future<void> example2_DebouncedSpatialQuery(
    SpatialActivityRepository spatialRepo,
  ) async {
    // Subscribe to debounced results
    final subscription = spatialRepo.resultStream.listen((result) {
      print('Debounced query result:');
      print('  Activities: ${result.activities.length}');
      print('  From cache: ${result.isFromCache}');
      print('  Bounds: ${result.bounds}');

      // Update map markers
      final markers = result.markers;
      // TODO: Update map with new markers
    });

    // Simulate rapid map movements (user panning quickly)
    // Only the last query after 200ms of no movement will execute
    spatialRepo.queryActivitiesInBoundsDebounced(
      bounds: LatLngBounds(
        south: 37.71,
        west: -122.49,
        north: 37.79,
        east: -122.36,
      ),
      userId: 'user123',
    );

    // If user continues panning, previous query is cancelled
    spatialRepo.queryActivitiesInBoundsDebounced(
      bounds: LatLngBounds(
        south: 37.72,
        west: -122.48,
        north: 37.78,
        east: -122.37,
      ),
      userId: 'user123',
    );

    // Wait for debounced query to complete
    final result = await spatialRepo.waitForDebouncedQuery();
    print('Final debounced result: ${result.activities.length} activities');

    // Clean up
    await subscription.cancel();
  }

  /// Example 3: Using viewport caching for performance
  ///
  /// The repository automatically caches viewport queries.
  /// Returning to a previously viewed area is instant.
  static Future<void> example3_ViewportCaching(
    SpatialActivityRepository spatialRepo,
  ) async {
    final bounds = LatLngBounds(
      south: 37.70,
      west: -122.50,
      north: 37.80,
      east: -122.35,
    );

    // First query - hits database
    final result1 = await spatialRepo.getActivitiesInBounds(
      bounds: bounds,
      userId: 'user123',
    );
    print('First query - from cache: ${result1.isFromCache}'); // false

    // Query same bounds again - hits cache
    final result2 = await spatialRepo.getActivitiesInBounds(
      bounds: bounds,
      userId: 'user123',
    );
    print('Second query - from cache: ${result2.isFromCache}'); // true

    // Query similar bounds (within 5% tolerance) - hits cache
    final similarBounds = LatLngBounds(
      south: 37.701,
      west: -122.499,
      north: 37.799,
      east: -122.351,
    );
    final result3 = await spatialRepo.getActivitiesInBounds(
      bounds: similarBounds,
      userId: 'user123',
    );
    print('Similar bounds query - from cache: ${result3.isFromCache}'); // true
  }

  /// Example 4: Monitoring cache performance
  ///
  /// Track cache effectiveness to optimize configuration.
  static Future<void> example4_CachePerformanceMonitoring(
    SpatialActivityRepository spatialRepo,
  ) async {
    // Perform several queries
    for (int i = 0; i < 10; i++) {
      final bounds = LatLngBounds(
        south: 37.70 + (i * 0.01),
        west: -122.50 + (i * 0.01),
        north: 37.80 + (i * 0.01),
        east: -122.35 + (i * 0.01),
      );

      await spatialRepo.getActivitiesInBounds(
        bounds: bounds,
        userId: 'user123',
      );
    }

    // Check statistics
    final stats = spatialRepo.statistics;
    print('Query Statistics:');
    print('  Total queries: ${stats['totalQueries']}');
    print('  Cache hits: ${stats['cacheHits']}');
    print('  Cache misses: ${stats['cacheMisses']}');
    print('  Cache hit rate: ${stats['cacheHitRate']}');
    print('  Current cache size: ${stats['cacheSize']}');
    print('  Max cache size: ${stats['maxCacheSize']}');

    // Clear cache if needed
    spatialRepo.clearCache();
    print('Cache cleared');

    // Reset statistics
    spatialRepo.resetStatistics();
    print('Statistics reset');
  }

  /// Example 5: Handling marker limiting for clustering
  ///
  /// When there are many markers in the viewport, results are limited
  /// to prevent performance issues during clustering.
  static Future<void> example5_MarkerLimiting(
    SpatialActivityRepository spatialRepo,
  ) async {
    // Query a dense area with many activities
    final bounds = LatLngBounds(
      south: 37.70,
      west: -122.50,
      north: 37.80,
      east: -122.35,
    );

    final result = await spatialRepo.getActivitiesInBounds(
      bounds: bounds,
      userId: 'user123',
    );

    if (result.isLimited) {
      print('Warning: Result was limited to ${result.markers.length} markers');
      print('Total activities in area: ${result.totalActivities}');
      print('Consider zooming in to see all activities');
    } else {
      print('All ${result.activities.length} activities loaded');
    }

    // Get statistics
    final stats = spatialRepo.statistics;
    print('Max markers setting: ${stats['maxMarkers']}');
  }

  /// Example 6: Integration with map viewport loader
  ///
  /// Use SpatialActivityRepository as the data source for MapViewportLoader.
  static Future<void> example6_MapViewportLoaderIntegration(
    SpatialActivityRepository spatialRepo,
  ) async {
    // When map bounds change, query activities for that viewport
    final bounds = LatLngBounds(
      south: 37.70,
      west: -122.50,
      north: 37.80,
      east: -122.35,
    );

    // Use debounced query for smooth performance
    spatialRepo.queryActivitiesInBoundsDebounced(
      bounds: bounds,
      userId: 'user123',
    );

    // Wait for result
    final result = await spatialRepo.waitForDebouncedQuery();

    // Convert to markers for clustering manager
    final markers = result.markers;

    // Pass markers to clustering manager
    // TODO: clusteringManager.updateMarkers(markers);

    print('Loaded ${markers.length} markers for clustering');
  }

  /// Example 7: Filtering by trip
  ///
  /// Query activities for a specific trip within bounds.
  static Future<void> example7_TripSpecificQueries(
    SpatialActivityRepository spatialRepo,
  ) async {
    final bounds = LatLngBounds(
      south: 37.70,
      west: -122.50,
      north: 37.80,
      east: -122.35,
    );

    // Query for specific trip
    final tripResult = await spatialRepo.getActivitiesInBounds(
      bounds: bounds,
      userId: 'user123',
      tripId: 'trip456',
    );

    print('Activities for trip in bounds: ${tripResult.activities.length}');

    // Query all user activities in bounds
    final allUserResult = await spatialRepo.getActivitiesInBounds(
      bounds: bounds,
      userId: 'user123',
    );

    print('All user activities in bounds: ${allUserResult.activities.length}');

    // Count activities with location for statistics
    final count = await spatialRepo.countActivitiesWithLocation(
      userId: 'user123',
      tripId: 'trip456',
    );

    print('Total activities with location: $count');
  }

  /// Example 8: Complete workflow with error handling
  ///
  /// Demonstrates proper error handling and resource cleanup.
  static Future<void> example8_CompleteWorkflow(
    SupabaseClient supabaseClient,
  ) async {
    // Create repository
    final spatialRepo = SpatialActivityRepository(
      supabaseClient: supabaseClient,
      maxMarkers: 1000,
      debounceDelayMs: 200,
    );

    try {
      // Subscribe to debounced results
      final subscription = spatialRepo.resultStream.listen(
        (result) {
          print('Got ${result.activities.length} activities');
          // Update map with result.markers
        },
        onError: (error) {
          print('Query error: $error');
        },
      );

      // Query bounds
      final bounds = LatLngBounds(
        south: 37.70,
        west: -122.50,
        north: 37.80,
        east: -122.35,
      );

      // Trigger debounced query
      spatialRepo.queryActivitiesInBoundsDebounced(
        bounds: bounds,
        userId: 'user123',
      );

      // Wait for result
      final result = await spatialRepo.waitForDebouncedQuery();

      if (result.isLimited) {
        print(
            'Warning: Only showing ${result.activities.length} of ${result.totalActivities} activities');
      }

      // Check performance statistics
      print('Statistics: ${spatialRepo.statistics}');

      // Clean up
      await subscription.cancel();
    } catch (e) {
      print('Error: $e');
    } finally {
      // Always dispose
      spatialRepo.dispose();
    }
  }
}
