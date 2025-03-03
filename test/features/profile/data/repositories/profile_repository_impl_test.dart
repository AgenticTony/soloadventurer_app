import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:soloadventurer/features/profile/data/datasources/profile_remote_data_source.dart';
import 'package:soloadventurer/features/profile/data/models/profile_model.dart';
import 'package:soloadventurer/features/profile/data/repositories/profile_repository_impl.dart';
import 'package:soloadventurer/features/profile/domain/entities/profile.dart';

class MockProfileRemoteDataSource extends Mock
    implements ProfileRemoteDataSource {}

class MockProfileLocalDataSource extends Mock
    implements ProfileLocalDataSource {}

void main() {
  late ProfileRepositoryImpl repository;
  late MockProfileRemoteDataSource mockRemoteDataSource;
  late MockProfileLocalDataSource mockLocalDataSource;

  final tProfile = ProfileModel(
    id: 'test_id',
    userId: 'test_user_id',
    displayName: 'Test User',
    bio: 'Test bio',
    createdAt: DateTime(2024),
    updatedAt: DateTime(2024),
    preferences: const {'theme': 'dark'},
    interests: const ['coding', 'testing'],
    isPublic: true,
  );

  setUp(() {
    mockRemoteDataSource = MockProfileRemoteDataSource();
    mockLocalDataSource = MockProfileLocalDataSource();
    repository = ProfileRepositoryImpl(
      remoteDataSource: mockRemoteDataSource,
      localDataSource: mockLocalDataSource,
    );
  });

  group('getProfile', () {
    const tUserId = 'test_user_id';

    test(
        'should return remote data when the call to remote data source is successful',
        () async {
      // arrange
      when(mockRemoteDataSource.getProfile(tUserId))
          .thenAnswer((_) async => tProfile);
      when(mockLocalDataSource.cacheProfile(tProfile)).thenAnswer((_) async {});

      // act
      final result = await repository.getProfile(tUserId);

      // assert
      verify(mockRemoteDataSource.getProfile(tUserId));
      verify(mockLocalDataSource.cacheProfile(tProfile));
      expect(result, equals(tProfile));
    });

    test(
        'should return cached data when the call to remote data source fails with NetworkTimeoutException',
        () async {
      // arrange
      when(mockRemoteDataSource.getProfile(tUserId))
          .thenThrow(const NetworkTimeoutException(message: 'Timeout'));
      when(mockLocalDataSource.getCachedProfile())
          .thenAnswer((_) async => tProfile);

      // act
      final result = await repository.getProfile(tUserId);

      // assert
      verify(mockRemoteDataSource.getProfile(tUserId));
      verify(mockLocalDataSource.getCachedProfile());
      expect(result, equals(tProfile));
    });

    test(
        'should throw NetworkTimeoutException when remote call fails and no cache is available',
        () async {
      // arrange
      when(mockRemoteDataSource.getProfile(tUserId))
          .thenThrow(const NetworkTimeoutException(message: 'Timeout'));
      when(mockLocalDataSource.getCachedProfile())
          .thenAnswer((_) async => null);

      // act
      final call = repository.getProfile;

      // assert
      expect(() => call(tUserId), throwsA(isA<NetworkTimeoutException>()));
    });
  });

  group('getCurrentProfile', () {
    test(
        'should return remote data when the call to remote data source is successful',
        () async {
      // arrange
      when(mockRemoteDataSource.getCurrentProfile())
          .thenAnswer((_) async => tProfile);
      when(mockLocalDataSource.cacheProfile(tProfile)).thenAnswer((_) async {});

      // act
      final result = await repository.getCurrentProfile();

      // assert
      verify(mockRemoteDataSource.getCurrentProfile());
      verify(mockLocalDataSource.cacheProfile(tProfile));
      expect(result, equals(tProfile));
    });

    test(
        'should return cached data when the call to remote data source fails with NetworkConnectivityException',
        () async {
      // arrange
      when(mockRemoteDataSource.getCurrentProfile()).thenThrow(
          const NetworkConnectivityException(message: 'No connection'));
      when(mockLocalDataSource.getCachedProfile())
          .thenAnswer((_) async => tProfile);

      // act
      final result = await repository.getCurrentProfile();

      // assert
      verify(mockRemoteDataSource.getCurrentProfile());
      verify(mockLocalDataSource.getCachedProfile());
      expect(result, equals(tProfile));
    });
  });

  group('updateProfile', () {
    test('should update profile on remote data source and cache the result',
        () async {
      // arrange
      when(mockRemoteDataSource.updateProfile(tProfile))
          .thenAnswer((_) async => tProfile);
      when(mockLocalDataSource.cacheProfile(tProfile)).thenAnswer((_) async {});

      // act
      final result = await repository.updateProfile(tProfile);

      // assert
      verify(mockRemoteDataSource.updateProfile(tProfile));
      verify(mockLocalDataSource.cacheProfile(tProfile));
      expect(result, equals(tProfile));
    });

    test('should throw ArgumentError when profile is not a ProfileModel',
        () async {
      // arrange
      final invalidProfile = _TestProfile();

      // act
      final call = repository.updateProfile;

      // assert
      expect(() => call(invalidProfile), throwsA(isA<ArgumentError>()));
    });
  });

  group('uploadAvatar', () {
    const tUserId = 'test_user_id';
    const tFilePath = 'test/assets/test_avatar.jpg';
    const tAvatarUrl = 'https://example.com/avatars/test.jpg';

    test('should upload avatar and update cached profile', () async {
      // arrange
      when(mockRemoteDataSource.uploadAvatar(tUserId, tFilePath))
          .thenAnswer((_) async => tAvatarUrl);
      when(mockLocalDataSource.getCachedProfile())
          .thenAnswer((_) async => tProfile);
      when(mockLocalDataSource
              .cacheProfile(tProfile.copyWith(avatarUrl: tAvatarUrl)))
          .thenAnswer((_) async {});

      // act
      final result = await repository.uploadAvatar(tUserId, tFilePath);

      // assert
      verify(mockRemoteDataSource.uploadAvatar(tUserId, tFilePath));
      verify(mockLocalDataSource.getCachedProfile());
      verify(mockLocalDataSource
          .cacheProfile(tProfile.copyWith(avatarUrl: tAvatarUrl)));
      expect(result, equals(tAvatarUrl));
    });
  });

  group('updatePreferences', () {
    const tUserId = 'test_user_id';
    final tPreferences = {'theme': 'light', 'notifications': true};

    test('should update preferences on remote data source and cache them',
        () async {
      // arrange
      when(mockRemoteDataSource.updatePreferences(tUserId, tPreferences))
          .thenAnswer((_) async {});
      when(mockLocalDataSource.cachePreferences(tUserId, tPreferences))
          .thenAnswer((_) async {});
      when(mockLocalDataSource.getCachedProfile())
          .thenAnswer((_) async => tProfile);
      when(mockLocalDataSource
              .cacheProfile(tProfile.copyWith(preferences: tPreferences)))
          .thenAnswer((_) async {});

      // act
      await repository.updatePreferences(tUserId, tPreferences);

      // assert
      verify(mockRemoteDataSource.updatePreferences(tUserId, tPreferences));
      verify(mockLocalDataSource.cachePreferences(tUserId, tPreferences));
      verify(mockLocalDataSource.getCachedProfile());
      verify(mockLocalDataSource
          .cacheProfile(tProfile.copyWith(preferences: tPreferences)));
    });
  });

  group('updateInterests', () {
    const tUserId = 'test_user_id';
    final tInterests = ['reading', 'writing', 'coding'];

    test('should update interests on remote data source and cache them',
        () async {
      // arrange
      when(mockRemoteDataSource.updateInterests(tUserId, tInterests))
          .thenAnswer((_) async {});
      when(mockLocalDataSource.cacheInterests(tUserId, tInterests))
          .thenAnswer((_) async {});
      when(mockLocalDataSource.getCachedProfile())
          .thenAnswer((_) async => tProfile);
      when(mockLocalDataSource
              .cacheProfile(tProfile.copyWith(interests: tInterests)))
          .thenAnswer((_) async {});

      // act
      await repository.updateInterests(tUserId, tInterests);

      // assert
      verify(mockRemoteDataSource.updateInterests(tUserId, tInterests));
      verify(mockLocalDataSource.cacheInterests(tUserId, tInterests));
      verify(mockLocalDataSource.getCachedProfile());
      verify(mockLocalDataSource
          .cacheProfile(tProfile.copyWith(interests: tInterests)));
    });
  });

  group('profileExists', () {
    const tUserId = 'test_user_id';

    test('should return true when profile exists on remote data source',
        () async {
      // arrange
      when(mockRemoteDataSource.profileExists(tUserId))
          .thenAnswer((_) async => true);

      // act
      final result = await repository.profileExists(tUserId);

      // assert
      verify(mockRemoteDataSource.profileExists(tUserId));
      expect(result, isTrue);
    });

    test('should check cached profile when remote call fails', () async {
      // arrange
      when(mockRemoteDataSource.profileExists(tUserId))
          .thenThrow(const NetworkTimeoutException(message: 'Timeout'));
      when(mockLocalDataSource.getCachedProfile())
          .thenAnswer((_) async => tProfile);

      // act
      final result = await repository.profileExists(tUserId);

      // assert
      verify(mockRemoteDataSource.profileExists(tUserId));
      verify(mockLocalDataSource.getCachedProfile());
      expect(result, isTrue);
    });
  });
}

class _TestProfile extends Profile {
  _TestProfile()
      : super(
          id: 'test_id',
          userId: 'test_user_id',
          displayName: 'Test User',
          bio: 'Test bio',
          createdAt: DateTime(2024),
          updatedAt: DateTime(2024),
          preferences: const {},
          interests: const [],
          isPublic: true,
        );
}
