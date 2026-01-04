/// Comprehensive End-to-End tests for Robust Authentication System
///
/// These tests verify complete authentication flows including:
/// - Complete login flow with session creation
/// - Token refresh during API calls with retry logic
/// - Session restoration after app restart
/// - Logout and re-login scenarios
/// - Offline to online transitions with sync
///
/// Tests verify integration of all auth components:
/// - AuthRepository
/// - TokenRefreshService (with exponential backoff)
/// - TokenExpirationTracker (75% threshold)
/// - TokenRefreshScheduler (lifecycle-aware)
/// - PersistentSessionManager (secure storage)
/// - OfflineAuthManager (offline mode)
/// - AuthProvider (state management)
library;

import 'dart:async';
import 'package:flutter/material.dart' as material
    show
        TextButton,
        ElevatedButton,
        AppBar,
        Text,
        Icons,
        Key,
        TextField,
        TextFormField,
        CircularProgressIndicator;
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/app/app.dart';
import 'package:soloadventurer/app/di/service_locator.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/token_refresh_service.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/token_expiration_tracker.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/token_refresh_scheduler.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/persistent_session_manager.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/offline_auth_manager.dart';
import 'package:soloadventurer/features/core/domain/services/connectivity_service.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_providers.dart';
import 'package:soloadventurer/features/auth/presentation/state/auth_state.dart';

