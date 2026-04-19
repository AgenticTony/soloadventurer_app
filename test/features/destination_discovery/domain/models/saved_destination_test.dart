import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/saved_destination.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/destination.dart';

void main() {
  group('SaveType enum', () {
    test('should have all correct values', () {
      expect(SaveType.values.length, 2);
      expect(SaveType.wishlist, isA<SaveType>());
      expect(SaveType.trip, isA<SaveType>());
    });

    test('should have correct names', () {
      expect(SaveType.wishlist.name, 'wishlist');
      expect(SaveType.trip.name, 'trip');
    });

    test('should look up by name', () {
      expect(SaveType.values.byName('wishlist'), SaveType.wishlist);
      expect(SaveType.values.byName('trip'), SaveType.trip);
    });
  });

  group('SavedDestination', () {
    late DateTime now;
    late Destination testDestination;

    setUp(() {
      now = DateTime.now();
      testDestination = Destination(
        id: 'dest_1',
        name: 'Tokyo',
        description: 'A vibrant metropolis',
        latitude: 35.6762,
        longitude: 139.6503,
        countryCode: 'JP',
        region: 'Kanto',
        safetyScore: 9.2,
        safetyInsights: [],
        soloSuitabilityScore: 8.8,
        soloSuitabilityFactors: const SoloSuitabilityFactors(
          safety: 9.5,
          nightlife: 8.0,
          walkability: 9.0,
          accommodation: 9.0,
          soloDining: 9.5,
          communication: 7.0,
          overall: 8.8,
        ),
        budgetLevel: BudgetLevel.expensive,
        activityLevels: [ActivityLevel.moderate],
        tags: ['urban'],
        images: [],
        popularActivities: [],
        createdAt: now,
        updatedAt: now,
      );
    });

    test('should create with all required fields', () {
      final savedDest = SavedDestination(
        id: 'saved_1',
        userId: 'user_1',
        destination: testDestination,
        saveType: SaveType.wishlist,
        createdAt: now,
        updatedAt: now,
      );

      expect(savedDest.id, 'saved_1');
      expect(savedDest.userId, 'user_1');
      expect(savedDest.destination, testDestination);
      expect(savedDest.saveType, SaveType.wishlist);
      expect(savedDest.createdAt, now);
      expect(savedDest.updatedAt, now);
    });

    test('should create with optional fields', () {
      final savedDest = SavedDestination(
        id: 'saved_1',
        userId: 'user_1',
        destination: testDestination,
        saveType: SaveType.trip,
        tripId: 'trip_1',
        notes: 'Want to visit temples',
        createdAt: now,
        updatedAt: now,
      );

      expect(savedDest.tripId, 'trip_1');
      expect(savedDest.notes, 'Want to visit temples');
    });

    test('should serialize to JSON correctly', () {
      final savedDest = SavedDestination(
        id: 'saved_1',
        userId: 'user_1',
        destination: testDestination,
        saveType: SaveType.wishlist,
        notes: 'Want to visit',
        createdAt: now,
        updatedAt: now,
      );

      final json = savedDest.toJson();

      expect(json['id'], 'saved_1');
      expect(json['userId'], 'user_1');
      expect(json['destination'], isA<Map<String, dynamic>>());
      expect(json['saveType'], 'wishlist');
      expect(json['notes'], 'Want to visit');
      expect(json['createdAt'], isA<String>());
      expect(json['updatedAt'], isA<String>());
    });

    test('should deserialize from JSON correctly', () {
      final savedDest = SavedDestination(
        id: 'saved_1',
        userId: 'user_1',
        destination: testDestination,
        saveType: SaveType.trip,
        tripId: 'trip_1',
        notes: 'My notes',
        createdAt: now,
        updatedAt: now,
      );

      final json = savedDest.toJson();
      final deserialized = SavedDestination.fromJson(json);

      expect(deserialized.id, savedDest.id);
      expect(deserialized.userId, savedDest.userId);
      expect(deserialized.destination.id, savedDest.destination.id);
      expect(deserialized.saveType, savedDest.saveType);
      expect(deserialized.tripId, savedDest.tripId);
      expect(deserialized.notes, savedDest.notes);
    });

    test('should implement equality correctly', () {
      final saved1 = SavedDestination(
        id: 'saved_1',
        userId: 'user_1',
        destination: testDestination,
        saveType: SaveType.wishlist,
        createdAt: now,
        updatedAt: now,
      );

      final saved2 = SavedDestination(
        id: 'saved_1',
        userId: 'user_1',
        destination: testDestination,
        saveType: SaveType.wishlist,
        createdAt: now,
        updatedAt: now,
      );

      final saved3 = SavedDestination(
        id: 'saved_2',
        userId: 'user_1',
        destination: testDestination,
        saveType: SaveType.trip,
        createdAt: now,
        updatedAt: now,
      );

      expect(saved1, equals(saved2));
      expect(saved1, isNot(equals(saved3)));
      expect(saved1.hashCode, equals(saved2.hashCode));
    });

    test('should support copyWith', () {
      final savedDest = SavedDestination(
        id: 'saved_1',
        userId: 'user_1',
        destination: testDestination,
        saveType: SaveType.wishlist,
        createdAt: now,
        updatedAt: now,
      );

      final updated = savedDest.copyWith(
        notes: 'Updated notes',
        tripId: 'trip_1',
      );

      expect(updated.id, savedDest.id);
      expect(updated.notes, 'Updated notes');
      expect(updated.tripId, 'trip_1');
      expect(updated.saveType, savedDest.saveType);
    });

    test('isWishlist should return true when saveType is wishlist', () {
      final savedDest = SavedDestination(
        id: 'saved_1',
        userId: 'user_1',
        destination: testDestination,
        saveType: SaveType.wishlist,
        createdAt: now,
        updatedAt: now,
      );

      expect(savedDest.isWishlist, true);
      expect(savedDest.isTrip, false);
    });

    test('isTrip should return true when saveType is trip', () {
      final savedDest = SavedDestination(
        id: 'saved_1',
        userId: 'user_1',
        destination: testDestination,
        saveType: SaveType.trip,
        tripId: 'trip_1',
        createdAt: now,
        updatedAt: now,
      );

      expect(savedDest.isTrip, true);
      expect(savedDest.isWishlist, false);
    });

    test('hasNotes should return true when notes are present', () {
      final savedWithNotes = SavedDestination(
        id: 'saved_1',
        userId: 'user_1',
        destination: testDestination,
        saveType: SaveType.wishlist,
        notes: 'My travel notes',
        createdAt: now,
        updatedAt: now,
      );

      expect(savedWithNotes.hasNotes, true);
    });

    test('hasNotes should return false when notes are null', () {
      final savedWithoutNotes = SavedDestination(
        id: 'saved_1',
        userId: 'user_1',
        destination: testDestination,
        saveType: SaveType.wishlist,
        createdAt: now,
        updatedAt: now,
      );

      expect(savedWithoutNotes.hasNotes, false);
    });

    test('hasNotes should return false when notes are empty or whitespace', () {
      final savedWithEmptyNotes = SavedDestination(
        id: 'saved_1',
        userId: 'user_1',
        destination: testDestination,
        saveType: SaveType.wishlist,
        notes: '   ',
        createdAt: now,
        updatedAt: now,
      );

      expect(savedWithEmptyNotes.hasNotes, false);
    });

    test('withUpdatedTimestamp should update updatedAt timestamp', () {
      final originalTime = now;
      // final newTime = now.add(const Duration(hours: 1));

      final savedDest = SavedDestination(
        id: 'saved_1',
        userId: 'user_1',
        destination: testDestination,
        saveType: SaveType.wishlist,
        createdAt: originalTime,
        updatedAt: originalTime,
      );

      // Mock DateTime.now() behavior - in real tests we'd use a clock library
      // For now, just verify the method returns a new instance
      final updated = savedDest.withUpdatedTimestamp();

      expect(updated.id, savedDest.id);
      expect(updated.updatedAt, isNot(equals(savedDest.updatedAt)));
    });

    test('withNotes should update notes and timestamp', () {
      final savedDest = SavedDestination(
        id: 'saved_1',
        userId: 'user_1',
        destination: testDestination,
        saveType: SaveType.wishlist,
        createdAt: now,
        updatedAt: now,
      );

      final updated = savedDest.withNotes('New notes');

      expect(updated.notes, 'New notes');
      expect(updated.updatedAt, isNot(equals(savedDest.updatedAt)));
    });

    test('withNotes should trim whitespace from notes', () {
      final savedDest = SavedDestination(
        id: 'saved_1',
        userId: 'user_1',
        destination: testDestination,
        saveType: SaveType.wishlist,
        createdAt: now,
        updatedAt: now,
      );

      final updated = savedDest.withNotes('  New notes with spaces  ');

      expect(updated.notes, 'New notes with spaces');
    });

    test('withNotes should set notes to null if empty after trimming', () {
      final savedDest = SavedDestination(
        id: 'saved_1',
        userId: 'user_1',
        destination: testDestination,
        saveType: SaveType.wishlist,
        notes: 'Original notes',
        createdAt: now,
        updatedAt: now,
      );

      final updated = savedDest.withNotes('   ');

      expect(updated.notes, isNull);
    });

    test('should handle wishlist save type correctly', () {
      final savedDest = SavedDestination(
        id: 'saved_1',
        userId: 'user_1',
        destination: testDestination,
        saveType: SaveType.wishlist,
        createdAt: now,
        updatedAt: now,
      );

      expect(savedDest.saveType, SaveType.wishlist);
      expect(savedDest.tripId, isNull);
      expect(savedDest.isWishlist, true);
    });

    test('should handle trip save type with tripId', () {
      final savedDest = SavedDestination(
        id: 'saved_1',
        userId: 'user_1',
        destination: testDestination,
        saveType: SaveType.trip,
        tripId: 'trip_123',
        notes: 'Planned for summer trip',
        createdAt: now,
        updatedAt: now,
      );

      expect(savedDest.saveType, SaveType.trip);
      expect(savedDest.tripId, 'trip_123');
      expect(savedDest.isTrip, true);
      expect(savedDest.notes, 'Planned for summer trip');
    });
  });
}
