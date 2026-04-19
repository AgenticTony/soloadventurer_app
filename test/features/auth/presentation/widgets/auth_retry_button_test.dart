import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/token_refresh_service.dart';
import 'package:soloadventurer/features/auth/presentation/widgets/auth_retry_button.dart';

void main() {
  group('AuthRetryButton', () {
    late MockAuthRepository mockAuthRepository;

    setUp(() {
      mockAuthRepository = MockAuthRepository();
    });

    Widget makeTestableWidget(Widget child) {
      return ProviderScope(
        overrides: const [],
        child: MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: Scaffold(body: Center(child: child)),
        ),
      );
    }

    group('Basic Rendering', () {
      testWidgets('renders retry button', (WidgetTester tester) async {
        bool retryPressed = false;

        await tester.pumpWidget(
          makeTestableWidget(
            AuthRetryButton(
              onRetry: () => retryPressed = true,
            ),
          ),
        );

        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('renders with custom button text',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            AuthRetryButton(
              onRetry: () {},
              buttonText: 'Try Again',
            ),
          ),
        );

        expect(find.text('Try Again'), findsOneWidget);
        expect(find.text('Retry'), findsNothing);
      });

      testWidgets('shows loading indicator when retrying',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            AuthRetryButton(
              onRetry: () {},
            ),
          ),
        );

        // Tap retry button
        await tester.tap(find.text('Retry'));
        await tester.pump();

        // Should show CircularProgressIndicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Drain pending timer
        await tester.pump(const Duration(seconds: 5));
      });
    });

    group('Retry Attempts Counter', () {
      testWidgets('displays attempt counter after first retry',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            AuthRetryButton(
              config: const AuthRetryButtonConfig(
                showAttemptCounter: true,
              ),
              onRetry: () {},
            ),
          ),
        );

        // Initially, no attempt counter
        expect(find.text('Attempt 0 of 3'), findsNothing);

        // Tap retry button
        await tester.tap(find.text('Retry'));
        await tester.pump();

        // Wait for retry to complete
        await tester.pump(const Duration(milliseconds: 500));

        // Should show attempt counter
        expect(find.text('Attempt 1 of 3'), findsOneWidget);
      });

      testWidgets('hides attempt counter when configured',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            AuthRetryButton(
              config: const AuthRetryButtonConfig(
                showAttemptCounter: false,
              ),
              onRetry: () {},
            ),
          ),
        );

        await tester.tap(find.text('Retry'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Should not show attempt counter
        expect(find.textContaining('Attempt'), findsNothing);
      });

      testWidgets('disables button after max attempts reached',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            AuthRetryButton(
              config: const AuthRetryButtonConfig(maxAttempts: 2),
              onRetry: () {},
            ),
          ),
        );

        // First retry
        await tester.tap(find.text('Retry'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Wait for countdown to finish (calculateDelay(2) = 2 seconds)
        await tester.pump(const Duration(seconds: 2));

        // Second retry
        await tester.tap(find.text('Retry'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump();

        // Should show max attempts message
        expect(find.text('Max Attempts Reached'), findsOneWidget);

        // Button should be disabled
        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton).first,
        );
        expect(button.onPressed, isNull);

        // Drain pending timers
        await tester.pump(const Duration(seconds: 5));
      });
    });

    group('Countdown Timer', () {
      testWidgets('shows countdown after retry attempt',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            AuthRetryButton(
              config: const AuthRetryButtonConfig(
                showCountdown: true,
                baseDelaySeconds: 2,
              ),
              onRetry: () {},
            ),
          ),
        );

        // Tap retry button
        await tester.tap(find.text('Retry'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Wait for countdown to start
        await tester.pump(const Duration(seconds: 1));

        // Should show countdown with remaining seconds
        expect(find.textContaining('Next retry in'), findsOneWidget);

        // Verify countdown value before advancing
        final countdownBefore = tester
            .widget<Text>(
              find.textContaining('Next retry in'),
            )
            .data;
        expect(countdownBefore, contains('second')); // countdown is showing

        // Advance and verify it decreased
        await tester.pump(const Duration(seconds: 1));
        // After 1s, countdown should either show a lower number or be gone
        final countdownFinder = find.textContaining('Next retry in');
        if (countdownFinder.evaluate().isNotEmpty) {
          final countdownAfter = tester.widget<Text>(countdownFinder).data;
          expect(countdownBefore, isNot(equals(countdownAfter)));
        }

        // Drain pending timers
        await tester.pump(const Duration(seconds: 5));
      });

      testWidgets('disables button during countdown',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            AuthRetryButton(
              config: const AuthRetryButtonConfig(
                baseDelaySeconds: 2,
              ),
              onRetry: () {},
            ),
          ),
        );

        // Trigger retry to start countdown
        await tester.tap(find.text('Retry'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(seconds: 1));

        // Button should be disabled during countdown
        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton).first,
        );
        expect(button.onPressed, isNull);

        // Wait for countdown to finish
        await tester.pump(const Duration(seconds: 2));

        // Button should be enabled again
        await tester.pump();
        final buttonAfter = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton).first,
        );
        expect(buttonAfter.onPressed, isNotNull);
      });

      testWidgets('hides countdown when configured',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            AuthRetryButton(
              config: const AuthRetryButtonConfig(
                showCountdown: false,
              ),
              onRetry: () {},
            ),
          ),
        );

        await tester.tap(find.text('Retry'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Should not show countdown
        expect(find.textContaining('Next retry in'), findsNothing);
      });

      testWidgets('shows "Ready to retry" when countdown finishes',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            AuthRetryButton(
              config: const AuthRetryButtonConfig(
                showCountdown: true,
                baseDelaySeconds: 1,
              ),
              onRetry: () {},
            ),
          ),
        );

        // Trigger retry
        await tester.tap(find.text('Retry'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Wait for countdown to finish
        await tester.pump(const Duration(seconds: 2));

        // Should show ready message
        expect(find.text('Ready to retry'), findsOneWidget);
      });
    });

    group('Exponential Backoff', () {
      testWidgets('increases delay time exponentially',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            AuthRetryButton(
              config: const AuthRetryButtonConfig(
                showCountdown: true,
                baseDelaySeconds: 1,
              ),
              onRetry: () {},
            ),
          ),
        );

        // First attempt - should have 2 second countdown (2^1)
        await tester.tap(find.text('Retry'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(seconds: 1));

        // Countdown for next attempt: calculateDelay(2) = 2 seconds
        // After pumping 1s, remaining = 1 → "Next retry in 1 second"
        expect(find.text('Next retry in 1 second'), findsOneWidget);

        // Wait for countdown to finish
        await tester.pump(const Duration(seconds: 1));

        // Second attempt
        await tester.tap(find.text('Retry'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(seconds: 1));

        // Countdown for next attempt: calculateDelay(3) = 4 seconds
        // After pumping 1s, remaining = 3 → "Next retry in 3 seconds"
        final countdown = tester
            .widget<Text>(
              find.textContaining('Next retry in'),
            )
            .data;
        expect(countdown, contains('3 seconds'));

        // Drain pending timers
        await tester.pump(const Duration(seconds: 5));
      });
    });

    group('Cancel Button', () {
      testWidgets('shows cancel button after retry attempt',
          (WidgetTester tester) async {
        bool cancelPressed = false;

        await tester.pumpWidget(
          makeTestableWidget(
            AuthRetryButton(
              config: const AuthRetryButtonConfig(
                showCancelButton: true,
              ),
              onRetry: () {},
              onCancel: () => cancelPressed = true,
            ),
          ),
        );

        // Initially, no cancel button
        expect(find.text('Cancel'), findsNothing);

        // Trigger retry
        await tester.tap(find.text('Retry'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Should show cancel button
        expect(find.text('Cancel'), findsOneWidget);
      });

      testWidgets('hides cancel button when configured',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            AuthRetryButton(
              config: const AuthRetryButtonConfig(
                showCancelButton: false,
              ),
              onRetry: () {},
            ),
          ),
        );

        await tester.tap(find.text('Retry'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Should not show cancel button
        expect(find.text('Cancel'), findsNothing);
      });

      testWidgets('calls onCancel callback when cancel pressed',
          (WidgetTester tester) async {
        bool cancelPressed = false;

        await tester.pumpWidget(
          makeTestableWidget(
            AuthRetryButton(
              onRetry: () {},
              onCancel: () => cancelPressed = true,
            ),
          ),
        );

        // Trigger retry to show cancel button
        await tester.tap(find.text('Retry'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Tap cancel button
        await tester.tap(find.text('Cancel'));
        await tester.pump();

        expect(cancelPressed, isTrue);

        // State should be reset
        expect(find.text('Attempt 1 of 3'), findsNothing);
      });
    });

    group('External Control', () {
      testWidgets('respects externallyEnabled property',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            AuthRetryButton(
              externallyEnabled: false,
              onRetry: () {},
            ),
          ),
        );

        // Button should be disabled
        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton).first,
        );
        expect(button.onPressed, isNull);
      });

      testWidgets('resets state when externallyEnabled changes to true',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            AuthRetryButton(
              externallyEnabled: false,
              config: const AuthRetryButtonConfig(
                maxAttempts: 1,
              ),
              onRetry: () {},
            ),
          ),
        );

        // Update to enabled
        await tester.pumpWidget(
          makeTestableWidget(
            AuthRetryButton(
              externallyEnabled: true,
              config: const AuthRetryButtonConfig(
                maxAttempts: 1,
              ),
              onRetry: () {},
            ),
          ),
        );

        await tester.pump();

        // Should be enabled now
        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton).first,
        );
        expect(button.onPressed, isNotNull);
      });
    });

    group('Minimal Configuration', () {
      testWidgets('minimal config hides all extra UI',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            AuthRetryButton(
              config: const AuthRetryButtonConfig.minimal(),
              onRetry: () {},
            ),
          ),
        );

        // Should only show button, no extra UI
        expect(find.byType(ElevatedButton), findsOneWidget);
        expect(find.textContaining('Attempt'), findsNothing);
        expect(find.textContaining('Next retry in'), findsNothing);
        expect(find.text('Cancel'), findsNothing);
      });
    });

    group('AuthRetryButtonAutomatic', () {
      testWidgets('renders correctly', (WidgetTester tester) async {
        final service = TokenRefreshService(
          authRepository: mockAuthRepository,
        );

        await tester.pumpWidget(
          makeTestableWidget(
            AuthRetryButtonAutomatic(
              refreshService: service,
            ),
          ),
        );

        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('shows loading when refresh is in progress',
          (WidgetTester tester) async {
        // Use a completer to keep the refresh hanging
        final completer = Completer<AuthSession>();
        final mockRepo = MockAuthRepository();
        when(() => mockRepo.performBasicTokenRefresh())
            .thenAnswer((_) => completer.future);
        final service = TokenRefreshService(
          authRepository: mockRepo,
        );

        await tester.pumpWidget(
          makeTestableWidget(
            AuthRetryButtonAutomatic(
              refreshService: service,
            ),
          ),
        );

        // Trigger a refresh
        service.refreshToken();
        await tester.pump();

        // Should show loading indicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);

        // Complete the refresh and drain
        completer.complete(createMockSession());
        await tester.pump(const Duration(seconds: 5));
      });

      testWidgets('disables button when max attempts reached',
          (WidgetTester tester) async {
        final mockRepo = MockAuthRepository();
        when(() => mockRepo.performBasicTokenRefresh()).thenThrow(
          const AuthException('Refresh failed'),
        );
        final service = TokenRefreshService(
          authRepository: mockRepo,
        );

        await tester.pumpWidget(
          makeTestableWidget(
            AuthRetryButtonAutomatic(
              refreshService: service,
              config: const AuthRetryButtonConfig(maxAttempts: 1),
            ),
          ),
        );

        // Trigger refresh which will fail immediately
        service.refreshToken().catchError((_) => createMockSession());
        await tester.pump();
        // Wait for all 3 retry attempts with backoff delays (2s + 4s)
        await tester.pump(const Duration(seconds: 8));

        // After all retries fail, should show max attempts
        expect(find.text('Max Attempts Reached'), findsOneWidget);

        // Drain pending timers
        await tester.pump(const Duration(seconds: 5));
      });

      testWidgets('cancel button calls onCancel and cancels refresh',
          (WidgetTester tester) async {
        final completer = Completer<AuthSession>();
        final mockRepo = MockAuthRepository();
        when(() => mockRepo.performBasicTokenRefresh())
            .thenAnswer((_) => completer.future);
        final service = TokenRefreshService(
          authRepository: mockRepo,
        );
        bool cancelCalled = false;

        await tester.pumpWidget(
          makeTestableWidget(
            AuthRetryButtonAutomatic(
              refreshService: service,
              onCancel: () => cancelCalled = true,
            ),
          ),
        );

        // Trigger refresh to show cancel button (ignore cancellation error)
        service.refreshToken().catchError((_) => createMockSession());
        await tester.pump();

        // Tap cancel button
        await tester.tap(find.text('Cancel'));
        await tester.pump();

        // Verify cancel was called
        expect(cancelCalled, isTrue);

        // Clean up
        completer.complete(createMockSession());
        await tester.pump(const Duration(seconds: 5));
      });
    });
  });
}

// Mock implementation for testing
class MockAuthRepository extends Mock implements AuthRepository {}

// Helper function to create a mock user
User createMockUser() {
  return User(
    id: 'test-id',
    email: 'test@example.com',
    username: 'Test User',
    createdAt: DateTime(2024),
  );
}

// Helper function to create a mock session
AuthSession createMockSession() {
  return AuthSession(
    accessToken: 'mock-access-token',
    idToken: 'mock-id-token',
    refreshToken: 'mock-refresh-token',
    expiresAt: DateTime.now().add(const Duration(hours: 1)),
  );
}
