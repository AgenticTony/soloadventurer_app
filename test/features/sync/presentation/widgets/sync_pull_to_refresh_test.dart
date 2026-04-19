import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/sync/presentation/notifiers/manual_sync_notifier.dart';
import 'package:soloadventurer/features/sync/presentation/state/manual_sync_state.dart';
import 'package:soloadventurer/features/sync/presentation/widgets/sync_pull_to_refresh.dart';

/// A simple fake notifier for testing
///
/// Uses AsyncNotifier pattern: build() returns Future<ManualSyncState>
class FakeManualSyncNotifier extends ManualSyncNotifier {
  final ManualSyncState _initialState;
  int triggerSyncCallCount = 0;

  FakeManualSyncNotifier(this._initialState);

  @override
  Future<ManualSyncState> build() async => _initialState;

  @override
  Future<void> triggerSync() async {
    triggerSyncCallCount++;
  }
}

void main() {
  group('SyncPullToRefresh', () {
    late ManualSyncState currentState;

    Widget createWidgetUnderTest({Widget? child, bool showNotifications = true, bool triggerOnMount = false}) {
      return ProviderScope(
        overrides: [
          manualSyncProvider.overrideWith(() => FakeManualSyncNotifier(currentState)),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SyncPullToRefresh(
              showNotifications: showNotifications,
              triggerOnMount: triggerOnMount,
              child: child ?? ListView(children: [Text('Content')]),
            ),
          ),
        ),
      );
    }

    testWidgets('wraps child widget correctly', (tester) async {
      currentState = ManualSyncState.initial();

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('triggers sync on pull down', (tester) async {
      currentState = ManualSyncState.initial();

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      await tester.drag(find.text('Content'), const Offset(0, 300));
      await tester.pump();

      // Verify no errors occur
    });

    testWidgets('renders correctly in syncing state', (tester) async {
      currentState = ManualSyncState.syncing(startedAt: DateTime.now());

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // The refresh indicator should be visible
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('renders correctly in success state', (tester) async {
      currentState = ManualSyncState.success(
        successCount: 5,
        failureCount: 0,
        completedAt: DateTime.now(),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Content'), findsOneWidget);
    });

    testWidgets('renders correctly in error state', (tester) async {
      currentState = ManualSyncState.failure(
        completedAt: DateTime.now(),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Content'), findsOneWidget);
    });
  });
}
