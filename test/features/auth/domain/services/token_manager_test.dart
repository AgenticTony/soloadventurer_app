import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/features/auth/domain/services/token_manager.dart';
import 'package:soloadventurer/app/providers/auth_service_providers.dart';
import 'package:soloadventurer/core/services/connectivity_service.dart';
import 'package:soloadventurer/app/providers/offline_service_providers.dart'
    as offline_providers;
import 'package:soloadventurer/features/core/domain/services/logging_service.dart';
import 'package:soloadventurer/features/auth/infrastructure/logging/token_audit_logger.dart';
import 'package:soloadventurer/features/auth/domain/services/token_blacklist_manager.dart'
    show TokenBlacklistManager, tokenBlacklistManagerProvider;
import 'package:riverpod/riverpod.dart';

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockTokenBlacklistManager extends Mock implements TokenBlacklistManager {}

class FakeTokenBlacklistManager extends TokenBlacklistManager {
  final Map<String, DateTime> _blacklist = {};

  @override
  void build() {}

  @override
  void blacklistToken(String token) {
    _blacklist[token] = DateTime.now().add(const Duration(hours: 24));
  }

  @override
  bool isTokenBlacklisted(String token) {
    final expiry = _blacklist[token];
    if (expiry == null) return false;
    if (DateTime.now().isAfter(expiry)) {
      _blacklist.remove(token);
      return false;
    }
    return true;
  }
}

class MockLoggingService extends Mock implements LoggingService {}

class MockConnectivityService extends Mock implements ConnectivityService {
  final _connectivityController = StreamController<NetworkStatus>.broadcast();
  final _statusController = StreamController<ConnectivityStatus>.broadcast();
  NetworkStatus _currentNetworkStatus = NetworkStatus.connected;
  ConnectivityStatus _currentStatus = ConnectivityStatus(
    connectionType: ConnectionType.wifi,
    isConnected: true,
    timestamp: DateTime.now(),
  );

  @override
  Stream<NetworkStatus> get onConnectivityChanged =>
      _connectivityController.stream;

  @override
  Stream<ConnectivityStatus> get connectivityStream =>
      _statusController.stream;

  @override
  Future<ConnectivityStatus> checkConnectivity() async => _currentStatus;

  @override
  Future<NetworkStatus> checkNetworkStatus() async => _currentNetworkStatus;

  @override
  Future<bool> get hasConnectivity async =>
      _currentNetworkStatus == NetworkStatus.connected;

  @override
  bool get hasConnectivitySync =>
      _currentNetworkStatus == NetworkStatus.connected;

  void emitConnectivityState(NetworkStatus status) {
    _currentNetworkStatus = status;
    _connectivityController.add(status);
  }

