import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:soloadventurer/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:soloadventurer/features/profile/data/models/profile_model.dart';
import 'mock_secure_storage.dart';

void main() {
  late ProfileLocalDataSourceImpl dataSource;
  late MockSecureStorage mockStorage;

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
    mockStorage = MockSecureStorage();
    dataSource = ProfileLocalDataSourceImpl(storage: mockStorage);
  });

  group('cacheProfile', () {
    test('should cache profile data and update timestamp', () async {
      // arrange
      when(mockStorage.write(any, any)).thenAnswer((_) async {
        return;
      });

      // act
      await dataSource.cacheProfile(tProfile);

      // assert
      verify(mockStorage.write(
        'cached_profile',
        jsonEncode(tProfile.toJson()),
      ));
      verify(mockStorage.write(
        'profile_last_update',
        any,
      ));
    });
  });

  group('getCachedProfile', () {
    test('should return cached profile when cache is valid', () async {
      // arrange
      final now = DateTime.now();
      when(mockStorage.read('profile_last_update'))
          .thenAnswer((_) async => now.toIso8601String());
      when(mockStorage.read('cached_profile'))
          .thenAnswer((_) async => jsonEncode(tProfile.toJson()));

      // act
      final result = await dataSource.getCachedProfile();

      // assert
      expect(result, equals(tProfile));
      verify(mockStorage.read('profile_last_update'));
      verify(mockStorage.read('cached_profile'));
    });

    test('should return null when cache is expired', () async {
      // arrange
      final expiredDate = DateTime.now().subtract(
        const Duration(hours: 25), // More than cache expiration
      );
      when(mockStorage.read('profile_last_update'))
          .thenAnswer((_) async => expiredDate.toIso8601String());
      when(mockStorage.delete(any)).thenAnswer((_) async {
        return;
      });

      // act
      final result = await dataSource.getCachedProfile();

      // assert
      expect(result, isNull);
      verify(mockStorage.read('profile_last_update'));
      verify(mockStorage.delete('cached_profile'));
      verify(mockStorage.delete('profile_last_update'));
    });

    test('should return null and clear cache when stored data is invalid',
        () async {
      // arrange
      final now = DateTime.now();
      when(mockStorage.read('profile_last_update'))
          .thenAnswer((_) async => now.toIso8601String());
      when(mockStorage.read('cached_profile'))
          .thenAnswer((_) async => 'invalid_json');
      when(mockStorage.delete(any)).thenAnswer((_) async {
        return;
      });

      // act
      final result = await dataSource.getCachedProfile();

      // assert
      expect(result, isNull);
      verify(mockStorage.delete('cached_profile'));
      verify(mockStorage.delete('profile_last_update'));
    });
  });

  group('clearCache', () {
    test('should clear all cached data', () async {
      // arrange
      when(mockStorage.delete(any)).thenAnswer((_) async {
        return;
      });

      // act
      await dataSource.clearCache();

      // assert
      verify(mockStorage.delete('cached_profile'));
      verify(mockStorage.delete('profile_last_update'));
    });
  });

  group('preferences', () {
    final tPreferences = {'theme': 'dark', 'notifications': true};
    const tUserId = 'test_user_id';

    test('should cache and retrieve preferences', () async {
      // arrange
      when(mockStorage.write(any, any)).thenAnswer((_) async {
        return;
      });
      when(mockStorage.read('profile_last_update'))
          .thenAnswer((_) async => DateTime.now().toIso8601String());
      when(mockStorage.read('profile_preferences_$tUserId'))
          .thenAnswer((_) async => jsonEncode(tPreferences));

      // act
      await dataSource.cachePreferences(tUserId, tPreferences);
      final result = await dataSource.getCachedPreferences(tUserId);

      // assert
      expect(result, equals(tPreferences));
      verify(mockStorage.write(
        'profile_preferences_$tUserId',
        jsonEncode(tPreferences),
      ));
    });
  });

  group('interests', () {
    final tInterests = ['coding', 'testing', 'flutter'];
    const tUserId = 'test_user_id';

    test('should cache and retrieve interests', () async {
      // arrange
      when(mockStorage.write(any, any)).thenAnswer((_) async {
        return;
      });
      when(mockStorage.read('profile_last_update'))
          .thenAnswer((_) async => DateTime.now().toIso8601String());
      when(mockStorage.read('profile_interests_$tUserId'))
          .thenAnswer((_) async => jsonEncode(tInterests));

      // act
      await dataSource.cacheInterests(tUserId, tInterests);
      final result = await dataSource.getCachedInterests(tUserId);

      // assert
      expect(result, equals(tInterests));
      verify(mockStorage.write(
        'profile_interests_$tUserId',
        jsonEncode(tInterests),
      ));
    });
  });

  group('isCacheExpired', () {
    test(
        'should return true when last update is older than expiration duration',
        () async {
      // arrange
      final expiredDate = DateTime.now().subtract(
        const Duration(hours: 25), // More than cache expiration
      );
      when(mockStorage.read('profile_last_update'))
          .thenAnswer((_) async => expiredDate.toIso8601String());

      // act
      final result = await dataSource.isCacheExpired();

      // assert
      expect(result, isTrue);
    });

    test('should return false when last update is within expiration duration',
        () async {
      // arrange
      final validDate = DateTime.now().subtract(
        const Duration(hours: 23), // Less than cache expiration
      );
      when(mockStorage.read('profile_last_update'))
          .thenAnswer((_) async => validDate.toIso8601String());

      // act
      final result = await dataSource.isCacheExpired();

      // assert
      expect(result, isFalse);
    });

    test('should return true when last update timestamp is missing', () async {
      // arrange
      when(mockStorage.read('profile_last_update'))
          .thenAnswer((_) async => null);

      // act
      final result = await dataSource.isCacheExpired();

      // assert
      expect(result, isTrue);
    });

    test('should return true when last update timestamp is invalid', () async {
      // arrange
      when(mockStorage.read('profile_last_update'))
          .thenAnswer((_) async => 'invalid_date');

      // act
      final result = await dataSource.isCacheExpired();

      // assert
      expect(result, isTrue);
    });
  });
}
