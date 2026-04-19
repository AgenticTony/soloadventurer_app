import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/matching/data/models/trip_model.dart';
import 'package:soloadventurer/features/matching/domain/entities/matching_trip.dart';

void main() {
  group('TripModel', () {
    late TripModel testTripModel;
    late Map<String, dynamic> testJson;

    setUp(() {
      testJson = {
        'id': 'trip-123',
        'user_id': 'user-456',
        'destination_name': 'Paris, France',
        'location': {
          'type': 'Point',
          'coordinates': [2.3522, 48.8566], // longitude, latitude (GeoJSON format)
        },
        'location_precision': 'city',
        'start_date': '2024-02-01',
        'end_date': '2024-02-07',
        'is_active': true,
        'created_at': '2024-01-15T10:00:00Z',
        'updated_at': '2024-01-15T10:00:00Z',
      };

      testTripModel = TripModel(
        id: 'trip-123',
        userId: 'user-456',
        destinationName: 'Paris, France',
        latitude: 48.8566,
        longitude: 2.3522,
        locationPrecision: LocationPrecision.city,
        startDate: DateTime(2024, 2, 1),
        endDate: DateTime(2024, 2, 7),
        isActive: true,
        createdAt: DateTime(2024, 1, 15, 10, 0, 0),
        updatedAt: DateTime(2024, 1, 15, 10, 0, 0),
      );
    });

    group('fromJson', () {
      test('should create TripModel from JSON correctly', () {
        final model = TripModel.fromJson(testJson);

        expect(model.id, 'trip-123');
        expect(model.userId, 'user-456');
        expect(model.destinationName, 'Paris, France');
        expect(model.latitude, 48.8566);
        expect(model.longitude, 2.3522);
        expect(model.locationPrecision, LocationPrecision.city);
        expect(model.isActive, true);
      });

      test('should parse GeoJSON coordinates correctly (longitude, latitude)', () {
        final model = TripModel.fromJson(testJson);
        
        // GeoJSON uses [longitude, latitude] order
        expect(model.longitude, 2.3522);
        expect(model.latitude, 48.8566);
      });

      test('should parse date strings correctly', () {
        final model = TripModel.fromJson(testJson);

        expect(model.startDate.year, 2024);
        expect(model.startDate.month, 2);
        expect(model.startDate.day, 1);
        expect(model.endDate.year, 2024);
        expect(model.endDate.month, 2);
        expect(model.endDate.day, 7);
      });

      test('should handle optional is_active field', () {
        testJson['is_active'] = null;
        final model = TripModel.fromJson(testJson);

        expect(model.isActive, true); // Default value
      });

      test('should parse location precision correctly', () {
        testJson['location_precision'] = 'neighborhood';
        var model = TripModel.fromJson(testJson);
        expect(model.locationPrecision, LocationPrecision.neighborhood);

        testJson['location_precision'] = 'exact';
        model = TripModel.fromJson(testJson);
        expect(model.locationPrecision, LocationPrecision.exact);

        testJson['location_precision'] = 'city';
        model = TripModel.fromJson(testJson);
        expect(model.locationPrecision, LocationPrecision.city);
      });

      test('should default to city precision if invalid', () {
        testJson['location_precision'] = 'invalid';
        final model = TripModel.fromJson(testJson);

        expect(model.locationPrecision, LocationPrecision.city);
      });

      test('should default to city precision if null', () {
        testJson['location_precision'] = null;
        final model = TripModel.fromJson(testJson);

        expect(model.locationPrecision, LocationPrecision.city);
      });
    });

    group('toJson', () {
      test('should convert TripModel to JSON correctly', () {
        final json = testTripModel.toJson();

        expect(json['id'], 'trip-123');
        expect(json['user_id'], 'user-456');
        expect(json['destination_name'], 'Paris, France');
        expect(json['location']['type'], 'Point');
        expect(json['location']['coordinates'], [2.3522, 48.8566]);
        expect(json['location_precision'], 'city');
        expect(json['is_active'], true);
      });

      test('should format dates as ISO 8601 date strings', () {
        final json = testTripModel.toJson();

        expect(json['start_date'], '2024-02-01');
        expect(json['end_date'], '2024-02-07');
      });

      test('should format timestamps as ISO 8601 strings', () {
        final json = testTripModel.toJson();

        expect(json['created_at'], contains('2024-01-15'));
        expect(json['updated_at'], contains('2024-01-15'));
      });

      test('should use GeoJSON format for coordinates (longitude, latitude)', () {
        final json = testTripModel.toJson();

        expect(json['location']['coordinates'][0], 2.3522); // longitude
        expect(json['location']['coordinates'][1], 48.8566); // latitude
      });
    });

    group('fromEntity', () {
      test('should create TripModel from MatchingTrip entity', () {
        final entity = MatchingTrip(
          id: 'trip-789',
          userId: 'user-123',
          destinationName: 'London, UK',
          latitude: 51.5074,
          longitude: -0.1278,
          locationPrecision: LocationPrecision.neighborhood,
          startDate: DateTime(2024, 3, 1),
          endDate: DateTime(2024, 3, 7),
          isActive: false,
          createdAt: DateTime(2024, 1, 15),
          updatedAt: DateTime(2024, 1, 15),
        );

        final model = TripModel.fromEntity(entity);

        expect(model.id, 'trip-789');
        expect(model.userId, 'user-123');
        expect(model.destinationName, 'London, UK');
        expect(model.latitude, 51.5074);
        expect(model.longitude, -0.1278);
        expect(model.locationPrecision, LocationPrecision.neighborhood);
        expect(model.isActive, false);
      });
    });

    group('toLocalDbMap', () {
      test('should convert to local database format correctly', () {
        final map = testTripModel.toLocalDbMap();

        expect(map['id'], 'trip-123');
        expect(map['user_id'], 'user-456');
        expect(map['destination_name'], 'Paris, France');
        expect(map['latitude'], 48.8566);
        expect(map['longitude'], 2.3522);
        expect(map['location_precision'], 'city');
        expect(map['is_active'], 1); // SQLite boolean as int
      });

      test('should convert boolean to integer for SQLite', () {
        final inactiveTrip = TripModel.fromEntity(testTripModel.copyWith(isActive: false));
        final map = inactiveTrip.toLocalDbMap();

        expect(map['is_active'], 0);
      });
    });

    group('fromLocalDbMap', () {
      test('should create TripModel from local database format', () {
        final map = {
          'id': 'trip-123',
          'user_id': 'user-456',
          'destination_name': 'Paris, France',
          'latitude': 48.8566,
          'longitude': 2.3522,
          'location_precision': 'city',
          'start_date': '2024-02-01',
          'end_date': '2024-02-07',
          'is_active': 1,
          'created_at': '2024-01-15T10:00:00.000',
          'updated_at': '2024-01-15T10:00:00.000',
        };

        final model = TripModel.fromLocalDbMap(map);

        expect(model.id, 'trip-123');
        expect(model.latitude, 48.8566);
        expect(model.longitude, 2.3522);
        expect(model.isActive, true);
      });

      test('should convert integer to boolean from SQLite', () {
        final map = <String, dynamic>{
          'id': 'trip-123',
          'user_id': 'user-456',
          'destination_name': 'Paris, France',
          'latitude': 48.8566,
          'longitude': 2.3522,
          'location_precision': 'city',
          'start_date': '2024-02-01',
          'end_date': '2024-02-07',
          'is_active': 0, // false in SQLite
          'created_at': '2024-01-15T10:00:00.000',
          'updated_at': '2024-01-15T10:00:00.000',
        };

        final model = TripModel.fromLocalDbMap(map);

        expect(model.isActive, false);
      });
    });

    group('Round-trip serialization', () {
      test('should maintain data integrity through fromJson/toJson cycle', () {
        final model1 = TripModel.fromJson(testJson);
        final json = model1.toJson();
        final model2 = TripModel.fromJson(json);

        expect(model1.id, model2.id);
        expect(model1.userId, model2.userId);
        expect(model1.destinationName, model2.destinationName);
        expect(model1.latitude, model2.latitude);
        expect(model1.longitude, model2.longitude);
        expect(model1.locationPrecision, model2.locationPrecision);
        expect(model1.isActive, model2.isActive);
      });

      test('should maintain data integrity through local DB cycle', () {
        final map1 = testTripModel.toLocalDbMap();
        final model = TripModel.fromLocalDbMap(map1);
        final map2 = model.toLocalDbMap();

        expect(map1['id'], map2['id']);
        expect(map1['latitude'], map2['latitude']);
        expect(map1['longitude'], map2['longitude']);
        expect(map1['is_active'], map2['is_active']);
      });
    });

    group('Inherited entity behavior', () {
      test('should inherit MatchingTrip properties and methods', () {
        expect(testTripModel.durationInDays, 7);
        expect(testTripModel.isEmpty, false);
        expect(testTripModel.isNotEmpty, true);
      });

      test('should support copyWith from base class', () {
        final updated = testTripModel.copyWith(
          destinationName: 'Berlin, Germany',
        );

        expect(updated.destinationName, 'Berlin, Germany');
        expect(updated.id, 'trip-123');
      });
    });
  });
}