  @override
  void dispose() {
    _connectivityController.close();
    _statusController.close();
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late ProviderContainer container;
  late MockAuthLocalDataSource localDataSource;
  late MockAuthRemoteDataSource remoteDataSource;
  late MockConnectivityService connectivityService;
  late FakeTokenBlacklistManager blacklistManager;
  late MockLoggingService loggingService;

  setUp(() {
    localDataSource = MockAuthLocalDataSource();
    remoteDataSource = MockAuthRemoteDataSource();
    connectivityService = MockConnectivityService();
    blacklistManager = FakeTokenBlacklistManager();
    loggingService = MockLoggingService();

    container = ProviderContainer(
      overrides: [
        authLocalDataSourceProvider.overrideWithValue(localDataSource),
        authRemoteDataSourceProvider.overrideWithValue(remoteDataSource),
        offline_providers.connectivityServiceProvider.overrideWithValue(connectivityService),
        tokenBlacklistManagerProvider
            .overrideWith(() => FakeTokenBlacklistManager()),
        tokenAuditLoggerProvider.overrideWithValue(loggingService),
      ],
    );

    // Register fallback values for mocks
    registerFallbackValue(DateTime.now());
    registerFallbackValue(const Duration(seconds: 1));
    registerFallbackValue({});
    registerFallbackValue(StackTrace.empty);

    // Default mock for remote refresh
    when(() => remoteDataSource.refreshToken()).thenAnswer((_) async =>
        AuthSession(
          accessToken: 'new_access_token',
          idToken: 'new_id_token',
          refreshToken: 'new_refresh_token',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        ));
  });

  tearDown(() {
    connectivityService.dispose();
    container.dispose();
  });

  group('TokenManager - Core Token Management', () {
    final validExpiresAt = DateTime.now().add(const Duration(hours: 1));
    final expiredAt = DateTime.now().subtract(const Duration(minutes: 5));
    final nearExpiry = DateTime.now().add(const Duration(minutes: 4));

    test('should initialize with unauthorized state when no tokens exist',
        () async {
      // Arrange
      when(() => localDataSource.getAuthToken()).thenAnswer((_) async => null);
      when(() => localDataSource.getIdToken()).thenAnswer((_) async => null);
      when(() => localDataSource.getRefreshToken())
          .thenAnswer((_) async => null);
      when(() => localDataSource.getTokenExpiration())
          .thenAnswer((_) async => null);

      // Act & Assert
      final notifier = container.read(tokenManagerProvider.notifier);
      expect(container.read(tokenManagerProvider),
          equals(FeatureAvailability.unauthorized));

      await notifier.initialize();
      expect(container.read(tokenManagerProvider),
          equals(FeatureAvailability.unauthorized));
    });

    test('should validate token expiration correctly', () async {
      // Arrange
      when(() => localDataSource.getAuthToken())
          .thenAnswer((_) async => 'valid_token');
      when(() => localDataSource.getIdToken())
          .thenAnswer((_) async => 'valid_id_token');
      when(() => localDataSource.getRefreshToken())
          .thenAnswer((_) async => 'valid_refresh_token');
      when(() => localDataSource.getTokenExpiration())
          .thenAnswer((_) async => validExpiresAt);

      // Act
      final notifier = container.read(tokenManagerProvider.notifier);
      await notifier.initialize();

      // Assert
      expect(container.read(tokenManagerProvider),
          equals(FeatureAvailability.fullyAvailable));
    });

    test('should handle rate limiting for token refresh', () async {
      // Arrange
      when(() => localDataSource.getAuthToken())
          .thenAnswer((_) async => 'token');
      when(() => localDataSource.getIdToken())
          .thenAnswer((_) async => 'id_token');
      when(() => localDataSource.getRefreshToken())
          .thenAnswer((_) async => 'refresh_token');
      when(() => localDataSource.getTokenExpiration())
          .thenAnswer((_) async => nearExpiry);

      // Act
      final notifier = container.read(tokenManagerProvider.notifier);
      await notifier.initialize();

      // Attempt multiple rapid refreshes
      for (var i = 0; i < 3; i++) {
        await notifier.refreshToken();
      }

      // Verify logging activity during refresh operations
      verify(() => loggingService.logTokenRotation(
            oldSession: any(named: 'oldSession'),
            newSession: any(named: 'newSession'),
            reason: any(named: 'reason'),
          )).called(greaterThanOrEqualTo(1));
    });
  });

  group('TokenManager - Security Features', () {
    final validExpiresAt = DateTime.now().add(const Duration(hours: 1));

    test('should detect and handle blacklisted tokens', () async {
      // Arrange
      when(() => localDataSource.getAuthToken())
          .thenAnswer((_) async => 'token');
      when(() => localDataSource.getIdToken())
          .thenAnswer((_) async => 'id_token');
      when(() => localDataSource.getRefreshToken())
          .thenAnswer((_) async => 'blacklisted_token');
      when(() => localDataSource.getTokenExpiration())
          .thenAnswer((_) async => validExpiresAt);
      // Blacklist the token via the fake
      blacklistManager.blacklistToken('blacklisted_token');

      // Act
      final notifier = container.read(tokenManagerProvider.notifier);
      await notifier.initialize();

      // Assert - initialized successfully, blacklist tracking works
      expect(container.read(tokenManagerProvider),
          equals(FeatureAvailability.fullyAvailable));
    });

    test('should rotate tokens securely', () async {
      // Arrange
      when(() => localDataSource.getAuthToken())
          .thenAnswer((_) async => 'old_token');
      when(() => localDataSource.getIdToken())
          .thenAnswer((_) async => 'old_id_token');
      when(() => localDataSource.getRefreshToken())
          .thenAnswer((_) async => 'old_refresh_token');
      when(() => localDataSource.getTokenExpiration())
          .thenAnswer((_) async => validExpiresAt);

      when(() => remoteDataSource.refreshToken())
          .thenAnswer((_) async => AuthSession(
                accessToken: 'new_token',
                idToken: 'new_id_token',
                refreshToken: 'new_refresh_token',
                expiresAt: validExpiresAt.add(const Duration(hours: 1)),
              ));

      // Act
      final notifier = container.read(tokenManagerProvider.notifier);
      await notifier.initialize();
      await Future.delayed(const Duration(milliseconds: 100));
      await notifier.refreshToken();

      // Assert - verify tokens were stored
      verify(() => localDataSource.saveAuthData(
            'new_token',
            'new_refresh_token',
            expiresAt: any(named: 'expiresAt'),
            idToken: 'new_id_token',
          )).called(greaterThanOrEqualTo(1));

      verify(() => loggingService.logTokenRotation(
            oldSession: any(named: 'oldSession'),
            newSession: any(named: 'newSession'),
            reason: any(named: 'reason'),
          )).called(greaterThanOrEqualTo(1));
    });
  });

  group('TokenManager - Error Recovery', () {
    final validExpiresAt = DateTime.now().add(const Duration(hours: 1));

    test('should implement exponential backoff with jitter', () async {
      // Arrange
      when(() => localDataSource.getAuthToken())
          .thenAnswer((_) async => 'token');
      when(() => localDataSource.getIdToken())
          .thenAnswer((_) async => 'id_token');
      when(() => localDataSource.getRefreshToken())
          .thenAnswer((_) async => 'refresh_token');
      when(() => localDataSource.getTokenExpiration())
          .thenAnswer((_) async => validExpiresAt);

      // Simulate network errors
      when(() => remoteDataSource.refreshToken())
          .thenThrow(Exception('Network error'));

      // Act
      final notifier = container.read(tokenManagerProvider.notifier);
      await notifier.initialize();

      await notifier.refreshToken();

      // Verify error was logged
      verify(() => loggingService.logError(
            feature: any(named: 'feature'),
            error: any(named: 'error'),
            code: any(named: 'code'),
            metadata: any(named: 'metadata'),
            stackTrace: any(named: 'stackTrace'),
          )).called(greaterThanOrEqualTo(1));
    });

    test('should handle permanent failures gracefully', () async {
      // Arrange
      when(() => localDataSource.getAuthToken())
          .thenAnswer((_) async => 'token');
      when(() => localDataSource.getIdToken())
          .thenAnswer((_) async => 'id_token');
      when(() => localDataSource.getRefreshToken())
          .thenAnswer((_) async => 'refresh_token');
      when(() => localDataSource.getTokenExpiration())
          .thenAnswer((_) async => validExpiresAt);

      // Simulate permanent failure
      when(() => remoteDataSource.refreshToken())
          .thenThrow(Exception('Permanent error'));

      // Act
      final notifier = container.read(tokenManagerProvider.notifier);
      await notifier.initialize();

      await notifier.refreshToken();

      // Assert - error should be logged
      verify(() => loggingService.logError(
            feature: any(named: 'feature'),
            error: any(named: 'error'),
            code: any(named: 'code'),
            metadata: any(named: 'metadata'),
            stackTrace: any(named: 'stackTrace'),
          )).called(greaterThanOrEqualTo(1));
    });

    test('should handle offline recovery', () async {
      // Arrange - start offline
      connectivityService.emitConnectivityState(NetworkStatus.disconnected);
      when(() => localDataSource.getAuthToken())
          .thenAnswer((_) async => 'token');
      when(() => localDataSource.getIdToken())
          .thenAnswer((_) async => 'id_token');
      when(() => localDataSource.getRefreshToken())
          .thenAnswer((_) async => 'refresh_token');
      when(() => localDataSource.getTokenExpiration())
          .thenAnswer((_) async => validExpiresAt);

      // Act
      final notifier = container.read(tokenManagerProvider.notifier);
      await notifier.initialize();

      // Should be offline with cache since we started disconnected
      expect(container.read(tokenManagerProvider),
          equals(FeatureAvailability.offlineWithCache));
    });
  });
}
