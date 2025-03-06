import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soloadventurer/app/app.dart';
import 'package:soloadventurer/core/api/client/api_client.dart';
import 'package:soloadventurer/core/security/security_manager.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/features/auth/domain/services/token_manager.dart';
import 'package:soloadventurer/features/core/domain/services/connectivity_service.dart';
import 'package:soloadventurer/app/di/service_locator.dart';
import 'package:soloadventurer/config/test_config.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:soloadventurer/features/core/data/services/connectivity_service_impl.dart';
import 'package:flutter/foundation.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/auth/data/models/user_model.dart';
import 'package:soloadventurer/features/auth/data/providers/auth_data_providers.dart';

class MockConnectivityService implements ConnectivityService {
  final _statusController = StreamController<NetworkStatus>.broadcast();
  NetworkStatus _currentStatus = NetworkStatus.connected;
  bool _isDisposed = false;

  @override
  Stream<NetworkStatus> get onConnectivityChanged => _statusController.stream;

  @override
  Future<NetworkStatus> checkConnectivity() async {
    debugPrint(
        'MockConnectivityService: Checking connectivity: $_currentStatus');
    return _currentStatus;
  }

  @override
  Future<bool> get hasConnectivity async {
    debugPrint(
        'MockConnectivityService: Has connectivity: ${_currentStatus == NetworkStatus.connected}');
    return _currentStatus == NetworkStatus.connected;
  }

  @override
  bool get hasConnectivitySync {
    debugPrint(
        'MockConnectivityService: Has connectivity sync: ${_currentStatus == NetworkStatus.connected}');
    return _currentStatus == NetworkStatus.connected;
  }

  void setConnected(bool connected) {
    if (_isDisposed) return;

    final newStatus =
        connected ? NetworkStatus.connected : NetworkStatus.disconnected;
    debugPrint(
        'MockConnectivityService: Setting connected to $connected, current: $_currentStatus, new: $newStatus');

    // Only update and notify if the status actually changed
    if (_currentStatus != newStatus) {
      _currentStatus = newStatus;
      if (!_statusController.isClosed) {
        debugPrint(
            'MockConnectivityService: Broadcasting new status: $_currentStatus');
        _statusController.add(_currentStatus);
      }
    } else {
      debugPrint(
          'MockConnectivityService: Status unchanged, skipping broadcast');
    }
  }

  @override
  void dispose() {
    debugPrint('MockConnectivityService: Disposing');
    _isDisposed = true;
    if (!_statusController.isClosed) {
      _statusController.close();
    }
  }
}

