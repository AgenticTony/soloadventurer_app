import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/providers/auth_provider.dart';
import '../../../test/utils/provider_container_utils.dart';
import '../../../test/mocks/repositories/auth_repository_mock.dart';

void main() {
  late MockAuthService mockAuthService;
  late ProviderContainer container;

  setUp(() {
    mockAuthService = MockAuthService();

    container = createContainer(
      overrides: [
        authServiceProvider.overrideWithValue(mockAuthService),
      ],
    );
  });

  group('AuthProvider', () {
    test('initial state should be loading', () {
      final authState = container.read(authProvider);
      expect(authState.state, AuthState.initial);
    });

    test('sign in success should update state to authenticated', () async {
      // Arrange
      mockAuthService.setupSuccessfulSignIn('testuser');

      // Act
      await container.read(authProvider.notifier).signIn(
            username: 'testuser',
            password: 'password',
          );

      // Assert
      final authState = container.read(authProvider);
      expect(authState.state, AuthState.authenticated);
      expect(authState.username, 'testuser');
    });

    test('sign in failure should update state to error', () async {
      // Arrange
      mockAuthService.setupFailedSignIn('Invalid credentials');

      // Act
      await container.read(authProvider.notifier).signIn(
            username: 'testuser',
            password: 'wrong-password',
          );

      // Assert
      final authState = container.read(authProvider);
      expect(authState.state, AuthState.error);
      expect(authState.errorMessage, isNotNull);
    });

    test('sign out should update state to unauthenticated', () async {
      // Arrange
      mockAuthService.setupSuccessfulSignIn('testuser');
      mockAuthService.setupSuccessfulSignOut();

      // First sign in
      await container.read(authProvider.notifier).signIn(
            username: 'testuser',
            password: 'password',
          );

      // Act
      await container.read(authProvider.notifier).signOut();

      // Assert
      final authState = container.read(authProvider);
      expect(authState.state, AuthState.unauthenticated);
      expect(authState.username, isNull);
    });
  });
}
