import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_error.dart';
import 'package:soloadventurer/features/sync/presentation/widgets/sync_error_card.dart';

void main() {
  group('SyncErrorCard', () {
    testWidgets('displays error information', (tester) async {
      final error = SyncError(
        errorId: 'test_error',
        type: SyncErrorType.network,
        severity: SyncErrorSeverity.medium,
        technicalMessage: 'Technical error message',
        userMessage: 'User-friendly message',
        suggestion: 'Try again later',
        occurredAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyncErrorCard(error: error),
          ),
        ),
      );

      expect(find.text('User-friendly message'), findsOneWidget);
      expect(find.text('MEDIUM'), findsOneWidget);
      expect(find.text('Network Error'), findsOneWidget);
    });

    testWidgets('is not expanded by default', (tester) async {
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
            body: SyncErrorCard(error: error),
          ),
        ),
      );

      // Technical details should not be visible when not expanded
      expect(find.text('Technical error'), findsNothing);
    });

    testWidgets('can be expanded by tapping', (tester) async {
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
            body: SyncErrorCard(error: error),
          ),
        ),
      );

      // Tap to expand
      await tester.tap(find.byType(InkWell));
      await tester.pumpAndSettle();

      // Technical details should now be visible
      expect(find.text('Technical error'), findsOneWidget);
    });

    testWidgets('can be initially expanded', (tester) async {
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
            body: SyncErrorCard(
              error: error,
              initiallyExpanded: true,
            ),
          ),
        ),
      );

      // Technical details should be visible when initially expanded
      expect(find.text('Technical error'), findsOneWidget);
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
            body: SyncErrorCard(
              error: error,
              initiallyExpanded: true,
              onRetry: () => retryPressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Retry'));
      await tester.pump();

      expect(retryPressed, isTrue);
    });

    testWidgets('does not show retry button for non-retryable errors',
        (tester) async {
      final error = SyncError(
        errorId: 'test_error',
        type: SyncErrorType.validation,
        severity: SyncErrorSeverity.high,
        technicalMessage: 'Technical error',
        userMessage: 'User-friendly message',
        suggestion: 'Fix the data',
        isRetryable: false,
        occurredAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyncErrorCard(
              error: error,
              initiallyExpanded: true,
            ),
          ),
        ),
      );

      expect(find.text('Retry'), findsNothing);
    });

    testWidgets('displays suggestion when provided', (tester) async {
      final error = SyncError(
        errorId: 'test_error',
        type: SyncErrorType.network,
        severity: SyncErrorSeverity.medium,
        technicalMessage: 'Technical error',
        userMessage: 'User-friendly message',
        suggestion: 'Check your internet connection',
        occurredAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyncErrorCard(
              error: error,
              initiallyExpanded: true,
            ),
          ),
        ),
      );

      expect(find.text('Check your internet connection'), findsOneWidget);
      expect(find.byIcon(Icons.lightbulb_outline), findsOneWidget);
    });

    testWidgets('displays error code when available', (tester) async {
      final error = SyncError(
        errorId: 'test_error',
        type: SyncErrorType.validation,
        severity: SyncErrorSeverity.high,
        code: 'INVALID_DATA',
        technicalMessage: 'Technical error',
        userMessage: 'User-friendly message',
        suggestion: 'Fix the data',
        occurredAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyncErrorCard(
              error: error,
              initiallyExpanded: true,
            ),
          ),
        ),
      );

      expect(find.text('INVALID_DATA'), findsOneWidget);
    });

    testWidgets('displays HTTP status code when available', (tester) async {
      final error = SyncError(
        errorId: 'test_error',
        type: SyncErrorType.server,
        severity: SyncErrorSeverity.medium,
        statusCode: 500,
        technicalMessage: 'Technical error',
        userMessage: 'User-friendly message',
        suggestion: 'Try again',
        occurredAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyncErrorCard(
              error: error,
              initiallyExpanded: true,
            ),
          ),
        ),
      );

      expect(find.text('500'), findsOneWidget);
    });

    testWidgets('displays entity context when available', (tester) async {
      final error = SyncError(
        errorId: 'test_error',
        type: SyncErrorType.network,
        severity: SyncErrorSeverity.medium,
        entityType: 'trip',
        entityId: 'trip_123',
        operationType: 'sync',
        technicalMessage: 'Technical error',
        userMessage: 'User-friendly message',
        suggestion: 'Try again',
        occurredAt: DateTime.now(),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyncErrorCard(
              error: error,
              initiallyExpanded: true,
            ),
          ),
        ),
      );

      expect(find.text('trip'), findsOneWidget);
      expect(find.text('trip_123'), findsOneWidget);
      expect(find.text('sync'), findsOneWidget);
    });

    testWidgets('shows copy details button', (tester) async {
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
            body: SyncErrorCard(
              error: error,
              initiallyExpanded: true,
            ),
          ),
        ),
      );

      expect(find.text('Copy Details'), findsOneWidget);
    });

    testWidgets('shows help button when onHelp is provided', (tester) async {
      final error = SyncError(
        errorId: 'test_error',
        type: SyncErrorType.network,
        severity: SyncErrorSeverity.medium,
        technicalMessage: 'Technical error',
        userMessage: 'User-friendly message',
        suggestion: 'Try again',
        occurredAt: DateTime.now(),
      );

      bool helpPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyncErrorCard(
              error: error,
              initiallyExpanded: true,
              onHelp: () => helpPressed = true,
            ),
          ),
        ),
      );

      await tester.tap(find.text('Get Help'));
      await tester.pump();

      expect(helpPressed, isTrue);
    });

    testWidgets('displays dismiss button when dismissible', (tester) async {
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
            body: SyncErrorCard(
              error: error,
              onDismiss: () => dismissPressed = true,
            ),
          ),
        ),
      );

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
            body: SyncErrorCard(
              error: error,
              isDismissible: false,
            ),
          ),
        ),
      );

      expect(find.byIcon(Icons.close), findsNothing);
    });

    testWidgets('displays additional details when available', (tester) async {
      final error = SyncError(
        errorId: 'test_error',
        type: SyncErrorType.network,
        severity: SyncErrorSeverity.medium,
        technicalMessage: 'Technical error',
        userMessage: 'User-friendly message',
        suggestion: 'Try again',
        occurredAt: DateTime.now(),
        details: const {'key1': 'value1', 'key2': 'value2'},
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SyncErrorCard(
              error: error,
              initiallyExpanded: true,
            ),
          ),
        ),
      );

      expect(find.text('Additional Details:'), findsOneWidget);
      expect(
        find.textContaining('key1'),
        findsOneWidget,
      );
    });
  });
}
