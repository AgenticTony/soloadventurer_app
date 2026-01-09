import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/offline_auth_manager.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/token_refresh_service.dart';
import 'package:soloadventurer/features/core/domain/services/connectivity_service.dart';

class MockConnectivityService extends Mock implements ConnectivityService {}
class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}
class MockTokenRefreshService extends Mock implements TokenRefreshService {}
class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockConnectivityService mockConnectivityService;
  late MockAuthLocalDataSource mockLocalDataSource;
  late MockTokenRefreshService mockTokenRefreshService;
  late MockAuthRepository mockAuthRepository;
  late OfflineAuthManager offlineAuthManager;
  late StreamController<NetworkStatus> connectivityStreamController;

  setUp(() {
    mockConnectivityService = MockConnectivityService();
    mockLocalDataSource = MockAuthLocalDataSource();
    mockTokenRefreshService = MockTokenRefreshService();
    mockAuthRepository = MockAuthRepository();
    connectivityStreamController = StreamController<NetworkStatus>.broadcast();

    // Setup default connectivity stream
    when(() => mockConnectivityService.onConnectivityChanged)
        .thenAnswer((_) => connectivityStreamController.stream);

    // Setup default connectivity check (connected)
    when(() => mockConnectivityService.checkConnectivity())
        .thenAnswer((_) async => NetworkStatus.connected);

    // Setup default has valid session (true)
    when(() => mockLocalDataSource.hasValidSession())
        .thenAnswer((_) async => true);

    // Setup default token expiration (recent)
    when(() => mockLocalDataSource.getTokenExpiration())
        .thenAnswer((_) async => DateTime.now().subtract(const Duration(hours: 1)));

    // Setup default isTokenExpired (false)
    when(() => mockLocalDataSource.isTokenExpired())
        .thenAnswer((_) async => false);

    // Setup default getCurrentUser (null)
    when(() => mockAuthRepository.getCurrentUser())
        .thenAnswer((_) async => null);

    offlineAuthManager = OfflineAuthManager(
      connectivityService: mockConnectivityService,
      localDataSource: mockLocalDataSource,
      tokenRefreshService: mockTokenRefreshService,
      authRepository: mockAuthRepository,
    );
  });

  tearDown(() {
    offlineAuthManager.dispose();
    connectivityStreamController.close();
  });

  group('OfflineAuthManager - Initialization', () {
    test('should initialize with online state when network is connected and has cached credentials', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.connected);

      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => true);

      // Act
      await offlineAuthManager.initialize();

      // Assert
      expect(offlineAuthManager.isOnline, isTrue);
      expect(offlineAuthManager.isOffline, isFalse);
      expect(offlineAuthManager.currentState, OfflineAuthState.online);
    });

    test('should initialize with offlineWithCache state when network is disconnected but has cached credentials', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.disconnected);

      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => true);

      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => DateTime.now().subtract(const Duration(hours: 2)));

      // Act
      await offlineAuthManager.initialize();

      // Assert
      expect(offlineAuthManager.isOffline, isTrue);
      expect(offlineAuthManager.hasCachedData, isTrue);
      expect(offlineAuthManager.currentState, OfflineAuthState.offlineWithCache);
    });

    test('should initialize with offlineWithoutCache state when network is disconnected and no cached credentials', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.disconnected);

      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => false);

      // Act
      await offlineAuthManager.initialize();

      // Assert
      expect(offlineAuthManager.isOffline, isTrue);
      expect(offlineAuthManager.hasCachedData, isFalse);
      expect(offlineAuthManager.currentState, OfflineAuthState.offlineWithoutCache);
    });

    test('should not initialize twice', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.connected);

      // Act
      await offlineAuthManager.initialize();
      await offlineAuthManager.initialize(); // Should not throw

      // Assert - should still be initialized
      expect(offlineAuthManager.currentState, OfflineAuthState.online);
    });

    test('should emit initial state on initialization', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.connected);

      final states = <OfflineAuthResult>[];
      final subscription = offlineAuthManager.onStateChanged.listen(states.add);

      // Act
      await offlineAuthManager.initialize();

      // Assert
      expect(states, hasLength(1));
      expect(states.first.state, OfflineAuthState.online);
      expect(states.first.success, isTrue);

      await subscription.cancel();
    });

    test('should consider cached credentials valid if expired less than 7 days ago', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.disconnected);

      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => true);

      // Token expired 3 days ago (within 7 day limit)
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => DateTime.now().subtract(const Duration(days: 3)));

      // Act
      await offlineAuthManager.initialize();

      // Assert
      expect(offlineAuthManager.currentState, OfflineAuthState.offlineWithCache);
    });

    test('should consider cached credentials invalid if expired more than 7 days ago', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.disconnected);

      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => true);

      // Token expired 10 days ago (beyond 7 day limit)
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => DateTime.now().subtract(const Duration(days: 10)));

      // Act
      await offlineAuthManager.initialize();

      // Assert
      expect(offlineAuthManager.currentState, OfflineAuthState.offlineWithoutCache);
    });
  });

  group('OfflineAuthManager - Connectivity Monitoring', () {
    test('should transition to offlineWithCache when losing connection with cached credentials', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.connected);

      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => true);

      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => DateTime.now().subtract(const Duration(hours: 1)));

      await offlineAuthManager.initialize();
      expect(offlineAuthManager.currentState, OfflineAuthState.online);

      final states = <OfflineAuthResult>[];
      final subscription = offlineAuthManager.onStateChanged.listen(states.add);
      states.clear();

      // Act
      connectivityStreamController.add(NetworkStatus.disconnected);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(offlineAuthManager.currentState, OfflineAuthState.offlineWithCache);
      expect(states.last.state, OfflineAuthState.offlineWithCache);

      await subscription.cancel();
    });

    test('should transition to needsSync when regaining connection', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.disconnected);

      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => true);

      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => DateTime.now().subtract(const Duration(hours: 1)));

      await offlineAuthManager.initialize();
      expect(offlineAuthManager.currentState, OfflineAuthState.offlineWithCache);

      final states = <OfflineAuthResult>[];
      final subscription = offlineAuthManager.onStateChanged.listen(states.add);
      states.clear();

      // Act
      connectivityStreamController.add(NetworkStatus.connected);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(offlineAuthManager.currentState, OfflineAuthState.needsSync);
      expect(states.last.state, OfflineAuthState.needsSync);

      await subscription.cancel();
    });

    test('should not change state if connectivity status is same', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.connected);

      await offlineAuthManager.initialize();

      final states = <OfflineAuthResult>[];
      final subscription = offlineAuthManager.onStateChanged.listen(states.add);
      final initialStateCount = states.length;

      // Act
      connectivityStreamController.add(NetworkStatus.connected); // Same state
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(states.length, equals(initialStateCount)); // No new state emitted

      await subscription.cancel();
    });
  });

  group('OfflineAuthManager - Cached Data Access', () {
    test('should return cached user profile when available', () async {
      // Arrange
      final cachedData = {
        'user_id': '123',
        'email': 'test@example.com',
        'name': 'Test User',
        'cached_at': DateTime.now().toIso8601String(),
      };

      when(() => mockLocalDataSource.getUserData())
          .thenAnswer((_) async => cachedData);

      // Act
      final result = await offlineAuthManager.getCachedUserProfile();

      // Assert
      expect(result, isNotNull);
      expect(result!['user_id'], '123');
      expect(result['email'], 'test@example.com');
      expect(result['name'], 'Test User');
    });

    test('should return null when no cached user profile exists', () async {
      // Arrange
      when(() => mockLocalDataSource.getUserData())
          .thenAnswer((_) async => null);

      // Act
      final result = await offlineAuthManager.getCachedUserProfile();

      // Assert
      expect(result, isNull);
    });

    test('should return cached data info with freshness status', () async {
      // Arrange
      final recentData = {
        'user_id': '123',
        'cached_at': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      };

      when(() => mockLocalDataSource.getUserData())
          .thenAnswer((_) async => recentData);

      // Act
      final info = await offlineAuthManager.getCachedDataInfo();

      // Assert
      expect(info.userProfile, isNotNull);
      expect(info.isFresh, isTrue); // Cached 1 hour ago (< 24 hours)
      expect(info.lastCachedAt, isNotNull);
    });

    test('should mark cached data as not fresh if older than 24 hours', () async {
      // Arrange
      final oldData = {
        'user_id': '123',
        'cached_at': DateTime.now().subtract(const Duration(hours: 25)).toIso8601String(),
      };

      when(() => mockLocalDataSource.getUserData())
          .thenAnswer((_) async => oldData);

      // Act
      final info = await offlineAuthManager.getCachedDataInfo();

      // Assert
      expect(info.userProfile, isNotNull);
      expect(info.isFresh, isFalse); // Cached 25 hours ago (> 24 hours)
    });

    test('should return none when no cached data exists', () async {
      // Arrange
      when(() => mockLocalDataSource.getUserData())
          .thenAnswer((_) async => null);

      // Act
      final info = await offlineAuthManager.getCachedDataInfo();

      // Assert
      expect(info.userProfile, isNull);
      expect(info.isFresh, isFalse);
      expect(info.lastCachedAt, isNull);
    });
  });

  group('OfflineAuthManager - Sync Operations', () {
    test('should sync with server when reconnected', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.disconnected);

      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => true);

      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => DateTime.now().subtract(const Duration(hours: 1)));

      await offlineAuthManager.initialize();
      expect(offlineAuthManager.currentState, OfflineAuthState.offlineWithCache);

      final states = <OfflineAuthResult>[];
      final subscription = offlineAuthManager.onStateChanged.listen(states.add);

      // Act - Simulate reconnection
      connectivityStreamController.add(NetworkStatus.connected);
      await Future.delayed(const Duration(milliseconds: 1500)); // Wait for sync delay

      // Assert
      expect(offlineAuthManager.currentState, OfflineAuthState.online);
      expect(states.last.state, OfflineAuthState.online);

      await subscription.cancel();
    });

    test('should not sync if already syncing', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.connected);

      await offlineAuthManager.initialize();
      expect(offlineAuthManager.isSyncing, isFalse);

      // Act - Start sync manually
      final future1 = offlineAuthManager.syncWithServer();
      expect(offlineAuthManager.isSyncing, isTrue);

      // Try to sync again while already syncing
      final future2 = offlineAuthManager.syncWithServer();

      // Assert
      await Future.wait([future1, future2]);
      expect(offlineAuthManager.isSyncing, isFalse);
    });

    test('should fail sync if network is disconnected', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.disconnected);

      await offlineAuthManager.initialize();

      // Act
      final result = await offlineAuthManager.syncWithServer();

      // Assert
      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Cannot sync while offline'));
    });

    test('should transition to needsSync before completing sync', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.disconnected);

      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => true);

      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => DateTime.now().subtract(const Duration(hours: 1)));

      await offlineAuthManager.initialize();
      connectivityStreamController.add(NetworkStatus.connected);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - Should be in needsSync state before sync completes
      expect(offlineAuthManager.currentState, OfflineAuthState.needsSync);
    });
  });

  group('OfflineAuthManager - Manual State Updates', () {
    test('should allow manual state update', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.connected);

      await offlineAuthManager.initialize();

      final states = <OfflineAuthResult>[];
      final subscription = offlineAuthManager.onStateChanged.listen(states.add);
      states.clear();

      // Act
      offlineAuthManager.updateState(OfflineAuthState.offlineWithCache);

      // Assert
      expect(offlineAuthManager.currentState, OfflineAuthState.offlineWithCache);
      expect(states.last.state, OfflineAuthState.offlineWithCache);
      expect(states.last.success, isTrue);

      await subscription.cancel();
    });

    test('should not emit state if same state is set', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.connected);

      await offlineAuthManager.initialize();

      final states = <OfflineAuthResult>[];
      final subscription = offlineAuthManager.onStateChanged.listen(states.add);
      final initialStateCount = states.length;

      // Act
      offlineAuthManager.updateState(OfflineAuthState.online); // Same state

      // Assert
      expect(states.length, equals(initialStateCount)); // No new state emitted

      await subscription.cancel();
    });
  });

  group('OfflineAuthManager - Utility Methods', () {
    test('should check if currently offline', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.disconnected);

      // Act
      final isOffline = await offlineAuthManager.isCurrentlyOffline();

      // Assert
      expect(isOffline, isTrue);
    });

    test('should check if currently online', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.connected);

      // Act
      final isOffline = await offlineAuthManager.isCurrentlyOffline();

      // Assert
      expect(isOffline, isFalse);
    });

    test('should get current network status', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.connected);

      // Act
      final status = await offlineAuthManager.getCurrentNetworkStatus();

      // Assert
      expect(status, NetworkStatus.connected);
      verify(() => mockConnectivityService.checkConnectivity()).called(1);
    });
  });

  group('OfflineAuthManager - Disposal', () {
    test('should dispose resources correctly', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.connected);

      await offlineAuthManager.initialize();
      expect(offlineAuthManager.currentState, isNotNull);

      // Act
      offlineAuthManager.dispose();

      // Assert
      // Should not throw when disposed
      expect(() => offlineAuthManager.dispose(), returnsNormally);
    });

    test('should reset state correctly', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.connected);

      await offlineAuthManager.initialize();
      expect(offlineAuthManager.currentState, OfflineAuthState.online);

      // Act
      offlineAuthManager.reset();

      // Assert
      expect(offlineAuthManager.currentState, OfflineAuthState.offlineWithoutCache);
    });
  });

  group('OfflineAuthManager - Error Handling', () {
    test('should handle initialization errors gracefully', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => offlineAuthManager.initialize(),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle errors when getting cached user profile', () async {
      // Arrange
      when(() => mockLocalDataSource.getUserData())
          .thenThrow(Exception('Storage error'));

      // Act
      final result = await offlineAuthManager.getCachedUserProfile();

      // Assert
      expect(result, isNull); // Should return null on error
    });

    test('should handle errors when getting cached data info', () async {
      // Arrange
      when(() => mockLocalDataSource.getUserData())
          .thenThrow(Exception('Storage error'));

      // Act
      final info = await offlineAuthManager.getCachedDataInfo();

      // Assert
      expect(info.userProfile, isNull);
      expect(info.isFresh, isFalse);
    });
  });

  group('OfflineAuthManager - Sync on Reconnect', () {
    test('should emit sync progress events during sync', () async {
      // Arrange
      await offlineAuthManager.initialize();

      final progressList = <SyncProgress>[];
      final subscription = offlineAuthManager.onSyncProgress.listen((progress) {
        progressList.add(progress);
      });

      // Act
      final result = await offlineAuthManager.syncWithServer();

      // Assert
      expect(result.success, isTrue);
      expect(result.state, OfflineAuthState.online);

      // Verify we got progress updates
      expect(progressList.isNotEmpty, isTrue);
      expect(progressList.last.step, SyncStep.completed);

      await subscription.cancel();
    });

    test('should refresh token when expired during sync', () async {
      // Arrange
      await offlineAuthManager.initialize();

      when(() => mockLocalDataSource.isTokenExpired())
          .thenAnswer((_) async => true);

      when(() => mockTokenRefreshService.refreshToken())
          .thenAnswer((_) async => Future.delayed(const Duration(milliseconds: 10)));

      // Act
      final result = await offlineAuthManager.syncWithServer();

      // Assert
      expect(result.success, isTrue);
      verify(() => mockTokenRefreshService.refreshToken()).called(1);
    });

    test('should skip token refresh when token is valid', () async {
      // Arrange
      await offlineAuthManager.initialize();

      when(() => mockLocalDataSource.isTokenExpired())
          .thenAnswer((_) async => false);

      // Act
      final result = await offlineAuthManager.syncWithServer();

      // Assert
      expect(result.success, isTrue);
      verifyNever(() => mockTokenRefreshService.refreshToken());
    });

    test('should fetch and cache user data during sync', () async {
      // Arrange
      await offlineAuthManager.initialize();

      final testUser = User(
        id: 'test-id',
        email: 'test@example.com',
        username: 'testuser',
        createdAt: DateTime.now(),
      );

      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => testUser);

      // Act
      final result = await offlineAuthManager.syncWithServer();

      // Assert
      expect(result.success, isTrue);
      verify(() => mockAuthRepository.getCurrentUser()).called(1);
      verify(() => mockLocalDataSource.cacheUserData(any())).called(1);
    });

    test('should handle token refresh failure gracefully', () async {
      // Arrange
      await offlineAuthManager.initialize();

      when(() => mockLocalDataSource.isTokenExpired())
          .thenAnswer((_) async => true);

      when(() => mockTokenRefreshService.refreshToken())
          .thenThrow(Exception('Token refresh failed'));

      // Act
      final result = await offlineAuthManager.syncWithServer();

      // Assert
      // Sync should still succeed even if token refresh fails
      expect(result.success, isTrue);
      expect(result.state, OfflineAuthState.online);
    });

    test('should handle user data fetch failure gracefully', () async {
      // Arrange
      await offlineAuthManager.initialize();

      when(() => mockAuthRepository.getCurrentUser())
          .thenThrow(Exception('Network error'));

      // Act
      final result = await offlineAuthManager.syncWithServer();

      // Assert
      // Sync should still succeed even if user data fetch fails
      expect(result.success, isTrue);
      expect(result.state, OfflineAuthState.online);
    });

    test('should not sync when offline', () async {
      // Arrange
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.disconnected);

      await offlineAuthManager.initialize();

      // Act
      final result = await offlineAuthManager.syncWithServer();

      // Assert
      expect(result.success, isFalse);
      expect(result.errorMessage, contains('Cannot sync while offline'));
      verifyNever(() => mockTokenRefreshService.refreshToken());
      verifyNever(() => mockAuthRepository.getCurrentUser());
    });

    test('should prevent concurrent sync operations', () async {
      // Arrange
      await offlineAuthManager.initialize();

      // Act - start two syncs concurrently
      final firstSync = offlineAuthManager.syncWithServer();
      final secondSync = offlineAuthManager.syncWithServer();

      final results = await Future.wait([firstSync, secondSync]);

      // Assert
      expect(results[0].success, isTrue);
      expect(results[1].success, isTrue);

      // Token refresh should only be called once
      verify(() => mockTokenRefreshService.refreshToken()).called(atMostOnce);
    });

    test('should complete all sync steps successfully', () async {
      // Arrange
      await offlineAuthManager.initialize();

      final testUser = User(
        id: 'test-id',
        email: 'test@example.com',
        username: 'testuser',
        createdAt: DateTime.now(),
      );

      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => testUser);

      final progressSteps = <SyncStep>[];
      final subscription = offlineAuthManager.onSyncProgress.listen((progress) {
        progressSteps.add(progress.step);
      });

      // Act
      final result = await offlineAuthManager.syncWithServer();

      // Assert
      expect(result.success, isTrue);
      expect(result.state, OfflineAuthState.online);

      // Verify all steps were executed
      expect(progressSteps, contains(SyncStep.starting));
      expect(progressSteps, contains(SyncStep.refreshingToken));
      expect(progressSteps, contains(SyncStep.syncingUserData));
      expect(progressSteps, contains(SyncStep.syncingPendingChanges));
      expect(progressSteps, contains(SyncStep.completed));

      await subscription.cancel();
    });

    test('should work without TokenRefreshService', () async {
      // Arrange
      final managerWithoutServices = OfflineAuthManager(
        connectivityService: mockConnectivityService,
        localDataSource: mockLocalDataSource,
        // tokenRefreshService and authRepository are null
      );

      await managerWithoutServices.initialize();

      // Act
      final result = await managerWithoutServices.syncWithServer();

      // Assert
      expect(result.success, isTrue);
      expect(result.state, OfflineAuthState.online);

      managerWithoutServices.dispose();
    });
  });

  group('OfflineAuthResult - Factory Methods', () {
    test('should create success result with correct values', () {
      // Act
      final result = OfflineAuthResult.success(
        state: OfflineAuthState.online,
      );

      // Assert
      expect(result.success, isTrue);
      expect(result.state, OfflineAuthState.online);
      expect(result.errorMessage, isNull);
      expect(result.timestamp, isNotNull);
    });

    test('should create failure result with error message', () {
      // Act
      final result = OfflineAuthResult.failure(
        errorMessage: 'Test error',
      );

      // Assert
      expect(result.success, isFalse);
      expect(result.state, OfflineAuthState.offlineWithoutCache);
      expect(result.errorMessage, 'Test error');
      expect(result.timestamp, isNotNull);
    });
  });

  group('CachedDataInfo - Factory Methods', () {
    test('should create info with data', () {
      // Arrange
      final data = {'key': 'value'};
      final cachedAt = DateTime.now();

      // Act
      final info = CachedDataInfo(
        userProfile: data,
        lastCachedAt: cachedAt,
        isFresh: true,
      );

      // Assert
      expect(info.userProfile, data);
      expect(info.lastCachedAt, cachedAt);
      expect(info.isFresh, isTrue);
    });

    test('should create none info for no data', () {
      // Act
      final info = CachedDataInfo.none();

      // Assert
      expect(info.userProfile, isNull);
      expect(info.lastCachedAt, isNull);
      expect(info.isFresh, isFalse);
    });
  });

  group('SyncProgress - Factory Methods', () {
    test('should create starting progress', () {
      // Act
      final progress = SyncProgress.starting();

      // Assert
      expect(progress.step, SyncStep.starting);
      expect(progress.progress, 0);
      expect(progress.isSuccess, isFalse);
      expect(progress.errorMessage, isNull);
    });

    test('should create refreshingToken progress', () {
      // Act
      final progress = SyncProgress.refreshingToken(progress: 25);

      // Assert
      expect(progress.step, SyncStep.refreshingToken);
      expect(progress.progress, 25);
      expect(progress.isSuccess, isFalse);
      expect(progress.errorMessage, isNull);
    });

    test('should create syncingUserData progress', () {
      // Act
      final progress = SyncProgress.syncingUserData(progress: 60);

      // Assert
      expect(progress.step, SyncStep.syncingUserData);
      expect(progress.progress, 60);
      expect(progress.isSuccess, isFalse);
      expect(progress.errorMessage, isNull);
    });

    test('should create syncingPendingChanges progress', () {
      // Act
      final progress = SyncProgress.syncingPendingChanges(progress: 90);

      // Assert
      expect(progress.step, SyncStep.syncingPendingChanges);
      expect(progress.progress, 90);
      expect(progress.isSuccess, isFalse);
      expect(progress.errorMessage, isNull);
    });

    test('should create completed progress', () {
      // Act
      final progress = SyncProgress.completed();

      // Assert
      expect(progress.step, SyncStep.completed);
      expect(progress.progress, 100);
      expect(progress.isSuccess, isTrue);
      expect(progress.errorMessage, isNull);
    });

    test('should create failed progress', () {
      // Arrange
      const errorMessage = 'Sync failed due to network error';

      // Act
      final progress = SyncProgress.failed(errorMessage: errorMessage);

      // Assert
      expect(progress.step, SyncStep.failed);
      expect(progress.progress, 0);
      expect(progress.isSuccess, isFalse);
      expect(progress.errorMessage, errorMessage);
    });

    test('should include timestamp when not provided', () {
      // Act
      final progress = SyncProgress.starting();
      final now = DateTime.now();

      // Assert
      expect(progress.timestamp.isBefore(now.add(const Duration(seconds: 1))), isTrue);
      expect(progress.timestamp.isAfter(now.subtract(const Duration(seconds: 1))), isTrue);
    });

    test('should use provided timestamp', () {
      // Arrange
      final timestamp = DateTime(2024, 1, 1, 12, 0, 0);

      // Act
      final progress = SyncProgress(
        step: SyncStep.completed,
        progress: 100,
        isSuccess: true,
        timestamp: timestamp,
      );

      // Assert
      expect(progress.timestamp, timestamp);
    });
  });
}
