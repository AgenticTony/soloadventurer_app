import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:dio/dio.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/token_refresh_service.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/token_expiration_tracker.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/token_refresh_scheduler.dart';
import 'package:soloadventurer/core/api/interceptors/auth_interceptor.dart';
import 'package:soloadventurer/app/di/service_locator.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

/// Integration tests for background token refresh behavior
///
/// These tests verify the complete integration of:
/// - TokenRefreshScheduler
/// - TokenExpirationTracker
/// - TokenRefreshService
/// - AuthInterceptor
///
/// Across various app lifecycle and network scenarios.
void main() {
  late MockAuthRepository mockAuthRepository;
  late TokenRefreshService refreshService;
  late TokenExpirationTracker expirationTracker;
  late TokenRefreshScheduler scheduler;

  setUpAll(() {
    // Initialize Flutter binding for all tests
    TestWidgetsFlutterBinding.ensureInitialized();
  });

  setUp(() {
    mockAuthRepository = MockAuthRepository();

    // Set up default successful refresh behavior
    final defaultSession = AuthSession(
      accessToken: 'new_access_token',
      idToken: 'new_id_token',
      refreshToken: 'new_refresh_token',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );

    when(() => mockAuthRepository.performBasicTokenRefresh())
        .thenAnswer((_) async => defaultSession);

    // Create service instances
    refreshService = TokenRefreshService(
      authRepository: mockAuthRepository,
    );

    expirationTracker = TokenExpirationTracker(
      refreshService: refreshService,
    );

    scheduler = TokenRefreshScheduler(
      expirationTracker: expirationTracker,
    );
  });

  tearDown(() {
    scheduler.dispose();
    expirationTracker.dispose();
    refreshService.dispose();
  });

  group('Background Refresh - Scheduling Integration', () {
    test('should schedule refresh at 75% of token lifetime', () async {
      // Arrange
      final session = AuthSession(
        accessToken: 'test_access_token',
        idToken: 'test_id_token',
        refreshToken: 'test_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      // Act
      scheduler.start(session);

      // Assert
      expect(scheduler.isRunning, isTrue);
      expect(expirationTracker.isMonitoring, isTrue);

      // Verify that expiration check indicates refresh should happen
      final expirationResult = expirationTracker.checkExpiration(session);
      expect(expirationResult.timeUntilRefresh, isNotNull);
      expect(expirationResult.timeUntilRefresh!.inMinutes, lessThanOrEqualTo(45));
    });

    test('should trigger immediate refresh for expiring token', () async {
      // Arrange
      final session = AuthSession(
        accessToken: 'test_access_token',
        idToken: 'test_id_token',
        refreshToken: 'test_refresh_token',
        expiresAt: DateTime.now().add(const Duration(minutes: 3)), // Less than 5 min threshold
      );

      bool refreshStarted = false;
      when(() => mockAuthRepository.performBasicTokenRefresh()).thenAnswer((_) async {
        refreshStarted = true;
        return AuthSession(
          accessToken: 'new_access_token',
          idToken: 'new_id_token',
          refreshToken: 'new_refresh_token',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );
      });

      // Act
      scheduler.start(session);

      // Wait for async refresh to start
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(refreshStarted, isTrue);
      verify(() => mockAuthRepository.performBasicTokenRefresh()).called(greaterThan(0));
    });

    test('should handle session update and reschedule refresh', () async {
      // Arrange
      final initialSession = AuthSession(
        accessToken: 'initial_token',
        idToken: 'initial_id',
        refreshToken: 'initial_refresh',
        expiresAt: DateTime.now().add(const Duration(minutes: 10)),
      );

      scheduler.start(initialSession);
      expect(scheduler.isRunning, isTrue);

      // Act
      final updatedSession = AuthSession(
        accessToken: 'updated_token',
        idToken: 'updated_id',
        refreshToken: 'updated_refresh',
        expiresAt: DateTime.now().add(const Duration(hours: 2)),
      );

      scheduler.updateSession(updatedSession);

      // Assert
      final expirationResult = scheduler.checkExpiration();
      expect(expirationResult, isNotNull);
      expect(expirationResult!.shouldRefresh, isFalse);
    });
  });

  group('Background Refresh - App Lifecycle Integration', () {
    test('should pause tracking when app goes to background', () {
      // Arrange
      final session = AuthSession(
        accessToken: 'test_token',
        idToken: 'test_id',
        refreshToken: 'test_refresh',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      scheduler.start(session);
      expect(scheduler.isRunning, isTrue);

      // Act
      scheduler.didChangeAppLifecycleState(AppLifecycleState.paused);

      // Assert
      expect(scheduler.isPaused, isTrue);
      expect(expirationTracker.isMonitoring, isFalse); // Timer should be stopped
    });

    test('should resume tracking when app returns to foreground', () {
      // Arrange
      final session = AuthSession(
        accessToken: 'test_token',
        idToken: 'test_id',
        refreshToken: 'test_refresh',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      scheduler.start(session);
      scheduler.didChangeAppLifecycleState(AppLifecycleState.paused);
      expect(scheduler.isPaused, isTrue);

      // Act
      scheduler.didChangeAppLifecycleState(AppLifecycleState.resumed);

      // Assert
      expect(scheduler.isRunning, isTrue);
      expect(expirationTracker.isMonitoring, isTrue); // Timer should be restarted
    });

    test('should check expiration immediately on resume', () async {
      // Arrange
      final expiringSession = AuthSession(
        accessToken: 'expiring_token',
        idToken: 'expiring_id',
        refreshToken: 'expiring_refresh',
        expiresAt: DateTime.now().add(const Duration(minutes: 2)),
      );

      bool refreshTriggered = false;
      when(() => mockAuthRepository.performBasicTokenRefresh()).thenAnswer((_) async {
        refreshTriggered = true;
        return AuthSession(
          accessToken: 'new_token',
          idToken: 'new_id',
          refreshToken: 'new_refresh',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );
      });

      scheduler.start(expiringSession);
      scheduler.didChangeAppLifecycleState(AppLifecycleState.paused);

      // Act
      scheduler.didChangeAppLifecycleState(AppLifecycleState.resumed);

      // Wait for async refresh
      await Future.delayed(const Duration(milliseconds: 200));

      // Assert
      expect(refreshTriggered, isTrue);
    });

    test('should stop tracking when app is detached', () {
      // Arrange
      final session = AuthSession(
        accessToken: 'test_token',
        idToken: 'test_id',
        refreshToken: 'test_refresh',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      scheduler.start(session);
      expect(scheduler.isRunning, isTrue);

      // Act
      scheduler.didChangeAppLifecycleState(AppLifecycleState.detached);

      // Assert
      expect(scheduler.isRunning, isFalse);
      expect(scheduler.status, TokenRefreshSchedulerStatus.stopped);
    });

    test('should handle rapid lifecycle state changes', () {
      // Arrange
      final session = AuthSession(
        accessToken: 'test_token',
        idToken: 'test_id',
        refreshToken: 'test_refresh',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      scheduler.start(session);

      // Act - Rapid state changes
      scheduler.didChangeAppLifecycleState(AppLifecycleState.inactive);
      scheduler.didChangeAppLifecycleState(AppLifecycleState.paused);
      scheduler.didChangeAppLifecycleState(AppLifecycleState.hidden);
      scheduler.didChangeAppLifecycleState(AppLifecycleState.resumed);

      // Assert - Should end up in running state
      expect(scheduler.isRunning, isTrue);
      expect(scheduler.status, TokenRefreshSchedulerStatus.running);
    });
  });

  group('Background Refresh - Service Integration', () {
    test('should integrate scheduler with refresh service', () async {
      // Arrange
      final session = AuthSession(
        accessToken: 'test_token',
        idToken: 'test_id',
        refreshToken: 'test_refresh',
        expiresAt: DateTime.now().add(const Duration(minutes: 2)),
      );

      final statusEvents = <TokenRefreshResult>[];
      final subscription = refreshService.statusStream.listen(statusEvents.add);

      // Act
      scheduler.start(session);

      // Wait for refresh to be triggered
      await Future.delayed(const Duration(milliseconds: 200));

      // Assert
      expect(statusEvents.isNotEmpty, isTrue);

      await subscription.cancel();
    });

    test('should propagate refresh service errors to tracker', () async {
      // Arrange
      final session = AuthSession(
        accessToken: 'test_token',
        idToken: 'test_id',
        refreshToken: 'test_refresh',
        expiresAt: DateTime.now().add(const Duration(minutes: 2)),
      );

      when(() => mockAuthRepository.performBasicTokenRefresh()).thenThrow(
        const AuthException('Unknown error', type: AuthErrorType.unknown),
      );

      // Act
      scheduler.start(session);

      // Wait for refresh attempt and error
      await Future.delayed(const Duration(milliseconds: 500));

      // Assert - Should still be running despite error
      expect(scheduler.isRunning, isTrue);
    });

    test('should maintain session consistency across refresh', () async {
      // Arrange
      final initialSession = AuthSession(
        accessToken: 'initial_token',
        idToken: 'initial_id',
        refreshToken: 'initial_refresh',
        expiresAt: DateTime.now().add(const Duration(minutes: 2)),
      );

      final refreshedSession = AuthSession(
        accessToken: 'refreshed_token',
        idToken: 'refreshed_id',
        refreshToken: 'refreshed_refresh',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockAuthRepository.performBasicTokenRefresh()).thenAnswer(
        (_) async => refreshedSession,
      );

      // Act
      scheduler.start(initialSession);

      // Wait for refresh
      await Future.delayed(const Duration(milliseconds: 200));

      // Assert
      final currentExpiration = scheduler.checkExpiration();
      expect(currentExpiration, isNotNull);
      expect(currentExpiration!.expirationTime, equals(refreshedSession.expiresAt));
    });
  });
}
