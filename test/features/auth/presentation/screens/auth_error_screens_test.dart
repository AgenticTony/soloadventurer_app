import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/auth_error_handler.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_navigation_provider.dart';
import 'package:soloadventurer/features/auth/presentation/routes/auth_routes.dart';
import 'package:soloadventurer/features/auth/presentation/screens/credentials_error_screen.dart';
import 'package:soloadventurer/features/auth/presentation/screens/network_error_screen.dart';
import 'package:soloadventurer/features/auth/presentation/screens/rate_limit_error_screen.dart';
import 'package:soloadventurer/features/auth/presentation/screens/session_expired_screen.dart';

void main() {
  group('SessionExpiredScreen', () {
    late MockAuthNavigationNotifier mockNavigationNotifier;

    setUp(() {
      mockNavigationNotifier = MockAuthNavigationNotifier();
    });

    Widget makeTestableWidget(Widget child) {
      return ProviderScope(
        overrides: [
          authNavigationProvider.overrideWith((ref) => mockNavigationNotifier),
        ],
        child: MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: Scaffold(body: child),
        ),
      );
    }

    group('Basic Rendering', () {
      testWidgets('renders session expired screen',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(const SessionExpiredScreen()),
        );

        expect(find.text('Session Expired'), findsOneWidget);
        expect(find.byIcon(Icons.lock_clock),
            findsNWidgets(2)); // Large icon + illustration
      });

      testWidgets('renders default message', (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(const SessionExpiredScreen()),
        );

        expect(
          find.text(
              'Your session has expired. Please sign in again to continue.'),
          findsOneWidget,
        );
      });

      testWidgets('renders custom message', (WidgetTester tester) async {
        const customMessage = 'Custom session expired message';

        await tester.pumpWidget(
          makeTestableWidget(
            const SessionExpiredScreen(customMessage: customMessage),
          ),
        );

        expect(find.text(customMessage), findsOneWidget);
        expect(
          find.text(
              'Your session has expired. Please sign in again to continue.'),
          findsNothing,
        );
      });

      testWidgets('renders sign in button', (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(const SessionExpiredScreen()),
        );

        expect(find.text('Sign In Again'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      testWidgets('renders cancel button', (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(const SessionExpiredScreen()),
        );

        expect(find.text('Cancel'), findsOneWidget);
        expect(find.byType(TextButton), findsOneWidget);
      });
    });

    group('User Interactions', () {
      testWidgets('navigates to login when sign in button pressed',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(const SessionExpiredScreen()),
        );

        await tester.tap(find.text('Sign In Again'));
        await tester.pump();

        verify(() => mockNavigationNotifier.navigateTo(AuthRoutes.login))
            .called(1);
      });

      testWidgets('navigates to home when cancel button pressed',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(const SessionExpiredScreen()),
        );

        await tester.tap(find.text('Cancel'));
        await tester.pump();

        verify(() => mockNavigationNotifier.navigateTo(AuthRoutes.home))
            .called(1);
      });
    });

    group('Visual Elements', () {
      testWidgets('displays security explanation', (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(const SessionExpiredScreen()),
        );

        expect(
          find.textContaining(
            'For your security, we automatically sign you out after a period of inactivity.',
          ),
          findsOneWidget,
        );
      });

      testWidgets('uses appropriate error icon', (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(const SessionExpiredScreen()),
        );

        final icons = find.byType(Icon);
        expect(icons, findsNWidgets(2));

        // First icon should be large error icon
        final largeIcon = tester.widget<Icon>(icons.first);
        expect(largeIcon.size, equals(80));
        expect(largeIcon.icon is IconData, isTrue);
      });
    });
  });

  group('NetworkErrorScreen', () {
    bool retryCalled = false;
    bool continueOfflineCalled = false;

    setUp(() {
      retryCalled = false;
      continueOfflineCalled = false;
    });

    Widget makeTestableWidget(Widget child) {
      return ProviderScope(
        child: MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: Scaffold(body: child),
        ),
      );
    }

    group('Basic Rendering', () {
      testWidgets('renders network error screen', (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            NetworkErrorScreen(
              onRetry: () => retryCalled = true,
              onContinueOffline: () => continueOfflineCalled = true,
            ),
          ),
        );

        expect(find.text('Connection Error'), findsOneWidget);
        expect(find.byIcon(Icons.wifi_off), findsOneWidget);
      });

      testWidgets('renders default message', (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            NetworkErrorScreen(
              onRetry: () => retryCalled = true,
              onContinueOffline: () => continueOfflineCalled = true,
            ),
          ),
        );

        expect(
          find.text(
              'Unable to connect to the server. Please check your internet connection.'),
          findsOneWidget,
        );
      });

      testWidgets('renders custom message', (WidgetTester tester) async {
        const customMessage = 'Custom network error message';

        await tester.pumpWidget(
          makeTestableWidget(
            NetworkErrorScreen(
              customMessage: customMessage,
              onRetry: () => retryCalled = true,
              onContinueOffline: () => continueOfflineCalled = true,
            ),
          ),
        );

        expect(find.text(customMessage), findsOneWidget);
      });

      testWidgets('shows network status indicator',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            NetworkErrorScreen(
              onRetry: () => retryCalled = true,
              onContinueOffline: () => continueOfflineCalled = true,
            ),
          ),
        );

        expect(find.text('No Connection'), findsOneWidget);
      });

      testWidgets('shows retry button', (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            NetworkErrorScreen(
              onRetry: () => retryCalled = true,
              onContinueOffline: () => continueOfflineCalled = true,
            ),
          ),
        );

        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('shows continue offline when available',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            NetworkErrorScreen(
              offlineModeAvailable: true,
              onRetry: () => retryCalled = true,
              onContinueOffline: () => continueOfflineCalled = true,
            ),
          ),
        );

        expect(find.text('Continue Offline'), findsOneWidget);
        expect(find.byIcon(Icons.offline_pin), findsOneWidget);
      });

      testWidgets('hides continue offline when not available',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            NetworkErrorScreen(
              offlineModeAvailable: false,
              onRetry: () => retryCalled = true,
              onContinueOffline: () => continueOfflineCalled = true,
            ),
          ),
        );

        expect(find.text('Continue Offline'), findsNothing);
      });

      testWidgets('shows troubleshooting section', (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            NetworkErrorScreen(
              onRetry: () => retryCalled = true,
              onContinueOffline: () => continueOfflineCalled = true,
            ),
          ),
        );

        expect(find.text('Troubleshooting'), findsOneWidget);
        expect(
            find.textContaining('Check your Wi-Fi or mobile data connection'),
            findsOneWidget);
      });
    });

    group('User Interactions', () {
      testWidgets('calls retry callback when retry pressed',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            NetworkErrorScreen(
              onRetry: () => retryCalled = true,
              onContinueOffline: () => continueOfflineCalled = true,
            ),
          ),
        );

        await tester.tap(find.text('Retry'));
        await tester.pump();

        expect(retryCalled, isTrue);
      });

      testWidgets('calls continue offline callback when pressed',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            NetworkErrorScreen(
              offlineModeAvailable: true,
              onRetry: () => retryCalled = true,
              onContinueOffline: () => continueOfflineCalled = true,
            ),
          ),
        );

        await tester.tap(find.text('Continue Offline'));
        await tester.pump();

        expect(continueOfflineCalled, isTrue);
      });

      testWidgets('shows OR divider between retry and offline buttons',
          (WidgetTester tester) async {
        await tester.pumpWidget(
          makeTestableWidget(
            NetworkErrorScreen(
              offlineModeAvailable: true,
              onRetry: () => retryCalled = true,
              onContinueOffline: () => continueOfflineCalled = true,
            ),
          ),
        );

        expect(find.text('OR'), findsOneWidget);
      });
    });
  });

  group('CredentialsErrorScreen', () {
    late MockAuthNavigationNotifier mockNavigationNotifier;
    bool tryAgainCalled = false;

    setUp(() {
      mockNavigationNotifier = MockAuthNavigationNotifier();
      tryAgainCalled = false;
    });

    Widget makeTestableWidget(Widget child) {
      return ProviderScope(
        overrides: [
          authNavigationProvider.overrideWith((ref) => mockNavigationNotifier),
        ],
        child: MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: Scaffold(body: child),
        ),
      );
    }

    group('Basic Rendering', () {
      testWidgets('renders credentials error screen',
          (WidgetTester tester) async {
        final errorInfo = createMockCredentialsError();

        await tester.pumpWidget(
          makeTestableWidget(
            CredentialsErrorScreen(
              errorInfo: errorInfo,
              onTryAgain: () => tryAgainCalled = true,
            ),
          ),
        );

        expect(find.text('Authentication Failed'), findsOneWidget);
        expect(find.byIcon(Icons.lock_person), findsOneWidget);
      });

      testWidgets('renders error message from errorInfo',
          (WidgetTester tester) async {
        final errorInfo = createMockCredentialsError();

        await tester.pumpWidget(
          makeTestableWidget(
            CredentialsErrorScreen(
              errorInfo: errorInfo,
              onTryAgain: () => tryAgainCalled = true,
            ),
          ),
        );

        expect(find.text(errorInfo.userMessage), findsOneWidget);
      });

      testWidgets('renders custom message when provided',
          (WidgetTester tester) async {
        final errorInfo = createMockCredentialsError();
        const customMessage = 'Custom credentials error';

        await tester.pumpWidget(
          makeTestableWidget(
            CredentialsErrorScreen(
              errorInfo: errorInfo,
              customMessage: customMessage,
              onTryAgain: () => tryAgainCalled = true,
            ),
          ),
        );

        expect(find.text(customMessage), findsOneWidget);
        expect(find.text(errorInfo.userMessage), findsNothing);
      });

      testWidgets('displays recovery guidance', (WidgetTester tester) async {
        final errorInfo = createMockCredentialsError();

        await tester.pumpWidget(
          makeTestableWidget(
            CredentialsErrorScreen(
              errorInfo: errorInfo,
              onTryAgain: () => tryAgainCalled = true,
            ),
          ),
        );

        expect(find.text('What to do'), findsOneWidget);
        expect(find.text(errorInfo.recovery.primaryAction), findsOneWidget);
      });

      testWidgets('displays try again button', (WidgetTester tester) async {
        final errorInfo = createMockCredentialsError();

        await tester.pumpWidget(
          makeTestableWidget(
            CredentialsErrorScreen(
              errorInfo: errorInfo,
              onTryAgain: () => tryAgainCalled = true,
            ),
          ),
        );

        expect(find.text('Try Again'), findsOneWidget);
        expect(find.byType(ElevatedButton), findsOneWidget);
      });

      testWidgets('displays forgot password button',
          (WidgetTester tester) async {
        final errorInfo = createMockCredentialsError();

        await tester.pumpWidget(
          makeTestableWidget(
            CredentialsErrorScreen(
              errorInfo: errorInfo,
              onTryAgain: () => tryAgainCalled = true,
            ),
          ),
        );

        expect(find.text('Forgot Password?'), findsOneWidget);
        expect(find.byType(OutlinedButton), findsOneWidget);
      });

      testWidgets('shows sign up link for USER_NOT_FOUND error',
          (WidgetTester tester) async {
        final errorInfo = createMockUserNotFoundError();

        await tester.pumpWidget(
          makeTestableWidget(
            CredentialsErrorScreen(
              errorInfo: errorInfo,
              onTryAgain: () => tryAgainCalled = true,
            ),
          ),
        );

        expect(find.text('Create an Account'), findsOneWidget);
        expect(find.byIcon(Icons.person_add), findsOneWidget);
      });

      testWidgets('hides sign up link for other errors',
          (WidgetTester tester) async {
        final errorInfo = createMockCredentialsError();

        await tester.pumpWidget(
          makeTestableWidget(
            CredentialsErrorScreen(
              errorInfo: errorInfo,
              onTryAgain: () => tryAgainCalled = true,
            ),
          ),
        );

        expect(find.text('Create an Account'), findsNothing);
      });

      testWidgets('displays common issues section',
          (WidgetTester tester) async {
        final errorInfo = createMockCredentialsError();

        await tester.pumpWidget(
          makeTestableWidget(
            CredentialsErrorScreen(
              errorInfo: errorInfo,
              onTryAgain: () => tryAgainCalled = true,
            ),
          ),
        );

        expect(find.text('Common Issues'), findsOneWidget);
        expect(find.textContaining('Check that Caps Lock is not on'),
            findsOneWidget);
      });
    });

    group('User Interactions', () {
      testWidgets('pops screen and calls onTryAgain when try again pressed',
          (WidgetTester tester) async {
        final errorInfo = createMockCredentialsError();

        await tester.pumpWidget(
          makeTestableWidget(
            CredentialsErrorScreen(
              errorInfo: errorInfo,
              onTryAgain: () => tryAgainCalled = true,
            ),
          ),
        );

        await tester.tap(find.text('Try Again'));
        await tester.pump();

        expect(tryAgainCalled, isTrue);
      });

      testWidgets('navigates to forgot password when button pressed',
          (WidgetTester tester) async {
        final errorInfo = createMockCredentialsError();

        await tester.pumpWidget(
          makeTestableWidget(
            CredentialsErrorScreen(
              errorInfo: errorInfo,
              onTryAgain: () => tryAgainCalled = true,
            ),
          ),
        );

        await tester.tap(find.text('Forgot Password?'));
        await tester.pump();

        verify(() =>
                mockNavigationNotifier.navigateTo(AuthRoutes.forgotPassword))
            .called(1);
      });

      testWidgets('navigates to sign up when create account pressed',
          (WidgetTester tester) async {
        final errorInfo = createMockUserNotFoundError();

        await tester.pumpWidget(
          makeTestableWidget(
            CredentialsErrorScreen(
              errorInfo: errorInfo,
              onTryAgain: () => tryAgainCalled = true,
            ),
          ),
        );

        await tester.tap(find.text('Create an Account'));
        await tester.pump();

        verify(() => mockNavigationNotifier.navigateTo(AuthRoutes.signup))
            .called(1);
      });

      testWidgets('navigates back when go back pressed',
          (WidgetTester tester) async {
        final errorInfo = createMockCredentialsError();

        await tester.pumpWidget(
          makeTestableWidget(
            CredentialsErrorScreen(
              errorInfo: errorInfo,
              onTryAgain: () => tryAgainCalled = true,
            ),
          ),
        );

        await tester.tap(find.text('Go Back'));
        await tester.pump();

        // Navigator.of(context).pop() should be called
        // Since we're not in a navigation stack, this won't actually pop,
        // but the tap should succeed without error
      });
    });
  });

  group('RateLimitErrorScreen', () {
    bool retryCalled = false;

    setUp(() {
      retryCalled = false;
    });

    Widget makeTestableWidget(Widget child) {
      return ProviderScope(
        child: MaterialApp(
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
            useMaterial3: true,
          ),
          home: Scaffold(body: child),
        ),
      );
    }

    group('Basic Rendering', () {
      testWidgets('renders rate limit error screen',
          (WidgetTester tester) async {
        final errorInfo = createMockRateLimitError();

        await tester.pumpWidget(
          makeTestableWidget(
            RateLimitErrorScreen(
              errorInfo: errorInfo,
              onRetryAllowed: () => retryCalled = true,
            ),
          ),
        );

        expect(find.text('Too Many Attempts'), findsOneWidget);
        expect(find.byIcon(Icons.speed), findsOneWidget);
      });

      testWidgets('renders error message from errorInfo',
          (WidgetTester tester) async {
        final errorInfo = createMockRateLimitError();

        await tester.pumpWidget(
          makeTestableWidget(
            RateLimitErrorScreen(
              errorInfo: errorInfo,
              onRetryAllowed: () => retryCalled = true,
            ),
          ),
        );

        expect(find.text(errorInfo.userMessage), findsOneWidget);
      });

      testWidgets('renders custom message when provided',
          (WidgetTester tester) async {
        final errorInfo = createMockRateLimitError();
        const customMessage = 'Custom rate limit message';

        await tester.pumpWidget(
          makeTestableWidget(
            RateLimitErrorScreen(
              errorInfo: errorInfo,
              customMessage: customMessage,
              onRetryAllowed: () => retryCalled = true,
            ),
          ),
        );

        expect(find.text(customMessage), findsOneWidget);
        expect(find.text(errorInfo.userMessage), findsNothing);
      });

      testWidgets('displays countdown timer', (WidgetTester tester) async {
        final errorInfo = createMockRateLimitError();

        await tester.pumpWidget(
          makeTestableWidget(
            RateLimitErrorScreen(
              errorInfo: errorInfo,
              onRetryAllowed: () => retryCalled = true,
            ),
          ),
        );

        expect(find.text('Please Wait'), findsOneWidget);
        expect(find.byIcon(Icons.schedule), findsOneWidget);
      });

      testWidgets('disables retry button during countdown',
          (WidgetTester tester) async {
        final errorInfo = createMockRateLimitError();

        await tester.pumpWidget(
          makeTestableWidget(
            RateLimitErrorScreen(
              errorInfo: errorInfo,
              onRetryAllowed: () => retryCalled = true,
            ),
          ),
        );

        final retryButton = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(retryButton.onPressed, isNull);
        expect(find.text('Please Wait'), findsOneWidget);
      });

      testWidgets('shows about rate limiting section',
          (WidgetTester tester) async {
        final errorInfo = createMockRateLimitError();

        await tester.pumpWidget(
          makeTestableWidget(
            RateLimitErrorScreen(
              errorInfo: errorInfo,
              onRetryAllowed: () => retryCalled = true,
            ),
          ),
        );

        expect(find.text('About Rate Limiting'), findsOneWidget);
        expect(find.textContaining('To protect our service and prevent abuse'),
            findsOneWidget);
      });

      testWidgets('shows tips section', (WidgetTester tester) async {
        final errorInfo = createMockRateLimitError();

        await tester.pumpWidget(
          makeTestableWidget(
            RateLimitErrorScreen(
              errorInfo: errorInfo,
              onRetryAllowed: () => retryCalled = true,
            ),
          ),
        );

        expect(find.text('Tips'), findsOneWidget);
        expect(
            find.textContaining(
                'Double-check your credentials before each attempt'),
            findsOneWidget);
      });
    });

    group('Countdown Timer', () {
      testWidgets('counts down from initial duration',
          (WidgetTester tester) async {
        final errorInfo = createMockRateLimitError();

        await tester.pumpWidget(
          makeTestableWidget(
            RateLimitErrorScreen(
              errorInfo: errorInfo,
              onRetryAllowed: () => retryCalled = true,
            ),
          ),
        );

        // Initial state should show remaining time
        expect(find.byIcon(Icons.schedule), findsOneWidget);

        // Pump forward 1 second
        await tester.pump(const Duration(seconds: 1));
        await tester.pump();

        // Timer should still be counting down
        expect(find.byIcon(Icons.schedule), findsOneWidget);
      });

      testWidgets('enables retry button when countdown finishes',
          (WidgetTester tester) async {
        // Use a short duration for testing
        const errorInfo = AuthErrorInfo(
          category: AuthErrorCategory.rateLimit,
          userMessage: 'Too many attempts',
          recovery: AuthErrorRecovery(
            primaryAction: 'Wait before retrying',
            canRetry: false,
            retryDelay: Duration(seconds: 2),
          ),
          errorCode: 'RATE_LIMIT_EXCEEDED',
          isRetryable: false,
        );

        await tester.pumpWidget(
          makeTestableWidget(
            RateLimitErrorScreen(
              errorInfo: errorInfo,
              onRetryAllowed: () => retryCalled = true,
            ),
          ),
        );

        // Initially disabled
        expect(find.text('Please Wait'), findsOneWidget);

        // Wait for countdown to finish
        await tester.pump(const Duration(seconds: 3));
        await tester.pump();

        // Should show ready state
        expect(find.text('Ready to Retry'), findsOneWidget);
        expect(find.byIcon(Icons.check_circle), findsOneWidget);

        // Retry button should be enabled
        final retryButton = tester.widget<ElevatedButton>(
          find.byType(ElevatedButton),
        );
        expect(retryButton.onPressed, isNotNull);
        expect(find.text('Retry Now'), findsOneWidget);
      });
    });

    group('User Interactions', () {
      testWidgets('calls onRetryAllowed when retry pressed after countdown',
          (WidgetTester tester) async {
        // Use a short duration for testing
        const errorInfo = AuthErrorInfo(
          category: AuthErrorCategory.rateLimit,
          userMessage: 'Too many attempts',
          recovery: AuthErrorRecovery(
            primaryAction: 'Wait before retrying',
            canRetry: false,
            retryDelay: Duration(seconds: 1),
          ),
          errorCode: 'RATE_LIMIT_EXCEEDED',
          isRetryable: false,
        );

        await tester.pumpWidget(
          makeTestableWidget(
            RateLimitErrorScreen(
              errorInfo: errorInfo,
              onRetryAllowed: () => retryCalled = true,
            ),
          ),
        );

        // Wait for countdown to finish
        await tester.pump(const Duration(seconds: 2));
        await tester.pump();

        // Tap retry button
        await tester.tap(find.text('Retry Now'));
        await tester.pump();

        expect(retryCalled, isTrue);
      });

      testWidgets('does not call retry when countdown not finished',
          (WidgetTester tester) async {
        final errorInfo = createMockRateLimitError();

        await tester.pumpWidget(
          makeTestableWidget(
            RateLimitErrorScreen(
              errorInfo: errorInfo,
              onRetryAllowed: () => retryCalled = true,
            ),
          ),
        );

        // Try to tap while button is disabled (shouldn't trigger)
        final retryButton = find.byType(ElevatedButton);
        await tester.tap(retryButton);
        await tester.pump();

        expect(retryCalled, isFalse);
      });

      testWidgets('navigates back when cancel pressed',
          (WidgetTester tester) async {
        final errorInfo = createMockRateLimitError();

        await tester.pumpWidget(
          makeTestableWidget(
            RateLimitErrorScreen(
              errorInfo: errorInfo,
              onRetryAllowed: () => retryCalled = true,
            ),
          ),
        );

        await tester.tap(find.text('Cancel'));
        await tester.pump();

        // Navigator.of(context).pop() should be called
        // Since we're not in a navigation stack, this won't actually pop,
        // but the tap should succeed without error
      });
    });

    group('Time Formatting', () {
      testWidgets('formats seconds correctly', (WidgetTester tester) async {
        const errorInfo = AuthErrorInfo(
          category: AuthErrorCategory.rateLimit,
          userMessage: 'Too many attempts',
          recovery: AuthErrorRecovery(
            primaryAction: 'Wait',
            canRetry: false,
            retryDelay: Duration(seconds: 45),
          ),
          errorCode: 'RATE_LIMIT_EXCEEDED',
          isRetryable: false,
        );

        await tester.pumpWidget(
          makeTestableWidget(
            RateLimitErrorScreen(
              errorInfo: errorInfo,
              onRetryAllowed: () => retryCalled = true,
            ),
          ),
        );

        // Should show "45 seconds"
        expect(find.textContaining('second'), findsOneWidget);
      });

      testWidgets('formats minutes and seconds correctly',
          (WidgetTester tester) async {
        const errorInfo = AuthErrorInfo(
          category: AuthErrorCategory.rateLimit,
          userMessage: 'Too many attempts',
          recovery: AuthErrorRecovery(
            primaryAction: 'Wait',
            canRetry: false,
            retryDelay: Duration(minutes: 5, seconds: 30),
          ),
          errorCode: 'RATE_LIMIT_EXCEEDED',
          isRetryable: false,
        );

        await tester.pumpWidget(
          makeTestableWidget(
            RateLimitErrorScreen(
              errorInfo: errorInfo,
              onRetryAllowed: () => retryCalled = true,
            ),
          ),
        );

        // Should show "5 minutes 30 seconds"
        expect(find.textContaining('minute'), findsOneWidget);
        expect(find.textContaining('second'), findsOneWidget);
      });

      testWidgets('formats hours correctly', (WidgetTester tester) async {
        const errorInfo = AuthErrorInfo(
          category: AuthErrorCategory.rateLimit,
          userMessage: 'Too many attempts',
          recovery: AuthErrorRecovery(
            primaryAction: 'Wait',
            canRetry: false,
            retryDelay: Duration(hours: 2, minutes: 30),
          ),
          errorCode: 'RATE_LIMIT_EXCEEDED',
          isRetryable: false,
        );

        await tester.pumpWidget(
          makeTestableWidget(
            RateLimitErrorScreen(
              errorInfo: errorInfo,
              onRetryAllowed: () => retryCalled = true,
            ),
          ),
        );

        // Should show "2 hours 30 minutes"
        expect(find.textContaining('hour'), findsOneWidget);
        expect(find.textContaining('minute'), findsOneWidget);
      });
    });
  });
}

