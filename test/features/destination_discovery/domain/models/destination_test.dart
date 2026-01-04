import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:solo_adventurer/features/destination_discovery/domain/models/destination.dart';

void main() {
  group('SoloSuitabilityFactors', () {
    test('should create with all required fields', () {
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

    test('should serialize to JSON correctly', () {
      final factors = SoloSuitabilityFactors(
        safety: 8.5,
        nightlife: 7.0,
        walkability: 9.0,
        accommodation: 8.0,
        soloDining: 7.5,
        communication: 6.5,
        overall: 7.8,
      );

      final json = factors.toJson();

      expect(json['safety'], 8.5);
      expect(json['nightlife'], 7.0);
      expect(json['walkability'], 9.0);
      expect(json['accommodation'], 8.0);
      expect(json['soloDining'], 7.5);
      expect(json['communication'], 6.5);
      expect(json['overall'], 7.8);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'safety': 8.5,
        'nightlife': 7.0,
        'walkability': 9.0,
        'accommodation': 8.0,
        'soloDining': 7.5,
        'communication': 6.5,
        'overall': 7.8,
      };

      final factors = SoloSuitabilityFactors.fromJson(json);

      expect(factors.safety, 8.5);
      expect(factors.nightlife, 7.0);
      expect(factors.walkability, 9.0);
      expect(factors.accommodation, 8.0);
      expect(factors.soloDining, 7.5);
      expect(factors.communication, 6.5);
      expect(factors.overall, 7.8);
    });

    test('should implement equality correctly', () {
      final factors1 = SoloSuitabilityFactors(
        safety: 8.5,
        nightlife: 7.0,
        walkability: 9.0,
        accommodation: 8.0,
        soloDining: 7.5,
        communication: 6.5,
        overall: 7.8,
      );

      final factors2 = SoloSuitabilityFactors(
        safety: 8.5,
        nightlife: 7.0,
        walkability: 9.0,
        accommodation: 8.0,
        soloDining: 7.5,
        communication: 6.5,
        overall: 7.8,
      );

      final factors3 = SoloSuitabilityFactors(
        safety: 7.5,
        nightlife: 7.0,
        walkability: 9.0,
        accommodation: 8.0,
        soloDining: 7.5,
        communication: 6.5,
        overall: 7.8,
      );

      expect(factors1, equals(factors2));
      expect(factors1, isNot(equals(factors3)));
      expect(factors1.hashCode, equals(factors2.hashCode));
    });

    test('should support copyWith', () {
      final factors = SoloSuitabilityFactors(
        safety: 8.5,
        nightlife: 7.0,
        walkability: 9.0,
        accommodation: 8.0,
        soloDining: 7.5,
        communication: 6.5,
        overall: 7.8,
      );

      final updated = factors.copyWith(safety: 9.0);

      expect(updated.safety, 9.0);
      expect(updated.nightlife, 7.0);
      expect(updated.walkability, 9.0);
    });
  });

  group('SafetyInsight', () {
    test('should create with all required fields', () {
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

    test('should serialize to JSON correctly', () {
      final insight = SafetyInsight(
        category: 'theft',
        description: 'Pickpocketing is common',
        severity: 'medium',
        tips: ['Tip 1', 'Tip 2'],
      );

      final json = insight.toJson();

      expect(json['category'], 'theft');
      expect(json['description'], 'Pickpocketing is common');
      expect(json['severity'], 'medium');
      expect(json['tips'], ['Tip 1', 'Tip 2']);
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'category': 'theft',
        'description': 'Pickpocketing is common',
        'severity': 'medium',
        'tips': ['Tip 1', 'Tip 2'],
      };

      final insight = SafetyInsight.fromJson(json);

      expect(insight.category, 'theft');
      expect(insight.description, 'Pickpocketing is common');
      expect(insight.severity, 'medium');
      expect(insight.tips, ['Tip 1', 'Tip 2']);
    });

    test('should implement equality correctly', () {
      final insight1 = SafetyInsight(
        category: 'theft',
        description: 'Pickpocketing is common',
        severity: 'medium',
        tips: ['Tip 1'],
      );

      final insight2 = SafetyInsight(
        category: 'theft',
        description: 'Pickpocketing is common',
        severity: 'medium',
        tips: ['Tip 1'],
      );

      final insight3 = SafetyInsight(
        category: 'theft',
        description: 'Different description',
        severity: 'medium',
        tips: ['Tip 1'],
      );

      expect(insight1, equals(insight2));
      expect(insight1, isNot(equals(insight3)));
    });
  });

  group('Activity', () {
    test('should create with all required fields', () {
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
      expect(activity.imageUrl, 'https://example.com/temple.jpg');
    });

    test('should create with only required fields', () {
      final activity = Activity(
        id: 'act_1',
        name: 'Temple Visit',
        category: 'cultural',
        soloFriendly: true,
      );

      expect(activity.id, 'act_1');
      expect(activity.name, 'Temple Visit');
      expect(activity.description, isNull);
      expect(activity.costLevel, isNull);
      expect(activity.imageUrl, isNull);
    });

    test('should serialize to JSON correctly', () {
      final activity = Activity(
        id: 'act_1',
        name: 'Temple Visit',
        description: 'Visit ancient temples',
        category: 'cultural',
        soloFriendly: true,
        costLevel: 'low',
      );

      final json = activity.toJson();

      expect(json['id'], 'act_1');
      expect(json['name'], 'Temple Visit');
      expect(json['description'], 'Visit ancient temples');
      expect(json['category'], 'cultural');
      expect(json['soloFriendly'], true);
      expect(json['costLevel'], 'low');
    });

    test('should deserialize from JSON correctly', () {
      final json = {
        'id': 'act_1',
        'name': 'Temple Visit',
        'description': 'Visit ancient temples',
        'category': 'cultural',
        'soloFriendly': true,
        'costLevel': 'low',
      };

      final activity = Activity.fromJson(json);

      expect(activity.id, 'act_1');
      expect(activity.name, 'Temple Visit');
      expect(activity.description, 'Visit ancient temples');
      expect(activity.category, 'cultural');
      expect(activity.soloFriendly, true);
      expect(activity.costLevel, 'low');
    });

    test('should implement equality correctly', () {
      final activity1 = Activity(
        id: 'act_1',
        name: 'Temple Visit',
        category: 'cultural',
        soloFriendly: true,
      );

      final activity2 = Activity(
        id: 'act_1',
        name: 'Temple Visit',
        category: 'cultural',
        soloFriendly: true,
      );

      final activity3 = Activity(
        id: 'act_2',
        name: 'Different Activity',
        category: 'cultural',
        soloFriendly: true,
      );

      expect(activity1, equals(activity2));
      expect(activity1, isNot(equals(activity3)));
    });
  });

  group('Destination', () {
    late DateTime now;
    late Destination destination;

    setUp(() {
      now = DateTime.now();
      destination = Destination(
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
    });

    test('should create with all required fields', () {
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

    test('should serialize to JSON correctly', () {
      final json = destination.toJson();

      expect(json['id'], 'dest_1');
      expect(json['name'], 'Tokyo');
      expect(json['safetyScore'], 9.2);
      expect(json['soloSuitabilityScore'], 8.8);
      expect(json['budgetLevel'], 'expensive');
      expect(json['activityLevels'], ['relaxed', 'moderate', 'adventurous']);
      expect(json['tags'], ['urban', 'cultural', 'food']);
      expect(json['images'].length, 2);
      expect(json['safetyInsights'].length, 1);
      expect(json['popularActivities'].length, 1);
    });

    test('should deserialize from JSON correctly', () {
      final json = destination.toJson();
      final deserialized = Destination.fromJson(json);

      expect(deserialized.id, destination.id);
      expect(deserialized.name, destination.name);
      expect(deserialized.safetyScore, destination.safetyScore);
      expect(deserialized.soloSuitabilityScore, destination.soloSuitabilityScore);
      expect(deserialized.budgetLevel, destination.budgetLevel);
      expect(deserialized.tags, destination.tags);
      expect(deserialized.images.length, destination.images.length);
      expect(deserialized.safetyInsights.length, destination.safetyInsights.length);
      expect(deserialized.popularActivities.length, destination.popularActivities.length);
    });

    test('should implement equality correctly', () {
      final destination1 = destination;
      final destination2 = Destination.fromJson(destination.toJson());

      expect(destination1, equals(destination2));
      expect(destination1.hashCode, equals(destination2.hashCode));
    });

    test('should support copyWith', () {
      final updated = destination.copyWith(
        name: 'Updated Tokyo',
        safetyScore: 9.5,
      );

      expect(updated.id, destination.id);
      expect(updated.name, 'Updated Tokyo');
      expect(updated.safetyScore, 9.5);
      expect(updated.latitude, destination.latitude);
    });
  });

  group('BudgetLevel enum', () {
    test('should have correct values', () {
      expect(BudgetLevel.values.length, 3);
      expect(BudgetLevel.budget, isA<BudgetLevel>());
      expect(BudgetLevel.moderate, isA<BudgetLevel>());
      expect(BudgetLevel.expensive, isA<BudgetLevel>());
    });

    test('should serialize correctly', () {
      expect(BudgetLevel.budget.toJson(), 'budget');
      expect(BudgetLevel.moderate.toJson(), 'moderate');
      expect(BudgetLevel.expensive.toJson(), 'expensive');
    });

    test('should deserialize correctly', () {
      expect(BudgetLevel.fromJson('budget'), BudgetLevel.budget);
      expect(BudgetLevel.fromJson('moderate'), BudgetLevel.moderate);
      expect(BudgetLevel.fromJson('expensive'), BudgetLevel.expensive);
    });
  });

  group('ActivityLevel enum', () {
    test('should have correct values', () {
      expect(ActivityLevel.values.length, 3);
      expect(ActivityLevel.relaxed, isA<ActivityLevel>());
      expect(ActivityLevel.moderate, isA<ActivityLevel>());
      expect(ActivityLevel.adventurous, isA<ActivityLevel>());
    });

    test('should serialize correctly', () {
      expect(ActivityLevel.relaxed.toJson(), 'relaxed');
      expect(ActivityLevel.moderate.toJson(), 'moderate');
      expect(ActivityLevel.adventurous.toJson(), 'adventurous');
    });

    test('should deserialize correctly', () {
      expect(ActivityLevel.fromJson('relaxed'), ActivityLevel.relaxed);
      expect(ActivityLevel.fromJson('moderate'), ActivityLevel.moderate);
      expect(ActivityLevel.fromJson('adventurous'), ActivityLevel.adventurous);
    });
  });
}
