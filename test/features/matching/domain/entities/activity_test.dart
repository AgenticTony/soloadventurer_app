import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/matching/domain/entities/activity.dart';

void main() {
  group('Activity', () {
    late Activity testActivity;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 15);
      testActivity = Activity(
        id: 'activity-123',
        name: 'Coffee',
        category: 'food',
        icon: '☕',
        isLocationSpecific: false,
        createdAt: testDate,
      );
    });

    test('should create an activity with all required fields', () {
      expect(testActivity.id, 'activity-123');
      expect(testActivity.name, 'Coffee');
      expect(testActivity.category, 'food');
      expect(testActivity.icon, '☕');
      expect(testActivity.isLocationSpecific, false);
    });

    test('should create an activity with minimal fields', () {
      final minimalActivity = Activity(
        id: 'activity-456',
        name: 'Hiking',
        category: 'outdoor',
        createdAt: testDate,
      );

      expect(minimalActivity.icon, isNull);
      expect(minimalActivity.isLocationSpecific, false); // Default value
    });

    test('should support equality via Equatable', () {
      final activity1 = Activity(
        id: 'activity-123',
        name: 'Coffee',
        category: 'food',
        icon: '☕',
        createdAt: testDate,
      );

      final activity2 = Activity(
        id: 'activity-123',
        name: 'Coffee',
        category: 'food',
        icon: '☕',
        createdAt: testDate,
      );

      expect(activity1, equals(activity2));
    });

    test('should not be equal if fields differ', () {
      final activity1 = Activity(
        id: 'activity-123',
        name: 'Coffee',
        category: 'food',
        createdAt: testDate,
      );

      final activity2 = Activity(
        id: 'activity-456',
        name: 'Tea',
        category: 'food',
        createdAt: testDate,
      );

      expect(activity1, isNot(equals(activity2)));
    });

    test('should create an empty activity', () {
      final emptyActivity = Activity.empty();
      
      expect(emptyActivity.isEmpty, true);
      expect(emptyActivity.isNotEmpty, false);
      expect(emptyActivity.id, '');
      expect(emptyActivity.name, '');
      expect(emptyActivity.category, '');
    });

    test('should correctly identify non-empty activity', () {
      expect(testActivity.isEmpty, false);
      expect(testActivity.isNotEmpty, true);
    });

    test('should support copyWith', () {
      final updatedActivity = testActivity.copyWith(
        name: 'Tea',
        icon: '🍵',
      );

      expect(updatedActivity.name, 'Tea');
      expect(updatedActivity.icon, '🍵');
      expect(updatedActivity.id, 'activity-123'); // Unchanged
      expect(updatedActivity.category, 'food'); // Unchanged
    });

    test('should handle location-specific activities', () {
      final locationSpecificActivity = Activity(
        id: 'activity-789',
        name: 'Eiffel Tower Visit',
        category: 'sightseeing',
        icon: '🗼',
        isLocationSpecific: true,
        createdAt: testDate,
      );

      expect(locationSpecificActivity.isLocationSpecific, true);
    });

    test('should provide meaningful toString representation', () {
      final str = testActivity.toString();
      
      expect(str, contains('activity-123'));
      expect(str, contains('Coffee'));
      expect(str, contains('food'));
      expect(str, contains('☕'));
    });

    group('Activity categories', () {
      test('should support various categories', () {
        final categories = ['food', 'outdoor', 'culture', 'nightlife', 'sports'];
        
        for (final category in categories) {
          final activity = Activity(
            id: 'test-${category}',
            name: 'Test',
            category: category,
            createdAt: testDate,
          );
          
          expect(activity.category, category);
        }
      });
    });
  });

  group('UserActivity', () {
    late UserActivity testUserActivity;
    late DateTime testDate;

    setUp(() {
      testDate = DateTime(2024, 1, 15);
      testUserActivity = UserActivity(
        id: 'user-activity-123',
        userId: 'user-456',
        activityId: 'activity-789',
        createdAt: testDate,
      );
    });

    test('should create a user activity with all required fields', () {
      expect(testUserActivity.id, 'user-activity-123');
      expect(testUserActivity.userId, 'user-456');
      expect(testUserActivity.activityId, 'activity-789');
      expect(testUserActivity.createdAt, testDate);
    });

    test('should support equality via Equatable', () {
      final ua1 = UserActivity(
        id: 'user-activity-123',
        userId: 'user-456',
        activityId: 'activity-789',
        createdAt: testDate,
      );

      final ua2 = UserActivity(
        id: 'user-activity-123',
        userId: 'user-456',
        activityId: 'activity-789',
        createdAt: testDate,
      );

      expect(ua1, equals(ua2));
    });

    test('should create an empty user activity', () {
      final emptyUserActivity = UserActivity.empty();
      
      expect(emptyUserActivity.isEmpty, true);
      expect(emptyUserActivity.isNotEmpty, false);
      expect(emptyUserActivity.id, '');
      expect(emptyUserActivity.userId, '');
      expect(emptyUserActivity.activityId, '');
    });

    test('should correctly identify non-empty user activity', () {
      expect(testUserActivity.isEmpty, false);
      expect(testUserActivity.isNotEmpty, true);
    });

    test('should link user to activity correctly', () {
      // This test verifies the relationship between user and activity
      expect(testUserActivity.userId, isNotEmpty);
      expect(testUserActivity.activityId, isNotEmpty);
      expect(testUserActivity.userId, isNot(equals(testUserActivity.activityId)));
    });
  });
}
