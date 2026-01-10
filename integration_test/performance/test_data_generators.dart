/// Test data generators for performance testing with large datasets
///
/// This library provides utilities for generating large amounts of test data
/// (500+ activities, 1000+ photos) for performance benchmarking and optimization testing.
///
/// ## Usage
///
/// ### Generate Large Activity Sets
/// ```dart
/// // Generate 500+ activities for a trip
/// final activities = TestDataGenerator.generateLargeActivitySet(
///   tripId: 'trip-123',
///   userId: 'user-456',
///   count: 500,
/// );
/// ```
///
/// ### Generate Large Photo Sets
/// ```dart
/// // Generate 1000+ photos for a trip
/// final photos = TestDataGenerator.generateLargePhotoSet(
///   tripId: 'trip-123',
///   count: 1000,
/// );
/// ```
///
/// ### Generate Complex Trip
/// ```dart
/// // Generate a trip with both activities and photos
/// final tripData = TestDataGenerator.generateComplexTripData(
///   activityCount: 500,
///   photoCount: 1000,
/// );
/// ```
library;

import 'package:soloadventurer/features/travel/domain/models/activity.dart';
import 'package:soloadventurer/features/travel/domain/models/photo.dart';
import 'package:soloadventurer/features/travel/domain/models/trip.dart';

/// Generator for performance test data
class TestDataGenerator {
  /// Default user ID for generated test data
  static const String defaultUserId = 'perf-test-user-id';

  /// Default trip ID for generated test data
  static const String defaultTripId = 'perf-test-trip-id';

  /// Default number of activities to generate for large dataset testing
  static const int defaultActivityCount = 500;

  /// Default number of photos to generate for large dataset testing
  static const int defaultPhotoCount = 1000;

  /// Generates a large set of activities for performance testing
  ///
  /// [tripId] - Trip ID to associate activities with
  /// [userId] - User ID to associate activities with
  /// [count] - Number of activities to generate (default: 500)
  ///
  /// Returns a list of [Activity] objects with realistic data for benchmarking.
  /// Activities are distributed across different categories, locations, and time ranges.
  static List<Activity> generateLargeActivitySet({
    required String tripId,
    String? userId,
    int count = defaultActivityCount,
  }) {
    final user = userId ?? defaultUserId;
    final baseDate = DateTime.now();

    return List.generate(
      count,
      (index) => _generateRealisticActivity(
        index: index,
        tripId: tripId,
        userId: user,
        baseDate: baseDate,
      ),
    );
  }

  /// Generates a large set of photos for performance testing
  ///
  /// [tripId] - Trip ID to associate photos with
  /// [count] - Number of photos to generate (default: 1000)
  /// [withLocation] - Whether to include geographic coordinates (default: true)
  ///
  /// Returns a list of [Photo] objects with realistic metadata for benchmarking.
  /// Photos include varying dimensions, file sizes, and timestamps to simulate
  /// real-world gallery data.
  static List<Photo> generateLargePhotoSet({
    required String tripId,
    int count = defaultPhotoCount,
    bool withLocation = true,
  }) {
    final baseDate = DateTime.now();

    return List.generate(
      count,
      (index) => _generateRealisticPhoto(
        index: index,
        tripId: tripId,
        baseDate: baseDate,
        withLocation: withLocation,
      ),
    );
  }

