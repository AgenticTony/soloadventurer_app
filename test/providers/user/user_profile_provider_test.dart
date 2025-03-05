import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/models/user.dart';
import 'package:soloadventurer/providers/user_profile_provider.dart';
import 'package:soloadventurer/core/api/api_service.dart';
import '../../utils/provider_container_utils.dart';
import '../../utils/test_data.dart';
import '../../utils/provider_test_helpers.dart';

// Mock classes
class MockApiService extends Mock implements ApiService {}

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockApiService mockApiService;
  late MockUserRepository mockUserRepository;
  late ProviderContainer container;

  // Test data
  final testUser = TestData.createUser(
    id: 'test-user-id',
    username: 'testuser',
    email: 'test@example.com',
  );

  const testUserId = 'test-user-id';

  setUp(() {
    mockApiService = MockApiService();
    mockUserRepository = MockUserRepository();

    container = createContainer(
      overrides: [
        apiServiceProvider.overrideWithValue(mockApiService),
        userRepositoryProvider.overrideWithValue(mockUserRepository),
        // Override the auth state provider to return a fixed user ID
        authStateProvider.overrideWithValue(AuthState(userId: testUserId)),
      ],
    );
  });

  group('userProfileProvider', () {
    test('should return loading state initially', () {
      when(() => mockUserRepository.getUserProfile(testUserId))
          .thenAnswer((_) async => testUser);

      final userProfileAsync = container.read(userProfileProvider(testUserId));

      expect(userProfileAsync, isA<AsyncLoading<User>>());
    });

    test('should return data state when repository returns data', () async {
      when(() => mockUserRepository.getUserProfile(testUserId))
          .thenAnswer((_) async => testUser);

      // Wait for the provider to complete
      await container.read(userProfileProvider(testUserId).future);

      final userProfileAsync = container.read(userProfileProvider(testUserId));

      expect(userProfileAsync, isA<AsyncData<User>>());
      expect(userProfileAsync.value, testUser);
    });

    test('should return error state when repository throws', () async {
      when(() => mockUserRepository.getUserProfile(testUserId))
          .thenThrow(Exception('Failed to load profile'));

      // Wait for the provider to complete
      await expectLater(
        container.read(userProfileProvider(testUserId).future),
        throwsException,
      );

      final userProfileAsync = container.read(userProfileProvider(testUserId));

      expect(userProfileAsync, isA<AsyncError<User>>());
      expect(userProfileAsync.error, isA<Exception>());
    });
  });

  group('currentUserProfileProvider', () {
    test('should return loading state initially', () {
      when(() => mockUserRepository.getUserProfile(testUserId))
          .thenAnswer((_) async => testUser);

      final userProfileAsync = container.read(currentUserProfileProvider);

      expect(userProfileAsync, isA<AsyncLoading<User?>>());
    });

    test('should return data state when repository returns data', () async {
      when(() => mockUserRepository.getUserProfile(testUserId))
          .thenAnswer((_) async => testUser);

      // Wait for the provider to complete
      await container.read(currentUserProfileProvider.future);

      final userProfileAsync = container.read(currentUserProfileProvider);

      expect(userProfileAsync, isA<AsyncData<User?>>());
      expect(userProfileAsync.value, testUser);
    });

    test('should return null when user ID is null', () async {
      // Create a new container with a null user ID
      final nullUserContainer = createContainer(
        overrides: [
          apiServiceProvider.overrideWithValue(mockApiService),
          userRepositoryProvider.overrideWithValue(mockUserRepository),
          authStateProvider.overrideWithValue(AuthState(userId: null)),
        ],
      );

      // Wait for the provider to complete
      await nullUserContainer.read(currentUserProfileProvider.future);

      final userProfileAsync =
          nullUserContainer.read(currentUserProfileProvider);

      expect(userProfileAsync, isA<AsyncData<User?>>());
      expect(userProfileAsync.value, isNull);
    });
  });

  group('userProfileNotifierProvider', () {
    test('userProfileNotifierProvider loads user profile on initialization',
        () async {
      // Arrange
      when(() => mockUserRepository.getUserProfile(any()))
          .thenAnswer((_) async => testUser);

      // Act
      final container = createContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockUserRepository),
        ],
      );

      // Get the provider and wait for it to complete loading
      container.read(userProfileNotifierProvider('test-user-id').notifier);

      // Wait for the async operation to complete
      await Future.delayed(Duration.zero);

      // Assert
      verify(() => mockUserRepository.getUserProfile('test-user-id')).called(1);
    });

    test('should update user profile when updateProfile is called', () async {
      when(() => mockUserRepository.getUserProfile(testUserId))
          .thenAnswer((_) async => testUser);

      final updatedUser = testUser.copyWith(
        firstName: 'Updated',
        lastName: 'User',
      );

      when(() => mockUserRepository.updateUserProfile(
            testUserId,
            any(),
          )).thenAnswer((_) async => updatedUser);

      // Read the provider to trigger initialization
      final notifier =
          container.read(userProfileNotifierProvider(testUserId).notifier);

      // Wait for the initial load to complete
      await Future.delayed(Duration.zero);

      // Update the profile
      await notifier.updateProfile({
        'firstName': 'Updated',
        'lastName': 'User',
      });

      // Verify the state
      final state = container.read(userProfileNotifierProvider(testUserId));
      expect(state, isA<AsyncData<User?>>());
      expect(state.value, updatedUser);

      // Verify the repository was called
      verify(() => mockUserRepository.updateUserProfile(
            testUserId,
            any(),
          )).called(1);
    });

    test('should handle errors when updating profile', () async {
      when(() => mockUserRepository.getUserProfile(testUserId))
          .thenAnswer((_) async => testUser);

      when(() => mockUserRepository.updateUserProfile(
            testUserId,
            any(),
          )).thenThrow(Exception('Failed to update profile'));

      // Read the provider to trigger initialization
      final notifier =
          container.read(userProfileNotifierProvider(testUserId).notifier);

      // Wait for the initial load to complete
      await Future.delayed(Duration.zero);

      // Update the profile
      await notifier.updateProfile({
        'firstName': 'Updated',
        'lastName': 'User',
      });

      // Verify the state
      final state = container.read(userProfileNotifierProvider(testUserId));
      expect(state, isA<AsyncError<User?>>());
      expect(state.error, isA<Exception>());
    });
  });

  // Using the provider test helpers
  group('userProfileProvider with test helpers', () {
    testFutureProvider<User>(
      provider: userProfileProvider(testUserId),
      buildMocks: [
        () {
          when(() => mockUserRepository.getUserProfile(testUserId))
              .thenAnswer((_) async => testUser);
        },
      ],
      testCases: [
        FutureProviderTestCase(
          description: 'should load user profile successfully',
          action: (container) async {},
          expectedData: testUser,
        ),
      ],
    );

    testFutureProvider<User>(
      provider: userProfileProvider(testUserId),
      buildMocks: [
        () {
          when(() => mockUserRepository.getUserProfile(testUserId))
              .thenThrow(Exception('Failed to load profile'));
        },
      ],
      testCases: [
        FutureProviderTestCase(
          description: 'should handle errors when loading user profile',
          action: (container) async {},
          expectedError: isA<Exception>(),
        ),
      ],
    );
  });
}
