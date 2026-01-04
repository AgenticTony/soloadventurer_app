import 'package:soloadventurer/features/auth/domain/models/user.dart';
import 'package:soloadventurer/features/travel/domain/models/trip.dart';

/// Performance test data generator for creating large datasets
///
/// This utility generates realistic test data with 500+ items for benchmarking
/// app performance with large trips, numerous locations, activities, and photos.
class PerformanceTestDataGenerator {
  /// Default user ID for generated test data
  static const String defaultUserId = 'perf-test-user-id';

  /// Default number of items to generate for large dataset testing
  static const int defaultLargeDatasetSize = 500;

  /// Generates a large list of trips for performance testing
  ///
  /// [count] - Number of trips to generate (default: 500)
  /// [userId] - User ID to associate with trips
  ///
  /// Returns a list of [Trip] objects with realistic data for benchmarking.
  /// Each trip includes geolocation data for map marker testing.
  static List<Trip> generateLargeTripList({
    int count = defaultLargeDatasetSize,
    String? userId,
  }) {
    return List.generate(
      count,
      (index) => _generateRealisticTrip(
        index: index,
        userId: userId ?? defaultUserId,
      ),
    );
  }

  /// Generates trips distributed across different regions for map testing
  ///
  /// [count] - Number of trips to generate
  /// [userId] - User ID to associate with trips
  ///
  /// Returns trips with coordinates spread across different geographic regions
  /// to test map marker clustering and rendering performance.
  static List<Trip> generateGeographicallyDistributedTrips({
    int count = defaultLargeDatasetSize,
    String? userId,
  }) {
    // Define regions: Europe, USA, Asia, Australia
    final regions = [
      {'name': 'Europe', 'latBase': 48.0, 'lonBase': 10.0, 'spread': 15.0},
      {'name': 'USA', 'latBase': 39.0, 'lonBase': -98.0, 'spread': 20.0},
      {'name': 'Asia', 'latBase': 35.0, 'lonBase': 105.0, 'spread': 25.0},
      {'name': 'Australia', 'latBase': -25.0, 'lonBase': 133.0, 'spread': 15.0},
    ];

    return List.generate(
      count,
      (index) {
        final region = regions[index % regions.length];
        return _generateRealisticTrip(
          index: index,
          userId: userId ?? defaultUserId,
          region: region['name'] as String,
          latBase: region['latBase'] as double,
          lonBase: region['lonBase'] as double,
          spread: region['spread'] as double,
        );
      },
    );
  }

  /// Generates trips concentrated in a small area for clustering tests
  ///
  /// [count] - Number of trips to generate
  /// [centerLatitude] - Center latitude for clustering
  /// [centerLongitude] - Center longitude for clustering
  /// [radius] - Radius in degrees to spread points
  /// [userId] - User ID to associate with trips
  ///
  /// Returns trips with coordinates within a small radius to test
  /// map marker clustering behavior and performance.
  static List<Trip> generateClusteredTrips({
    int count = 100,
    double centerLatitude = 48.8566,
    double centerLongitude = 2.3522,
    double radius = 0.5,
    String? userId,
  }) {
    final random = _RandomSeeded(index: 0);

    return List.generate(
      count,
      (index) {
        final latitude = centerLatitude +
            (random.nextDouble() * 2 - 1) * radius;
        final longitude = centerLongitude +
            (random.nextDouble() * 2 - 1) * radius;

        return Trip(
          id: 'clustered-trip-$index',
          userId: userId ?? defaultUserId,
          title: 'Paris Location ${index + 1}',
          description: 'Test location ${index + 1} in Paris cluster',
          startDate: DateTime.now().add(Duration(days: index * 2)),
          endDate: DateTime.now().add(Duration(days: index * 2 + 7)),
          destination: 'Paris Area',
          latitude: latitude,
          longitude: longitude,
          status: _getRandomStatus(random),
          budget: 1000 + random.nextInt(5000),
          coverImageUrl: index % 5 == 0
              ? 'https://example.com/covers/clustered-$index.jpg'
              : null,
          travelCompanionIds: random.nextBool()
              ? ['companion-${random.nextInt(10)}']
              : null,
          createdAt: DateTime.now().subtract(Duration(days: 30 - index)),
          updatedAt: DateTime.now().subtract(Duration(days: 29 - index)),
        );
      },
    );
  }

  /// Generates a single trip with numerous sub-items for testing
  ///
  /// This creates a trip object that can be used to simulate a trip
  /// with hundreds of activities, notes, or photos by encoding
  /// metadata in the description field.
  ///
  /// [activityCount] - Number of activities to simulate
  /// [photoCount] - Number of photos to simulate
  /// [userId] - User ID to associate with trip
  static Trip generateTripWithSubItems({
    int activityCount = 100,
    int photoCount = 200,
    String? userId,
  }) {
    return Trip(
      id: 'complex-trip',
      userId: userId ?? defaultUserId,
      title: 'Complex Performance Test Trip',
      description: _createComplexDescription(
        activityCount: activityCount,
        photoCount: photoCount,
      ),
      startDate: DateTime.now(),
      endDate: DateTime.now().add(const Duration(days: 30)),
      destination: 'Multi-Country Tour',
      latitude: 48.8566,
      longitude: 2.3522,
      status: 'planning',
      budget: 10000,
      coverImageUrl: 'https://example.com/covers/complex-trip.jpg',
      createdAt: DateTime.now(),
      updatedAt: DateTime.now(),
    );
  }

