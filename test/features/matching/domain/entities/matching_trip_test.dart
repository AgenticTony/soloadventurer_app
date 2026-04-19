import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/matching/domain/entities/matching_trip.dart';

void main() {
  group('MatchingTrip', () {
    late MatchingTrip testTrip;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 15);
      testTrip = MatchingTrip(
        id: 'trip-123',
        userId: 'user-123',
        destinationName: 'Paris, France',
        latitude: 48.8566,
        longitude: 2.3522,
        locationPrecision: LocationPrecision.city,
        startDate: DateTime(2024, 2, 1),
        endDate: DateTime(2024, 2, 7),
        isActive: true,
        createdAt: testDate,
        updatedAt: testDate,
      );
    });

    test('should create a trip with all required fields', () {
      expect(testTrip.id, 'trip-123');
      expect(testTrip.userId, 'user-123');
      expect(testTrip.destinationName, 'Paris, France');
      expect(testTrip.latitude, 48.8566);
      expect(testTrip.longitude, 2.3522);
      expect(testTrip.locationPrecision, LocationPrecision.city);
      expect(testTrip.isActive, true);
    });

    test('should calculate duration in days correctly', () {
      expect(testTrip.durationInDays, 7);
    });

    test('should calculate duration correctly for single day trip', () {
      final singleDayTrip = testTrip.copyWith(
        startDate: DateTime(2024, 2, 1),
        endDate: DateTime(2024, 2, 1),
      );
      
      expect(singleDayTrip.durationInDays, 1);
    });

    test('should support equality via Equatable', () {
      final trip1 = MatchingTrip(
        id: 'trip-123',
        userId: 'user-123',
        destinationName: 'Paris, France',
        latitude: 48.8566,
        longitude: 2.3522,
        startDate: DateTime(2024, 2, 1),
        endDate: DateTime(2024, 2, 7),
        createdAt: testDate,
        updatedAt: testDate,
      );

      final trip2 = MatchingTrip(
        id: 'trip-123',
        userId: 'user-123',
        destinationName: 'Paris, France',
        latitude: 48.8566,
        longitude: 2.3522,
        startDate: DateTime(2024, 2, 1),
        endDate: DateTime(2024, 2, 7),
        createdAt: testDate,
        updatedAt: testDate,
      );

      expect(trip1, equals(trip2));
    });

    test('should create an empty trip', () {
      final emptyTrip = MatchingTrip.empty();
      
      expect(emptyTrip.isEmpty, true);
      expect(emptyTrip.isNotEmpty, false);
      expect(emptyTrip.id, '');
      expect(emptyTrip.userId, '');
    });

    test('should correctly identify non-empty trip', () {
      expect(testTrip.isEmpty, false);
      expect(testTrip.isNotEmpty, true);
    });

    test('should support copyWith', () {
      final updatedTrip = testTrip.copyWith(
        destinationName: 'London, UK',
        isActive: false,
      );

      expect(updatedTrip.destinationName, 'London, UK');
      expect(updatedTrip.isActive, false);
      expect(updatedTrip.id, 'trip-123'); // Unchanged
      expect(updatedTrip.userId, 'user-123'); // Unchanged
    });

    test('should identify current trip correctly', () {
      final now = DateTime.now();
      final currentTrip = MatchingTrip(
        id: 'current-trip',
        userId: 'user-123',
        destinationName: 'Paris, France',
        latitude: 48.8566,
        longitude: 2.3522,
        startDate: now.subtract(const Duration(days: 1)),
        endDate: now.add(const Duration(days: 1)),
        createdAt: now,
        updatedAt: now,
      );

      expect(currentTrip.isCurrentTrip, true);
      expect(currentTrip.isFutureTrip, false);
      expect(currentTrip.isPastTrip, false);
    });

    test('should identify future trip correctly', () {
      final now = DateTime.now();
      final futureTrip = MatchingTrip(
        id: 'future-trip',
        userId: 'user-123',
        destinationName: 'Paris, France',
        latitude: 48.8566,
        longitude: 2.3522,
        startDate: now.add(const Duration(days: 10)),
        endDate: now.add(const Duration(days: 17)),
        createdAt: now,
        updatedAt: now,
      );

      expect(futureTrip.isCurrentTrip, false);
      expect(futureTrip.isFutureTrip, true);
      expect(futureTrip.isPastTrip, false);
    });

    test('should identify past trip correctly', () {
      final now = DateTime.now();
      final pastTrip = MatchingTrip(
        id: 'past-trip',
        userId: 'user-123',
        destinationName: 'Paris, France',
        latitude: 48.8566,
        longitude: 2.3522,
        startDate: now.subtract(const Duration(days: 17)),
        endDate: now.subtract(const Duration(days: 10)),
        createdAt: now.subtract(const Duration(days: 20)),
        updatedAt: now.subtract(const Duration(days: 20)),
      );

      expect(pastTrip.isCurrentTrip, false);
      expect(pastTrip.isFutureTrip, false);
      expect(pastTrip.isPastTrip, true);
    });

    test('should handle edge case: trip starts today', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final tripStartingToday = MatchingTrip(
        id: 'today-trip',
        userId: 'user-123',
        destinationName: 'Paris, France',
        latitude: 48.8566,
        longitude: 2.3522,
        startDate: today,
        endDate: today.add(const Duration(days: 7)),
        createdAt: now,
        updatedAt: now,
      );

      expect(tripStartingToday.isCurrentTrip, true);
      expect(tripStartingToday.isFutureTrip, false);
    });

    test('should handle edge case: trip ends today', () {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      
      final tripEndingToday = MatchingTrip(
        id: 'ending-today-trip',
        userId: 'user-123',
        destinationName: 'Paris, France',
        latitude: 48.8566,
        longitude: 2.3522,
        startDate: today.subtract(const Duration(days: 7)),
        endDate: today,
        createdAt: now,
        updatedAt: now,
      );

      expect(tripEndingToday.isCurrentTrip, true);
      expect(tripEndingToday.isPastTrip, false);
    });

    test('should provide meaningful toString representation', () {
      final str = testTrip.toString();
      
      expect(str, contains('trip-123'));
      expect(str, contains('Paris, France'));
      expect(str, contains('active: true'));
    });

    group('LocationPrecision enum', () {
      test('should have all expected precision levels', () {
        expect(LocationPrecision.values.length, 3);
        expect(LocationPrecision.values, contains(LocationPrecision.city));
        expect(LocationPrecision.values, contains(LocationPrecision.neighborhood));
        expect(LocationPrecision.values, contains(LocationPrecision.exact));
      });

      test('should default to city precision', () {
        final defaultTrip = MatchingTrip(
          id: 'trip-123',
          userId: 'user-123',
          destinationName: 'Paris, France',
          latitude: 48.8566,
          longitude: 2.3522,
          startDate: DateTime(2024, 2, 1),
          endDate: DateTime(2024, 2, 7),
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(defaultTrip.locationPrecision, LocationPrecision.city);
      });
    });

    group('Coordinate validation', () {
      test('should accept valid latitude and longitude', () {
        final trip = MatchingTrip(
          id: 'trip-123',
          userId: 'user-123',
          destinationName: 'Sydney, Australia',
          latitude: -33.8688,
          longitude: 151.2093,
          startDate: DateTime(2024, 2, 1),
          endDate: DateTime(2024, 2, 7),
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(trip.latitude, -33.8688);
        expect(trip.longitude, 151.2093);
      });

      test('should handle zero coordinates', () {
        final trip = MatchingTrip(
          id: 'trip-123',
          userId: 'user-123',
          destinationName: 'Null Island',
          latitude: 0.0,
          longitude: 0.0,
          startDate: DateTime(2024, 2, 1),
          endDate: DateTime(2024, 2, 7),
          createdAt: testDate,
          updatedAt: testDate,
        );

        expect(trip.latitude, 0.0);
        expect(trip.longitude, 0.0);
      });
    });
  });
}