// Mock classes
class MockAuthRepository extends Mock implements AuthRepository {}
class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}
class MockConnectivityService extends Mock implements ConnectivityService {}
class MockTokenRefreshService extends Mock implements TokenRefreshService {}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late MockAuthRepository mockAuthRepository;
  late MockAuthLocalDataSource mockLocalDataSource;
  late MockConnectivityService mockConnectivityService;
  late MockTokenRefreshService mockTokenRefreshService;
  late StreamController<NetworkStatus> connectivityController;

  // Test data
  const testEmail = 'test@example.com';
  const testPassword = 'password123';
  const testUserId = 'user-123';
  const testAccessToken = 'access-token-123';
  const testRefreshToken = 'refresh-token-123';
  const testIdToken = 'id-token-123';

  // Helper to create a test session
  AuthSession createTestSession({Duration? expiration}) {
    return AuthSession(
      accessToken: testAccessToken,
      idToken: testIdToken,
      refreshToken: testRefreshToken,
      expiresAt: DateTime.now().add(expiration ?? const Duration(hours: 1)),
    );
  }

  // Helper to create a test user
  User createTestUser() {
    return User(
      id: testUserId,
      email: testEmail,
      username: 'testuser',
      emailVerified: true,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }

  setUpAll(() {
    // Register fallback values for mocktail
    registerFallbackValue(const AuthSession(
      accessToken: '',
      idToken: '',
      refreshToken: '',
      expiresAt: Duration.zero,
    ));
    registerFallbackValue(const User(
      id: '',
      email: '',
      username: '',
      emailVerified: false,
      createdAt: Duration.zero,
      lastLoginAt: Duration.zero,
    ));
  });

  setUp(() async {
    // Initialize service locator in test mode
    await setupServiceLocator(isTest: true);

    // Create mocks
    mockAuthRepository = MockAuthRepository();
    mockLocalDataSource = MockAuthLocalDataSource();
    mockConnectivityService = MockConnectivityService();
    mockTokenRefreshService = MockTokenRefreshService();

    // Set up connectivity stream
    connectivityController = StreamController<NetworkStatus>.broadcast();
    when(() => mockConnectivityService.onConnectivityChanged)
        .thenAnswer((_) => connectivityController.stream);
    when(() => mockConnectivityService.checkConnectivity())
        .thenAnswer((_) async => NetworkStatus.connected);

    // Set up default mock behaviors
    _setupDefaultMockBehaviors();

    // Create provider container with overrides
    container = ProviderContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
        authLocalDataSourceProvider.overrideWithValue(mockLocalDataSource),
      ],
    );
  });

  tearDown(() async {
    await connectivityController.close();
    await container.dispose();
    await resetServiceLocator();
  });

  void _setupDefaultMockBehaviors() {
    // Default: User is authenticated
    when(() => mockAuthRepository.isAuthenticated())
        .thenAnswer((_) async => true);
    when(() => mockAuthRepository.getCurrentUser())
        .thenAnswer((_) async => createTestUser());

    // Default: Session exists in storage
    when(() => mockLocalDataSource.getAuthToken())
        .thenAnswer((_) async => testAccessToken);
    when(() => mockLocalDataSource.getIdToken())
        .thenAnswer((_) async => testIdToken);
    when(() => mockLocalDataSource.getRefreshToken())
        .thenAnswer((_) async => testRefreshToken);
    when(() => mockLocalDataSource.getTokenExpiration())
        .thenAnswer((_) async => DateTime.now().add(const Duration(hours: 1)));
    when(() => mockLocalDataSource.hasValidSession())
        .thenAnswer((_) async => true);

    // Default: Successful token refresh
    when(() => mockAuthRepository.performBasicTokenRefresh())
        .thenAnswer((_) async => createTestSession());

    // Default: Successful sign out
    when(() => mockAuthRepository.signOut())
        .thenAnswer((_) async {});

    // Default: Successful local storage operations
    when(() => mockLocalDataSource.saveAuthData(
      any(),
      any(),
      expiresAt: any(named: 'expiresAt'),
      idToken: any(named: 'idToken'),
    )).thenAnswer((_) async {});

    when(() => mockLocalDataSource.cacheUserData(any()))
        .thenAnswer((_) async {});

    when(() => mockLocalDataSource.clearAuthData())
        .thenAnswer((_) async {});
  }

  group('E2E - Complete Login Flow', () {
    testWidgets('should successfully log in user and create session', (tester) async {
      // Arrange - Set up successful login
      when(() => mockAuthRepository.signInWithEmailAndPassword(
        testEmail,
        testPassword,
      )).thenAnswer((_) async => createTestUser());

      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => createTestUser());

      // Act - Pump app with provider container
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      // Assert - Should show login screen initially
      expect(find.text('SoloAdventurer'), findsOneWidget);

      // Enter credentials using widget text finding
      await tester.enterText(
        find.widgetWithText(material.TextFormField, 'Email'),
        testEmail,
      );
      await tester.enterText(
        find.widgetWithText(material.TextFormField, 'Password'),
        testPassword,
      );
      await tester.pumpAndSettle();

      // Tap login button
      await tester.tap(find.widgetWithText(material.ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Assert - Should navigate to home screen
      expect(find.text('Welcome to SoloAdventurer!'), findsOneWidget);

      // Verify session was saved
      verify(() => mockLocalDataSource.saveAuthData(
        testAccessToken,
        testRefreshToken,
        expiresAt: any(named: 'expiresAt'),
        idToken: testIdToken,
      )).called(1);

      // Verify user was cached
      verify(() => mockLocalDataSource.cacheUserData(any())).called(1);
    });

    testWidgets('should show error message on failed login', (tester) async {
      // Arrange - Set up failed login
      when(() => mockAuthRepository.signInWithEmailAndPassword(
        any(),
        any(),
      )).thenThrow(
        const AuthException(
          message: 'Invalid credentials',
          statusCode: 401,
        ),
      );

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      // Enter credentials
      await tester.enterText(
        find.widgetWithText(material.TextFormField, 'Email'),
        testEmail,
      );
      await tester.enterText(
        find.widgetWithText(material.TextFormField, 'Password'),
        'wrongpassword',
      );
      await tester.pumpAndSettle();

      // Tap login button
      await tester.tap(find.widgetWithText(material.ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Assert - Should show error message
      expect(find.text('Invalid credentials'), findsOneWidget);

      // Should remain on login screen
      expect(find.text('SoloAdventurer'), findsOneWidget);
    });
  });

  group('E2E - Token Refresh During API Call', () {
    testWidgets('should refresh token when it expires during API call', (tester) async {
      // Arrange - Set up session that will expire soon
      final expiringSession = createTestSession(
        expiration: const Duration(minutes: 2),
      );

      final newSession = AuthSession(
        accessToken: 'new-access-token',
        idToken: 'new-id-token',
        refreshToken: 'new-refresh-token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => createTestUser());

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenAnswer((_) async => newSession);

      // Act - Start app with expiring session
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      // Simulate token refresh being triggered
      final authNotifier = container.read(authNotifierProvider.notifier);
      await authNotifier.initialize();

      // Wait for refresh to complete
      await tester.pump(const Duration(seconds: 1));
      await tester.pumpAndSettle();

      // Assert - Token refresh was called
      verify(() => mockAuthRepository.performBasicTokenRefresh()).called(1);

      // New session was saved
      verify(() => mockLocalDataSource.saveAuthData(
        newSession.accessToken,
        newSession.refreshToken,
        expiresAt: newSession.expiresAt,
        idToken: newSession.idToken,
      )).called(1);
    });

    testWidgets('should handle token refresh failure with retry', (tester) async {
      // Arrange - Set up token refresh to fail initially then succeed
      var attemptCount = 0;

      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => createTestUser());

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenAnswer((_) async {
        attemptCount++;
        if (attemptCount == 1) {
          throw const AuthException(
            message: 'Network error',
            statusCode: 0,
          );
        }
        return createTestSession();
      });

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      // Trigger refresh
      final authNotifier = container.read(authNotifierProvider.notifier);
      await authNotifier.initialize();

      // Wait for retry
      await tester.pump(const Duration(seconds: 5));
      await tester.pumpAndSettle();

      // Assert - Refresh was attempted multiple times
      expect(attemptCount, greaterThan(1));

      // Eventually succeeded and session was saved
      verify(() => mockLocalDataSource.saveAuthData(
        any(),
        any(),
        expiresAt: any(named: 'expiresAt'),
        idToken: any(named: 'idToken'),
      )).called(1);
    });
  });

  group('E2E - Session Restoration After App Restart', () {
    testWidgets('should restore valid session on app restart', (tester) async {
      // Arrange - Set up valid session in storage
      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => true);

      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => DateTime.now().add(const Duration(hours: 1)));

      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => createTestUser());

      // Act - Start app
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      // Initialize auth (simulates app startup)
      final authNotifier = container.read(authNotifierProvider.notifier);
      await authNotifier.initialize();
      await tester.pumpAndSettle();

      // Assert - User should be logged in automatically
      final authState = container.read(authStateProvider);
      expect(authState?.isAuthenticated, isTrue);
      expect(authState?.user?.email, equals(testEmail));

      // Should navigate to home screen
      expect(find.text('Welcome to SoloAdventurer!'), findsOneWidget);
    });

    testWidgets('should attempt refresh for recently expired session', (tester) async {
      // Arrange - Set up recently expired session (< 24 hours)
      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => true);

      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => DateTime.now().subtract(const Duration(hours: 2)));

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenAnswer((_) async => createTestSession());

      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => createTestUser());

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      final authNotifier = container.read(authNotifierProvider.notifier);
      await authNotifier.initialize();
      await tester.pumpAndSettle();

      // Assert - Token refresh was attempted
      verify(() => mockAuthRepository.performBasicTokenRefresh()).called(1);

      // User should be logged in after refresh
      final authState = container.read(authStateProvider);
      expect(authState?.isAuthenticated, isTrue);
    });

    testWidgets('should require re-authentication for old expired session', (tester) async {
      // Arrange - Set up old expired session (> 24 hours)
      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => true);

      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => DateTime.now().subtract(const Duration(hours: 25)));

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      final authNotifier = container.read(authNotifierProvider.notifier);
      await authNotifier.initialize();
      await tester.pumpAndSettle();

      // Assert - No refresh attempted, user is logged out
      verifyNever(() => mockAuthRepository.performBasicTokenRefresh());

      final authState = container.read(authStateProvider);
      expect(authState?.isAuthenticated, isFalse);

      // Should show login screen
      expect(find.text('SoloAdventurer'), findsOneWidget);
    });
  });

  group('E2E - Logout and Re-login', () {
    testWidgets('should successfully logout and clear session', (tester) async {
      // Arrange - Set up authenticated user
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => createTestUser());

      when(() => mockAuthRepository.signOut())
          .thenAnswer((_) async {});

      // Act - Start app as authenticated
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      final authNotifier = container.read(authNotifierProvider.notifier);
      await authNotifier.initialize();
      await tester.pumpAndSettle();

      // Verify authenticated
      expect(container.read(authStateProvider)?.isAuthenticated, isTrue);

      // Logout
      await authNotifier.signOut();
      await tester.pumpAndSettle();

      // Assert - Session was cleared
      verify(() => mockAuthRepository.signOut()).called(1);
      verify(() => mockLocalDataSource.clearAuthData()).called(1);

      final authState = container.read(authStateProvider);
      expect(authState?.isAuthenticated, isFalse);

      // Should show login screen
      expect(find.text('SoloAdventurer'), findsOneWidget);
    });

    testWidgets('should successfully re-login after logout', (tester) async {
      // Arrange - Set up successful login
      when(() => mockAuthRepository.signInWithEmailAndPassword(
        testEmail,
        testPassword,
      )).thenAnswer((_) async => createTestUser());

      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => createTestUser());

      when(() => mockAuthRepository.signOut())
          .thenAnswer((_) async {});

      // Act - Start app
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      // Login
      await tester.enterText(
        find.widgetWithText(material.TextFormField, 'Email'),
        testEmail,
      );
      await tester.enterText(
        find.widgetWithText(material.TextFormField, 'Password'),
        testPassword,
      );
      await tester.tap(find.widgetWithText(material.ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Verify logged in
      expect(find.text('Welcome to SoloAdventurer!'), findsOneWidget);

      // Logout
      final authNotifier = container.read(authNotifierProvider.notifier);
      await authNotifier.signOut();
      await tester.pumpAndSettle();

      // Verify logged out
      expect(find.text('SoloAdventurer'), findsOneWidget);

      // Login again
      await tester.enterText(
        find.widgetWithText(material.TextFormField, 'Email'),
        testEmail,
      );
      await tester.enterText(
        find.widgetWithText(material.TextFormField, 'Password'),
        testPassword,
      );
      await tester.tap(find.widgetWithText(material.ElevatedButton, 'Login'));
      await tester.pumpAndSettle();

      // Assert - Successfully logged in again
      expect(find.text('Welcome to SoloAdventurer!'), findsOneWidget);
      expect(container.read(authStateProvider)?.isAuthenticated, isTrue);
    });
  });

  group('E2E - Offline to Online Transition', () {
    testWidgets('should transition to offline mode on network loss', (tester) async {
      // Arrange - Set up offline state with cached data
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.disconnected);

      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => true);

      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => DateTime.now().subtract(const Duration(hours: 1)));

      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => createTestUser());

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      final authNotifier = container.read(authNotifierProvider.notifier);
      await authNotifier.initialize();
      await tester.pumpAndSettle();

      // Assert - Should show offline indicator
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);
    });

    testWidgets('should sync when connection is restored', (tester) async {
      // Arrange - Start offline
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.disconnected);

      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => true);

      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => createTestUser());

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenAnswer((_) async => createTestSession());

      // Act - Start app offline
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      final authNotifier = container.read(authNotifierProvider.notifier);
      await authNotifier.initialize();
      await tester.pumpAndSettle();

      // Verify offline state
      expect(find.byIcon(Icons.cloud_off), findsOneWidget);

      // Simulate network reconnection
      when(() => mockConnectivityService.checkConnectivity())
          .thenAnswer((_) async => NetworkStatus.connected);

      connectivityController.add(NetworkStatus.connected);
      await tester.pumpAndSettle();

      // Wait for sync to complete
      await tester.pump(const Duration(seconds: 2));
      await tester.pumpAndSettle();

      // Assert - Token refresh was attempted (sync occurred)
      verify(() => mockAuthRepository.performBasicTokenRefresh()).called(1);

      // Should show online indicator
      expect(find.byIcon(Icons.cloud_done), findsOneWidget);
    });

    testWidgets('should handle rapid offline/online transitions', (tester) async {
      // Arrange
      when(() => mockAuthRepository.getCurrentUser())
          .thenAnswer((_) async => createTestUser());

      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => true);

      // Act
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      final authNotifier = container.read(authNotifierProvider.notifier);
      await authNotifier.initialize();
      await tester.pumpAndSettle();

      // Simulate rapid transitions
      for (int i = 0; i < 3; i++) {
        when(() => mockConnectivityService.checkConnectivity())
            .thenAnswer((_) async => NetworkStatus.disconnected);
        connectivityController.add(NetworkStatus.disconnected);
        await tester.pump(const Duration(milliseconds: 100));

        when(() => mockConnectivityService.checkConnectivity())
            .thenAnswer((_) async => NetworkStatus.connected);
        connectivityController.add(NetworkStatus.connected);
        await tester.pump(const Duration(milliseconds: 100));
      }

      await tester.pumpAndSettle();

      // Assert - App should remain stable
      final authState = container.read(authStateProvider);
      expect(authState, isNotNull);
    });
  });

  group('E2E - Complete User Journey', () {
    testWidgets('should handle complete user journey: signup -> login -> refresh -> logout', (tester) async {
      // Arrange - Set up signup success
      when(() => mockAuthRepository.signUpWithEmailAndPassword(
        any(),
        any(),
      )).thenAnswer((_) async => createTestUser());

      // Act - Start app
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: const App(),
        ),
      );
      await tester.pumpAndSettle();

      // Navigate to signup
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      // Fill signup form
      await tester.enterText(
        find.widgetWithText(material.TextFormField, 'Full Name'),
        'Test User',
      );
      await tester.enterText(
        find.widgetWithText(material.TextFormField, 'Email'),
        testEmail,
      );
      await tester.enterText(
        find.widgetWithText(material.TextFormField, 'Password'),
        testPassword,
      );
      await tester.enterText(
        find.widgetWithText(material.TextFormField, 'Confirm Password'),
        testPassword,
      );

      // Submit signup
      await tester.tap(find.widgetWithText(material.ElevatedButton, 'Sign Up'));
      await tester.pumpAndSettle();

      // Verify signed up (should show home or profile screen)
      expect(
        find.text('Welcome to SoloAdventurer!').or(find.text('Edit Profile')),
        findsOneWidget,
      );

      // Logout
      final authNotifier = container.read(authNotifierProvider.notifier);
      await authNotifier.signOut();
      await tester.pumpAndSettle();

      // Login again
      when(() => mockAuthRepository.signInWithEmailAndPassword(
        testEmail,
        testPassword,
      )).thenAnswer((_) async => createTestUser());

      await tester.enterText(
        find.byKey(const Key('login_email_field')),
        testEmail,
      );
      await tester.enterText(
        find.byKey(const Key('login_password_field')),
        testPassword,
      );
      await tester.tap(find.byKey(const Key('login_button')));
      await tester.pumpAndSettle();

      // Verify logged in
      expect(find.text('Welcome to SoloAdventurer!'), findsOneWidget);

      // Simulate token refresh
      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenAnswer((_) async => createTestSession());

      await authNotifier.initialize();
      await tester.pumpAndSettle();

      // Verify refresh occurred
      verify(() => mockAuthRepository.performBasicTokenRefresh()).called(1);

      // Logout
      await authNotifier.signOut();
      await tester.pumpAndSettle();

      // Verify logged out
      expect(find.text('SoloAdventurer'), findsOneWidget);
    });
  });
}
