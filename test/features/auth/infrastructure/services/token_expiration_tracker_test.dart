import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/token_refresh_service.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/token_expiration_tracker.dart';

class MockTokenRefreshService extends Mock implements TokenRefreshService {}

void main() {
  late MockTokenRefreshService mockRefreshService;
  late TokenExpirationTracker tracker;

  setUp(() {
    mockRefreshService = MockTokenRefreshService();
    tracker = TokenExpirationTracker(
      refreshService: mockRefreshService,
      refreshThreshold: 0.75,
    );

    // Register fallback values for mocks
    registerFallbackValue(const Duration(seconds: 1));
  });

  group('TokenExpirationTracker - Expiration Calculation', () {
    test('should correctly calculate time until expiration for valid token',
        () {
      // Arrange
      final expiresAt = DateTime.now().add(const Duration(hours: 1));
      final session = AuthSession(
        accessToken: 'access_token',
        idToken: 'id_token',
        refreshToken: 'refresh_token',
        expiresAt: expiresAt,
      );

      // Act
      final result = tracker.checkExpiration(session);

      // Assert
      expect(result.isExpired, isFalse);
      expect(result.shouldRefresh, isFalse);
      expect(result.timeUntilExpiration, isNotNull);
      expect(result.timeUntilExpiration!.inMinutes, isPositive);
      expect(result.expirationTime, equals(expiresAt));
    });

    test('should identify expired token', () {
      // Arrange
      final expiresAt = DateTime.now().subtract(const Duration(minutes: 5));
      final session = AuthSession(
        accessToken: 'access_token',
        idToken: 'id_token',
        refreshToken: 'refresh_token',
        expiresAt: expiresAt,
      );

      // Act
      final result = tracker.checkExpiration(session);

      // Assert
      expect(result.isExpired, isTrue);
      expect(result.shouldRefresh, isTrue);
      expect(result.timeUntilExpiration!.inSeconds, greaterThan(0));
      expect(result.timeUntilRefresh, equals(Duration.zero));
    });

    test('should trigger refresh when token is within refresh threshold', () {
      // Arrange
      // Token expires in 10 minutes, which is less than 75% of assumed 1 hour lifetime (45 min)
      final expiresAt = DateTime.now().add(const Duration(minutes: 10));
      final session = AuthSession(
        accessToken: 'access_token',
        idToken: 'id_token',
        refreshToken: 'refresh_token',
        expiresAt: expiresAt,
      );

      // Act
      final result = tracker.checkExpiration(session);

      // Assert
      expect(result.isExpired, isFalse);
      expect(result.shouldRefresh, isTrue);
      expect(result.timeUntilRefresh!.isNegative, isFalse); // Duration.zero when should refresh now
    });

    test('should not trigger refresh when token is well within threshold', () {
      // Arrange
      // Token expires in 50 minutes, which is more than 75% of assumed 1 hour lifetime (45 min)
      final expiresAt = DateTime.now().add(const Duration(minutes: 50));
      final session = AuthSession(
        accessToken: 'access_token',
        idToken: 'idToken',
        refreshToken: 'refresh_token',
        expiresAt: expiresAt,
      );

      // Act
      final result = tracker.checkExpiration(session);

      // Assert
      expect(result.isExpired, isFalse);
      expect(result.shouldRefresh, isFalse);
      expect(result.timeUntilRefresh, isNotNull);
      expect(result.timeUntilRefresh! > Duration.zero, isTrue);
    });

    test('should handle token with no expiration information', () {
      // Arrange
      final session = AuthSession(
        accessToken: 'access_token',
        idToken: 'id_token',
        refreshToken: 'refresh_token',
        expiresAt: DateTime(0), // DateTime(0) indicates no expiration
      );

      // Act
      final result = tracker.checkExpiration(session);

      // Assert
      expect(result.isExpired, isFalse);
      expect(result.shouldRefresh, isFalse);
      expect(result.timeUntilExpiration, isNull);
      expect(result.timeUntilRefresh, isNull);
      expect(result.expirationTime, isNull);
    });

    test('should calculate correct refresh time at 75% threshold', () {
      // Arrange
      final expiresAt = DateTime.now().add(const Duration(hours: 1));
      final session = AuthSession(
        accessToken: 'access_token',
        idToken: 'id_token',
        refreshToken: 'refresh_token',
        expiresAt: expiresAt,
      );

      // Act
      final result = tracker.checkExpiration(session);

      // Assert
      // 75% of 1 hour = 45 minutes, so refresh should be scheduled in 15 minutes
      final timeUntilRefresh = result.timeUntilRefresh;
      expect(timeUntilRefresh, isNotNull);
      expect(timeUntilRefresh!.inMinutes, isPositive);
      // Allow some tolerance for timing
      expect(timeUntilRefresh.inMinutes, greaterThan(10));
      expect(timeUntilRefresh.inMinutes, lessThan(20));
    });
  });

  group('TokenExpirationTracker - Helper Methods', () {
    test('should return time until expiration for valid token', () {
      // Arrange
      final expiresAt = DateTime.now().add(const Duration(minutes: 30));
      final session = AuthSession(
        accessToken: 'access_token',
        idToken: 'id_token',
        refreshToken: 'refresh_token',
        expiresAt: expiresAt,
      );

      // Act
      final timeUntil = tracker.getTimeUntilExpiration(session);

      // Assert
      expect(timeUntil, isNotNull);
      expect(timeUntil!.inMinutes, isPositive);
      expect(timeUntil.inMinutes, lessThan(35)); // Allow 5 min tolerance
      expect(timeUntil.inMinutes, greaterThan(25)); // Allow 5 min tolerance
    });

    test('should return null for time until expiration when no expiration', () {
      // Arrange
      final session = AuthSession(
        accessToken: 'access_token',
        idToken: 'id_token',
        refreshToken: 'refresh_token',
        expiresAt: DateTime(0),
      );

      // Act
      final timeUntil = tracker.getTimeUntilExpiration(session);

      // Assert
      expect(timeUntil, isNull);
    });

    test('should return negative duration for expired token', () {
      // Arrange
      final expiresAt = DateTime.now().subtract(const Duration(minutes: 10));
      final session = AuthSession(
        accessToken: 'access_token',
        idToken: 'id_token',
        refreshToken: 'refresh_token',
        expiresAt: expiresAt,
      );

      // Act
      final timeUntil = tracker.getTimeUntilExpiration(session);

      // Assert
      expect(timeUntil, isNotNull);
      expect(timeUntil!.inSeconds, isNegative);
    });

    test('should correctly identify expired token', () {
      // Arrange
      final expiresAt = DateTime.now().subtract(const Duration(minutes: 5));
      final session = AuthSession(
        accessToken: 'access_token',
        idToken: 'id_token',
        refreshToken: 'refresh_token',
        expiresAt: expiresAt,
      );

      // Act
      final isExpired = tracker.isTokenExpired(session);

      // Assert
      expect(isExpired, isTrue);
    });

    test('should correctly identify non-expired token', () {
      // Arrange
      final expiresAt = DateTime.now().add(const Duration(minutes: 30));
      final session = AuthSession(
        accessToken: 'access_token',
        idToken: 'id_token',
        refreshToken: 'refresh_token',
        expiresAt: expiresAt,
      );

      // Act
      final isExpired = tracker.isTokenExpired(session);

      // Assert
      expect(isExpired, isFalse);
    });

    test('should return false for expired check when no expiration', () {
      // Arrange
      final session = AuthSession(
        accessToken: 'access_token',
        idToken: 'id_token',
        refreshToken: 'refresh_token',
        expiresAt: DateTime(0),
      );

      // Act
      final isExpired = tracker.isTokenExpired(session);

      // Assert
      expect(isExpired, isFalse);
    });

    test('should correctly determine when to refresh token', () {
      // Arrange
      final expiresAt = DateTime.now().add(const Duration(minutes: 10));
      final session = AuthSession(
        accessToken: 'access_token',
        idToken: 'id_token',
        refreshToken: 'refresh_token',
        expiresAt: expiresAt,
      );

      // Act
      final shouldRefresh = tracker.shouldRefreshToken(session);

      // Assert
      expect(shouldRefresh, isTrue);
    });

    test('should correctly determine when not to refresh token', () {
      // Arrange
      final expiresAt = DateTime.now().add(const Duration(minutes: 50));
      final session = AuthSession(
        accessToken: 'access_token',
        idToken: 'id_token',
        refreshToken: 'refresh_token',
        expiresAt: expiresAt,
      );

      // Act
      final shouldRefresh = tracker.shouldRefreshToken(session);

      // Assert
      expect(shouldRefresh, isFalse);
    });
  });

  group('TokenExpirationTracker - Tracking and Scheduling', () {
    test('should start tracking a session', () {
      // Arrange
      final expiresAt = DateTime.now().add(const Duration(minutes: 50));
      final session = AuthSession(
        accessToken: 'access_token',
        idToken: 'id_token',
        refreshToken: 'refresh_token',
        expiresAt: expiresAt,
      );

      // Act
      tracker.startTracking(session);

      // Assert
      expect(tracker.isMonitoring, isTrue);
    });

    test('should stop tracking and cancel timers', () {
      // Arrange
      final expiresAt = DateTime.now().add(const Duration(minutes: 50));
      final session = AuthSession(
        accessToken: 'access_token',
        idToken: 'id_token',
        refreshToken: 'refresh_token',
        expiresAt: expiresAt,
      );
      tracker.startTracking(session);

      // Act
      tracker.stopTracking();

      // Assert
      expect(tracker.isMonitoring, isFalse);
    });

    test('should update tracked session and reschedule', () {
      // Arrange
      final expiresAt1 = DateTime.now().add(const Duration(minutes: 50));
      final session1 = AuthSession(
        accessToken: 'access_token1',
        idToken: 'id_token1',
        refreshToken: 'refresh_token1',
        expiresAt: expiresAt1,
      );

      final expiresAt2 = DateTime.now().add(const Duration(minutes: 55));
      final session2 = AuthSession(
        accessToken: 'access_token2',
        idToken: 'id_token2',
        refreshToken: 'refresh_token2',
        expiresAt: expiresAt2,
      );

      tracker.startTracking(session1);

      // Act
      tracker.updateSession(session2);

      // Assert
      expect(tracker.isMonitoring, isTrue);
    });

    test('should dispose and clean up resources', () {
      // Arrange
      final expiresAt = DateTime.now().add(const Duration(minutes: 50));
      final session = AuthSession(
        accessToken: 'access_token',
        idToken: 'id_token',
        refreshToken: 'refresh_token',
        expiresAt: expiresAt,
      );
      tracker.startTracking(session);

      // Act
      tracker.dispose();

      // Assert
      expect(tracker.isMonitoring, isFalse);
    });
  });

  group('TokenExpirationTracker - Refresh Integration', () {
    test('should trigger immediate refresh for expired token', () async {
      // Arrange
      final expiresAt = DateTime.now().subtract(const Duration(minutes: 5));
      final session = AuthSession(
        accessToken: 'access_token',
        idToken: 'id_token',
        refreshToken: 'refresh_token',
        expiresAt: expiresAt,
      );

      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockRefreshService.refreshToken())
          .thenAnswer((_) async => newSession);

      // Act
      tracker.startTracking(session);

      // Wait a bit for async operations
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      verify(() => mockRefreshService.refreshToken()).called(1);
    });

    test('should handle refresh service errors and schedule retry', () async {
      // Arrange
      final expiresAt = DateTime.now().subtract(const Duration(minutes: 5));
      final session = AuthSession(
        accessToken: 'access_token',
        idToken: 'id_token',
        refreshToken: 'refresh_token',
        expiresAt: expiresAt,
      );

      when(() => mockRefreshService.refreshToken()).thenThrow(
          const AuthException('Refresh failed', code: 'REFRESH_ERROR'));

      // Act
      tracker.startTracking(session);

      // Wait for initial refresh attempt and retry scheduling
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      verify(() => mockRefreshService.refreshToken()).called(1);
    });

    test('should update session after successful refresh', () async {
      // Arrange
      final expiresAt = DateTime.now().subtract(const Duration(minutes: 5));
      final session = AuthSession(
        accessToken: 'access_token',
        idToken: 'id_token',
        refreshToken: 'refresh_token',
        expiresAt: expiresAt,
      );

      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockRefreshService.refreshToken())
          .thenAnswer((_) async => newSession);

      // Act
      tracker.startTracking(session);

      // Wait for refresh to complete
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert - tracker should still be monitoring with new session
      expect(tracker.isMonitoring, isTrue);
    });
  });

  group('TokenExpirationTracker - Edge Cases', () {
    test('should handle multiple startTracking calls', () {
      // Arrange
      final session1 = AuthSession(
        accessToken: 'access_token1',
        idToken: 'id_token1',
        refreshToken: 'refresh_token1',
        expiresAt: DateTime.now().add(const Duration(minutes: 50)),
      );

      final session2 = AuthSession(
        accessToken: 'access_token2',
        idToken: 'id_token2',
        refreshToken: 'refresh_token2',
        expiresAt: DateTime.now().add(const Duration(minutes: 55)),
      );

      // Act
      tracker.startTracking(session1);
      tracker.startTracking(session2);

      // Assert
      expect(tracker.isMonitoring, isTrue);
    });

    test('should handle stopTracking when not tracking', () {
      // Act
      tracker.stopTracking();

      // Assert - should not throw
      expect(tracker.isMonitoring, isFalse);
    });

    test('should handle updateSession when not tracking', () {
      // Arrange
      final session = AuthSession(
        accessToken: 'access_token',
        idToken: 'id_token',
        refreshToken: 'refresh_token',
        expiresAt: DateTime.now().add(const Duration(minutes: 50)),
      );

      // Act - should not throw
      tracker.updateSession(session);

      // Assert
      expect(tracker.isMonitoring, isFalse);
    });

    test('should reset tracker state', () {
      // Arrange
      final session = AuthSession(
        accessToken: 'access_token',
        idToken: 'id_token',
        refreshToken: 'refresh_token',
        expiresAt: DateTime.now().add(const Duration(minutes: 50)),
      );
      tracker.startTracking(session);

      // Act
      tracker.reset();

      // Assert
      expect(tracker.isMonitoring, isFalse);
    });

    test('should enforce refreshThreshold validation', () {
      // Act & Assert - should throw for threshold <= 0
      expect(
        () => TokenExpirationTracker(
          refreshService: mockRefreshService,
          refreshThreshold: 0.0,
        ),
        throwsA(isA<AssertionError>()),
      );

      // Act & Assert - should throw for threshold >= 1
      expect(
        () => TokenExpirationTracker(
          refreshService: mockRefreshService,
          refreshThreshold: 1.0,
        ),
        throwsA(isA<AssertionError>()),
      );
    });

    test('should allow valid refreshThreshold values', () {
      // Act & Assert - should not throw for valid values
      expect(
        () => TokenExpirationTracker(
          refreshService: mockRefreshService,
          refreshThreshold: 0.5,
        ),
        returnsNormally,
      );

      expect(
        () => TokenExpirationTracker(
          refreshService: mockRefreshService,
          refreshThreshold: 0.99,
        ),
        returnsNormally,
      );
    });
  });

  group('TokenExpirationResult - Factory Methods', () {
    test('should create expired result correctly', () {
      // Arrange
      final expirationTime =
          DateTime.now().subtract(const Duration(minutes: 5));

      // Act
      final result = TokenExpirationResult.expired(
        expirationTime: expirationTime,
      );

      // Assert
      expect(result.isExpired, isTrue);
      expect(result.shouldRefresh, isTrue);
      expect(result.expirationTime, equals(expirationTime));
      expect(result.timeUntilRefresh, equals(Duration.zero));
    });

    test('should create shouldRefreshNow result correctly', () {
      // Arrange
      final expirationTime = DateTime.now().add(const Duration(minutes: 10));
      const timeUntilExpiration = Duration(minutes: 10);
      const timeUntilRefresh = Duration.zero;

      // Act
      final result = TokenExpirationResult.shouldRefreshNow(
        expirationTime: expirationTime,
        timeUntilExpiration: timeUntilExpiration,
        timeUntilRefresh: timeUntilRefresh,
      );

      // Assert
      expect(result.isExpired, isFalse);
      expect(result.shouldRefresh, isTrue);
      expect(result.expirationTime, equals(expirationTime));
      expect(result.timeUntilExpiration, equals(timeUntilExpiration));
      expect(result.timeUntilRefresh, equals(timeUntilRefresh));
    });

    test('should create valid result correctly', () {
      // Arrange
      final expirationTime = DateTime.now().add(const Duration(minutes: 50));
      const timeUntilExpiration = Duration(minutes: 50);
      const timeUntilRefresh = Duration(minutes: 5);

      // Act
      final result = TokenExpirationResult.valid(
        expirationTime: expirationTime,
        timeUntilExpiration: timeUntilExpiration,
        timeUntilRefresh: timeUntilRefresh,
      );

      // Assert
      expect(result.isExpired, isFalse);
      expect(result.shouldRefresh, isFalse);
      expect(result.expirationTime, equals(expirationTime));
      expect(result.timeUntilExpiration, equals(timeUntilExpiration));
      expect(result.timeUntilRefresh, equals(timeUntilRefresh));
    });

    test('should create noExpiration result correctly', () {
      // Act
      final result = TokenExpirationResult.noExpiration();

      // Assert
      expect(result.isExpired, isFalse);
      expect(result.shouldRefresh, isFalse);
      expect(result.timeUntilExpiration, isNull);
      expect(result.timeUntilRefresh, isNull);
      expect(result.expirationTime, isNull);
    });
  });
}
