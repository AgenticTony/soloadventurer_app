// Test Fixtures - SoloAdventurer
// Central location for all test fixtures

export 'fixtures/users.dart';
export 'fixtures/trips.dart';
export 'fixtures/connections.dart';
export 'fixtures/activities.dart';

/// Common test constants
class TestConstants {
  // Dates
  static final DateTime april10 = DateTime(2026, 4, 10);
  static final DateTime april15 = DateTime(2026, 4, 15);
  static final DateTime april20 = DateTime(2026, 4, 20);
  static final DateTime april1 = DateTime(2026, 4, 1);
  static final DateTime april5 = DateTime(2026, 4, 5);
  
  // Locations
  static const String parisCoords = 'POINT(2.3522 48.8566)';
  static const String lyonCoords = 'POINT(4.8357 45.7640)';
  static const String berlinCoords = 'POINT(13.4050 52.5200)';
  static const String londonCoords = 'POINT(-0.1276 51.5074)';
  
  // Distances
  static const double parisLyonKm = 394.0;
  static const double parisLondonKm = 344.0;
  static const double parisBerlinKm = 878.0;
  
  // Benchmark settings
  static const int benchmarkTripCount = 100000;
  static const int benchmarkUserCount = 50000;
}
