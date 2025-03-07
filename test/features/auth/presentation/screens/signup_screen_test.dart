import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_provider.dart';
import 'package:soloadventurer/features/auth/presentation/screens/signup_screen.dart';
import 'package:soloadventurer/features/auth/presentation/state/auth_state.dart';

class MockAuthNotifier extends StateNotifier<AsyncValue<AuthState>>
    with Mock
    implements AuthNotifier {
  MockAuthNotifier() : super(AsyncValue.data(AuthState.initial()));

  @override
  Future<void> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    return super.noSuchMethod(
      Invocation.method(
        #signUp,
        [],
        {
          #email: email,
          #password: password,
          #name: name,
        },
      ),
    );
  }
}

void main() {
  group('SignupScreen', () {
    late MockAuthNotifier mockAuthNotifier;

    setUp(() {
      mockAuthNotifier = MockAuthNotifier();
      registerFallbackValue(AsyncValue<AuthState>.data(AuthState.initial()));
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
        child: MaterialApp(
          home: SignupScreen(),
        ),
      );
    }

    testWidgets('shows error message when registration fails',
        (WidgetTester tester) async {
      // Arrange
      when(() => mockAuthNotifier.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            name: any(named: 'name'),
          )).thenAnswer((_) async {
        mockAuthNotifier.state =
            AsyncValue.error('Registration failed', StackTrace.current);
      });

      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.enterText(find.byType(TextFormField).at(0), 'test@test.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.enterText(find.byType(TextFormField).at(2), 'Test User');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      verify(() => mockAuthNotifier.signUp(
            email: 'test@test.com',
            password: 'password123',
            name: 'Test User',
          )).called(1);

      expect(find.text('Registration failed'), findsOneWidget);
    });

    testWidgets('shows loading indicator while registering',
        (WidgetTester tester) async {
      // Arrange
      final completer = Completer<void>();

      when(() => mockAuthNotifier.signUp(
            email: any(named: 'email'),
            password: any(named: 'password'),
            name: any(named: 'name'),
          )).thenAnswer((_) async {
        mockAuthNotifier.state = const AsyncValue.loading();
        await completer.future;
      });

      await tester.pumpWidget(createWidgetUnderTest());

      // Act
      await tester.enterText(find.byType(TextFormField).at(0), 'test@test.com');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.enterText(find.byType(TextFormField).at(2), 'Test User');
      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });
  });
}
