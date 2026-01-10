import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/token_expiration_tracker.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/token_refresh_scheduler.dart';

class MockTokenExpirationTracker extends Mock
    implements TokenExpirationTracker {}

void main() {
  late MockTokenExpirationTracker mockTracker;
  late TokenRefreshScheduler scheduler;

  setUp(() {
    mockTracker = MockTokenExpirationTracker();
    scheduler = TokenRefreshScheduler(
      expirationTracker: mockTracker,
    );

    // Register fallback values
    registerFallbackValue(
      TokenExpirationResult.valid(
        expirationTime: DateTime.now().add(const Duration(hours: 1)),
        timeUntilExpiration: const Duration(hours: 1),
        timeUntilRefresh: const Duration(minutes: 45),
      ),
    );
  });

  tearDown(() {
    scheduler.dispose();
  });

  group('TokenRefreshScheduler - Lifecycle', () {
    test('should start with stopped status', () {
      expect(scheduler.status, TokenRefreshSchedulerStatus.stopped);
      expect(scheduler.isRunning, isFalse);
      expect(scheduler.isPaused, isFalse);
    });

    test('should start monitoring session', () {
      // Arrange
      final session = _createTestSession(expiresIn: const Duration(hours: 1));

      // Act
      scheduler.start(session);

      // Assert
      verify(() => mockTracker.startTracking(session)).called(1);
      expect(scheduler.status, TokenRefreshSchedulerStatus.running);
      expect(scheduler.isRunning, isTrue);
    });

    test('should stop monitoring session', () {
      // Arrange
      final session = _createTestSession(expiresIn: const Duration(hours: 1));
      scheduler.start(session);

      // Act
      scheduler.stop();

      // Assert
      verify(() => mockTracker.stopTracking()).called(1);
      expect(scheduler.status, TokenRefreshSchedulerStatus.stopped);
      expect(scheduler.isRunning, isFalse);
    });

    test('should pause and resume monitoring', () {
      // Arrange
      final session = _createTestSession(expiresIn: const Duration(hours: 1));
      scheduler.start(session);

      // Act - Pause
      scheduler.pause();

      // Assert - Paused
      verify(() => mockTracker.stopTracking()).called(1);
      expect(scheduler.status, TokenRefreshSchedulerStatus.paused);
      expect(scheduler.isPaused, isTrue);

      // Act - Resume
      scheduler.resume();

      // Assert - Resumed
      verify(() => mockTracker.startTracking(session))
          .called(2); // Once in start(), once in resume()
      expect(scheduler.status, TokenRefreshSchedulerStatus.running);
      expect(scheduler.isRunning, isTrue);
    });

    test('should not pause when not running', () {
      // Arrange
      final session = _createTestSession(expiresIn: const Duration(hours: 1));
      scheduler.start(session);
      scheduler.stop();

      // Act
      scheduler.pause();

      // Assert
      verify(() => mockTracker.stopTracking())
          .called(1); // Only from stop(), not from pause()
      expect(scheduler.status, TokenRefreshSchedulerStatus.stopped);
    });

    test('should not resume when not paused', () {
      // Arrange
      final session = _createTestSession(expiresIn: const Duration(hours: 1));

      // Act - try to resume without starting
      scheduler.resume();

      // Assert
      verifyNever(() => mockTracker.startTracking(any()));
      expect(scheduler.status, TokenRefreshSchedulerStatus.stopped);
    });

    test('should not resume when paused but no session', () {
      // Arrange
      final session = _createTestSession(expiresIn: const Duration(hours: 1));
      scheduler.start(session);
      scheduler.pause();

      // Clear the session manually (simulating edge case)
      scheduler.stop();

      // Act
      scheduler.resume();

      // Assert
      verifyNever(() => mockTracker.startTracking(any()));
    });
  });

  group('TokenRefreshScheduler - App Lifecycle', () {
    test('should pause when app goes to background', () {
      // Arrange
      final session = _createTestSession(expiresIn: const Duration(hours: 1));
      scheduler.start(session);

      // Act
      scheduler.didChangeAppLifecycleState(AppLifecycleState.paused);

      // Assert
      verify(() => mockTracker.stopTracking()).called(1);
      expect(scheduler.status, TokenRefreshSchedulerStatus.paused);
    });

    test('should pause when app becomes inactive', () {
      // Arrange
      final session = _createTestSession(expiresIn: const Duration(hours: 1));
      scheduler.start(session);

      // Act
      scheduler.didChangeAppLifecycleState(AppLifecycleState.inactive);

      // Assert
      verify(() => mockTracker.stopTracking()).called(1);
      expect(scheduler.status, TokenRefreshSchedulerStatus.paused);
    });

    test('should pause when app becomes hidden', () {
      // Arrange
      final session = _createTestSession(expiresIn: const Duration(hours: 1));
      scheduler.start(session);

      // Act
      scheduler.didChangeAppLifecycleState(AppLifecycleState.hidden);

      // Assert
      verify(() => mockTracker.stopTracking()).called(1);
      expect(scheduler.status, TokenRefreshSchedulerStatus.paused);
    });

    test('should resume when app returns to foreground', () {
      // Arrange
      final session = _createTestSession(expiresIn: const Duration(hours: 1));
      final expirationResult = TokenExpirationResult.valid(
        expirationTime: DateTime.now().add(const Duration(hours: 1)),
        timeUntilExpiration: const Duration(hours: 1),
        timeUntilRefresh: const Duration(minutes: 45),
      );

      scheduler.start(session);
      when(() => mockTracker.checkExpiration(any()))
          .thenReturn(expirationResult);

      // Act
      scheduler.didChangeAppLifecycleState(AppLifecycleState.resumed);

      // Assert
      verify(() => mockTracker.checkExpiration(session)).called(1);
      verify(() => mockTracker.startTracking(session))
          .called(2); // start() + resume()
      expect(scheduler.status, TokenRefreshSchedulerStatus.running);
    });

    test('should stop when app is detached', () {
      // Arrange
      final session = _createTestSession(expiresIn: const Duration(hours: 1));
      scheduler.start(session);

      // Act
      scheduler.didChangeAppLifecycleState(AppLifecycleState.detached);

      // Assert
      verify(() => mockTracker.stopTracking()).called(1);
      expect(scheduler.status, TokenRefreshSchedulerStatus.stopped);
    });

    test('should handle app resume when token is expired', () {
      // Arrange
      final session =
          _createTestSession(expiresIn: const Duration(hours: -1)); // Expired
      final expirationResult = TokenExpirationResult.expired(
        expirationTime: DateTime.now().subtract(const Duration(hours: 1)),
      );

      scheduler.start(session);
      when(() => mockTracker.checkExpiration(any()))
          .thenReturn(expirationResult);

      // Act
      scheduler.didChangeAppLifecycleState(AppLifecycleState.resumed);

      // Assert
      verify(() => mockTracker.checkExpiration(session)).called(1);
      verify(() => mockTracker.startTracking(session))
          .called(2); // Should still resume
      expect(scheduler.status, TokenRefreshSchedulerStatus.running);
    });

    test('should handle app resume when token should refresh', () {
      // Arrange
      final session =
          _createTestSession(expiresIn: const Duration(minutes: 10));
      final expirationResult = TokenExpirationResult.shouldRefreshNow(
        expirationTime: DateTime.now().add(const Duration(minutes: 10)),
        timeUntilExpiration: const Duration(minutes: 10),
        timeUntilRefresh: Duration.zero,
      );

      scheduler.start(session);
      when(() => mockTracker.checkExpiration(any()))
          .thenReturn(expirationResult);

      // Act
      scheduler.didChangeAppLifecycleState(AppLifecycleState.resumed);

      // Assert
      verify(() => mockTracker.checkExpiration(session)).called(1);
      expect(scheduler.status, TokenRefreshSchedulerStatus.running);
    });

    test('should handle app resume with no session', () {
      // Arrange - scheduler stopped with no session
      when(() => mockTracker.checkExpiration(any())).thenReturn(null);

      // Act
      scheduler.didChangeAppLifecycleState(AppLifecycleState.resumed);

      // Assert
      verifyNever(() => mockTracker.checkExpiration(any()));
      expect(scheduler.status, TokenRefreshSchedulerStatus.stopped);
    });
  });

  group('TokenRefreshScheduler - Session Management', () {
    test('should update session while running', () {
      // Arrange
      final oldSession =
          _createTestSession(expiresIn: const Duration(hours: 1));
      final newSession =
          _createTestSession(expiresIn: const Duration(hours: 2));

      scheduler.start(oldSession);

      // Act
      scheduler.updateSession(newSession);

      // Assert
      verify(() => mockTracker.updateSession(newSession)).called(1);
    });

    test('should update session while paused', () {
      // Arrange
      final oldSession =
          _createTestSession(expiresIn: const Duration(hours: 1));
      final newSession =
          _createTestSession(expiresIn: const Duration(hours: 2));

      scheduler.start(oldSession);
      scheduler.pause();

      // Act
      scheduler.updateSession(newSession);

      // Assert
      verifyNever(() => mockTracker.updateSession(any()));
      // Session is updated internally but tracker is not called while paused
      expect(scheduler.status, TokenRefreshSchedulerStatus.paused);
    });

    test('should check expiration for current session', () {
      // Arrange
      final session = _createTestSession(expiresIn: const Duration(hours: 1));
      final expirationResult = TokenExpirationResult.valid(
        expirationTime: DateTime.now().add(const Duration(hours: 1)),
        timeUntilExpiration: const Duration(hours: 1),
        timeUntilRefresh: const Duration(minutes: 45),
      );

      scheduler.start(session);
      when(() => mockTracker.checkExpiration(any()))
          .thenReturn(expirationResult);

      // Act
      final result = scheduler.checkExpiration();

      // Assert
      verify(() => mockTracker.checkExpiration(session)).called(1);
      expect(result, equals(expirationResult));
    });

    test('should return null when checking expiration with no session', () {
      // Arrange
      when(() => mockTracker.checkExpiration(any())).thenReturn(null);

      // Act
      final result = scheduler.checkExpiration();

      // Assert
      verifyNever(() => mockTracker.checkExpiration(any()));
      expect(result, isNull);
    });
  });

  group('TokenRefreshScheduler - Edge Cases', () {
    test('should handle multiple start calls', () {
      // Arrange
      final session = _createTestSession(expiresIn: const Duration(hours: 1));

      // Act
      scheduler.start(session);
      scheduler.start(session);

      // Assert
      verify(() => mockTracker.startTracking(session)).called(2);
      expect(scheduler.status, TokenRefreshSchedulerStatus.running);
    });

    test('should handle multiple stop calls', () {
      // Arrange
      final session = _createTestSession(expiresIn: const Duration(hours: 1));
      scheduler.start(session);

      // Act
      scheduler.stop();
      scheduler.stop();

      // Assert
      verify(() => mockTracker.stopTracking()).called(2); // Once per stop
      expect(scheduler.status, TokenRefreshSchedulerStatus.stopped);
    });

    test('should handle start after stop', () {
      // Arrange
      final session = _createTestSession(expiresIn: const Duration(hours: 1));

      // Act
      scheduler.start(session);
      scheduler.stop();
      scheduler.start(session);

      // Assert
      verify(() => mockTracker.startTracking(session)).called(2);
      expect(scheduler.status, TokenRefreshSchedulerStatus.running);
    });

    test('should handle lifecycle state changes when stopped', () {
      // Arrange - scheduler is stopped

      // Act
      scheduler.didChangeAppLifecycleState(AppLifecycleState.paused);

      // Assert - should not crash or change state
      expect(scheduler.status, TokenRefreshSchedulerStatus.stopped);
      verifyNever(() => mockTracker.stopTracking());
    });

    test('should handle rapid lifecycle state changes', () {
      // Arrange
      final session = _createTestSession(expiresIn: const Duration(hours: 1));
      final expirationResult = TokenExpirationResult.valid(
        expirationTime: DateTime.now().add(const Duration(hours: 1)),
        timeUntilExpiration: const Duration(hours: 1),
        timeUntilRefresh: const Duration(minutes: 45),
      );

      scheduler.start(session);
      when(() => mockTracker.checkExpiration(any()))
          .thenReturn(expirationResult);

      // Act - rapid state changes
      scheduler.didChangeAppLifecycleState(AppLifecycleState.paused);
      scheduler.didChangeAppLifecycleState(AppLifecycleState.inactive);
      scheduler.didChangeAppLifecycleState(AppLifecycleState.resumed);

      // Assert
      verify(() => mockTracker.startTracking(session)).called(atLeast(1));
      expect(scheduler.status, TokenRefreshSchedulerStatus.running);
    });

    test('should handle disposal', () {
      // Arrange
      final session = _createTestSession(expiresIn: const Duration(hours: 1));
      scheduler.start(session);

      // Act
      scheduler.dispose();

      // Assert
      verify(() => mockTracker.stopTracking()).called(1);
      expect(scheduler.status, TokenRefreshSchedulerStatus.stopped);
    });

    test('should handle reset', () {
      // Arrange
      final session = _createTestSession(expiresIn: const Duration(hours: 1));
      scheduler.start(session);

      // Act
      scheduler.reset();

      // Assert
      verify(() => mockTracker.stopTracking()).called(1);
      expect(scheduler.status, TokenRefreshSchedulerStatus.stopped);
    });
  });

  group('TokenRefreshScheduler - WidgetsBindingObserver', () {
    testWidgets('should register and unregister observer', (tester) async {
      // Arrange
      final session = _createTestSession(expiresIn: const Duration(hours: 1));

      // Act
      scheduler.start(session);
      scheduler.stop();

      // Assert - if observer is not properly unregistered, test would leak
      expect(scheduler.status, TokenRefreshSchedulerStatus.stopped);
    });

    test('should handle multiple start-stop cycles', () {
      // Arrange
      final session = _createTestSession(expiresIn: const Duration(hours: 1));

      // Act - multiple cycles
      for (int i = 0; i < 3; i++) {
        scheduler.start(session);
        scheduler.stop();
      }

      // Assert
      verify(() => mockTracker.startTracking(session)).called(3);
      verify(() => mockTracker.stopTracking()).called(3);
      expect(scheduler.status, TokenRefreshSchedulerStatus.stopped);
    });
  });
}

/// Helper function to create a test AuthSession
AuthSession _createTestSession({required Duration expiresIn}) {
  return AuthSession(
    accessToken: 'test_access_token',
    idToken: 'test_id_token',
    refreshToken: 'test_refresh_token',
    expiresAt: DateTime.now().add(expiresIn),
  );
}
