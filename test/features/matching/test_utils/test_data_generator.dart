// Test Data Generator
// Utilities for generating realistic test data

import 'dart:math';

/// Random test data generator
class TestDataGenerator {
  static final Random _random = Random();
  static int _idCounter = 0;

  /// Generate unique ID
  static String generateId([String prefix = 'test']) {
    return '${prefix}_${DateTime.now().millisecondsSinceEpoch}_${_idCounter++}';
  }

  /// Reset ID counter (use in setUp)
  static void reset() => _idCounter = 0;

  // ============ String Generators ============

  static const List<String> _firstNames = [
    'Alex', 'Jordan', 'Taylor', 'Morgan', 'Casey',
    'Riley', 'Quinn', 'Avery', 'Harper', 'Sage',
    'Marcus', 'Priya', 'Emma', 'Lucas', 'Olivia',
  ];

  static const List<String> _emailDomains = [
    'gmail.com', 'outlook.com', 'yahoo.com', 'icloud.com',
  ];

  static const List<String> _countries = [
    'US', 'UK', 'DE', 'FR', 'IT', 'ES', 'AU', 'CA', 'JP', 'IN',
  ];

  static const List<String> _genders = ['male', 'female', 'non-binary'];

  static const List<String> _ageRanges = [
    '18-24', '25-30', '30-35', '35-40', '40-45', '45-50', '50+',
  ];

  /// Generate random first name
  static String firstName() => _firstNames[_random.nextInt(_firstNames.length)];

  /// Generate random email
  static String email([String? name]) {
    final n = name ?? firstName().toLowerCase();
    final domain = _emailDomains[_random.nextInt(_emailDomains.length)];
    return '$n${_random.nextInt(999)}@$domain';
  }

  /// Generate random country code
  static String country() => _countries[_random.nextInt(_countries.length)];

  /// Generate random gender
  static String gender() => _genders[_random.nextInt(_genders.length)];

  /// Generate random age range
  static String ageRange() => _ageRanges[_random.nextInt(_ageRanges.length)];

  // ============ Date Generators ============

  /// Generate random date in future
  static DateTime futureDate({int minDays = 1, int maxDays = 365}) {
    final days = minDays + _random.nextInt(maxDays - minDays);
    return DateTime.now().add(Duration(days: days));
  }

  /// Generate random date range
  static DateTimeRange dateRange({int minDuration = 1, int maxDuration = 90}) {
    final start = futureDate();
    final duration = minDuration + _random.nextInt(maxDuration - minDuration);
    final end = start.add(Duration(days: duration));
    return DateTimeRange(start: start, end: end);
  }

  /// Generate date range overlapping with existing range
  static DateTimeRange overlappingDateRange(DateTimeRange existing, {
    int minOverlap = 1,
    int maxOverlap = 10,
  }) {
    final overlap = minOverlap + _random.nextInt(maxOverlap - minOverlap);
    final maxStartOffset = existing.durationDays - minOverlap;
    final startOffset = maxStartOffset > 0 ? _random.nextInt(maxStartOffset) : 0;
    
    final newStart = existing.start.add(Duration(days: startOffset));
    final newEnd = newStart.add(Duration(days: overlap + _random.nextInt(30)));
    
    return DateTimeRange(start: newStart, end: newEnd);
  }

  /// Generate date range with NO overlap
  static DateTimeRange nonOverlappingDateRange(DateTimeRange existing) {
    // Either before or after
    if (_random.nextBool()) {
      // Before
      final end = existing.start.subtract(Duration(days: 1));
      final duration = 1 + _random.nextInt(30);
      return DateTimeRange(
        start: end.subtract(Duration(days: duration)),
        end: end,
      );
    } else {
      // After
      final start = existing.end.add(Duration(days: 1));
      final duration = 1 + _random.nextInt(30);
      return DateTimeRange(
        start: start,
        end: start.add(Duration(days: duration)),
      );
    }
  }

  // ============ Location Generators ============

  static const List<Map<String, dynamic>> _cities = [
    {'name': 'Paris, France', 'lat': 48.8566, 'lng': 2.3522},
    {'name': 'London, UK', 'lat': 51.5074, 'lng': -0.1276},
    {'name': 'Berlin, Germany', 'lat': 52.5200, 'lng': 13.4050},
    {'name': 'Rome, Italy', 'lat': 41.9028, 'lng': 12.4964},
    {'name': 'Barcelona, Spain', 'lat': 41.3851, 'lng': 2.1734},
    {'name': 'Bangkok, Thailand', 'lat': 13.7563, 'lng': 100.5018},
    {'name': 'Tokyo, Japan', 'lat': 35.6895, 'lng': 139.6917},
    {'name': 'Singapore', 'lat': 1.3521, 'lng': 103.8198},
    {'name': 'Sydney, Australia', 'lat': -33.8688, 'lng': 151.2093},
    {'name': 'New York, USA', 'lat': 40.7128, 'lng': -74.0060},
    {'name': 'Amsterdam, Netherlands', 'lat': 52.3676, 'lng': 4.9041},
    {'name': 'Vienna, Austria', 'lat': 48.2082, 'lng': 16.3738},
    {'name': 'Prague, Czech Republic', 'lat': 50.0755, 'lng': 14.4378},
    {'name': 'Lisbon, Portugal', 'lat': 38.7223, 'lng': -9.1393},
    {'name': 'Dubrovnik, Croatia', 'lat': 42.6507, 'lng': 18.0944},
  ];

  /// Generate random city
  static Map<String, dynamic> city() => _cities[_random.nextInt(_cities.length)];

  /// Generate PostGIS POINT string
  static String postgisPoint(double lat, double lng) => 'POINT($lng $lat)';

