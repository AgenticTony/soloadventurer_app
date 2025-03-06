import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/features/auth/domain/services/token_manager.dart';
import 'package:soloadventurer/features/auth/data/providers/auth_data_providers.dart';
import 'package:soloadventurer/features/core/domain/services/connectivity_service.dart';
import 'package:soloadventurer/features/core/data/services/connectivity_service_impl.dart';
import 'package:riverpod/riverpod.dart';

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

class MockAuthRemoteDataSource extends Mock implements AuthRemoteDataSource {}

class MockConnectivityService extends Mock implements ConnectivityService {
  final _connectivityController = StreamController<NetworkStatus>.broadcast();
  NetworkStatus _currentStatus = NetworkStatus.connected;

  @override
  Stream<NetworkStatus> get onConnectivityChanged =>
      _connectivityController.stream;

  @override
  Future<NetworkStatus> checkConnectivity() async => _currentStatus;

  @override
  Future<bool> get hasConnectivity async =>
      _currentStatus == NetworkStatus.connected;

  void emitConnectivityState(NetworkStatus status) {
    _currentStatus = status;
    _connectivityController.add(status);
  }

  @override
  void dispose() {
    _connectivityController.close();
  }
}

void main() {
  late ProviderContainer container;
  late MockAuthLocalDataSource localDataSource;
  late MockAuthRemoteDataSource remoteDataSource;
  late MockConnectivityService connectivityService;

  setUp(() {
    localDataSource = MockAuthLocalDataSource();
    remoteDataSource = MockAuthRemoteDataSource();
    connectivityService = MockConnectivityService();

    container = ProviderContainer(
      overrides: [
        authLocalDataSourceProvider.overrideWithValue(localDataSource),
        authRemoteDataSourceProvider.overrideWithValue(remoteDataSource),
        connectivityServiceImplProvider.overrideWithValue(connectivityService),
      ],
    );

    // Register fallback values for mocks
    registerFallbackValue(DateTime.now());
  });

  tearDown(() {
    connectivityService.dispose();
    container.dispose();
  });

  group('TokenManager - Token Lifecycle', () {
    final expiresAt = DateTime.now().add(const Duration(hours: 1));
    final expiredAt = DateTime.now().subtract(const Duration(minutes: 5));

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

    test('should be fully available with valid tokens', () async {
      // Arrange
      when(() => localDataSource.getAuthToken())
          .thenAnswer((_) async => 'valid_access_token');
      when(() => localDataSource.getIdToken())
          .thenAnswer((_) async => 'valid_id_token');
      when(() => localDataSource.getRefreshToken())
          .thenAnswer((_) async => 'valid_refresh_token');
      when(() => localDataSource.getTokenExpiration())
          .thenAnswer((_) async => expiresAt);

      // Act
      final notifier = container.read(tokenManagerProvider.notifier);
      await notifier.initialize();

      // Assert
      expect(container.read(tokenManagerProvider),
          equals(FeatureAvailability.fullyAvailable));
    });

    test('should handle token refresh with exponential backoff', () async {
      // Arrange
      when(() => localDataSource.getAuthToken())
          .thenAnswer((_) async => 'expired_token');
      when(() => localDataSource.getIdToken())
          .thenAnswer((_) async => 'expired_id_token');
      when(() => localDataSource.getRefreshToken())
          .thenAnswer((_) async => 'valid_refresh_token');
      when(() => localDataSource.getTokenExpiration())
          .thenAnswer((_) async => expiredAt);

      // Simulate network error for first attempt
      when(() => remoteDataSource.refreshToken())
          .thenThrow(Exception('Network error'));

      // Act & Assert
      final stopwatch = Stopwatch()..start();
      final notifier = container.read(tokenManagerProvider.notifier);
      await notifier.initialize();

      // First attempt
      await notifier.refreshToken();
      final firstAttemptDuration = stopwatch.elapsed;

      // Second attempt
      await notifier.refreshToken();
      final secondAttemptDuration = stopwatch.elapsed;

      // Verify exponential backoff
      expect(
        secondAttemptDuration.inMilliseconds >
            firstAttemptDuration.inMilliseconds * 1.5,
        isTrue,
        reason: 'Second attempt should take longer due to exponential backoff',
      );
    });

    test('should handle offline mode with cached tokens', () async {
      // Arrange
      when(() => localDataSource.getAuthToken())
          .thenAnswer((_) async => 'cached_token');
      when(() => localDataSource.getIdToken())
          .thenAnswer((_) async => 'cached_id_token');
      when(() => localDataSource.getRefreshToken())
          .thenAnswer((_) async => 'cached_refresh_token');
      when(() => localDataSource.getTokenExpiration())
          .thenAnswer((_) async => expiresAt);

      // Set offline mode
      connectivityService.emitConnectivityState(NetworkStatus.disconnected);

      // Act
      final notifier = container.read(tokenManagerProvider.notifier);
      await notifier.initialize();

      // Assert
      expect(container.read(tokenManagerProvider),
          equals(FeatureAvailability.offlineWithCache));
      verifyNever(() => remoteDataSource.refreshToken());
    });

    test('should clear session and tokens', () async {
      // Arrange
      when(() => localDataSource.clearAuthData()).thenAnswer((_) async {});

      // Act
      final notifier = container.read(tokenManagerProvider.notifier);
      await notifier.clearSession();

      // Assert
      expect(container.read(tokenManagerProvider),
          equals(FeatureAvailability.unauthorized));
      verify(() => localDataSource.clearAuthData()).called(1);
    });

    test('should automatically refresh tokens near expiry', () async {
      // Arrange
      final nearExpiry = DateTime.now().add(const Duration(minutes: 4));
      when(() => localDataSource.getAuthToken())
          .thenAnswer((_) async => 'current_token');
      when(() => localDataSource.getIdToken())
          .thenAnswer((_) async => 'current_id_token');
      when(() => localDataSource.getRefreshToken())
          .thenAnswer((_) async => 'valid_refresh_token');
      when(() => localDataSource.getTokenExpiration())
          .thenAnswer((_) async => nearExpiry);

      when(() => remoteDataSource.refreshToken())
          .thenAnswer((_) async => AuthSession(
                accessToken: 'new_token',
                idToken: 'new_id_token',
                refreshToken: 'new_refresh_token',
                expiresAt: expiresAt,
              ));

      when(() => localDataSource.saveAuthData(
            any(),
            any(),
            expiresAt: any(named: 'expiresAt'),
            idToken: any(named: 'idToken'),
          )).thenAnswer((_) async {});

      // Act
      final notifier = container.read(tokenManagerProvider.notifier);
      await notifier.initialize();
      await notifier.refreshToken(); // Explicitly trigger refresh

      // Assert
      expect(container.read(tokenManagerProvider),
          equals(FeatureAvailability.fullyAvailable));
      verify(() => remoteDataSource.refreshToken()).called(1);
      verify(() => localDataSource.saveAuthData(
            'new_token',
            'new_refresh_token',
            expiresAt: expiresAt,
            idToken: 'new_id_token',
          )).called(1);
    });

    test('should handle connectivity changes', () async {
      // Arrange
      when(() => localDataSource.getAuthToken())
          .thenAnswer((_) async => 'valid_token');
      when(() => localDataSource.getIdToken())
          .thenAnswer((_) async => 'valid_id_token');
      when(() => localDataSource.getRefreshToken())
          .thenAnswer((_) async => 'valid_refresh_token');
      when(() => localDataSource.getTokenExpiration())
          .thenAnswer((_) async => expiresAt);

      // Act
      final notifier = container.read(tokenManagerProvider.notifier);
      await notifier.initialize();

      // Assert initial state
      expect(container.read(tokenManagerProvider),
          equals(FeatureAvailability.fullyAvailable));

      // Create a completer to track state changes
      final stateChanged = Completer<void>();
      final subscription = container.listen(
        tokenManagerProvider,
        (_, __) {
          if (!stateChanged.isCompleted) {
            stateChanged.complete();
          }
        },
      );

      // Simulate going offline
      connectivityService.emitConnectivityState(NetworkStatus.disconnected);
      await stateChanged.future;
      
      expect(container.read(tokenManagerProvider),
          equals(FeatureAvailability.offlineWithCache));

      // Create another completer for the next state change
      final onlineStateChanged = Completer<void>();
      final onlineSubscription = container.listen(
        tokenManagerProvider,
        (_, __) {
          if (!onlineStateChanged.isCompleted) {
            onlineStateChanged.complete();
          }
        },
      );

      // Simulate coming back online
      connectivityService.emitConnectivityState(NetworkStatus.connected);
      await onlineStateChanged.future;

      expect(container.read(tokenManagerProvider),
          equals(FeatureAvailability.fullyAvailable));

      // Cleanup
      subscription.close();
      onlineSubscription.close();
    });
  });
}
