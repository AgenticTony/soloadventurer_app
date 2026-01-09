import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/safety/domain/entities/check_in.dart';
import 'package:soloadventurer/features/safety/domain/providers/safety_usecase_providers.dart';
import 'package:soloadventurer/features/safety/domain/usecases/create_check_in.dart';
import 'package:soloadventurer/features/safety/domain/usecases/schedule_check_in.dart';
import 'package:soloadventurer/features/safety/domain/usecases/complete_check_in.dart';
import 'package:soloadventurer/features/safety/domain/usecases/cancel_check_in.dart';
import 'package:soloadventurer/features/safety/domain/usecases/get_upcoming_check_ins.dart';
import 'package:soloadventurer/features/safety/presentation/notifiers/check_in_notifier.dart';
import 'package:soloadventurer/features/safety/presentation/state/check_in_data.dart';
import 'package:soloadventurer/features/safety/presentation/providers/notifier_providers.dart'
    as notifier_providers show checkInNotifierProvider;

import '../../../../helpers/safety_test_helpers.dart';

class MockCreateCheckInUseCase extends Mock implements CreateCheckInUseCase {}

class MockScheduleCheckInUseCase extends Mock
    implements ScheduleCheckInUseCase {}

class MockCompleteCheckInUseCase extends Mock
    implements CompleteCheckInUseCase {}

class MockCancelCheckInUseCase extends Mock implements CancelCheckInUseCase {}

class MockGetUpcomingCheckInsUseCase extends Mock
    implements GetUpcomingCheckInsUseCase {}