  /// Generate coordinates near a point
  static LatLng nearLocation(LatLng center, {double maxDistanceKm = 50.0}) {
    // Roughly 111km per degree of latitude
    final degreesPerKm = 1 / 111.0;
    final maxDegrees = maxDistanceKm * degreesPerKm;
    
    final lat = center.lat + (_random.nextDouble() * 2 - 1) * maxDegrees;
    final lng = center.lng + (_random.nextDouble() * 2 - 1) * maxDegrees;
    
    return LatLng(lat, lng);
  }

  // ============ Complex Object Generators ============

  /// Generate user map
  static Map<String, dynamic> user({
    String? id,
    String? email,
    String? firstName,
    String? gender,
    bool? womenOnlyMode,
  }) => {
    'id': id ?? generateId('user'),
    'email': email ?? TestDataGenerator.email(firstName),
    'first_name': firstName ?? TestDataGenerator.firstName(),
    'gender': gender ?? TestDataGenerator.gender(),
    'age_range': ageRange(),
    'home_country': country(),
    'women_only_mode': womenOnlyMode ?? false,
    'created_at': DateTime.now().toIso8601String(),
  };

  /// Generate trip map
  static Map<String, dynamic> trip({
    String? id,
    String? userId,
    String? destination,
    String? location,
    DateTimeRange? dates,
    bool? isActive,
  }) {
    final cityData = city();
    final d = dates ?? dateRange();
    return {
      'id': id ?? generateId('trip'),
      'user_id': userId ?? generateId('user'),
      'destination': destination ?? cityData['name'],
      'location': location ?? postgisPoint(cityData['lat'], cityData['lng']),
      'start_date': d.start.toIso8601String().split('T')[0],
      'end_date': d.end.toIso8601String().split('T')[0],
      'is_active': isActive ?? true,
    };
  }

  /// Generate match map
  static Map<String, dynamic> match({
    String? id,
    String? userAId,
    String? userBId,
    int? overlapDays,
    double? distanceKm,
  }) => {
    'id': id ?? generateId('match'),
    'user_a_id': userAId ?? generateId('user'),
    'user_b_id': userBId ?? generateId('user'),
    'match_reason': 'geographic_overlap',
    'overlap_days': overlapDays ?? (1 + _random.nextInt(10)),
    'distance_km': distanceKm ?? (_random.nextDouble() * 100),
    'created_at': DateTime.now().toIso8601String(),
  };

  /// Generate message map
  static Map<String, dynamic> message({
    String? id,
    String? senderId,
    String? receiverId,
    String? content,
  }) => {
    'id': id ?? generateId('msg'),
    'sender_id': senderId ?? generateId('user'),
    'receiver_id': receiverId ?? generateId('user'),
    'content': content ?? 'Test message ${_random.nextInt(1000)}',
    'sent_at': DateTime.now().toIso8601String(),
    'delivered_at': null,
    'read_at': null,
  };

  // ============ Batch Generators ============

  /// Generate multiple users
  static List<Map<String, dynamic>> users(int count, {
    String? gender,
    bool? womenOnlyMode,
  }) => List.generate(count, (_) => user(
    gender: gender,
    womenOnlyMode: womenOnlyMode,
  ));

  /// Generate multiple trips
  static List<Map<String, dynamic>> trips(int count, {
    String? userId,
    DateTimeRange? dateRange,
  }) => List.generate(count, (_) => trip(
    userId: userId,
    dates: dateRange,
  ));

  /// Generate benchmark data (100K trips)
  static List<Map<String, dynamic>> benchmarkTrips({
    int count = 100000,
    int userCount = 50000,
  }) {
    return List.generate(count, (i) {
      final cityData = _cities[i % _cities.length];
      final startDay = i % 365;
      final duration = (i % 90) + 1;
      return {
        'id': 'bench-trip-$i',
        'user_id': 'bench-user-${i % userCount}',
        'destination': cityData['name'],
        'location': postgisPoint(cityData['lat'], cityData['lng']),
        'start_date': DateTime.now().add(Duration(days: startDay)).toIso8601String().split('T')[0],
        'end_date': DateTime.now().add(Duration(days: startDay + duration)).toIso8601String().split('T')[0],
        'is_active': i % 5 != 0, // 80% active
      };
    });
  }
}

/// Simple date range class
class DateTimeRange {
  final DateTime start;
  final DateTime end;

  const DateTimeRange({required this.start, required this.end});

  int get durationDays => end.difference(start).inDays + 1;

  bool overlapsWith(DateTimeRange other) {
    return start.isBefore(other.end) && end.isAfter(other.start);
  }

  int overlapDays(DateTimeRange other) {
    if (!overlapsWith(other)) return 0;
    final s = start.isAfter(other.start) ? start : other.start;
    final e = end.isBefore(other.end) ? end : other.end;
    return e.difference(s).inDays + 1;
  }
}

/// Latitude/Longitude pair
class LatLng {
  final double lat;
  final double lng;

  const LatLng(this.lat, this.lng);

  double distanceTo(LatLng other) {
    // Haversine formula approximation
    const earthRadiusKm = 6371;
    final dLat = _degreesToRadians(other.lat - lat);
    final dLng = _degreesToRadians(other.lng - lng);
    final a = (1 - cos(dLat)) / 2 +
        cos(_degreesToRadians(lat)) * cos(_degreesToRadians(other.lat)) * (1 - cos(dLng)) / 2;
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return earthRadiusKm * c;
  }

  double _degreesToRadians(double degrees) => degrees * pi / 180;

  String toPostGIS() => 'POINT($lng $lat)';
}
