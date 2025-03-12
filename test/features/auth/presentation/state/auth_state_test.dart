import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/auth/presentation/state/auth_state.dart';

void main() {
  group('AuthState', () {
    test('initial state has correct values', () {
      const state = AuthState.initial();
      expect(state.isLoading, false);
      expect(state.user, null);
      expect(state.error, null);
      expect(state.errorCode, null);
      expect(state.requiresEmailVerification, false);
      expect(state.requiresPasswordReset, false);
      expect(state.isLoggedIn, false);
      expect(state.isAuthenticated, false);
      expect(state.needsVerification, false);
      expect(state.isNewUser, false);
    });

    test('loading state has correct values', () {
      const state = AuthState.loading();
      expect(state.isLoading, true);
      expect(state.user, null);
      expect(state.error, null);
      expect(state.errorCode, null);
      expect(state.requiresEmailVerification, false);
      expect(state.requiresPasswordReset, false);
    });

    test('error state has correct values', () {
      const state = AuthState.error('Test error', 'ERROR_CODE');
      expect(state.isLoading, false);
      expect(state.user, null);
      expect(state.error, 'Test error');
      expect(state.errorCode, 'ERROR_CODE');
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
      final state = AuthState.authenticated(user);
      expect(state.isLoading, false);
      expect(state.user, user);
      expect(state.error, null);
      expect(state.errorCode, null);
      expect(state.requiresEmailVerification, false);
      expect(state.requiresPasswordReset, false);
      expect(state.isLoggedIn, true);
      expect(state.isAuthenticated, true);
      expect(state.needsVerification, false);
      expect(state.isNewUser, false);
    });

    test('unverified state has correct values', () {
      final user = User(
        id: '1',
        email: 'test@test.com',
        username: 'test',
        createdAt: DateTime.now(),
      );
      final state = AuthState.unverified(user);
      expect(state.isLoading, false);
      expect(state.user, user);
      expect(state.error, null);
      expect(state.errorCode, null);
      expect(state.requiresEmailVerification, true);
      expect(state.requiresPasswordReset, false);
      expect(state.isLoggedIn, false);
      expect(state.isAuthenticated, true);
      expect(state.needsVerification, true);
      expect(state.isNewUser, true);
    });

    test('copyWith creates new instance with updated values', () {
      final user = User(
        id: '1',
        email: 'test@test.com',
        username: 'test',
        createdAt: DateTime.now(),
      );
      const state = AuthState.initial();
      final newState = state.copyWith(
        user: user,
        isLoading: true,
        error: 'Test error',
        errorCode: 'ERROR_CODE',
        requiresEmailVerification: true,
        requiresPasswordReset: true,
      );

      expect(newState.user, user);
      expect(newState.isLoading, true);
      expect(newState.error, 'Test error');
      expect(newState.errorCode, 'ERROR_CODE');
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
      final state = AuthState.authenticated(user);
      final newState = state.copyWith();

      expect(newState.user, state.user);
      expect(newState.isLoading, state.isLoading);
      expect(newState.error, state.error);
      expect(newState.errorCode, state.errorCode);
      expect(
          newState.requiresEmailVerification, state.requiresEmailVerification);
      expect(newState.requiresPasswordReset, state.requiresPasswordReset);
    });

    test('props contains all properties', () {
      final user = User(
        id: '1',
        email: 'test@test.com',
        username: 'test',
        createdAt: DateTime.now(),
      );
      final state = AuthState(
        user: user,
        isLoading: true,
        error: 'Test error',
        errorCode: 'ERROR_CODE',
        requiresEmailVerification: true,
        requiresPasswordReset: true,
      );

      expect(state.props, [
        user,
        true,
        'Test error',
        'ERROR_CODE',
        true,
        true,
      ]);
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
        isLoading: true,
        error: 'Test error',
        errorCode: 'ERROR_CODE',
        requiresEmailVerification: true,
        requiresPasswordReset: true,
      );

      expect(
        state.toString(),
        'AuthState(user: $user, isLoading: true, error: Test error, errorCode: ERROR_CODE, requiresEmailVerification: true, requiresPasswordReset: true)',
      );
    });
  });
}