void main() {
  late MockCreateCheckInUseCase mockCreateCheckIn;
  late MockScheduleCheckInUseCase mockScheduleCheckIn;
  late MockCompleteCheckInUseCase mockCompleteCheckIn;
  late MockCancelCheckInUseCase mockCancelCheckIn;
  late MockGetUpcomingCheckInsUseCase mockGetUpcomingCheckIns;

  setUp(() {
    mockCreateCheckIn = MockCreateCheckInUseCase();
    mockScheduleCheckIn = MockScheduleCheckInUseCase();
    mockCompleteCheckIn = MockCompleteCheckInUseCase();
    mockCancelCheckIn = MockCancelCheckInUseCase();
    mockGetUpcomingCheckIns = MockGetUpcomingCheckInsUseCase();

    // Setup default mock behaviors
    registerFallbackValue(testDateTime);
    registerFallbackValue(createTestCheckInLocation());
  });

  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        createCheckInUseCaseProvider.overrideWithValue(mockCreateCheckIn),
        scheduleCheckInUseCaseProvider.overrideWithValue(mockScheduleCheckIn),
        completeCheckInUseCaseProvider.overrideWithValue(mockCompleteCheckIn),
        cancelCheckInUseCaseProvider.overrideWithValue(mockCancelCheckIn),
        getUpcomingCheckInsUseCaseProvider
            .overrideWithValue(mockGetUpcomingCheckIns),
      ],
    );
  }

  group('CheckInNotifier', () {
    test('initial state is AsyncValue.data with empty CheckInData', () {
      final container = createContainer();

      final state = container.read(notifier_providers.checkInNotifierProvider);

      expect(state, isA<AsyncValue<CheckInData>>());
      expect(state.value, isA<CheckInData>());
      expect(state.value?.checkIns, isEmpty);
      expect(state.value?.upcomingCheckIns, isEmpty);
      expect(state.value?.selectedCheckIn, isNull);

      container.dispose();
    });

    group('loadCheckIns', () {
      test('loads all check-ins successfully', () async {
        // Arrange
        final allCheckIns = createTestCheckInsList(count: 3);
        final upcomingCheckIns = createTestCheckInsList(count: 2);

        when(() => mockGetUpcomingCheckIns.getAllCheckIns())
            .thenAnswer((_) async => allCheckIns);
        when(() => mockGetUpcomingCheckIns())
            .thenAnswer((_) async => upcomingCheckIns);

        final container = createContainer();

        // Act
        await container
            .read(notifier_providers.checkInNotifierProvider.notifier)
            .loadCheckIns();

        // Assert
        final state =
            container.read(notifier_providers.checkInNotifierProvider);
        expect(state.value?.checkIns, hasLength(3));
        expect(state.value?.upcomingCheckIns, hasLength(2));

        verify(() => mockGetUpcomingCheckIns.getAllCheckIns()).called(1);
        verify(() => mockGetUpcomingCheckIns()).called(1);

        container.dispose();
      });

      test('sets loading state while loading', () async {
        // Arrange
        when(() => mockGetUpcomingCheckIns.getAllCheckIns())
            .thenAnswer((_) async => createTestCheckInsList(count: 3));
        when(() => mockGetUpcomingCheckIns())
            .thenAnswer((_) async => createTestCheckInsList(count: 2));

        final container = createContainer();

        // Act
        final future = container
            .read(notifier_providers.checkInNotifierProvider.notifier)
            .loadCheckIns();

        // Assert
        expect(
          container.read(notifier_providers.checkInNotifierProvider),
          isA<AsyncValue<CheckInData>>()
              .having((s) => s.isLoading, 'isLoading', true),
        );

        await future;
        container.dispose();
      });

      test('handles errors during loading', () async {
        // Arrange
        when(() => mockGetUpcomingCheckIns.getAllCheckIns())
            .thenThrow(const ServerException(message: 'Network error'));

        final container = createContainer();

        // Act
        await container
            .read(notifier_providers.checkInNotifierProvider.notifier)
            .loadCheckIns();

        // Assert
        final state =
            container.read(notifier_providers.checkInNotifierProvider);
        expect(state.hasError, isTrue);

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
        container
                .read(notifier_providers.checkInNotifierProvider.notifier)
                .state =
            AsyncValue.data(
                CheckInData(checkIns: createTestCheckInsList(count: 5)));

        // Act
        await container
            .read(notifier_providers.checkInNotifierProvider.notifier)
            .loadUpcomingCheckIns();

        // Assert
        final state =
            container.read(notifier_providers.checkInNotifierProvider);
        expect(state.value?.upcomingCheckIns, hasLength(2));
        expect(state.value?.checkIns,
            hasLength(5)); // Original check-ins preserved

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
            .read(notifier_providers.checkInNotifierProvider.notifier)
            .loadUpcomingCheckIns();

        // Assert
        final state =
            container.read(notifier_providers.checkInNotifierProvider);
        expect(state.hasError, isTrue);

        container.dispose();
      });
    });

    group('createManualCheckIn', () {
      test('creates a manual check-in successfully', () async {
        // Arrange
        final testLocation = createTestCheckInLocation();
        final createdCheckIn = createTestCheckIn(
          id: 'new-checkin',
          status: CheckInStatus.completed,
          triggerType: CheckInTriggerType.manual,
        );

        when(() => mockCreateCheckIn(any()))
            .thenAnswer((_) async => createdCheckIn);

        final container = createContainer();

        // Act
        await container
            .read(notifier_providers.checkInNotifierProvider.notifier)
            .createManualCheckIn(
              userId: testUserId,
              location: testLocation,
              statusMessage: testStatusMessage,
            );

        // Assert
        final state =
            container.read(notifier_providers.checkInNotifierProvider);
        expect(state.value?.checkIns.first.id, equals('new-checkin'));
        expect(state.value?.checkIns.first.status,
            equals(CheckInStatus.completed));
        expect(state.value?.selectedCheckIn?.id, equals('new-checkin'));

        verify(() => mockCreateCheckIn(argThat(
              isA<CheckIn>()
                  .having((c) => c.status, 'status', CheckInStatus.completed)
                  .having((c) => c.triggerType, 'triggerType',
                      CheckInTriggerType.manual),
            ))).called(1);

        container.dispose();
      });

      test('adds check-in to existing list', () async {
        // Arrange
        final testLocation = createTestCheckInLocation();
        final existingCheckIns = createTestCheckInsList(count: 2);
        final createdCheckIn = createTestCheckIn(id: 'new-checkin');

        when(() => mockCreateCheckIn(any()))
            .thenAnswer((_) async => createdCheckIn);

        final container = createContainer();
        container
            .read(notifier_providers.checkInNotifierProvider.notifier)
            .state = AsyncValue.data(CheckInData(checkIns: existingCheckIns));

        // Act
        await container
            .read(notifier_providers.checkInNotifierProvider.notifier)
            .createManualCheckIn(
              userId: testUserId,
              location: testLocation,
            );

        // Assert
        final state =
            container.read(notifier_providers.checkInNotifierProvider);
        expect(state.value?.checkIns, hasLength(3)); // 2 existing + 1 new

        container.dispose();
      });

      test('handles errors during creation', () async {
        // Arrange
        final testLocation = createTestCheckInLocation();
        when(() => mockCreateCheckIn(any()))
            .thenThrow(const ServerException(message: 'Creation failed'));

        final container = createContainer();

        // Act
        await container
            .read(notifier_providers.checkInNotifierProvider.notifier)
            .createManualCheckIn(
              userId: testUserId,
              location: testLocation,
            );

        // Assert
        final state =
            container.read(notifier_providers.checkInNotifierProvider);
        expect(state.hasError, isTrue);

        container.dispose();
      });
    });

    group('scheduleCheckIn', () {
      test('schedules a new check-in successfully', () async {
        // Arrange
        final scheduledTime = testFutureDateTime;
        final deadline = scheduledTime.add(const Duration(hours: 1));
        final testLocation = createTestCheckInLocation();

        final scheduledCheckIn = createTestCheckIn(
          id: 'scheduled-checkin',
          status: CheckInStatus.scheduled,
          scheduledTime: scheduledTime,
          deadline: deadline,
        );

        when(() => mockScheduleCheckIn(
              userId: any(),
              scheduledTime: any(),
              deadline: any(named: 'deadline'),
              location: any(named: 'location'),
              statusMessage: any(named: 'statusMessage'),
              notifyContactIds: any(named: 'notifyContactIds'),
              tripId: any(named: 'tripId'),
              triggerType: any(named: 'triggerType'),
            )).thenAnswer((_) async => scheduledCheckIn);

        final container = createContainer();

        // Act
        await container
            .read(notifier_providers.checkInNotifierProvider.notifier)
            .scheduleCheckIn(
          userId: testUserId,
          scheduledTime: scheduledTime,
          deadline: deadline,
          location: testLocation,
          statusMessage: testStatusMessage,
          notifyContactIds: [testContactId],
        );

        // Assert
        final state =
            container.read(notifier_providers.checkInNotifierProvider);
        expect(state.value?.checkIns.first.id, equals('scheduled-checkin'));
        expect(state.value?.checkIns.first.status,
            equals(CheckInStatus.scheduled));
        expect(state.value?.upcomingCheckIns.first.id,
            equals('scheduled-checkin'));
        expect(state.value?.selectedCheckIn?.id, equals('scheduled-checkin'));

        verify(() => mockScheduleCheckIn(
              userId: testUserId,
              scheduledTime: scheduledTime,
              deadline: deadline,
              location: testLocation,
              statusMessage: testStatusMessage,
              notifyContactIds: [testContactId],
            )).called(1);

        container.dispose();
      });

      test('handles errors during scheduling', () async {
        // Arrange
        when(() => mockScheduleCheckIn(
              userId: any(),
              scheduledTime: any(),
            )).thenThrow(const ServerException(message: 'Scheduling failed'));

        final container = createContainer();

        // Act
        await container
            .read(notifier_providers.checkInNotifierProvider.notifier)
            .scheduleCheckIn(
              userId: testUserId,
              scheduledTime: testFutureDateTime,
            );

        // Assert
        final state =
            container.read(notifier_providers.checkInNotifierProvider);
        expect(state.hasError, isTrue);

        container.dispose();
      });
    });

    group('completeCheckIn', () {
      test('completes a scheduled check-in successfully', () async {
        // Arrange
        final testLocation = createTestCheckInLocation();
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
              location: testLocation,
              statusMessage: testStatusMessage,
            )).thenAnswer((_) async => completedCheckIn);

        final container = createContainer();
        container
            .read(notifier_providers.checkInNotifierProvider.notifier)
            .state = AsyncValue.data(CheckInData(
          checkIns: [existingCheckIn],
          upcomingCheckIns: [existingCheckIn],
        ));

        // Act
        await container
            .read(notifier_providers.checkInNotifierProvider.notifier)
            .completeCheckIn(
              checkInId: testCheckInId,
              location: testLocation,
              statusMessage: testStatusMessage,
            );

        // Assert
        final state =
            container.read(notifier_providers.checkInNotifierProvider);
        final updatedCheckIn = state.value?.checkIns.first;
        expect(updatedCheckIn?.status, equals(CheckInStatus.completed));
        expect(updatedCheckIn?.completedAt, isNotNull);
        expect(state.value?.upcomingCheckIns, isEmpty); // Removed from upcoming
        expect(state.value?.selectedCheckIn?.id, equals(testCheckInId));

        verify(() => mockCompleteCheckIn(
              checkInId: testCheckInId,
              location: testLocation,
              statusMessage: testStatusMessage,
            )).called(1);

        container.dispose();
      });

      test('handles errors during completion', () async {
        // Arrange
        final testLocation = createTestCheckInLocation();
        when(() => mockCompleteCheckIn(
              checkInId: any(),
              location: any(),
            )).thenThrow(const ServerException(message: 'Completion failed'));

        final container = createContainer();

        // Act
        await container
            .read(notifier_providers.checkInNotifierProvider.notifier)
            .completeCheckIn(
              checkInId: testCheckInId,
              location: testLocation,
            );

        // Assert
        final state =
            container.read(notifier_providers.checkInNotifierProvider);
        expect(state.hasError, isTrue);

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

        when(() => mockCancelCheckIn(testCheckInId)).thenAnswer((_) async {});

        final container = createContainer();
        container
            .read(notifier_providers.checkInNotifierProvider.notifier)
            .state = AsyncValue.data(CheckInData(
          checkIns: [existingCheckIn],
          upcomingCheckIns: [existingCheckIn],
        ));

        // Act
        await container
            .read(notifier_providers.checkInNotifierProvider.notifier)
            .cancelCheckIn(testCheckInId);

        // Assert
        final state =
            container.read(notifier_providers.checkInNotifierProvider);
        final cancelledCheckIn = state.value?.checkIns.first;
        expect(cancelledCheckIn?.status, equals(CheckInStatus.cancelled));
        expect(state.value?.upcomingCheckIns, isEmpty); // Removed from upcoming
        expect(state.value?.selectedCheckIn?.id, equals(testCheckInId));

        verify(() => mockCancelCheckIn(testCheckInId)).called(1);

        container.dispose();
      });

      test('throws when cancelling non-existent check-in', () async {
        // Arrange
        when(() => mockCancelCheckIn('non-existent'))
            .thenThrow(const ServerException(message: 'Not found'));

        final container = createContainer();

        // Act & Assert
        await container
            .read(notifier_providers.checkInNotifierProvider.notifier)
            .cancelCheckIn('non-existent');

        final state =
            container.read(notifier_providers.checkInNotifierProvider);
        expect(state.hasError, isTrue);

        container.dispose();
      });
    });

    group('loadCheckInsByTrip', () {
      test('loads check-ins for a specific trip', () async {
        // Arrange
        final tripCheckIns = [
          createTestCheckIn(id: 'checkin-1', tripId: testTripId),
          createTestCheckIn(id: 'checkin-2', tripId: testTripId),
        ];

        when(() => mockGetUpcomingCheckIns.getCheckInsByTrip(testTripId))
            .thenAnswer((_) async => tripCheckIns);

        final container = createContainer();

        // Act
        await container
            .read(notifier_providers.checkInNotifierProvider.notifier)
            .loadCheckInsByTrip(testTripId);

        // Assert
        final state =
            container.read(notifier_providers.checkInNotifierProvider);
        expect(state.value?.checkIns, hasLength(2));
        expect(
            state.value?.checkIns.every((c) => c.tripId == testTripId), isTrue);

        verify(() => mockGetUpcomingCheckIns.getCheckInsByTrip(testTripId))
            .called(1);

        container.dispose();
      });

      test('handles errors during trip loading', () async {
        // Arrange
        when(() => mockGetUpcomingCheckIns.getCheckInsByTrip(testTripId))
            .thenThrow(const ServerException(message: 'Trip not found'));

        final container = createContainer();

        // Act
        await container
            .read(notifier_providers.checkInNotifierProvider.notifier)
            .loadCheckInsByTrip(testTripId);

        // Assert
        final state =
            container.read(notifier_providers.checkInNotifierProvider);
        expect(state.hasError, isTrue);

        container.dispose();
      });
    });

    group('selectCheckIn', () {
      test('selects a check-in', () {
        // Arrange
        final checkInToSelect = createTestCheckIn(id: 'checkin-1');
        final container = createContainer();
        container
                .read(notifier_providers.checkInNotifierProvider.notifier)
                .state =
            AsyncValue.data(
                CheckInData(checkIns: createTestCheckInsList(count: 3)));

        // Act
        container
            .read(notifier_providers.checkInNotifierProvider.notifier)
            .selectCheckIn(checkInToSelect);

        // Assert
        final state =
            container.read(notifier_providers.checkInNotifierProvider);
        expect(state.value?.selectedCheckIn?.id, equals('checkin-1'));

        container.dispose();
      });

      test('deselects when null is passed', () {
        // Arrange
        final container = createContainer();
        container
            .read(notifier_providers.checkInNotifierProvider.notifier)
            .state = AsyncValue.data(CheckInData(
          checkIns: createTestCheckInsList(count: 3),
          selectedCheckIn: createTestCheckIn(id: 'checkin-1'),
        ));

        // Act
        container
            .read(notifier_providers.checkInNotifierProvider.notifier)
            .selectCheckIn(null);

        // Assert
        final state =
            container.read(notifier_providers.checkInNotifierProvider);
        expect(state.value?.selectedCheckIn, isNull);

        container.dispose();
      });

      test('does nothing when state has no data', () {
        // Arrange
        final container = createContainer();
        container
            .read(notifier_providers.checkInNotifierProvider.notifier)
            .state = const AsyncValue.data(CheckInData());

        // Act
        container
            .read(notifier_providers.checkInNotifierProvider.notifier)
            .selectCheckIn(createTestCheckIn());

        // Assert
        final state =
            container.read(notifier_providers.checkInNotifierProvider);
        expect(state.value?.selectedCheckIn, isNull);

        container.dispose();
      });
    });

    group('clearSelection', () {
      test('clears the selected check-in', () {
        // Arrange
        final container = createContainer();
        container
            .read(notifier_providers.checkInNotifierProvider.notifier)
            .state = AsyncValue.data(CheckInData(
          checkIns: createTestCheckInsList(count: 3),
          selectedCheckIn: createTestCheckIn(id: 'checkin-1'),
        ));

        // Act
        container
            .read(notifier_providers.checkInNotifierProvider.notifier)
            .clearSelection();

        // Assert
        final state =
            container.read(notifier_providers.checkInNotifierProvider);
        expect(state.value?.selectedCheckIn, isNull);

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
        await container
            .read(notifier_providers.checkInNotifierProvider.notifier)
            .refreshUpcoming();

        // Assert
        verify(() => mockGetUpcomingCheckIns()).called(1);

        container.dispose();
      });
    });

    group('CheckInData getters', () {
      test('hasUpcomingCheckIns returns true when upcoming check-ins exist',
          () {
        final data = CheckInData(
          upcomingCheckIns: createTestCheckInsList(count: 2),
        );

        expect(data.hasUpcomingCheckIns, isTrue);
      });

      test('hasUpcomingCheckIns returns false when no upcoming check-ins', () {
        const data = CheckInData();

        expect(data.hasUpcomingCheckIns, isFalse);
      });

      test('dueSoonCount returns count of check-ins due within an hour', () {
        final now = DateTime.now();
        final dueSoonCheckIn = createTestCheckIn(
          id: 'checkin-1',
          deadline: now.add(const Duration(minutes: 30)),
        );
        final laterCheckIn = createTestCheckIn(
          id: 'checkin-2',
          deadline: now.add(const Duration(hours: 2)),
        );

        final data = CheckInData(
          upcomingCheckIns: [dueSoonCheckIn, laterCheckIn],
        );

        expect(data.dueSoonCount, equals(1));
      });

      test('missedCount returns count of missed check-ins', () {
        final missedCheckIn = createTestCheckIn(
          id: 'checkin-1',
          status: CheckInStatus.missed,
        );
        final completedCheckIn = createTestCheckIn(
          id: 'checkin-2',
          status: CheckInStatus.completed,
        );

        final data = CheckInData(
          checkIns: [missedCheckIn, completedCheckIn],
        );

        expect(data.missedCount, equals(1));
      });

      test('nextCheckIn returns the earliest upcoming check-in', () {
        final now = DateTime.now();
        final firstCheckIn = createTestCheckIn(
          id: 'checkin-1',
          scheduledTime: now.add(const Duration(minutes: 30)),
        );
        final secondCheckIn = createTestCheckIn(
          id: 'checkin-2',
          scheduledTime: now.add(const Duration(hours: 1)),
        );

        final data = CheckInData(
          upcomingCheckIns: [secondCheckIn, firstCheckIn],
        );

        expect(data.nextCheckIn?.id, equals('checkin-1'));
      });

      test('nextCheckIn returns null when no upcoming check-ins', () {
        const data = CheckInData();

        expect(data.nextCheckIn, isNull);
      });

      test('nextCheckIn sorts by scheduledTime then deadline', () {
        final now = DateTime.now();
        final checkIn1 = createTestCheckIn(
          id: 'checkin-1',
          scheduledTime: null,
          deadline: now.add(const Duration(hours: 2)),
        );
        final checkIn2 = createTestCheckIn(
          id: 'checkin-2',
          scheduledTime: now.add(const Duration(minutes: 30)),
          deadline: null,
        );
        final checkIn3 = createTestCheckIn(
          id: 'checkin-3',
          scheduledTime: null,
          deadline: now.add(const Duration(hours: 1)),
        );

        final data = CheckInData(
          upcomingCheckIns: [checkIn1, checkIn2, checkIn3],
        );

        // checkin-2 is first (has scheduledTime), then checkin-3 (earlier deadline)
        expect(data.nextCheckIn?.id, equals('checkin-2'));
      });
    });
  });
}
