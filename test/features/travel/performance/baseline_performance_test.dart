import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../../utils/performance/performance_test_utils.dart';

/// Performance baseline tests for large datasets
///
/// Tests data generation, memory handling, and list rendering
/// with large datasets (500+ items).
void main() {
  group('Performance Baseline Tests', () {
    test('Data generation performance for trips', () {
      const iterations = 10;
      final timings = <int>[];

      for (int i = 0; i < iterations; i++) {
        final stopwatch = Stopwatch()..start();

        PerformanceTestDataGenerator.generateBatch(
          500,
          PerformanceTestDataGenerator.generateTripData,
        );

        stopwatch.stop();
        timings.add(stopwatch.elapsedMilliseconds);
      }

      final averageTime = timings.reduce((a, b) => a + b) / timings.length;

      debugPrint('Trip data generation ($iterations iterations):');
      debugPrint('  Average: ${averageTime.toStringAsFixed(2)}ms');

      expect(averageTime, lessThan(500),
          reason: 'Average generation time should be under 500ms');

      debugPrint(
          'BASELINE: Trip generation = ${averageTime.toStringAsFixed(2)}ms avg');
    });

    test('Data generation performance for photo metadata', () {
      const iterations = 10;
      final timings = <int>[];

      for (int i = 0; i < iterations; i++) {
        final stopwatch = Stopwatch()..start();

        PhotoDataGenerator.generatePhotoBatch(500);

        stopwatch.stop();
        timings.add(stopwatch.elapsedMilliseconds);
      }

      final averageTime = timings.reduce((a, b) => a + b) / timings.length;

      debugPrint('Photo metadata generation ($iterations iterations):');
      debugPrint('  Average: ${averageTime.toStringAsFixed(2)}ms');

      expect(averageTime, lessThan(500),
          reason: 'Average generation time should be under 500ms');

      debugPrint(
          'BASELINE: Photo generation = ${averageTime.toStringAsFixed(2)}ms avg');
    });

    test('Large dataset generation (1000 trips)', () {
      final stopwatch = Stopwatch()..start();

      final trips = PerformanceTestDataGenerator.generateBatch(
        1000,
        PerformanceTestDataGenerator.generateTripData,
      );

      stopwatch.stop();

      expect(trips.length, 1000);
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));

      debugPrint(
          'BASELINE: 1000 trips generated in ${stopwatch.elapsedMilliseconds}ms');
    });

    test('Photo batch generation performance', () {
      final stopwatch = Stopwatch()..start();

      final photos = PhotoDataGenerator.generatePhotoBatch(500);

      stopwatch.stop();

      expect(photos.length, 500);
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));

      debugPrint(
          'BASELINE: 500 photo metadata generated in ${stopwatch.elapsedMilliseconds}ms');
    });

    test('Trip data structure validation', () {
      final trips = PerformanceTestDataGenerator.generateBatch(
        100,
        PerformanceTestDataGenerator.generateTripData,
      );

      for (final trip in trips) {
        expect(trip, containsPair('id', isNotNull));
        expect(trip, containsPair('title', isNotNull));
        expect(trip, containsPair('latitude', isNotNull));
        expect(trip, containsPair('longitude', isNotNull));
      }
    });

    test('Photo metadata structure validation', () {
      final photos = PhotoDataGenerator.generatePhotoBatch(100);

      for (final photo in photos) {
        expect(photo, containsPair('id', isNotNull));
        expect(photo, containsPair('path', isNotNull));
        expect(photo, containsPair('width', isNotNull));
        expect(photo, containsPair('height', isNotNull));
        expect(photo, containsPair('format', isNotNull));
        expect(photo, containsPair('size', isNotNull));
      }
    });

    test('PerformanceReporter metrics tracking', () {
      final reporter = PerformanceReporter(name: 'baseline_test');

      reporter.startTimer('test_operation');
      // Simulate work
      for (int i = 0; i < 100000; i++) {
        PerformanceTestDataGenerator.generateId();
      }
      final duration = reporter.stopTimer('test_operation');

      expect(duration, isNotNull);
      expect(duration!.inMicroseconds, greaterThan(0));

      final stats = reporter.getStats('test_operation');
      expect(stats, isNotNull);
      expect(stats!.count, 1);
      expect(stats.average, greaterThan(0));

      debugPrint('BASELINE: ID generation (100k) = ${duration.inMilliseconds}ms');
    });

    test('PerformanceReporter batch timing', () {
      final reporter = PerformanceReporter(name: 'batch_test');

      for (int i = 0; i < 10; i++) {
        reporter.startTimer('batch_gen');
        PerformanceTestDataGenerator.generateBatch(
          100,
          PerformanceTestDataGenerator.generateTripData,
        );
        reporter.stopTimer('batch_gen');
      }

      final stats = reporter.getStats('batch_gen');
      expect(stats, isNotNull);
      expect(stats!.count, 10);
      expect(stats.average, greaterThan(0));

      debugPrint('Batch generation (10x100 trips):');
      debugPrint('  Avg: ${stats.average.toStringAsFixed(2)} μs');
      debugPrint('  Min: ${stats.min.toStringAsFixed(2)} μs');
      debugPrint('  Max: ${stats.max.toStringAsFixed(2)} μs');
    });

    test('Coordinates generation performance', () {
      final stopwatch = Stopwatch()..start();

      final coords = List.generate(
        500,
        (_) => PerformanceTestDataGenerator.generateCoordinates(),
      );

      stopwatch.stop();

      expect(coords.length, 500);
      for (final c in coords) {
        expect(c.latitude, inInclusiveRange(-90.0, 90.0));
        expect(c.longitude, inInclusiveRange(-180.0, 180.0));
      }

      debugPrint(
          'BASELINE: 500 coords generated in ${stopwatch.elapsedMilliseconds}ms');
    });

    test('Photo image bytes generation', () {
      final stopwatch = Stopwatch()..start();

      final bytes = PhotoDataGenerator.generateImageBytes(size: 1024 * 100); // 100KB

      stopwatch.stop();

      expect(bytes.length, 1024 * 100);
      expect(stopwatch.elapsedMilliseconds, lessThan(100));

      debugPrint(
          'BASELINE: 100KB image bytes generated in ${stopwatch.elapsedMilliseconds}ms');
    });

    testWidgets('List rendering performance with generated data',
        (tester) async {
      final trips = PerformanceTestDataGenerator.generateBatch(
        100,
        PerformanceTestDataGenerator.generateTripData,
      );

      final reporter = PerformanceReporter(name: 'list_render');

      // ignore: unused_local_variable
      final renderDuration = reporter.measureSync('render_100_items', () {
        tester.binding.scheduleFrame();
      });

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                return ListTile(
                  title: Text(trip['title'] as String),
                  subtitle: Text(trip['description'] as String),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify list rendered
      expect(find.byType(ListView), findsOneWidget);

      debugPrint('BASELINE: List with 100 items rendered');
    });

    testWidgets('Scroll performance with generated data', (tester) async {
      final trips = PerformanceTestDataGenerator.generateBatch(
        200,
        PerformanceTestDataGenerator.generateTripData,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: ListView.builder(
              itemCount: trips.length,
              itemBuilder: (context, index) {
                final trip = trips[index];
                return ListTile(
                  title: Text(trip['title'] as String),
                  subtitle: Text(trip['description'] as String),
                );
              },
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Scroll through the list
      for (int i = 0; i < 10; i++) {
        await tester.drag(
          find.byType(ListView),
          const Offset(0, -300),
        );
        await tester.pump(const Duration(milliseconds: 100));
      }

      stopwatch.stop();

      debugPrint(
          'BASELINE: 10 scrolls on 200-item list = ${stopwatch.elapsedMilliseconds}ms');

      expect(find.byType(ListView), findsOneWidget);
    });

    test('Comprehensive performance baseline', () async {
      debugPrint('\n========================================');
      debugPrint('COMPREHENSIVE PERFORMANCE BASELINE');
      debugPrint('========================================\n');

      final reporter = PerformanceReporter(name: 'comprehensive');

      // Measure 1: Trip data generation
      reporter.startTimer('trip_generation');
      final trips = PerformanceTestDataGenerator.generateBatch(
        500,
        PerformanceTestDataGenerator.generateTripData,
      );
      reporter.stopTimer('trip_generation');

      // Measure 2: Photo metadata generation
      reporter.startTimer('photo_generation');
      final photos = PhotoDataGenerator.generatePhotoBatch(500);
      reporter.stopTimer('photo_generation');

      // Measure 3: Coordinates generation
      reporter.startTimer('coords_generation');
      final coords = List.generate(
        500,
        (_) => PerformanceTestDataGenerator.generateCoordinates(),
      );
      reporter.stopTimer('coords_generation');

      // Report
      debugPrint('Dataset Size: 500 trips, 500 photos, 500 coordinates');
      debugPrint('');

      final tripStats = reporter.getStats('trip_generation');
      final photoStats = reporter.getStats('photo_generation');
      final coordsStats = reporter.getStats('coords_generation');

      if (tripStats != null) {
        debugPrint(
            'Trip generation: ${tripStats.average.toStringAsFixed(2)} μs');
      }
      if (photoStats != null) {
        debugPrint(
            'Photo generation: ${photoStats.average.toStringAsFixed(2)} μs');
      }
      if (coordsStats != null) {
        debugPrint(
            'Coords generation: ${coordsStats.average.toStringAsFixed(2)} μs');
      }

      // Assert targets
      expect(trips.length, 500);
      expect(photos.length, 500);
      expect(coords.length, 500);

      debugPrint('═' * 40);
    });
  });
}
