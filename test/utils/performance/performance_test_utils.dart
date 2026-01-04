/// Performance testing utilities for generating large test datasets
///
/// This library provides utilities for generating large amounts of test data
/// (500+ items) for performance benchmarking and optimization testing.
///
/// ## Usage
///
/// ### Generate Large Trip Lists
/// ```dart
/// import 'package:soloadventurer_test/utils/performance/performance_test_utils.dart';
///
/// // Generate 500 trips for list rendering tests
/// final trips = PerformanceTestDataGenerator.generateLargeTripList(count: 500);
///
/// // Generate geographically distributed trips for map tests
/// final mapTrips = PerformanceTestDataGenerator.generateGeographicallyDistributedTrips(count: 500);
///
/// // Generate clustered trips for clustering algorithm tests
/// final clusteredTrips = PerformanceTestDataGenerator.generateClusteredTrips(count: 100);
/// ```
///
/// ### Generate Photo Data for Gallery Tests
/// ```dart
/// // Generate photo URLs for testing image loading
/// final photoUrls = PhotoDataGenerator.generatePhotoUrls(count: 500);
///
/// // Generate detailed photo metadata for list rendering tests
/// final photoMetadata = PhotoDataGenerator.generatePhotoMetadata(count: 500);
///
/// // Generate trip-specific photos
/// final tripPhotos = PhotoDataGenerator.generateTripPhotoUrls(tripId: 'trip-123', photoCount: 200);
/// ```
///
/// ### Test Data Estimation
/// ```dart
/// // Estimate memory usage for photo caching
/// final memoryBytes = PhotoDataGenerator.estimateMemoryUsage(photoCount: 500);
/// print('Estimated memory: ${(memoryBytes / 1024 / 1024).toStringAsFixed(2)} MB');
/// ```
///
/// ## Performance Test Patterns
///
/// ### List Rendering Performance
/// ```dart
/// testWidgets('Trip list renders smoothly with 500+ items', (tester) async {
///   final trips = PerformanceTestDataGenerator.generateLargeTripList(count: 500);
///
///   final stopwatch = Stopwatch()..start();
///
///   await tester.pumpWidget(
///     MaterialApp(
///       home: TripListScreen(trips: trips),
///     ),
///   );
///
///   await tester.pumpAndSettle();
///   stopwatch.stop();
///
///   expect(stopwatch.elapsedMilliseconds, lessThan(3000)); // Should render in < 3s
/// });
/// ```
///
/// ### Map Marker Performance
/// ```dart
/// test('Map renders 500+ markers efficiently', () async {
///   final trips = PerformanceTestDataGenerator.generateGeographicallyDistributedTrips(count: 500);
///
///   final stopwatch = Stopwatch()..start();
///
///   // Add all markers to map
///   for (final trip in trips) {
///     await mapController.addMarker(
///       LatLng(trip.latitude!, trip.longitude!),
///     );
///   }
///
///   stopwatch.stop();
///
///   expect(stopwatch.elapsedMilliseconds, lessThan(2000)); // Should add markers in < 2s
/// });
/// ```
///
/// ### Memory Usage Testing
/// ```dart
/// test('Photo gallery stays within memory limits', () async {
///   final photos = PhotoDataGenerator.generatePhotoUrls(count: 500);
///   final initialMemory = await getMemoryUsage();
///
///   // Load all photos
///   for (final url in photos) {
///     await imageCache.loadImage(url);
///   }
///
///   final finalMemory = await getMemoryUsage();
///   final memoryDelta = finalMemory - initialMemory;
///
///   expect(memoryDelta, lessThan(200 * 1024 * 1024)); // Less than 200MB increase
/// });
/// ```

library;

export 'test_data_generator.dart';
export 'photo_data_generator.dart';
export 'performance_reporter.dart';