class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  bool _isAuthenticated = false;
  AuthSession? _currentSession;

  @override
  Future<AuthSession> refreshToken() async {
    debugPrint('MockAuthRemoteDataSource: Refreshing token');
    if (!_isAuthenticated) {
      debugPrint('MockAuthRemoteDataSource: Not authenticated');
      throw const AuthException('No authenticated user');
    }

    if (_currentSession == null) {
      debugPrint('MockAuthRemoteDataSource: No current session');
      throw const AuthException('No current session');
    }

    // Return a new session with refreshed tokens
    final newSession = AuthSession(
      accessToken:
          'refreshed_access_token_${DateTime.now().millisecondsSinceEpoch}',
      idToken: 'refreshed_id_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken:
          'refreshed_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );

    _currentSession = newSession;
    debugPrint('MockAuthRemoteDataSource: Token refreshed successfully');
    return newSession;
  }

  void setAuthenticated(bool authenticated, {AuthSession? session}) {
    _isAuthenticated = authenticated;
    _currentSession = session;
  }

  @override
  Future<(UserModel, bool)> register({
    required String email,
    required String password,
    required String name,
  }) async {
    throw UnimplementedError();
  }

  @override
  Future<(UserModel, String)> signIn(String email, String password) async {
    throw UnimplementedError();
  }

  @override
  Future<void> signOut() async {
    throw UnimplementedError();
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    throw UnimplementedError();
  }

  @override
  Future<bool> isSignedIn() async {
    throw UnimplementedError();
  }

  @override
  Future<void> verifyEmail(String code, String email) async {
    throw UnimplementedError();
  }

  @override
  Future<void> resendVerificationEmail() async {
    throw UnimplementedError();
  }

  @override
  Future<void> forgotPassword(String email) async {
    throw UnimplementedError();
  }

  @override
  Future<void> confirmForgotPassword(
      String email, String code, String newPassword) async {
    throw UnimplementedError();
  }

  @override
  Future<void> adminSetUserPassword(String email, String newPassword,
      {bool permanent = false}) async {
    throw UnimplementedError();
  }

  @override
  Future<void> adminResetUserPassword(String email) async {
    throw UnimplementedError();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    throw UnimplementedError();
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late TokenManager tokenManager;
  late MockConnectivityService mockConnectivityService;
  late AuthLocalDataSource authLocalDataSource;
  late MockAuthRemoteDataSource mockAuthRemoteDataSource;
  late SecurityManager securityManager;

  setUp(() async {
    debugPrint('\n=== Setting up test ===');
    debugPrint('Resetting service locator and initializing test environment');
    await resetServiceLocator();
    SharedPreferences.setMockInitialValues({});

    debugPrint('Creating and configuring mock services');
    mockConnectivityService = MockConnectivityService();
    debugPrint('Initialized MockConnectivityService with default connected state');

    mockAuthRemoteDataSource = MockAuthRemoteDataSource();
    debugPrint('Initialized MockAuthRemoteDataSource with unauthenticated state');

    debugPrint('Setting up service locator in test mode');
    await setupServiceLocator(isTest: true);

    debugPrint('Creating ProviderContainer with mock service overrides');
    container = ProviderContainer(
      overrides: [
        connectivityServiceImplProvider
            .overrideWithValue(mockConnectivityService),
        authRemoteDataSourceProvider
            .overrideWithValue(mockAuthRemoteDataSource),
      ],
    );
    debugPrint('Provider container created with mock service overrides');

    debugPrint('Initializing security manager and local data source');
    securityManager = getIt<SecurityManager>();
    authLocalDataSource = AuthLocalDataSourceImpl(securityManager);

    debugPrint('Clearing existing storage and auth data');
    await getIt<FlutterSecureStorage>().deleteAll();
    await authLocalDataSource.clearAuthData();

    debugPrint('Setting up initial authentication state');
    final initialTokens = AuthSession(
      accessToken: 'test_access_token',
      idToken: 'test_id_token',
      refreshToken: 'test_refresh_token',
      expiresAt: DateTime.now().add(const Duration(minutes: 10)),
    );
    debugPrint('Created initial test tokens with 10-minute validity');

    debugPrint('Saving auth data to local storage');
    await authLocalDataSource.saveAuthData(
      initialTokens.accessToken,
      initialTokens.refreshToken,
      expiresAt: initialTokens.expiresAt,
      idToken: initialTokens.idToken,
    );
    debugPrint('Auth data saved to local storage');

    debugPrint('Configuring mock remote data source');
    mockAuthRemoteDataSource.setAuthenticated(true, session: initialTokens);
    debugPrint('Mock remote data source configured with test session');

    debugPrint('Initializing TokenManager');
    tokenManager = container.read(tokenManagerProvider.notifier);
    debugPrint('TokenManager instance created');

    debugPrint('Waiting for TokenManager initialization');
    await tokenManager.initialize();
    debugPrint('TokenManager initialization completed');

    addTearDown(() async {
      debugPrint('\n=== Tearing down test ===');
      debugPrint('Clearing TokenManager session');
      await tokenManager.clearSession();
      debugPrint('Disposing provider container');
      container.dispose();
      debugPrint('Clearing secure storage');
      await getIt<FlutterSecureStorage>().deleteAll();
      debugPrint('Resetting service locator');
      await resetServiceLocator();
      debugPrint('Test teardown complete');
    });
  });

  Future<void> waitForState(FeatureAvailability expectedState) async {
    debugPrint('\nWaiting for state transition to: $expectedState');
    debugPrint('Current state: ${tokenManager.state}');
    
    if (tokenManager.state == expectedState) {
      debugPrint('Already in expected state: $expectedState');
      return;
    }

    final completer = Completer<void>();
    late ProviderSubscription<FeatureAvailability> subscription;

    debugPrint('Setting up state change listener');
    subscription = container.listen(
      tokenManagerProvider,
      (previous, next) {
        debugPrint('State changed: $previous -> $next');
        if (next == expectedState && !completer.isCompleted) {
          debugPrint('Reached expected state: $expectedState');
          completer.complete();
          subscription.close();
        }
      },
    );

    try {
      debugPrint('Waiting for state transition with 5-second timeout');
      await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          debugPrint('State transition timeout - expected: $expectedState, current: ${tokenManager.state}');
          throw TimeoutException(
            'Failed to transition to $expectedState state. Current state: ${tokenManager.state}',
          );
        },
      );
    } finally {
      debugPrint('Cleaning up state change listener');
      subscription.close();
    }
  }

  group('TokenManager Integration Tests', () {
    testWidgets('should handle token lifecycle according to AWS specifications',
        (tester) async {
      // 1. Wait for initial state
      await waitForState(FeatureAvailability.fullyAvailable);
      expect(tokenManager.state, equals(FeatureAvailability.fullyAvailable));

      // 2. Test offline transition
      mockConnectivityService.setConnected(false);
      await tester.pumpAndSettle();
      await waitForState(FeatureAvailability.offlineWithCache);
      expect(tokenManager.state, equals(FeatureAvailability.offlineWithCache));

      // 3. Test online transition
      mockConnectivityService.setConnected(true);
      await tester.pumpAndSettle();
      await waitForState(FeatureAvailability.fullyAvailable);
      expect(tokenManager.state, equals(FeatureAvailability.fullyAvailable));
    });

    testWidgets('should handle token refresh with AWS exponential backoff',
        (tester) async {
      // 1. Setup tokens near expiration
      final expiringTokens = AuthSession(
        accessToken: 'test_access_token',
        idToken: 'test_id_token',
        refreshToken: 'test_refresh_token',
        expiresAt: DateTime.now().add(const Duration(minutes: 3)),
      );

      await authLocalDataSource.saveAuthData(
        expiringTokens.accessToken,
        expiringTokens.refreshToken,
        expiresAt: expiringTokens.expiresAt,
        idToken: expiringTokens.idToken,
      );

      // 2. Initialize and wait for completion
      final stateCompleter = Completer<void>();
      final subscription = container.listen(
        tokenManagerProvider,
        (previous, next) {
          if (next == FeatureAvailability.fullyAvailable &&
              !stateCompleter.isCompleted) {
            stateCompleter.complete();
          }
        },
      );

      await tokenManager.initialize();
      await tokenManager.waitForInitialization();
      await tester.pumpAndSettle();

      // Wait for state to update with timeout
      await stateCompleter.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException(
          'Failed to transition to fully available state. Current state: ${tokenManager.state}',
        ),
      );

      expect(tokenManager.state, equals(FeatureAvailability.fullyAvailable));

      // 3. Force multiple refresh attempts to test exponential backoff
      await tokenManager.initialize();
      await tester.pump(const Duration(seconds: 1));
      await tokenManager.initialize();
      await tester.pump(const Duration(seconds: 2));
      await tokenManager.initialize();
      await tester.pump(const Duration(seconds: 4));

      subscription.close();
    });

    testWidgets(
        'should handle token revocation according to AWS specifications',
        (tester) async {
      // 1. Setup initial tokens
      final initialTokens = AuthSession(
        accessToken: 'test_access_token',
        idToken: 'test_id_token',
        refreshToken: 'test_refresh_token',
        expiresAt: DateTime.now().add(const Duration(minutes: 30)),
      );

      await authLocalDataSource.saveAuthData(
        initialTokens.accessToken,
        initialTokens.refreshToken,
        expiresAt: initialTokens.expiresAt,
        idToken: initialTokens.idToken,
      );

      // 2. Initialize and wait for completion
      final stateCompleter = Completer<void>();
      final subscription = container.listen(
        tokenManagerProvider,
        (previous, next) {
          if (next == FeatureAvailability.fullyAvailable &&
              !stateCompleter.isCompleted) {
            stateCompleter.complete();
          }
        },
      );

      await tokenManager.initialize();
      await tokenManager.waitForInitialization();
      await tester.pumpAndSettle();

      // Wait for state to update with timeout
      await stateCompleter.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException(
          'Failed to transition to fully available state. Current state: ${tokenManager.state}',
        ),
      );

      expect(tokenManager.state, equals(FeatureAvailability.fullyAvailable));

      // 3. Simulate token revocation
      await authLocalDataSource.clearAuthData();
      await tester.pumpAndSettle();

      expect(tokenManager.state, equals(FeatureAvailability.unauthorized));

      subscription.close();
    });

    testWidgets('should handle minimum token validity threshold',
        (tester) async {
      // 1. Setup tokens with less than 2 minutes validity (AWS minimum)
      final nearExpiryTokens = AuthSession(
        accessToken: 'test_access_token',
        idToken: 'test_id_token',
        refreshToken: 'test_refresh_token',
        expiresAt: DateTime.now().add(const Duration(minutes: 1)),
      );

      await authLocalDataSource.saveAuthData(
        nearExpiryTokens.accessToken,
        nearExpiryTokens.refreshToken,
        expiresAt: nearExpiryTokens.expiresAt,
        idToken: nearExpiryTokens.idToken,
      );

      // 2. Initialize and wait for completion
      final stateCompleter = Completer<void>();
      final subscription = container.listen(
        tokenManagerProvider,
        (previous, next) {
          if (next == FeatureAvailability.tokenExpired &&
              !stateCompleter.isCompleted) {
            stateCompleter.complete();
          }
        },
      );

      await tokenManager.initialize();
      await tokenManager.waitForInitialization();
      await tester.pumpAndSettle();

      // Wait for state to update with timeout
      await stateCompleter.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException(
          'Failed to transition to token expired state. Current state: ${tokenManager.state}',
        ),
      );

      // 3. Verify token is considered expired due to minimum validity threshold
      expect(tokenManager.state, equals(FeatureAvailability.tokenExpired),
          reason: 'AWS requires minimum 2-minute token validity');

      subscription.close();
    });

    testWidgets('should handle token refresh recovery attempts',
        (tester) async {
      // 1. Setup tokens that will trigger refresh
      final expiringTokens = AuthSession(
        accessToken: 'test_access_token',
        idToken: 'test_id_token',
        refreshToken: 'test_refresh_token',
        expiresAt: DateTime.now().add(const Duration(minutes: 3)),
      );

      await authLocalDataSource.saveAuthData(
        expiringTokens.accessToken,
        expiringTokens.refreshToken,
        expiresAt: expiringTokens.expiresAt,
        idToken: expiringTokens.idToken,
      );

      // 2. Initialize and wait for completion
      final stateCompleter = Completer<void>();
      final subscription = container.listen(
        tokenManagerProvider,
        (previous, next) {
          if (next == FeatureAvailability.fullyAvailable &&
              !stateCompleter.isCompleted) {
            stateCompleter.complete();
          }
        },
      );

      await tokenManager.initialize();
      await tokenManager.waitForInitialization();
      await tester.pumpAndSettle();

      // Wait for state to update with timeout
      await stateCompleter.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () => throw TimeoutException(
          'Failed to transition to fully available state. Current state: ${tokenManager.state}',
        ),
      );

      expect(tokenManager.state, equals(FeatureAvailability.fullyAvailable));

      // 3. Simulate failed refresh attempts
      mockAuthRemoteDataSource.setAuthenticated(false);
      await tokenManager.initialize(); // Force refresh attempt
      await tester.pump(const Duration(seconds: 1)); // Wait for backoff

      // 4. Verify state transitions during recovery
      expect(tokenManager.state, equals(FeatureAvailability.tokenExpired));

      // 5. Re-authenticate and verify recovery
      mockAuthRemoteDataSource.setAuthenticated(true,
          session: AuthSession(
            accessToken: 'recovered_access_token',
            idToken: 'recovered_id_token',
            refreshToken: 'recovered_refresh_token',
            expiresAt: DateTime.now().add(const Duration(hours: 1)),
          ));

      // Wait for recovery
      await tester.pump(const Duration(seconds: 2));
      expect(tokenManager.state, equals(FeatureAvailability.fullyAvailable));

      subscription.close();
    });
  });
}