  /// Generates a complex trip with activities and photos
  ///
  /// [activityCount] - Number of activities to generate (default: 500)
  /// [photoCount] - Number of photos to generate (default: 1000)
  /// [userId] - User ID to associate data with
  ///
  /// Returns a map containing the trip, activities, and photos for comprehensive
  /// performance testing of list rendering, image loading, and memory usage.
  static Map<String, dynamic> generateComplexTripData({
    int activityCount = defaultActivityCount,
    int photoCount = defaultPhotoCount,
    String? userId,
  }) {
    final user = userId ?? defaultUserId;
    const tripId = defaultTripId;

    final trip = Trip(
      id: tripId,
      userId: user,
      title: 'Performance Test Trip',
      description: 'Complex trip with $activityCount activities and $photoCount photos',
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
      destination: 'Multiple Destinations',
      latitude: 48.8566,
      longitude: 2.3522,
      status: 'ongoing',
      budget: 10000,
      coverImageUrl: 'https://example.com/covers/perf-test.jpg',
      createdAt: DateTime.now().subtract(const Duration(days: 30)),
      updatedAt: DateTime.now(),
    );

    final activities = generateLargeActivitySet(
      tripId: tripId,
      userId: user,
      count: activityCount,
    );

    final photos = generateLargePhotoSet(
      tripId: tripId,
      count: photoCount,
    );

    return {
      'trip': trip,
      'activities': activities,
      'photos': photos,
      'metadata': {
        'activityCount': activityCount,
        'photoCount': photoCount,
        'estimatedMemoryUsage': _estimateMemoryUsage(activityCount, photoCount),
      },
    };
  }

