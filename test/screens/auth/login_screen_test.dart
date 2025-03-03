import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/auth/presentation/screens/login_screen.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_provider.dart';
import 'package:soloadventurer/services/auth_service.dart';

// Mock classes
class MockAuthService extends Mock implements AuthService {}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockRoute extends Mock implements Route {}

class MockAuthNotifier extends StateNotifier<AuthState>
    with Mock
    implements AuthNotifier {
  MockAuthNotifier() : super(AuthState.initial());

  @override
  Future<void> signIn({required String email, required String password}) async {
    return Future.value();
  }
}

void main() {
  late MockAuthService mockAuthService;
  late MockNavigatorObserver mockNavigatorObserver;
  late MockAuthNotifier mockAuthNotifier;

  setUp(() {
    mockAuthService = MockAuthService();
    mockNavigatorObserver = MockNavigatorObserver();
    mockAuthNotifier = MockAuthNotifier();

    // Register fallback values for navigation
    registerFallbackValue(MockRoute());
    registerFallbackValue(MockRoute());
  });

  Widget createTestableWidget() {
    return ProviderScope(
      overrides: [
        authProvider.overrideWith((ref) => mockAuthNotifier),
      ],
      child: MaterialApp(
        home: const LoginScreen(),
        navigatorObservers: [mockNavigatorObserver],
      ),
    );
  }

  group('LoginScreen UI Tests', () {
    testWidgets('should display all UI elements correctly', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestableWidget());

      // Assert
      expect(find.text('SoloAdventurer'), findsOneWidget);
      expect(find.text('Login'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('Password'), findsOneWidget);
      expect(find.text('Forgot Password?'), findsOneWidget);
      expect(find.text("Don't have an account?"), findsOneWidget);
      expect(find.text('Sign Up'), findsOneWidget);

      // Check for form fields and buttons
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
      expect(find.byIcon(Icons.email), findsOneWidget);
      expect(find.byIcon(Icons.lock), findsOneWidget);
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });

    testWidgets('should toggle password visibility', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestableWidget());

      // Initial state - password should be obscured
      final passwordField = tester.widget<TextField>(
        find.descendant(
          of: find.byType(TextFormField).at(1),
          matching: find.byType(TextField),
        ),
      );
      expect(passwordField.obscureText, isTrue);

      // Act - tap the visibility toggle
      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      // Assert - password should now be visible
      final updatedPasswordField = tester.widget<TextField>(
        find.descendant(
          of: find.byType(TextFormField).at(1),
          matching: find.byType(TextField),
        ),
      );
      expect(updatedPasswordField.obscureText, isFalse);
      expect(find.byIcon(Icons.visibility_off), findsOneWidget);

      // Act - tap again to hide
      await tester.tap(find.byIcon(Icons.visibility_off));
      await tester.pump();

      // Assert - password should be obscured again
      final finalPasswordField = tester.widget<TextField>(
        find.descendant(
          of: find.byType(TextFormField).at(1),
          matching: find.byType(TextField),
        ),
      );
      expect(finalPasswordField.obscureText, isTrue);
      expect(find.byIcon(Icons.visibility), findsOneWidget);
    });
  });

  group('Form Validation Tests', () {
    testWidgets('should validate email field', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestableWidget());

      // Act - submit with empty email
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(find.text('Please enter your email'), findsOneWidget);

      // Act - enter invalid email
      await tester.enterText(find.byType(TextFormField).at(0), 'invalid-email');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(find.text('Please enter a valid email'), findsOneWidget);

      // Act - enter valid email
      await tester.enterText(
          find.byType(TextFormField).at(0), 'test@example.com');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert - no email error
      expect(find.text('Please enter your email'), findsNothing);
      expect(find.text('Please enter a valid email'), findsNothing);
    });

    testWidgets('should validate password field', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestableWidget());

      // Act - submit with empty password
      await tester.enterText(
          find.byType(TextFormField).at(0), 'test@example.com');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(find.text('Please enter your password'), findsOneWidget);

      // Act - enter short password
      await tester.enterText(find.byType(TextFormField).at(1), 'short');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(
          find.text('Password must be at least 8 characters'), findsOneWidget);

      // Act - enter valid password
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert - no password error
      expect(find.text('Please enter your password'), findsNothing);
      expect(find.text('Password must be at least 8 characters'), findsNothing);
    });
  });

  group('Authentication Tests', () {
    testWidgets('should show loading indicator during authentication',
        (tester) async {
      // Arrange
      when(() => mockAuthService.signIn(
                username: any(named: 'username'),
                password: any(named: 'password'),
              ))
          .thenAnswer((_) =>
              Future.delayed(const Duration(milliseconds: 500), () => true));

      await tester.pumpWidget(createTestableWidget());

      // Act - fill form and submit
      await tester.enterText(
          find.byType(TextFormField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert - should show loading indicator
      expect(find.byType(CircularProgressIndicator), findsOneWidget);

      // Complete the future
      await tester.pumpAndSettle();

      // Assert - loading indicator should be gone
      expect(find.byType(CircularProgressIndicator), findsNothing);
    });

    testWidgets('should handle successful login', (tester) async {
      // Arrange
      when(() => mockAuthService.signIn(
            username: any(named: 'username'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => true);

      await tester.pumpWidget(createTestableWidget());

      // Act - fill form and submit
      await tester.enterText(
          find.byType(TextFormField).at(0), 'test@example.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Assert - verify auth service was called with correct credentials
      verify(() => mockAuthService.signIn(
            username: 'test@example.com',
            password: 'password123',
          )).called(1);
    });

    testWidgets('should display error message on failed login', (tester) async {
      // Arrange
      when(() => mockAuthService.signIn(
            username: any(named: 'username'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => false);

      await tester.pumpWidget(createTestableWidget());

      // Act - fill form and submit
      await tester.enterText(
          find.byType(TextFormField).at(0), 'test@example.com');
      await tester.enterText(
          find.byType(TextFormField).at(1), 'wrong-password');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Assert - verify error is displayed
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Invalid credentials'), findsOneWidget);
    });
  });

  group('Navigation Tests', () {
    testWidgets('should navigate to sign up screen', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestableWidget());

      // Act - tap sign up button
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Assert - verify navigation was triggered
      verify(() => mockNavigatorObserver.didPush(any(), any())).called(1);
    });

    testWidgets('should navigate to forgot password screen', (tester) async {
      // Arrange
      await tester.pumpWidget(createTestableWidget());

      // Act - tap forgot password button
      await tester.tap(find.text('Forgot Password?'));
      await tester.pumpAndSettle();

      // Assert - verify navigation was triggered
      verify(() => mockNavigatorObserver.didPush(any(), any())).called(1);
    });
  });

  group('Provider Integration Tests', () {
    testWidgets('should disable form fields during loading', (tester) async {
      // Create a simplified mock for the auth notifier
      when(() => mockAuthNotifier.state)
          .thenReturn(const AuthState(isLoading: true, error: null));

      // Arrange - create a provider container with a loading state
      final testWidget = ProviderScope(
        overrides: [
          authProvider.overrideWith((_) => mockAuthNotifier),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      );

      await tester.pumpWidget(testWidget);

      // Assert - form fields should be disabled
      final emailField =
          tester.widget<TextFormField>(find.byType(TextFormField).at(0));
      final passwordField =
          tester.widget<TextFormField>(find.byType(TextFormField).at(1));
      final loginButton =
          tester.widget<ElevatedButton>(find.byType(ElevatedButton));

      expect(emailField.enabled, isFalse);
      expect(passwordField.enabled, isFalse);
      expect(loginButton.enabled, isFalse);
    });

    testWidgets('should clear error when requested', (tester) async {
      // Create a simplified mock for the auth notifier with an error
      when(() => mockAuthNotifier.state)
          .thenReturn(const AuthState(isLoading: false, error: 'Test error'));

      // Mock the clearError method
      when(() => mockAuthNotifier.clearError()).thenReturn(null);

      // Arrange - create a provider container with an error state
      final testWidget = ProviderScope(
        overrides: [
          authProvider.overrideWith((_) => mockAuthNotifier),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      );

      await tester.pumpWidget(testWidget);
      await tester.pump(); // Allow post frame callback to execute

      // Assert - error should be displayed
      expect(find.byType(SnackBar), findsOneWidget);
      expect(find.text('Test error'), findsOneWidget);

      // Verify error was cleared
      verify(() => mockAuthNotifier.clearError()).called(1);
    });
  });
}
