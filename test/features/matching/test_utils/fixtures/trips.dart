// Trip Test Fixtures

class TripFixture {
  final String id;
  final String userId;
  final String destination;
  final String location; // PostGIS format: POINT(lng lat)
  final DateTime startDate;
  final DateTime endDate;
  final bool isActive;

  const TripFixture({
    required this.id,
    required this.userId,
    required this.destination,
    required this.location,
    required this.startDate,
    required this.endDate,
    this.isActive = true,
  });

  int get durationDays => endDate.difference(startDate).inDays + 1;

  Map<String, dynamic> toMap() => {
    'id': id,
    'user_id': userId,
    'destination': destination,
    'location': location,
    'start_date': startDate.toIso8601String().split('T')[0],
    'end_date': endDate.toIso8601String().split('T')[0],
    'is_active': isActive,
  };

  /// Check if this trip overlaps with another trip
  bool overlapsWith(TripFixture other) {
    return startDate.isBefore(other.endDate) && 
           endDate.isAfter(other.startDate);
  }

  /// Get overlap days with another trip
  int overlapDaysWith(TripFixture other) {
    if (!overlapsWith(other)) return 0;
    final start = startDate.isAfter(other.startDate) ? startDate : other.startDate;
    final end = endDate.isBefore(other.endDate) ? endDate : other.endDate;
    return end.difference(start).inDays + 1;
  }
}

/// Predefined trip fixtures for testing
class Trips {
  // Paris trips with different date ranges
  
  /// Alex's Paris trip: Apr 10-15 (6 days)
  static TripFixture get parisAlex => TripFixture(
    id: 'trip-paris-alex',
    userId: 'user-alex',
    destination: 'Paris, France',
    location: 'POINT(2.3522 48.8566)',
    startDate: DateTime(2026, 4, 10),
    endDate: DateTime(2026, 4, 15),
  );

  /// Marcus's Paris trip: Apr 12-18 (7 days)
  /// Overlaps with Alex by 4 days (Apr 12-15)
  static TripFixture get parisMarcus => TripFixture(
    id: 'trip-paris-marcus',
    userId: 'user-marcus',
    destination: 'Paris, France',
    location: 'POINT(2.3522 48.8566)',
    startDate: DateTime(2026, 4, 12),
    endDate: DateTime(2026, 4, 18),
  );

  /// Priya's Lyon trip: Apr 10-15 (6 days)
  /// Same dates as Alex, but different city (394km away)
  static TripFixture get lyonPriya => TripFixture(
    id: 'trip-lyon-priya',
    userId: 'user-priya',
    destination: 'Lyon, France',
    location: 'POINT(4.8357 45.7640)',
    startDate: DateTime(2026, 4, 10),
    endDate: DateTime(2026, 4, 15),
  );

  /// Paris trip with NO date overlap: Apr 1-5
  static TripFixture get parisNoOverlap => TripFixture(
    id: 'trip-paris-no-overlap',
    userId: 'user-john',
    destination: 'Paris, France',
    location: 'POINT(2.3522 48.8566)',
    startDate: DateTime(2026, 4, 1),
    endDate: DateTime(2026, 4, 5),
  );

  /// Emma's Paris trip: Same dates as Alex (perfect overlap)
  static TripFixture get parisEmma => TripFixture(
    id: 'trip-paris-emma',
    userId: 'user-emma',
    destination: 'Paris, France',
    location: 'POINT(2.3522 48.8566)',
    startDate: DateTime(2026, 4, 10),
    endDate: DateTime(2026, 4, 15),
  );

  /// Inactive/archived trip
  static TripFixture get parisInactive => TripFixture(
    id: 'trip-paris-inactive',
    userId: 'user-john',
    destination: 'Paris, France',
    location: 'POINT(2.3522 48.8566)',
    startDate: DateTime(2026, 4, 10),
    endDate: DateTime(2026, 4, 15),
    isActive: false,
  );

  /// Berlin trip: Apr 10-15 (for radius testing)
  /// ~878km from Paris
  static TripFixture get berlinAlex => TripFixture(
    id: 'trip-berlin-alex',
    userId: 'user-alex',
    destination: 'Berlin, Germany',
    location: 'POINT(13.4050 52.5200)',
    startDate: DateTime(2026, 4, 10),
    endDate: DateTime(2026, 4, 15),
  );

