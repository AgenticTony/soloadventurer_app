import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:solo_adventurer/features/destination_discovery/application/providers/add_to_trip_provider.dart';
import 'package:solo_adventurer/features/destination_discovery/domain/models/destination.dart';
import 'package:solo_adventurer/features/travel/domain/models/trip_planning_operation.dart';
import 'package:solo_adventurer/features/travel/domain/repositories/travel_operation_repository.dart';

// Mock classes
class MockTravelOperationRepository extends Mock implements TravelOperationRepository {}

void main() {
  late MockTravelOperationRepository mockRepository;
  late AddToTripNotifier notifier;

  // Test data
  final testDestination = Destination(
    id: 'dest1',
    name: 'Tokyo',
    description: 'Amazing city',
    location: (lat: 35.6762, lng: 139.6503),
    safetyScore: 8.5,
    soloSuitabilityScore: 8.0,
    soloSuitabilityFactors: SoloSuitabilityFactors(
      safety: 8.5,
      nightlife: 7.0,
      walkability: 9.0,
      accommodation: 8.0,
      soloDining: 7.5,
      communication: 6.5,
      overall: 7.8,
    ),
    countryCode: 'JP',
    region: 'Kanto',
    budgetLevel: BudgetLevel.moderate,
    activityLevel: ActivityLevel.moderate,
    tags: ['urban', 'cultural'],
    images: ['https://example.com/tokyo.jpg'],
    popularActivities: [],
    bestTimeToVisit: 'Spring',
  );

  final testOperation = TripPlanningOperation.update(
    tripId: 'trip123',
    destinations: ['dest1'],
    startDate: DateTime(2024, 3, 15),
    endDate: DateTime(2024, 3, 20),
  );

  setUp(() {
    mockRepository = MockTravelOperationRepository();
    notifier = AddToTripNotifier(mockRepository);
  });

  group('AddToTripNotifier', () {
    group('initial state', () {
      test('should start with initial state', () {
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.isSuccess, isFalse);
        expect(notifier.state.hasError, isFalse);
        expect(notifier.state.isComplete, isFalse);
        expect(notifier.state.destination, isNull);
        expect(notifier.state.tripId, isNull);
        expect(notifier.state.tripName, isNull);
        expect(notifier.state.errorMessage, isNull);
      });
    });

    group('addToExistingTrip', () {
      test('should add destination to existing trip successfully', () async {
        when(() => mockRepository.saveOperation(any()))
            .thenAnswer((_) async => {});

        await notifier.addToExistingTrip(
          destination: testDestination,
          tripId: 'trip123',
          tripName: 'Japan Adventure',
          startDate: DateTime(2024, 3, 15),
          endDate: DateTime(2024, 3, 20),
          notes: 'Must visit temples',
        );

        // Verify repository was called
        verify(() => mockRepository.saveOperation(any())).called(1);

        // Check final state
        expect(notifier.state.isSuccess, isTrue);
        expect(notifier.state.isComplete, isTrue);
        expect(notifier.state.tripId, 'trip123');
        expect(notifier.state.tripName, 'Japan Adventure');
        expect(notifier.state.hasError, isFalse);
        expect(notifier.state.isLoading, isFalse);
      });

      test('should create operation with correct parameters', () async {
        when(() => mockRepository.saveOperation(any()))
            .thenAnswer((_) async => {});

        await notifier.addToExistingTrip(
          destination: testDestination,
          tripId: 'trip456',
          tripName: 'Summer Trip',
        );

        final capturedOperation = verify(() => mockRepository.saveOperation(captureAny()))
            .captured.single as TripPlanningOperation;

        expect(capturedOperation.tripId, 'trip456');
        expect(capturedOperation.destinations, ['dest1']);
      });

      test('should set loading state during operation', () async {
        // Setup delayed response to check loading state
        when(() => mockRepository.saveOperation(any())).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
        });

        final future = notifier.addToExistingTrip(
          destination: testDestination,
          tripId: 'trip123',
          tripName: 'Test',
        );

        // Check loading state
        expect(notifier.isLoading, isTrue);
        expect(notifier.state.isLoading, isTrue);

        await future;

        // Check final state
        expect(notifier.isLoading, isFalse);
        expect(notifier.state.isSuccess, isTrue);
      });

      test('should handle errors during add', () async {
        when(() => mockRepository.saveOperation(any()))
            .thenThrow(Exception('Network error'));

        expect(
          () async => await notifier.addToExistingTrip(
            destination: testDestination,
            tripId: 'trip123',
            tripName: 'Test',
          ),
          throwsException,
        );

        expect(notifier.state.hasError, isTrue);
        expect(notifier.state.isComplete, isTrue);
        expect(notifier.state.errorMessage, isNotNull);
        expect(notifier.state.isLoading, isFalse);
      });

      test('should handle optional parameters', () async {
        when(() => mockRepository.saveOperation(any()))
            .thenAnswer((_) async => {});

        await notifier.addToExistingTrip(
          destination: testDestination,
          tripId: 'trip123',
          tripName: 'Japan Trip',
          // No optional params
        );

        verify(() => mockRepository.saveOperation(any())).called(1);
        expect(notifier.state.isSuccess, isTrue);
      });
    });

    group('addToNewTrip', () {
      test('should create new trip and add destination', () async {
        when(() => mockRepository.saveOperation(any()))
            .thenAnswer((_) async => {});

        final tripId = await notifier.addToNewTrip(
          destination: testDestination,
          tripTitle: 'Summer Adventure 2024',
          tripDescription: 'Exploring Europe',
          startDate: DateTime(2024, 6, 1),
          endDate: DateTime(2024, 6, 21),
          notes: 'First stop: Paris',
        );

        // Verify repository was called
        verify(() => mockRepository.saveOperation(any())).called(1);

        // Check returned trip ID
        expect(tripId, isNotNull);
        expect(tripId.isNotEmpty, isTrue);

        // Check final state
        expect(notifier.state.isSuccess, isTrue);
        expect(notifier.state.isComplete, isTrue);
        expect(notifier.state.tripId, tripId);
        expect(notifier.state.tripName, 'Summer Adventure 2024');
        expect(notifier.state.hasError, isFalse);
      });

      test('should create operation with correct type', () async {
        when(() => mockRepository.saveOperation(any()))
            .thenAnswer((_) async => {});

        await notifier.addToNewTrip(
          destination: testDestination,
          tripTitle: 'New Adventure',
        );

        final capturedOperation = verify(() => mockRepository.saveOperation(captureAny()))
            .captured.single as TripPlanningOperation;

        expect(capturedOperation.tripId, isNotNull);
        expect(capturedOperation.tripName, 'New Adventure');
        expect(capturedOperation.destinations, ['dest1']);
      });

      test('should set loading state during operation', () async {
        when(() => mockRepository.saveOperation(any())).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 100));
        });

        final future = notifier.addToNewTrip(
          destination: testDestination,
          tripTitle: 'Test Trip',
        );

        expect(notifier.isLoading, isTrue);

        await future;

        expect(notifier.isLoading, isFalse);
        expect(notifier.state.isSuccess, isTrue);
      });

      test('should handle errors during creation', () async {
        when(() => mockRepository.saveOperation(any()))
            .thenThrow(Exception('Failed to create trip'));

        expect(
          () async => await notifier.addToNewTrip(
            destination: testDestination,
            tripTitle: 'Test Trip',
          ),
          throwsException,
        );

        expect(notifier.state.hasError, isTrue);
        expect(notifier.state.isComplete, isTrue);
        expect(notifier.state.errorMessage, isNotNull);
      });

      test('should handle optional parameters', () async {
        when(() => mockRepository.saveOperation(any()))
            .thenAnswer((_) async => {});

        final tripId = await notifier.addToNewTrip(
          destination: testDestination,
          tripTitle: 'Quick Trip',
          // No optional params
        );

        expect(tripId, isNotNull);
        expect(notifier.state.isSuccess, isTrue);
      });
    });

    group('reset', () {
      test('should reset state to initial', () async {
        // Setup state
        when(() => mockRepository.saveOperation(any()))
            .thenAnswer((_) async => {});
        await notifier.addToExistingTrip(
          destination: testDestination,
          tripId: 'trip123',
          tripName: 'Test',
        );

        notifier.reset();

        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.isSuccess, isFalse);
        expect(notifier.state.hasError, isFalse);
        expect(notifier.state.isComplete, isFalse);
        expect(notifier.state.destination, isNull);
        expect(notifier.state.tripId, isNull);
        expect(notifier.state.tripName, isNull);
        expect(notifier.state.errorMessage, isNull);
      });
    });

    group('clearError', () {
      test('should clear error message', () async {
        // Setup error state
        when(() => mockRepository.saveOperation(any()))
            .thenThrow(Exception('Error'));

        try {
          await notifier.addToExistingTrip(
            destination: testDestination,
            tripId: 'trip123',
            tripName: 'Test',
          );
        } catch (_) {}

        expect(notifier.state.hasError, isTrue);

        notifier.clearError();

        expect(notifier.state.hasError, isFalse);
        expect(notifier.state.errorMessage, isNull);
      });

      test('should do nothing when no error', () async {
        notifier.clearError();

        // Should not throw
        expect(notifier.state.hasError, isFalse);
      });
    });

    group('getters', () {
      test('destination getter should return destination', () async {
        when(() => mockRepository.saveOperation(any()))
            .thenAnswer((_) async => {});

        await notifier.addToExistingTrip(
          destination: testDestination,
          tripId: 'trip123',
          tripName: 'Test',
        );

        expect(notifier.destination?.id, 'dest1');
        expect(notifier.destination?.name, 'Tokyo');
      });

      test('tripId getter should return trip ID', () async {
        when(() => mockRepository.saveOperation(any()))
            .thenAnswer((_) async => {});

        await notifier.addToExistingTrip(
          destination: testDestination,
          tripId: 'trip456',
          tripName: 'Test',
        );

        expect(notifier.tripId, 'trip456');
      });

      test('tripName getter should return trip name', () async {
        when(() => mockRepository.saveOperation(any()))
            .thenAnswer((_) async => {});

        await notifier.addToNewTrip(
          destination: testDestination,
          tripTitle: 'My Adventure',
        );

        expect(notifier.tripName, 'My Adventure');
      });

      test('isLoading getter should return loading state', () async {
        when(() => mockRepository.saveOperation(any())).thenAnswer((_) async {
          await Future.delayed(const Duration(milliseconds: 50));
        });

        final future = notifier.addToExistingTrip(
          destination: testDestination,
          tripId: 'trip123',
          tripName: 'Test',
        );

        expect(notifier.isLoading, isTrue);

        await future;

        expect(notifier.isLoading, isFalse);
      });

      test('isSuccess getter should return success state', () async {
        when(() => mockRepository.saveOperation(any()))
            .thenAnswer((_) async => {});

        await notifier.addToExistingTrip(
          destination: testDestination,
          tripId: 'trip123',
          tripName: 'Test',
        );

        expect(notifier.isSuccess, isTrue);
      });

      test('hasError getter should return error state', () async {
        when(() => mockRepository.saveOperation(any()))
            .thenThrow(Exception('Error'));

        try {
          await notifier.addToExistingTrip(
            destination: testDestination,
            tripId: 'trip123',
            tripName: 'Test',
          );
        } catch (_) {}

        expect(notifier.hasError, isTrue);
      });

      test('errorMessage getter should return error message', () async {
        when(() => mockRepository.saveOperation(any()))
            .thenThrow(Exception('Specific error message'));

        try {
          await notifier.addToExistingTrip(
            destination: testDestination,
            tripId: 'trip123',
            tripName: 'Test',
          );
        } catch (_) {}

        expect(notifier.errorMessage, isNotNull);
        expect(notifier.errorMessage?.contains('error message'), isTrue);
      });

      test('isComplete getter should return completion status', () async {
        when(() => mockRepository.saveOperation(any()))
            .thenAnswer((_) async => {});

        await notifier.addToExistingTrip(
          destination: testDestination,
          tripId: 'trip123',
          tripName: 'Test',
        );

        expect(notifier.isComplete, isTrue);
      });

      test('getters should return null/false in initial state', () {
        expect(notifier.destination, isNull);
        expect(notifier.tripId, isNull);
        expect(notifier.tripName, isNull);
        expect(notifier.isLoading, isFalse);
        expect(notifier.isSuccess, isFalse);
        expect(notifier.hasError, isFalse);
        expect(notifier.errorMessage, isNull);
        expect(notifier.isComplete, isFalse);
      });
    });

    group('state transitions', () {
      test('should transition through loading to success', () async {
        when(() => mockRepository.saveOperation(any()))
            .thenAnswer((_) async => {});

        // Initial state
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.isSuccess, isFalse);

        // Start operation
        final future = notifier.addToExistingTrip(
          destination: testDestination,
          tripId: 'trip123',
          tripName: 'Test',
        );

        // Loading state
        expect(notifier.state.isLoading, isTrue);

        await future;

        // Success state
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.isSuccess, isTrue);
        expect(notifier.state.isComplete, isTrue);
      });

      test('should transition through loading to error', () async {
        when(() => mockRepository.saveOperation(any()))
            .thenThrow(Exception('Network error'));

        // Start operation
        final future = notifier.addToExistingTrip(
          destination: testDestination,
          tripId: 'trip123',
          tripName: 'Test',
        );

        // Loading state
        expect(notifier.state.isLoading, isTrue);

        try {
          await future;
        } catch (_) {}

        // Error state
        expect(notifier.state.isLoading, isFalse);
        expect(notifier.state.hasError, isTrue);
        expect(notifier.state.isComplete, isTrue);
      });

      test('should handle sequential operations', () async {
        when(() => mockRepository.saveOperation(any()))
            .thenAnswer((_) async => {});

        // First operation
        await notifier.addToExistingTrip(
          destination: testDestination,
          tripId: 'trip123',
          tripName: 'First Trip',
        );

        expect(notifier.isSuccess, isTrue);

        // Reset for next operation
        notifier.reset();

        expect(notifier.isSuccess, isFalse);

        // Second operation
        await notifier.addToNewTrip(
          destination: testDestination,
          tripTitle: 'Second Trip',
        );

        expect(notifier.isSuccess, isTrue);
        expect(notifier.tripName, 'Second Trip');
      });
    });
  });
}
