import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:solo_adventurer/core/monitoring/performance/memory_profiler.dart';
import 'package:solo_adventurer/core/models/paginated_data.dart';
import 'package:solo_adventurer/core/models/map_marker.dart';
import 'package:solo_adventurer/core/services/map_marker_clustering_service.dart';
import 'package:solo_adventurer/core/services/map_viewport_loader.dart';
import 'package:solo_adventurer/core/services/zoom_aware_clustering_manager.dart';
import 'package:solo_adventurer/core/widgets/widgets.dart';
import 'package:solo_adventurer/features/travel/domain/models/activity.dart';
import 'package:solo_adventurer/features/travel/domain/models/photo.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'test_data_generators.dart';

/// Integration tests for memory leak detection
///
/// These tests detect memory leaks during common user flows by:
/// - Performing repeated operations (scrolling, navigation, data loading)
/// - Capturing memory snapshots before, during, and after operations
/// - Verifying memory returns to baseline after disposal
/// - Detecting gradual memory growth over multiple iterations
///
/// A memory leak is indicated when:
/// - Memory grows consistently across iterations (> 10% per cycle)
/// - Memory doesn't return to baseline after widget disposal
/// - Memory trend shows continuous growth without recovery
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Memory Leak Detection Tests', () {
    late ProviderContainer container;

    setUp(() async {
      // Create test container
      container = ProviderContainer();
    });

    tearDown(() async {
      container.dispose();
    });

    testWidgets('Activities screen - No memory leaks during scrolling',
        (tester) async {
      // Baseline memory before any operations
      final baselineSnapshot = await MemoryProfiler.captureSnapshot();
      final baselineMemory = baselineSnapshot.heapUsageBytes;

      await MemoryProfiler.startProfiling();

      // Generate large activity set (500 items)
      final activities = TestDataGenerator.generateLargeActivitySet(
        tripId: 'memory-leak-test-activities',
        userId: 'test-user',
        count: 500,
      );

      // Create mock fetch function
      Future<PaginatedData<Activity>> fetchActivities(String? cursor) async {
        await Future.delayed(const Duration(milliseconds: 100));
        final page = cursor == null ? 1 : int.parse(cursor);
        final pageSize = 20;
        final startIndex = (page - 1) * pageSize;

        if (startIndex >= activities.length) {
          return PaginatedData(
            items: [],
            pageInfo: PageInfo(
              currentPage: page,
              itemsPerPage: pageSize,
              totalItems: activities.length,
              totalPages: (activities.length / pageSize).ceil(),
              hasNextPage: false,
              hasPreviousPage: page > 1,
              nextCursor: null,
              previousCursor: page > 1 ? '${page - 1}' : null,
            ),
          );
        }

        final endIndex = (startIndex + pageSize).clamp(0, activities.length);
        final pageActivities = activities.sublist(startIndex, endIndex);

        return PaginatedData(
          items: pageActivities,
          pageInfo: PageInfo(
            currentPage: page,
            itemsPerPage: pageSize,
            totalItems: activities.length,
            totalPages: (activities.length / pageSize).ceil(),
            hasNextPage: endIndex < activities.length,
            hasPreviousPage: page > 1,
            nextCursor: endIndex < activities.length ? '$page' : null,
            previousCursor: page > 1 ? '${page - 1}' : null,
          ),
        );
      }

      // Perform multiple cycles of scrolling and disposal
      final memorySnapshots = <MemorySnapshot>[];

      for (var cycle = 0; cycle < 3; cycle++) {
        // Build and pump the activities screen
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: InfiniteScrollListView<Activity>(
                  fetchFunction: fetchActivities,
                  itemBuilder: (context, activity, index) {
                    return ListTile(
                      title: Text(activity.title),
                      subtitle: Text(activity.locationName ?? 'No location'),
                      trailing: Text(activity.category.name),
                    );
                  },
                  loadingWidget: () => const CircularProgressIndicator(),
                  errorWidget: (error, retry) => Text('Error: $error'),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Scroll through multiple pages
        for (var i = 0; i < 5; i++) {
          await tester.fling(
            find.byType(InfiniteScrollListView<Activity>),
            const Offset(0, -500),
            10000,
          );
          await tester.pumpAndSettle(const Duration(seconds: 1));
        }

        // Capture memory after scrolling
        final snapshot = await MemoryProfiler.captureSnapshot();
        memorySnapshots.add(snapshot);

        // Dispose the widget
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(home: Scaffold()),
          ),
        );
        await tester.pumpAndSettle();

        // Force garbage collection hint
        await Future.delayed(const Duration(milliseconds: 500));
      }

      final finalStats = await MemoryProfiler.stopProfiling();

      // Verify no memory leak
      // Memory should not grow consistently (> 10% per cycle)
      if (memorySnapshots.length >= 2) {
        final firstCycle = memorySnapshots[0].heapUsageBytes;
        final lastCycle = memorySnapshots.last.heapUsageBytes;
        final growth = ((lastCycle - firstCycle) / firstCycle) * 100;

        expect(
          growth,
          lessThan(30), // Allow some growth but not 30%+ over 3 cycles
          reason: 'Memory should not grow consistently across cycles. '
              'Growth: ${growth.toStringAsFixed(1)}%',
        );
      }

      // Final memory should be within reasonable bounds of baseline
      if (finalStats != null) {
        final finalMemory = finalStats.currentHeapUsageBytes;
        final totalGrowth = ((finalMemory - baselineMemory) / baselineMemory) * 100;

        expect(
          totalGrowth,
          lessThan(50), // Allow up to 50% total growth for 500 items
          reason: 'Total memory growth should be reasonable. '
              'Baseline: ${(baselineMemory / (1024 * 1024)).toStringAsFixed(2)} MB, '
              'Final: ${(finalMemory / (1024 * 1024)).toStringAsFixed(2)} MB, '
              'Growth: ${totalGrowth.toStringAsFixed(1)}%',
        );

        // Trend should not be consistently increasing
        expect(
          finalStats.trend,
          isNot(MemoryTrend.increasing),
          reason: 'Memory trend should not be increasing after disposal',
        );
      }

      _logMemoryTestResults(
        testName: 'Activities Screen Memory Leak Test',
        baselineMemory: baselineMemory,
        finalStats: finalStats,
        snapshots: memorySnapshots,
      );
    });

    testWidgets('Photo gallery - No memory leaks during image loading',
        (tester) async {
      // Baseline memory before any operations
      final baselineSnapshot = await MemoryProfiler.captureSnapshot();
      final baselineMemory = baselineSnapshot.heapUsageBytes;

      await MemoryProfiler.startProfiling();

      // Generate large photo set (300 items with varied aspect ratios)
      final photos = TestDataGenerator.generatePhotosWithAspectRations(
        tripId: 'memory-leak-test-photos',
        count: 300,
      );

      // Create mock fetch function
      Future<PaginatedData<Photo>> fetchPhotos(String? cursor) async {
        await Future.delayed(const Duration(milliseconds: 100));
        final page = cursor == null ? 1 : int.parse(cursor);
        final pageSize = 20;
        final startIndex = (page - 1) * pageSize;

        if (startIndex >= photos.length) {
          return PaginatedData(
            items: [],
            pageInfo: PageInfo(
              currentPage: page,
              itemsPerPage: pageSize,
              totalItems: photos.length,
              totalPages: (photos.length / pageSize).ceil(),
              hasNextPage: false,
              hasPreviousPage: page > 1,
              nextCursor: null,
              previousCursor: page > 1 ? '${page - 1}' : null,
            ),
          );
        }

        final endIndex = (startIndex + pageSize).clamp(0, photos.length);
        final pagePhotos = photos.sublist(startIndex, endIndex);

        return PaginatedData(
          items: pagePhotos,
          pageInfo: PageInfo(
            currentPage: page,
            itemsPerPage: pageSize,
            totalItems: photos.length,
            totalPages: (photos.length / pageSize).ceil(),
            hasNextPage: endIndex < photos.length,
            hasPreviousPage: page > 1,
            nextCursor: endIndex < photos.length ? '$page' : null,
            previousCursor: page > 1 ? '${page - 1}' : null,
          ),
        );
      }

      // Perform multiple cycles of image loading and disposal
      final memorySnapshots = <MemorySnapshot>[];

      for (var cycle = 0; cycle < 3; cycle++) {
        // Build and pump the photo gallery screen
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                body: InfiniteScrollGridView<Photo>(
                  fetchFunction: fetchPhotos,
                  itemBuilder: (context, photo, index) {
                    return Card(
                      clipBehavior: Clip.antiAlias,
                      child: LazyLoadImage(
                        imageUrl: photo.imageUrl,
                        placeholder: (context) => Container(
                          color: Colors.grey[300],
                          child: const Center(
                            child: CircularProgressIndicator(),
                          ),
                        ),
                        errorWidget: (context, error, stackTrace) {
                          return Container(
                            color: Colors.grey[300],
                            child: const Icon(Icons.error),
                          );
                        },
                      ),
                    );
                  },
                  crossAxisCount: 3,
                  mainAxisSpacing: 4,
                  crossAxisSpacing: 4,
                  loadingWidget: () => const CircularProgressIndicator(),
                  errorWidget: (error, retry) => Text('Error: $error'),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Scroll through multiple pages
        for (var i = 0; i < 5; i++) {
          await tester.fling(
            find.byType(InfiniteScrollGridView<Photo>),
            const Offset(0, -500),
            10000,
          );
          await tester.pumpAndSettle(const Duration(seconds: 1));
        }

        // Capture memory after loading images
        final snapshot = await MemoryProfiler.captureSnapshot();
        memorySnapshots.add(snapshot);

        // Dispose the widget
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(home: Scaffold()),
          ),
        );
        await tester.pumpAndSettle();

        // Force garbage collection hint
        await Future.delayed(const Duration(milliseconds: 500));
      }

      final finalStats = await MemoryProfiler.stopProfiling();

      // Verify no memory leak from image caching
      if (memorySnapshots.length >= 2) {
        final firstCycle = memorySnapshots[0].heapUsageBytes;
        final lastCycle = memorySnapshots.last.heapUsageBytes;
        final growth = ((lastCycle - firstCycle) / firstCycle) * 100;

        expect(
          growth,
          lessThan(30),
          reason: 'Memory should not grow consistently across image loading cycles. '
              'Growth: ${growth.toStringAsFixed(1)}%',
        );
      }

      // Final memory should be within reasonable bounds
      if (finalStats != null) {
        final finalMemory = finalStats.currentHeapUsageBytes;
        final totalGrowth = ((finalMemory - baselineMemory) / baselineMemory) * 100;

        // Images are cached, so allow more growth but not excessive
        expect(
          totalGrowth,
          lessThan(100), // Allow up to 100% growth for 300 cached photos
          reason: 'Total memory growth should be reasonable for cached images. '
              'Baseline: ${(baselineMemory / (1024 * 1024)).toStringAsFixed(2)} MB, '
              'Final: ${(finalMemory / (1024 * 1024)).toStringAsFixed(2)} MB, '
              'Growth: ${totalGrowth.toStringAsFixed(1)}%',
        );
      }

      _logMemoryTestResults(
        testName: 'Photo Gallery Memory Leak Test',
        baselineMemory: baselineMemory,
        finalStats: finalStats,
        snapshots: memorySnapshots,
      );
    });

    testWidgets('Map screen - No memory leaks during marker navigation',
        (tester) async {
      // Baseline memory before any operations
      final baselineSnapshot = await MemoryProfiler.captureSnapshot();
      final baselineMemory = baselineSnapshot.heapUsageBytes;

      await MemoryProfiler.startProfiling();

      // Generate clustered activities (200 markers)
      final activities = TestDataGenerator.generateClusteredActivities(
        tripId: 'memory-leak-test-map',
        userId: 'test-user',
        count: 200,
      );

      // Convert to map markers
      final markers = activities.map((activity) {
        return MapMarker(
          id: activity.id,
          position: LatLng(activity.latitude!, activity.longitude!),
          title: activity.title,
          type: _getMarkerTypeFromCategory(activity.category),
        );
      }).toList();

      // Perform multiple cycles of map navigation and disposal
      final memorySnapshots = <MemorySnapshot>[];

      for (var cycle = 0; cycle < 3; cycle++) {
        late ZoomAwareClusteringManager clusteringManager;
        late MapViewportLoader viewportLoader;

        // Build and pump the map screen with clustering
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: _TestMapScreen(
                markers: markers,
                onClusteringCreated: (manager, loader) {
                  clusteringManager = manager;
                  viewportLoader = loader;
                },
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Simulate map navigation (pan and zoom)
        final mapController = MapController();
        for (var i = 0; i < 5; i++) {
          // Pan map
          final center = LatLng(37.7749 + (i * 0.01), -122.4194 + (i * 0.01));
          mapController.move(center, 12.0 + (i % 3));
          await tester.pumpAndSettle(const Duration(milliseconds: 500));
        }

        // Capture memory after navigation
        final snapshot = await MemoryProfiler.captureSnapshot();
        memorySnapshots.add(snapshot);

        // Dispose managers
        await clusteringManager.dispose();
        await viewportLoader.dispose();
        await mapController.dispose();

        // Dispose the widget
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(home: Scaffold()),
          ),
        );
        await tester.pumpAndSettle();

        // Force garbage collection hint
        await Future.delayed(const Duration(milliseconds: 500));
      }

      final finalStats = await MemoryProfiler.stopProfiling();

      // Verify no memory leak from map markers
      if (memorySnapshots.length >= 2) {
        final firstCycle = memorySnapshots[0].heapUsageBytes;
        final lastCycle = memorySnapshots.last.heapUsageBytes;
        final growth = ((lastCycle - firstCycle) / firstCycle) * 100;

        expect(
          growth,
          lessThan(30),
          reason: 'Memory should not grow consistently across map navigation cycles. '
              'Growth: ${growth.toStringAsFixed(1)}%',
        );
      }

      // Final memory should be within reasonable bounds
      if (finalStats != null) {
        final finalMemory = finalStats.currentHeapUsageBytes;
        final totalGrowth = ((finalMemory - baselineMemory) / baselineMemory) * 100;

        expect(
          totalGrowth,
          lessThan(50), // Allow up to 50% growth for 200 markers
          reason: 'Total memory growth should be reasonable for map markers. '
              'Baseline: ${(baselineMemory / (1024 * 1024)).toStringAsFixed(2)} MB, '
              'Final: ${(finalMemory / (1024 * 1024)).toStringAsFixed(2)} MB, '
              'Growth: ${totalGrowth.toStringAsFixed(1)}%',
        );

        // Trend should not be consistently increasing
        expect(
          finalStats.trend,
          isNot(MemoryTrend.increasing),
          reason: 'Memory trend should not be increasing after disposal',
        );
      }

      _logMemoryTestResults(
        testName: 'Map Screen Memory Leak Test',
        baselineMemory: baselineMemory,
        finalStats: finalStats,
        snapshots: memorySnapshots,
      );
    });

    testWidgets('Repeated widget creation/disposal - No memory leaks',
        (tester) async {
      // Baseline memory
      final baselineSnapshot = await MemoryProfiler.captureSnapshot();
      final baselineMemory = baselineSnapshot.heapUsageBytes;

      await MemoryProfiler.startProfiling();

      final memorySnapshots = <MemorySnapshot>[];

      // Rapidly create and dispose widgets 20 times
      for (var i = 0; i < 20; i++) {
        // Create complex widget hierarchy
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: MaterialApp(
              home: Scaffold(
                appBar: AppBar(title: const Text('Test $i')),
                body: ListView.builder(
                  itemCount: 100,
                  itemBuilder: (context, index) {
                    return ListTile(
                      title: Text('Item $index'),
                      subtitle: Text('Subtitle $index'),
                      leading: const Icon(Icons.star),
                      trailing: const Icon(Icons.arrow_forward),
                    );
                  },
                ),
                floatingActionButton: FloatingActionButton(
                  onPressed: () {},
                  child: const Icon(Icons.add),
                ),
              ),
            ),
          ),
        );

        await tester.pumpAndSettle();

        // Capture memory every 5 iterations
        if (i % 5 == 0) {
          final snapshot = await MemoryProfiler.captureSnapshot();
          memorySnapshots.add(snapshot);
        }

        // Dispose
        await tester.pumpWidget(
          UncontrolledProviderScope(
            container: container,
            child: const MaterialApp(home: Scaffold()),
          ),
        );
        await tester.pumpAndSettle();
      }

      final finalStats = await MemoryProfiler.stopProfiling();

      // Memory should remain stable across many create/dispose cycles
      if (memorySnapshots.length >= 2) {
        final firstSnapshot = memorySnapshots[0].heapUsageBytes;
        final lastSnapshot = memorySnapshots.last.heapUsageBytes;
        final growth = ((lastSnapshot - firstSnapshot) / firstSnapshot) * 100;

        expect(
          growth,
          lessThan(15), // Very strict for widget creation cycles
          reason: 'Memory should remain stable across widget creation cycles. '
              'Growth: ${growth.toStringAsFixed(1)}%',
        );
      }

      // Final memory should be close to baseline
      if (finalStats != null) {
        final finalMemory = finalStats.currentHeapUsageBytes;
        final totalGrowth = ((finalMemory - baselineMemory) / baselineMemory) * 100;

        expect(
          totalGrowth,
          lessThan(20), // Allow up to 20% total growth
          reason: 'Final memory should be close to baseline after widget cycles. '
              'Baseline: ${(baselineMemory / (1024 * 1024)).toStringAsFixed(2)} MB, '
              'Final: ${(finalMemory / (1024 * 1024)).toStringAsFixed(2)} MB, '
              'Growth: ${totalGrowth.toStringAsFixed(1)}%',
        );

        // Trend should be stable or decreasing
        expect(
          finalStats.trend,
          isNot(MemoryTrend.increasing),
          reason: 'Memory trend should be stable or decreasing after widget disposal cycles',
        );
      }

      _logMemoryTestResults(
        testName: 'Widget Creation/Disposal Memory Leak Test',
        baselineMemory: baselineMemory,
        finalStats: finalStats,
        snapshots: memorySnapshots,
      );
    });

    testWidgets('Stream subscription memory leak test', (tester) async {
      // Baseline memory
      final baselineSnapshot = await MemoryProfiler.captureSnapshot();
      final baselineMemory = baselineSnapshot.heapUsageBytes;

      await MemoryProfiler.startProfiling();

      final memorySnapshots = <MemorySnapshot>[];

      // Create and dispose stream subscriptions multiple times
      for (var cycle = 0; cycle < 5; cycle++) {
        final manager = ZoomAwareClusteringManager(
          markers: [],
          clusteringParams: ClusteringParams.forZoomLevel(zoomLevel: 12),
        );

        // Subscribe to stream
        final subscription = manager.clusteringStream.listen((result) {
          // Sink to prevent unused warning
        });

        // Trigger multiple updates
        for (var i = 0; i < 10; i++) {
          manager.updateBounds(
            LatLngBounds(
              LatLng(37.7 + (i * 0.01), -122.4 + (i * 0.01)),
              LatLng(37.8 + (i * 0.01), -122.5 + (i * 0.01)),
            ),
          );
        }

        await tester.pumpAndSettle(const Duration(milliseconds: 100));

        // Capture memory
        if (cycle % 2 == 0) {
          final snapshot = await MemoryProfiler.captureSnapshot();
          memorySnapshots.add(snapshot);
        }

        // Cancel subscription and dispose
        await subscription.cancel();
        await manager.dispose();

        await tester.pumpAndSettle();
      }

      final finalStats = await MemoryProfiler.stopProfiling();

      // Verify no memory leak from stream subscriptions
      if (memorySnapshots.length >= 2) {
        final firstSnapshot = memorySnapshots[0].heapUsageBytes;
        final lastSnapshot = memorySnapshots.last.heapUsageBytes;
        final growth = ((lastSnapshot - firstSnapshot) / firstSnapshot) * 100;

        expect(
          growth,
          lessThan(20),
          reason: 'Memory should not grow from stream subscription cycles. '
              'Growth: ${growth.toStringAsFixed(1)}%',
        );
      }

      // Final memory should be close to baseline
      if (finalStats != null) {
        final finalMemory = finalStats.currentHeapUsageBytes;
        final totalGrowth = ((finalMemory - baselineMemory) / baselineMemory) * 100;

        expect(
          totalGrowth,
          lessThan(25),
          reason: 'Final memory should be close to baseline after stream cycles. '
              'Growth: ${totalGrowth.toStringAsFixed(1)}%',
        );
      }

      _logMemoryTestResults(
        testName: 'Stream Subscription Memory Leak Test',
        baselineMemory: baselineMemory,
        finalStats: finalStats,
        snapshots: memorySnapshots,
      );
    });
  });
}

