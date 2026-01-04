import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/auth/domain/models/user.dart';
import 'package:soloadventurer/features/travel/domain/models/trip.dart';
import 'package:soloadventurer_test/utils/performance/performance_test_utils.dart';

/// Example performance tests demonstrating the use of performance test data generators
///
/// These tests show how to use the performance testing utilities to benchmark
/// app performance with large datasets (500+ items).
void main() {
  group('Performance Data Generation Examples', () {
    test('Generate 500 trips for list rendering tests', () {
      final stopwatch = Stopwatch()..start();

      final trips = PerformanceTestDataGenerator.generateLargeTripList(
        count: 500,
      );

      stopwatch.stop();

      // Verify data generation is fast
      expect(stopwatch.elapsedMilliseconds, lessThan(100));

      // Verify correct number of trips
      expect(trips.length, equals(500));

      // Verify all trips have required fields
      for (final trip in trips) {
        expect(trip.id, isNotEmpty);
        expect(trip.userId, isNotEmpty);
        expect(trip.title, isNotEmpty);
        expect(trip.destination, isNotEmpty);
        expect(trip.startDate, isNotNull);
        expect(trip.endDate, isNotNull);
        expect(trip.latitude, isNotNull);
        expect(trip.longitude, isNotNull);
        expect(trip.status, isNotEmpty);
        expect(trip.budget, greaterThan(0));
        expect(trip.createdAt, isNotNull);
        expect(trip.updatedAt, isNotNull);
      }

      print('Generated 500 trips in ${stopwatch.elapsedMilliseconds}ms');
    });

    test('Generate geographically distributed trips for map tests', () {
      final stopwatch = Stopwatch()..start();

      final trips = PerformanceTestDataGenerator
          .generateGeographicallyDistributedTrips(
        count: 500,
      );

      stopwatch.stop();

      expect(trips.length, equals(500));

      // Verify trips are distributed across different regions
      final latitudes = trips.map((t) => t.latitude!).toList();
      final longitudes = trips.map((t) => t.longitude!).toList();

      // Check we have a good spread of coordinates
      expect(latitudes.reduce((a, b) => a < b ? a : b), lessThan(-20));
      expect(latitudes.reduce((a, b) => a > b ? a : b), greaterThan(60));
      expect(longitudes.reduce((a, b) => a < b ? a : b), lessThan(-100));
      expect(longitudes.reduce((a, b) => a > b ? a : b), greaterThan(100));

      print('Generated 500 geographically distributed trips in '
            '${stopwatch.elapsedMilliseconds}ms');
      print('Latitude range: ${latitudes.reduce((a, b) => a < b ? a : b).toStringAsFixed(2)} '
            'to ${latitudes.reduce((a, b) => a > b ? a : b).toStringAsFixed(2)}');
      print('Longitude range: ${longitudes.reduce((a, b) => a < b ? a : b).toStringAsFixed(2)} '
            'to ${longitudes.reduce((a, b) => a > b ? a : b).toStringAsFixed(2)}');
    });

    test('Generate clustered trips for map clustering tests', () {
      final stopwatch = Stopwatch()..start();

      final trips = PerformanceTestDataGenerator.generateClusteredTrips(
        count: 100,
        centerLatitude: 48.8566, // Paris
        centerLongitude: 2.3522,
        radius: 0.5,
      );

      stopwatch.stop();

      expect(trips.length, equals(100));

      // Verify all trips are within the specified radius
      for (final trip in trips) {
        final latDiff = (trip.latitude! - 48.8566).abs();
        final lonDiff = (trip.longitude! - 2.3522).abs();

        expect(latDiff, lessThan(0.5));
        expect(lonDiff, lessThan(0.5));
      }

      print('Generated 100 clustered trips in ${stopwatch.elapsedMilliseconds}ms');
    });

    test('Generate complex trip with sub-items', () {
      final trip = PerformanceTestDataGenerator.generateTripWithSubItems(
        activityCount: 100,
        photoCount: 200,
      );

      expect(trip.id, equals('complex-trip'));
      expect(trip.title, contains('Complex Performance Test'));
      expect(trip.description, contains('100 activities'));
      expect(trip.description, contains('200 photos'));

      final metadata = PerformanceTestDataGenerator.generateTripMetadata(
        activityCount: 100,
        photoCount: 200,
        noteCount: 50,
      );

      expect(metadata['activityCount'], equals(100));
      expect(metadata['photoCount'], equals(200));
      expect(metadata['noteCount'], equals(50));
      expect(metadata['estimatedMemoryUsage'], isNotNull);

      final memoryMB = (metadata['estimatedMemoryUsage'] as int) / 1024 / 1024;
      print('Estimated memory usage for complex trip: ${memoryMB.toStringAsFixed(2)} MB');
    });

    test('Generate users with trips for multi-user testing', () {
      final userTrips = PerformanceTestDataGenerator.generateUsersWithTrips(
        userCount: 10,
        tripsPerUser: 50,
      );

      expect(userTrips.length, equals(10));

      // Verify each user has correct number of trips
      userTrips.forEach((user, trips) {
        expect(user.id, startsWith('perf-user-'));
        expect(trips.length, equals(50));

        // Verify all trips belong to the correct user
        for (final trip in trips) {
          expect(trip.userId, equals(user.id));
        }
      });

      final totalTrips = userTrips.values.fold<int>(0, (sum, trips) => sum + trips.length);
      print('Generated ${userTrips.length} users with $totalTrips total trips');
    });

    test('Generate photo URLs for gallery tests', () {
      final stopwatch = Stopwatch()..start();

      final photoUrls = PhotoDataGenerator.generatePhotoUrls(count: 500);

      stopwatch.stop();

      expect(photoUrls.length, equals(500));
      expect(stopwatch.elapsedMilliseconds, lessThan(50));

      // Verify all URLs are valid
      for (final url in photoUrls) {
        expect(url, startsWith('https'));
        expect(url, contains('picsum.photos'));
      }

      // Verify uniqueness
      final uniqueUrls = photoUrls.toSet();
      expect(uniqueUrls.length, equals(500));

      print('Generated 500 unique photo URLs in ${stopwatch.elapsedMilliseconds}ms');
    });

    test('Generate photo metadata for list rendering tests', () {
      final stopwatch = Stopwatch()..start();

      final photoMetadata = PhotoDataGenerator.generatePhotoMetadata(count: 500);

      stopwatch.stop();

      expect(photoMetadata.length, equals(500));
      expect(stopwatch.elapsedMilliseconds, lessThan(100));

      // Verify metadata structure
      for (final photo in photoMetadata) {
        expect(photo['id'], isNotEmpty);
        expect(photo['url'], isNotEmpty);
        expect(photo['thumbnailUrl'], isNotEmpty);
        expect(photo['title'], isNotEmpty);
        expect(photo['location'], isNotEmpty);
        expect(photo['category'], isNotEmpty);
        expect(photo['width'], isNotNull);
        expect(photo['height'], isNotNull);
        expect(photo['sizeBytes'], isNotNull);
        expect(photo['capturedAt'], isNotNull);
        expect(photo['uploadedAt'], isNotNull);
        expect(photo['tags'], isNotNull);
      }

      print('Generated 500 photo metadata entries in ${stopwatch.elapsedMilliseconds}ms');
    });

    test('Generate trip-specific photo URLs', () {
      final tripPhotos = PhotoDataGenerator.generateTripPhotoUrls(
        tripId: 'test-trip-123',
        photoCount: 200,
      );

      expect(tripPhotos.length, equals(200));

      // Verify all URLs contain the trip ID
      for (final url in tripPhotos) {
        expect(url, contains('test-trip-123'));
      }

      print('Generated 200 trip-specific photo URLs');
    });

    test('Estimate memory usage for photo caching', () {
      final memory100 = PhotoDataGenerator.estimateMemoryUsage(photoCount: 100);
      final memory500 = PhotoDataGenerator.estimateMemoryUsage(photoCount: 500);
      final memory1000 = PhotoDataGenerator.estimateMemoryUsage(photoCount: 1000);

      expect(memory100, equals(100 * 1024 * 1024));
      expect(memory500, equals(500 * 1024 * 1024));
      expect(memory1000, equals(1000 * 1024 * 1024));

      print('Estimated memory for 100 photos: ${(memory100 / 1024 / 1024).toStringAsFixed(0)} MB');
      print('Estimated memory for 500 photos: ${(memory500 / 1024 / 1024).toStringAsFixed(0)} MB');
      print('Estimated memory for 1000 photos: ${(memory1000 / 1024 / 1024).toStringAsFixed(0)} MB');
    });

    test('Generate variable size photo URLs', () {
      final photoUrls = PhotoDataGenerator.generateVariableSizePhotoUrls(
        count: 500,
      );

      expect(photoUrls.length, equals(500));

      // Verify we have different sizes
      final sizes = photoUrls.map((url) {
        final match = RegExp(r'\/(\d+)\/(\d+)\?').firstMatch(url);
        return match != null ? '${match.group(1)}x${match.group(2)}' : '';
      }).toSet();

      expect(sizes.length, greaterThan(1)); // Should have multiple sizes
      expect(sizes.contains('400x300'), isTrue);
      expect(sizes.contains('1920x1080'), isTrue);

      print('Generated 500 photos with ${sizes.length} different size variations');
    });

    test('Data generation performance benchmark', () {
      final iterations = 10;
      final timings = <int>[];

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

      print('Data generation performance ($iterations iterations):');
      print('  Average: ${averageTime.toStringAsFixed(2)}ms');
      print('  Min: ${minTime}ms');
      print('  Max: ${maxTime}ms');

      // Data generation should be consistently fast
      expect(averageTime, lessThan(200));
      expect(maxTime, lessThan(500));
    });
  });
}
