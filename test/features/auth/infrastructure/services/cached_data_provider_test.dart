import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/cached_data_provider.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/offline_auth_manager.dart';
import 'package:soloadventurer/features/core/domain/services/connectivity_service.dart';

// Mocks
class MockOfflineAuthManager extends Mock implements OfflineAuthManager {}

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  group('CachedDataProvider', () {
    late CachedDataProvider provider;
    late MockOfflineAuthManager mockOfflineAuthManager;
    late MockAuthLocalDataSource mockLocalDataSource;

    // Test data
    final testUser = User(
      id: 'test-user-id',
      email: 'test@example.com',
      username: 'testuser',
      createdAt: DateTime(2024, 1, 1, 12, 0, 0),
      lastLoginAt: DateTime(2024, 1, 15, 10, 30, 0),
    );

    final testUserData = {
      'id': 'test-user-id',
      'email': 'test@example.com',
      'username': 'testuser',
      'created_at': '2024-01-01T12:00:00.000Z',
      'last_login_at': '2024-01-15T10:30:00.000Z',
      'cached_at': '2024-01-15T10:30:00.000Z',
    };

    setUp(() {
      mockOfflineAuthManager = MockOfflineAuthManager();
      mockLocalDataSource = MockAuthLocalDataSource();

      provider = CachedDataProvider(
        offlineAuthManager: mockOfflineAuthManager,
        localDataSource: mockLocalDataSource,
      );

      // Register fallback values
      registerFallbackValue(const NetworkStatus.connected);
    });

    group('getCachedUserProfile', () {
      test('should return cached user profile when available', () async {
        // Arrange
        when(() => mockLocalDataSource.getUserData())
            .thenAnswer((_) async => testUserData);

        // Act
        final result = await provider.getCachedUserProfile();

        // Assert
        expect(result.success, true);
        expect(result.data, isNotNull);
        expect(result.data!.id, testUser.id);
        expect(result.data!.email, testUser.email);
        expect(result.data!.username, testUser.username);
        expect(result.isFromCache, true);
        expect(result.isFresh, true); // Within 24 hours
        expect(result.cachedAt, isNotNull);
      });

      test('should return no data when no cached user exists', () async {
        // Arrange
        when(() => mockLocalDataSource.getUserData())
            .thenAnswer((_) async => null);

        // Act
        final result = await provider.getCachedUserProfile();

        // Assert
        expect(result.success, true);
        expect(result.data, isNull);
        expect(result.isFromCache, false);
        expect(result.isFresh, false);
      });

      test('should mark cached data as not fresh when older than 24 hours', () async {
        // Arrange
        final oldUserData = Map<String, dynamic>.from(testUserData);
        oldUserData['cached_at'] = DateTime.now()
            .subtract(const Duration(hours: 25))
            .toIso8601String();

        when(() => mockLocalDataSource.getUserData())
            .thenAnswer((_) async => oldUserData);

        // Act
        final result = await provider.getCachedUserProfile();

        // Assert
        expect(result.success, true);
        expect(result.data, isNotNull);
        expect(result.isFromCache, true);
        expect(result.isFresh, false);
      });

      test('should handle missing cached_at timestamp', () async {
        // Arrange
        final userDataWithoutTimestamp = Map<String, dynamic>.from(testUserData);
        userDataWithoutTimestamp.remove('cached_at');

        when(() => mockLocalDataSource.getUserData())
            .thenAnswer((_) async => userDataWithoutTimestamp);

        // Act
        final result = await provider.getCachedUserProfile();

        // Assert
        expect(result.success, true);
        expect(result.data, isNotNull);
        expect(result.cachedAt, isNull);
        expect(result.isFresh, false); // No timestamp means not fresh
      });

      test('should return failure when user data parsing fails', () async {
        // Arrange
        final invalidUserData = <String, dynamic>{
          'id': null,
          'email': 'invalid-email',
        };

        when(() => mockLocalDataSource.getUserData())
            .thenAnswer((_) async => invalidUserData);

        // Act
        final result = await provider.getCachedUserProfile();

        // Assert
        expect(result.success, false);
        expect(result.data, isNull);
        expect(result.errorMessage, isNotNull);
        expect(result.errorMessage, contains('Failed to parse cached user data'));
      });

      test('should return failure when exception occurs', () async {
        // Arrange
        when(() => mockLocalDataSource.getUserData())
            .thenThrow(Exception('Storage error'));

        // Act
        final result = await provider.getCachedUserProfile();

        // Assert
        expect(result.success, false);
        expect(result.data, isNull);
        expect(result.errorMessage, contains('Failed to get cached user profile'));
      });

      test('should handle invalid cached_at timestamp gracefully', () async {
        // Arrange
        final userDataWithInvalidTimestamp = Map<String, dynamic>.from(testUserData);
        userDataWithInvalidTimestamp['cached_at'] = 'invalid-date';

        when(() => mockLocalDataSource.getUserData())
            .thenAnswer((_) async => userDataWithInvalidTimestamp);

        // Act
        final result = await provider.getCachedUserProfile();

        // Assert
        expect(result.success, true);
        expect(result.data, isNotNull);
        expect(result.cachedAt, isNull);
        expect(result.isFresh, false);
      });

      test('should handle user data with missing optional fields', () async {
        // Arrange
        final minimalUserData = {
          'id': 'test-user-id',
          'email': 'test@example.com',
          'username': 'testuser',
          'created_at': '2024-01-01T12:00:00.000Z',
        };

        when(() => mockLocalDataSource.getUserData())
            .thenAnswer((_) async => minimalUserData);

        // Act
        final result = await provider.getCachedUserProfile();

        // Assert
        expect(result.success, true);
        expect(result.data, isNotNull);
        expect(result.data!.id, 'test-user-id');
        expect(result.data!.lastLoginAt, isNull);
      });
    });

    group('getCachedTrips', () {
      test('should return no data when online', () async {
        // Arrange
        when(() => mockOfflineAuthManager.isCurrentlyOffline())
            .thenAnswer((_) async => false);

        // Act
        final result = await provider.getCachedTrips();

        // Assert
        expect(result.success, true);
        expect(result.data, isNull);
        expect(result.isFromCache, false);
        expect(result.isFresh, false);
      });

      test('should return no data when offline (not yet implemented)', () async {
        // Arrange
        when(() => mockOfflineAuthManager.isCurrentlyOffline())
            .thenAnswer((_) async => true);

        // Act
        final result = await provider.getCachedTrips();

        // Assert
        expect(result.success, true);
        expect(result.data, isNull);
        expect(result.isFromCache, false);
        expect(result.isFresh, false);
      });

      test('should return failure on exception', () async {
        // Arrange
        when(() => mockOfflineAuthManager.isCurrentlyOffline())
            .thenThrow(Exception('Connectivity error'));

        // Act
        final result = await provider.getCachedTrips();

        // Assert
        expect(result.success, false);
        expect(result.data, isNull);
        expect(result.errorMessage, contains('Failed to get cached trips'));
      });
    });

    group('updateUserProfile', () {
      test('should throw OfflineException when offline', () async {
        // Arrange
        when(() => mockOfflineAuthManager.isCurrentlyOffline())
            .thenAnswer((_) async => true);

        // Act & Assert
        expect(
          () => provider.updateUserProfile(testUser),
          throwsA(isA<OfflineException>()
              .having(
                (e) => e.message,
                'message',
                contains('Cannot update user profile while offline'),
              )
              .having(
                (e) => e.recoveryAction,
                'recoveryAction',
                contains('Please connect to the internet'),
              )),
        );
      });

      test('should cache updated user data when online', () async {
        // Arrange
        when(() => mockOfflineAuthManager.isCurrentlyOffline())
            .thenAnswer((_) async => false);
        when(() => mockLocalDataSource.cacheUserData(any()))
            .thenAnswer((_) async {});

        // Act
        await provider.updateUserProfile(testUser);

        // Assert
        verify(() => mockLocalDataSource.cacheUserData(any())).called(1);
      });

      test('should throw AuthException when caching fails', () async {
        // Arrange
        when(() => mockOfflineAuthManager.isCurrentlyOffline())
            .thenAnswer((_) async => false);
        when(() => mockLocalDataSource.cacheUserData(any()))
            .thenThrow(Exception('Storage error'));

        // Act & Assert
        expect(
          () => provider.updateUserProfile(testUser),
          throwsA(isA<AuthException>()
              .having((e) => e.message, 'message', contains('Failed to update'))),
        );
      });

      test('should include cached_at timestamp in cached data', () async {
        // Arrange
        when(() => mockOfflineAuthManager.isCurrentlyOffline())
            .thenAnswer((_) async => false);
        when(() => mockLocalDataSource.cacheUserData(any()))
            .thenAnswer((_) async {});

        // Act
        await provider.updateUserProfile(testUser);

        // Assert
        final captured = verify(() => mockLocalDataSource.cacheUserData(captureAny()))
            .captured.single as Map<String, dynamic>;
        expect(captured['cached_at'], isNotNull);
        expect(captured['cached_at'], isA<String>());
      });

      test('should preserve all user fields in cached data', () async {
        // Arrange
        when(() => mockOfflineAuthManager.isCurrentlyOffline())
            .thenAnswer((_) async => false);
        when(() => mockLocalDataSource.cacheUserData(any()))
            .thenAnswer((_) async {});

        // Act
        await provider.updateUserProfile(testUser);

        // Assert
        final captured = verify(() => mockLocalDataSource.cacheUserData(captureAny()))
            .captured.single as Map<String, dynamic>;
        expect(captured['id'], testUser.id);
        expect(captured['email'], testUser.email);
        expect(captured['username'], testUser.username);
        expect(captured['created_at'], testUser.createdAt.toIso8601String());
      });
    });

    group('createTrip', () {
      test('should throw OfflineException when offline', () async {
        // Arrange
        when(() => mockOfflineAuthManager.isCurrentlyOffline())
            .thenAnswer((_) async => true);

        // Act & Assert
        expect(
          () => provider.createTrip({'title': 'New Trip'}),
          throwsA(isA<OfflineException>()
              .having(
                (e) => e.message,
                'message',
                contains('Cannot create trip while offline'),
              )
              .having(
                (e) => e.recoveryAction,
                'recoveryAction',
                contains('Please connect to the internet'),
              )),
        );
      });

      test('should throw UnimplementedError when online', () async {
        // Arrange
        when(() => mockOfflineAuthManager.isCurrentlyOffline())
            .thenAnswer((_) async => false);

        // Act & Assert
        expect(
          () => provider.createTrip({'title': 'New Trip'}),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });

    group('updateTrip', () {
      test('should throw OfflineException when offline', () async {
        // Arrange
        when(() => mockOfflineAuthManager.isCurrentlyOffline())
            .thenAnswer((_) async => true);

        // Act & Assert
        expect(
          () => provider.updateTrip('trip-id', {'title': 'Updated Trip'}),
          throwsA(isA<OfflineException>()
              .having(
                (e) => e.message,
                'message',
                contains('Cannot update trip while offline'),
              )),
        );
      });

      test('should throw UnimplementedError when online', () async {
        // Arrange
        when(() => mockOfflineAuthManager.isCurrentlyOffline())
            .thenAnswer((_) async => false);

        // Act & Assert
        expect(
          () => provider.updateTrip('trip-id', {'title': 'Updated Trip'}),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });

    group('deleteTrip', () {
      test('should throw OfflineException when offline', () async {
        // Arrange
        when(() => mockOfflineAuthManager.isCurrentlyOffline())
            .thenAnswer((_) async => true);

        // Act & Assert
        expect(
          () => provider.deleteTrip('trip-id'),
          throwsA(isA<OfflineException>()
              .having(
                (e) => e.message,
                'message',
                contains('Cannot delete trip while offline'),
              )),
        );
      });

      test('should throw UnimplementedError when online', () async {
        // Arrange
        when(() => mockOfflineAuthManager.isCurrentlyOffline())
            .thenAnswer((_) async => false);

        // Act & Assert
        expect(
          () => provider.deleteTrip('trip-id'),
          throwsA(isA<UnimplementedError>()),
        );
      });
    });

    group('isOffline', () {
      test('should return true when offline', () async {
        // Arrange
        when(() => mockOfflineAuthManager.isCurrentlyOffline())
            .thenAnswer((_) async => true);

        // Act
        final result = await provider.isOffline();

        // Assert
        expect(result, true);
      });

      test('should return false when online', () async {
        // Arrange
        when(() => mockOfflineAuthManager.isCurrentlyOffline())
            .thenAnswer((_) async => false);

        // Act
        final result = await provider.isOffline();

        // Assert
        expect(result, false);
      });
    });

    group('getCachedDataInfo', () {
      test('should return info when user data is cached', () async {
        // Arrange
        when(() => mockOfflineAuthManager.getCachedDataInfo())
            .thenAnswer((_) async => CachedDataInfo(
                  userProfile: testUserData,
                  lastCachedAt: DateTime.now(),
                  isFresh: true,
                ));
        when(() => mockLocalDataSource.getUserData())
            .thenAnswer((_) async => testUserData);

        // Act
        final result = await provider.getCachedDataInfo();

        // Assert
        expect(result['hasUserData'], true);
        expect(result['hasTripData'], false);
        expect(result['userCacheAge'], isNotNull);
        expect(result['isUserCacheFresh'], true);
        expect(result['userCachedAt'], isNotNull);
      });

      test('should return info when no user data is cached', () async {
        // Arrange
        when(() => mockOfflineAuthManager.getCachedDataInfo())
            .thenAnswer((_) async => CachedDataInfo.none());
        when(() => mockLocalDataSource.getUserData())
            .thenAnswer((_) async => null);

        // Act
        final result = await provider.getCachedDataInfo();

        // Assert
        expect(result['hasUserData'], false);
        expect(result['hasTripData'], false);
        expect(result['userCacheAge'], isNull);
        expect(result['isUserCacheFresh'], false);
        expect(result['userCachedAt'], isNull);
      });

      test('should calculate user cache age correctly', () async {
        // Arrange
        final cachedTime = DateTime.now().subtract(const Duration(hours: 5));
        final userDataWithTimestamp = Map<String, dynamic>.from(testUserData);
        userDataWithTimestamp['cached_at'] = cachedTime.toIso8601String();

        when(() => mockOfflineAuthManager.getCachedDataInfo())
            .thenAnswer((_) async => CachedDataInfo(
                  userProfile: userDataWithTimestamp,
                  lastCachedAt: cachedTime,
                  isFresh: true,
                ));
        when(() => mockLocalDataSource.getUserData())
            .thenAnswer((_) async => userDataWithTimestamp);

        // Act
        final result = await provider.getCachedDataInfo();

        // Assert
        expect(result['userCacheAge'], closeTo(5.0, 0.1)); // Within 0.1 hours
      });

      test('should handle exceptions gracefully', () async {
        // Arrange
        when(() => mockOfflineAuthManager.getCachedDataInfo())
            .thenThrow(Exception('Error getting info'));

        // Act
        final result = await provider.getCachedDataInfo();

        // Assert
        expect(result['hasUserData'], false);
        expect(result['hasTripData'], false);
        expect(result['userCacheAge'], isNull);
        expect(result['isUserCacheFresh'], false);
        expect(result['error'], isNotNull);
      });
    });

    group('CachedDataResult', () {
      test('cached factory should create correct result', () {
        // Act
        final result = CachedDataResult<User>.cached(
          data: testUser,
          cachedAt: DateTime.now(),
          isFresh: true,
        );

        // Assert
        expect(result.success, true);
        expect(result.data, testUser);
        expect(result.isFromCache, true);
        expect(result.isFresh, true);
        expect(result.errorMessage, isNull);
      });

      test('live factory should create correct result', () {
        // Act
        final result = CachedDataResult<User>.live(data: testUser);

        // Assert
        expect(result.success, true);
        expect(result.data, testUser);
        expect(result.isFromCache, false);
        expect(result.isFresh, true);
        expect(result.cachedAt, isNull);
        expect(result.errorMessage, isNull);
      });

      test('failure factory should create correct result', () {
        // Act
        final result = CachedDataResult<User>.failure(
          errorMessage: 'Test error',
        );

        // Assert
        expect(result.success, false);
        expect(result.data, isNull);
        expect(result.isFromCache, false);
        expect(result.isFresh, false);
        expect(result.cachedAt, isNull);
        expect(result.errorMessage, 'Test error');
      });

      test('noData factory should create correct result', () {
        // Act
        final result = CachedDataResult<User>.noData();

        // Assert
        expect(result.success, true);
        expect(result.data, isNull);
        expect(result.isFromCache, false);
        expect(result.isFresh, false);
        expect(result.cachedAt, isNull);
        expect(result.errorMessage, isNull);
      });

      test('toString should include all relevant information', () {
        // Arrange
        final result = CachedDataResult<User>.cached(
          data: testUser,
          cachedAt: DateTime(2024, 1, 15, 10, 0),
          isFresh: true,
        );

        // Act
        final str = result.toString();

        // Assert
        expect(str, contains('success: true'));
        expect(str, contains('isFromCache: true'));
        expect(str, contains('isFresh: true'));
        expect(str, contains('hasData: true'));
      });
    });

    group('Edge Cases and Error Handling', () {
      test('should handle concurrent calls to getCachedUserProfile', () async {
        // Arrange
        when(() => mockLocalDataSource.getUserData())
            .thenAnswer((_) async => testUserData);

        // Act
        final results = await Future.wait(
          List.generate(10, (_) => provider.getCachedUserProfile()),
        );

        // Assert
        expect(results.length, 10);
        for (final result in results) {
          expect(result.success, true);
          expect(result.data, isNotNull);
        }
      });

      test('should handle null values in user data gracefully', () async {
        // Arrange
        final userDataWithNulls = {
          'id': 'test-id',
          'email': null,
          'username': null,
          'created_at': null,
        };

        when(() => mockLocalDataSource.getUserData())
            .thenAnswer((_) async => userDataWithNulls);

        // Act
        final result = await provider.getCachedUserProfile();

        // Assert
        expect(result.success, true);
        expect(result.data, isNotNull);
        expect(result.data!.id, 'test-id');
        expect(result.data!.email, ''); // Empty string for null
        expect(result.data!.username, ''); // Empty string for null
      });

      test('should handle extremely old cache timestamps', () async {
        // Arrange
        final ancientUserData = Map<String, dynamic>.from(testUserData);
        ancientUserData['cached_at'] = DateTime(2020, 1, 1).toIso8601String();

        when(() => mockLocalDataSource.getUserData())
            .thenAnswer((_) async => ancientUserData);

        // Act
        final result = await provider.getCachedUserProfile();

        // Assert
        expect(result.success, true);
        expect(result.data, isNotNull);
        expect(result.isFresh, false);
        expect(result.cachedAt, DateTime(2020, 1, 1));
      });

      test('should handle DateTime parsing edge cases', () async {
        // Arrange
        final userDataWithEdgeDates = {
          'id': 'test-id',
          'email': 'test@example.com',
          'username': 'testuser',
          'created_at': DateTime.now().toIso8601String(),
          'last_login_at': '', // Empty string instead of null
        };

        when(() => mockLocalDataSource.getUserData())
            .thenAnswer((_) async => userDataWithEdgeDates);

        // Act
        final result = await provider.getCachedUserProfile();

        // Assert
        expect(result.success, true); // Should handle gracefully
      });
    });
  });
}