/// Test map screen wrapper for memory leak testing
class _TestMapScreen extends StatefulWidget {
  final List<MapMarker> markers;
  final void Function(ZoomAwareClusteringManager, MapViewportLoader) onClusteringCreated;

  const _TestMapScreen({
    required this.markers,
    required this.onClusteringCreated,
  });

  @override
  State<_TestMapScreen> createState() => _TestMapScreenState();
}

class _TestMapScreenState extends State<_TestMapScreen> {
  late ZoomAwareClusteringManager _clusteringManager;
  late MapViewportLoader _viewportLoader;
  final MapController _mapController = MapController();

  @override
  void initState() {
    super.initState();
    _initializeClustering();
  }

  void _initializeClustering() {
    // Create viewport loader
    _viewportLoader = MapViewportLoader(
      allMarkers: widget.markers,
      config: const ViewportLoaderConfig(
        bufferRatio: 0.3,
        debounceDelay: Duration(milliseconds: 200),
      ),
    );

    // Create clustering manager
    _clusteringManager = ZoomAwareClusteringManager(
      markers: [],
      clusteringParams: ClusteringParams.forZoomLevel(zoomLevel: 12),
    );

    // Notify parent
    widget.onClusteringCreated(_clusteringManager, _viewportLoader);

    // Initialize viewport
    final initialBounds = LatLngBounds(
      const LatLng(37.7, -122.5),
      const LatLng(37.8, -122.4),
    );
    _viewportLoader.initialize(initialBounds);
  }

