import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/matching/data/models/connection_model.dart';
import 'package:soloadventurer/features/matching/domain/entities/connection.dart';

void main() {
  group('ConnectionModel', () {
    late ConnectionModel testConnectionModel;
    late Map<String, dynamic> testJson;

    setUp(() {
      testJson = {
        'id': 'conn-123',
        'user_a_id': 'user-a',
        'user_b_id': 'user-b',
        'match_type': 'geographicOverlap',
        'status': 'pending',
        'overlap_start_date': '2024-02-01',
        'overlap_end_date': '2024-02-07',
        'overlap_days': 7,
        'distance_meters': 1500.0,
        'is_active': true,
        'created_at': '2024-01-15T10:00:00Z',
        'matched_user': {
          'id': 'user-b',
          'first_name': 'Jane',
          'age_range': '25-30',
          'home_country': 'US',
          'gender': 'female',
          'avatar_url': 'https://example.com/avatar.jpg',
          'trip': {
            'destination_name': 'Paris, France',
            'start_date': '2024-02-01',
            'end_date': '2024-02-10',
          },
        },
      };

      testConnectionModel = ConnectionModel(
        id: 'conn-123',
        userAId: 'user-a',
        userBId: 'user-b',
        matchType: MatchType.geographicOverlap,
        status: ConnectionStatus.pending,
        overlapStartDate: DateTime(2024, 2, 1),
        overlapEndDate: DateTime(2024, 2, 7),
        overlapDays: 7,
        distanceMeters: 1500.0,
        isActive: true,
        createdAt: DateTime(2024, 1, 15, 10, 0, 0),
      );
    });

    group('fromJson', () {
      test('should create ConnectionModel from JSON correctly', () {
        final model = ConnectionModel.fromJson(testJson);

        expect(model.id, 'conn-123');
        expect(model.userAId, 'user-a');
        expect(model.userBId, 'user-b');
        expect(model.matchType, MatchType.geographicOverlap);
        expect(model.status, ConnectionStatus.pending);
        expect(model.overlapDays, 7);
        expect(model.distanceMeters, 1500.0);
        expect(model.isActive, true);
      });

      test('should parse match type correctly', () {
        testJson['match_type'] = 'activity_match';
        var model = ConnectionModel.fromJson(testJson);
        expect(model.matchType, MatchType.activityMatch);

        testJson['match_type'] = 'combined_match';
        model = ConnectionModel.fromJson(testJson);
        expect(model.matchType, MatchType.combinedMatch);

        testJson['match_type'] = 'geographic_overlap';
        model = ConnectionModel.fromJson(testJson);
        expect(model.matchType, MatchType.geographicOverlap);
      });

      test('should default to geographicOverlap for invalid match type', () {
        testJson['match_type'] = 'invalid';
        final model = ConnectionModel.fromJson(testJson);
        expect(model.matchType, MatchType.geographicOverlap);
      });

      test('should parse connection status correctly', () {
        final statuses = {
          'pending': ConnectionStatus.pending,
          'accepted': ConnectionStatus.accepted,
          'declined': ConnectionStatus.declined,
          'blocked': ConnectionStatus.blocked,
        };

        statuses.forEach((key, expectedStatus) {
          testJson['status'] = key;
          final model = ConnectionModel.fromJson(testJson);
          expect(model.status, expectedStatus);
        });
      });

      test('should default to pending for invalid status', () {
        testJson['status'] = 'invalid';
        final model = ConnectionModel.fromJson(testJson);
        expect(model.status, ConnectionStatus.pending);
      });

      test('should parse matched user profile when present', () {
        final model = ConnectionModel.fromJson(testJson);

        expect(model.matchedUserProfile, isNotNull);
        expect(model.matchedUserProfile!.id, 'user-b');
        expect(model.matchedUserProfile!.firstName, 'Jane');
        expect(model.matchedUserProfile!.ageRange, '25-30');
        expect(model.matchedUserProfile!.homeCountry, 'US');
        expect(model.matchedUserProfile!.gender, 'female');
        expect(model.matchedUserProfile!.avatarUrl, 'https://example.com/avatar.jpg');
      });

      test('should parse matched user trip when present', () {
        final model = ConnectionModel.fromJson(testJson);

        expect(model.matchedUserProfile!.trip, isNotNull);
        expect(model.matchedUserProfile!.trip!.destinationName, 'Paris, France');
        expect(model.matchedUserProfile!.trip!.startDate, DateTime(2024, 2, 1));
        expect(model.matchedUserProfile!.trip!.endDate, DateTime(2024, 2, 10));
      });

      test('should handle missing matched user profile', () {
        testJson['matched_user'] = null;
        final model = ConnectionModel.fromJson(testJson);

        expect(model.matchedUserProfile, isNull);
      });

      test('should handle optional distance_meters field', () {
        testJson['distance_meters'] = null;
        final model = ConnectionModel.fromJson(testJson);

        expect(model.distanceMeters, isNull);
      });

      test('should handle optional is_active field', () {
        testJson['is_active'] = null;
        final model = ConnectionModel.fromJson(testJson);

        expect(model.isActive, true); // Default value
      });
    });

    group('toJson', () {
      test('should convert ConnectionModel to JSON correctly', () {
        final json = testConnectionModel.toJson();

        expect(json['id'], 'conn-123');
        expect(json['user_a_id'], 'user-a');
        expect(json['user_b_id'], 'user-b');
        expect(json['match_type'], 'geographicOverlap');
        expect(json['status'], 'pending');
        expect(json['overlap_days'], 7);
        expect(json['distance_meters'], 1500.0);
        expect(json['is_active'], true);
      });

      test('should format dates as ISO 8601 date strings', () {
        final json = testConnectionModel.toJson();

        expect(json['overlap_start_date'], '2024-02-01');
        expect(json['overlap_end_date'], '2024-02-07');
      });

      test('should not include matched user profile in toJson', () {
        final json = testConnectionModel.toJson();

        // toJson is for sending to server, matched_user is read-only from server
        expect(json.containsKey('matched_user'), false);
      });
    });

    group('fromEntity', () {
      test('should create ConnectionModel from Connection entity', () {
        final entity = Connection(
          id: 'conn-789',
          userAId: 'user-x',
          userBId: 'user-y',
          matchType: MatchType.activityMatch,
          status: ConnectionStatus.accepted,
          overlapStartDate: DateTime(2024, 3, 1),
          overlapEndDate: DateTime(2024, 3, 7),
          overlapDays: 7,
          distanceMeters: 2000.0,
          isActive: false,
          createdAt: DateTime(2024, 1, 15),
        );

        final model = ConnectionModel.fromEntity(entity);

        expect(model.id, 'conn-789');
        expect(model.userAId, 'user-x');
        expect(model.userBId, 'user-y');
        expect(model.matchType, MatchType.activityMatch);
        expect(model.status, ConnectionStatus.accepted);
        expect(model.distanceMeters, 2000.0);
        expect(model.isActive, false);
      });
    });

    group('toLocalDbMap', () {
      test('should convert to local database format correctly', () {
        final map = testConnectionModel.toLocalDbMap();

        expect(map['id'], 'conn-123');
        expect(map['user_a_id'], 'user-a');
        expect(map['user_b_id'], 'user-b');
        expect(map['match_type'], 'geographicOverlap');
        expect(map['status'], 'pending');
        expect(map['overlap_days'], 7);
        expect(map['is_active'], 1); // SQLite boolean as int
      });

      test('should convert boolean to integer for SQLite', () {
        final inactiveConnection = ConnectionModel.fromEntity(testConnectionModel.copyWith(isActive: false));
        final map = inactiveConnection.toLocalDbMap();

        expect(map['is_active'], 0);
      });
    });

    group('fromLocalDbMap', () {
      test('should create ConnectionModel from local database format', () {
        final map = {
          'id': 'conn-123',
          'user_a_id': 'user-a',
          'user_b_id': 'user-b',
          'match_type': 'geographicOverlap',
          'status': 'pending',
          'overlap_start_date': '2024-02-01',
          'overlap_end_date': '2024-02-07',
          'overlap_days': 7,
          'distance_meters': 1500.0,
          'is_active': 1,
          'created_at': '2024-01-15T10:00:00.000',
        };

        final model = ConnectionModel.fromLocalDbMap(map);

        expect(model.id, 'conn-123');
        expect(model.userAId, 'user-a');
        expect(model.userBId, 'user-b');
        expect(model.matchType, MatchType.geographicOverlap);
        expect(model.status, ConnectionStatus.pending);
        expect(model.overlapDays, 7);
        expect(model.isActive, true);
      });

      test('should convert integer to boolean from SQLite', () {
        final map = <String, dynamic>{
          'id': 'conn-123',
          'user_a_id': 'user-a',
          'user_b_id': 'user-b',
          'match_type': 'geographicOverlap',
          'status': 'pending',
          'overlap_start_date': '2024-02-01',
          'overlap_end_date': '2024-02-07',
          'overlap_days': 7,
          'distance_meters': 1500.0,
          'is_active': 0, // false in SQLite
          'created_at': '2024-01-15T10:00:00.000',
        };

        final model = ConnectionModel.fromLocalDbMap(map);

        expect(model.isActive, false);
      });

      test('should not include matched user profile from local DB', () {
        final map = {
          'id': 'conn-123',
          'user_a_id': 'user-a',
          'user_b_id': 'user-b',
          'match_type': 'geographicOverlap',
          'status': 'pending',
          'overlap_start_date': '2024-02-01',
          'overlap_end_date': '2024-02-07',
          'overlap_days': 7,
          'is_active': 1,
          'created_at': '2024-01-15T10:00:00.000',
        };

        final model = ConnectionModel.fromLocalDbMap(map);

        // Local DB doesn't store matched user profile
        expect(model.matchedUserProfile, isNull);
      });
    });

    group('Round-trip serialization', () {
      test('should maintain data integrity through fromJson/toJson cycle', () {
        final model1 = ConnectionModel.fromJson(testJson);
        final json = model1.toJson();
        final model2 = ConnectionModel.fromJson(json);

        expect(model1.id, model2.id);
        expect(model1.userAId, model2.userAId);
        expect(model1.userBId, model2.userBId);
        expect(model1.matchType, model2.matchType);
        expect(model1.status, model2.status);
        expect(model1.overlapDays, model2.overlapDays);
        expect(model1.isActive, model2.isActive);
      });

      test('should maintain data integrity through local DB cycle', () {
        final map1 = testConnectionModel.toLocalDbMap();
        final model = ConnectionModel.fromLocalDbMap(map1);
        final map2 = model.toLocalDbMap();

        expect(map1['id'], map2['id']);
        expect(map1['match_type'], map2['match_type']);
        expect(map1['status'], map2['status']);
        expect(map1['is_active'], map2['is_active']);
      });
    });

    group('Inherited entity behavior', () {
      test('should inherit Connection properties and methods', () {
        expect(testConnectionModel.isEmpty, false);
        expect(testConnectionModel.isNotEmpty, true);
      });

      test('should support copyWith from base class', () {
        final updated = testConnectionModel.copyWith(
          status: ConnectionStatus.accepted,
        );

        expect(updated.status, ConnectionStatus.accepted);
        expect(updated.id, 'conn-123');
      });
    });
  });

  group('MatchedUserProfileModel', () {
    late Map<String, dynamic> testJson;

    setUp(() {
      testJson = {
        'id': 'user-123',
        'first_name': 'Jane',
        'age_range': '25-30',
        'home_country': 'US',
        'gender': 'female',
        'avatar_url': 'https://example.com/avatar.jpg',
        'trip': {
          'destination_name': 'Paris, France',
          'start_date': '2024-02-01',
          'end_date': '2024-02-10',
        },
      };
    });

    test('should create from JSON correctly', () {
      final model = MatchedUserProfileModel.fromJson(testJson);

      expect(model.id, 'user-123');
      expect(model.firstName, 'Jane');
      expect(model.ageRange, '25-30');
      expect(model.homeCountry, 'US');
      expect(model.gender, 'female');
      expect(model.avatarUrl, 'https://example.com/avatar.jpg');
    });

    test('should parse trip when present', () {
      final model = MatchedUserProfileModel.fromJson(testJson);

      expect(model.trip, isNotNull);
      expect(model.trip!.destinationName, 'Paris, France');
    });

    test('should handle missing trip', () {
      testJson['trip'] = null;
      final model = MatchedUserProfileModel.fromJson(testJson);

      expect(model.trip, isNull);
    });

    test('should convert to JSON correctly', () {
      final model = MatchedUserProfileModel.fromJson(testJson);
      final json = model.toJson();

      expect(json['id'], 'user-123');
      expect(json['first_name'], 'Jane');
      expect(json['age_range'], '25-30');
    });

    test('should create from entity', () {
      final entity = MatchedUserProfile(
        id: 'user-456',
        firstName: 'John',
        ageRange: '30-35',
        homeCountry: 'UK',
        gender: 'male',
      );

      final model = MatchedUserProfileModel.fromEntity(entity);

      expect(model.id, 'user-456');
      expect(model.firstName, 'John');
      expect(model.ageRange, '30-35');
    });
  });

  group('MatchedUserTripModel', () {
    test('should create from JSON correctly', () {
      final json = {
        'destination_name': 'Paris, France',
        'start_date': '2024-02-01',
        'end_date': '2024-02-10',
      };

      final model = MatchedUserTripModel.fromJson(json);

      expect(model.destinationName, 'Paris, France');
      expect(model.startDate, DateTime(2024, 2, 1));
      expect(model.endDate, DateTime(2024, 2, 10));
    });

    test('should convert to JSON correctly', () {
      final model = MatchedUserTripModel(
        destinationName: 'London, UK',
        startDate: DateTime(2024, 3, 1),
        endDate: DateTime(2024, 3, 7),
      );

      final json = model.toJson();

      expect(json['destination_name'], 'London, UK');
      expect(json['start_date'], '2024-03-01');
      expect(json['end_date'], '2024-03-07');
    });

    test('should create from entity', () {
      final entity = MatchedUserTrip(
        destinationName: 'Berlin, Germany',
        startDate: DateTime(2024, 4, 1),
        endDate: DateTime(2024, 4, 7),
      );

      final model = MatchedUserTripModel.fromEntity(entity);

      expect(model.destinationName, 'Berlin, Germany');
      expect(model.durationInDays, 7);
    });

    test('should calculate duration correctly', () {
      final model = MatchedUserTripModel(
        destinationName: 'Tokyo, Japan',
        startDate: DateTime(2024, 5, 1),
        endDate: DateTime(2024, 5, 14),
      );

      expect(model.durationInDays, 14);
    });
  });
}
