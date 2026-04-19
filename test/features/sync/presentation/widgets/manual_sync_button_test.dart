import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_operation.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_status.dart';
import 'package:soloadventurer/features/sync/domain/services/sync_service.dart';
import 'package:soloadventurer/features/sync/presentation/notifiers/manual_sync_notifier.dart';
import 'package:soloadventurer/features/sync/presentation/providers/service_providers.dart';
import 'package:soloadventurer/features/sync/presentation/state/manual_sync_state.dart';
import 'package:soloadventurer/features/sync/presentation/widgets/manual_sync_button.dart';

/// A simple fake notifier for testing
///
/// Uses AsyncNotifier pattern: build() returns Future<ManualSyncState>
class FakeManualSyncNotifier extends ManualSyncNotifier {
  final ManualSyncState _initialState;
  bool triggerSyncCalled = false;

  FakeManualSyncNotifier(this._initialState);

  @override
  Future<ManualSyncState> build() async => _initialState;

  @override
  Future<void> triggerSync() async {
    triggerSyncCalled = true;
  }
}

/// A minimal fake SyncService for widget tests
class FakeSyncService implements SyncService {
  @override
  int queueSize = 0;

  @override
  SyncOperationStatus status = SyncOperationStatus.idle;

  @override
  bool isProcessing = false;

  @override
  Stream<SyncOperationStatus> get statusStream => const Stream.empty();

  @override
  Stream<List<SyncOperation>> get queueStream => const Stream.empty();

  @override
  dynamic noSuchMethod(Invocation invocation) => null;
}

void main() {
  group('ManualSyncButton', () {
    late ManualSyncState currentState;

    Widget createWidgetUnderTest() {
      return ProviderScope(
        overrides: [
          manualSyncProvider.overrideWith(() => FakeManualSyncNotifier(currentState)),
          syncServiceProvider.overrideWithValue(FakeSyncService()),
        ],
        child: const MaterialApp(
          home: Scaffold(
            body: ManualSyncButton(),
          ),
        ),
      );
    }

    testWidgets('displays sync button with correct label when idle',
        (tester) async {
      currentState = ManualSyncState.initial();

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Sync Now'), findsOneWidget);
      expect(find.byIcon(Icons.sync), findsOneWidget);
    });

    testWidgets('shows success state after successful sync', (tester) async {
      currentState = ManualSyncState.success(
        successCount: 5,
        failureCount: 0,
        completedAt: DateTime.now(),
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Sync Again'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows error state after failed sync', (tester) async {
      currentState = ManualSyncState.failure(
        completedAt: DateTime.now(),
        failureCount: 1,
      );

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.text('Retry Sync'), findsOneWidget);
      expect(find.byIcon(Icons.error), findsOneWidget);
    });

    testWidgets('renders widget correctly', (tester) async {
      currentState = ManualSyncState.initial();

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      expect(find.byType(ManualSyncButton), findsOneWidget);
    });
  });
}
