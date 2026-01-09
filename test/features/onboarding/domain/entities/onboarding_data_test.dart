import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/budget_range.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/date_range.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/destination.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/onboarding_data.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/travel_interest.dart';

void main() {
  group('OnboardingData', () {
    // Test data factory
    OnboardingData createValidOnboardingData({
      String name = 'John Doe',
      Destination? destination,
      DateRange? dateRange,
      Set<TravelInterest>? interests,
      BudgetRange? budget,
    }) {
      return OnboardingData(
        name: name,
        destination: destination ??
            const Destination(
              placeId: 'ChIJDS8jQWWW6hkVRdVaUE7mX9k',
              name: 'Paris, France',
              latitude: 48.8566,
              longitude: 2.3522,
            ),
        dateRange: dateRange ??
            DateRange(
              start: DateTime(2026, 5, 11),
              end: DateTime(2026, 5, 18),
            ),
        interests: interests ?? {TravelInterest.food, TravelInterest.culture},
        budget: budget,
      );
    }

    group('Validation', () {
      test('should be valid when all required fields are present', () {
        final data = createValidOnboardingData();

        expect(data.isValid, isTrue);
        expect(data.validationErrors, isEmpty);
      });

      test('should be invalid when name is empty', () {
        final data = createValidOnboardingData(name: '');

        expect(data.isValid, isFalse);
        expect(data.validationErrors, contains('Please enter your name'));
      });

      test('should be invalid when name contains only whitespace', () {
        final data = createValidOnboardingData(name: '   ');

        expect(data.isValid, isFalse);
        expect(data.validationErrors, contains('Please enter your name'));
      });

      test('should be invalid when destination is invalid', () {
        final data = createValidOnboardingData(
          destination: const Destination(
            placeId: '',
            name: '',
            latitude: 0,
            longitude: 0,
          ),
        );

        expect(data.isValid, isFalse);
        expect(
          data.validationErrors,
          contains('Please select a valid destination'),
        );
      });

      test('should be invalid when date range is invalid', () {
        final data = createValidOnboardingData(
          dateRange: DateRange(
            start: DateTime(2026, 5, 18),
            end: DateTime(2026, 5, 11), // End before start
          ),
        );

        expect(data.isValid, isFalse);
        expect(
          data.validationErrors,
          contains('Please select valid travel dates'),
        );
      });

      test('should be invalid when no interests are selected', () {
        final data = createValidOnboardingData(interests: {});

        expect(data.isValid, isFalse);
        expect(
          data.validationErrors,
          contains('Please select at least one interest'),
        );
      });

      test('should be invalid when more than 5 interests are selected', () {
        final data = createValidOnboardingData(
          interests: TravelInterest.values.toSet(),
        );

        expect(data.isValid, isFalse);
        expect(
          data.validationErrors,
          contains('Please select no more than 5 interests'),
        );
      });

      test(
          'should return all validation errors when multiple fields are invalid',
          () {
        final data = OnboardingData(
          name: '',
          destination: const Destination(
            placeId: '',
            name: '',
            latitude: 0,
            longitude: 0,
          ),
          dateRange: DateRange(
            start: DateTime(2026, 5, 18),
            end: DateTime(2026, 5, 11),
          ),
          interests: {},
        );

        expect(data.isValid, isFalse);
        expect(data.validationErrors.length, greaterThan(1));
      });
    });

    group('Freezed equality', () {
      test('should be equal when all properties match', () {
        final data1 = createValidOnboardingData();
        final data2 = createValidOnboardingData();

        expect(data1, equals(data2));
        expect(data1.hashCode, equals(data2.hashCode));
      });

      test('should not be equal when name differs', () {
        final data1 = createValidOnboardingData(name: 'John');
        final data2 = createValidOnboardingData(name: 'Jane');

        expect(data1, isNot(equals(data2)));
      });

      test('should not be equal when destination differs', () {
        final data1 = createValidOnboardingData(
          destination: const Destination(
            placeId: 'paris-id',
            name: 'Paris',
            latitude: 48.8566,
            longitude: 2.3522,
          ),
        );
        final data2 = createValidOnboardingData(
          destination: const Destination(
            placeId: 'london-id',
            name: 'London',
            latitude: 51.5074,
            longitude: -0.1278,
          ),
        );

        expect(data1, isNot(equals(data2)));
      });

      test('should not be equal when date range differs', () {
        final data1 = createValidOnboardingData(
          dateRange: DateRange(
            start: DateTime(2026, 5, 11),
            end: DateTime(2026, 5, 18),
          ),
        );
        final data2 = createValidOnboardingData(
          dateRange: DateRange(
            start: DateTime(2026, 6, 11),
            end: DateTime(2026, 6, 18),
          ),
        );

        expect(data1, isNot(equals(data2)));
      });

      test('should not be equal when interests differ', () {
        final data1 = createValidOnboardingData(
          interests: {TravelInterest.food},
        );
        final data2 = createValidOnboardingData(
          interests: {TravelInterest.culture},
        );

        expect(data1, isNot(equals(data2)));
      });

      test('should not be equal when budget differs', () {
        final data1 =
            createValidOnboardingData(budget: BudgetRange.budgetFriendly);
        final data2 = createValidOnboardingData(budget: BudgetRange.flexible);

        expect(data1, isNot(equals(data2)));
      });
    });

    group('copyWith', () {
      test('should create a copy with updated name', () {
        final data1 = createValidOnboardingData(name: 'John');
        final data2 = data1.copyWith(name: 'Jane');

        expect(data2.name, 'Jane');
        expect(data1.name, 'John'); // Original unchanged
      });

      test('should create a copy with updated interests', () {
        final data1 = createValidOnboardingData(
          interests: {TravelInterest.food},
        );
        final data2 = data1.copyWith(
          interests: {TravelInterest.food, TravelInterest.culture},
        );

        expect(data2.interests.length, 2);
        expect(data1.interests.length, 1); // Original unchanged
      });

      test('should create a copy with budget added', () {
        final data1 = createValidOnboardingData(budget: null);
        final data2 = data1.copyWith(budget: BudgetRange.moderate);

        expect(data2.budget, BudgetRange.moderate);
        expect(data1.budget, isNull); // Original unchanged
      });
    });

    group('summary', () {
      test('should return formatted summary string', () {
        final data = createValidOnboardingData(
          name: 'John',
          destination: const Destination(
            placeId: 'paris-id',
            name: 'Paris, France',
            latitude: 48.8566,
            longitude: 2.3522,
          ),
          dateRange: DateRange(
            start: DateTime(2026, 5, 11),
            end: DateTime(2026, 5, 18),
          ),
          interests: {TravelInterest.food, TravelInterest.culture},
        );

        final summary = data.summary;

        expect(summary, contains("John's trip to Paris, France"));
        expect(summary, contains('May 11-18, 2026'));
        expect(summary, contains('Food'));
        expect(summary, contains('Culture'));
      });

      test('should truncate interests when more than 3', () {
        final data = createValidOnboardingData(
          name: 'John',
          interests: {
            TravelInterest.food,
            TravelInterest.culture,
            TravelInterest.nature,
            TravelInterest.art,
            TravelInterest.shopping,
          },
        );

        final summary = data.summary;

        expect(summary, contains('+2 more'));
      });
    });

    group('JSON serialization', () {
      test('should serialize to JSON and back', () {
        final data = createValidOnboardingData(
          budget: BudgetRange.budgetFriendly,
        );

        final json = data.toJson();
        final deserialized = OnboardingData.fromJson(json);

        expect(deserialized, equals(data));
        expect(deserialized.name, data.name);
        expect(deserialized.budget, data.budget);
      });
    });
  });
}