  /// Single day trip
  static TripFixture get singleDayTrip => TripFixture(
    id: 'trip-single-day',
    userId: 'user-alex',
    destination: 'Paris, France',
    location: 'POINT(2.3522 48.8566)',
    startDate: DateTime(2026, 4, 10),
    endDate: DateTime(2026, 4, 10),
  );

  /// Maximum duration trip (90 days)
  static TripFixture get maxDurationTrip => TripFixture(
    id: 'trip-max-duration',
    userId: 'user-alex',
    destination: 'Paris, France',
    location: 'POINT(2.3522 48.8566)',
    startDate: DateTime(2026, 4, 1),
    endDate: DateTime(2026, 6, 29), // 90 days
  );

  /// All trip fixtures
  static List<TripFixture> get all => [
    parisAlex,
    parisMarcus,
    lyonPriya,
    parisNoOverlap,
    parisEmma,
    parisInactive,
    berlinAlex,
  ];

  /// Active trips only
  static List<TripFixture> get active => all.where((t) => t.isActive).toList();

  /// Trips that overlap with Alex's Paris trip
  static List<TripFixture> overlappingWithAlex() => 
    active.where((t) => 
      t.userId != 'user-alex' && t.overlapsWith(parisAlex)
    ).toList();
}

/// Generate test trips programmatically
class TripGenerator {
  static int _counter = 0;

  static TripFixture generate({
    String? userId,
    String? destination,
    String? location,
    DateTime? startDate,
    int durationDays = 5,
    bool isActive = true,
  }) {
    final id = 'trip-${DateTime.now().millisecondsSinceEpoch}-${_counter++}';
    final start = startDate ?? DateTime.now().add(Duration(days: _counter));
    return TripFixture(
      id: id,
      userId: userId ?? 'user-$id',
      destination: destination ?? 'Test City',
      location: location ?? 'POINT(0 0)',
      startDate: start,
      endDate: start.add(Duration(days: durationDays)),
      isActive: isActive,
    );
  }

  static List<TripFixture> generateBatch(int count, {
    String? userId,
    String baseDestination = 'Paris, France',
    String baseLocation = 'POINT(2.3522 48.8566)',
  }) {
    return List.generate(count, (i) => generate(
      userId: userId,
      destination: '$baseDestination $i',
      location: baseLocation,
      startDate: DateTime.now().add(Duration(days: i * 5)),
    ));
  }

  /// Generate trips for benchmark testing
  static List<Map<String, dynamic>> generateBenchmarkTrips({
    int count = 100000,
    int userCount = 50000,
  }) {
    final cities = [
      {'name': 'Paris, France', 'location': 'POINT(2.3522 48.8566)'},
      {'name': 'London, UK', 'location': 'POINT(-0.1276 51.5074)'},
      {'name': 'Berlin, Germany', 'location': 'POINT(13.4050 52.5200)'},
      {'name': 'Rome, Italy', 'location': 'POINT(12.4964 41.9028)'},
      {'name': 'Barcelona, Spain', 'location': 'POINT(2.1734 41.3851)'},
      {'name': 'Bangkok, Thailand', 'location': 'POINT(100.5018 13.7563)'},
      {'name': 'Tokyo, Japan', 'location': 'POINT(139.6917 35.6895)'},
      {'name': 'Singapore', 'location': 'POINT(103.8198 1.3521)'},
      {'name': 'Sydney, Australia', 'location': 'POINT(151.2093 -33.8688)'},
      {'name': 'New York, USA', 'location': 'POINT(-74.0060 40.7128)'},
    ];

    return List.generate(count, (i) {
      final city = cities[i % cities.length];
      final startDay = i % 365;
      final duration = (i % 90) + 1;
      return {
        'id': 'bench-trip-$i',
        'user_id': 'bench-user-${i % userCount}',
        'destination': city['name'],
        'location': city['location'],
        'start_date': DateTime.now().add(Duration(days: startDay)).toIso8601String().split('T')[0],
        'end_date': DateTime.now().add(Duration(days: startDay + duration)).toIso8601String().split('T')[0],
        'is_active': i % 5 != 0, // 80% active
      };
    });
  }

  static void reset() => _counter = 0;
}