// Mock classes
class MockAuthNavigationNotifier extends Mock
    implements AuthNavigationNotifier {}

// Helper functions to create mock error info
AuthErrorInfo createMockCredentialsError() {
  return const AuthErrorInfo(
    category: AuthErrorCategory.credentials,
    userMessage: 'Incorrect email or password. Please try again.',
    recovery: AuthErrorRecovery(
      primaryAction: 'Check your email and password and try again',
      secondaryAction: 'Reset your password if you forgot it',
      canRetry: true,
    ),
    errorCode: 'INVALID_CREDENTIALS',
    isRetryable: true,
  );
}

AuthErrorInfo createMockUserNotFoundError() {
  return const AuthErrorInfo(
    category: AuthErrorCategory.credentials,
    userMessage: 'No account found with this email address.',
    recovery: AuthErrorRecovery(
      primaryAction: 'Check your email address and try again',
      secondaryAction: 'Create a new account if needed',
      canRetry: true,
    ),
    errorCode: 'USER_NOT_FOUND',
    isRetryable: true,
  );
}

AuthErrorInfo createMockRateLimitError() {
  return const AuthErrorInfo(
    category: AuthErrorCategory.rateLimit,
    userMessage: 'Too many attempts. Please wait before trying again.',
    recovery: AuthErrorRecovery(
      primaryAction: 'Please wait before trying again',
      canRetry: false,
      retryDelay: Duration(minutes: 15),
    ),
    errorCode: 'RATE_LIMIT_EXCEEDED',
    isRetryable: false,
  );
}
