import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/persistent_session_manager.dart';

class MockAuthLocalDataSource extends Mock implements AuthLocalDataSource {}

void main() {
  late MockAuthLocalDataSource mockLocalDataSource;
  late PersistentSessionManager sessionManager;

  setUp(() {
    mockLocalDataSource = MockAuthLocalDataSource();
    sessionManager = PersistentSessionManager(
      localDataSource: mockLocalDataSource,
    );
  });

  group('PersistentSessionManager - saveSession', () {
    final testSession = AuthSession(
      accessToken: 'test_access_token',
      idToken: 'test_id_token',
      refreshToken: 'test_refresh_token',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );

    test('should save session with all tokens and expiration', () async {
      // Arrange
      when(() => mockLocalDataSource.saveAuthData(
        any(),
        any(),
        expiresAt: any(named: 'expiresAt'),
        idToken: any(named: 'idToken'),
      )).thenAnswer((_) async {});

      when(() => mockLocalDataSource.cacheUserData(any()))
          .thenAnswer((_) async {});

      // Act
      await sessionManager.saveSession(testSession);

      // Assert
      verify(() => mockLocalDataSource.saveAuthData(
        testSession.accessToken,
        testSession.refreshToken,
        expiresAt: testSession.expiresAt,
        idToken: testSession.idToken,
      )).called(1);

      verify(() => mockLocalDataSource.cacheUserData(
        argThat(isA<Map<String, dynamic>>()),
      )).called(1);
    });

    test('should throw AuthException when save fails', () async {
      // Arrange
      when(() => mockLocalDataSource.saveAuthData(
        any(),
        any(),
        expiresAt: any(named: 'expiresAt'),
        idToken: any(named: 'idToken'),
      )).thenThrow(Exception('Storage error'));

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

    test('should include session version in cached data', () async {
      // Arrange
      when(() => mockLocalDataSource.saveAuthData(
        any(),
        any(),
        expiresAt: any(named: 'expiresAt'),
        idToken: any(named: 'idToken'),
      )).thenAnswer((_) async {});

      when(() => mockLocalDataSource.cacheUserData(any()))
          .thenAnswer((_) async {});

      // Act
      await sessionManager.saveSession(testSession);

      // Assert
      verify(() => mockLocalDataSource.cacheUserData(
        argThat(
          allOf([
            containsPair('version', '1.0'),
            containsPair('saved_at', isA<String>()),
          ]),
        ),
      )).called(1);
    });
  });

  group('PersistentSessionManager - loadSession', () {
    final testSession = AuthSession(
      accessToken: 'test_access_token',
      idToken: 'test_id_token',
      refreshToken: 'test_refresh_token',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );

    test('should load session when all tokens are present', () async {
      // Arrange
      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => testSession.accessToken);
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => testSession.idToken);
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => testSession.refreshToken);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => testSession.expiresAt);

      // Act
      final loadedSession = await sessionManager.loadSession();

      // Assert
      expect(loadedSession, isNotNull);
      expect(loadedSession!.accessToken, equals(testSession.accessToken));
      expect(loadedSession.idToken, equals(testSession.idToken));
      expect(loadedSession.refreshToken, equals(testSession.refreshToken));
      expect(loadedSession.expiresAt, equals(testSession.expiresAt));
    });

    test('should return null when access token is missing', () async {
      // Arrange
      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => null);
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => testSession.idToken);
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => testSession.refreshToken);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => testSession.expiresAt);

      // Act
      final loadedSession = await sessionManager.loadSession();

      // Assert
      expect(loadedSession, isNull);
    });

    test('should return null when refresh token is missing', () async {
      // Arrange
      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => testSession.accessToken);
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => testSession.idToken);
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => null);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => testSession.expiresAt);

      // Act
      final loadedSession = await sessionManager.loadSession();

      // Assert
      expect(loadedSession, isNull);
    });

    test('should return null when expiration is missing', () async {
      // Arrange
      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => testSession.accessToken);
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => testSession.idToken);
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => testSession.refreshToken);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => null);

      // Act
      final loadedSession = await sessionManager.loadSession();

      // Assert
      expect(loadedSession, isNull);
    });

    test('should handle missing ID token gracefully', () async {
      // Arrange
      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => testSession.accessToken);
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => null);
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => testSession.refreshToken);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => testSession.expiresAt);

      // Act
      final loadedSession = await sessionManager.loadSession();

      // Assert
      expect(loadedSession, isNotNull);
      expect(loadedSession!.idToken, isEmpty);
    });

    test('should throw AuthException when loading fails', () async {
      // Arrange
      when(() => mockLocalDataSource.getAuthToken())
          .thenThrow(Exception('Storage error'));

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

  group('PersistentSessionManager - validateSession', () {
    final validSession = AuthSession(
      accessToken: 'test_access_token',
      idToken: 'test_id_token',
      refreshToken: 'test_refresh_token',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );

    final expiredSession = AuthSession(
      accessToken: 'test_access_token',
      idToken: 'test_id_token',
      refreshToken: 'test_refresh_token',
      expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
    );

    test('should return valid result for valid session', () async {
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

    test('should return invalid result for expired session', () async {
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
    });

    test('should return invalid result when no session exists', () async {
      // Arrange
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

    test('should return failure result on error', () async {
      // Arrange
      when(() => mockLocalDataSource.getAuthToken())
          .thenThrow(Exception('Validation error'));

      // Act
      final result = await sessionManager.validateSession();

      // Assert
      expect(result.status, equals(SessionOperationStatus.failed));
      expect(result.isValid, isFalse);
      expect(result.error, isNotNull);
      expect(result.error!.code, equals('SESSION_VALIDATION_FAILED'));
    });
  });

  group('PersistentSessionManager - clearSession', () {
    test('should clear session data', () async {
      // Arrange
      when(() => mockLocalDataSource.clearAuthData())
          .thenAnswer((_) async {});

      // Act
      await sessionManager.clearSession();

      // Assert
      verify(() => mockLocalDataSource.clearAuthData()).called(1);
    });

    test('should throw AuthException when clear fails', () async {
      // Arrange
      when(() => mockLocalDataSource.clearAuthData())
          .thenThrow(Exception('Clear error'));

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
  });

  group('PersistentSessionManager - hasValidSession', () {
    test('should return true when session is valid', () async {
      // Arrange
      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => true);

      // Act
      final hasSession = await sessionManager.hasValidSession();

      // Assert
      expect(hasSession, isTrue);
    });

    test('should return false when session is invalid', () async {
      // Arrange
      when(() => mockLocalDataSource.hasValidSession())
          .thenAnswer((_) async => false);

      // Act
      final hasSession = await sessionManager.hasValidSession();

      // Assert
      expect(hasSession, isFalse);
    });

    test('should return false on error', () async {
      // Arrange
      when(() => mockLocalDataSource.hasValidSession())
          .thenThrow(Exception('Error'));

      // Act
      final hasSession = await sessionManager.hasValidSession();

      // Assert
      expect(hasSession, isFalse);
    });
  });

  group('PersistentSessionManager - getTokenExpiration', () {
    final testExpiration = DateTime.now().add(const Duration(hours: 1));

    test('should return token expiration', () async {
      // Arrange
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => testExpiration);

      // Act
      final expiration = await sessionManager.getTokenExpiration();

      // Assert
      expect(expiration, equals(testExpiration));
    });

    test('should return null when no expiration is stored', () async {
      // Arrange
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => null);

      // Act
      final expiration = await sessionManager.getTokenExpiration();

      // Assert
      expect(expiration, isNull);
    });

    test('should return null on error', () async {
      // Arrange
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenThrow(Exception('Error'));

      // Act
      final expiration = await sessionManager.getTokenExpiration();

      // Assert
      expect(expiration, isNull);
    });
  });

  group('PersistentSessionManager - isTokenExpired', () {
    test('should return true when token is expired', () async {
      // Arrange
      when(() => mockLocalDataSource.isTokenExpired())
          .thenAnswer((_) async => true);

      // Act
      final isExpired = await sessionManager.isTokenExpired();

      // Assert
      expect(isExpired, isTrue);
    });

    test('should return false when token is valid', () async {
      // Arrange
      when(() => mockLocalDataSource.isTokenExpired())
          .thenAnswer((_) async => false);

      // Act
      final isExpired = await sessionManager.isTokenExpired();

      // Assert
      expect(isExpired, isFalse);
    });

    test('should return true on error', () async {
      // Arrange
      when(() => mockLocalDataSource.isTokenExpired())
          .thenThrow(Exception('Error'));

      // Act
      final isExpired = await sessionManager.isTokenExpired();

      // Assert
      expect(isExpired, isTrue); // Assume expired on error
    });
  });

  group('PersistentSessionManager - getAccessToken', () {
    test('should return access token', () async {
      // Arrange
      const testToken = 'test_access_token';
      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => testToken);

      // Act
      final token = await sessionManager.getAccessToken();

      // Assert
      expect(token, equals(testToken));
    });

    test('should return null when no token is stored', () async {
      // Arrange
      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => null);

      // Act
      final token = await sessionManager.getAccessToken();

      // Assert
      expect(token, isNull);
    });

    test('should return null on error', () async {
      // Arrange
      when(() => mockLocalDataSource.getAuthToken())
          .thenThrow(Exception('Error'));

      // Act
      final token = await sessionManager.getAccessToken();

      // Assert
      expect(token, isNull);
    });
  });

  group('PersistentSessionManager - getIdToken', () {
    test('should return ID token', () async {
      // Arrange
      const testToken = 'test_id_token';
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => testToken);

      // Act
      final token = await sessionManager.getIdToken();

      // Assert
      expect(token, equals(testToken));
    });

    test('should return null when no token is stored', () async {
      // Arrange
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => null);

      // Act
      final token = await sessionManager.getIdToken();

      // Assert
      expect(token, isNull);
    });

    test('should return null on error', () async {
      // Arrange
      when(() => mockLocalDataSource.getIdToken())
          .thenThrow(Exception('Error'));

      // Act
      final token = await sessionManager.getIdToken();

      // Assert
      expect(token, isNull);
    });
  });

  group('PersistentSessionManager - getRefreshToken', () {
    test('should return refresh token', () async {
      // Arrange
      const testToken = 'test_refresh_token';
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => testToken);

      // Act
      final token = await sessionManager.getRefreshToken();

      // Assert
      expect(token, equals(testToken));
    });

    test('should return null when no token is stored', () async {
      // Arrange
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => null);

      // Act
      final token = await sessionManager.getRefreshToken();

      // Assert
      expect(token, isNull);
    });

    test('should return null on error', () async {
      // Arrange
      when(() => mockLocalDataSource.getRefreshToken())
          .thenThrow(Exception('Error'));

      // Act
      final token = await sessionManager.getRefreshToken();

      // Assert
      expect(token, isNull);
    });
  });

  group('PersistentSessionManager - token masking', () {
    test('should mask long tokens correctly', () {
      // Arrange
      const longToken = 'abcdefghijklmnopqrstuvwxyz123456';

      // Act
      final masked = sessionManager._maskToken(longToken);

      // Assert
      expect(masked, startsWith('abcdefgh'));
      expect(masked, endsWith('3456'));
      expect(masked, contains('...'));
      expect(masked, contains('32 chars'));
    });

    test('should mask short tokens', () {
      // Arrange
      const shortToken = 'short';

      // Act
      final masked = sessionManager._maskToken(shortToken);

      // Assert
      expect(masked, equals('****'));
    });
  });

  group('PersistentSessionManager - validateSessionForRestoration', () {
    final validSession = AuthSession(
      accessToken: 'test_access_token',
      idToken: 'test_id_token',
      refreshToken: 'test_refresh_token',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );

    final recentlyExpiredSession = AuthSession(
      accessToken: 'test_access_token',
      idToken: 'test_id_token',
      refreshToken: 'test_refresh_token',
      expiresAt: DateTime.now().subtract(const Duration(hours: 12)),
    );

    final longExpiredSession = AuthSession(
      accessToken: 'test_access_token',
      idToken: 'test_id_token',
      refreshToken: 'test_refresh_token',
      expiresAt: DateTime.now().subtract(const Duration(hours: 30)),
    );

    test('should return valid result for non-expired session', () async {
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
      final result = await sessionManager.validateSessionForRestoration();

      // Assert
      expect(result.action, equals(SessionValidationAction.valid));
      expect(result.session, isNotNull);
      expect(result.session!.accessToken, equals(validSession.accessToken));
      expect(result.timeSinceExpiration, isNull);
    });

    test('should return canRefresh for session expired less than 24 hours ago', () async {
      // Arrange
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

      // Assert
      expect(result.action, equals(SessionValidationAction.canRefresh));
      expect(result.session, isNotNull);
      expect(result.timeSinceExpiration, isNotNull);
      expect(result.timeSinceExpiration!.inHours, greaterThan(11));
      expect(result.timeSinceExpiration!.inHours, lessThan(13));
    });

    test('should return reauthenticate for session expired more than 24 hours ago', () async {
      // Arrange
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

      // Assert
      expect(result.action, equals(SessionValidationAction.reauthenticate));
      expect(result.session, isNotNull);
      expect(result.timeSinceExpiration, isNotNull);
      expect(result.timeSinceExpiration!.inHours, greaterThan(29));
    });

    test('should return invalid for missing session', () async {
      // Arrange
      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => null);
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => null);
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => null);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => null);

      // Act
      final result = await sessionManager.validateSessionForRestoration();

      // Assert
      expect(result.action, equals(SessionValidationAction.invalid));
      expect(result.session, isNull);
      expect(result.error, isNotNull);
      expect(result.error!.code, equals('NO_SESSION'));
    });

    test('should return invalid when session loading fails', () async {
      // Arrange
      when(() => mockLocalDataSource.getAuthToken())
          .thenThrow(Exception('Storage error'));

      // Act
      final result = await sessionManager.validateSessionForRestoration();

      // Assert
      expect(result.action, equals(SessionValidationAction.invalid));
      expect(result.session, isNull);
      expect(result.error, isNotNull);
      expect(result.error!.code, equals('SESSION_VALIDATION_FAILED'));
    });

    test('should handle exactly 24 hour expiration boundary', () async {
      // Arrange - session expired exactly 24 hours ago
      final boundarySession = AuthSession(
        accessToken: 'test_access_token',
        idToken: 'test_id_token',
        refreshToken: 'test_refresh_token',
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

      // Assert
      // Exactly 24 hours should still be canRefresh (<= threshold)
      expect(result.action, equals(SessionValidationAction.canRefresh));
      expect(result.timeSinceExpiration, isNotNull);
    });

    test('should handle session expired just over 24 hours', () async {
      // Arrange - session expired 24 hours and 1 second ago
      final overBoundarySession = AuthSession(
        accessToken: 'test_access_token',
        idToken: 'test_id_token',
        refreshToken: 'test_refresh_token',
        expiresAt: DateTime.now().subtract(const Duration(hours: 24, seconds: 1)),
      );

      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => overBoundarySession.accessToken);
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => overBoundarySession.idToken);
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => overBoundarySession.refreshToken);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => overBoundarySession.expiresAt);

      // Act
      final result = await sessionManager.validateSessionForRestoration();

      // Assert
      // Just over 24 hours should be reauthenticate
      expect(result.action, equals(SessionValidationAction.reauthenticate));
      expect(result.timeSinceExpiration, isNotNull);
    });

    test('should handle corrupted session data (missing access token)', () async {
      // Arrange
      when(() => mockLocalDataSource.getAuthToken())
          .thenAnswer((_) async => null);
      when(() => mockLocalDataSource.getIdToken())
          .thenAnswer((_) async => validSession.idToken);
      when(() => mockLocalDataSource.getRefreshToken())
          .thenAnswer((_) async => validSession.refreshToken);
      when(() => mockLocalDataSource.getTokenExpiration())
          .thenAnswer((_) async => validSession.expiresAt);

      // Act
      final result = await sessionManager.validateSessionForRestoration();

      // Assert
      expect(result.action, equals(SessionValidationAction.invalid));
      expect(result.session, isNull);
      expect(result.error, isNotNull);
    });
  });
}
