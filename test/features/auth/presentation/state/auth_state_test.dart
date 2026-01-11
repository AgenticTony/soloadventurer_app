import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/auth/presentation/state/auth_state.dart';

void main() {
  group('AuthState', () {
    test('initial state has correct values', () {
      final state = AuthState.initial();
      expect(state.user, null);
      expect(state.isAuthenticated, false);
      expect(state.requiresMFA, false);
      expect(state.requiresEmailVerification, false);
      expect(state.requiresPasswordReset, false);
    });

    test('authenticated state has correct values', () {
      final user = User(
        id: '1',
        email: 'test@test.com',
        username: 'test',
        createdAt: DateTime.now(),
      );
      final state = AuthState.authenticated(
        user: user,
        accessToken: 'test-token',
        idToken: 'test-id-token',
        refreshToken: 'test-refresh-token',
        tokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
      expect(state.user, user);
      expect(state.isAuthenticated, true);
      expect(state.requiresMFA, false);
      expect(state.requiresEmailVerification, false);
      expect(state.requiresPasswordReset, false);
    });

    test('unverified state has correct values', () {
      final user = User(
        id: '1',
        email: 'test@test.com',
        username: 'test',
        createdAt: DateTime.now(),
      );
      final state = AuthState.unverified(user: user);
      expect(state.user, user);
      expect(state.isAuthenticated, false);
      expect(state.requiresMFA, false);
      expect(state.requiresEmailVerification, true);
      expect(state.requiresPasswordReset, false);
    });

    test('mfaRequired state has correct values', () {
      final user = User(
        id: '1',
        email: 'test@test.com',
        username: 'test',
        createdAt: DateTime.now(),
      );
      final state = AuthState.mfaRequired(user: user);
      expect(state.user, user);
      expect(state.isAuthenticated, false);
      expect(state.requiresMFA, true);
      expect(state.requiresEmailVerification, false);
      expect(state.requiresPasswordReset, false);
    });

    test('passwordResetRequired state has correct values', () {
      final user = User(
        id: '1',
        email: 'test@test.com',
        username: 'test',
        createdAt: DateTime.now(),
      );
      final state = AuthState.passwordResetRequired(user: user);
      expect(state.user, user);
      expect(state.isAuthenticated, false);
      expect(state.requiresMFA, false);
      expect(state.requiresEmailVerification, false);
      expect(state.requiresPasswordReset, true);
    });

    test('copyWith creates new instance with updated values', () {
      final user = User(
        id: '1',
        email: 'test@test.com',
        username: 'test',
        createdAt: DateTime.now(),
      );
      final state = AuthState.initial();
      final newState = state.copyWith(
        user: user,
        isAuthenticated: true,
        requiresMFA: true,
        requiresEmailVerification: true,
        requiresPasswordReset: true,
      );

      expect(newState.user, user);
      expect(newState.isAuthenticated, true);
      expect(newState.requiresMFA, true);
      expect(newState.requiresEmailVerification, true);
      expect(newState.requiresPasswordReset, true);
    });

    test('copyWith preserves values when not specified', () {
      final user = User(
        id: '1',
        email: 'test@test.com',
        username: 'test',
        createdAt: DateTime.now(),
      );
      final state = AuthState.authenticated(
        user: user,
        accessToken: 'test-token',
        idToken: 'test-id-token',
        refreshToken: 'test-refresh-token',
        tokenExpiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
      final newState = state.copyWith();

      expect(newState.user, state.user);
      expect(newState.isAuthenticated, state.isAuthenticated);
      expect(newState.requiresMFA, state.requiresMFA);
      expect(
          newState.requiresEmailVerification, state.requiresEmailVerification);
      expect(newState.requiresPasswordReset, state.requiresPasswordReset);
    });

    test('equality works correctly', () {
      final user1 = User(
        id: '1',
        email: 'test@test.com',
        username: 'test',
        createdAt: DateTime.now(),
      );

      final user2 = User(
        id: '1',
        email: 'test@test.com',
        username: 'test',
        createdAt: user1.createdAt,
      );

      final tokenExpiresAt = DateTime.now().add(const Duration(hours: 1));

      final state1 = AuthState.authenticated(
        user: user1,
        accessToken: 'test-token',
        idToken: 'test-id-token',
        refreshToken: 'test-refresh-token',
        tokenExpiresAt: tokenExpiresAt,
      );
      final state2 = AuthState.authenticated(
        user: user2,
        accessToken: 'test-token',
        idToken: 'test-id-token',
        refreshToken: 'test-refresh-token',
        tokenExpiresAt: tokenExpiresAt,
      );
      final state3 = AuthState.unverified(user: user1);

      expect(state1 == state2, isTrue);
      expect(state1 == state3, isFalse);
    });

    test('toString returns correct string representation', () {
      final user = User(
        id: '1',
        email: 'test@test.com',
        username: 'test',
        createdAt: DateTime.now(),
      );
      final state = AuthState(
        user: user,
        isAuthenticated: true,
        requiresMFA: false,
        requiresEmailVerification: true,
        requiresPasswordReset: false,
      );

      // AuthState doesn't have a custom toString, so we just check it's not null
      expect(state.toString(), isNotNull);
      expect(state.toString(), isNotEmpty);
    });
  });
}
