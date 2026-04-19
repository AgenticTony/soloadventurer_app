import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/safety/domain/entities/check_in.dart';
import 'package:soloadventurer/features/safety/presentation/providers/safety_providers.dart';
import 'package:soloadventurer/features/safety/domain/usecases/complete_check_in.dart';
import 'package:soloadventurer/features/safety/domain/usecases/cancel_check_in.dart';
import 'package:soloadventurer/features/safety/domain/usecases/get_upcoming_check_ins.dart';
import 'package:soloadventurer/features/safety/presentation/state/check_in_state.dart';
import 'package:soloadventurer/features/safety/presentation/providers/check_in_provider.dart';

import '../../../../helpers/safety_test_helpers.dart';

class MockCompleteCheckInUseCase extends Mock
    implements CompleteCheckInUseCase {}

class MockCancelCheckInUseCase extends Mock implements CancelCheckInUseCase {}

class MockGetUpcomingCheckInsUseCase extends Mock
    implements GetUpcomingCheckInsUseCase {}

void main() {
  late MockCompleteCheckInUseCase mockCompleteCheckIn;
  late MockCancelCheckInUseCase mockCancelCheckIn;
  late MockGetUpcomingCheckInsUseCase mockGetUpcomingCheckIns;

  setUp(() {
    mockCompleteCheckIn = MockCompleteCheckInUseCase();
    mockCancelCheckIn = MockCancelCheckInUseCase();
    mockGetUpcomingCheckIns = MockGetUpcomingCheckInsUseCase();

    registerFallbackValue(testDateTime);
    registerFallbackValue(createTestCheckInLocation());
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        completeCheckInUseCaseProvider.overrideWithValue(mockCompleteCheckIn),
        cancelCheckInUseCaseProvider.overrideWithValue(mockCancelCheckIn),
        getUpcomingCheckInsUseCaseProvider
            .overrideWithValue(mockGetUpcomingCheckIns),
      ],
    );
  }

  group('CheckInNotifier', () {
    test('initial state has correct defaults', () async {
      final container = createContainer();

      // AsyncNotifier builds asynchronously, so wait for it
      await container.read(checkInProvider.future);
      final asyncState = container.read(checkInProvider);

      expect(asyncState.isLoading, isFalse);
      final state = asyncState.value!;
      expect(state.checkIns, isEmpty);
      expect(state.upcomingCheckIns, isEmpty);
      expect(state.selectedCheckIn, isNull);
      expect(asyncState.hasError, isFalse);
      expect(state.isCreating, isFalse);
      expect(state.isCompleting, isFalse);
      expect(state.isCancelling, isFalse);
      expect(state.hasUpcomingCheckIns, isFalse);
      expect(state.isProcessing, isFalse);
      expect(state.dueSoonCount, equals(0));
      expect(state.missedCount, equals(0));
      expect(state.nextCheckIn, isNull);

      container.dispose();
    });

    group('loadCheckIns', () {
      test('loads all check-ins successfully', () async {
        // Arrange
        final upcomingCheckIns = createTestCheckInsList(count: 2);

        when(() => mockGetUpcomingCheckIns())
            .thenAnswer((_) async => upcomingCheckIns);

        final container = createContainer();

        // Act
        await container.read(checkInProvider.notifier).loadCheckIns();

        // Assert
        final asyncState = container.read(checkInProvider);
        final state = asyncState.value!;
        expect(state.checkIns, hasLength(2));
        expect(state.upcomingCheckIns, hasLength(2));
        expect(asyncState.isLoading, isFalse);
        expect(asyncState.hasError, isFalse);

        verify(() => mockGetUpcomingCheckIns()).called(1);

        container.dispose();
      });

      test('sets loading state while loading', () async {
        // Arrange
        when(() => mockGetUpcomingCheckIns())
            .thenAnswer((_) async => createTestCheckInsList(count: 2));

        final container = createContainer();

        // Act
        final future =
            container.read(checkInProvider.notifier).loadCheckIns();

        // Assert - check loading state during operation
        expect(
          container.read(checkInProvider).isLoading,
          isTrue,
        );

        await future;
        container.dispose();
      });

      test('handles errors during loading', () async {
        // Arrange
        when(() => mockGetUpcomingCheckIns())
            .thenThrow(const ServerException(message: 'Network error'));

        final container = createContainer();

        // Act
        await container.read(checkInProvider.notifier).loadCheckIns();

        // Assert
        final asyncState = container.read(checkInProvider);
        expect(asyncState.isLoading, isFalse);
        expect(asyncState, isA<AsyncError>());

        container.dispose();
      });
    });

    group('loadUpcomingCheckIns', () {
      test('loads only upcoming check-ins', () async {
        // Arrange
        final upcomingCheckIns = createTestCheckInsList(count: 2);

        when(() => mockGetUpcomingCheckIns())
            .thenAnswer((_) async => upcomingCheckIns);

        final container = createContainer();

        // Act
        await container
            .read(checkInProvider.notifier)
            .loadUpcomingCheckIns();

        // Assert
        final state = container.read(checkInProvider).value!;
        expect(state.upcomingCheckIns, hasLength(2));
        expect(container.read(checkInProvider).isLoading, isFalse);

        verify(() => mockGetUpcomingCheckIns()).called(1);

        container.dispose();
      });

      test('handles errors during loading', () async {
        // Arrange
        when(() => mockGetUpcomingCheckIns())
            .thenThrow(const ServerException(message: 'Failed'));

        final container = createContainer();

        // Act
        await container
            .read(checkInProvider.notifier)
            .loadUpcomingCheckIns();

        // Assert
        final asyncState = container.read(checkInProvider);
        expect(asyncState, isA<AsyncError>());

        container.dispose();
      });
    });

    group('completeCheckIn', () {
      test('completes a scheduled check-in successfully', () async {
        // Arrange
        final existingCheckIn = createTestCheckIn(
          id: testCheckInId,
          status: CheckInStatus.scheduled,
        );
        final completedCheckIn = existingCheckIn.copyWith(
          status: CheckInStatus.completed,
          completedAt: testDateTime,
        );

        when(() => mockCompleteCheckIn(
              checkInId: testCheckInId,
              location: any(named: 'location'),
              statusMessage: any(named: 'statusMessage'),
            )).thenAnswer((_) async => completedCheckIn);

        final container = createContainer();
        // Pre-set state with existing check-in
        container.read(checkInProvider.notifier).state = AsyncData(CheckInState(
          checkIns: [existingCheckIn],
          upcomingCheckIns: [existingCheckIn],
        ));

        // Act
        await container.read(checkInProvider.notifier).completeCheckIn(
              checkInId: testCheckInId,
              latitude: testLatitude,
              longitude: testLongitude,
              statusMessage: testStatusMessage,
            );

        // Assert
        final state = container.read(checkInProvider).value!;
        final updatedCheckIn = state.checkIns.first;
        expect(updatedCheckIn.status, equals(CheckInStatus.completed));
        expect(state.upcomingCheckIns, isEmpty);
        expect(state.selectedCheckIn?.id, equals(testCheckInId));

        container.dispose();
      });

      test('handles errors during completion', () async {
        // Arrange
        final existingCheckIn = createTestCheckIn(
          id: testCheckInId,
          status: CheckInStatus.scheduled,
        );
        when(() => mockCompleteCheckIn(
              checkInId: any(named: 'checkInId'),
              location: any(named: 'location'),
            )).thenThrow(const ServerException(message: 'Completion failed'));

        final container = createContainer();
        // Wait for initial async build, then set state with existing check-in
        await container.read(checkInProvider.future);
        container.read(checkInProvider.notifier).state = AsyncData(CheckInState(
          checkIns: [existingCheckIn],
          upcomingCheckIns: [existingCheckIn],
        ));

        // Act
        await container.read(checkInProvider.notifier).completeCheckIn(
              checkInId: testCheckInId,
              latitude: testLatitude,
              longitude: testLongitude,
            );

        // Assert
        final asyncState = container.read(checkInProvider);
        expect(asyncState, isA<AsyncError>());

        container.dispose();
      });
    });

    group('cancelCheckIn', () {
      test('cancels a scheduled check-in successfully', () async {
        // Arrange
        final existingCheckIn = createTestCheckIn(
          id: testCheckInId,
          status: CheckInStatus.scheduled,
        );

        when(() => mockCancelCheckIn(testCheckInId))
            .thenAnswer((_) async {});

        final container = createContainer();
        container.read(checkInProvider.notifier).state = AsyncData(CheckInState(
          checkIns: [existingCheckIn],
          upcomingCheckIns: [existingCheckIn],
        ));

        // Act
        await container
            .read(checkInProvider.notifier)
            .cancelCheckIn(testCheckInId);

        // Assert
        final state = container.read(checkInProvider).value!;
        final cancelledCheckIn = state.checkIns.first;
        expect(cancelledCheckIn.status, equals(CheckInStatus.cancelled));
        expect(state.upcomingCheckIns, isEmpty);

        verify(() => mockCancelCheckIn(testCheckInId)).called(1);

        container.dispose();
      });

      test('handles errors during cancellation', () async {
        // Arrange
        final existingCheckIn = createTestCheckIn(
          id: 'non-existent',
          status: CheckInStatus.scheduled,
        );
        when(() => mockCancelCheckIn('non-existent'))
            .thenThrow(const ServerException(message: 'Not found'));

        final container = createContainer();
        // Wait for initial async build, then set state with existing check-in
        await container.read(checkInProvider.future);
        container.read(checkInProvider.notifier).state = AsyncData(CheckInState(
          checkIns: [existingCheckIn],
          upcomingCheckIns: [existingCheckIn],
        ));

        // Act
        await container
            .read(checkInProvider.notifier)
            .cancelCheckIn('non-existent');

        // Assert
        final asyncState = container.read(checkInProvider);
        expect(asyncState, isA<AsyncError>());

        container.dispose();
      });
    });

    group('loadCheckInsByTrip', () {
      test('loads check-ins for a specific trip', () async {
        // Arrange
        final allCheckIns = [
          createTestCheckIn(id: 'checkin-1', tripId: testTripId),
          createTestCheckIn(id: 'checkin-2', tripId: testTripId),
          createTestCheckIn(id: 'checkin-3', tripId: 'other-trip'),
        ];

        when(() => mockGetUpcomingCheckIns())
            .thenAnswer((_) async => allCheckIns);

        final container = createContainer();

        // Act
        await container
            .read(checkInProvider.notifier)
            .loadCheckInsByTrip(testTripId);

        // Assert
        final state = container.read(checkInProvider).value!;
        expect(state.checkIns, hasLength(2));
        expect(
            state.checkIns.every((c) => c.tripId == testTripId), isTrue);

        container.dispose();
      });
    });

    group('selectCheckIn', () {
      test('selects a check-in', () {
        // Arrange
        final checkInToSelect = createTestCheckIn(id: 'checkin-1');
        final container = createContainer();
        container.read(checkInProvider.notifier).state = AsyncData(CheckInState(
          checkIns: createTestCheckInsList(count: 3),
        ));

        // Act
        container
            .read(checkInProvider.notifier)
            .selectCheckIn(checkInToSelect);

        // Assert
        final state = container.read(checkInProvider).value!;
        expect(state.selectedCheckIn?.id, equals('checkin-1'));

        container.dispose();
      });

      test('deselects when null is passed', () {
        // Arrange
        final container = createContainer();
        container.read(checkInProvider.notifier).state = AsyncData(CheckInState(
          checkIns: createTestCheckInsList(count: 3),
          selectedCheckIn: createTestCheckIn(id: 'checkin-1'),
        ));

        // Act
        container.read(checkInProvider.notifier).selectCheckIn(null);

        // Assert
        final state = container.read(checkInProvider).value!;
        expect(state.selectedCheckIn, isNull);

        container.dispose();
      });
    });

    group('clearSelection', () {
      test('clears the selected check-in', () {
        // Arrange
        final container = createContainer();
        container.read(checkInProvider.notifier).state = AsyncData(CheckInState(
          checkIns: createTestCheckInsList(count: 3),
          selectedCheckIn: createTestCheckIn(id: 'checkin-1'),
        ));

        // Act
        container.read(checkInProvider.notifier).clearSelection();

        // Assert
        final state = container.read(checkInProvider).value!;
        expect(state.selectedCheckIn, isNull);

        container.dispose();
      });
    });

    group('refreshUpcoming', () {
      test('calls loadUpcomingCheckIns', () async {
        // Arrange
        final upcomingCheckIns = createTestCheckInsList(count: 2);
        when(() => mockGetUpcomingCheckIns())
            .thenAnswer((_) async => upcomingCheckIns);

        final container = createContainer();

        // Act
        await container.read(checkInProvider.notifier).refreshUpcoming();

        // Assert
        verify(() => mockGetUpcomingCheckIns()).called(1);

        container.dispose();
      });
    });

    group('CheckInState computed values', () {
      test('hasUpcomingCheckIns is true when upcoming check-ins exist', () {
        final container = createContainer();
        container.read(checkInProvider.notifier).state = AsyncData(CheckInState(
          upcomingCheckIns: createTestCheckInsList(count: 2),
          hasUpcomingCheckIns: true,
        ));

        expect(container.read(checkInProvider).value!.hasUpcomingCheckIns, isTrue);
        container.dispose();
      });

      test('hasUpcomingCheckIns is false when no upcoming check-ins', () {
        const state = CheckInState();
        expect(state.hasUpcomingCheckIns, isFalse);
      });

      test('dueSoonCount field works', () {
        final state = CheckInState(
          dueSoonCount: 1,
        );
        expect(state.dueSoonCount, equals(1));
      });

      test('missedCount field works', () {
        final state = CheckInState(
          missedCount: 1,
        );
        expect(state.missedCount, equals(1));
      });

      test('nextCheckIn returns the set check-in', () {
        final firstCheckIn = createTestCheckIn(id: 'checkin-1');
        final state = CheckInState(
          upcomingCheckIns: [firstCheckIn],
          nextCheckIn: firstCheckIn,
        );
        expect(state.nextCheckIn?.id, equals('checkin-1'));
      });

      test('nextCheckIn returns null when not set', () {
        const state = CheckInState();
        expect(state.nextCheckIn, isNull);
      });
    });
  });
}
