import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_notifier.dart';
import 'package:soloadventurer/features/auth/presentation/screens/signup_screen.dart';
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
        home: SignUpScreen(),
      ),
    );
  }

  testWidgets('should display all required UI elements', (tester) async {
    await tester.pumpWidget(createWidgetUnderTest());

    expect(find.text('Sign Up'), findsOneWidget);
    expect(find.text('Join SoloAdventurer'), findsOneWidget);
    expect(find.byIcon(Icons.hiking), findsOneWidget);
    expect(find.byIcon(Icons.person), findsOneWidget);
    expect(find.byIcon(Icons.email), findsOneWidget);
    expect(find.byIcon(Icons.lock), findsNWidgets(2));
    expect(find.text('Already have an account?'), findsOneWidget);
    expect(find.text('Login'), findsOneWidget);
  });

  group('name field validation', () {
    testWidgets('should show error when name is empty', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Please enter your name'), findsOneWidget);
    });
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

  group('password fields validation', () {
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

    testWidgets('should show error when passwords do not match',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), 'password123');
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Confirm Password'),
          'password456');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(find.text('Passwords do not match'), findsOneWidget);
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

      await tester.tap(find.byIcon(Icons.visibility).first);
      await tester.pump();

      final toggledObscureText =
          tester.widget<TextField>(passwordField).obscureText;
      expect(toggledObscureText, false);
    });

    testWidgets('should toggle confirm password visibility', (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      final confirmPasswordField = find.descendant(
        of: find.widgetWithText(TextFormField, 'Confirm Password'),
        matching: find.byType(TextField),
      );

      final initialObscureText =
          tester.widget<TextField>(confirmPasswordField).obscureText;
      expect(initialObscureText, true);

      await tester.tap(find.byIcon(Icons.visibility).last);
      await tester.pump();

      final toggledObscureText =
          tester.widget<TextField>(confirmPasswordField).obscureText;
      expect(toggledObscureText, false);
    });
  });

  group('sign up button', () {
    testWidgets('should call signUp when form is valid', (tester) async {
      const name = 'Test User';
      const email = 'test@example.com';
      const password = 'password123';

      when(() => mockAuthNotifier.register(email, password, name))
          .thenAnswer((_) async {});

      await tester.pumpWidget(createWidgetUnderTest());

      await tester.enterText(
          find.widgetWithText(TextFormField, 'Full Name'), name);
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Email'), email);
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Password'), password);
      await tester.enterText(
          find.widgetWithText(TextFormField, 'Confirm Password'), password);
      await tester.tap(find.byType(ElevatedButton));

      verify(() => mockAuthNotifier.register(email, password, name)).called(1);
    });

    testWidgets('should show loading indicator while signing up',
        (tester) async {
      when(() => mockAuthNotifier.state).thenReturn(AuthState.loading());

      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      expect(find.text('Sign Up'), findsNothing);
    });
  });

  group('error handling', () {
    testWidgets('should show error message in snackbar', (tester) async {
      const errorMessage = 'Email already exists';

      when(() => mockAuthNotifier.state)
          .thenReturn(AuthState.error(errorMessage));

      await tester.pumpWidget(createWidgetUnderTest());
      await tester.pump();

      expect(find.text(errorMessage), findsOneWidget);
      verify(() => mockAuthNotifier.clearError()).called(1);
    });
  });

  group('navigation', () {
    testWidgets('should navigate back when login link is tapped',
        (tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.text('Login'));
      await tester.pumpAndSettle();

      // Note: We would verify navigation here once it's implemented
      // For now, we just verify the button is tappable
    });
  });
}
