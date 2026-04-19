import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_alert.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_status.dart';
import 'package:soloadventurer/features/safety/presentation/state/safety_state.dart';
import 'package:soloadventurer/features/safety/presentation/screens/emergency_sos_screen.dart';
import 'package:soloadventurer/features/safety/presentation/providers/safety_provider.dart';
import 'package:soloadventurer/features/safety/presentation/providers/safety_providers.dart';
import 'package:soloadventurer/core/services/location_service.dart' as core;

import '../../../../helpers/safety_test_helpers.dart';

class MockLocationService extends Mock implements core.LocationService {}

/// A test notifier that returns a fixed initial state
class TestSafetyNotifier extends Safety {
  final SafetyState _initialState;

  TestSafetyNotifier(this._initialState);

  @override
  Future<SafetyState> build() async => _initialState;
}

void main() {
  late MockLocationService mockLocationService;

  setUp(() {
    mockLocationService = MockLocationService();
  });

  Widget createWidgetUnderTest({SafetyState? safetyState}) {
    return ProviderScope(
      overrides: [
        safetyProvider
            .overrideWith(() => TestSafetyNotifier(safetyState ?? const SafetyState())),
        locationServiceProvider.overrideWithValue(mockLocationService),
      ],
      child: const MaterialApp(
        home: EmergencySOSScreen(),
      ),
    );
  }

  group('EmergencySOSScreen', () {
    testWidgets('renders emergency SOS screen', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text('Emergency SOS'), findsOneWidget);
    });

    testWidgets('shows message input field', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('renders when active alerts exist', (tester) async {
      final activeAlert = createTestSafetyAlert(
        status: SafetyAlertStatus.sent,
      );
      final state = SafetyState(
        activeAlerts: [activeAlert],
      );

      await tester.pumpWidget(createWidgetUnderTest(safetyState: state));
      await tester.pump();

      expect(find.text('Emergency SOS'), findsOneWidget);
    });

    testWidgets('renders when processing', (tester) async {
      const state = SafetyState(isProcessing: true);

      await tester.pumpWidget(createWidgetUnderTest(safetyState: state));
      await tester.pump();

      expect(find.text('Emergency SOS'), findsOneWidget);
    });

    testWidgets('renders when in emergency status', (tester) async {
      final state = SafetyState(
        currentStatus: createTestSafetyStatus(
          status: SafetyStatusType.emergency,
        ),
        activeAlerts: [createTestSafetyAlert()],
      );

      await tester.pumpWidget(createWidgetUnderTest(safetyState: state));
      await tester.pump();

      expect(find.text('Emergency SOS'), findsOneWidget);
    });

    testWidgets('has scaffold with correct structure', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.byType(Scaffold), findsOneWidget);
      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
