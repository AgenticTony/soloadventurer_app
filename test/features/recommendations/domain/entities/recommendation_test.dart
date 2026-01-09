import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/travel_interest.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/place_activity.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation.dart';

void main() {
  group('PersonalizedRecommendation', () {
    const placeActivity = PlaceActivity(
      id: 'place-1',
      name: 'Test Restaurant',
      category: RecommendationCategory.food,
      rating: 4.5,
    );

    final metadata = RecommendationMetadata(
      matchedInterests: {TravelInterest.foodTours},
      suggestedDate: DateTime(2026, 1, 15),
      suggestedTime: const TimeOfDay(hour: 12),
      distance: DistanceFromHotel.walking,
      weather: WeatherContext.anyWeather,
      crowdLevel: CrowdLevel.medium,
    );

    group('Factory Constructor', () {
      test('creates PersonalizedRecommendation with required fields', () {
        final recommendation = PersonalizedRecommendation(
          id: 'rec-1',
          activity: placeActivity,
          metadata: metadata,
          reasoning: 'Great match for your food interests',
        );

        expect(recommendation.id, 'rec-1');
        expect(recommendation.activity, placeActivity);
        expect(recommendation.metadata, metadata);
        expect(recommendation.reasoning, 'Great match for your food interests');
      });

      test('uses default values for optional fields', () {
        final recommendation = PersonalizedRecommendation(
          id: 'rec-1',
          activity: placeActivity,
          metadata: metadata,
          reasoning: 'Test reasoning',
        );

        expect(recommendation.relevanceScore, 0.0);
        expect(recommendation.source, RecommendationSource.personalized);
        expect(recommendation.isSaved, false);
        expect(recommendation.isAddedToItinerary, false);
      });

      test('creates with all optional fields', () {
        final recommendation = PersonalizedRecommendation(
          id: 'rec-1',
          activity: placeActivity,
          metadata: metadata,
          reasoning: 'Test reasoning',
          relevanceScore: 85.5,
          source: RecommendationSource.collaborative,
          isSaved: true,
          isAddedToItinerary: true,
        );

        expect(recommendation.relevanceScore, 85.5);
        expect(recommendation.source, RecommendationSource.collaborative);
        expect(recommendation.isSaved, true);
        expect(recommendation.isAddedToItinerary, true);
      });
    });

    group('JSON Serialization', () {
      test('serializes metadata to JSON correctly', () {
        final json = metadata.toJson();

        expect(json['matchedInterests'], isA<List>());
        expect(json['suggestedDate'], isA<String>());
        expect(json['suggestedTime'], isA<Map>());
      });

      test('deserializes metadata from JSON correctly', () {
        final json = {
          'matchedInterests': [TravelInterest.foodTours.index],
          'suggestedDate': '2026-01-15T00:00:00.000',
          'suggestedTime': {'hour': 12, 'minute': 0},
          'distance': DistanceFromHotel.walking.index,
          'weather': WeatherContext.anyWeather.index,
          'crowdLevel': CrowdLevel.medium.index,
          'estimatedDuration': 0,
          'requiresAdvanceBooking': false,
          'isIndoor': false,
        };

        final deserialized = RecommendationMetadata.fromJson(json);

        expect(
            deserialized.matchedInterests, contains(TravelInterest.foodTours));
        expect(deserialized.suggestedDate, DateTime(2026, 1, 15));
      });

      test('serializes TimeOfDay to JSON correctly', () {
        const timeOfDay = TimeOfDay(hour: 14, minute: 30);

        final json = timeOfDay.toJson();

        expect(json['hour'], 14);
        expect(json['minute'], 30);
      });

      test('deserializes TimeOfDay from JSON correctly', () {
        final json = {'hour': 9, 'minute': 15};

        final timeOfDay = TimeOfDay.fromJson(json);

        expect(timeOfDay.hour, 9);
        expect(timeOfDay.minute, 15);
      });

      test('serializes Money to JSON correctly', () {
        const money = Money(amount: 50.0, currency: 'USD');

        final json = money.toJson();

        expect(json['amount'], 50.0);
        expect(json['currency'], 'USD');
      });

      test('deserializes Money from JSON correctly', () {
        final json = {'amount': 100.0, 'currency': 'EUR'};

        final money = Money.fromJson(json);

        expect(money.amount, 100.0);
        expect(money.currency, 'EUR');
      });
    });

    group('Computed Properties', () {
      test('scoreColor returns excellent for score >= 80', () {
        final highScore = PersonalizedRecommendation(
          id: 'rec-1',
          activity: placeActivity,
          metadata: metadata,
          reasoning: 'Test',
          relevanceScore: 85.0,
        );

        expect(highScore.scoreColor, ScoreColor.excellent);
      });

      test('scoreColor returns excellent for score exactly 80', () {
        final recommendation = PersonalizedRecommendation(
          id: 'rec-1',
          activity: placeActivity,
          metadata: metadata,
          reasoning: 'Test',
          relevanceScore: 80.0,
        );

        expect(recommendation.scoreColor, ScoreColor.excellent);
      });

      test('scoreColor returns good for score 60-79', () {
        final recommendation = PersonalizedRecommendation(
          id: 'rec-1',
          activity: placeActivity,
          metadata: metadata,
          reasoning: 'Test',
          relevanceScore: 70.0,
        );

        expect(recommendation.scoreColor, ScoreColor.good);
      });

      test('scoreColor returns good for score exactly 60', () {
        final recommendation = PersonalizedRecommendation(
          id: 'rec-1',
          activity: placeActivity,
          metadata: metadata,
          reasoning: 'Test',
          relevanceScore: 60.0,
        );

        expect(recommendation.scoreColor, ScoreColor.good);
      });

      test('scoreColor returns fair for score 40-59', () {
        final recommendation = PersonalizedRecommendation(
          id: 'rec-1',
          activity: placeActivity,
          metadata: metadata,
          reasoning: 'Test',
          relevanceScore: 50.0,
        );

        expect(recommendation.scoreColor, ScoreColor.fair);
      });

      test('scoreColor returns fair for score exactly 40', () {
        final recommendation = PersonalizedRecommendation(
          id: 'rec-1',
          activity: placeActivity,
          metadata: metadata,
          reasoning: 'Test',
          relevanceScore: 40.0,
        );

        expect(recommendation.scoreColor, ScoreColor.fair);
      });

      test('scoreColor returns poor for score < 40', () {
        final recommendation = PersonalizedRecommendation(
          id: 'rec-1',
          activity: placeActivity,
          metadata: metadata,
          reasoning: 'Test',
          relevanceScore: 30.0,
        );

        expect(recommendation.scoreColor, ScoreColor.poor);
      });
    });
  });

  group('TimeOfDay', () {
    group('Factory Constructor', () {
      test('creates TimeOfDay with hour only', () {
        const timeOfDay = TimeOfDay(hour: 14);

        expect(timeOfDay.hour, 14);
        expect(timeOfDay.minute, 0);
      });

      test('creates TimeOfDay with hour and minute', () {
        const timeOfDay = TimeOfDay(hour: 9, minute: 30);

        expect(timeOfDay.hour, 9);
        expect(timeOfDay.minute, 30);
      });
    });

    group('Computed Properties', () {
      test('formatted returns AM time correctly', () {
        expect(
          const TimeOfDay(hour: 9, minute: 0).formatted,
          '9:00 AM',
        );

        expect(
          const TimeOfDay(hour: 9, minute: 5).formatted,
          '9:05 AM',
        );

        expect(
          const TimeOfDay(hour: 11, minute: 30).formatted,
          '11:30 AM',
        );
      });

      test('formatted returns PM time correctly', () {
        expect(
          const TimeOfDay(hour: 12, minute: 0).formatted,
          '12:00 PM',
        );

        expect(
          const TimeOfDay(hour: 14, minute: 0).formatted,
          '2:00 PM',
        );

        expect(
          const TimeOfDay(hour: 23, minute: 59).formatted,
          '11:59 PM',
        );
      });

      test('formatted handles midnight', () {
        expect(
          const TimeOfDay(hour: 0, minute: 0).formatted,
          '12:00 AM',
        );
      });
    });

    group('Methods', () {
      test('toDateTime creates correct DateTime', () {
        const timeOfDay = TimeOfDay(hour: 14, minute: 30);
        final date = DateTime(2026, 1, 15);

        final result = timeOfDay.toDateTime(date);

        expect(result, DateTime(2026, 1, 15, 14, 30));
      });
    });
  });

  group('Money', () {
    group('Factory Constructor', () {
      test('creates Money with amount and default currency', () {
        const money = Money(amount: 100.0);

        expect(money.amount, 100.0);
        expect(money.currency, 'USD');
      });

      test('creates Money with amount and custom currency', () {
        const money = Money(amount: 50.0, currency: 'EUR');

        expect(money.amount, 50.0);
        expect(money.currency, 'EUR');
      });
    });

    group('Computed Properties', () {
      test('formatted returns USD symbol', () {
        const money = Money(amount: 50.0, currency: 'USD');

        expect(money.formatted, '\$50.00');
      });

      test('formatted returns EUR symbol', () {
        const money = Money(amount: 30.0, currency: 'EUR');

        expect(money.formatted, '€30.00');
      });

      test('formatted returns GBP symbol', () {
        const money = Money(amount: 25.0, currency: 'GBP');

        expect(money.formatted, '£25.00');
      });

      test('formatted returns JPY symbol', () {
        const money = Money(amount: 1000.0, currency: 'JPY');

        expect(money.formatted, '¥1000.00');
      });

      test('formatted returns USD for unknown currency', () {
        const money = Money(amount: 100.0, currency: 'CAD');

        expect(money.formatted, '\$100.00');
      });

      test('formatted formats to two decimal places', () {
        const money = Money(amount: 123.456, currency: 'USD');

        expect(money.formatted, '\$123.46');
      });
    });
  });

  group('Enums', () {
    group('RecommendationSource', () {
      test('has all expected values', () {
        expect(RecommendationSource.values.length, 5);

        expect(RecommendationSource.values,
            contains(RecommendationSource.personalized));
        expect(RecommendationSource.values,
            contains(RecommendationSource.collaborative));
        expect(RecommendationSource.values,
            contains(RecommendationSource.trending));
        expect(
            RecommendationSource.values, contains(RecommendationSource.local));
        expect(RecommendationSource.values,
            contains(RecommendationSource.contextual));
      });
    });

    group('DistanceFromHotel', () {
      test('has all expected values', () {
        expect(DistanceFromHotel.values.length, 4);

        expect(DistanceFromHotel.values, contains(DistanceFromHotel.walking));
        expect(DistanceFromHotel.values, contains(DistanceFromHotel.shortTrip));
        expect(
            DistanceFromHotel.values, contains(DistanceFromHotel.mediumTrip));
        expect(DistanceFromHotel.values, contains(DistanceFromHotel.far));
      });
    });

    group('WeatherContext', () {
      test('has all expected values', () {
        expect(WeatherContext.values.length, 4);

        expect(WeatherContext.values, contains(WeatherContext.anyWeather));
        expect(WeatherContext.values, contains(WeatherContext.indoor));
        expect(WeatherContext.values, contains(WeatherContext.outdoor));
        expect(
            WeatherContext.values, contains(WeatherContext.weatherDependent));
      });
    });

    group('CrowdLevel', () {
      test('has all expected values', () {
        expect(CrowdLevel.values.length, 4);

        expect(CrowdLevel.values, contains(CrowdLevel.low));
        expect(CrowdLevel.values, contains(CrowdLevel.medium));
        expect(CrowdLevel.values, contains(CrowdLevel.high));
        expect(CrowdLevel.values, contains(CrowdLevel.peak));
      });
    });

    group('ScoreColor', () {
      test('has all expected values', () {
        expect(ScoreColor.values.length, 4);

        expect(ScoreColor.values, contains(ScoreColor.excellent));
        expect(ScoreColor.values, contains(ScoreColor.good));
        expect(ScoreColor.values, contains(ScoreColor.fair));
        expect(ScoreColor.values, contains(ScoreColor.poor));
      });
    });
  });
}
