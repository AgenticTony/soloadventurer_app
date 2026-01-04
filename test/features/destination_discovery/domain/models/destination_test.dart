import 'package:flutter_test/flutter_test.dart';
import 'package:solo_adventurer/features/destination_discovery/domain/models/destination.dart';

void main() {
  group('Destination Models', () {
    test('SoloSuitabilityFactors should have all required fields', () {
      final factors = SoloSuitabilityFactors(
        safety: 8.5,
        nightlife: 7.0,
        walkability: 9.0,
        accommodation: 8.0,
        soloDining: 7.5,
        communication: 6.5,
        overall: 7.8,
      );

      expect(factors.safety, 8.5);
      expect(factors.nightlife, 7.0);
      expect(factors.walkability, 9.0);
      expect(factors.accommodation, 8.0);
      expect(factors.soloDining, 7.5);
      expect(factors.communication, 6.5);
      expect(factors.overall, 7.8);
    });

    test('SafetyInsight should have all required fields', () {
      final insight = SafetyInsight(
        category: 'theft',
        description: 'Pickpocketing is common in tourist areas',
        severity: 'medium',
        tips: [
          'Keep valuables secure',
          'Use anti-theft bags',
          'Avoid displaying expensive items'
        ],
      );

      expect(insight.category, 'theft');
      expect(insight.description, contains('Pickpocketing'));
      expect(insight.severity, 'medium');
      expect(insight.tips.length, 3);
    });

    test('Activity should have all required fields', () {
      final activity = Activity(
        id: 'act_1',
        name: 'Temple Visit',
        description: 'Visit ancient temples',
        category: 'cultural',
        soloFriendly: true,
        costLevel: 'low',
        imageUrl: 'https://example.com/temple.jpg',
      );

      expect(activity.id, 'act_1');
      expect(activity.name, 'Temple Visit');
      expect(activity.category, 'cultural');
      expect(activity.soloFriendly, true);
      expect(activity.costLevel, 'low');
    });

    test('Destination should have all required fields', () {
      final now = DateTime.now();
      final destination = Destination(
        id: 'dest_1',
        name: 'Tokyo',
        description: 'A vibrant metropolis',
        latitude: 35.6762,
        longitude: 139.6503,
        countryCode: 'JP',
        region: 'Kanto',
        safetyScore: 9.2,
        safetyInsights: [
          SafetyInsight(
            category: 'general',
            description: 'Very safe city',
            severity: 'low',
            tips: ['Normal precautions apply'],
          ),
        ],
        soloSuitabilityScore: 8.8,
        soloSuitabilityFactors: SoloSuitabilityFactors(
          safety: 9.5,
          nightlife: 8.0,
          walkability: 9.0,
          accommodation: 9.0,
          soloDining: 9.5,
          communication: 7.0,
          overall: 8.8,
        ),
        budgetLevel: BudgetLevel.expensive,
        activityLevels: [
          ActivityLevel.relaxed,
          ActivityLevel.moderate,
          ActivityLevel.adventurous,
        ],
        tags: ['urban', 'cultural', 'food'],
        images: [
          'https://example.com/tokyo1.jpg',
          'https://example.com/tokyo2.jpg',
        ],
        coverImageUrl: 'https://example.com/tokyo_cover.jpg',
        popularActivities: [
          Activity(
            id: 'act_1',
            name: 'Visit temples',
            category: 'cultural',
            soloFriendly: true,
          ),
        ],
        bestTimeToVisit: 'March to May, October to November',
        averageDailyCost: 150,
        currencyCode: 'JPY',
        language: 'Japanese',
        timezone: 'Asia/Tokyo',
        createdAt: now,
        updatedAt: now,
      );

      expect(destination.id, 'dest_1');
      expect(destination.name, 'Tokyo');
      expect(destination.safetyScore, 9.2);
      expect(destination.soloSuitabilityScore, 8.8);
      expect(destination.budgetLevel, BudgetLevel.expensive);
      expect(destination.activityLevels.length, 3);
      expect(destination.tags, contains('urban'));
      expect(destination.images.length, 2);
      expect(destination.popularActivities.length, 1);
    });

    test('BudgetLevel enum should have correct values', () {
      expect(BudgetLevel.values.length, 3);
      expect(BudgetLevel.budget, isA<BudgetLevel>());
      expect(BudgetLevel.moderate, isA<BudgetLevel>());
      expect(BudgetLevel.expensive, isA<BudgetLevel>());
    });

    test('ActivityLevel enum should have correct values', () {
      expect(ActivityLevel.values.length, 3);
      expect(ActivityLevel.relaxed, isA<ActivityLevel>());
      expect(ActivityLevel.moderate, isA<ActivityLevel>());
      expect(ActivityLevel.adventurous, isA<ActivityLevel>());
    });
  });
}
