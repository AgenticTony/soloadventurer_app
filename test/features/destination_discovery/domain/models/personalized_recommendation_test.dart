import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/personalized_recommendation.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/destination.dart';

void main() {
  group('RecommendationSource enum', () {
    test('should have all correct values', () {
      expect(RecommendationSource.values.length, 6);

      expect(RecommendationSource.userPreferences, isA<RecommendationSource>());
      expect(RecommendationSource.pastTrips, isA<RecommendationSource>());
      expect(RecommendationSource.similarUsers, isA<RecommendationSource>());
      expect(RecommendationSource.trending, isA<RecommendationSource>());
      expect(RecommendationSource.curated, isA<RecommendationSource>());
      expect(RecommendationSource.aiGenerated, isA<RecommendationSource>());
    });

    test('should serialize correctly', () {
      // Test JSON serialization through the PersonalizedRecommendation model
      final recommendation = PersonalizedRecommendation(
        id: 'rec_1',
        userId: 'user_1',
        recommendations: const [],
        source: RecommendationSource.userPreferences,
        generatedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      final json = recommendation.toJson();
      expect(json['source'], 'user_preferences');
    });

    test('should deserialize correctly', () {
      // Test JSON serialization/deserialization through the PersonalizedRecommendation model
      final recommendation = PersonalizedRecommendation(
        id: 'rec_1',
        userId: 'user_1',
        recommendations: const [],
        source: RecommendationSource.userPreferences,
        generatedAt: DateTime.now(),
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      final json = recommendation.toJson();
      expect(json['source'], 'user_preferences');

      final deserialized = PersonalizedRecommendation.fromJson(json);
      expect(deserialized.source, RecommendationSource.userPreferences);
    });
  });

  group('RecommendedDestination', () {
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
        images: ['https://example.com/tokyo1.jpg'],
        popularActivities: [],
        createdAt: now,
        updatedAt: now,
      );
    });

    test('should create with all required fields', () {
      final recommendedDest = RecommendedDestination(
        destination: testDestination,
        matchScore: 0.85,
        reason: 'Perfect for your love of cultural experiences',
        matchingFactors: ['high solo suitability', 'cultural activities'],
      );

      expect(recommendedDest.destination, testDestination);
      expect(recommendedDest.matchScore, 0.85);
      expect(recommendedDest.reason, 'Perfect for your love of cultural experiences');
      expect(recommendedDest.matchingFactors, ['high solo suitability', 'cultural activities']);
      expect(recommendedDest.isHiddenGemMatch, false);
    });

    test('should create with isHiddenGemMatch', () {
      final recommendedDest = RecommendedDestination(
        destination: testDestination,
        matchScore: 0.85,
        reason: 'Hidden gem match',
        matchingFactors: ['hidden gem'],
        isHiddenGemMatch: true,
      );

      expect(recommendedDest.isHiddenGemMatch, true);
    });

    test('should serialize to JSON correctly', () {
      final recommendedDest = RecommendedDestination(
        destination: testDestination,
        matchScore: 0.85,
        reason: 'Perfect for cultural experiences',
        matchingFactors: ['high solo suitability', 'cultural'],
      );

      final json = recommendedDest.toJson();

      // Note: The toJson() method returns a Map<String, dynamic> but nested
      // objects (like destination) are not automatically converted to Maps.
      // Use jsonEncode/jsonDecode for full JSON serialization.
      expect(json['destination'], isA<Destination>());
      expect(json['matchScore'], 0.85);
      expect(json['reason'], 'Perfect for cultural experiences');
      expect(json['matchingFactors'], ['high solo suitability', 'cultural']);
      expect(json['isHiddenGemMatch'], false);

      // Verify full JSON serialization works with jsonEncode
      final jsonString = jsonEncode(json);
      final decoded = jsonDecode(jsonString) as Map<String, dynamic>;
      expect(decoded['destination'], isA<Map<String, dynamic>>());
    });

    test('should deserialize from JSON correctly', () {
      final recommendedDest = RecommendedDestination(
        destination: testDestination,
        matchScore: 0.85,
        reason: 'Perfect for cultural experiences',
        matchingFactors: ['high solo suitability', 'cultural'],
      );

      // Serialize to JSON string and back to ensure proper JSON conversion
      final jsonString = jsonEncode(recommendedDest.toJson());
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      final deserialized = RecommendedDestination.fromJson(json);

      expect(deserialized.destination.id, testDestination.id);
      expect(deserialized.matchScore, recommendedDest.matchScore);
      expect(deserialized.reason, recommendedDest.reason);
      expect(deserialized.matchingFactors, recommendedDest.matchingFactors);
      expect(deserialized.isHiddenGemMatch, recommendedDest.isHiddenGemMatch);
    });

    test('should implement equality correctly', () {
      final dest1 = RecommendedDestination(
        destination: testDestination,
        matchScore: 0.85,
        reason: 'Perfect match',
        matchingFactors: ['cultural'],
      );

      final dest2 = RecommendedDestination(
        destination: testDestination,
        matchScore: 0.85,
        reason: 'Perfect match',
        matchingFactors: ['cultural'],
      );

      final dest3 = RecommendedDestination(
        destination: testDestination,
        matchScore: 0.75,
        reason: 'Good match',
        matchingFactors: ['cultural'],
      );

      expect(dest1, equals(dest2));
      expect(dest1, isNot(equals(dest3)));
    });

    test('should support copyWith', () {
      final recommendedDest = RecommendedDestination(
        destination: testDestination,
        matchScore: 0.85,
        reason: 'Perfect match',
        matchingFactors: ['cultural'],
      );

      final updated = recommendedDest.copyWith(matchScore: 0.90);

      expect(updated.matchScore, 0.90);
      expect(updated.reason, 'Perfect match');
      expect(updated.matchingFactors, ['cultural']);
    });
  });

  group('PersonalizedRecommendation', () {
    late DateTime now;
    late Destination testDestination;
    late List<RecommendedDestination> recommendations;

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
        images: ['https://example.com/tokyo1.jpg'],
        popularActivities: [],
        createdAt: now,
        updatedAt: now,
      );

      recommendations = [
        RecommendedDestination(
          destination: testDestination,
          matchScore: 0.85,
          reason: 'Perfect for cultural experiences',
          matchingFactors: ['high solo suitability', 'cultural'],
        ),
      ];
    });

    test('should create with all required fields', () {
      final generatedAt = now;
      final expiresAt = now.add(const Duration(days: 7));

      final recommendation = PersonalizedRecommendation(
        id: 'rec_1',
        userId: 'user_1',
        recommendations: recommendations,
        source: RecommendationSource.userPreferences,
        generatedAt: generatedAt,
        expiresAt: expiresAt,
      );

      expect(recommendation.id, 'rec_1');
      expect(recommendation.userId, 'user_1');
      expect(recommendation.recommendations, recommendations);
      expect(recommendation.source, RecommendationSource.userPreferences);
      expect(recommendation.generatedAt, generatedAt);
      expect(recommendation.expiresAt, expiresAt);
    });

    test('should create with optional fields', () {
      final generatedAt = now;
      final expiresAt = now.add(const Duration(days: 7));

      final recommendation = PersonalizedRecommendation(
        id: 'rec_1',
        userId: 'user_1',
        recommendations: recommendations,
        source: RecommendationSource.aiGenerated,
        summary: 'Based on your love for cultural immersion',
        totalCount: 10,
        generatedAt: generatedAt,
        expiresAt: expiresAt,
        preferenceSnapshot: {'budget': 'moderate', 'activity': 'cultural'},
      );

      expect(recommendation.summary, 'Based on your love for cultural immersion');
      expect(recommendation.totalCount, 10);
      expect(recommendation.preferenceSnapshot, isNotNull);
      expect(recommendation.preferenceSnapshot!['budget'], 'moderate');
    });

    test('should serialize to JSON correctly', () {
      final generatedAt = now;
      final expiresAt = now.add(const Duration(days: 7));

      final recommendation = PersonalizedRecommendation(
        id: 'rec_1',
        userId: 'user_1',
        recommendations: recommendations,
        source: RecommendationSource.userPreferences,
        summary: 'Cultural immersion recommendations',
        totalCount: 5,
        generatedAt: generatedAt,
        expiresAt: expiresAt,
        preferenceSnapshot: {'budget': 'moderate'},
      );

      final json = recommendation.toJson();

      expect(json['id'], 'rec_1');
      expect(json['userId'], 'user_1');
      expect(json['source'], 'user_preferences');
      expect(json['summary'], 'Cultural immersion recommendations');
      expect(json['totalCount'], 5);
      expect(json['generatedAt'], isA<String>());
      expect(json['expiresAt'], isA<String>());
      expect(json['preferenceSnapshot'], {'budget': 'moderate'});
      expect(json['recommendations'], isA<List>());
    });

    test('should deserialize from JSON correctly', () {
      final generatedAt = now;
      final expiresAt = now.add(const Duration(days: 7));

      final recommendation = PersonalizedRecommendation(
        id: 'rec_1',
        userId: 'user_1',
        recommendations: recommendations,
        source: RecommendationSource.userPreferences,
        generatedAt: generatedAt,
        expiresAt: expiresAt,
      );

      // Serialize to JSON string and back to ensure proper JSON conversion
      final jsonString = jsonEncode(recommendation.toJson());
      final json = jsonDecode(jsonString) as Map<String, dynamic>;

      final deserialized = PersonalizedRecommendation.fromJson(json);

      expect(deserialized.id, recommendation.id);
      expect(deserialized.userId, recommendation.userId);
      expect(deserialized.source, recommendation.source);
      expect(deserialized.recommendations.length, recommendation.recommendations.length);
      expect(deserialized.generatedAt, recommendation.generatedAt);
      expect(deserialized.expiresAt, recommendation.expiresAt);
    });

    test('should implement equality correctly', () {
      final generatedAt = now;
      final expiresAt = now.add(const Duration(days: 7));

      final rec1 = PersonalizedRecommendation(
        id: 'rec_1',
        userId: 'user_1',
        recommendations: recommendations,
        source: RecommendationSource.userPreferences,
        generatedAt: generatedAt,
        expiresAt: expiresAt,
      );

      final rec2 = PersonalizedRecommendation(
        id: 'rec_1',
        userId: 'user_1',
        recommendations: recommendations,
        source: RecommendationSource.userPreferences,
        generatedAt: generatedAt,
        expiresAt: expiresAt,
      );

      final rec3 = PersonalizedRecommendation(
        id: 'rec_2',
        userId: 'user_1',
        recommendations: recommendations,
        source: RecommendationSource.trending,
        generatedAt: generatedAt,
        expiresAt: expiresAt,
      );

      expect(rec1, equals(rec2));
      expect(rec1, isNot(equals(rec3)));
      expect(rec1.hashCode, equals(rec2.hashCode));
    });

    test('should support copyWith', () {
      final generatedAt = now;
      final expiresAt = now.add(const Duration(days: 7));

      final recommendation = PersonalizedRecommendation(
        id: 'rec_1',
        userId: 'user_1',
        recommendations: recommendations,
        source: RecommendationSource.userPreferences,
        generatedAt: generatedAt,
        expiresAt: expiresAt,
      );

      final updated = recommendation.copyWith(
        summary: 'Updated summary',
        totalCount: 10,
      );

      expect(updated.id, recommendation.id);
      expect(updated.summary, 'Updated summary');
      expect(updated.totalCount, 10);
      expect(updated.source, recommendation.source);
    });

    test('isExpired should return true when expired', () {
      final generatedAt = now;
      final expiresAt = now.subtract(const Duration(hours: 1));

      final recommendation = PersonalizedRecommendation(
        id: 'rec_1',
        userId: 'user_1',
        recommendations: recommendations,
        source: RecommendationSource.userPreferences,
        generatedAt: generatedAt,
        expiresAt: expiresAt,
      );

      expect(recommendation.isExpired, true);
    });

    test('isExpired should return false when not expired', () {
      final generatedAt = now;
      final expiresAt = now.add(const Duration(days: 7));

      final recommendation = PersonalizedRecommendation(
        id: 'rec_1',
        userId: 'user_1',
        recommendations: recommendations,
        source: RecommendationSource.userPreferences,
        generatedAt: generatedAt,
        expiresAt: expiresAt,
      );

      expect(recommendation.isExpired, false);
    });

    test('isValid should return true when not expired', () {
      final generatedAt = now;
      final expiresAt = now.add(const Duration(days: 7));

      final recommendation = PersonalizedRecommendation(
        id: 'rec_1',
        userId: 'user_1',
        recommendations: recommendations,
        source: RecommendationSource.userPreferences,
        generatedAt: generatedAt,
        expiresAt: expiresAt,
      );

      expect(recommendation.isValid, true);
    });

    test('isValid should return false when expired', () {
      final generatedAt = now;
      final expiresAt = now.subtract(const Duration(hours: 1));

      final recommendation = PersonalizedRecommendation(
        id: 'rec_1',
        userId: 'user_1',
        recommendations: recommendations,
        source: RecommendationSource.userPreferences,
        generatedAt: generatedAt,
        expiresAt: expiresAt,
      );

      expect(recommendation.isValid, false);
    });

    test('highMatchRecommendations should filter by match score', () {
      final now = DateTime.now();
      final highMatchRec = PersonalizedRecommendation(
        id: 'rec_1',
        userId: 'user_1',
        recommendations: [
          RecommendedDestination(
            destination: testDestination,
            matchScore: 0.85,
            reason: 'High match',
            matchingFactors: ['cultural'],
          ),
          RecommendedDestination(
            destination: testDestination,
            matchScore: 0.65,
            reason: 'Medium match',
            matchingFactors: ['urban'],
          ),
        ],
        source: RecommendationSource.aiGenerated,
        generatedAt: now,
        expiresAt: now.add(const Duration(days: 7)),
      );

      final highMatches = highMatchRec.highMatchRecommendations;

      expect(highMatches.length, 1);
      expect(highMatches.first.matchScore, 0.85);
    });

    test('hiddenGemRecommendations should filter hidden gems', () {
      final now = DateTime.now();
      final hiddenGemRec = PersonalizedRecommendation(
        id: 'rec_1',
        userId: 'user_1',
        recommendations: [
          RecommendedDestination(
            destination: testDestination,
            matchScore: 0.85,
            reason: 'Hidden gem',
            matchingFactors: ['hidden'],
            isHiddenGemMatch: true,
          ),
          RecommendedDestination(
            destination: testDestination,
            matchScore: 0.75,
            reason: 'Popular',
            matchingFactors: ['urban'],
            isHiddenGemMatch: false,
          ),
        ],
        source: RecommendationSource.curated,
        generatedAt: now,
        expiresAt: now.add(const Duration(days: 7)),
      );

      final hiddenGems = hiddenGemRec.hiddenGemRecommendations;

      expect(hiddenGems.length, 1);
      expect(hiddenGems.first.isHiddenGemMatch, true);
    });

    test('sortedByMatchScore should return recommendations sorted by match score', () {
      final now = DateTime.now();
      final unsortedRec = PersonalizedRecommendation(
        id: 'rec_1',
        userId: 'user_1',
        recommendations: [
          RecommendedDestination(
            destination: testDestination,
            matchScore: 0.65,
            reason: 'Medium match',
            matchingFactors: ['urban'],
          ),
          RecommendedDestination(
            destination: testDestination,
            matchScore: 0.90,
            reason: 'High match',
            matchingFactors: ['cultural'],
          ),
          RecommendedDestination(
            destination: testDestination,
            matchScore: 0.75,
            reason: 'Good match',
            matchingFactors: ['food'],
          ),
        ],
        source: RecommendationSource.aiGenerated,
        generatedAt: now,
        expiresAt: now.add(const Duration(days: 7)),
      );

      final sorted = unsortedRec.sortedByMatchScore;

      expect(sorted[0].matchScore, 0.90);
      expect(sorted[1].matchScore, 0.75);
      expect(sorted[2].matchScore, 0.65);
    });
  });
}
