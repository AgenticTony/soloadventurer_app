import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/providers/auth_provider.dart';
import 'package:soloadventurer/services/auth_service.dart';
import 'package:soloadventurer/test_utils/provider_test_utils.dart';

// Create a provider for testing
final authServiceProvider = Provider<AuthService>((ref) => MockAuthService());
final authNotifierProvider = StateNotifierProvider<AuthNotifier, AuthStateData>(
  (ref) => AuthNotifier(ref.watch(authServiceProvider)),
);

void main() {
  late ProviderTestHelper testHelper;
  late MockAuthService mockAuthService;

  setUp(() {
    mockAuthService = MockAuthService();
    testHelper = ProviderTestHelper(
      overrides: [
        authServiceProvider.overrideWithValue(mockAuthService),
      ],
    );
  });

  tearDown(() {
    testHelper.dispose();
  });

  group('AuthNotifier', () {
    test('initial state should be loading', () {
      final authState = testHelper.container.read(authNotifierProvider);
      expect(authState.state, AuthState.loading);
    });

    test('signIn success should update state to authenticated', () async {
      // Arrange
      when(() => mockAuthService.signIn(
            username: any(named: 'username'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => true);

      // Get the notifier
      final notifier = testHelper.container.read(authNotifierProvider.notifier);

      // Act
      await notifier.signIn(username: 'testuser', password: 'password');

      // Assert
      final authState = testHelper.container.read(authNotifierProvider);
      expect(authState.state, AuthState.authenticated);
      expect(authState.username, 'testuser');
      expect(authState.errorMessage, null);

      // Verify
      verify(() => mockAuthService.signIn(
            username: 'testuser',
            password: 'password',
          )).called(1);
    });

    test('signIn failure should update state to error', () async {
      // Arrange
      when(() => mockAuthService.signIn(
            username: any(named: 'username'),
            password: any(named: 'password'),
          )).thenAnswer((_) async => false);

      // Get the notifier
      final notifier = testHelper.container.read(authNotifierProvider.notifier);

      // Act
      await notifier.signIn(username: 'testuser', password: 'wrong_password');

      // Assert
      final authState = testHelper.container.read(authNotifierProvider);
      expect(authState.state, AuthState.error);
      expect(authState.errorMessage, 'Invalid credentials');

      // Verify
      verify(() => mockAuthService.signIn(
            username: 'testuser',
            password: 'wrong_password',
          )).called(1);
    });

    test('signUp success should update state to unauthenticated with username',
        () async {
      // Arrange
      when(() => mockAuthService.signUp(
            username: any(named: 'username'),
            password: any(named: 'password'),
            email: any(named: 'email'),
            firstName: any(named: 'firstName'),
            lastName: any(named: 'lastName'),
            displayName: any(named: 'displayName'),
          )).thenAnswer((_) async => true);

      // Get the notifier
      final notifier = testHelper.container.read(authNotifierProvider.notifier);

      // Act
      await notifier.signUp(
        username: 'newuser',
        password: 'password123',
        email: 'newuser@example.com',
        firstName: 'New',
        lastName: 'User',
        displayName: 'NewUser',
      );

      // Assert
      final authState = testHelper.container.read(authNotifierProvider);
      expect(authState.state, AuthState.unauthenticated);
      expect(authState.username, 'newuser');
      expect(authState.errorMessage, null);

      // Verify
      verify(() => mockAuthService.signUp(
            username: 'newuser',
            password: 'password123',
            email: 'newuser@example.com',
            firstName: 'New',
            lastName: 'User',
            displayName: 'NewUser',
          )).called(1);
    });
  });
}