  /// Generates activities distributed across time for date range queries
  ///
  /// [tripId] - Trip ID to associate activities with
  /// [userId] - User ID to associate activities with
  /// [count] - Number of activities to generate
  /// [startDate] - Start date for activity distribution
  /// [endDate] - End date for activity distribution
  ///
  /// Returns activities spread across the date range for testing date-based queries
  /// and filtering performance.
  static List<Activity> generateActivitiesInDateRange({
    required String tripId,
    String? userId,
    int count = 100,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    final user = userId ?? defaultUserId;
    final start = startDate ?? DateTime.now();
    final end = endDate ?? start.add(const Duration(days: 30));
    final totalDuration = end.difference(start);

    return List.generate(
      count,
      (index) {
        final random = _RandomSeeded(index: index);
        final offset = Duration(
          milliseconds: (totalDuration.inMilliseconds * random.nextDouble()).toInt(),
        );
        final activityStart = start.add(offset);
        final duration = Duration(hours: 1 + random.nextInt(8));

        return Activity(
          id: 'activity-$index',
          tripId: tripId,
          userId: user,
          title: 'Activity ${index + 1}',
          description: 'Test activity $index in date range',
          category: _getRandomCategory(random),
          locationName: 'Location ${index + 1}',
          address: 'Address ${index + 1}',
          latitude: 48.0 + random.nextDouble() * 2.0,
          longitude: 2.0 + random.nextDouble() * 2.0,
          startDateTime: activityStart,
          endDateTime: activityStart.add(duration),
          estimatedCost: 10.0 + random.nextDouble() * 200.0,
          currency: 'USD',
          isCompleted: random.nextBool(),
          isPriority: random.nextInt(5) == 0,
          createdAt: activityStart.subtract(const Duration(days: 1)),
          updatedAt: activityStart.subtract(const Duration(hours: 1)),
        );
      },
    );
  }

  /// Generates activities clustered in specific geographic regions
  ///
  /// [tripId] - Trip ID to associate activities with
  /// [userId] - User ID to associate activities with
  /// [count] - Number of activities to generate per region
  /// [regions] - List of regions with center coordinates
  ///
  /// Returns activities clustered around specific coordinates for testing
  /// map marker clustering performance.
  static List<Activity> generateClusteredActivities({
    required String tripId,
    String? userId,
    int count = 50,
    List<Map<String, double>>? regions,
  }) {
    final user = userId ?? defaultUserId;

    final defaultRegions = [
      {'latitude': 48.8566, 'longitude': 2.3522}, // Paris
      {'latitude': 40.7128, 'longitude': -74.0060}, // New York
      {'latitude': 35.6762, 'longitude': 139.6503}, // Tokyo
    ];

    final clusterRegions = regions ?? defaultRegions;

    final allActivities = <Activity>[];

    for (final region in clusterRegions) {
      final centerLat = region['latitude']!;
      final centerLon = region['longitude']!;

      final regionActivities = List.generate(
        count,
        (index) {
          final random = _RandomSeeded(index: index + allActivities.length);
          const offset = 0.01; // ~1km radius
          final lat = centerLat + (random.nextDouble() * 2 - 1) * offset;
          final lon = centerLon + (random.nextDouble() * 2 - 1) * offset;

          return Activity(
            id: 'activity-cluster-${allActivities.length + index}',
            tripId: tripId,
            userId: user,
            title: 'Cluster Activity ${allActivities.length + index + 1}',
            description: 'Activity in cluster',
            category: _getRandomCategory(random),
            locationName: 'Location ${allActivities.length + index + 1}',
            latitude: lat,
            longitude: lon,
            startDateTime: DateTime.now().add(Duration(hours: random.nextInt(72))),
            estimatedCost: 20.0 + random.nextDouble() * 100.0,
            currency: 'USD',
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          );
        },
      );

      allActivities.addAll(regionActivities);
    }

    return allActivities;
  }

  /// Generates photos with varying aspect ratios for grid testing
  ///
  /// [tripId] - Trip ID to associate photos with
  /// [count] - Number of photos to generate
  /// [aspectRatios] - List of aspect ratios to use (width/height)
  ///
  /// Returns photos with different dimensions to test grid layout performance
  /// with varying item sizes.
  static List<Photo> generatePhotosWithAspectRations({
    required String tripId,
    int count = 100,
    List<double>? aspectRatios,
  }) {
    final defaultRatios = [1.0, 4.0 / 3.0, 16.0 / 9.0, 3.0 / 4.0, 9.0 / 16.0];
    final ratios = aspectRatios ?? defaultRatios;

    return List.generate(
      count,
      (index) {
        final random = _RandomSeeded(index: index);
        final ratio = ratios[index % ratios.length];
        const baseSize = 1920;
        const width = baseSize;
        final height = (baseSize / ratio).round();

        return Photo(
          id: 'photo-$index',
          imageUrl: 'https://example.com/photos/photo-$index.jpg',
          thumbnailUrl: 'https://example.com/photos/thumbs/photo-$index.jpg',
          caption: 'Photo ${index + 1}',
          tripId: tripId,
          location: 'Location ${index + 1}',
          latitude: 48.0 + random.nextDouble() * 2.0,
          longitude: 2.0 + random.nextDouble() * 2.0,
          takenAt: DateTime.now().subtract(Duration(hours: random.nextInt(720))),
          width: width,
          height: height,
          sizeInBytes: (500 * 1024) + random.nextInt(2000 * 1024),
          createdAt: DateTime.now(),
        );
      },
    );
  }

  // Private helper methods

  static Activity _generateRealisticActivity({
    required int index,
    required String tripId,
    required String userId,
    required DateTime baseDate,
  }) {
    final random = _RandomSeeded(index: index);

    const categories = ActivityCategory.values;
    final category = categories[index % categories.length];

    final locations = [
      'Eiffel Tower',
      'Louvre Museum',
      'Central Park',
      'Times Square',
      'Shibuya Crossing',
      'Senso-ji Temple',
      'Sydney Opera House',
      'Bondi Beach',
      'Colosseum',
      'Vatican Museums',
    ];

    final titles = [
      'Guided Tour',
      'Sightseeing',
      'Museum Visit',
      'Dinner',
      'Lunch',
      'Shopping',
      'Transport',
      'Hotel Check-in',
      'Walking Tour',
      'Photo Session',
    ];

    final location = locations[index % locations.length];
    final title = titles[random.nextInt(titles.length)];

    final startDate = baseDate.add(Duration(
      days: index % 30,
      hours: 9 + random.nextInt(12),
    ));
    final duration = Duration(hours: 1 + random.nextInt(4));

    return Activity(
      id: 'activity-$index',
      tripId: tripId,
      userId: userId,
      title: '$title at $location',
      description: 'Activity $index for performance testing',
      category: category,
      locationName: location,
      address: '$index Test Street',
      latitude: 48.0 + (index % 10) * 0.5,
      longitude: 2.0 + (index % 10) * 0.5,
      startDateTime: startDate,
      endDateTime: startDate.add(duration),
      estimatedCost: 10.0 + random.nextDouble() * 200.0,
      actualCost: random.nextBool() ? null : 10.0 + random.nextDouble() * 200.0,
      currency: 'USD',
      websiteUrl: 'https://example.com/activity-$index',
      phoneNumber: '+1${random.nextInt(9000000000) + 1000000000}',
      notes: random.nextInt(3) == 0 ? 'Notes for activity $index' : null,
      isCompleted: index % 3 == 0,
      isPriority: index % 10 == 0,
      photoIds: index % 5 == 0
          ? ['photo-${index * 2}', 'photo-${index * 2 + 1}']
          : null,
      tags: index % 4 == 0 ? ['tag1', 'tag2'] : null,
      createdAt: baseDate.subtract(Duration(days: 30 - index % 30)),
      updatedAt: baseDate.subtract(Duration(days: 29 - index % 30)),
    );
  }

  static Photo _generateRealisticPhoto({
    required int index,
    required String tripId,
    required DateTime baseDate,
    required bool withLocation,
  }) {
    final random = _RandomSeeded(index: index);

    // Vary photo dimensions to simulate different cameras and orientations
    final dimensions = [
      [1920, 1080], // 16:9 landscape
      [1080, 1920], // 9:16 portrait
      [3024, 4032], // 4:3 portrait (iPhone)
      [4032, 3024], // 3:4 landscape
      [2048, 1536], // 4:3 landscape
    ];

    final dim = dimensions[index % dimensions.length];
    final width = dim[0];
    final height = dim[1];

    // Vary file sizes to simulate different compression levels
    final sizeInBytes = (512 * 1024) + random.nextInt(4 * 1024 * 1024);

    return Photo(
      id: 'photo-$index',
      imageUrl: 'https://example.com/photos/photo-$index.jpg',
      thumbnailUrl: 'https://example.com/photos/thumbs/photo-$index.jpg',
      caption: index % 3 == 0 ? 'Photo ${index + 1}' : null,
      tripId: tripId,
      location: withLocation ? 'Location ${index + 1}' : null,
      latitude: withLocation ? 48.0 + (index % 20) * 0.1 : null,
      longitude: withLocation ? 2.0 + (index % 20) * 0.1 : null,
      takenAt: baseDate.subtract(Duration(hours: random.nextInt(720))),
      width: width,
      height: height,
      sizeInBytes: sizeInBytes,
      createdAt: baseDate.subtract(Duration(days: random.nextInt(30))),
    );
  }

  static ActivityCategory _getRandomCategory(_RandomSeeded random) {
    const categories = ActivityCategory.values;
    return categories[random.nextInt(categories.length)];
  }

  static int _estimateMemoryUsage(int activityCount, int photoCount) {
    // Estimate: activity ~1KB, photo ~500KB (cached)
    final activityMemory = activityCount * 1024;
    final photoMemory = photoCount * 512 * 1024;
    return activityMemory + photoMemory;
  }
}

/// A simple seeded random number generator for reproducible test data
class _RandomSeeded {
  late int _seed;

  _RandomSeeded({required int index}) {
    _seed = index * 1337 + 42;
  }

  int nextInt(int max) {
    _seed = (_seed * 1103515245 + 12345) & 0x7fffffff;
    return _seed % max;
  }

  double nextDouble() {
    _seed = (_seed * 1103515245 + 12345) & 0x7fffffff;
    return _seed / 0x7fffffff;
  }

  bool nextBool() {
    return nextInt(2) == 1;
  }
}
