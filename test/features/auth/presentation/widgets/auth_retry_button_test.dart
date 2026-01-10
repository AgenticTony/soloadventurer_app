import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
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

        // Wait for countdown
        await tester.pump(const Duration(seconds: 1));

        // Second retry
        await tester.tap(find.text('Retry'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));

        // Should show max attempts message
        expect(find.text('Max Attempts Reached'), findsOneWidget);

        // Button should be disabled
        final button = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton).first,
        );
        expect(button.onPressed, isNull);
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

        // Countdown should decrease
        final countdownBefore = tester
            .widget<Text>(
              find.textContaining('Next retry in'),
            )
            .data;
        await tester.pump(const Duration(seconds: 1));
        final countdownAfter = tester
            .widget<Text>(
              find.textContaining('Next retry in'),
            )
            .data;

        expect(countdownBefore, isNot(equals(countdownAfter)));
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

        expect(find.text('Next retry in 1 second'), findsOneWidget);

        // Wait for countdown
        await tester.pump(const Duration(seconds: 1));

        // Second attempt - should have 2 second countdown (2^1)
        await tester.tap(find.text('Retry'));
        await tester.pump();
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(seconds: 1));

        // Countdown should be for 2 seconds (2^1)
        final countdown = tester
            .widget<Text>(
              find.textContaining('Next retry in'),
            )
            .data;
        expect(countdown, contains('2 seconds'));
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

        // Trigger a refresh
        service.refreshToken();
        await tester.pump();

        // Should show loading indicator
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
      });

      testWidgets('disables button when max attempts reached',
          (WidgetTester tester) async {
        final service = TokenRefreshService(
          authRepository: mockAuthRepository,
        );

        await tester.pumpWidget(
          makeTestableWidget(
            AuthRetryButtonAutomatic(
              refreshService: service,
              config: const AuthRetryButtonConfig(maxAttempts: 1),
            ),
          ),
        );

        // Wait for service to complete (will fail since mock returns null)
        await tester.pump(const Duration(seconds: 2));

        // After failure, should show max attempts
        expect(find.text('Max Attempts Reached'), findsOneWidget);
      });

      testWidgets('cancel button calls onCancel and cancels refresh',
          (WidgetTester tester) async {
        final service = TokenRefreshService(
          authRepository: mockAuthRepository,
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

        // Trigger refresh to show cancel button
        service.refreshToken();
        await tester.pump();

        // Tap cancel button (need to wait for it to appear)
        await tester.pump(const Duration(milliseconds: 100));

        // Verify cancel was called
        expect(cancelCalled, isTrue);
      });
    });
  });
}

// Mock implementation for testing
class MockAuthRepository extends Mock implements AuthRepository {}

// Helper function to create a mock user
User createMockUser() {
  return const User(
    id: 'test-id',
    email: 'test@example.com',
    name: 'Test User',
  );
}

// Helper function to create a mock session
AuthSession createMockSession() {
  return AuthSession(
    accessToken: 'mock-access-token',
    idToken: 'mock-id-token',
    refreshToken: 'mock-refresh-token',
    expiration: DateTime.now().add(const Duration(hours: 1)),
  );
}
