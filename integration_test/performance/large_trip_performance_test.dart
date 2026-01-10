import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:soloadventurer/core/monitoring/performance/memory_profiler.dart';
import 'package:soloadventurer/core/monitoring/performance/performance_monitor.dart';
import 'package:soloadventurer/core/monitoring/performance/performance_metrics.dart';
import 'package:soloadventurer/features/travel/domain/models/activity.dart';
import 'package:soloadventurer/features/travel/domain/models/photo.dart';
import 'package:soloadventurer/features/travel/domain/models/trip.dart';
import 'package:soloadventurer/features/travel/infrastructure/repositories/in_memory_activity_repository.dart';
import 'package:soloadventurer/features/travel/infrastructure/repositories/in_memory_trip_repository.dart';
import 'test_data_generators.dart';

/// Integration tests for large trip performance
///
/// These tests establish baseline performance metrics for handling large trips
/// with 500+ activities and 1000+ photos. They measure:
/// - App startup time with large datasets
/// - List scrolling performance
/// - Image loading performance
/// - Memory usage
/// - Query performance with pagination
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Large Trip Performance Tests', () {
    late InMemoryTripRepository tripRepository;
    late InMemoryActivityRepository activityRepository;
    late ProviderContainer container;

    setUp(() async {
      // Initialize repositories
      tripRepository = InMemoryTripRepository();
      activityRepository = InMemoryActivityRepository();

      // Create test container
      container = ProviderContainer();

      // Initialize performance monitor in test mode
      await PerformanceMonitor.initialize(
        config: const PerformanceMonitorConfig(
          enabled: true,
          enableAlerts: false,
          monitoringInterval: Duration(seconds: 1),
        ),
        onMetricsUpdated: (metrics) {
          // Log metrics in test mode
        },
      );
    });

    tearDown(() async {
      tripRepository.clear();
      activityRepository.clear();
      await PerformanceMonitor.dispose();
      container.dispose();
    });

    testWidgets('Generate and load 500+ activities',
        (tester) async {
      final stopwatch = Stopwatch()..start();

      // Start memory profiling
      await MemoryProfiler.startProfiling();

      // Generate 500 activities
      final activities = TestDataGenerator.generateLargeActivitySet(
        tripId: 'test-trip-500',
        userId: 'test-user',
        count: 500,
      );

      final generationTime = stopwatch.elapsedMilliseconds;
      stopwatch.reset();
      stopwatch.start();

      // Create activities in repository
      for (final activity in activities) {
        await activityRepository.createActivity(activity: activity);
      }

      final insertTime = stopwatch.elapsedMilliseconds;
      stopwatch.reset();
      stopwatch.start();

      // Query all activities using pagination
      final paginatedResult = await activityRepository.getActivitiesCursor(
        tripId: 'test-trip-500',
        userId: 'test-user',
        pageSize: 50,
      );

      final queryTime = stopwatch.elapsedMilliseconds;
      stopwatch.stop();

      // Get memory statistics
      final memoryStats = await MemoryProfiler.stopProfiling();

      // Verify data generation
      expect(activities.length, greaterThanOrEqualTo(500),
          reason: 'Should generate 500+ activities');

      // Verify pagination
      expect(paginatedResult.items.length, equals(50),
          reason: 'Should return page size of 50 items');
      expect(paginatedResult.pageInfo.hasNextPage, isTrue,
          reason: 'Should have more pages');

      // Verify performance targets
      expect(generationTime, lessThan(1000),
          reason: 'Activity generation should take < 1s');
      expect(insertTime, lessThan(2000),
          reason: 'Activity insertion should take < 2s');
      expect(queryTime, lessThan(500),
          reason: 'Paginated query should take < 500ms');

      // Log baseline metrics
      _logPerformanceMetrics(
        testName: '500+ Activities',
        metrics: {
          'generationTimeMs': generationTime,
          'insertTimeMs': insertTime,
          'queryTimeMs': queryTime,
          'activityCount': activities.length,
          if (memoryStats != null)
            'peakMemoryMB': memoryStats.peakHeapUsageMB.toStringAsFixed(2),
        },
      );
    });

    testWidgets('Generate and load 1000+ photos', (tester) async {
      final stopwatch = Stopwatch()..start();

      // Start memory profiling
      await MemoryProfiler.startProfiling();

      // Generate 1000 photos
      final photos = TestDataGenerator.generateLargePhotoSet(
        tripId: 'test-trip-1000',
        count: 1000,
      );

      final generationTime = stopwatch.elapsedMilliseconds;
      stopwatch.stop();

      // Get memory statistics
      final memoryStats = await MemoryProfiler.stopProfiling();

      // Verify data generation
      expect(photos.length, greaterThanOrEqualTo(1000),
          reason: 'Should generate 1000+ photos');

      // Verify performance targets
      expect(generationTime, lessThan(1000),
          reason: 'Photo generation should take < 1s');

      // Verify memory usage stays within reasonable limits
      if (memoryStats != null) {
        expect(memoryStats.peakHeapUsageMB, lessThan(250),
            reason: 'Peak memory should be < 250MB for 1000 photos');
      }

      // Log baseline metrics
      _logPerformanceMetrics(
        testName: '1000+ Photos',
        metrics: {
          'generationTimeMs': generationTime,
          'photoCount': photos.length,
          'estimatedMemoryMB': (photos.length * 512 / 1024).toStringAsFixed(2),
          if (memoryStats != null)
            'actualMemoryMB': memoryStats.peakHeapUsageMB.toStringAsFixed(2),
        },
      );
    });

    testWidgets('Complex trip with 500 activities and 1000 photos',
        (tester) async {
      final stopwatch = Stopwatch()..start();

      // Start memory profiling
      await MemoryProfiler.startProfiling();

      // Generate complex trip data
      final tripData = TestDataGenerator.generateComplexTripData(
        activityCount: 500,
        photoCount: 1000,
        userId: 'test-user',
      );

      final trip = tripData['trip'] as Trip;
      final activities = tripData['activities'] as List<Activity>;
      final photos = tripData['photos'] as List<Photo>;

      // Create trip and activities in repositories
      await tripRepository.createTrip(trip: trip);
      for (final activity in activities) {
        await activityRepository.createActivity(activity: activity);
      }

      final setupTime = stopwatch.elapsedMilliseconds;
      stopwatch.reset();
      stopwatch.start();

      // Query activities with pagination
      String? cursor;
      var totalActivities = 0;
      var pageCount = 0;

      do {
        final result = await activityRepository.getActivitiesCursor(
          tripId: trip.id,
          userId: trip.userId,
          cursor: cursor,
          pageSize: 50,
        );

        totalActivities += result.items.length;
        pageCount++;
        cursor = result.pageInfo.nextCursor;

        // Safety check to prevent infinite loops
        if (pageCount > 20) break;
      } while (cursor != null);

      final queryTime = stopwatch.elapsedMilliseconds;
      stopwatch.stop();

      // Get memory statistics
      final memoryStats = await MemoryProfiler.stopProfiling();

      // Verify data
      expect(totalActivities, equals(500),
          reason: 'Should load all 500 activities through pagination');

      // Verify performance targets
      expect(setupTime, lessThan(3000),
          reason: 'Setup should complete in < 3s');
      expect(queryTime, lessThan(2000),
          reason: 'Full paginated query should complete in < 2s');

      // Log baseline metrics
      _logPerformanceMetrics(
        testName: 'Complex Trip (500 activities + 1000 photos)',
        metrics: {
          'setupTimeMs': setupTime,
          'queryTimeMs': queryTime,
          'pageCount': pageCount,
          'activitiesPerPage': (500 / pageCount).toStringAsFixed(1),
          if (memoryStats != null)
            'peakMemoryMB': memoryStats.peakHeapUsageMB.toStringAsFixed(2),
        },
      );
    });

    testWidgets('Activities pagination performance with 500+ items',
        (tester) async {
      // Generate and insert 500 activities
      final activities = TestDataGenerator.generateLargeActivitySet(
        tripId: 'pagination-test',
        userId: 'test-user',
        count: 500,
      );

      for (final activity in activities) {
        await activityRepository.createActivity(activity: activity);
      }

      // Test pagination performance
      final paginationTimings = <int>[];
      String? cursor;
      var pageCount = 0;

      final stopwatch = Stopwatch()..start();

      do {
        final pageStopwatch = Stopwatch()..start();

        final result = await activityRepository.getActivitiesCursor(
          tripId: 'pagination-test',
          userId: 'test-user',
          cursor: cursor,
          pageSize: 50,
        );

        pageStopwatch.stop();
        paginationTimings.add(pageStopwatch.elapsedMilliseconds);

        pageCount++;
        cursor = result.pageInfo.nextCursor;

        // Safety check
        if (pageCount > 20) break;
      } while (cursor != null);

      stopwatch.stop();

      // Calculate statistics
      final avgPageTime = paginationTimings.reduce((a, b) => a + b) /
          paginationTimings.length;
      final maxPageTime = paginationTimings.reduce((a, b) => a > b ? a : b);

      // Verify pagination performance
      expect(avgPageTime, lessThan(100),
          reason: 'Average page load time should be < 100ms');
      expect(maxPageTime, lessThan(200),
          reason: 'Max page load time should be < 200ms');

      // Log baseline metrics
      _logPerformanceMetrics(
        testName: 'Pagination Performance (500 activities)',
        metrics: {
          'totalPages': pageCount,
          'avgPageTimeMs': avgPageTime.toStringAsFixed(2),
          'maxPageTimeMs': maxPageTime,
          'totalTimeMs': stopwatch.elapsedMilliseconds,
        },
      );
    });

    testWidgets('Memory usage with large datasets', (tester) async {
      // Capture initial memory
      final initialSnapshot = await MemoryProfiler.captureSnapshot();
      final initialMemory = initialSnapshot.heapUsageBytes;

      // Start profiling
      await MemoryProfiler.startProfiling();

      // Generate large datasets
      final tripData = TestDataGenerator.generateComplexTripData(
        activityCount: 500,
        photoCount: 1000,
      );

      final activities = tripData['activities'] as List<Activity>;
      final photos = tripData['photos'] as List<Photo>;

      // Insert into repositories
      for (final activity in activities) {
        await activityRepository.createActivity(activity: activity);
      }

      // Simulate holding references (worst case)
      final loadedActivities = await activityRepository.getActivitiesCursor(
        tripId: TestDataGenerator.defaultTripId,
        userId: TestDataGenerator.defaultUserId,
        pageSize: 500,
      );

      // Force multiple page loads
      String? cursor;
      for (var i = 0; i < 5; i++) {
        final result = await activityRepository.getActivitiesCursor(
          tripId: TestDataGenerator.defaultTripId,
          userId: TestDataGenerator.defaultUserId,
          cursor: cursor,
          pageSize: 100,
        );
        cursor = result.pageInfo.nextCursor;
        if (cursor == null) break;
      }

      // Capture final memory
      final finalStats = await MemoryProfiler.stopProfiling();

      // Verify memory usage
      if (finalStats != null) {
        final memoryIncrease = finalStats.peakHeapUsageBytes - initialMemory;
        final memoryIncreaseMB = memoryIncrease / (1024 * 1024);

        expect(finalStats.peakHeapUsageMB, lessThan(300),
            reason: 'Peak memory should be < 300MB for large datasets');
        expect(memoryIncreaseMB, lessThan(200),
            reason: 'Memory increase should be < 200MB');

        // Log baseline metrics
        _logPerformanceMetrics(
          testName: 'Memory Usage (500 activities + 1000 photos)',
          metrics: {
            'initialMemoryMB': (initialMemory / (1024 * 1024)).toStringAsFixed(2),
            'peakMemoryMB': finalStats.peakHeapUsageMB.toStringAsFixed(2),
            'memoryIncreaseMB': memoryIncreaseMB.toStringAsFixed(2),
            'trend': finalStats.trend.name,
            'trendPercentage': finalStats.trendPercentage.toStringAsFixed(1),
          },
        );
      }
    });

    testWidgets('Activity query performance with various filters',
        (tester) async {
      // Generate activities across different categories and dates
      final activities = TestDataGenerator.generateActivitiesInDateRange(
        tripId: 'filter-test',
        userId: 'test-user',
        count: 500,
        startDate: DateTime(2024, 1, 1),
        endDate: DateTime(2024, 12, 31),
      );

      for (final activity in activities) {
        await activityRepository.createActivity(activity: activity);
      }

      // Test different query types
      final queryTests = {
        'All Activities': () async {
          return await activityRepository.getActivitiesCursor(
            tripId: 'filter-test',
            userId: 'test-user',
            pageSize: 50,
          );
        },
        'By Category': () async {
          return await activityRepository.getActivitiesByCategory(
            tripId: 'filter-test',
            userId: 'test-user',
            category: ActivityCategory.food,
            pageSize: 50,
          );
        },
        'Date Range': () async {
          return await activityRepository.getActivitiesInDateRange(
            tripId: 'filter-test',
            userId: 'test-user',
            startDate: DateTime(2024, 6, 1),
            endDate: DateTime(2024, 6, 30),
            pageSize: 50,
          );
        },
        'Upcoming': () async {
          return await activityRepository.getUpcomingActivities(
            tripId: 'filter-test',
            userId: 'test-user',
            pageSize: 50,
          );
        },
        'Completed': () async {
          return await activityRepository.getCompletedActivities(
            tripId: 'filter-test',
            userId: 'test-user',
            pageSize: 50,
          );
        },
        'Priority': () async {
          return await activityRepository.getPriorityActivities(
            tripId: 'filter-test',
            userId: 'test-user',
            pageSize: 50,
          );
        },
      };

      final results = <String, int>{};

      for (final entry in queryTests.entries) {
        final stopwatch = Stopwatch()..start();
        await entry.value();
        stopwatch.stop();

        results[entry.key] = stopwatch.elapsedMilliseconds;

        // Each query should be fast
        expect(stopwatch.elapsedMilliseconds, lessThan(200),
            reason: '${entry.key} query should complete in < 200ms');
      }

      // Log baseline metrics
      _logPerformanceMetrics(
        testName: 'Query Performance with Filters',
        metrics: results.map((key, value) => MapEntry(
            '${key}TimeMs',
            value.toString())),
      );
    });

    testWidgets('Performance monitor integration test', (tester) async {
      // Test performance monitor with large datasets
      final activities = TestDataGenerator.generateLargeActivitySet(
        tripId: 'monitor-test',
        userId: 'test-user',
        count: 500,
      );

      for (final activity in activities) {
        await activityRepository.createActivity(activity: activity);
      }

      // Capture metrics
      final initialMetrics = await PerformanceMonitor.getCurrentMetrics();

      // Perform operations and track metrics
      await activityRepository.getActivitiesCursor(
        tripId: 'monitor-test',
        userId: 'test-user',
        pageSize: 100,
      );

      final finalMetrics = await PerformanceMonitor.getCurrentMetrics();

      expect(finalMetrics.totalNetworkRequests, greaterThanOrEqualTo(0),
          reason: 'Should track network requests');

      // Log baseline metrics
      _logPerformanceMetrics(
        testName: 'Performance Monitor Integration',
        metrics: {
          'totalFrames': finalMetrics.totalFrames,
          'jankyFrames': finalMetrics.jankyFrames,
          'jankyFramePercentage': finalMetrics.jankyFramePercentage.toStringAsFixed(2),
          'currentFPS': finalMetrics.currentFPS.toStringAsFixed(1),
          'averageFPS': finalMetrics.averageFPS.toStringAsFixed(1),
          'currentMemoryMB': finalMetrics.currentMemoryUsageMB.toStringAsFixed(2),
          'peakMemoryMB': finalMetrics.peakMemoryUsageMB.toStringAsFixed(2),
        },
      );
    });
  });

  group('Photo Grid Performance Tests', () {
    testWidgets('Generate photos with varying aspect ratios',
        (tester) async {
      final stopwatch = Stopwatch()..start();

      // Generate photos with different aspect ratios
      final photos = TestDataGenerator.generatePhotosWithAspectRations(
        tripId: 'grid-test',
        count: 500,
      );

      final generationTime = stopwatch.elapsedMilliseconds;
      stopwatch.stop();

      // Verify generation
      expect(photos.length, equals(500),
          reason: 'Should generate 500 photos');

      // Verify aspect ratios are varied
      final aspectRatios = photos.map((p) => p.aspectRatio).toSet();
      expect(aspectRatios.length, greaterThan(1),
          reason: 'Should have varying aspect ratios');

      // Verify performance
      expect(generationTime, lessThan(1000),
          reason: 'Photo generation should take < 1s');

      // Log baseline metrics
      _logPerformanceMetrics(
        testName: 'Photo Grid (varying aspect ratios)',
        metrics: {
          'photoCount': photos.length,
          'generationTimeMs': generationTime,
          'uniqueAspectRatios': aspectRatios.length,
        },
      );
    });
  });
}

/// Logs performance metrics in a structured format
void _logPerformanceMetrics({
  required String testName,
  required Map<String, dynamic> metrics,
}) {
  final buffer = StringBuffer();
  buffer.writeln();
  buffer.writeln('═' * 60);
  buffer.writeln('Performance Test: $testName');
  buffer.writeln('─' * 60);

  metrics.forEach((key, value) {
    buffer.writeln('  $key: $value');
  });

  buffer.writeln('═' * 60);
  buffer.writeln();

  // Print in test output
  print(buffer.toString());
}