  /// Generates users with associated trips for user testing
  ///
  /// [userCount] - Number of users to generate
  /// [tripsPerUser] - Number of trips per user
  ///
  /// Returns a map of users to their generated trips for testing
  /// user-specific performance and data isolation.
  static Map<User, List<Trip>> generateUsersWithTrips({
    int userCount = 10,
    int tripsPerUser = 50,
  }) {
    final Map<User, List<Trip>> result = {};

    for (int i = 0; i < userCount; i++) {
      final user = User(
        id: 'perf-user-$i',
        username: 'perfuser$i',
        email: 'perfuser$i@example.com',
        firstName: 'Performance',
        lastName: 'User $i',
        profilePictureUrl: 'https://example.com/avatars/user-$i.jpg',
        createdAt: DateTime.now().subtract(Duration(days: 30 * i)),
        updatedAt: DateTime.now(),
      );

      final trips = generateLargeTripList(
        count: tripsPerUser,
        userId: user.id,
      );

      result[user] = trips;
    }

    return result;
  }

  /// Generates trip metadata for simulating activities/photos
  ///
  /// This is a helper method that generates metadata to simulate
  /// complex trip data without requiring database entities.
  static Map<String, dynamic> generateTripMetadata({
    int activityCount = 100,
    int photoCount = 200,
    int noteCount = 50,
  }) {
    return {
      'activityCount': activityCount,
      'photoCount': photoCount,
      'noteCount': noteCount,
      'estimatedMemoryUsage':
          (activityCount * 1024) + (photoCount * 512 * 1024) + (noteCount * 512),
      'createdAt': DateTime.now().toIso8601String(),
    };
  }

  // Private helper methods

  static Trip _generateRealisticTrip({
    required int index,
    required String userId,
    String region = 'Global',
    double latBase = 30.0,
    double lonBase = 0.0,
    double spread = 60.0,
  }) {
    final random = _RandomSeeded(index: index);

    final destinations = [
      'Paris',
      'Tokyo',
      'New York',
      'London',
      'Sydney',
      'Rome',
      'Barcelona',
      'Dubai',
      'Singapore',
      'Amsterdam',
      'Berlin',
      'Bangkok',
      'Los Angeles',
      'San Francisco',
      'Toronto',
    ];

    final titles = [
      'Adventure Trip',
      'City Break',
      'Beach Vacation',
      'Cultural Tour',
      'Business Trip',
      'Weekend Getaway',
      'Backpacking',
      'Luxury Escape',
      'Road Trip',
      'Food & Wine Tour',
    ];

    final destination = destinations[random.nextInt(destinations.length)];
    final title = titles[random.nextInt(titles.length)];

    final latitude = latBase + (random.nextDouble() * 2 - 1) * spread;
    final longitude = lonBase + (random.nextDouble() * 2 - 1) * spread;

    final startDate = DateTime.now().add(Duration(days: random.nextInt(365)));
    final endDate = startDate.add(Duration(days: 3 + random.nextInt(14)));

    return Trip(
      id: 'perf-trip-$index',
      userId: userId,
      title: '$title to $destination',
      description: 'Performance test trip $index to $destination',
      startDate: startDate,
      endDate: endDate,
      destination: destination,
      latitude: latitude,
      longitude: longitude,
      status: _getRandomStatus(random),
      budget: 500 + random.nextInt(10000),
      coverImageUrl: random.nextInt(3) == 0
          ? 'https://example.com/covers/trip-$index.jpg'
          : null,
      travelCompanionIds: random.nextInt(3) > 0
          ? List.generate(
              random.nextInt(3),
              (i) => 'companion-${random.nextInt(100)}',
            )
          : null,
      createdAt: DateTime.now().subtract(Duration(days: random.nextInt(365))),
      updatedAt: DateTime.now().subtract(Duration(days: random.nextInt(30))),
    );
  }

  static String _getRandomStatus(_RandomSeeded random) {
    final statuses = ['planning', 'ongoing', 'completed', 'cancelled'];
    return statuses[random.nextInt(statuses.length)];
  }

  static String _createComplexDescription({
    required int activityCount,
    required int photoCount,
  }) {
    return '''
Complex Performance Test Trip

This trip simulates a complex travel scenario with:
- $activityCount activities
- $photoCount photos
- Multiple destinations
- Extended duration

Use this trip for testing:
- List rendering performance
- Memory usage with large datasets
- Scroll performance
- State management overhead
''';
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
