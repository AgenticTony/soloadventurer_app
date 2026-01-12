import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soloadventurer/core/security/security_manager.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/features/auth/data/models/auth_tokens.dart';
import 'package:soloadventurer/features/auth/data/models/credentials.dart';
import 'package:soloadventurer/features/auth/domain/services/token_manager.dart';
import 'package:soloadventurer/features/core/domain/services/connectivity_service.dart';
import 'package:soloadventurer/app/di/service_locator.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:soloadventurer/features/core/data/services/connectivity_service_impl.dart';
import 'package:flutter/foundation.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/auth/data/models/user_model.dart';
import 'package:soloadventurer/app/providers/auth_service_providers.dart';

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
    if (!_isAuthenticated) {
      throw const AuthException('No authenticated user');
    }

    if (_currentSession == null) {
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
    return newSession;
  }

  @override
  Future<AuthTokens> refreshTokenWithString(String refreshToken) async {
    if (!_isAuthenticated) {
      throw const AuthException('No authenticated user');
    }

    // Create a new session with refreshed tokens
    final newSession = AuthSession(
      accessToken:
          'refreshed_access_token_${DateTime.now().millisecondsSinceEpoch}',
      idToken: 'refreshed_id_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken: refreshToken,
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );

    _currentSession = newSession;

    // Return AuthTokens
    return AuthTokens(
      accessToken: newSession.accessToken,
      idToken: newSession.idToken,
      refreshToken: newSession.refreshToken,
      expiration: DateTime.now().add(const Duration(hours: 1)),
    );
  }

  @override
  Future<AuthTokens> reauthenticate(Credentials credentials) async {
    if (!_isAuthenticated) {
      throw const AuthException('No authenticated user');
    }

    // Create a new session with refreshed tokens
    final newSession = AuthSession(
      accessToken:
          'reauth_access_token_${DateTime.now().millisecondsSinceEpoch}',
      idToken: 'reauth_id_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken:
          'reauth_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );

    _currentSession = newSession;

    // Return AuthTokens
    return AuthTokens(
      accessToken: newSession.accessToken,
      idToken: newSession.idToken,
      refreshToken: newSession.refreshToken,
      expiration: DateTime.now().add(const Duration(hours: 1)),
    );
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
    // Set up test environment
    await resetServiceLocator();
    SharedPreferences.setMockInitialValues({});

    // Create and configure mock services
    mockConnectivityService = MockConnectivityService();
    mockAuthRemoteDataSource = MockAuthRemoteDataSource();

    // Set up service locator in test mode
    await setupServiceLocator(isTest: true);

    // Create ProviderContainer with mock service overrides
    container = ProviderContainer(
      overrides: [
        connectivityServiceImplProvider
            .overrideWithValue(mockConnectivityService),
        authRemoteDataSourceProvider
            .overrideWithValue(mockAuthRemoteDataSource),
      ],
    );

    // Initialize security manager and local data source
    securityManager = getIt<SecurityManager>();
    final sharedPrefs = await SharedPreferences.getInstance();
    authLocalDataSource = AuthLocalDataSourceImpl(securityManager, sharedPrefs);

    // Clear existing storage and auth data
    await getIt<FlutterSecureStorage>().deleteAll();
    await authLocalDataSource.clearAuthData();

    // Set up initial authentication state
    final initialTokens = AuthSession(
      accessToken: 'test_access_token',
      idToken: 'test_id_token',
      refreshToken: 'test_refresh_token',
      expiresAt: DateTime.now().add(const Duration(minutes: 10)),
    );

    // Save auth data to local storage
    await authLocalDataSource.saveAuthData(
      initialTokens.accessToken,
      initialTokens.refreshToken,
      expiresAt: initialTokens.expiresAt,
      idToken: initialTokens.idToken,
    );

    // Configure mock remote data source
    mockAuthRemoteDataSource.setAuthenticated(true, session: initialTokens);

    // Initialize TokenManager
    tokenManager = container.read(tokenManagerProvider.notifier);
    await tokenManager.initialize();

    addTearDown(() async {
      // Clean up resources
      await tokenManager.clearSession();
      container.dispose();
      await getIt<FlutterSecureStorage>().deleteAll();
      await resetServiceLocator();
    });
  });

  Future<void> waitForState(FeatureAvailability expectedState) async {
    if (tokenManager.state == expectedState) {
      return;
    }

    final completer = Completer<void>();
    late ProviderSubscription<FeatureAvailability> subscription;

    subscription = container.listen(
      tokenManagerProvider,
      (previous, next) {
        if (next == expectedState && !completer.isCompleted) {
          completer.complete();
          subscription.close();
        }
      },
    );

    try {
      await completer.future.timeout(
        const Duration(seconds: 5),
        onTimeout: () {
          throw TimeoutException(
            'Failed to transition to $expectedState state. Current state: ${tokenManager.state}',
          );
        },
      );
    } finally {
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
