import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/profile/data/datasources/profile_local_data_source.dart';
import 'package:soloadventurer/features/profile/data/models/profile_model.dart';
import 'mock_secure_storage.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {
  final Map<String, String> _data = {};

  @override
  String? getString(String key) {
    return _data[key];
  }

  @override
  Future<bool> setString(String key, Object? value) async {
    if (value is String) {
      _data[key] = value;
    }
    return true;
  }

  @override
  Future<bool> remove(String key) async {
    _data.remove(key);
    return true;
  }
}

void main() {
  late ProfileLocalDataSourceImpl dataSource;
  late MockSecureStorage mockStorage;
  late MockSharedPreferences mockPrefs;

  const tUserId = 'test_user_id';

  final tProfile = ProfileModel(
    id: 'test_id',
    userId: tUserId,
    username: 'testuser',
    email: 'test@example.com',
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
    mockPrefs = MockSharedPreferences();
    dataSource = ProfileLocalDataSourceImpl(
      storage: mockStorage,
      sharedPreferences: mockPrefs,
    );
  });

  group('createProfile', () {
    test('should store profile in shared preferences', () async {
      await dataSource.createProfile(tProfile);

      final key = 'CACHED_PROFILE_${tProfile.userId}';
      expect(mockPrefs.getString(key), isNotNull);
      final stored = jsonDecode(mockPrefs.getString(key)!);
      expect(stored['id'], tProfile.id);
    });
  });

  group('cacheProfile', () {
    test('should cache profile data and update timestamp', () async {
      when(mockStorage.write(
        'profile_last_update',
        '2024-01-01T00:00:00.000',
      )).thenAnswer((_) async {});

      await dataSource.cacheProfile(tProfile);

      final key = 'CACHED_PROFILE_${tProfile.userId}';
      expect(mockPrefs.getString(key), isNotNull);
    });
  });

  group('getCachedProfile', () {
    test('should return cached profile when cache is valid', () async {
      when(mockStorage.read('profile_last_update'))
          .thenAnswer((_) async => DateTime.now().toIso8601String());
      final key = 'CACHED_PROFILE_$tUserId';
      await mockPrefs.setString(key, jsonEncode(tProfile.toJson()));

      final result = await dataSource.getCachedProfile(tUserId);

      expect(result.id, tProfile.id);
      expect(result.userId, tProfile.userId);
      expect(result.displayName, tProfile.displayName);
    });

    test('should throw CacheException when cache is expired', () async {
      final expiredDate = DateTime.now().subtract(
        const Duration(hours: 25),
      );
      when(mockStorage.read('profile_last_update'))
          .thenAnswer((_) async => expiredDate.toIso8601String());
      when(mockStorage.delete('CACHED_PROFILE_$tUserId'))
          .thenAnswer((_) async {});
      when(mockStorage.delete('profile_last_update'))
          .thenAnswer((_) async {});

      expect(
        () => dataSource.getCachedProfile(tUserId),
        throwsA(isA<CacheException>()),
      );
    });

    test('should throw CacheException when no cached data found', () async {
      when(mockStorage.read('profile_last_update'))
          .thenAnswer((_) async => DateTime.now().toIso8601String());

      expect(
        () => dataSource.getCachedProfile(tUserId),
        throwsA(isA<CacheException>()),
      );
    });

    test('should throw CacheException when stored data is invalid', () async {
      when(mockStorage.read('profile_last_update'))
          .thenAnswer((_) async => DateTime.now().toIso8601String());
      when(mockStorage.delete('CACHED_PROFILE_$tUserId'))
          .thenAnswer((_) async {});
      when(mockStorage.delete('profile_last_update'))
          .thenAnswer((_) async {});

      final key = 'CACHED_PROFILE_$tUserId';
      await mockPrefs.setString(key, 'invalid_json');

      expect(
        () => dataSource.getCachedProfile(tUserId),
        throwsA(isA<CacheException>()),
      );
    });
  });

  group('clearCachedProfile', () {
    test('should clear cached profile data', () async {
      when(mockStorage.delete('profile_last_update'))
          .thenAnswer((_) async {});

      await dataSource.clearCachedProfile(tUserId);

      final key = 'CACHED_PROFILE_$tUserId';
      expect(mockPrefs.getString(key), isNull);
      verify(mockStorage.delete('profile_last_update'));
    });
  });

  group('preferences', () {
    final tPreferences = {'theme': 'dark', 'notifications': true};

    test('should cache and retrieve preferences', () async {
      when(mockStorage.write(
        'profile_preferences_$tUserId',
        jsonEncode(tPreferences),
      )).thenAnswer((_) async {});
      when(mockStorage.read('profile_last_update'))
          .thenAnswer((_) async => DateTime.now().toIso8601String());
      when(mockStorage.read('profile_preferences_$tUserId'))
          .thenAnswer((_) async => jsonEncode(tPreferences));

      await dataSource.cachePreferences(tUserId, tPreferences);
      final result = await dataSource.getCachedPreferences(tUserId);

      expect(result, equals(tPreferences));
      verify(mockStorage.write(
        'profile_preferences_$tUserId',
        jsonEncode(tPreferences),
      ));
    });
  });

  group('interests', () {
    final tInterests = ['coding', 'testing', 'flutter'];

    test('should cache and retrieve interests', () async {
      when(mockStorage.write(
        'profile_interests_$tUserId',
        jsonEncode(tInterests),
      )).thenAnswer((_) async {});
      when(mockStorage.read('profile_last_update'))
          .thenAnswer((_) async => DateTime.now().toIso8601String());
      when(mockStorage.read('profile_interests_$tUserId'))
          .thenAnswer((_) async => jsonEncode(tInterests));

      await dataSource.cacheInterests(tUserId, tInterests);
      final result = await dataSource.getCachedInterests(tUserId);

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
      final expiredDate = DateTime.now().subtract(
        const Duration(hours: 25),
      );
      when(mockStorage.read('profile_last_update'))
          .thenAnswer((_) async => expiredDate.toIso8601String());

      final result = await dataSource.isCacheExpired();

      expect(result, isTrue);
    });

    test('should return false when last update is within expiration duration',
        () async {
      final validDate = DateTime.now().subtract(
        const Duration(hours: 23),
      );
      when(mockStorage.read('profile_last_update'))
          .thenAnswer((_) async => validDate.toIso8601String());

      final result = await dataSource.isCacheExpired();

      expect(result, isFalse);
    });

    test('should return true when last update timestamp is missing', () async {
      when(mockStorage.read('profile_last_update'))
          .thenAnswer((_) async => null);

      final result = await dataSource.isCacheExpired();

      expect(result, isTrue);
    });
  });
}
