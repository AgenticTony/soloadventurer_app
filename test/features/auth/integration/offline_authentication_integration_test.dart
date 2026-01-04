import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/offline_auth_manager.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/cached_data_provider.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/token_refresh_service.dart';
import 'package:soloadventurer/features/core/domain/services/connectivity_service.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';

class MockConnectivityService extends Mock implements ConnectivityService {}
class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}
class MockAuthRepository extends Mock implements AuthRepository {}
class MockTokenRefreshService extends Mock implements TokenRefreshService {}

/// Integration tests for offline authentication behavior and sync on reconnect
///
/// These tests verify the complete integration of:
/// - OfflineAuthManager
/// - CachedDataProvider
/// - ConnectivityService
/// - AuthLocalDataSource
/// - TokenRefreshService
/// - AuthRepository
///
/// Across various offline and online transition scenarios.
void main() {
  late MockConnectivityService mockConnectivityService;
  late MockAuthLocalDataSource mockLocalDataSource;
  late MockAuthRepository mockAuthRepository;
  late MockTokenRefreshService mockTokenRefreshService;
  late OfflineAuthManager offlineAuthManager;
  late CachedDataProvider cachedDataProvider;
  late StreamController<NetworkStatus> connectivityController;

  setUp(() {
    mockConnectivityService = MockConnectivityService();
    mockLocalDataSource = MockAuthLocalDataSource();
    mockAuthRepository = MockAuthRepository();
    mockTokenRefreshService = MockTokenRefreshService();

    // Set up connectivity stream
    connectivityController = StreamController<NetworkStatus>.broadcast();
    when(() => mockConnectivityService.onConnectivityChanged)
        .thenAnswer((_) => connectivityController.stream);

    // Create service instances
    offlineAuthManager = OfflineAuthManager(
      connectivityService: mockConnectivityService,
      localDataSource: mockLocalDataSource,
      tokenRefreshService: mockTokenRefreshService,
      authRepository: mockAuthRepository,
    );

    cachedDataProvider = CachedDataProvider(
      offlineAuthManager: offlineAuthManager,
      localDataSource: mockLocalDataSource,
    );
  });

  tearDown(() async {
    await connectivityController.close();
    offlineAuthManager.dispose();
  });

  group('Offline Authentication - Mode Detection', () {
    test('should initialize as online when network is connected', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.connected);
      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => true);

      // Act
      await offlineAuthManager.initialize();

      // Assert
      expect(offlineAuthManager.currentState, equals(OfflineAuthState.online));
      expect(offlineAuthManager.isOnline, isTrue);
      expect(offlineAuthManager.isOffline, isFalse);
    });

    test('should initialize as offline with cache when disconnected with valid session', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.disconnected);
      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => true);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => DateTime.now().subtract(const Duration(hours: 1)));

      // Act
      await offlineAuthManager.initialize();

      // Assert
      expect(offlineAuthManager.currentState, equals(OfflineAuthState.offlineWithCache));
      expect(offlineAuthManager.isOffline, isTrue);
      expect(offlineAuthManager.hasCachedData, isTrue);
    });

    test('should initialize as offline without cache when disconnected with invalid session', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.disconnected);
      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => false);

      // Act
      await offlineAuthManager.initialize();

      // Assert
      expect(offlineAuthManager.currentState, equals(OfflineAuthState.offlineWithoutCache));
      expect(offlineAuthManager.isOffline, isTrue);
      expect(offlineAuthManager.hasCachedData, isFalse);
    });

    test('should transition from online to offline on network loss', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.connected);
      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => true);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => DateTime.now().subtract(const Duration(hours: 1)));

      await offlineAuthManager.initialize();
      expect(offlineAuthManager.currentState, equals(OfflineAuthState.online));

      // Act - Simulate network loss
      connectivityController.add(NetworkStatus.disconnected);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(offlineAuthManager.currentState, equals(OfflineAuthState.offlineWithCache));
    });

    test('should transition from offline to needsSync on reconnection', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.disconnected);
      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => true);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => DateTime.now().subtract(const Duration(hours: 1)));

      await offlineAuthManager.initialize();
      expect(offlineAuthManager.currentState, equals(OfflineAuthState.offlineWithCache));

      // Act - Simulate reconnection
      connectivityController.add(NetworkStatus.connected);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(offlineAuthManager.currentState, equals(OfflineAuthState.needsSync));
    });

    test('should emit state change events on connectivity transitions', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.connected);
      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => true);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => DateTime.now().subtract(const Duration(hours: 1)));

      final stateChanges = <OfflineAuthResult>[];
      final subscription = offlineAuthManager.onStateChanged.listen(stateChanges.add);

      await offlineAuthManager.initialize();

      // Act - Simulate network loss and reconnection
      connectivityController.add(NetworkStatus.disconnected);
      await Future.delayed(const Duration(milliseconds: 50));
      connectivityController.add(NetworkStatus.connected);
      await Future.delayed(const Duration(milliseconds: 50));

      // Assert
      expect(stateChanges.length, greaterThanOrEqualTo(3)); // online -> offline -> needsSync
      expect(stateChanges[0].state, equals(OfflineAuthState.online));
      expect(stateChanges[1].state, equals(OfflineAuthState.offlineWithCache));
      expect(stateChanges[2].state, equals(OfflineAuthState.needsSync));

      await subscription.cancel();
    });
  });

  group('Offline Authentication - Cached Data Access', () {
    setUp(() {
      // Set up default online state
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.connected);
      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => true);
    });

    test('should retrieve cached user profile when offline', () async {
      // Arrange
      final cachedUserData = {
        'id': 'user123',
        'email': 'test@example.com',
        'username': 'testuser',
        'created_at': DateTime.now().toIso8601String(),
        'last_login_at': DateTime.now().toIso8601String(),
        'cached_at': DateTime.now().toIso8601String(),
      };

      when(() => mockLocalDataSource.getUserData())
          .thenAnswer((_) async => cachedUserData);

      // Act
      final result = await cachedDataProvider.getCachedUserProfile();

      // Assert
      expect(result.success, isTrue);
      expect(result.data, isNotNull);
      expect(result.data!.id, equals('user123'));
      expect(result.data!.email, equals('test@example.com'));
      expect(result.isFromCache, isTrue);
      expect(result.isFresh, isTrue); // Cache is fresh (< 24 hours)
    });

    test('should mark cached data as not fresh when older than 24 hours', () async {
      // Arrange
      final oldCachedUserData = {
        'id': 'user123',
        'email': 'test@example.com',
        'username': 'testuser',
        'created_at': DateTime.now().toIso8601String(),
        'last_login_at': DateTime.now().toIso8601String(),
        'cached_at': DateTime.now().subtract(const Duration(hours: 25)).toIso8601String(),
      };

      when(() => mockLocalDataSource.getUserData())
          .thenAnswer((_) async => oldCachedUserData);

      // Act
      final result = await cachedDataProvider.getCachedUserProfile();

      // Assert
      expect(result.success, isTrue);
      expect(result.data, isNotNull);
      expect(result.isFromCache, isTrue);
      expect(result.isFresh, isFalse); // Cache is stale (> 24 hours)
    });

    test('should return no data when cache is empty', () async {
      // Arrange
      when(() => mockLocalDataSource.getUserData())
          .thenAnswer((_) async => null);

      // Act
      final result = await cachedDataProvider.getCachedUserProfile();

      // Assert
      expect(result.success, isTrue);
      expect(result.data, isNull);
      expect(result.isFromCache, isFalse);
    });

    test('should return failure on cache parsing error', () async {
      // Arrange
      final invalidUserData = {
        'id': 'user123',
        // Missing required fields
        'cached_at': DateTime.now().toIso8601String(),
      };

      when(() => mockLocalDataSource.getUserData())
          .thenAnswer((_) async => invalidUserData);

      // Act
      final result = await cachedDataProvider.getCachedUserProfile();

      // Assert
      expect(result.success, isFalse);
      expect(result.data, isNull);
      expect(result.errorMessage, isNotNull);
      expect(result.errorMessage, contains('Failed to parse'));
    });

    test('should provide cached data info with metadata', () async {
      // Arrange
      final cachedUserData = {
        'id': 'user123',
        'email': 'test@example.com',
        'username': 'testuser',
        'created_at': DateTime.now().toIso8601String(),
        'cached_at': DateTime.now().subtract(const Duration(hours: 2)).toIso8601String(),
      };

      when(() => mockLocalDataSource.getUserData())
          .thenAnswer((_) async => cachedUserData);

      // Act
      final info = await cachedDataProvider.getCachedDataInfo();

      // Assert
      expect(info['hasUserData'], isTrue);
      expect(info['hasTripData'], isFalse); // Trip caching not yet implemented
      expect(info['userCacheAge'], isNotNull);
      expect(info['userCacheAge'], equals(2.0)); // 2 hours old
      expect(info['isUserCacheFresh'], isTrue); // < 24 hours
    });

    test('should prevent write operations when offline', () async {
      // Arrange - Set offline state
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.disconnected);
      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => true);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => DateTime.now().subtract(const Duration(hours: 1)));

      await offlineAuthManager.initialize();

      final user = User(
        id: 'user123',
        email: 'test@example.com',
        username: 'testuser',
        createdAt: DateTime.now(),
      );

      // Act & Assert
      expect(
        () => cachedDataProvider.updateUserProfile(user),
        throwsA(isA<OfflineException>()),
      );
    });

    test('should allow write operations when online', () async {
      // Arrange - Ensure online state
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.connected);
      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => true);

      await offlineAuthManager.initialize();

      final user = User(
        id: 'user123',
        email: 'test@example.com',
        username: 'testuser',
        createdAt: DateTime.now(),
      );

      when(() => mockLocalDataSource.cacheUserData(any()))
          .thenAnswer((_) async {});

      // Act
      await cachedDataProvider.updateUserProfile(user);

      // Assert
      verify(() => mockLocalDataSource.cacheUserData(any())).called(1);
    });
  });

  group('Offline Authentication - Sync on Reconnect', () {
    setUp(() {
      // Set up default offline state with cache
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.disconnected);
      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => true);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => DateTime.now().subtract(const Duration(hours: 1)));
    });

    test('should trigger sync when reconnecting', () async {
      // Arrange
      await offlineAuthManager.initialize();
      expect(offlineAuthManager.currentState, equals(OfflineAuthState.offlineWithCache));

      // Set up mocks for sync
      when(() => mockLocalDataSource.isTokenExpired())
          .thenAnswer((_) async => false);
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => User(
            id: 'user123',
            email: 'test@example.com',
            username: 'testuser',
            createdAt: DateTime.now(),
          ));
      when(() => mockLocalDataSource.cacheUserData(any()))
          .thenAnswer((_) async {});

      final syncProgressEvents = <SyncProgress>[];
      final subscription = offlineAuthManager.onSyncProgress.listen(syncProgressEvents.add);

      // Act - Reconnect
      connectivityController.add(NetworkStatus.connected);
      await Future.delayed(const Duration(seconds: 2)); // Wait for sync to complete

      // Assert
      expect(syncProgressEvents.isNotEmpty, isTrue);
      expect(syncProgressEvents.last.step, equals(SyncStep.completed));
      expect(offlineAuthManager.currentState, equals(OfflineAuthState.online));

      await subscription.cancel();
    });

    test('should refresh token if expired during sync', () async {
      // Arrange
      await offlineAuthManager.initialize();

      when(() => mockLocalDataSource.isTokenExpired())
          .thenAnswer((_) async => true); // Token is expired
      when(() => mockTokenRefreshService.refreshToken())
          .thenAnswer((_) async {});
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => User(
            id: 'user123',
            email: 'test@example.com',
            username: 'testuser',
            createdAt: DateTime.now(),
          ));
      when(() => mockLocalDataSource.cacheUserData(any()))
          .thenAnswer((_) async {});

      final syncProgressEvents = <SyncProgress>[];
      final subscription = offlineAuthManager.onSyncProgress.listen(syncProgressEvents.add);

      // Act - Reconnect
      connectivityController.add(NetworkStatus.connected);
      await Future.delayed(const Duration(seconds: 2));

      // Assert
      expect(syncProgressEvents.any((e) => e.step == SyncStep.refreshingToken), isTrue);
      verify(() => mockTokenRefreshService.refreshToken()).called(1);

      await subscription.cancel();
    });

    test('should fetch and cache fresh user data during sync', () async {
      // Arrange
      await offlineAuthManager.initialize();

      when(() => mockLocalDataSource.isTokenExpired())
          .thenAnswer((_) async => false);

      final freshUser = User(
        id: 'user123',
        email: 'fresh@example.com',
        username: 'freshuser',
        createdAt: DateTime.now(),
      );

      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => freshUser);
      when(() => mockLocalDataSource.cacheUserData(any()))
          .thenAnswer((_) async {});

      final syncProgressEvents = <SyncProgress>[];
      final subscription = offlineAuthManager.onSyncProgress.listen(syncProgressEvents.add);

      // Act - Reconnect
      connectivityController.add(NetworkStatus.connected);
      await Future.delayed(const Duration(seconds: 2));

      // Assert
      expect(syncProgressEvents.any((e) => e.step == SyncStep.syncingUserData), isTrue);
      verify(() => mockAuthRepository.getCurrentUser()).called(1);
      verify(() => mockLocalDataSource.cacheUserData(any())).called(1);

      await subscription.cancel();
    });

    test('should handle sync failure gracefully', () async {
      // Arrange
      await offlineAuthManager.initialize();

      when(() => mockLocalDataSource.isTokenExpired())
          .thenAnswer((_) async => false);
      when(() => mockAuthRepository.getCurrentUser())
          .thenThrow(const AuthException.network('Network error'));

      final syncProgressEvents = <SyncProgress>[];
      final subscription = offlineAuthManager.onSyncProgress.listen(syncProgressEvents.add);

      // Act - Reconnect
      connectivityController.add(NetworkStatus.connected);
      await Future.delayed(const Duration(seconds: 2));

      // Assert
      expect(syncProgressEvents.any((e) => e.step == SyncStep.failed), isTrue);
      expect(offlineAuthManager.currentState, equals(OfflineAuthState.offlineWithoutCache));

      await subscription.cancel();
    });

    test('should not sync when already syncing', () async {
      // Arrange
      await offlineAuthManager.initialize();

      when(() => mockLocalDataSource.isTokenExpired())
          .thenAnswer((_) async => false);
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 1)); // Simulate slow sync
        return User(
          id: 'user123',
          email: 'test@example.com',
          username: 'testuser',
          createdAt: DateTime.now(),
        );
      });
      when(() => mockLocalDataSource.cacheUserData(any()))
          .thenAnswer((_) async {});

      // Act - Start first sync
      connectivityController.add(NetworkStatus.connected);
      await Future.delayed(const Duration(milliseconds: 100));

      // Try to sync again while first sync is in progress
      final result = await offlineAuthManager.syncWithServer();

      // Assert
      expect(result.success, isTrue); // Should return success without duplicate sync
      expect(offlineAuthManager.isSyncing, isTrue);
    });

    test('should emit progress updates during sync', () async {
      // Arrange
      await offlineAuthManager.initialize();

      when(() => mockLocalDataSource.isTokenExpired())
          .thenAnswer((_) async => false);
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => User(
            id: 'user123',
            email: 'test@example.com',
            username: 'testuser',
            createdAt: DateTime.now(),
          ));
      when(() => mockLocalDataSource.cacheUserData(any()))
          .thenAnswer((_) async {});

      final syncProgressEvents = <SyncProgress>[];
      final subscription = offlineAuthManager.onSyncProgress.listen(syncProgressEvents.add);

      // Act - Reconnect
      connectivityController.add(NetworkStatus.connected);
      await Future.delayed(const Duration(seconds: 2));

      // Assert
      expect(syncProgressEvents.length, greaterThan(3));
      expect(syncProgressEvents[0].step, equals(SyncStep.starting));
      expect(syncProgressEvents.last.step, equals(SyncStep.completed));
      expect(syncProgressEvents.last.progress, equals(100));

      await subscription.cancel();
    });
  });

  group('Offline Authentication - Token Refresh After Reconnection', () {
    setUp(() {
      // Set up offline state
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.disconnected);
      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => true);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => DateTime.now().subtract(const Duration(hours: 1)));
    });

    test('should attempt token refresh on reconnection if token expired', () async {
      // Arrange
      await offlineAuthManager.initialize();

      when(() => mockLocalDataSource.isTokenExpired())
          .thenAnswer((_) async => true);
      when(() => mockTokenRefreshService.refreshToken())
          .thenAnswer((_) async {});
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => User(
            id: 'user123',
            email: 'test@example.com',
            username: 'testuser',
            createdAt: DateTime.now(),
          ));
      when(() => mockLocalDataSource.cacheUserData(any()))
          .thenAnswer((_) async {});

      // Act - Reconnect
      connectivityController.add(NetworkStatus.connected);
      await Future.delayed(const Duration(seconds: 2));

      // Assert
      verify(() => mockTokenRefreshService.refreshToken()).called(1);
    });

    test('should continue sync if token refresh fails', () async {
      // Arrange
      await offlineAuthManager.initialize();

      when(() => mockLocalDataSource.isTokenExpired())
          .thenAnswer((_) async => true);
      when(() => mockTokenRefreshService.refreshToken())
          .thenThrow(const AuthException.network('Token refresh failed'));
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => User(
            id: 'user123',
            email: 'test@example.com',
            username: 'testuser',
            createdAt: DateTime.now(),
          ));
      when(() => mockLocalDataSource.cacheUserData(any()))
          .thenAnswer((_) async {});

      final syncProgressEvents = <SyncProgress>[];
      final subscription = offlineAuthManager.onSyncProgress.listen(syncProgressEvents.add);

      // Act - Reconnect
      connectivityController.add(NetworkStatus.connected);
      await Future.delayed(const Duration(seconds: 2));

      // Assert
      verify(() => mockTokenRefreshService.refreshToken()).called(1);
      expect(syncProgressEvents.any((e) => e.step == SyncStep.syncingUserData), isTrue);
      expect(syncProgressEvents.last.step, equals(SyncStep.completed));

      await subscription.cancel();
    });

    test('should skip token refresh if token is still valid', () async {
      // Arrange
      await offlineAuthManager.initialize();

      when(() => mockLocalDataSource.isTokenExpired())
          .thenAnswer((_) async => false); // Token is valid
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => User(
            id: 'user123',
            email: 'test@example.com',
            username: 'testuser',
            createdAt: DateTime.now(),
          ));
      when(() => mockLocalDataSource.cacheUserData(any()))
          .thenAnswer((_) async {});

      // Act - Reconnect
      connectivityController.add(NetworkStatus.connected);
      await Future.delayed(const Duration(seconds: 2));

      // Assert
      verifyNever(() => mockTokenRefreshService.refreshToken());
    });
  });

  group('Offline Authentication - Edge Cases', () {
    test('should handle rapid offline/online transitions', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.connected);
      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => true);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => DateTime.now().subtract(const Duration(hours: 1)));

      await offlineAuthManager.initialize();

      when(() => mockLocalDataSource.isTokenExpired())
          .thenAnswer((_) async => false);
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => User(
            id: 'user123',
            email: 'test@example.com',
            username: 'testuser',
            createdAt: DateTime.now(),
          ));
      when(() => mockLocalDataSource.cacheUserData(any())
      ).thenAnswer((_) async {});

      // Act - Rapid transitions
      for (int i = 0; i < 3; i++) {
        connectivityController.add(NetworkStatus.disconnected);
        await Future.delayed(const Duration(milliseconds: 50));
        connectivityController.add(NetworkStatus.connected);
        await Future.delayed(const Duration(milliseconds: 50));
      }

      await Future.delayed(const Duration(seconds: 1));

      // Assert - Should end up online after all transitions
      expect(offlineAuthManager.currentState, equals(OfflineAuthState.online));
    });

    test('should handle sync without TokenRefreshService', () async {
      // Arrange - Create manager without token refresh service
      final managerWithoutRefresh = OfflineAuthManager(
        connectivityService: mockConnectivityService,
        localDataSource: mockLocalDataSource,
        tokenRefreshService: null, // No token refresh service
        authRepository: mockAuthRepository,
      );

      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.disconnected);
      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => true);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => DateTime.now().subtract(const Duration(hours: 1)));

      await managerWithoutRefresh.initialize();

      when(() => mockLocalDataSource.isTokenExpired())
          .thenAnswer((_) async => true);
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => User(
            id: 'user123',
            email: 'test@example.com',
            username: 'testuser',
            createdAt: DateTime.now(),
          ));
      when(() => mockLocalDataSource.cacheUserData(any()))
          .thenAnswer((_) async {});

      // Act - Reconnect
      connectivityController.add(NetworkStatus.connected);
      await Future.delayed(const Duration(seconds: 2));

      // Assert - Should still sync user data even without token refresh service
      verify(() => mockAuthRepository.getCurrentUser()).called(1);
      expect(managerWithoutRefresh.currentState, equals(OfflineAuthState.online));

      managerWithoutRefresh.dispose();
    });

    test('should handle sync without AuthRepository', () async {
      // Arrange - Create manager without auth repository
      final managerWithoutRepo = OfflineAuthManager(
        connectivityService: mockConnectivityService,
        localDataSource: mockLocalDataSource,
        tokenRefreshService: mockTokenRefreshService,
        authRepository: null, // No auth repository
      );

      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.disconnected);
      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => true);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => DateTime.now().subtract(const Duration(hours: 1)));

      await managerWithoutRepo.initialize();

      when(() => mockLocalDataSource.isTokenExpired())
          .thenAnswer((_) async => true);
      when(() => mockTokenRefreshService.refreshToken())
          .thenAnswer((_) async {});

      // Act - Reconnect
      connectivityController.add(NetworkStatus.connected);
      await Future.delayed(const Duration(seconds: 2));

      // Assert - Should complete sync even without auth repository
      expect(managerWithoutRepo.currentState, equals(OfflineAuthState.online));

      managerWithoutRepo.dispose();
    });

    test('should handle initialization failure gracefully', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenThrow(const AuthException.unknown('Connectivity check failed'));

      // Act & Assert
      expect(
        () => offlineAuthManager.initialize(),
        throwsA(isA<AuthException>()),
      );

      // State should be offline without cache after failure
      expect(offlineAuthManager.currentState, equals(OfflineAuthState.offlineWithoutCache));
    });

    test('should not sync when offline', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.disconnected);
      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => true);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => DateTime.now().subtract(const Duration(hours: 1)));

      await offlineAuthManager.initialize();

      // Act
      final result = await offlineAuthManager.syncWithServer();

      // Assert
      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Cannot sync while offline'));
    });

    test('should provide cached data info with accurate metadata', () async {
      // Arrange
      final cachedUserData = {
        'id': 'user123',
        'email': 'test@example.com',
        'username': 'testuser',
        'created_at': DateTime.now().toIso8601String(),
        'cached_at': DateTime.now().subtract(const Duration(hours: 12)).toIso8601String(),
      };

      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.connected);
      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => true);
      when(() => mockLocalDataSource.getUserData())
          .thenAnswer((_) async => cachedUserData);

      await offlineAuthManager.initialize();

      // Act
      final cachedInfo = await offlineAuthManager.getCachedDataInfo();

      // Assert
      expect(cachedInfo.userProfile, isNotNull);
      expect(cachedInfo.lastCachedAt, isNotNull);
      expect(cachedInfo.isFresh, isTrue); // 12 hours is less than 24
    });

    test('should return no cached data info when no cache exists', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.disconnected);
      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => false);
      when(() => mockLocalDataSource.getUserData())
          .thenAnswer((_) async => null);

      await offlineAuthManager.initialize();

      // Act
      final cachedInfo = await offlineAuthManager.getCachedDataInfo();

      // Assert
      expect(cachedInfo.userProfile, isNull);
      expect(cachedInfo.lastCachedAt, isNull);
      expect(cachedInfo.isFresh, isFalse);
    });
  });

  group('Offline Authentication - Offline Indicator State', () {
    test('should provide correct state for offline indicator UI', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.connected);
      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => true);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => DateTime.now().subtract(const Duration(hours: 1)));

      await offlineAuthManager.initialize();

      // Act - Go offline
      connectivityController.add(NetworkStatus.disconnected);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - State should reflect offline with cache for UI indicator
      expect(offlineAuthManager.currentState, OfflineAuthState.offlineWithCache);
      expect(offlineAuthManager.hasCachedData, isTrue);

      // Act - Reconnect
      when(() => mockLocalDataSource.isTokenExpired())
          .thenAnswer((_) async => false);
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => User(
            id: 'user123',
            email: 'test@example.com',
            username: 'testuser',
            createdAt: DateTime.now(),
          ));
      when(() => mockLocalDataSource.cacheUserData(any()))
          .thenAnswer((_) async {});

      connectivityController.add(NetworkStatus.connected);
      await Future.delayed(const Duration(seconds: 2));

      // Assert - Should end up online
      expect(offlineAuthManager.currentState, OfflineAuthState.online);
    });

    test('should track time offline for display', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.connected);
      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => true);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => DateTime.now().subtract(const Duration(hours: 1)));

      await offlineAuthManager.initialize();

      final stateChanges = <OfflineAuthResult>[];
      final subscription = offlineAuthManager.onStateChanged.listen(stateChanges.add);

      // Act - Go offline
      connectivityController.add(NetworkStatus.disconnected);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(stateChanges.last.state, OfflineAuthState.offlineWithCache);
      expect(stateChanges.last.timestamp, isNotNull);

      // Verify timestamp is recent (within last second)
      final timeSinceTransition = DateTime.now().difference(stateChanges.last.timestamp);
      expect(timeSinceTransition.inSeconds, lessThanOrEqualTo(1));

      await subscription.cancel();
    });
  });
}
