import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/matching/domain/entities/connection.dart';

void main() {
  group('Connection', () {
    late Connection testConnection;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 15);
      testConnection = Connection(
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
        createdAt: testDate,
      );
    });

    test('should create a connection with all required fields', () {
      expect(testConnection.id, 'conn-123');
      expect(testConnection.userAId, 'user-a');
      expect(testConnection.userBId, 'user-b');
      expect(testConnection.matchType, MatchType.geographicOverlap);
      expect(testConnection.status, ConnectionStatus.pending);
      expect(testConnection.overlapDays, 7);
      expect(testConnection.distanceMeters, 1500.0);
      expect(testConnection.isActive, true);
    });

    test('should support equality via Equatable', () {
      final connection1 = Connection(
        id: 'conn-123',
        userAId: 'user-a',
        userBId: 'user-b',
        matchType: MatchType.geographicOverlap,
        status: ConnectionStatus.pending,
        overlapStartDate: DateTime(2024, 2, 1),
        overlapEndDate: DateTime(2024, 2, 7),
        overlapDays: 7,
        createdAt: testDate,
      );

      final connection2 = Connection(
        id: 'conn-123',
        userAId: 'user-a',
        userBId: 'user-b',
        matchType: MatchType.geographicOverlap,
        status: ConnectionStatus.pending,
        overlapStartDate: DateTime(2024, 2, 1),
        overlapEndDate: DateTime(2024, 2, 7),
        overlapDays: 7,
        createdAt: testDate,
      );

      expect(connection1, equals(connection2));
    });

    test('should create an empty connection', () {
      final emptyConnection = Connection.empty();
      
      expect(emptyConnection.isEmpty, true);
      expect(emptyConnection.isNotEmpty, false);
      expect(emptyConnection.id, '');
    });

    test('should correctly identify non-empty connection', () {
      expect(testConnection.isEmpty, false);
      expect(testConnection.isNotEmpty, true);
    });

    test('should support copyWith', () {
      final updatedConnection = testConnection.copyWith(
        status: ConnectionStatus.accepted,
        isActive: false,
      );

      expect(updatedConnection.status, ConnectionStatus.accepted);
      expect(updatedConnection.isActive, false);
      expect(updatedConnection.id, 'conn-123'); // Unchanged
    });

    test('should include matched user profile when provided', () {
      final profile = MatchedUserProfile(
        id: 'user-b',
        firstName: 'Jane',
        ageRange: '25-30',
        homeCountry: 'US',
        gender: 'female',
      );

      final connectionWithProfile = testConnection.copyWith(
        matchedUserProfile: profile,
      );

      expect(connectionWithProfile.matchedUserProfile, isNotNull);
      expect(connectionWithProfile.matchedUserProfile!.firstName, 'Jane');
    });

    test('should provide meaningful toString representation', () {
      final str = testConnection.toString();
      
      expect(str, contains('conn-123'));
      expect(str, contains('user-a'));
      expect(str, contains('user-b'));
      expect(str, contains('7 days'));
    });

    group('ConnectionStatus enum', () {
      test('should have all expected statuses', () {
        expect(ConnectionStatus.values.length, 4);
        expect(ConnectionStatus.values, contains(ConnectionStatus.pending));
        expect(ConnectionStatus.values, contains(ConnectionStatus.accepted));
        expect(ConnectionStatus.values, contains(ConnectionStatus.declined));
        expect(ConnectionStatus.values, contains(ConnectionStatus.blocked));
      });
    });

    group('MatchType enum', () {
      test('should have all expected types', () {
        expect(MatchType.values.length, 3);
        expect(MatchType.values, contains(MatchType.geographicOverlap));
        expect(MatchType.values, contains(MatchType.activityMatch));
        expect(MatchType.values, contains(MatchType.combinedMatch));
      });
    });
  });

  group('MatchedUserProfile', () {
    test('should create a profile with all required fields', () {
      final profile = MatchedUserProfile(
        id: 'user-123',
        firstName: 'Jane',
        ageRange: '25-30',
        homeCountry: 'US',
        gender: 'female',
        avatarUrl: 'https://example.com/avatar.jpg',
      );

      expect(profile.id, 'user-123');
      expect(profile.firstName, 'Jane');
      expect(profile.ageRange, '25-30');
      expect(profile.homeCountry, 'US');
      expect(profile.gender, 'female');
      expect(profile.avatarUrl, 'https://example.com/avatar.jpg');
    });

    test('should create an empty profile', () {
      final emptyProfile = MatchedUserProfile.empty();
      
      expect(emptyProfile.isEmpty, true);
      expect(emptyProfile.id, '');
    });

    test('should support equality', () {
      final profile1 = MatchedUserProfile(
        id: 'user-123',
        firstName: 'Jane',
        ageRange: '25-30',
        homeCountry: 'US',
        gender: 'female',
      );

      final profile2 = MatchedUserProfile(
        id: 'user-123',
        firstName: 'Jane',
        ageRange: '25-30',
        homeCountry: 'US',
        gender: 'female',
      );

      expect(profile1, equals(profile2));
    });

    test('should include trip information when provided', () {
      final trip = MatchedUserTrip(
        destinationName: 'Paris, France',
        startDate: DateTime(2024, 2, 1),
        endDate: DateTime(2024, 2, 7),
      );

      final profile = MatchedUserProfile(
        id: 'user-123',
        firstName: 'Jane',
        ageRange: '25-30',
        homeCountry: 'US',
        gender: 'female',
        trip: trip,
      );

      expect(profile.trip, isNotNull);
      expect(profile.trip!.destinationName, 'Paris, France');
    });
  });

  group('MatchedUserTrip', () {
    test('should create a trip with required fields', () {
      final trip = MatchedUserTrip(
        destinationName: 'Paris, France',
        startDate: DateTime(2024, 2, 1),
        endDate: DateTime(2024, 2, 7),
      );

      expect(trip.destinationName, 'Paris, France');
      expect(trip.startDate, DateTime(2024, 2, 1));
      expect(trip.endDate, DateTime(2024, 2, 7));
    });

    test('should calculate duration in days correctly', () {
      final trip = MatchedUserTrip(
        destinationName: 'Paris, France',
        startDate: DateTime(2024, 2, 1),
        endDate: DateTime(2024, 2, 7),
      );

      expect(trip.durationInDays, 7);
    });

    test('should support equality', () {
      final trip1 = MatchedUserTrip(
        destinationName: 'Paris, France',
        startDate: DateTime(2024, 2, 1),
        endDate: DateTime(2024, 2, 7),
      );

      final trip2 = MatchedUserTrip(
        destinationName: 'Paris, France',
        startDate: DateTime(2024, 2, 1),
        endDate: DateTime(2024, 2, 7),
      );

      expect(trip1, equals(trip2));
    });
  });
}
