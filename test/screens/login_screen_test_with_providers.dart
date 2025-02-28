import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/providers/auth_provider.dart';
import 'package:soloadventurer/screens/login_screen.dart';
import 'package:soloadventurer/services/auth_service.dart';
import 'package:soloadventurer/test_utils/provider_test_utils.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Create a provider for testing
final authServiceProvider = Provider<AuthService>((ref) => MockAuthService());
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthStateData>(
  (ref) => AuthNotifier(ref.watch(authServiceProvider)),
);

void main() {
  late AuthTestHelper authTestHelper;

  setUpAll(() {
    // Register fallback values
    registerFallbackValue(MockRoute());
  });

  setUp(() {
    authTestHelper = AuthTestHelper();
  });

  group('LoginScreen with providers', () {
    testWidgets('should show login form', (WidgetTester tester) async {
      // Arrange
      final mockAuthService = authTestHelper.authService;
      final mockNavigatorObserver = authTestHelper.navigatorObserver;

      // Build the widget
      await tester.pumpWidget(
        createTestableApp(
          child: const LoginScreen(),
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
          navigatorObservers: [mockNavigatorObserver],
        ),
      );

      // Assert
      expect(find.text('Login'), findsOneWidget);
      expect(find.byType(TextFormField), findsNWidgets(2));
      expect(find.byType(ElevatedButton), findsOneWidget);
    });

    testWidgets('should call signIn when form is submitted with valid data',
        (WidgetTester tester) async {
      // Arrange
      final mockAuthService = authTestHelper.authService;
      final mockNavigatorObserver = authTestHelper.navigatorObserver;

      // Setup mock behavior
      when(() => mockAuthService.signIn(
            username: any(named: 'username'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => true);

      // Build the widget
      await tester.pumpWidget(
        createTestableApp(
          child: const LoginScreen(),
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
          navigatorObservers: [mockNavigatorObserver],
        ),
      );

      // Act - Fill in the form
      await tester.enterText(
          find.byKey(const Key('username_field')), 'testuser');
      await tester.enterText(
          find.byKey(const Key('password_field')), 'password123');

      // Submit the form
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      verify(() => mockAuthService.signIn(
            username: 'testuser',
            password: 'password123',
          )).called(1);
    });

    testWidgets('should show error message when login fails',
        (WidgetTester tester) async {
      // Arrange
      final mockAuthService = authTestHelper.authService;
      final mockNavigatorObserver = authTestHelper.navigatorObserver;

      // Setup mock behavior for failed login
      when(() => mockAuthService.signIn(
            username: any(named: 'username'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => false);

      // Build the widget
      await tester.pumpWidget(
        createTestableApp(
          child: const LoginScreen(),
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
          navigatorObservers: [mockNavigatorObserver],
        ),
      );

      // Act - Fill in the form
      await tester.enterText(
          find.byKey(const Key('username_field')), 'testuser');
      await tester.enterText(
          find.byKey(const Key('password_field')), 'wrong_password');

      // Submit the form
      await tester.tap(find.byType(ElevatedButton));
      await tester.pumpAndSettle();

      // Assert - Check for error message
      expect(find.text('Invalid credentials'), findsOneWidget);
    });

    testWidgets('should navigate to signup screen when signup button is tapped',
        (WidgetTester tester) async {
      // Arrange
      final mockAuthService = authTestHelper.authService;
      final mockNavigatorObserver = authTestHelper.navigatorObserver;

      // Build the widget
      await tester.pumpWidget(
        createTestableApp(
          child: const LoginScreen(),
          overrides: [
            authServiceProvider.overrideWithValue(mockAuthService),
          ],
          navigatorObservers: [mockNavigatorObserver],
        ),
      );

      // Act - Tap the signup button
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Assert - Verify navigation
      verify(() => mockNavigatorObserver.didPush(any(), any())).called(1);
    });
  });
}
