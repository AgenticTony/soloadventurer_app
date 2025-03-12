import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_provider.dart';
import 'package:soloadventurer/features/auth/presentation/screens/login_screen.dart';
import 'package:soloadventurer/features/auth/presentation/state/auth_state.dart';

class MockAuthNotifier extends StateNotifier<AsyncValue<AuthState>>
    with Mock
    implements AuthNotifier {
  MockAuthNotifier() : super(const AsyncValue.data(AuthState.initial()));

  @override
  Future<void> signIn(String email, String password) async {
    return super.noSuchMethod(
      Invocation.method(
        #signIn,
        [email, password],
      ),
    );
  }
}

void main() {
  group('LoginScreen', () {
    late MockAuthNotifier mockAuthNotifier;

    setUp(() {
      mockAuthNotifier = MockAuthNotifier();
      registerFallbackValue(const AsyncValue<AuthState>.data(AuthState.initial()));
    });

    Widget createWidgetUnderTest() {
      return ProviderScope(
        overrides: [
          authProvider.overrideWithProvider(
            StateNotifierProvider<AuthNotifier, AsyncValue<AuthState>>(
              (ref) => mockAuthNotifier,
            ),
          ),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      );
    }

    testWidgets('shows error message when login fails',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockAuthNotifier.signIn(any(), any())).thenAnswer((_) async {
        mockAuthNotifier.state =
            AsyncValue.error('Login failed', StackTrace.current);
      });

      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.enterText(find.byType(TextFormField).at(0), 'test@test.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      verify(() => mockAuthNotifier.signIn('test@test.com', 'password123'))
          .called(1);
      expect(find.text('Login failed'), findsOneWidget);
    });

    testWidgets('shows loading indicator while logging in',
        (WidgetTester tester) async {
      // Arrange
      final completer = Completer<void>();

      when(() => mockAuthNotifier.signIn(any(), any())).thenAnswer((_) async {
        mockAuthNotifier.state = const AsyncValue.loading();
        await completer.future;
      });

      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.enterText(find.byType(TextFormField).at(0), 'test@test.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