  @override
  void dispose() {
    _clusteringManager.dispose();
    _viewportLoader.dispose();
    _mapController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FlutterMap(
        mapController: _mapController,
        options: MapOptions(
          center: const LatLng(37.7749, -122.4194),
          zoom: 12.0,
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          ),
        ],
      ),
    );
  }
}

/// Helper to get marker type from activity category
MarkerType _getMarkerTypeFromCategory(ActivityCategory category) {
  switch (category) {
    case ActivityCategory.accommodation:
      return MarkerType.accommodation;
    case ActivityCategory.food:
      return MarkerType.restaurant;
    case ActivityCategory.transport:
      return MarkerType.transport;
    case ActivityCategory.activity:
      return MarkerType.activity;
    default:
      return MarkerType.poi;
  }
}

/// Logs memory test results in a structured format
void _logMemoryTestResults({
  required String testName,
  required int baselineMemory,
  required MemoryStatistics? finalStats,
  required List<MemorySnapshot> snapshots,
}) {
  final buffer = StringBuffer();
  buffer.writeln();
  buffer.writeln('═' * 70);
  buffer.writeln('Memory Leak Test: $testName');
  buffer.writeln('─' * 70);

  // Baseline
  buffer.writeln('Baseline Memory: ${(baselineMemory / (1024 * 1024)).toStringAsFixed(2)} MB');

  // Final stats
  if (finalStats != null) {
    buffer.writeln('Final Memory: ${finalStats.currentHeapUsageMB.toStringAsFixed(2)} MB');
    buffer.writeln('Peak Memory: ${finalStats.peakHeapUsageMB.toStringAsFixed(2)} MB');
    buffer.writeln('Average Memory: ${finalStats.averageHeapUsageMB.toStringAsFixed(2)} MB');
    buffer.writeln('Trend: ${finalStats.trend.name} (${finalStats.trendPercentage.toStringAsFixed(1)}%)');
    buffer.writeln('Snapshots: ${finalStats.snapshotCount}');

    final totalGrowth = ((finalStats.currentHeapUsageBytes - baselineMemory) / baselineMemory) * 100;
    buffer.writeln('Total Growth: ${totalGrowth.toStringAsFixed(1)}%');
  }

  // Individual snapshots
  if (snapshots.isNotEmpty) {
    buffer.writeln();
    buffer.writeln('Cycle Snapshots:');
    for (var i = 0; i < snapshots.length; i++) {
      final snapshot = snapshots[i];
      final growth = ((snapshot.heapUsageBytes - baselineMemory) / baselineMemory) * 100;
      buffer.writeln(
        '  Cycle ${i + 1}: ${snapshot.heapUsageMB.toStringAsFixed(2)} MB '
        '(${growth >= 0 ? '+' : ''}${growth.toStringAsFixed(1)}%)',
      );
    }
  }

  buffer.writeln('═' * 70);
  buffer.writeln();

  // Print in test output
  print(buffer.toString());
}
