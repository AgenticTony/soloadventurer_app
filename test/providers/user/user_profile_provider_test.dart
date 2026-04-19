import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/profile/presentation/providers/user_profile_provider.dart';
import 'package:soloadventurer/features/core/infrastructure/api/api_service.dart';
import '../../utils/provider_container_utils.dart';

// Mock classes
class MockApiService extends Mock implements ApiService {}

class MockUserRepository extends Mock implements UserRepository {}

void main() {
  late MockApiService mockApiService;
  late MockUserRepository mockUserRepository;
  late ProviderContainer container;

  // Test data
  final testUser = User(
    id: 'test-user-id',
    username: 'testuser',
    email: 'test@example.com',
    createdAt: DateTime(2024, 1, 1),
  );

  const testUserId = 'test-user-id';

  setUp(() {
    mockApiService = MockApiService();
    mockUserRepository = MockUserRepository();

    container = createContainer(
      overrides: [
        apiServiceProvider.overrideWithValue(mockApiService),
        userRepositoryProvider.overrideWithValue(mockUserRepository),
      ],
    );
  });

  group('userProfileProvider', () {
    test('should return loading state initially', () {
      when(() => mockUserRepository.getUserProfile(testUserId))
          .thenAnswer((_) async => testUser);

      final userProfileAsync =
          container.read(userProfileProvider(testUserId));

      expect(userProfileAsync, isA<AsyncLoading<User?>>());
    });

    test('should return data state when repository returns data', () async {
      when(() => mockUserRepository.getUserProfile(testUserId))
          .thenAnswer((_) async => testUser);

      // Wait for the provider to complete
      await container.read(userProfileProvider(testUserId).future);

      final userProfileAsync =
          container.read(userProfileProvider(testUserId));

      expect(userProfileAsync, isA<AsyncData<User?>>());
      expect(userProfileAsync.value, testUser);
    });

    test('should return error state when repository throws', () async {
      when(() => mockUserRepository.getUserProfile(testUserId))
          .thenThrow(Exception('Failed to load profile'));

      // Read the provider and expect it to be in error state
      try {
        await container.read(userProfileProvider(testUserId).future);
      } catch (_) {}

      final userProfileAsync =
          container.read(userProfileProvider(testUserId));

      expect(userProfileAsync, isA<AsyncError>());
      expect(userProfileAsync.error, isA<Exception>());
    });
  });

  group('userProfileNotifier', () {
    test('loads user profile on initialization', () async {
      when(() => mockUserRepository.getUserProfile(any()))
          .thenAnswer((_) async => testUser);

      final testContainer = createContainer(
        overrides: [
          userRepositoryProvider.overrideWithValue(mockUserRepository),
        ],
      );

      // Read the provider to trigger initialization
      testContainer.read(userProfileProvider(testUserId).notifier);

      // Wait for the async operation to complete
      await Future.delayed(Duration.zero);

      verify(() => mockUserRepository.getUserProfile(testUserId))
          .called(greaterThanOrEqualTo(1));
    });

    test('should update user profile when updateProfile is called', () async {
      when(() => mockUserRepository.getUserProfile(testUserId))
          .thenAnswer((_) async => testUser);

      final updatedUser = testUser.copyWith(
        username: 'updateduser',
      );

      when(() => mockUserRepository.updateUserProfile(
            testUserId,
            any(),
          )).thenAnswer((_) async => updatedUser);

      // Read the provider to trigger initialization
      final notifier =
          container.read(userProfileProvider(testUserId).notifier);

      // Wait for the initial load to complete
      await container.read(userProfileProvider(testUserId).future);

      // Update the profile
      await notifier.updateProfile({
        'username': 'updateduser',
      });

      // Verify the state
      final state = container.read(userProfileProvider(testUserId));
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
          container.read(userProfileProvider(testUserId).notifier);

      // Wait for the initial load to complete
      await container.read(userProfileProvider(testUserId).future);

      // Update the profile
      await notifier.updateProfile({
        'username': 'updateduser',
      });

      // Verify the state
      final state = container.read(userProfileProvider(testUserId));
      expect(state, isA<AsyncError>());
      expect(state.error, isA<Exception>());
    });
  });

  group('userProfileLoading selector', () {
    test('returns true when loading', () {
      when(() => mockUserRepository.getUserProfile(testUserId))
          .thenAnswer((_) async => testUser);

      final isLoading =
          container.read(userProfileLoadingProvider(testUserId));
      expect(isLoading, true);
    });

    test('returns false when loaded', () async {
      when(() => mockUserRepository.getUserProfile(testUserId))
          .thenAnswer((_) async => testUser);

      await container.read(userProfileProvider(testUserId).future);

      final isLoading =
          container.read(userProfileLoadingProvider(testUserId));
      expect(isLoading, false);
    });
  });

  group('userProfileError selector', () {
    test('returns null when no error', () async {
      when(() => mockUserRepository.getUserProfile(testUserId))
          .thenAnswer((_) async => testUser);

      await container.read(userProfileProvider(testUserId).future);

      final error =
          container.read(userProfileErrorProvider(testUserId));
      expect(error, isNull);
    });

    test('returns error string when error occurs', () async {
      when(() => mockUserRepository.getUserProfile(testUserId))
          .thenThrow(Exception('Failed to load profile'));

      // Listen for state changes
      AsyncValue<User?>? capturedState;
      final sub = container.listen<AsyncValue<User?>>(
        userProfileProvider(testUserId),
        (_, next) => capturedState = next,
        fireImmediately: true,
      );

      // Wait for the provider to settle
      await container.read(userProfileProvider(testUserId).future).catchError((_) => null as User?);

      await Future.delayed(Duration.zero);

      final error =
          container.read(userProfileErrorProvider(testUserId));
      expect(error, isNotNull);

      sub.close();
    });
  });
}
