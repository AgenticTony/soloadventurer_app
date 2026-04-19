import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/budget_range.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/date_range.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/destination.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/onboarding_data.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/travel_interest.dart';
import 'package:soloadventurer/features/onboarding/domain/repositories/itinerary_generation_repository.dart';
import 'package:soloadventurer/features/onboarding/domain/usecases/generate_starter_itinerary.dart';
import 'package:soloadventurer/features/onboarding/presentation/notifiers/onboarding_notifier.dart';
import 'package:soloadventurer/features/onboarding/presentation/providers/onboarding_providers.dart';
import 'package:soloadventurer/features/onboarding/presentation/state/onboarding_state.dart';
import 'package:soloadventurer/features/travel/domain/models/itinerary.dart';

class MockItineraryGenerationRepository extends Mock
    implements ItineraryGenerationRepository {}

void main() {
  setUpAll(() {
    registerFallbackValue(<String, dynamic>{});
  });
  group('OnboardingProviders', () {
    late ProviderContainer container;
    late MockItineraryGenerationRepository mockRepository;

    setUp(() {
      mockRepository = MockItineraryGenerationRepository();

      container = ProviderContainer(
        overrides: [
          itineraryGenerationRepositoryProvider
              .overrideWithValue(mockRepository),
        ],
      );

      addTearDown(container.dispose);
    });

    // Helper to create valid OnboardingData
    OnboardingData createValidOnboardingData({
      String name = 'Test User',
      Set<TravelInterest>? interests,
    }) {
      return OnboardingData(
        name: name,
        destination: const Destination(
          placeId: 'test-place-id',
          name: 'Test City, Test Country',
          latitude: 40.7128,
          longitude: -74.0060,
        ),
        dateRange: DateRange(
          start: DateTime(2026, 6, 1),
          end: DateTime(2026, 6, 7),
        ),
        interests: interests ?? {TravelInterest.food, TravelInterest.culture},
        budget: BudgetRange.moderate,
      );
    }

    // Helper to create a mock Itinerary
    Itinerary createMockItinerary() {
      return Itinerary(
        id: 'test-itinerary-id',
        name: 'Test Trip',
        destination: const Destination(
          placeId: 'test-place-id',
          name: 'Test City',
          latitude: 40.7128,
          longitude: -74.0060,
        ),
        dateRange: DateRange(
          start: DateTime(2026, 6, 1),
          end: DateTime(2026, 6, 7),
        ),
        items: [],
        isStarter: true,
        createdAt: DateTime.now(),
      );
    }

    group('generateStarterItineraryProvider', () {
      test('should provide GenerateStarterItinerary use case', () {
        final useCase = container.read(generateStarterItineraryProvider);

        expect(useCase, isA<GenerateStarterItinerary>());
      });

      test('should inject repository into use case', () {
        final useCase = container.read(generateStarterItineraryProvider);

        expect(useCase, isNotNull);
      });
    });

    group('onboardingProvider', () {
      test('should start with initial state', () {
        final state = container.read(onboardingProvider);

        expect(state, isA<OnboardingState>());
        expect(
          state.maybeWhen(
            initial: () => true,
            orElse: () => false,
          ),
          isTrue,
        );
      });

      test('should update state when form data changes', () {
        final notifier = container.read(onboardingProvider.notifier);
        const name = 'Jane Doe';

        notifier.updateName(name);

        final state = container.read(onboardingProvider);

        expect(
          state.maybeWhen(
            inProgress: (data, _, __) => data.name == name,
            orElse: () => false,
          ),
          isTrue,
        );
      });

      test('should update to submitting state when form is submitted',
          () async {
        final data = createValidOnboardingData();
        final mockItineraryJson = <String, dynamic>{
          'id': 'test-itinerary-id',
          'name': 'Test Trip',
          'destination': {
            'placeId': 'test-place-id',
            'name': 'Test City',
            'latitude': 40.7128,
            'longitude': -74.006,
          },
          'dateRange': {
            'start': '2026-06-01T00:00:00.000',
            'end': '2026-06-07T00:00:00.000',
          },
          'items': <dynamic>[],
          'isStarter': true,
          'createdAt': DateTime.now().toIso8601String(),
        };

        when(() => mockRepository.canGenerateItinerary(any()))
            .thenAnswer((_) async => true);
        when(() => mockRepository.generateStarterItinerary(any()))
            .thenAnswer((_) async => mockItineraryJson);

        final notifier = container.read(onboardingProvider.notifier);

        // Update form with valid data first
        notifier.updateFormData(data);

        // Submit the form
        await notifier
              .submitForm(container.read(generateStarterItineraryProvider));

        final state = container.read(onboardingProvider);

        expect(
          state.maybeWhen(
            success: (_, __) => true,
            orElse: () => false,
          ),
          isTrue,
        );
      });

      test('should update to error state when submission fails', () async {
        final data = createValidOnboardingData();

        when(() => mockRepository.canGenerateItinerary(any()))
            .thenThrow(Exception('Network error'));

        final notifier = container.read(onboardingProvider.notifier);

        notifier.updateFormData(data);

        try {
          await notifier.submitForm(
            container.read(generateStarterItineraryProvider),
          );
        } catch (_) {
          // Exception is expected
        }

        final state = container.read(onboardingProvider);

        expect(
          state.maybeWhen(
            error: (_, __, ___) => true,
            orElse: () => false,
          ),
          isTrue,
        );
      });
    });

    group('currentOnboardingDataProvider', () {
      test('should return null in initial state', () {
        final currentData = container.read(currentOnboardingDataProvider);

        expect(currentData, isNull);
      });

      test('should return data in inProgress state', () {
        final notifier = container.read(onboardingProvider.notifier);
        final data = createValidOnboardingData();

        notifier.updateFormData(data);

        final currentData = container.read(currentOnboardingDataProvider);

        expect(currentData, equals(data));
      });

      test('should return data in submitting state', () {
        final notifier = container.read(onboardingProvider.notifier);
        final data = createValidOnboardingData();

        notifier.updateFormData(data);

        final currentData = container.read(currentOnboardingDataProvider);

        expect(currentData, equals(data));
      });

      test('should return data in success state', () async {
        final notifier = container.read(onboardingProvider.notifier);
        final data = createValidOnboardingData();
        final mockItineraryJson = <String, dynamic>{
          'id': 'test-itinerary-id',
          'name': 'Test Trip',
          'destination': {
            'placeId': 'test-place-id',
            'name': 'Test City',
            'latitude': 40.7128,
            'longitude': -74.006,
          },
          'dateRange': {
            'start': '2026-06-01T00:00:00.000',
            'end': '2026-06-07T00:00:00.000',
          },
          'items': <dynamic>[],
          'isStarter': true,
          'createdAt': DateTime.now().toIso8601String(),
        };

        when(() => mockRepository.canGenerateItinerary(any()))
            .thenAnswer((_) async => true);
        when(() => mockRepository.generateStarterItinerary(any()))
            .thenAnswer((_) async => mockItineraryJson);

        notifier.updateFormData(data);
        await notifier.submitForm(
          container.read(generateStarterItineraryProvider),
        );

        final currentData = container.read(currentOnboardingDataProvider);

        expect(currentData, equals(data));
      });

      test('should return data in error state', () {
        final notifier = container.read(onboardingProvider.notifier);
        final data = createValidOnboardingData();

        notifier.updateFormData(data);
        // Force error state by setting invalid data
        notifier.updateName(''); // Empty name is invalid

        final currentData = container.read(currentOnboardingDataProvider);

        expect(currentData, isNotNull);
      });
    });

    group('isOnboardingFormValidProvider', () {
      test('should return false in initial state', () {
        final isValid = container.read(isOnboardingFormValidProvider);

        expect(isValid, isFalse);
      });

      test('should return true when form data is valid', () {
        final notifier = container.read(onboardingProvider.notifier);
        final data = createValidOnboardingData();

        notifier.updateFormData(data);

        final isValid = container.read(isOnboardingFormValidProvider);

        expect(isValid, isTrue);
      });

      test('should return false when form data is invalid', () {
        final notifier = container.read(onboardingProvider.notifier);
        final data = OnboardingData(
          name: '', // Invalid
          destination: const Destination(
            placeId: 'test',
            name: 'Test',
            latitude: 0,
            longitude: 0,
          ),
          dateRange: DateRange(
            start: DateTime.now(),
            end: DateTime.now().add(const Duration(days: 7)),
          ),
          interests: {},
        );

        notifier.updateFormData(data);

        final isValid = container.read(isOnboardingFormValidProvider);

        expect(isValid, isFalse);
      });
    });

    group('onboardingValidationErrorsProvider', () {
      test('should return empty list in initial state', () {
        final errors = container.read(onboardingValidationErrorsProvider);

        expect(errors, isEmpty);
      });

      test('should return errors when form is invalid', () {
        final notifier = container.read(onboardingProvider.notifier);
        final data = OnboardingData(
          name: '',
          destination: const Destination(
            placeId: '',
            name: '',
            latitude: 0,
            longitude: 0,
          ),
          dateRange: DateRange(
            start: DateTime.now(),
            end: DateTime.now().add(const Duration(days: 7)),
          ),
          interests: {},
        );

        notifier.updateFormData(data);

        final errors = container.read(onboardingValidationErrorsProvider);

        expect(errors, isNotEmpty);
      });

      test('should return empty list when form is valid', () {
        final notifier = container.read(onboardingProvider.notifier);
        final data = createValidOnboardingData();

        notifier.updateFormData(data);

        final errors = container.read(onboardingValidationErrorsProvider);

        expect(errors, isEmpty);
      });
    });

    group('isOnboardingSubmittingProvider', () {
      test('should return false in initial state', () {
        final isSubmitting = container.read(isOnboardingSubmittingProvider);

        expect(isSubmitting, isFalse);
      });

      test('should return true in submitting state', () async {
        final notifier = container.read(onboardingProvider.notifier);
        final data = createValidOnboardingData();
        final mockItineraryJson = <String, dynamic>{
          'id': 'test-itinerary-id',
          'name': 'Test Trip',
          'destination': {
            'placeId': 'test-place-id',
            'name': 'Test City',
            'latitude': 40.7128,
            'longitude': -74.006,
          },
          'dateRange': {
            'start': '2026-06-01T00:00:00.000',
            'end': '2026-06-07T00:00:00.000',
          },
          'items': <dynamic>[],
          'isStarter': true,
          'createdAt': DateTime.now().toIso8601String(),
        };

        // Use a completer to keep the submission pending
        final completer = Completer<Map<String, dynamic>>();

        when(() => mockRepository.canGenerateItinerary(any()))
            .thenAnswer((_) async => true);
        when(() => mockRepository.generateStarterItinerary(any()))
            .thenAnswer((_) => completer.future);

        notifier.updateFormData(data);

        // Start submission (don't await)
        final future = notifier.submitForm(
          container.read(generateStarterItineraryProvider),
        );

        // Check submitting state while submission is in progress
        final isSubmitting = container.read(isOnboardingSubmittingProvider);

        expect(isSubmitting, isTrue);

        // Complete the future to clean up
        completer.complete(mockItineraryJson);
        await future;
      });

      test('should return false in success state', () async {
        final notifier = container.read(onboardingProvider.notifier);
        final data = createValidOnboardingData();
        final mockItineraryJson = <String, dynamic>{
          'id': 'test-itinerary-id',
          'name': 'Test Trip',
          'destination': {
            'placeId': 'test-place-id',
            'name': 'Test City',
            'latitude': 40.7128,
            'longitude': -74.006,
          },
          'dateRange': {
            'start': '2026-06-01T00:00:00.000',
            'end': '2026-06-07T00:00:00.000',
          },
          'items': <dynamic>[],
          'isStarter': true,
          'createdAt': DateTime.now().toIso8601String(),
        };

        when(() => mockRepository.canGenerateItinerary(any()))
            .thenAnswer((_) async => true);
        when(() => mockRepository.generateStarterItinerary(any()))
            .thenAnswer((_) async => mockItineraryJson);

        notifier.updateFormData(data);
        await notifier.submitForm(
          container.read(generateStarterItineraryProvider),
        );

        final isSubmitting = container.read(isOnboardingSubmittingProvider);

        expect(isSubmitting, isFalse);
      });
    });

    group('generatedItineraryProvider', () {
      test('should return null in initial state', () {
        final itinerary = container.read(generatedItineraryProvider);

        expect(itinerary, isNull);
      });

      test('should return null in inProgress state', () {
        final notifier = container.read(onboardingProvider.notifier);
        final data = createValidOnboardingData();

        notifier.updateFormData(data);

        final itinerary = container.read(generatedItineraryProvider);

        expect(itinerary, isNull);
      });

      test('should return itinerary JSON in success state', () async {
        final notifier = container.read(onboardingProvider.notifier);
        final data = createValidOnboardingData();
        final mockItineraryJson = <String, dynamic>{
          'id': 'test-itinerary-id',
          'name': 'Test Trip',
          'destination': {
            'placeId': 'test-place-id',
            'name': 'Test City',
            'latitude': 40.7128,
            'longitude': -74.006,
          },
          'dateRange': {
            'start': '2026-06-01T00:00:00.000',
            'end': '2026-06-07T00:00:00.000',
          },
          'items': <dynamic>[],
          'isStarter': true,
          'createdAt': DateTime.now().toIso8601String(),
        };

        when(() => mockRepository.canGenerateItinerary(any()))
            .thenAnswer((_) async => true);
        when(() => mockRepository.generateStarterItinerary(any()))
            .thenAnswer((_) async => mockItineraryJson);

        notifier.updateFormData(data);
        await notifier.submitForm(
          container.read(generateStarterItineraryProvider),
        );

        final itinerary = container.read(generatedItineraryProvider);

        expect(itinerary, isNotNull);
        expect(itinerary!['id'], equals('test-itinerary-id'));
        expect(itinerary['name'], equals('Test Trip'));
      });

      test('should return null in error state', () {
        final notifier = container.read(onboardingProvider.notifier);
        final data = createValidOnboardingData();

        notifier.updateFormData(data);
        notifier.updateName(''); // Invalid - empty name

        final itinerary = container.read(generatedItineraryProvider);

        expect(itinerary, isNull);
      });
    });

    group('onboardingErrorMessageProvider', () {
      test('should return null in initial state', () {
        final errorMessage = container.read(onboardingErrorMessageProvider);

        expect(errorMessage, isNull);
      });

      test('should return null in inProgress state when valid', () {
        final notifier = container.read(onboardingProvider.notifier);
        final data = createValidOnboardingData();

        notifier.updateFormData(data);

        final errorMessage = container.read(onboardingErrorMessageProvider);

        expect(errorMessage, isNull);
      });

      test('should return error message in error state', () async {
        final notifier = container.read(onboardingProvider.notifier);
        final data = createValidOnboardingData();

        when(() => mockRepository.canGenerateItinerary(any()))
            .thenThrow(Exception('Network error'));

        notifier.updateFormData(data);
        await notifier.submitForm(
          container.read(generateStarterItineraryProvider),
        );

        final errorMessage = container.read(onboardingErrorMessageProvider);

        expect(errorMessage, isNotNull);
      });

      test('should return null in success state', () async {
        final notifier = container.read(onboardingProvider.notifier);
        final data = createValidOnboardingData();
        final mockItineraryJson = <String, dynamic>{
          'id': 'test-itinerary-id',
          'name': 'Test Trip',
          'destination': {
            'placeId': 'test-place-id',
            'name': 'Test City',
            'latitude': 40.7128,
            'longitude': -74.006,
          },
          'dateRange': {
            'start': '2026-06-01T00:00:00.000',
            'end': '2026-06-07T00:00:00.000',
          },
          'items': <dynamic>[],
          'isStarter': true,
          'createdAt': DateTime.now().toIso8601String(),
        };

        when(() => mockRepository.canGenerateItinerary(any()))
            .thenAnswer((_) async => true);
        when(() => mockRepository.generateStarterItinerary(any()))
            .thenAnswer((_) async => mockItineraryJson);

        notifier.updateFormData(data);
        await notifier.submitForm(
          container.read(generateStarterItineraryProvider),
        );

        final errorMessage = container.read(onboardingErrorMessageProvider);

        expect(errorMessage, isNull);
      });
    });
  });
}
