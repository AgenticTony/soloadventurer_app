import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/travel_interest.dart';
import 'package:soloadventurer/features/recommendations/data/datasources/recommendation_local_data_source.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/place_activity.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation.dart';

void main() {
  late RecommendationLocalDataSourceImpl dataSource;

  setUp(() {
    dataSource = RecommendationLocalDataSourceImpl();
  });

  group('RecommendationLocalDataSource - User Data Isolation', () {
    test('saveRecommendation - should isolate recommendations by userId',
        () async {
      // Arrange
      const user1Id = 'user-123';
      const user2Id = 'user-456';
      final recommendation1 = _createTestRecommendation('rec-1', 'Museum A');
      final recommendation2 = _createTestRecommendation('rec-2', 'Museum B');

      // Act
      await dataSource.saveRecommendation(user1Id, recommendation1);
      await dataSource.saveRecommendation(user2Id, recommendation2);

      // Assert - Each user should only see their own recommendations
      final user1Saved = await dataSource.getSavedRecommendations(user1Id);
      final user2Saved = await dataSource.getSavedRecommendations(user2Id);

      expect(user1Saved.length, 1,
          reason: 'User 1 should have 1 saved recommendation');
      expect(user2Saved.length, 1,
          reason: 'User 2 should have 1 saved recommendation');
      expect(user1Saved.first.id, 'rec-1',
          reason: 'User 1 should see their recommendation');
      expect(user2Saved.first.id, 'rec-2',
          reason: 'User 2 should see their recommendation');
    });

    test(
        'saveRecommendation - same recommendationId for different users should not collide',
        () async {
      // Arrange
      const user1Id = 'user-123';
      const user2Id = 'user-456';
      final recommendation1 =
          _createTestRecommendation('rec-same', 'Place for User 1');
      final recommendation2 =
          _createTestRecommendation('rec-same', 'Place for User 2');

      // Act - Both users save a recommendation with the same ID
      await dataSource.saveRecommendation(user1Id, recommendation1);
      await dataSource.saveRecommendation(user2Id, recommendation2);

      // Assert - Each user should have their own version
      final user1Saved = await dataSource.getSavedRecommendations(user1Id);
      final user2Saved = await dataSource.getSavedRecommendations(user2Id);

      expect(user1Saved.first.activity.name, 'Place for User 1',
          reason: 'User 1 should have their version');
      expect(user2Saved.first.activity.name, 'Place for User 2',
          reason: 'User 2 should have their version');
    });

    test('dismissRecommendation - should only dismiss for the requesting user',
        () async {
      // Arrange
      const user1Id = 'user-123';
      const user2Id = 'user-456';
      final recommendation = _createTestRecommendation('rec-1', 'Museum A');

      await dataSource.saveRecommendation(user1Id, recommendation);
      await dataSource.saveRecommendation(user2Id, recommendation);

      // Act - User 1 dismisses the recommendation
      await dataSource.dismissRecommendation(user1Id, 'rec-1');

      // Assert - Only User 1 should have it dismissed
      final user1Saved = await dataSource.getSavedRecommendations(user1Id);
      final user2Saved = await dataSource.getSavedRecommendations(user2Id);
      final user1Dismissed =
          await dataSource.getDismissedRecommendations(user1Id);
      final user2Dismissed =
          await dataSource.getDismissedRecommendations(user2Id);

      expect(user1Saved, isEmpty,
          reason: 'User 1 should have no saved recommendations');
      expect(user2Saved, isNotEmpty,
          reason: 'User 2 should still have their saved recommendation');
      expect(user1Dismissed, contains('rec-1'),
          reason: 'User 1 should have rec-1 in dismissed');
      expect(user2Dismissed, isEmpty,
          reason: 'User 2 should not have rec-1 in dismissed');
    });

    test('getDismissedRecommendations - should be isolated per user', () async {
      // Arrange
      const user1Id = 'user-123';
      const user2Id = 'user-456';
      final rec1 = _createTestRecommendation('rec-1', 'Place A');
      final rec2 = _createTestRecommendation('rec-2', 'Place B');

      await dataSource.saveRecommendation(user1Id, rec1);
      await dataSource.saveRecommendation(user2Id, rec2);

      // Act - Both users dismiss their respective recommendations
      await dataSource.dismissRecommendation(user1Id, 'rec-1');
      await dataSource.dismissRecommendation(user2Id, 'rec-2');

      // Assert - Dismissed lists should be separate
      final user1Dismissed =
          await dataSource.getDismissedRecommendations(user1Id);
      final user2Dismissed =
          await dataSource.getDismissedRecommendations(user2Id);

      expect(user1Dismissed, contains('rec-1'),
          reason: 'User 1 should have rec-1 dismissed');
      expect(user1Dismissed, isNot(contains('rec-2')),
          reason: 'User 1 should not see User 2 dismissals');
      expect(user2Dismissed, contains('rec-2'),
          reason: 'User 2 should have rec-2 dismissed');
      expect(user2Dismissed, isNot(contains('rec-1')),
          reason: 'User 2 should not see User 1 dismissals');
    });

    test('clearOldDismissals - should only clear for the specified user',
        () async {
      // Arrange
      const user1Id = 'user-123';
      const user2Id = 'user-456';
      final rec1 = _createTestRecommendation('rec-1', 'Place A');
      final rec2 = _createTestRecommendation('rec-2', 'Place B');

      await dataSource.dismissRecommendation(user1Id, 'rec-1');
      await dataSource.dismissRecommendation(user2Id, 'rec-2');

      // Act - Clear dismissals for User 1 only
      final clearedCount = await dataSource.clearOldDismissals(
        userId: user1Id,
        olderThan: const Duration(days: 1),
      );

      // Assert - Only User 1 dismissals should be cleared
      expect(clearedCount, 1, reason: 'Should clear 1 dismissal for User 1');
      final user1Dismissed =
          await dataSource.getDismissedRecommendations(user1Id);
      final user2Dismissed =
          await dataSource.getDismissedRecommendations(user2Id);

      expect(user1Dismissed, isEmpty,
          reason: 'User 1 dismissals should be cleared');
      expect(user2Dismissed, isNotEmpty,
          reason: 'User 2 dismissals should remain');
    });

    test('isDismissed - should only return true for the user who dismissed',
        () async {
      // Arrange
      const user1Id = 'user-123';
      const user2Id = 'user-456';
      final recommendation = _createTestRecommendation('rec-1', 'Place A');

      await dataSource.dismissRecommendation(user1Id, 'rec-1');

      // Act & Assert
      expect(dataSource.isDismissed(user1Id, 'rec-1'), isTrue,
          reason: 'User 1 should see the recommendation as dismissed');
      expect(dataSource.isDismissed(user2Id, 'rec-1'), isFalse,
          reason: 'User 2 should not see User 1 dismissals');
    });

    test('multiple users - should maintain complete isolation', () async {
      // Arrange - Multiple users with multiple recommendations
      const user1Id = 'user-123';
      const user2Id = 'user-456';
      const user3Id = 'user-789';

      final rec1 = _createTestRecommendation('rec-1', 'Place A');
      final rec2 = _createTestRecommendation('rec-2', 'Place B');
      final rec3 = _createTestRecommendation('rec-3', 'Place C');

      // Act - Each user saves different recommendations
      await dataSource.saveRecommendation(user1Id, rec1);
      await dataSource.saveRecommendation(user2Id, rec2);
      await dataSource.saveRecommendation(user3Id, rec3);

      await dataSource.dismissRecommendation(user1Id, 'rec-1');

      // Assert - Complete isolation
      final user1Saved = await dataSource.getSavedRecommendations(user1Id);
      final user2Saved = await dataSource.getSavedRecommendations(user2Id);
      final user3Saved = await dataSource.getSavedRecommendations(user3Id);

      expect(user1Saved, isEmpty,
          reason: 'User 1 dismissed their only recommendation');
      expect(user2Saved.length, 1,
          reason: 'User 2 should have 1 recommendation');
      expect(user3Saved.length, 1,
          reason: 'User 3 should have 1 recommendation');

      expect(await dataSource.getDismissedRecommendations(user1Id),
          contains('rec-1'));
      expect(await dataSource.getDismissedRecommendations(user2Id), isEmpty);
      expect(await dataSource.getDismissedRecommendations(user3Id), isEmpty);
    });
  });

  group('RecommendationLocalDataSource - Edge Cases', () {
    test('getSavedRecommendations - should return empty list for new user',
        () async {
      // Arrange
      const newUserId = 'new-user-999';

      // Act
      final saved = await dataSource.getSavedRecommendations(newUserId);

      // Assert
      expect(saved, isEmpty,
          reason: 'New user should have no saved recommendations');
    });

    test(
        'getSavedRecommendations - should return empty list for non-existent user',
        () async {
      // Arrange
      const nonExistentUserId = 'non-existent-user';

      // Act
      final saved = await dataSource.getSavedRecommendations(nonExistentUserId);

      // Assert
      expect(saved, isEmpty,
          reason: 'Non-existent user should have no saved recommendations');
    });

    test('dismissRecommendation - should be idempotent for same user',
        () async {
      // Arrange
      const userId = 'user-123';
      final recommendation = _createTestRecommendation('rec-1', 'Place A');
      await dataSource.saveRecommendation(userId, recommendation);

      // Act - Dismiss the same recommendation twice
      await dataSource.dismissRecommendation(userId, 'rec-1');
      await dataSource.dismissRecommendation(userId, 'rec-1');

      // Assert - Should not cause errors
      final saved = await dataSource.getSavedRecommendations(userId);
      final dismissed = await dataSource.getDismissedRecommendations(userId);

      expect(saved, isEmpty);
      expect(dismissed, contains('rec-1'));
    });

    test(
        'saveRecommendation - should allow updating saved recommendation for same user',
        () async {
      // Arrange
      const userId = 'user-123';
      final original = _createTestRecommendation('rec-1', 'Original Name');
      final updated = _createTestRecommendation('rec-1', 'Updated Name');

      // Act
      await dataSource.saveRecommendation(userId, original);
      await dataSource.saveRecommendation(userId, updated);

      // Assert - Should update, not duplicate
      final saved = await dataSource.getSavedRecommendations(userId);
      expect(saved.length, 1, reason: 'Should only have one recommendation');
      expect(saved.first.activity.name, 'Updated Name',
          reason: 'Should have the updated name');
    });
  });

  group('RecommendationLocalDataSource - Security', () {
    test(
        'should prevent user enumeration - empty results look same as non-existent user',
        () async {
      // Arrange
      const existingUserId = 'user-123';
      const nonExistentUserId = 'non-existent';
      final recommendation = _createTestRecommendation('rec-1', 'Place A');
      await dataSource.saveRecommendation(existingUserId, recommendation);

      // Act
      final existingUserSaved =
          await dataSource.getSavedRecommendations(existingUserId);
      await dataSource.dismissRecommendation(existingUserId, 'rec-1');
      final existingUserSavedAfterDismiss =
          await dataSource.getSavedRecommendations(existingUserId);
      final nonExistentUserSaved =
          await dataSource.getSavedRecommendations(nonExistentUserId);

      // Assert - Empty state should look the same for existing vs non-existent users
      expect(existingUserSavedAfterDismiss, isEmpty);
      expect(nonExistentUserSaved, isEmpty);
      // Both return empty lists, preventing user enumeration
    });
  });
}

/// Helper function to create test recommendations
PersonalizedRecommendation _createTestRecommendation(String id, String name) {
  return PersonalizedRecommendation(
    id: id,
    activity: PlaceActivity(
      id: id,
      name: name,
      category: RecommendationCategory.attraction,
      description: 'Test description',
      location: 'Test location',
      rating: 4.5,
      reviewCount: 100,
      priceLevel: '\$\$',
      cost: 20.0,
    ),
    metadata: RecommendationMetadata(
      matchedInterests: {TravelInterest.culture},
      suggestedDate: DateTime(2026, 1, 6),
      suggestedTime: const TimeOfDay(hour: 10),
      distance: DistanceFromHotel.walking,
      weather: WeatherContext.anyWeather,
      crowdLevel: CrowdLevel.medium,
    ),
    reasoning: 'Test reasoning for $name',
    relevanceScore: 85.0,
  );
}
