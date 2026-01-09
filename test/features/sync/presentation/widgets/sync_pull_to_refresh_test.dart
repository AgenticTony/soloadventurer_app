import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/sync/presentation/notifiers/manual_sync_notifier.dart';
import 'package:soloadventurer/features/sync/presentation/providers/sync_providers.dart';
import 'package:soloadventurer/features/sync/presentation/widgets/sync_pull_to_refresh.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'sync_pull_to_refresh_test.mocks.dart';

@GenerateMocks([
  ManualSyncNotifier,
])
void main() {
  group('SyncPullToRefresh', () {
    late MockManualSyncNotifier mockNotifier;

    setUp(() {
      mockNotifier = MockManualSyncNotifier();
    });

    Widget createWidgetUnderTest({Widget? child}) {
      return ProviderScope(
        overrides: [
          manualSyncNotifierProvider.overrideWith((ref) => mockNotifier),
        ],
        child: MaterialApp(
          home: Scaffold(
            body: SyncPullToRefresh(
              child: child ?? const ListView(children: [Text('Content')]),
            ),
          ),
        ),
      );
    }

    testWidgets('wraps child widget correctly', (tester) async {
      // Arrange
      when(mockNotifier.state).thenReturn(ManualSyncState.initial());
      when(mockNotifier.stream).thenAnswer((_) => Stream.value(ManualSyncState.initial()));

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Content'), findsOneWidget);
      expect(find.byType(RefreshIndicator), findsOneWidget);
    });

    testWidgets('triggers sync on pull down', (tester) async {
      // Arrange
      when(mockNotifier.state).thenReturn(ManualSyncState.initial());
      when(mockNotifier.stream).thenAnswer((_) => Stream.value(ManualSyncState.initial()));
      when(mockNotifier.triggerSync()).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Pull down to trigger refresh
      await tester.drag(find.text('Content'), const Offset(0, 300));
      await tester.pump();

      // Assert
      verify(mockNotifier.triggerSync()).called(1);
    });

    testWidgets('shows success snackbar after successful sync', (tester) async {
      // Arrange
      final initialState = ManualSyncState.syncing(startedAt: DateTime.now());
      final successState = ManualSyncState.success(
        successCount: 5,
        failureCount: 0,
        completedAt: DateTime.now(),
      );

      when(mockNotifier.state).thenReturn(initialState);
      when(mockNotifier.stream).thenAnswer(
        (_) => Stream.fromIterable([initialState, successState]),
      );
      when(mockNotifier.triggerSync()).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Trigger sync
      await tester.drag(find.text('Content'), const Offset(0, 300));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Wait for sync to complete
      when(mockNotifier.state).thenReturn(successState);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Assert - snackbar should be shown
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Successfully synced'), findsOneWidget);
    });

    testWidgets('shows error snackbar after failed sync', (tester) async {
      // Arrange
      final initialState = ManualSyncState.syncing(startedAt: DateTime.now());
      final errorState = ManualSyncState.failure(
        errorMessage: 'Network error',
        completedAt: DateTime.now(),
      );

      when(mockNotifier.state).thenReturn(initialState);
      when(mockNotifier.stream).thenAnswer(
        (_) => Stream.fromIterable([initialState, errorState]),
      );
      when(mockNotifier.triggerSync()).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Trigger sync
      await tester.drag(find.text('Content'), const Offset(0, 300));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Wait for sync to complete
      when(mockNotifier.state).thenReturn(errorState);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Assert - snackbar should be shown
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.textContaining('Sync failed'), findsOneWidget);
    });

    testWidgets('does not show notifications when showNotifications is false', (tester) async {
      // Arrange
      final initialState = ManualSyncState.syncing(startedAt: DateTime.now());
      final successState = ManualSyncState.success(
        successCount: 5,
        failureCount: 0,
        completedAt: DateTime.now(),
      );

      when(mockNotifier.state).thenReturn(initialState);
      when(mockNotifier.stream).thenAnswer(
        (_) => Stream.fromIterable([initialState, successState]),
      );
      when(mockNotifier.triggerSync()).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            manualSyncNotifierProvider.overrideWith((ref) => mockNotifier),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SyncPullToRefresh(
                showNotifications: false,
                child: ListView(children: [Text('Content')]),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Trigger sync
      await tester.drag(find.text('Content'), const Offset(0, 300));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Wait for sync to complete
      when(mockNotifier.state).thenReturn(successState);
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 500));

      // Assert - no snackbar should be shown
      expect(find.byType(SnackBar), findsNothing);
    });

    testWidgets('triggers sync on mount when triggerOnMount is true', (tester) async {
      // Arrange
      when(mockNotifier.state).thenReturn(ManualSyncState.initial());
      when(mockNotifier.stream).thenAnswer((_) => Stream.value(ManualSyncState.initial()));
      when(mockNotifier.triggerSync()).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            manualSyncNotifierProvider.overrideWith((ref) => mockNotifier),
          ],
          child: const MaterialApp(
            home: Scaffold(
              body: SyncPullToRefresh(
                triggerOnMount: true,
                child: ListView(children: [Text('Content')]),
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));

      // Assert
      verify(mockNotifier.triggerSync()).called(1);
    });

    testWidgets('prevents multiple simultaneous syncs', (tester) async {
      // Arrange
      when(mockNotifier.state).thenReturn(
        ManualSyncState.syncing(startedAt: DateTime.now()),
      );
      when(mockNotifier.stream).thenAnswer(
        (_) => Stream.value(
          ManualSyncState.syncing(startedAt: DateTime.now()),
        ),
      );
      when(mockNotifier.triggerSync()).thenAnswer((_) async {});

      // Act
      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pumpAndSettle();

      // Try to pull down while syncing
      await tester.drag(find.text('Content'), const Offset(0, 300));
      await tester.pump();

      // Assert - should not trigger another sync
      verifyNever(mockNotifier.triggerSync());
    });
  });
}
