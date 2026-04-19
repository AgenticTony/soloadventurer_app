import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/date_range.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/destination.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/travel_interest.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/place_activity.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation.dart';
import 'package:soloadventurer/features/recommendations/domain/entities/recommendation_request.dart';

void main() {
  group('RecommendationRequest', () {
    const destination = Destination(
      placeId: 'test-place-id',
      name: 'Paris',
      latitude: 48.8566,
      longitude: 2.3522,
    );

    final dateRange = DateRange(
      start: DateTime(2026, 6, 1),
      end: DateTime(2026, 6, 7),
    );

    final interests = {
      TravelInterest.food,
      TravelInterest.art,
      TravelInterest.adventure,
    };

    group('Factory Constructor', () {
      test('creates RecommendationRequest with required fields', () {
        final request = RecommendationRequest(
          itineraryId: 'itinerary-1',
          destination: destination,
          tripDates: dateRange,
          interests: interests,
        );

        expect(request.itineraryId, 'itinerary-1');
        expect(request.destination, destination);
        expect(request.tripDates, dateRange);
        expect(request.interests, interests);
      });

      test('uses default values for optional fields', () {
        final request = RecommendationRequest(
          itineraryId: 'itinerary-1',
          destination: destination,
          tripDates: dateRange,
          interests: interests,
        );

        expect(request.limit, 20);
        expect(request.excludeItineraryItems, true);
        expect(request.hotelLocation, isNull);
        expect(request.budget, isNull);
        expect(request.categories, isNull);
        expect(request.weatherPreference, isNull);
        expect(request.maxDistance, isNull);
      });

      test('creates with all optional fields', () {
        const hotelLocation = HotelLocation(
          name: 'Test Hotel',
          latitude: 48.8500,
          longitude: 2.3500,
        );

        const budget = BudgetRange(min: 50, max: 200);

        final categories = <RecommendationCategory>{
          RecommendationCategory.food,
          RecommendationCategory.attraction,
        };

        final weatherPreferences = <WeatherContext>{
          WeatherContext.anyWeather,
          WeatherContext.indoor,
        };

        final request = RecommendationRequest(
          itineraryId: 'itinerary-1',
          destination: destination,
          tripDates: dateRange,
          interests: interests,
          hotelLocation: hotelLocation,
          budget: budget,
          categories: categories,
          weatherPreference: weatherPreferences,
          maxDistance: DistanceFromHotel.shortTrip,
          limit: 15,
          excludeItineraryItems: false,
        );

        expect(request.hotelLocation, hotelLocation);
        expect(request.budget, budget);
        expect(request.categories, categories);
        expect(request.weatherPreference, weatherPreferences);
        expect(request.maxDistance, DistanceFromHotel.shortTrip);
        expect(request.limit, 15);
        expect(request.excludeItineraryItems, false);
      });
    });

    group('JSON Serialization', () {
      test('serializes to JSON correctly', () {
        final request = RecommendationRequest(
          itineraryId: 'itinerary-1',
          destination: destination,
          tripDates: dateRange,
          interests: interests,
        );

        final json = request.toJson();

        expect(json['itineraryId'], 'itinerary-1');
        expect(json['limit'], 20);
        expect(json['excludeItineraryItems'], true);
      });

      test('deserializes from JSON correctly', () {
        final json = {
          'itineraryId': 'itinerary-1',
          'destination': destination.toJson(),
          'tripDates': dateRange.toJson(),
          'interests': interests.map((i) => i.name).toList(),
          'limit': 20,
          'excludeItineraryItems': true,
        };

        final request = RecommendationRequest.fromJson(json);

        expect(request.itineraryId, 'itinerary-1');
        expect(request.limit, 20);
        expect(request.excludeItineraryItems, true);
      });
    });

    group('Validation', () {
      test('isValid returns true when all required fields are present', () {
        final request = RecommendationRequest(
          itineraryId: 'itinerary-1',
          destination: destination,
          tripDates: dateRange,
          interests: interests,
        );

        expect(request.isValid, true);
      });

      test('isValid returns false when itineraryId is empty', () {
        final request = RecommendationRequest(
          itineraryId: '',
          destination: destination,
          tripDates: dateRange,
          interests: interests,
        );

        expect(request.isValid, false);
      });

      test('isValid returns false when destination is invalid', () {
        const invalidDestination = Destination(
          placeId: '',
          name: '',
          latitude: 0,
          longitude: 0,
        );

        final request = RecommendationRequest(
          itineraryId: 'itinerary-1',
          destination: invalidDestination,
          tripDates: dateRange,
          interests: interests,
        );

        expect(request.isValid, false);
      });

      test('isValid returns false when tripDates is invalid', () {
        final invalidDateRange = DateRange(
          start: DateTime(2020, 6, 7),
          end: DateTime(2020, 6, 1), // End before start
        );

        final request = RecommendationRequest(
          itineraryId: 'itinerary-1',
          destination: destination,
          tripDates: invalidDateRange,
          interests: interests,
        );

        expect(request.isValid, false);
      });

      test('isValid returns false when interests is empty', () {
        final request = RecommendationRequest(
          itineraryId: 'itinerary-1',
          destination: destination,
          tripDates: dateRange,
          interests: {},
        );

        expect(request.isValid, false);
      });
    });

    group('Computed Properties', () {
      test('interestsDisplay returns "All interests" when empty', () {
        final request = RecommendationRequest(
          itineraryId: 'itinerary-1',
          destination: destination,
          tripDates: dateRange,
          interests: {},
        );

        expect(request.interestsDisplay, 'All interests');
      });

      test('interestsDisplay returns single interest', () {
        final request = RecommendationRequest(
          itineraryId: 'itinerary-1',
          destination: destination,
          tripDates: dateRange,
          interests: <TravelInterest>{TravelInterest.food},
        );

        expect(request.interestsDisplay, 'Food & Cuisine');
      });

      test('interestsDisplay joins two interests with &', () {
        final request = RecommendationRequest(
          itineraryId: 'itinerary-1',
          destination: destination,
          tripDates: dateRange,
          interests: <TravelInterest>{TravelInterest.food, TravelInterest.art},
        );

        expect(request.interestsDisplay, 'Food & Cuisine & Art & Museums');
      });

      test('interestsDisplay shows count for more than 2 interests', () {
        final request = RecommendationRequest(
          itineraryId: 'itinerary-1',
          destination: destination,
          tripDates: dateRange,
          interests: interests,
        );

        expect(request.interestsDisplay, 'Food & Cuisine +2 more');
      });
    });
  });

  group('HotelLocation', () {
    group('Factory Constructor', () {
      test('creates HotelLocation with required fields', () {
        const hotelLocation = HotelLocation(
          name: 'Test Hotel',
          latitude: 48.8500,
          longitude: 2.3500,
        );

        expect(hotelLocation.name, 'Test Hotel');
        expect(hotelLocation.latitude, 48.8500);
        expect(hotelLocation.longitude, 2.3500);
      });

      test('creates HotelLocation with optional address', () {
        const hotelLocation = HotelLocation(
          name: 'Test Hotel',
          address: '123 Main St',
          latitude: 48.8500,
          longitude: 2.3500,
        );

        expect(hotelLocation.address, '123 Main St');
      });
    });

    group('JSON Serialization', () {
      test('serializes to JSON correctly', () {
        const hotelLocation = HotelLocation(
          name: 'Test Hotel',
          address: '123 Main St',
          latitude: 48.8500,
          longitude: 2.3500,
        );

        final json = hotelLocation.toJson();

        expect(json['name'], 'Test Hotel');
        expect(json['address'], '123 Main St');
        expect(json['latitude'], 48.8500);
        expect(json['longitude'], 2.3500);
      });

      test('deserializes from JSON correctly', () {
        final json = {
          'name': 'Test Hotel',
          'address': '123 Main St',
          'latitude': 48.8500,
          'longitude': 2.3500,
        };

        final hotelLocation = HotelLocation.fromJson(json);

        expect(hotelLocation.name, 'Test Hotel');
        expect(hotelLocation.address, '123 Main St');
        expect(hotelLocation.latitude, 48.8500);
        expect(hotelLocation.longitude, 2.3500);
      });

      test('round-trips through JSON serialization', () {
        const original = HotelLocation(
          name: 'Grand Hotel',
          address: '1 Avenue des Champs-Élysées',
          latitude: 48.8698,
          longitude: 2.3075,
        );

        final json = original.toJson();
        final deserialized = HotelLocation.fromJson(json);

        expect(deserialized.name, original.name);
        expect(deserialized.address, original.address);
        expect(deserialized.latitude, original.latitude);
        expect(deserialized.longitude, original.longitude);
      });
    });
  });

  group('BudgetRange', () {
    group('Factory Constructor', () {
      test('creates BudgetRange with min only', () {
        const budget = BudgetRange(min: 50);

        expect(budget.min, 50);
        expect(budget.max, isNull);
        expect(budget.currency, 'USD');
      });

      test('creates BudgetRange with max only', () {
        const budget = BudgetRange(max: 200);

        expect(budget.min, isNull);
        expect(budget.max, 200);
        expect(budget.currency, 'USD');
      });

      test('creates BudgetRange with min and max', () {
        const budget = BudgetRange(min: 50, max: 200);

        expect(budget.min, 50);
        expect(budget.max, 200);
        expect(budget.currency, 'USD');
      });

      test('creates BudgetRange with custom currency', () {
        const budget = BudgetRange(
          min: 40,
          max: 150,
          currency: 'EUR',
        );

        expect(budget.currency, 'EUR');
      });
    });

    group('JSON Serialization', () {
      test('serializes to JSON correctly', () {
        const budget = BudgetRange(min: 50, max: 200, currency: 'USD');

        final json = budget.toJson();

        expect(json['min'], 50);
        expect(json['max'], 200);
        expect(json['currency'], 'USD');
      });

      test('deserializes from JSON correctly', () {
        final json = {'min': 50, 'max': 200, 'currency': 'USD'};

        final budget = BudgetRange.fromJson(json);

        expect(budget.min, 50);
        expect(budget.max, 200);
        expect(budget.currency, 'USD');
      });

      test('round-trips through JSON serialization', () {
        const original = BudgetRange(min: 40, max: 180, currency: 'GBP');

        final json = original.toJson();
        final deserialized = BudgetRange.fromJson(json);

        expect(deserialized.min, original.min);
        expect(deserialized.max, original.max);
        expect(deserialized.currency, original.currency);
      });
    });

    group('Methods', () {
      test('contains returns true when amount is within range', () {
        const budget = BudgetRange(min: 50, max: 200);

        expect(budget.contains(100), true);
        expect(budget.contains(50), true);
        expect(budget.contains(200), true);
      });

      test('contains returns false when amount is below min', () {
        const budget = BudgetRange(min: 50, max: 200);

        expect(budget.contains(40), false);
        expect(budget.contains(49), false);
      });

      test('contains returns false when amount is above max', () {
        const budget = BudgetRange(min: 50, max: 200);

        expect(budget.contains(201), false);
        expect(budget.contains(300), false);
      });

      test('contains returns true when only min is set and amount >= min', () {
        const budget = BudgetRange(min: 50);

        expect(budget.contains(50), true);
        expect(budget.contains(100), true);
        expect(budget.contains(1000), true);
      });

      test('contains returns true when only max is set and amount <= max', () {
        const budget = BudgetRange(max: 200);

        expect(budget.contains(0), true);
        expect(budget.contains(100), true);
        expect(budget.contains(200), true);
      });

      test('contains returns true when no limits are set', () {
        const budget = BudgetRange();

        expect(budget.contains(0), true);
        expect(budget.contains(100), true);
        expect(budget.contains(10000), true);
      });
    });

    group('Computed Properties', () {
      test('display returns range with currency symbol', () {
        const budget = BudgetRange(min: 50, max: 200, currency: 'USD');

        expect(budget.display, '\$50 - \$200');
      });

      test('display returns "From min" when only min is set', () {
        const budget = BudgetRange(min: 50, currency: 'USD');

        expect(budget.display, 'From \$50');
      });

      test('display returns "Up to max" when only max is set', () {
        const budget = BudgetRange(max: 200, currency: 'USD');

        expect(budget.display, 'Up to \$200');
      });

      test('display returns "Any budget" when no limits', () {
        const budget = BudgetRange();

        expect(budget.display, 'Any budget');
      });

      test('display uses EUR currency symbol', () {
        const budget = BudgetRange(min: 40, max: 150, currency: 'EUR');

        expect(budget.display, '€40 - €150');
      });

      test('display uses GBP currency symbol', () {
        const budget = BudgetRange(min: 30, max: 120, currency: 'GBP');

        expect(budget.display, '£30 - £120');
      });

      test('display uses JPY currency symbol', () {
        const budget = BudgetRange(min: 5000, max: 15000, currency: 'JPY');

        expect(budget.display, '¥5000 - ¥15000');
      });

      test('display formats to zero decimal places', () {
        const budget = BudgetRange(min: 50, max: 200, currency: 'USD');

        expect(budget.display, '\$50 - \$200');
      });
    });
  });

  group('RecommendationFeedback enum', () {
    test('has all expected values', () {
      expect(RecommendationFeedback.values.length, 5);

      expect(RecommendationFeedback.values,
          contains(RecommendationFeedback.helpful));
      expect(RecommendationFeedback.values,
          contains(RecommendationFeedback.notHelpful));
      expect(RecommendationFeedback.values,
          contains(RecommendationFeedback.notInterested));
      expect(RecommendationFeedback.values,
          contains(RecommendationFeedback.alreadyDone));
      expect(RecommendationFeedback.values,
          contains(RecommendationFeedback.inaccurate));
    });
  });
}
