import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_error.dart';
import 'package:soloadventurer/features/sync/presentation/widgets/sync_error_banner.dart';

void main() {
  group('SyncErrorBanner', () {
    testWidgets('displays error message and suggestion', (tester) async {
      final error = SyncError(
        errorId: 'test_error',
        type: SyncErrorType.network,
        severity: SyncErrorSeverity.medium,
        technicalMessage: 'Technical error',
        userMessage: 'User-friendly message',
        suggestion: 'Try again',
        occurredAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyncErrorBanner(
              error: error,
              onRetry: () {},
              onDismiss: () {},
            ),
          ),
        ),
      );

      expect(find.text('User-friendly message'), findsOneWidget);
      expect(find.text('Try again'), findsOneWidget);
    });

    testWidgets('shows retry button for retryable errors', (tester) async {
      final error = SyncError(
        errorId: 'test_error',
        type: SyncErrorType.network,
        severity: SyncErrorSeverity.medium,
        technicalMessage: 'Technical error',
        userMessage: 'User-friendly message',
        suggestion: 'Try again',
        isRetryable: true,
        occurredAt: DateTime.now(),
      );

      bool retryPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyncErrorBanner(
              error: error,
              onRetry: () => retryPressed = true,
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retryPressed, isTrue);
    });

    testWidgets('does not show retry button when showRetryButton is false',
        (tester) async {
      final error = SyncError(
        errorId: 'test_error',
        type: SyncErrorType.network,
        severity: SyncErrorSeverity.medium,
        technicalMessage: 'Technical error',
        userMessage: 'User-friendly message',
        suggestion: 'Try again',
        isRetryable: true,
        occurredAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyncErrorBanner(
              error: error,
              onRetry: () {},
              showRetryButton: false,
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('shows dismiss button when dismissible', (tester) async {
      final error = SyncError(
        errorId: 'test_error',
        type: SyncErrorType.network,
        severity: SyncErrorSeverity.medium,
        technicalMessage: 'Technical error',
        userMessage: 'User-friendly message',
        suggestion: 'Try again',
        occurredAt: DateTime.now(),
      );

      bool dismissPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyncErrorBanner(
              error: error,
              onDismiss: () => dismissPressed = true,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsOneWidget);

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(dismissPressed, isTrue);
    });

    testWidgets('does not show dismiss button when not dismissible',
        (tester) async {
      final error = SyncError(
        errorId: 'test_error',
        type: SyncErrorType.network,
        severity: SyncErrorSeverity.medium,
        technicalMessage: 'Technical error',
        userMessage: 'User-friendly message',
        suggestion: 'Try again',
        occurredAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyncErrorBanner(
              error: error,
              onDismiss: () {},
              isDismissible: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('displays retry count badge when retry count > 0',
        (tester) async {
      final error = SyncError(
        errorId: 'test_error',
        type: SyncErrorType.network,
        severity: SyncErrorSeverity.medium,
        technicalMessage: 'Technical error',
        userMessage: 'User-friendly message',
        suggestion: 'Try again',
        retryCount: 3,
        occurredAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyncErrorBanner(
              error: error,
            ),
          ),
        ),
      );

      expect(find.text('Retry 3'), findsOneWidget);
    });

    testWidgets('displays correct icon for error type', (tester) async {
      final errorTypes = [
        SyncErrorType.network,
        SyncErrorType.authentication,
        SyncErrorType.server,
      ];

      final expectedIcons = [
        Icons.wifi_off,
        Icons.lock_outline,
        Icons.cloud_off,
      ];

      for (var i = 0; i < errorTypes.length; i++) {
        final error = SyncError(
          errorId: 'test_error',
          type: errorTypes[i],
          severity: SyncErrorSeverity.medium,
          technicalMessage: 'Technical error',
          userMessage: 'User-friendly message',
          suggestion: 'Try again',
          occurredAt: DateTime.now(),
        );

        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SyncErrorBanner(error: error),
            ),
          ),
        );

        expect(find.byIcon(expectedIcons[i]), findsOneWidget);

        await tester.pumpWidget(Container());
      }
    });

    testWidgets('calls onViewDetails when Details button is tapped',
        (tester) async {
      final error = SyncError(
        errorId: 'test_error',
        type: SyncErrorType.network,
        severity: SyncErrorSeverity.medium,
        technicalMessage: 'Technical error',
        userMessage: 'User-friendly message',
        suggestion: 'Try again',
        occurredAt: DateTime.now(),
      );

      bool detailsPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyncErrorBanner(
              error: error,
              onViewDetails: () => detailsPressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Details'));
      await tester.pump();

      expect(detailsPressed, isTrue);
    });
  });

  group('MultipleSyncErrorsBanner', () {
    testWidgets('displays error count', (tester) async {
      final errors = List.generate(
        3,
        (i) => SyncError(
          errorId: 'error_$i',
          type: SyncErrorType.network,
          severity: SyncErrorSeverity.medium,
          technicalMessage: 'Technical error',
          userMessage: 'User-friendly message',
          suggestion: 'Try again',
          occurredAt: DateTime.now(),
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultipleSyncErrorsBanner(
              errors: errors,
              onViewAll: () {},
            ),
          ),
        ),
      );

      expect(find.text('3 Sync Errors'), findsOneWidget);
    });

    testWidgets('displays singular form for single error', (tester) async {
      final errors = [
        SyncError(
          errorId: 'error_1',
          type: SyncErrorType.network,
          severity: SyncErrorSeverity.medium,
          technicalMessage: 'Technical error',
          userMessage: 'User-friendly message',
          suggestion: 'Try again',
          occurredAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultipleSyncErrorsBanner(
              errors: errors,
              onViewAll: () {},
            ),
          ),
        ),
      );

      expect(find.text('1 Sync Error'), findsOneWidget);
    });

    testWidgets('calls onViewAll when View All button is tapped',
        (tester) async {
      final errors = [
        SyncError(
          errorId: 'error_1',
          type: SyncErrorType.network,
          severity: SyncErrorSeverity.medium,
          technicalMessage: 'Technical error',
          userMessage: 'User-friendly message',
          suggestion: 'Try again',
          occurredAt: DateTime.now(),
        ),
      ];

      bool viewAllPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultipleSyncErrorsBanner(
              errors: errors,
              onViewAll: () => viewAllPressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('View All'));
      await tester.pump();

      expect(viewAllPressed, isTrue);
    });

    testWidgets('displays severity breakdown', (tester) async {
      final errors = [
        SyncError(
          errorId: 'error_1',
          type: SyncErrorType.network,
          severity: SyncErrorSeverity.high,
          technicalMessage: 'Technical error',
          userMessage: 'User-friendly message',
          suggestion: 'Try again',
          occurredAt: DateTime.now(),
        ),
        SyncError(
          errorId: 'error_2',
          type: SyncErrorType.network,
          severity: SyncErrorSeverity.medium,
          technicalMessage: 'Technical error',
          userMessage: 'User-friendly message',
          suggestion: 'Try again',
          occurredAt: DateTime.now(),
        ),
        SyncError(
          errorId: 'error_3',
          type: SyncErrorType.network,
          severity: SyncErrorSeverity.low,
          technicalMessage: 'Technical error',
          userMessage: 'User-friendly message',
          suggestion: 'Try again',
          occurredAt: DateTime.now(),
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultipleSyncErrorsBanner(
              errors: errors,
              onViewAll: () {},
            ),
          ),
        ),
      );

      expect(find.text('1 high, 1 medium, 1 low severity'), findsOneWidget);
    });

    testWidgets('dismisses when onDismiss is called', (tester) async {
      final errors = [
        SyncError(
          errorId: 'error_1',
          type: SyncErrorType.network,
          severity: SyncErrorSeverity.medium,
          technicalMessage: 'Technical error',
          userMessage: 'User-friendly message',
          suggestion: 'Try again',
          occurredAt: DateTime.now(),
        ),
      ];

      bool dismissPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MultipleSyncErrorsBanner(
              errors: errors,
              onViewAll: () {},
              onDismiss: () => dismissPressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.close));
      await tester.pump();

      expect(dismissPressed, isTrue);
    });
  });
}
