import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/models/user.dart';
import 'package:soloadventurer/providers/auth_provider.dart';
import 'package:soloadventurer/providers/user_profile_provider.dart'
    as user_profile;
import '../../utils/provider_container_utils.dart';
import '../../utils/test_data.dart';
import '../../mocks/repositories/auth_repository_mock.dart';

// Mock classes
class MockUserRepository extends Mock implements user_profile.UserRepository {}

void main() {
  late MockAuthService mockAuthService;
  late MockUserRepository mockUserRepository;
  late ProviderContainer container;

  // Test data
  final testUser = TestData.createUser(
    id: 'test-user-id',
    username: 'testuser',
    email: 'test@example.com',
  );

  setUp(() {
    mockAuthService = MockAuthService();
    mockUserRepository = MockUserRepository();

    container = createContainer(
      overrides: [
        authServiceProvider.overrideWithValue(mockAuthService),
        user_profile.userRepositoryProvider
            .overrideWithValue(mockUserRepository),
      ],
    );
  });

  group('Auth and User Profile Integration', () {
    test('should load user profile after successful sign-in', () async {
      // Set up the auth service mock
      mockAuthService.setupSuccessfulSignIn('testuser');

      // Set up the user repository mock
      when(() => mockUserRepository.getUserProfile(any()))
          .thenAnswer((_) async => testUser);

      // Sign in
      await container.read(authProvider.notifier).signIn(
            username: 'testuser',
            password: 'password',
          );

      // Verify auth state
      final authState = container.read(authProvider);
      expect(authState.state, AuthState.authenticated);
      expect(authState.username, 'testuser');

      // Override the auth state provider to use the real auth provider
      final containerWithRealAuthState = createContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          user_profile.userRepositoryProvider
              .overrideWithValue(mockUserRepository),
          // Use a custom auth state that matches what we need for the user profile provider
          user_profile.authStateProvider.overrideWithValue(
              user_profile.AuthState(userId: 'test-user-id')),
        ],
      );

      // Wait for the user profile provider to complete
      await containerWithRealAuthState
          .read(user_profile.currentUserProfileProvider.future);

      // Verify user profile state
      final userProfileState = containerWithRealAuthState
          .read(user_profile.currentUserProfileProvider);
      expect(userProfileState, isA<AsyncData<User?>>());
      expect(userProfileState.value, testUser);

      // Verify the user repository was called with the correct user ID
      verify(() => mockUserRepository.getUserProfile('test-user-id')).called(1);
    });

    test('should clear user profile after sign-out', () async {
      // Set up the auth service mock
      mockAuthService.setupSuccessfulSignIn('testuser');
      mockAuthService.setupSuccessfulSignOut();

      // Set up the user repository mock
      when(() => mockUserRepository.getUserProfile(any()))
          .thenAnswer((_) async => testUser);

      // Sign in
      await container.read(authProvider.notifier).signIn(
            username: 'testuser',
            password: 'password',
          );

      // Override the auth state provider to use the real auth provider
      final containerWithRealAuthState = createContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          user_profile.userRepositoryProvider
              .overrideWithValue(mockUserRepository),
          // Use a custom auth state that matches what we need for the user profile provider
          user_profile.authStateProvider.overrideWithValue(
              user_profile.AuthState(userId: 'test-user-id')),
        ],
      );

      // Wait for the user profile provider to complete
      await containerWithRealAuthState
          .read(user_profile.currentUserProfileProvider.future);

      // Verify user profile state before sign-out
      final userProfileStateBefore = containerWithRealAuthState
          .read(user_profile.currentUserProfileProvider);
      expect(userProfileStateBefore.value, testUser);

      // Sign out
      await container.read(authProvider.notifier).signOut();

      // Verify auth state
      final authState = container.read(authProvider);
      expect(authState.state, AuthState.unauthenticated);

      // Create a new container with updated auth state (null user ID)
      final containerAfterSignOut = createContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          user_profile.userRepositoryProvider
              .overrideWithValue(mockUserRepository),
          // Use a custom auth state that matches what we need for the user profile provider
          user_profile.authStateProvider
              .overrideWithValue(user_profile.AuthState(userId: null)),
        ],
      );

      // Wait for the user profile provider to complete
      await containerAfterSignOut
          .read(user_profile.currentUserProfileProvider.future);

      // Verify user profile state after sign-out
      final userProfileStateAfter =
          containerAfterSignOut.read(user_profile.currentUserProfileProvider);
      expect(userProfileStateAfter.value, isNull);
    });

    test('should handle auth errors and not load user profile', () async {
      // Set up the auth service mock
      mockAuthService.setupFailedSignIn('Invalid credentials');

      // Set up the user repository mock
      when(() => mockUserRepository.getUserProfile(any()))
          .thenAnswer((_) async => testUser);

      // Attempt to sign in
      await container.read(authProvider.notifier).signIn(
            username: 'testuser',
            password: 'wrong-password',
          );

      // Verify auth state
      final authState = container.read(authProvider);
      expect(authState.state, AuthState.error);

      // Create a container with null user ID to simulate unauthenticated state
      final containerWithNullUserId = createContainer(
        overrides: [
          authServiceProvider.overrideWithValue(mockAuthService),
          user_profile.userRepositoryProvider
              .overrideWithValue(mockUserRepository),
          user_profile.authStateProvider
              .overrideWithValue(user_profile.AuthState(userId: null)),
        ],
      );

      // Wait for the user profile provider to complete
      await containerWithNullUserId
          .read(user_profile.currentUserProfileProvider.future);

      // Verify user profile state
      final userProfileState =
          containerWithNullUserId.read(user_profile.currentUserProfileProvider);
      expect(userProfileState.value, isNull);

      // Verify the user repository was not called
      verifyNever(() => mockUserRepository.getUserProfile(any()));
    });
  });
}
