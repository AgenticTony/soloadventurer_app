import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:soloadventurer/features/travel/domain/models/trip.dart';
import 'package:soloadventurer_test/utils/performance/performance_test_utils.dart';

/// Performance baseline tests for large datasets
///
/// This test suite establishes baseline performance metrics for the app
/// when handling large datasets (500+ items). Metrics include:
/// - Memory usage with large datasets
/// - List rendering times
/// - Scroll performance
/// - Data generation performance
///
/// Run these tests to establish performance baselines before optimization
/// and to validate that performance meets target criteria.
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Performance Baseline Tests', () {
    test('Memory usage with 500 trips loaded', () async {
      // Generate large dataset
      final trips = PerformanceTestDataGenerator.generateLargeTripList(
        count: 500,
      );

      // Capture initial memory
      final initialMemory = await PerformanceReporter.captureMemoryUsage();
      debugPrint('Initial memory: ${(initialMemory / 1024 / 1024).toStringAsFixed(2)} MB');

      // Load all trips into memory
      final loadedTrips = <Trip>[];
      for (final trip in trips) {
        loadedTrips.add(trip);
      }

      // Capture memory after loading
      final finalMemory = await PerformanceReporter.captureMemoryUsage();
      final memoryDelta = finalMemory - initialMemory;

      debugPrint('Memory after loading 500 trips: ${(finalMemory / 1024 / 1024).toStringAsFixed(2)} MB');
      debugPrint('Memory delta: ${(memoryDelta / 1024 / 1024).toStringAsFixed(2)} MB');

      // Verify memory usage is reasonable
      // Target: Memory increase should be less than 50MB for 500 simple trip objects
      expect(
        memoryDelta,
        lessThan(50 * 1024 * 1024),
        reason: 'Memory usage for 500 trips should be less than 50MB',
      );

      // Log baseline metric
      debugPrint('BASELINE: Memory for 500 trips = ${(memoryDelta / 1024 / 1024).toStringAsFixed(2)} MB');
    });

    test('Memory usage with 500 photo URLs loaded', () async {
      // Generate large dataset
      final photoUrls = PhotoDataGenerator.generatePhotoUrls(count: 500);

      // Capture initial memory
      final initialMemory = await PerformanceReporter.captureMemoryUsage();
      debugPrint('Initial memory: ${(initialMemory / 1024 / 1024).toStringAsFixed(2)} MB');

      // Load all photo URLs into memory
      final loadedUrls = <String>[];
      for (final url in photoUrls) {
        loadedUrls.add(url);
      }

      // Capture memory after loading
      final finalMemory = await PerformanceReporter.captureMemoryUsage();
      final memoryDelta = finalMemory - initialMemory;

      debugPrint('Memory after loading 500 photo URLs: ${(finalMemory / 1024 / 1024).toStringAsFixed(2)} MB');
      debugPrint('Memory delta: ${(memoryDelta / 1024 / 1024).toStringAsFixed(2)} MB');

      // Photo URLs are strings, should be very lightweight
      expect(
        memoryDelta,
        lessThan(5 * 1024 * 1024),
        reason: 'Memory usage for 500 photo URLs should be less than 5MB',
      );

      debugPrint('BASELINE: Memory for 500 photo URLs = ${(memoryDelta / 1024 / 1024).toStringAsFixed(2)} MB');
    });

    test('Memory usage with 500 photo metadata objects', () async {
      // Generate large dataset
      final photoMetadata = PhotoDataGenerator.generatePhotoMetadata(count: 500);

      // Capture initial memory
      final initialMemory = await PerformanceReporter.captureMemoryUsage();
      debugPrint('Initial memory: ${(initialMemory / 1024 / 1024).toStringAsFixed(2)} MB');

      // Load all metadata into memory
      final loadedMetadata = <Map<String, dynamic>>[];
      for (final metadata in photoMetadata) {
        loadedMetadata.add(metadata);
      }

      // Capture memory after loading
      final finalMemory = await PerformanceReporter.captureMemoryUsage();
      final memoryDelta = finalMemory - initialMemory;

      debugPrint('Memory after loading 500 photo metadata: ${(finalMemory / 1024 / 1024).toStringAsFixed(2)} MB');
      debugPrint('Memory delta: ${(memoryDelta / 1024 / 1024).toStringAsFixed(2)} MB');

      // Photo metadata contains more data, but should still be reasonable
      expect(
        memoryDelta,
        lessThan(30 * 1024 * 1024),
        reason: 'Memory usage for 500 photo metadata should be less than 30MB',
      );

      debugPrint('BASELINE: Memory for 500 photo metadata = ${(memoryDelta / 1024 / 1024).toStringAsFixed(2)} MB');
    });

    testWidgets('List rendering performance with 500 items', (tester) async {
      // Generate large dataset
      final trips = PerformanceTestDataGenerator.generateLargeTripList(
        count: 500,
      );

      // Measure list creation and rendering time
      final renderTime = await PerformanceReporter.measureTime(
        'List rendering',
        () async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ListView.builder(
                  itemCount: trips.length,
                  itemBuilder: (context, index) {
                    final trip = trips[index];
                    return ListTile(
                      title: Text(trip.title),
                      subtitle: Text(trip.destination),
                      trailing: Text('\$${trip.budget}'),
                    );
                  },
                ),
              ),
            ),
          );

          // Wait for list to render
          await tester.pumpAndSettle();
        },
      );

      debugPrint('List render time: ${renderTime.inMilliseconds}ms');

      // Target: List should render in less than 3 seconds
      expect(
        renderTime.inMilliseconds,
        lessThan(3000),
        reason: 'List of 500 items should render in less than 3 seconds',
      );

      debugPrint('BASELINE: List render time for 500 items = ${renderTime.inMilliseconds}ms');
    });

    testWidgets('Scroll performance with 500 items', (tester) async {
      // Generate large dataset
      final trips = PerformanceTestDataGenerator.generateLargeTripList(
        count: 500,
      );

      // Build the list
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                return ListTile(
                  title: Text(trip.title),
                  subtitle: Text(trip.destination),
                  trailing: Text('\$${trip.budget}'),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Measure scroll performance
      final scrollStopwatch = Stopwatch()..start();
      int jankyFrames = 0;

      // Scroll through the list in chunks
      for (int i = 0; i < 20; i++) {
        final scrollStart = DateTime.now();

        // Scroll down
        await tester.timedFind(
          find.byType(ListView),
          const Duration(seconds: 1),
        );

        // Trigger a scroll event
        await tester.drag(
          find.byType(ListView),
          Offset(0, -300),
        );
        await tester.pump();

        final scrollEnd = DateTime.now();
        final frameDuration = scrollEnd.difference(scrollStart).inMilliseconds;

        // A frame is janky if it takes longer than 16ms (60 FPS target)
        if (frameDuration > 16) {
          jankyFrames++;
        }
      }

      scrollStopwatch.stop();

      final totalFrames = 20;
      final jankyPercentage = (jankyFrames / totalFrames * 100);
      final avgFPS = totalFrames / (scrollStopwatch.elapsedMilliseconds / 1000);

      debugPrint('Scroll performance:');
      debugPrint('  Total time: ${scrollStopwatch.elapsedMilliseconds}ms');
      debugPrint('  Janky frames: $jankyFrames/$totalFrames');
      debugPrint('  Janky percentage: ${jankyPercentage.toStringAsFixed(1)}%');
      debugPrint('  Average FPS: ${avgFPS.toStringAsFixed(1)}');

      // Target: Less than 10% janky frames
      expect(
        jankyPercentage,
        lessThan(10),
        reason: 'Janky frame percentage should be less than 10%',
      );

      debugPrint('BASELINE: Scroll janky frames = ${jankyPercentage.toStringAsFixed(1)}%');
      debugPrint('BASELINE: Scroll FPS = ${avgFPS.toStringAsFixed(1)}');
    });

    test('Data generation performance', () {
      final iterations = 10;
      final timings = <int>[];

      // Measure data generation performance over multiple iterations
      for (int i = 0; i < iterations; i++) {
        final stopwatch = Stopwatch()..start();

        PerformanceTestDataGenerator.generateLargeTripList(count: 500);
        PhotoDataGenerator.generatePhotoUrls(count: 500);
        PhotoDataGenerator.generatePhotoMetadata(count: 500);

        stopwatch.stop();
        timings.add(stopwatch.elapsedMilliseconds);
      }

      final averageTime = timings.reduce((a, b) => a + b) / timings.length;
      final minTime = timings.reduce((a, b) => a < b ? a : b);
      final maxTime = timings.reduce((a, b) => a > b ? a : b);

      debugPrint('Data generation performance ($iterations iterations):');
      debugPrint('  Average: ${averageTime.toStringAsFixed(2)}ms');
      debugPrint('  Min: $minTime ms');
      debugPrint('  Max: $maxTime ms');

      // Data generation should be consistently fast
      expect(
        averageTime,
        lessThan(200),
        reason: 'Average data generation time should be less than 200ms',
      );
      expect(
        maxTime,
        lessThan(500),
        reason: 'Max data generation time should be less than 500ms',
      );

      debugPrint('BASELINE: Data generation = ${averageTime.toStringAsFixed(2)}ms avg');
    });

    test('Memory stress test with 1000 trips', () async {
      // Generate extra large dataset
      final trips = PerformanceTestDataGenerator.generateLargeTripList(
        count: 1000,
      );

      final initialMemory = await PerformanceReporter.captureMemoryUsage();
      debugPrint('Initial memory: ${(initialMemory / 1024 / 1024).toStringAsFixed(2)} MB');

      // Load all trips
      final loadedTrips = <Trip>[];
      for (final trip in trips) {
        loadedTrips.add(trip);
      }

      final finalMemory = await PerformanceReporter.captureMemoryUsage();
      final memoryDelta = finalMemory - initialMemory;

      debugPrint('Memory after loading 1000 trips: ${(finalMemory / 1024 / 1024).toStringAsFixed(2)} MB');
      debugPrint('Memory delta: ${(memoryDelta / 1024 / 1024).toStringAsFixed(2)} MB');

      // Even with 1000 trips, memory should be reasonable
      expect(
        memoryDelta,
        lessThan(100 * 1024 * 1024),
        reason: 'Memory usage for 1000 trips should be less than 100MB',
      );

      debugPrint('BASELINE: Memory for 1000 trips = ${(memoryDelta / 1024 / 1024).toStringAsFixed(2)} MB');
    });

    testWidgets('List rendering with complex items', (tester) async {
      // Generate dataset with more complex data
      final photoMetadata = PhotoDataGenerator.generatePhotoMetadata(count: 500);

      final renderTime = await PerformanceReporter.measureTime(
        'Complex list rendering',
        () async {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: ListView.builder(
                  itemCount: photoMetadata.length,
                  itemBuilder: (context, index) {
                    final photo = photoMetadata[index];
                    return Card(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              photo['title'] as String,
                              style: const TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            Text(photo['description'] as String),
                            const SizedBox(height: 4),
                            Text('📍 ${photo['location']}'),
                            Text('📅 ${photo['capturedAt']}'),
                            Text('🏷️ ${(photo['tags'] as List).join(', ')}'),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
            ),
          );

          await tester.pumpAndSettle();
        },
      );

      debugPrint('Complex list render time: ${renderTime.inMilliseconds}ms');

      // Complex items will take longer, but should still be reasonable
      expect(
        renderTime.inMilliseconds,
        lessThan(5000),
        reason: 'Complex list of 500 items should render in less than 5 seconds',
      );

      debugPrint('BASELINE: Complex list render time = ${renderTime.inMilliseconds}ms');
    });

    test('Geographic distribution performance', () {
      final stopwatch = Stopwatch()..start();

      final trips = PerformanceTestDataGenerator.generateGeographicallyDistributedTrips(
        count: 500,
      );

      stopwatch.stop();

      expect(trips.length, equals(500));
      expect(stopwatch.elapsedMilliseconds, lessThan(100));

      // Verify distribution
      final latitudes = trips.map((t) => t.latitude!).toList();
      final longitudes = trips.map((t) => t.longitude!).toList();

      final latSpread = latitudes.reduce((a, b) => a > b ? a : b) -
          latitudes.reduce((a, b) => a < b ? a : b);
      final lonSpread = longitudes.reduce((a, b) => a > b ? a : b) -
          longitudes.reduce((a, b) => a < b ? a : b);

      debugPrint('Geographic spread:');
      debugPrint('  Latitude: ${latSpread.toStringAsFixed(2)}°');
      debugPrint('  Longitude: ${lonSpread.toStringAsFixed(2)}°');
      debugPrint('  Generation time: ${stopwatch.elapsedMilliseconds}ms');

      debugPrint('BASELINE: Geographic generation = ${stopwatch.elapsedMilliseconds}ms for 500 trips');
    });

    test('Comprehensive performance baseline', () async {
      debugPrint('\n========================================');
      debugPrint('COMPREHENSIVE PERFORMANCE BASELINE');
      debugPrint('========================================\n');

      // Generate test data
      final trips = PerformanceTestDataGenerator.generateLargeTripList(count: 500);
      final photos = PhotoDataGenerator.generatePhotoMetadata(count: 500);

      // Measure 1: Memory with trips
      final memoryBeforeTrips = await PerformanceReporter.captureMemoryUsage();
      final loadedTrips = [...trips];
      final memoryAfterTrips = await PerformanceReporter.captureMemoryUsage();
      final tripMemory = memoryAfterTrips - memoryBeforeTrips;

      // Measure 2: Memory with photos
      final memoryBeforePhotos = await PerformanceReporter.captureMemoryUsage();
      final loadedPhotos = [...photos];
      final memoryAfterPhotos = await PerformanceReporter.captureMemoryUsage();
      final photoMemory = memoryAfterPhotos - memoryBeforePhotos;

      // Measure 3: Data generation speed
      final genStopwatch = Stopwatch()..start();
      PerformanceTestDataGenerator.generateLargeTripList(count: 500);
      PhotoDataGenerator.generatePhotoMetadata(count: 500);
      genStopwatch.stop();

      // Create comprehensive report
      debugPrint('PERFORMANCE BASELINE SUMMARY:');
      debugPrint('─' * 40);
      debugPrint('Dataset Size: 500 trips, 500 photos');
      debugPrint('');
      debugPrint('Memory Usage:');
      debugPrint('  Trip objects: ${(tripMemory / 1024 / 1024).toStringAsFixed(2)} MB');
      debugPrint('  Photo metadata: ${(photoMemory / 1024 / 1024).toStringAsFixed(2)} MB');
      debugPrint('  Total: ${((tripMemory + photoMemory) / 1024 / 1024).toStringAsFixed(2)} MB');
      debugPrint('');
      debugPrint('Data Generation Speed:');
      debugPrint('  Total time: ${genStopwatch.elapsedMilliseconds}ms');
      debugPrint('  Average per item: ${(genStopwatch.elapsedMilliseconds / 1000).toStringAsFixed(2)}ms');
      debugPrint('');
      debugPrint('Targets:');
      debugPrint('  ✓ Memory < 200 MB: ${(tripMemory + photoMemory) < 200 * 1024 * 1024 ? "PASS" : "FAIL"}');
      debugPrint('  ✓ Generation < 200ms: ${genStopwatch.elapsedMilliseconds < 200 ? "PASS" : "FAIL"}');
      debugPrint('');
      debugPrint('═' * 40);

      // Assert targets
      expect(tripMemory + photoMemory, lessThan(200 * 1024 * 1024));
      expect(genStopwatch.elapsedMilliseconds, lessThan(200));
    });
  });
}
