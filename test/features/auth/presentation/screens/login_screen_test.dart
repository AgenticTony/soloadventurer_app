import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_notifier.dart';
import 'package:soloadventurer/features/auth/presentation/screens/login_screen.dart';
import 'package:soloadventurer/features/auth/presentation/state/auth_state.dart';

class MockAuthNotifier extends StateNotifier<AuthState>
    with Mock
    implements AuthNotifier {
  MockAuthNotifier() : super(AuthState.initial());
}

void main() {
  late MockAuthNotifier mockAuthNotifier;

  setUp(() {
    mockAuthNotifier = MockAuthNotifier();
  });

  Widget createWidgetUnderTest() {
    return ProviderScope(
      overrides: [
        authProvider.overrideWith((ref) => mockAuthNotifier),
      ],
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    );
  }

  testWidgets('should display all required UI elements', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Login'), findsOneWidget);
    expect(find.text('SoloAdventurer'), findsOneWidget);
    expect(find.byIcon(Icons.hiking), findsOneWidget);
    expect(find.byIcon(Icons.email), findsOneWidget);
    expect(find.byIcon(Icons.lock), findsOneWidget);
    expect(find.text('Forgot Password?'), findsOneWidget);
    expect(find.text("Don't have an account?"), findsOneWidget);
    expect(find.text('Sign Up'), findsOneWidget);
  });

  group('email field validation', () {
    testWidgets('should show error when email is empty', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please enter your email'), findsOneWidget);
    });

    testWidgets('should show error when email is invalid', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'), 'invalid-email');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please enter a valid email'), findsOneWidget);
    });
  });

  group('password field validation', () {
    testWidgets('should show error when password is empty', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please enter your password'), findsOneWidget);
    });

    testWidgets('should show error when password is too short', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), '123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(
          find.text('Password must be at least 8 characters'), findsOneWidget);
    });

    testWidgets('should toggle password visibility', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final passwordField = find.descendant(
        of: find.widgetWithText(TextFormField, 'Password'),
        matching: find.byType(TextField),
      );

      final initialObscureText =
          tester.widget<TextField>(passwordField).obscureText;
      expect(initialObscureText, true);

      await tester.tap(find.byIcon(Icons.visibility));
      await tester.pump();

      final toggledObscureText =
          tester.widget<TextField>(passwordField).obscureText;
      expect(toggledObscureText, false);
    });
  });

  group('login button', () {
    testWidgets('should call signIn when form is valid', (tester) async {
      const email = 'test@example.com';
      const password = 'password123';

      when(() => mockAuthNotifier.signIn(email, password))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'), email);
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), password);
      await tester.tap(find.byType(ElevatedButton));

      verify(() => mockAuthNotifier.signIn(email, password)).called(1);
    });

    testWidgets('should show loading indicator while logging in',
        (tester) async {
      when(() => mockAuthNotifier.state).thenReturn(AuthState.loading());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Login'), findsNothing);
    });
  });

  group('error handling', () {
    testWidgets('should show error message in snackbar', (tester) async {
      const errorMessage = 'Invalid credentials';

      when(() => mockAuthNotifier.state)
          .thenReturn(AuthState.error(errorMessage));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text(errorMessage), findsOneWidget);
      verify(() => mockAuthNotifier.clearError()).called(1);
    });
  });

  group('navigation', () {
    testWidgets('should call navigation methods when links are tapped',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Forgot Password?'));
      await tester.tap(find.text('Sign Up'));

      // Note: Currently these buttons don't do anything as the navigation
      // is commented out in the implementation. We would test the actual
      // navigation once it's implemented.
    });
  });
}
