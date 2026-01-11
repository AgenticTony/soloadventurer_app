import 'dart:math';

/// Generates test data for performance testing scenarios.
///
/// Usage:
/// ```dart
/// final id = PerformanceTestDataGenerator.generateId();
/// final trip = PerformanceTestDataGenerator.generateTripData();
/// ```
class PerformanceTestDataGenerator {
  PerformanceTestDataGenerator._();

  static final _random = Random();

  /// Generate a unique test ID
  static String generateId() =>
      'test-${DateTime.now().millisecondsSinceEpoch}-${_random.nextInt(999999)}';

  /// Generate a random string of specified length
  static String generateString(int length) {
    const chars =
        'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789';
    return List.generate(
      length,
      (_) => chars[_random.nextInt(chars.length)],
    ).join();
  }

  /// Generate a random date within the past year
  static DateTime generateDate() {
    return DateTime.now().subtract(Duration(days: _random.nextInt(365)));
  }

  /// Generate a random date within a range
  static DateTime generateDateInRange(DateTime start, DateTime end) {
    final diff = end.difference(start).inDays;
    return start.add(Duration(days: _random.nextInt(diff.abs())));
  }

  /// Generate a random JSON-like object with specified fields
  static Map<String, dynamic> generateJsonObject(int fields) {
    return Map.fromEntries(
      List.generate(
        fields,
        (i) => MapEntry('field$i', generateString(10)),
      ),
    );
  }

  /// Generate random coordinates (latitude, longitude)
  static ({double latitude, double longitude}) generateCoordinates() {
    return (
      latitude: -90 + _random.nextDouble() * 180,
      longitude: -180 + _random.nextDouble() * 360,
    );
  }

  /// Generate mock trip data
  static Map<String, dynamic> generateTripData() {
    final coords = generateCoordinates();
    return {
      'id': generateId(),
      'title': 'Trip ${generateString(5)}',
      'description': generateString(100),
      'startDate': generateDate().toIso8601String(),
      'endDate': generateDate().toIso8601String(),
      'latitude': coords.latitude,
      'longitude': coords.longitude,
      'status': ['planned', 'active', 'completed'][_random.nextInt(3)],
    };
  }

  /// Generate mock journal entry data
  static Map<String, dynamic> generateJournalEntryData() {
    return {
      'id': generateId(),
      'tripId': generateId(),
      'title': 'Entry ${generateString(5)}',
      'content': generateString(500),
      'createdAt': generateDate().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'mood': [
        'happy',
        'excited',
        'peaceful',
        'adventurous'
      ][_random.nextInt(4)],
      'tags': List.generate(_random.nextInt(5), (_) => generateString(8)),
    };
  }

  /// Generate a batch of test data
  static List<Map<String, dynamic>> generateBatch(
    int count,
    Map<String, dynamic> Function() generator,
  ) {
    return List.generate(count, (_) => generator());
  }
}
