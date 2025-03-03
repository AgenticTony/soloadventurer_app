import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/auth/presentation/state/auth_state.dart';

void main() {
  group('AuthState', () {
    const testEmail = 'test@example.com';
    final testUser = User(
      id: '1',
      email: testEmail,
      username: 'testuser',
      createdAt: DateTime(2024),
    );

    test('initial state should have default values', () {
      const state = AuthState();

      expect(state.isLoading, false);
      expect(state.user, null);
      expect(state.error, null);
      expect(state.isAuthenticated, false);
    });

    test('AuthState.initial() should create initial state', () {
      final state = AuthState.initial();

      expect(state.isLoading, false);
      expect(state.user, null);
      expect(state.error, null);
      expect(state.isAuthenticated, false);
    });

    test('AuthState.loading() should create loading state', () {
      final state = AuthState.loading();

      expect(state.isLoading, true);
      expect(state.user, null);
      expect(state.error, null);
      expect(state.isAuthenticated, false);
    });

    test('AuthState.authenticated() should create authenticated state', () {
      final state = AuthState.authenticated(testUser);

      expect(state.isLoading, false);
      expect(state.user, testUser);
      expect(state.error, null);
      expect(state.isAuthenticated, true);
    });

    test('AuthState.error() should create error state', () {
      const errorMessage = 'Test error';
      final state = AuthState.error(errorMessage);

      expect(state.isLoading, false);
      expect(state.user, null);
      expect(state.error, errorMessage);
      expect(state.isAuthenticated, false);
    });

    test('copyWith should only change specified fields', () {
      const initialState = AuthState();

      final loadingState = initialState.copyWith(isLoading: true);
      expect(loadingState.isLoading, true);
      expect(loadingState.user, null);
      expect(loadingState.error, null);

      final authenticatedState = loadingState.copyWith(user: testUser);
      expect(authenticatedState.isLoading, true);
      expect(authenticatedState.user, testUser);
      expect(authenticatedState.error, null);

      final errorState = authenticatedState.copyWith(error: 'Test error');
      expect(errorState.isLoading, true);
      expect(errorState.user, testUser);
      expect(errorState.error, 'Test error');
    });

    test('props should contain all properties', () {
      final state = AuthState(
        isLoading: true,
        user: testUser,
        error: 'Test error',
      );

      expect(state.props, [true, testUser, 'Test error']);
    });

    test('states with same values should be equal', () {
      final state1 = AuthState(
        isLoading: true,
        user: testUser,
        error: 'Test error',
      );

      final state2 = AuthState(
        isLoading: true,
        user: testUser,
        error: 'Test error',
      );

      expect(state1, state2);
    });
  });
}
