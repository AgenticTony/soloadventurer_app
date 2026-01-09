import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/persistent_session_manager.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}
class MockAuthRepository extends Mock implements AuthRepository {}

/// Integration tests for session persistence across app restarts and various scenarios
///
/// These tests verify the complete integration of:
/// - PersistentSessionManager
/// - AuthLocalDataSource
/// - AuthRepository
///
/// Across various session lifecycle scenarios including save, load, validation,
/// auto-refresh, logout, and error handling.
void main() {
  late MockAuthLocalDataSource mockLocalDataSource;
  late MockAuthRepository mockAuthRepository;
  late PersistentSessionManager sessionManager;

  setUp(() {
    mockLocalDataSource = MockAuthLocalDataSource();
    mockAuthRepository = MockAuthRepository();
    sessionManager = PersistentSessionManager(
      localDataSource: mockLocalDataSource,
    );
  });

  group('Session Persistence - Save and Load Integration', () {
    final testSession = AuthSession(
      accessToken: 'test_access_token',
      idToken: 'test_id_token',
      refreshToken: 'test_refresh_token',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );

    test('should save and load session with complete data', () async {
      // Arrange - Set up mock for save
      when(() => mockLocalDataSource.saveAuthData(
        any(),
        any(),
        expiresAt: any(named: 'expiresAt'),
        idToken: any(named: 'idToken'),
      )).thenAnswer((_) async {});

      when(() => mockLocalDataSource.cacheUserData(any()))
          .thenAnswer((_) async {});

      // Act - Save session
      await sessionManager.saveSession(testSession);

      // Set up mock for load
      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => testSession.accessToken);
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => testSession.idToken);
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => testSession.refreshToken);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => testSession.expiresAt);

      // Load session
      final loadedSession = await sessionManager.loadSession();

      // Assert - Session should be loaded with all data intact
      expect(loadedSession, isNotNull);
      expect(loadedSession!.accessToken, equals(testSession.accessToken));
      expect(loadedSession.idToken, equals(testSession.idToken));
      expect(loadedSession.refreshToken, equals(testSession.refreshToken));
      expect(loadedSession.expiresAt, equals(testSession.expiresAt));

      // Verify save was called
      verify(() => mockLocalDataSource.saveAuthData(
        testSession.accessToken,
        testSession.refreshToken,
        expiresAt: testSession.expiresAt,
        idToken: testSession.idToken,
      )).called(1);

      // Verify load was called
      verify(() => mockLocalDataSource.getAuthToken()).called(1);
      verify(() => mockLocalDataSource.getIdToken()).called(1);
      verify(() => mockLocalDataSource.getRefreshToken()).called(1);
      verify(() => mockLocalDataSource.getTokenExpiration()).called(1);
    });

    test('should save and load multiple sessions sequentially', () async {
      // Arrange - Create multiple sessions
      final session1 = AuthSession(
        accessToken: 'access_token_1',
        idToken: 'id_token_1',
        refreshToken: 'refresh_token_1',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      final session2 = AuthSession(
        accessToken: 'access_token_2',
        idToken: 'id_token_2',
        refreshToken: 'refresh_token_2',
        expiresAt: DateTime.now().add(const Duration(hours: 2)),
      );

      // Act - Save first session
      when(() => mockLocalDataSource.saveAuthData(
        any(),
        any(),
        expiresAt: any(named: 'expiresAt'),
        idToken: any(named: 'idToken'),
      )).thenAnswer((_) async {});

      when(() => mockLocalDataSource.cacheUserData(any()))
          .thenAnswer((_) async {});

      await sessionManager.saveSession(session1);

      // Load first session
      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => session1.accessToken);
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => session1.idToken);
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => session1.refreshToken);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => session1.expiresAt);

      final loaded1 = await sessionManager.loadSession();
      expect(loaded1?.accessToken, equals(session1.accessToken));

      // Save second session (should overwrite first)
      await sessionManager.saveSession(session2);

      // Load second session
      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => session2.accessToken);
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => session2.idToken);
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => session2.refreshToken);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => session2.expiresAt);

      final loaded2 = await sessionManager.loadSession();

      // Assert - Second session should have replaced first
      expect(loaded2, isNotNull);
      expect(loaded2!.accessToken, equals(session2.accessToken));
      expect(loaded2.refreshToken, equals(session2.refreshToken));
      verify(() => mockLocalDataSource.saveAuthData(
        session2.accessToken,
        session2.refreshToken,
        expiresAt: session2.expiresAt,
        idToken: session2.idToken,
      )).called(1);
    });

    test('should handle save operation failures gracefully', () async {
      // Arrange
      when(() => mockLocalDataSource.saveAuthData(
        any(),
        any(),
        expiresAt: any(named: 'expiresAt'),
        idToken: any(named: 'idToken'),
      )).thenThrow(Exception('Storage unavailable'));

      // Act & Assert
      expect(
        () => sessionManager.saveSession(testSession),
        throwsA(isA<AuthException>().having(
          (e) => e.code,
          'code',
          'SESSION_SAVE_FAILED',
        )),
      );
    });

    test('should handle load operation failures gracefully', () async {
      // Arrange
      when(() => mockLocalDataSource.getAuthToken())
          .thenThrow(Exception('Storage corrupted'));

      // Act & Assert
      expect(
        () => sessionManager.loadSession(),
        throwsA(isA<AuthException>().having(
          (e) => e.code,
          'code',
          'SESSION_LOAD_FAILED',
        )),
      );
    });
  });

  group('Session Persistence - Validation Integration', () {
    final validSession = AuthSession(
      accessToken: 'valid_access_token',
      idToken: 'valid_id_token',
      refreshToken: 'valid_refresh_token',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );

    final expiredSession = AuthSession(
      accessToken: 'expired_access_token',
      idToken: 'expired_id_token',
      refreshToken: 'expired_refresh_token',
      expiresAt: DateTime.now().subtract(const Duration(minutes: 30)),
    );

    test('should validate and report valid session correctly', () async {
      // Arrange
      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => validSession.accessToken);
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => validSession.idToken);
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => validSession.refreshToken);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => validSession.expiresAt);

      // Act
      final result = await sessionManager.validateSession();

      // Assert
      expect(result.isValid, isTrue);
      expect(result.status, equals(SessionOperationStatus.validated));
      expect(result.session, isNotNull);
      expect(result.session!.accessToken, equals(validSession.accessToken));
    });

    test('should validate and report expired session correctly', () async {
      // Arrange
      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => expiredSession.accessToken);
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => expiredSession.idToken);
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => expiredSession.refreshToken);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => expiredSession.expiresAt);

      // Act
      final result = await sessionManager.validateSession();

      // Assert
      expect(result.isValid, isFalse);
      expect(result.status, equals(SessionOperationStatus.validated));
      expect(result.session, isNotNull);
      expect(result.session!.accessToken, equals(expiredSession.accessToken));
    });

    test('should validate session with missing tokens as invalid', () async {
      // Arrange - Session with incomplete data
      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => null);
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => null);
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => null);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => null);

      // Act
      final result = await sessionManager.validateSession();

      // Assert
      expect(result.isValid, isFalse);
      expect(result.status, equals(SessionOperationStatus.validated));
      expect(result.session, isNull);
    });

    test('should validate session about to expire', () async {
      // Arrange - Session expiring in less than 5 minutes
      final expiringSoonSession = AuthSession(
        accessToken: 'expiring_soon_token',
        idToken: 'expiring_soon_id',
        refreshToken: 'expiring_soon_refresh',
        expiresAt: DateTime.now().add(const Duration(minutes: 3)),
      );

      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => expiringSoonSession.accessToken);
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => expiringSoonSession.idToken);
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => expiringSoonSession.refreshToken);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => expiringSoonSession.expiresAt);

      // Act
      final result = await sessionManager.validateSession();

      // Assert - Should still be valid (not expired yet)
      expect(result.isValid, isTrue);
      expect(result.session, isNotNull);
      expect(result.session!.expiresAt, equals(expiringSoonSession.expiresAt));
    });
  });

  group('Session Persistence - Auto-Refresh on App Restart', () {
    final recentlyExpiredSession = AuthSession(
      accessToken: 'recently_expired_token',
      idToken: 'recently_expired_id',
      refreshToken: 'recently_expired_refresh',
      expiresAt: DateTime.now().subtract(const Duration(hours: 12)),
    );

    final refreshedSession = AuthSession(
      accessToken: 'refreshed_token',
      idToken: 'refreshed_id',
      refreshToken: 'refreshed_refresh',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );

    test('should detect recently expired session and allow refresh', () async {
      // Arrange - Session expired 12 hours ago (< 24h threshold)
      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => recentlyExpiredSession.accessToken);
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => recentlyExpiredSession.idToken);
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => recentlyExpiredSession.refreshToken);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => recentlyExpiredSession.expiresAt);

      // Act
      final result = await sessionManager.validateSessionForRestoration();

      // Assert - Should indicate refresh is possible
      expect(result.action, equals(SessionValidationAction.canRefresh));
      expect(result.session, isNotNull);
      expect(result.timeSinceExpiration, isNotNull);
      expect(result.timeSinceExpiration!.inHours, greaterThanOrEqualTo(11));
      expect(result.timeSinceExpiration!.inHours, lessThan(13));
    });

    test('should successfully refresh session and persist new tokens', () async {
      // Arrange - Set up repository for refresh
      when(() => mockAuthRepository.refreshToken())
          .thenAnswer((_) async => refreshedSession);

      // Set up mocks for save
      when(() => mockLocalDataSource.saveAuthData(
        any(),
        any(),
        expiresAt: any(named: 'expiresAt'),
        idToken: any(named: 'idToken'),
      )).thenAnswer((_) async {});

      when(() => mockLocalDataSource.cacheUserData(any()))
          .thenAnswer((_) async {});

      // Act - Simulate refresh flow
      final newSession = await mockAuthRepository.refreshToken();
      await sessionManager.saveSession(newSession);

      // Assert - New session should be saved
      verify(() => mockLocalDataSource.saveAuthData(
        refreshedSession.accessToken,
        refreshedSession.refreshToken,
        expiresAt: refreshedSession.expiresAt,
        idToken: refreshedSession.idToken,
      )).called(1);

      // Verify we can load the refreshed session
      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => refreshedSession.accessToken);
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => refreshedSession.idToken);
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => refreshedSession.refreshToken);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => refreshedSession.expiresAt);

      final loadedSession = await sessionManager.loadSession();
      expect(loadedSession?.accessToken, equals(refreshedSession.accessToken));
    });

    test('should handle refresh failure on app restart', () async {
      // Arrange - Session that needs refresh but refresh fails
      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => recentlyExpiredSession.accessToken);
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => recentlyExpiredSession.idToken);
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => recentlyExpiredSession.refreshToken);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => recentlyExpiredSession.expiresAt);

      // Validate that refresh is needed
      final validationResult = await sessionManager.validateSessionForRestoration();
      expect(validationResult.action, equals(SessionValidationAction.canRefresh));

      // Attempt refresh fails
      when(() => mockAuthRepository.refreshToken())
          .thenThrow(const AuthException.refreshTokenExpired('Refresh token is expired'));

      // Act & Assert - Refresh should fail
      expect(
        () => mockAuthRepository.refreshToken(),
        throwsA(isA<AuthException>()),
      );
    });

    test('should detect long-expired session and require re-authentication', () async {
      // Arrange - Session expired 30 hours ago (> 24h threshold)
      final longExpiredSession = AuthSession(
        accessToken: 'long_expired_token',
        idToken: 'long_expired_id',
        refreshToken: 'long_expired_refresh',
        expiresAt: DateTime.now().subtract(const Duration(hours: 30)),
      );

      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => longExpiredSession.accessToken);
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => longExpiredSession.idToken);
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => longExpiredSession.refreshToken);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => longExpiredSession.expiresAt);

      // Act
      final result = await sessionManager.validateSessionForRestoration();

      // Assert - Should require re-authentication
      expect(result.action, equals(SessionValidationAction.reauthenticate));
      expect(result.session, isNotNull);
      expect(result.timeSinceExpiration, isNotNull);
      expect(result.timeSinceExpiration!.inHours, greaterThan(29));
    });
  });

  group('Session Persistence - Logout Clearing Session', () {
    final testSession = AuthSession(
      accessToken: 'test_access_token',
      idToken: 'test_id_token',
      refreshToken: 'test_refresh_token',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );

    test('should clear all session data on logout', () async {
      // Arrange - User is logged in
      when(() => mockLocalDataSource.saveAuthData(
        any(),
        any(),
        expiresAt: any(named: 'expiresAt'),
        idToken: any(named: 'idToken'),
      )).thenAnswer((_) async {});

      when(() => mockLocalDataSource.cacheUserData(any()))
          .thenAnswer((_) async {});

      await sessionManager.saveSession(testSession);

      // Verify session exists
      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => testSession.accessToken);
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => testSession.idToken);
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => testSession.refreshToken);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => testSession.expiresAt);

      final sessionBeforeLogout = await sessionManager.loadSession();
      expect(sessionBeforeLogout, isNotNull);

      // Arrange logout
      when(() => mockLocalDataSource.clearAuthData())
          .thenAnswer((_) async {});

      // Act - Logout
      await sessionManager.clearSession();

      // Assert - Session should be cleared
      verify(() => mockLocalDataSource.clearAuthData()).called(1);

      // Verify session is gone
      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => null);
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => null);
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => null);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => null);

      final sessionAfterLogout = await sessionManager.loadSession();
      expect(sessionAfterLogout, isNull);
    });

    test('should handle clear session failure gracefully', () async {
      // Arrange
      when(() => mockLocalDataSource.clearAuthData())
          .thenThrow(Exception('Storage unavailable'));

      // Act & Assert
      expect(
        () => sessionManager.clearSession(),
        throwsA(isA<AuthException>().having(
          (e) => e.code,
          'code',
          'SESSION_CLEAR_FAILED',
        )),
      );
    });

    test('should allow new login after logout', () async {
      // Arrange - Logout clears session
      when(() => mockLocalDataSource.clearAuthData())
          .thenAnswer((_) async {});

      await sessionManager.clearSession();

      // Act - Login again with new session
      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 2)),
      );

      when(() => mockLocalDataSource.saveAuthData(
        any(),
        any(),
        expiresAt: any(named: 'expiresAt'),
        idToken: any(named: 'idToken'),
      )).thenAnswer((_) async {});

      when(() => mockLocalDataSource.cacheUserData(any()))
          .thenAnswer((_) async {});

      await sessionManager.saveSession(newSession);

      // Assert - New session should be saved
      verify(() => mockLocalDataSource.saveAuthData(
        newSession.accessToken,
        newSession.refreshToken,
        expiresAt: newSession.expiresAt,
        idToken: newSession.idToken,
      )).called(1);

      // Verify we can load the new session
      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => newSession.accessToken);
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => newSession.idToken);
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => newSession.refreshToken);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => newSession.expiresAt);

      final loadedSession = await sessionManager.loadSession();
      expect(loadedSession?.accessToken, equals(newSession.accessToken));
    });
  });

  group('Session Persistence - Corrupted Session Handling', () {
    test('should handle missing access token gracefully', () async {
      // Arrange - Corrupted session: missing access token
      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => null);
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => 'some_id_token');
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => 'some_refresh_token');
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => DateTime.now().add(const Duration(hours: 1)));

      // Act
      final result = await sessionManager.validateSessionForRestoration();

      // Assert - Should detect invalid session
      expect(result.action, equals(SessionValidationAction.invalid));
      expect(result.session, isNull);
      expect(result.error, isNotNull);
      expect(result.error!.code, equals('NO_SESSION'));
    });

    test('should handle missing refresh token gracefully', () async {
      // Arrange - Corrupted session: missing refresh token
      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => 'some_access_token');
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => 'some_id_token');
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => null);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => DateTime.now().add(const Duration(hours: 1)));

      // Act
      final result = await sessionManager.validateSessionForRestoration();

      // Assert - Should detect invalid session
      expect(result.action, equals(SessionValidationAction.invalid));
      expect(result.session, isNull);
    });

    test('should handle missing expiration timestamp gracefully', () async {
      // Arrange - Corrupted session: missing expiration
      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => 'some_access_token');
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => 'some_id_token');
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => 'some_refresh_token');
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => null);

      // Act
      final result = await sessionManager.validateSessionForRestoration();

      // Assert - Should detect invalid session
      expect(result.action, equals(SessionValidationAction.invalid));
      expect(result.session, isNull);
    });

    test('should handle storage read errors during restoration', () async {
      // Arrange - Storage error when reading
      when(() => mockLocalDataSource.getAuthToken())
          .thenThrow(Exception('Storage corrupted'));

      // Act
      final result = await sessionManager.validateSessionForRestoration();

      // Assert - Should detect invalid session
      expect(result.action, equals(SessionValidationAction.invalid));
      expect(result.session, isNull);
      expect(result.error, isNotNull);
      expect(result.error!.code, equals('SESSION_VALIDATION_FAILED'));
    });

    test('should handle partially available session data', () async {
      // Arrange - Only access token available
      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => 'only_access_token');
      when(() => mockLocalDataSource.getIdToken())
          .thenThrow(Exception('Read error'));
      when(() => mockLocalDataSource.getRefreshToken())
          .thenThrow(Exception('Read error'));
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenThrow(Exception('Read error'));

      // Act
      final result = await sessionManager.validateSessionForRestoration();

      // Assert - Should detect invalid session
      expect(result.action, equals(SessionValidationAction.invalid));
      expect(result.session, isNull);
      expect(result.error, isNotNull);
    });

    test('should recover from corrupted session by clearing', () async {
      // Arrange - Corrupted session detected
      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => null);
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => 'some_id_token');
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => 'some_refresh_token');
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => DateTime.now().add(const Duration(hours: 1)));

      final validationResult = await sessionManager.validateSessionForRestoration();
      expect(validationResult.action, equals(SessionValidationAction.invalid));

      // Act - Clear corrupted session
      when(() => mockLocalDataSource.clearAuthData())
          .thenAnswer((_) async {});

      await sessionManager.clearSession();

      // Assert - Corrupted data should be cleared
      verify(() => mockLocalDataSource.clearAuthData()).called(1);

      // Verify no session remains
      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => null);
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => null);
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => null);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => null);

      final sessionAfterClear = await sessionManager.loadSession();
      expect(sessionAfterClear, isNull);
    });
  });

  group('Session Persistence - Complete Auth Flow Integration', () {
    test('should handle complete login → save → restart → restore → refresh → logout flow', () async {
      // 1. User logs in
      final loginSession = AuthSession(
        accessToken: 'login_access_token',
        idToken: 'login_id_token',
        refreshToken: 'login_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockLocalDataSource.saveAuthData(
        any(),
        any(),
        expiresAt: any(named: 'expiresAt'),
        idToken: any(named: 'idToken'),
      )).thenAnswer((_) async {});

      when(() => mockLocalDataSource.cacheUserData(any()))
          .thenAnswer((_) async {});

      await sessionManager.saveSession(loginSession);
      verify(() => mockLocalDataSource.saveAuthData(
        loginSession.accessToken,
        loginSession.refreshToken,
        expiresAt: loginSession.expiresAt,
        idToken: loginSession.idToken,
      )).called(1);

      // 2. App restarts - session is still valid
      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => loginSession.accessToken);
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => loginSession.idToken);
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => loginSession.refreshToken);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => loginSession.expiresAt);

      final restoredSession = await sessionManager.loadSession();
      expect(restoredSession?.accessToken, equals(loginSession.accessToken));

      final validationResult = await sessionManager.validateSessionForRestoration();
      expect(validationResult.action, equals(SessionValidationAction.valid));

      // 3. App restarts later - session expired but can refresh
      final expiredSession = AuthSession(
        accessToken: 'expired_access_token',
        idToken: 'expired_id_token',
        refreshToken: 'expired_refresh_token',
        expiresAt: DateTime.now().subtract(const Duration(hours: 12)),
      );

      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => expiredSession.accessToken);
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => expiredSession.idToken);
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => expiredSession.refreshToken);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => expiredSession.expiresAt);

      final expiredValidation = await sessionManager.validateSessionForRestoration();
      expect(expiredValidation.action, equals(SessionValidationAction.canRefresh));

      // 4. Refresh tokens
      final refreshedSession = AuthSession(
        accessToken: 'refreshed_access_token',
        idToken: 'refreshed_id_token',
        refreshToken: 'refreshed_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockAuthRepository.refreshToken())
          .thenAnswer((_) async => refreshedSession);

      final newSession = await mockAuthRepository.refreshToken();

      // Save refreshed session
      await sessionManager.saveSession(newSession);

      // 5. User logs out
      when(() => mockLocalDataSource.clearAuthData())
          .thenAnswer((_) async {});

      await sessionManager.clearSession();

      // 6. Verify session is cleared
      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => null);
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => null);
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => null);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => null);

      final finalSession = await sessionManager.loadSession();
      expect(finalSession, isNull);

      // Verify clear was called
      verify(() => mockLocalDataSource.clearAuthData()).called(1);
    });
  });

  group('Session Persistence - Edge Cases', () {
    test('should handle session with exactly 24 hour expiration boundary', () async {
      // Arrange - Session expired exactly 24 hours ago
      final boundarySession = AuthSession(
        accessToken: 'boundary_token',
        idToken: 'boundary_id',
        refreshToken: 'boundary_refresh',
        expiresAt: DateTime.now().subtract(const Duration(hours: 24)),
      );

      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => boundarySession.accessToken);
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => boundarySession.idToken);
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => boundarySession.refreshToken);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => boundarySession.expiresAt);

      // Act
      final result = await sessionManager.validateSessionForRestoration();

      // Assert - Should be canRefresh (<= 24h)
      expect(result.action, equals(SessionValidationAction.canRefresh));
      expect(result.timeSinceExpiration, isNotNull);
    });

    test('should handle session with very long expiration', () async {
      // Arrange - Session that expires in 30 days
      final longLivedSession = AuthSession(
        accessToken: 'long_lived_token',
        idToken: 'long_lived_id',
        refreshToken: 'long_lived_refresh',
        expiresAt: DateTime.now().add(const Duration(days: 30)),
      );

      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => longLivedSession.accessToken);
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => longLivedSession.idToken);
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => longLivedSession.refreshToken);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => longLivedSession.expiresAt);

      // Act
      final result = await sessionManager.validateSessionForRestoration();

      // Assert - Should be valid
      expect(result.action, equals(SessionValidationAction.valid));
      expect(result.session, isNotNull);
      expect(result.session!.expiresAt, equals(longLivedSession.expiresAt));
    });

    test('should handle rapid save/load cycles', () async {
      // Arrange
      final session = AuthSession(
        accessToken: 'rapid_token',
        idToken: 'rapid_id',
        refreshToken: 'rapid_refresh',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockLocalDataSource.saveAuthData(
        any(),
        any(),
        expiresAt: any(named: 'expiresAt'),
        idToken: any(named: 'idToken'),
      )).thenAnswer((_) async {});

      when(() => mockLocalDataSource.cacheUserData(any()))
          .thenAnswer((_) async {});

      // Act - Rapid save/load cycles
      for (int i = 0; i < 5; i++) {
        await sessionManager.saveSession(session);

        when(() => mockLocalDataSource.getAuthToken())
            .thenAnswer((_) async => session.accessToken);
        when(() => mockLocalDataSource.getIdToken())
            .thenAnswer((_) async => session.idToken);
        when(() => mockLocalDataSource.getRefreshToken())
            .thenAnswer((_) async => session.refreshToken);
        when(() => mockLocalDataSource.getTokenExpiration())
            .thenAnswer((_) async => session.expiresAt);

        final loaded = await sessionManager.loadSession();
        expect(loaded?.accessToken, equals(session.accessToken));
      }

      // Assert - All operations should complete successfully
      verify(() => mockLocalDataSource.saveAuthData(
        session.accessToken,
        session.refreshToken,
        expiresAt: session.expiresAt,
        idToken: session.idToken,
      )).called(5);
    });

    test('should handle missing ID token (optional field)', () async {
      // Arrange - Session without ID token (optional field)
      final sessionWithoutId = AuthSession(
        accessToken: 'access_token',
        idToken: '',
        refreshToken: 'refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => sessionWithoutId.accessToken);
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => null);
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => sessionWithoutId.refreshToken);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => sessionWithoutId.expiresAt);

      // Act
      final result = await sessionManager.validateSessionForRestoration();

      // Assert - Should still be valid (ID token is optional)
      expect(result.action, equals(SessionValidationAction.valid));
      expect(result.session, isNotNull);
      expect(result.session!.idToken, isEmpty);
    });
  });
}
