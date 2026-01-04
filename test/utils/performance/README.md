# Performance Testing Utilities

This directory contains utilities for generating large test datasets (500+ items) for performance benchmarking and optimization testing.

## Overview

These utilities address the need to test app performance with large, complex datasets similar to real-world scenarios like:
- Wanderlog's performance issues with 730+ pins
- Roadtrippers lagging with numerous items
- Solo travelers planning 3-month trips with hundreds of locations

## Files

### `test_data_generator.dart`
Generates realistic trip data for performance testing:
- **Large trip lists** (500+ trips) for list rendering tests
- **Geographically distributed trips** for map marker performance
- **Clustered trips** for testing marker clustering algorithms
- **Complex trips** with simulated sub-items (activities, photos)
- **Multi-user datasets** for testing data isolation

### `photo_data_generator.dart`
Generates photo and image data for testing:
- **Photo URLs** (500+) for gallery loading tests
- **Variable size photos** for responsive image testing
- **Photo metadata** for list rendering performance
- **Trip-specific photos** for gallery testing
- Memory usage estimation utilities

### `performance_test_utils.dart`
Barrel file that exports all performance testing utilities with comprehensive documentation and usage examples.

### `example_performance_test.dart`
Example test suite demonstrating how to use the performance testing utilities. Run these tests to see the generators in action and verify they work correctly.

## Quick Start

```dart
import 'package:soloadventurer_test/utils/performance/performance_test_utils.dart';

// Generate 500 trips for list rendering tests
final trips = PerformanceTestDataGenerator.generateLargeTripList(count: 500);

// Generate photo URLs for gallery tests
final photos = PhotoDataGenerator.generatePhotoUrls(count: 500);

// Estimate memory usage
final memoryMB = PhotoDataGenerator.estimateMemoryUsage(photoCount: 500) / 1024 / 1024;
```

## Use Cases

### 1. List Rendering Performance
Test how your app handles scrolling through 500+ trip items:

```dart
testWidgets('Trip list renders smoothly', (tester) async {
  final trips = PerformanceTestDataGenerator.generateLargeTripList(count: 500);

  final stopwatch = Stopwatch()..start();
  await tester.pumpWidget(TripListScreen(trips: trips));
  await tester.pumpAndSettle();
  stopwatch.stop();

  expect(stopwatch.elapsedMilliseconds, lessThan(3000));
});
```

### 2. Map Marker Performance
Test map rendering with hundreds of markers:

```dart
test('Map renders 500+ markers efficiently', () async {
  final trips = PerformanceTestDataGenerator.generateGeographicallyDistributedTrips(count: 500);

  final stopwatch = Stopwatch()..start();
  for (final trip in trips) {
    await mapController.addMarker(LatLng(trip.latitude!, trip.longitude!));
  }
  stopwatch.stop();

  expect(stopwatch.elapsedMilliseconds, lessThan(2000));
});
```

### 3. Memory Usage Testing
Test memory limits with large photo galleries:

```dart
test('Photo gallery stays within memory limits', () async {
  final photos = PhotoDataGenerator.generatePhotoUrls(count: 500);
  final initialMemory = await getMemoryUsage();

  for (final url in photos) {
    await imageCache.loadImage(url);
  }

  final finalMemory = await getMemoryUsage();
  expect(finalMemory - initialMemory, lessThan(200 * 1024 * 1024));
});
```

## Data Characteristics

### Trip Data
- Realistic titles and destinations
- Geolocation coordinates (latitude/longitude)
- Date ranges (start/end dates)
- Budgets, cover images, travel companions
- Multiple statuses (planning, ongoing, completed, cancelled)
- Geographic distribution across Europe, USA, Asia, Australia

### Photo Data
- Realistic URLs using picsum.photos placeholder service
- Variable sizes (400x300 to 1920x1080)
- Metadata including title, location, category, tags
- Capture and upload timestamps
- File size estimates for memory calculations

## Performance Benchmarks

Based on the example tests, data generation should be:
- **Trip generation**: < 100ms for 500 trips
- **Photo URL generation**: < 50ms for 500 URLs
- **Photo metadata generation**: < 100ms for 500 items

## Best Practices

1. **Use seeded random**: The generators use seeded random number generators for reproducible test data
2. **Customize datasets**: Adjust parameters like count, geographic distribution, and clustering as needed
3. **Memory estimation**: Use `estimateMemoryUsage()` before running large tests to ensure you stay within limits
4. **Test incrementally**: Start with smaller datasets (50-100 items) before scaling to 500+
5. **Clean up**: Ensure tests dispose of resources and clear caches between runs

## Integration with Existing Tests

These utilities complement the existing `test/utils/test_data.dart` file:
- `test_data.dart`: Small datasets for unit tests (default 1-10 items)
- `performance/test_data_generator.dart`: Large datasets for performance tests (500+ items)

## Related Documentation

- [Performance Optimization Spec](../../../.auto-claude/specs/006-performance-optimization-for-large-trips/spec.md)
- [Implementation Plan](../../../.auto-claude/specs/006-performance-optimization-for-large-trips/implementation_plan.json)
- [Build Progress](../../../.auto-claude/specs/006-performance-optimization-for-large-trips/build-progress.txt)

## Future Enhancements

Potential additions as the performance optimization work progresses:
- Activity data generators for trip activities
- Location/POI generators for points of interest
- Network response simulators for testing API performance
- Database population utilities for local storage testing
