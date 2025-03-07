import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/data/models/user_model.dart';
import 'package:soloadventurer/features/auth/domain/providers/auth_providers.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:soloadventurer/features/auth/domain/notifiers/auth_notifier.dart';
import 'package:soloadventurer/features/auth/domain/state/auth_state.dart';

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

void main() {
  late MockAuthRemoteDataSource mockAuthDataSource;
  late ProviderContainer container;

  setUp(() async {
    mockAuthDataSource = MockAuthRemoteDataSource();

    // Register mock methods
    registerFallbackValue('test@test.com');
    registerFallbackValue('password');
    registerFallbackValue('Test User');

    // Set up default mock behavior
    when(() => mockAuthDataSource.getCurrentUser())
        .thenAnswer((_) async => null);

    container = ProviderContainer(
      overrides: [
        authNotifierProvider.overrideWithProvider(
          StateNotifierProvider<AuthNotifier, AuthState>(
            (ref) => AuthNotifier(mockAuthDataSource),
          ),
        ),
      ],
    );

    // Wait for the auth notifier to initialize
    await Future.delayed(const Duration(milliseconds: 100));
  });

  tearDown(() {
    container.dispose();
  });

  group('Auth Flow', () {
    test('full authentication flow', () async {
      // Initial state should be unauthenticated
      expect(
        container.read(authNotifierProvider),
        isA<AuthState>()
            .having((state) => state.isLoggedIn, 'isLoggedIn', false)
            .having((state) => state.user, 'user', null)
            .having((state) => state.accessToken, 'accessToken', null)
            .having((state) => state.requiresEmailVerification,
                'requiresEmailVerification', false)
            .having((state) => state.requiresPasswordReset,
                'requiresPasswordReset', false),
      );

      // Sign in
      final user = UserModel(
        id: '1',
        email: 'test@test.com',
        username: 'test',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      when(() => mockAuthDataSource.signIn(any(), any()))
          .thenAnswer((_) async => (user, 'access_token'));

      await container
          .read(authNotifierProvider.notifier)
          .signIn('test@test.com', 'password');

      // Should be authenticated with token
      expect(
        container.read(authNotifierProvider),
        isA<AuthState>()
            .having((state) => state.isLoggedIn, 'isLoggedIn', true)
            .having((state) => state.user, 'user', user)
            .having((state) => state.accessToken, 'accessToken', 'access_token')
            .having((state) => state.requiresEmailVerification,
                'requiresEmailVerification', false)
            .having((state) => state.requiresPasswordReset,
                'requiresPasswordReset', false),
      );

      // Sign out
      when(() => mockAuthDataSource.signOut()).thenAnswer((_) async {});

      await container.read(authNotifierProvider.notifier).signOut();

      // Should be unauthenticated with no tokens
      expect(
        container.read(authNotifierProvider),
        isA<AuthState>()
            .having((state) => state.isLoggedIn, 'isLoggedIn', false)
            .having((state) => state.user, 'user', null)
            .having((state) => state.accessToken, 'accessToken', null)
            .having((state) => state.requiresEmailVerification,
                'requiresEmailVerification', false)
            .having((state) => state.requiresPasswordReset,
                'requiresPasswordReset', false),
      );
    });

    test('unverified user flow', () async {
      // Sign up with unverified user
      final user = UserModel(
        id: '1',
        email: 'test@test.com',
        username: 'test',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      when(() => mockAuthDataSource.register(
            email: any(named: 'email'),
            password: any(named: 'password'),
            name: any(named: 'name'),
          )).thenAnswer((_) async => (user, true));

      await container.read(authNotifierProvider.notifier).register(
            email: 'test@test.com',
            password: 'password',
            name: 'Test User',
          );

      // Should be unverified
      expect(
        container.read(authNotifierProvider),
        isA<AuthState>()
            .having((state) => state.isLoggedIn, 'isLoggedIn', false)
            .having((state) => state.user, 'user', user)
            .having((state) => state.accessToken, 'accessToken', null)
            .having((state) => state.requiresEmailVerification,
                'requiresEmailVerification', true)
            .having((state) => state.requiresPasswordReset,
                'requiresPasswordReset', false),
      );

      // Test email verification
      when(() => mockAuthDataSource.verifyEmail(any(), any()))
          .thenAnswer((_) async {});

      await container.read(authNotifierProvider.notifier).verifyEmail('123456');

      // After verification, should return to initial state
      expect(
        container.read(authNotifierProvider),
        isA<AuthState>()
            .having((state) => state.isLoggedIn, 'isLoggedIn', false)
            .having((state) => state.user, 'user', null)
            .having((state) => state.accessToken, 'accessToken', null)
            .having((state) => state.requiresEmailVerification,
                'requiresEmailVerification', false)
            .having((state) => state.requiresPasswordReset,
                'requiresPasswordReset', false),
      );
    });

    test('password reset flow', () async {
      // Request password reset
      when(() => mockAuthDataSource.forgotPassword(any()))
          .thenAnswer((_) async {});

      await container
          .read(authNotifierProvider.notifier)
          .forgotPassword('test@test.com');

      // Should be in password reset state
      expect(
        container.read(authNotifierProvider),
        isA<AuthState>()
            .having((state) => state.isLoggedIn, 'isLoggedIn', false)
            .having((state) => state.user, 'user', null)
            .having((state) => state.accessToken, 'accessToken', null)
            .having((state) => state.requiresEmailVerification,
                'requiresEmailVerification', false)
            .having((state) => state.requiresPasswordReset,
                'requiresPasswordReset', true),
      );

      // Confirm password reset
      when(() => mockAuthDataSource.confirmForgotPassword(any(), any(), any()))
          .thenAnswer((_) async {});

      await container.read(authNotifierProvider.notifier).confirmPasswordReset(
            email: 'test@test.com',
            code: '123456',
            newPassword: 'newpassword',
          );

      // Should return to initial state after password reset
      expect(
        container.read(authNotifierProvider),
        isA<AuthState>()
            .having((state) => state.isLoggedIn, 'isLoggedIn', false)
            .having((state) => state.user, 'user', null)
            .having((state) => state.accessToken, 'accessToken', null)
            .having((state) => state.requiresEmailVerification,
                'requiresEmailVerification', false)
            .having((state) => state.requiresPasswordReset,
                'requiresPasswordReset', false),
      );
    });
  });
}
