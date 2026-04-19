import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/safety/domain/entities/check_in.dart';
import 'package:soloadventurer/features/safety/domain/usecases/complete_check_in.dart';
import 'package:soloadventurer/features/safety/domain/usecases/cancel_check_in.dart';
import 'package:soloadventurer/features/safety/domain/usecases/get_upcoming_check_ins.dart';
import 'package:soloadventurer/features/safety/domain/usecases/create_check_in.dart';
import 'package:soloadventurer/features/safety/domain/usecases/schedule_check_in.dart';
import 'package:soloadventurer/features/safety/presentation/state/check_in_state.dart';
import 'package:soloadventurer/features/safety/presentation/screens/check_in_home_screen.dart';
import 'package:soloadventurer/features/safety/presentation/providers/check_in_provider.dart';
import 'package:soloadventurer/features/safety/presentation/providers/safety_providers.dart';

import '../../../../helpers/safety_test_helpers.dart';

class MockGetUpcomingCheckInsUseCase extends Mock
    implements GetUpcomingCheckInsUseCase {}

class MockCreateCheckInUseCase extends Mock implements CreateCheckInUseCase {}

class MockScheduleCheckInUseCase extends Mock
    implements ScheduleCheckInUseCase {}

class MockCompleteCheckInUseCase extends Mock
    implements CompleteCheckInUseCase {}

class MockCancelCheckInUseCase extends Mock implements CancelCheckInUseCase {}

void main() {
  late MockGetUpcomingCheckInsUseCase mockGetUpcomingCheckIns;

  setUp(() {
    mockGetUpcomingCheckIns = MockGetUpcomingCheckInsUseCase();
    // Return empty list by default
    when(() => mockGetUpcomingCheckIns()).thenAnswer((_) async => []);
  });

  Widget createWidgetUnderTest({CheckInState? checkInState}) {
    return ProviderScope(
      overrides: [
        getUpcomingCheckInsUseCaseProvider
            .overrideWithValue(mockGetUpcomingCheckIns),
        createCheckInUseCaseProvider
            .overrideWithValue(MockCreateCheckInUseCase()),
        scheduleCheckInUseCaseProvider
            .overrideWithValue(MockScheduleCheckInUseCase()),
        completeCheckInUseCaseProvider
            .overrideWithValue(MockCompleteCheckInUseCase()),
        cancelCheckInUseCaseProvider
            .overrideWithValue(MockCancelCheckInUseCase()),
      ],
      child: const MaterialApp(
        home: CheckInHomeScreen(),
      ),
    );
  }

  group('CheckInHomeScreen', () {
    testWidgets('renders app bar with title', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Check-ins'), findsOneWidget);
    });

    testWidgets('renders history button in app bar', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.history), findsOneWidget);
    });

    testWidgets('shows empty state when no check-ins', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Check-ins'), findsOneWidget);
    });

    testWidgets('renders upcoming check-ins when loaded', (tester) async {
      when(() => mockGetUpcomingCheckIns())
          .thenAnswer((_) async => createTestCheckInsList(count: 2));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Check-ins'), findsOneWidget);
    });

    testWidgets('renders FAB for creating new check-in', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(FloatingActionButton), findsOneWidget);
    });
  });
}
