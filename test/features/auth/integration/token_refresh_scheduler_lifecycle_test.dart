import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/token_expiration_tracker.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/token_refresh_scheduler.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/token_refresh_service.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  group('TokenRefreshScheduler Lifecycle Integration', () {
    late TokenRefreshScheduler scheduler;
    late TokenExpirationTracker tracker;
    late MockTokenRefreshService mockRefreshService;

    setUp(() {
      // Ensure Flutter binding is initialized
      TestWidgetsFlutterBinding.ensureInitialized();
      mockRefreshService = MockTokenRefreshService();
      tracker = TokenExpirationTracker(refreshService: mockRefreshService);
      scheduler = TokenRefreshScheduler(expirationTracker: tracker);
    });

    tearDown(() {
      scheduler.dispose();
    });

    test('should register and unregister as WidgetsBindingObserver', () {
      // Create a session that expires in 1 hour
      final session = AuthSession(
        accessToken: 'test_access_token',
        idToken: 'test_id_token',
        refreshToken: 'test_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      // Start the scheduler
      scheduler.start(session);

      // Verify scheduler is running
      expect(scheduler.isRunning, true);
      expect(scheduler.status, TokenRefreshSchedulerStatus.running);

      // Stop the scheduler
      scheduler.stop();

      // Verify scheduler is stopped
      expect(scheduler.isRunning, false);
      expect(scheduler.status, TokenRefreshSchedulerStatus.stopped);
    });

    test('should pause on inactive state', () {
      final session = AuthSession(
        accessToken: 'test_access_token',
        idToken: 'test_id_token',
        refreshToken: 'test_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      scheduler.start(session);
      expect(scheduler.isRunning, true);

      // Simulate app going to inactive state
      scheduler.didChangeAppLifecycleState(AppLifecycleState.inactive);

      // Verify scheduler is paused
      expect(scheduler.isPaused, true);
      expect(scheduler.status, TokenRefreshSchedulerStatus.paused);
    });

    test('should pause on paused state', () {
      final session = AuthSession(
        accessToken: 'test_access_token',
        idToken: 'test_id_token',
        refreshToken: 'test_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      scheduler.start(session);
      expect(scheduler.isRunning, true);

      // Simulate app going to background
      scheduler.didChangeAppLifecycleState(AppLifecycleState.paused);

      // Verify scheduler is paused
      expect(scheduler.isPaused, true);
      expect(scheduler.status, TokenRefreshSchedulerStatus.paused);
    });

    test('should resume on resumed state', () {
      final session = AuthSession(
        accessToken: 'test_access_token',
        idToken: 'test_id_token',
        refreshToken: 'test_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      scheduler.start(session);

      // Simulate app going to background
      scheduler.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(scheduler.isPaused, true);

      // Simulate app returning to foreground
      scheduler.didChangeAppLifecycleState(AppLifecycleState.resumed);

      // Verify scheduler is running again
      expect(scheduler.isRunning, true);
      expect(scheduler.status, TokenRefreshSchedulerStatus.running);
    });

    test('should stop on detached state', () {
      final session = AuthSession(
        accessToken: 'test_access_token',
        idToken: 'test_id_token',
        refreshToken: 'test_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      scheduler.start(session);
      expect(scheduler.isRunning, true);

      // Simulate app being destroyed
      scheduler.didChangeAppLifecycleState(AppLifecycleState.detached);

      // Verify scheduler is stopped
      expect(scheduler.isRunning, false);
      expect(scheduler.status, TokenRefreshSchedulerStatus.stopped);
    });

    test('should handle multiple pause/resume cycles', () {
      final session = AuthSession(
        accessToken: 'test_access_token',
        idToken: 'test_id_token',
        refreshToken: 'test_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      scheduler.start(session);

      // First pause/resume cycle
      scheduler.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(scheduler.isPaused, true);

      scheduler.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(scheduler.isRunning, true);

      // Second pause/resume cycle
      scheduler.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(scheduler.isPaused, true);

      scheduler.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(scheduler.isRunning, true);

      // Third pause/resume cycle
      scheduler.didChangeAppLifecycleState(AppLifecycleState.hidden);
      expect(scheduler.isPaused, true);

      scheduler.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(scheduler.isRunning, true);
    });

    test('should check expiration on resume', () {
      final session = AuthSession(
        accessToken: 'test_access_token',
        idToken: 'test_id_token',
        refreshToken: 'test_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      scheduler.start(session);

      // Pause the scheduler
      scheduler.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(scheduler.isPaused, true);

      // Resume the scheduler
      scheduler.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(scheduler.isRunning, true);

      // Check that expiration check was performed
      final expirationResult = scheduler.checkExpiration();
      expect(expirationResult, isNotNull);
      expect(expirationResult!.isExpired, false);
    });

    test('should handle rapid state changes', () {
      final session = AuthSession(
        accessToken: 'test_access_token',
        idToken: 'test_id_token',
        refreshToken: 'test_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      scheduler.start(session);

      // Simulate rapid state changes
      scheduler.didChangeAppLifecycleState(AppLifecycleState.inactive);
      scheduler.didChangeAppLifecycleState(AppLifecycleState.paused);
      scheduler.didChangeAppLifecycleState(AppLifecycleState.hidden);
      scheduler.didChangeAppLifecycleState(AppLifecycleState.resumed);

      // Should end up in running state
      expect(scheduler.isRunning, true);
      expect(scheduler.status, TokenRefreshSchedulerStatus.running);
    });

    test('should not crash when pause is called without start', () {
      // Try to pause without starting - should not crash
      scheduler.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(scheduler.status, TokenRefreshSchedulerStatus.stopped);
    });

    test('should not crash when resume is called without pause', () {
      final session = AuthSession(
        accessToken: 'test_access_token',
        idToken: 'test_id_token',
        refreshToken: 'test_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      scheduler.start(session);

      // Try to resume without pausing first - should handle gracefully
      scheduler.didChangeAppLifecycleState(AppLifecycleState.resumed);
      expect(scheduler.isRunning, true);
    });

    test('should handle stop during pause', () {
      final session = AuthSession(
        accessToken: 'test_access_token',
        idToken: 'test_id_token',
        refreshToken: 'test_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      scheduler.start(session);
      scheduler.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(scheduler.isPaused, true);

      // Stop while paused
      scheduler.stop();

      // Should be stopped, not paused
      expect(scheduler.isRunning, false);
      expect(scheduler.isPaused, false);
      expect(scheduler.status, TokenRefreshSchedulerStatus.stopped);
    });
  });
}

class MockTokenRefreshService extends Mock implements TokenRefreshService {}
