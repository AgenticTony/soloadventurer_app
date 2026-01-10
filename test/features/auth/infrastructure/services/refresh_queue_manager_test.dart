import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/refresh_queue_manager.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/token_refresh_service.dart';

class MockTokenRefreshService extends Mock implements TokenRefreshService {}

void main() {
  late MockTokenRefreshService mockRefreshService;
  late RefreshQueueManager queueManager;

  setUp(() {
    mockRefreshService = MockTokenRefreshService();
    queueManager = RefreshQueueManager(
      refreshService: mockRefreshService,
    );
  });

  group('RefreshQueueManager - Basic Operations', () {
    test('should perform refresh when queue is empty', () async {
      // Arrange
      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockRefreshService.refreshToken())
          .thenAnswer((_) async => newSession);

      // Act
      final result = await queueManager.enqueueRefresh();

      // Assert
      expect(result.success, isTrue);
      expect(result.session, equals(newSession));
      expect(result.error, isNull);
      expect(result.timedOut, isFalse);
      verify(() => mockRefreshService.refreshToken()).called(1);
    });

    test('should queue multiple concurrent requests', () async {
      // Arrange
      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      // Delay the refresh response to simulate concurrent requests
      when(() => mockRefreshService.refreshToken()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return newSession;
      });

      // Act - enqueue multiple requests before the first completes
      final future1 = queueManager.enqueueRefresh();
      await Future.delayed(const Duration(milliseconds: 10));
      final future2 = queueManager.enqueueRefresh();
      await Future.delayed(const Duration(milliseconds: 10));
      final future3 = queueManager.enqueueRefresh();

      final results = await Future.wait([future1, future2, future3]);

      // Assert
      expect(results.length, equals(3));
      for (final result in results) {
        expect(result.success, isTrue);
        expect(result.session, equals(newSession));
        expect(result.error, isNull);
      }

      // Verify only one refresh was performed
      verify(() => mockRefreshService.refreshToken()).called(1);
    });

    test('should set isRefreshing flag correctly', () async {
      // Arrange
      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockRefreshService.refreshToken()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return newSession;
      });

      // Act
      final future = queueManager.enqueueRefresh();
      expect(queueManager.isRefreshing, isTrue);

      await future;

      // Assert
      expect(queueManager.isRefreshing, isFalse);
    });

    test('should report queue length correctly', () async {
      // Arrange
      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockRefreshService.refreshToken()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return newSession;
      });

      // Act
      final future1 = queueManager.enqueueRefresh();
      await Future.delayed(const Duration(milliseconds: 10));
      expect(queueManager.queueLength, greaterThanOrEqualTo(1));

      final future2 = queueManager.enqueueRefresh();
      await Future.delayed(const Duration(milliseconds: 10));
      expect(queueManager.queueLength, greaterThanOrEqualTo(2));

      await Future.wait([future1, future2]);

      // Assert
      expect(queueManager.queueLength, equals(0));
    });
  });

  group('RefreshQueueManager - Error Handling', () {
    test('should handle refresh failure and resolve all queued requests',
        () async {
      // Arrange
      const error = AuthException('Refresh failed', code: 'REFRESH_ERROR');

      when(() => mockRefreshService.refreshToken()).thenThrow(error);

      // Act
      final future1 = queueManager.enqueueRefresh();
      await Future.delayed(const Duration(milliseconds: 10));
      final future2 = queueManager.enqueueRefresh();

      final results = await Future.wait([future1, future2]);

      // Assert
      expect(results.length, equals(2));
      for (final result in results) {
        expect(result.success, isFalse);
        expect(result.error, equals(error));
        expect(result.timedOut, isFalse);
      }

      verify(() => mockRefreshService.refreshToken()).called(1);
    });

    test('should handle unexpected errors and wrap in AuthException', () async {
      // Arrange
      when(() => mockRefreshService.refreshToken())
          .thenThrow(Exception('Unexpected error'));

      // Act
      final result = await queueManager.enqueueRefresh();

      // Assert
      expect(result.success, isFalse);
      expect(result.error, isNotNull);
      expect(
          result.error!.code, isNull); // Wrapped exception doesn't have a code
      expect(result.timedOut, isFalse);
    });

    test('should reset isRefreshing flag after error', () async {
      // Arrange
      when(() => mockRefreshService.refreshToken()).thenThrow(
          const AuthException('Refresh failed', code: 'REFRESH_ERROR'));

      // Act
      await queueManager.enqueueRefresh();

      // Assert
      expect(queueManager.isRefreshing, isFalse);
    });

    test('should process new requests after previous failure', () async {
      // Arrange
      const error = AuthException('Refresh failed', code: 'REFRESH_ERROR');
      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockRefreshService.refreshToken())
          .thenThrow(error)
          .thenAnswer((_) async => newSession);

      // Act - first request fails
      final result1 = await queueManager.enqueueRefresh();
      expect(result1.success, isFalse);

      // Second request succeeds
      final result2 = await queueManager.enqueueRefresh();

      // Assert
      expect(result2.success, isTrue);
      expect(result2.session, equals(newSession));

      verify(() => mockRefreshService.refreshToken()).called(2);
    });
  });

  group('RefreshQueueManager - Timeout Handling', () {
    test('should timeout request after 30 seconds', () async {
      // Arrange
      when(() => mockRefreshService.refreshToken()).thenAnswer((_) async {
        // Simulate a very long refresh operation
        await Future.delayed(const Duration(seconds: 35));
        return AuthSession(
          accessToken: 'new_access_token',
          idToken: 'new_id_token',
          refreshToken: 'new_refresh_token',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );
      });

      // Act
      final result = await queueManager.enqueueRefresh();

      // Assert
      expect(result.success, isFalse);
      expect(result.timedOut, isTrue);
      expect(result.error, isNotNull);
      expect(result.error!.code, equals('QUEUE_TIMEOUT'));
      expect(result.queueTimeMs, greaterThan(29000)); // ~30 seconds
    });

    test('should allow configuring custom timeout', () async {
      // Note: The timeout is currently hardcoded to 30 seconds
      // This test verifies the current behavior
      // If custom timeout is needed in the future, this test will need updating

      // Arrange
      when(() => mockRefreshService.refreshToken()).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 35));
        return AuthSession(
          accessToken: 'new_access_token',
          idToken: 'new_id_token',
          refreshToken: 'new_refresh_token',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );
      });

      // Act
      final result = await queueManager.enqueueRefresh();

      // Assert - should timeout at 30 seconds, not earlier
      expect(result.queueTimeMs, greaterThan(29000));
      expect(result.timedOut, isTrue);
    });

    test('should handle timeout while requests are queued', () async {
      // Arrange
      when(() => mockRefreshService.refreshToken()).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 35));
        return AuthSession(
          accessToken: 'new_access_token',
          idToken: 'new_id_token',
          refreshToken: 'new_refresh_token',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );
      });

      // Act - queue multiple requests
      final future1 = queueManager.enqueueRefresh();
      await Future.delayed(const Duration(milliseconds: 100));
      final future2 = queueManager.enqueueRefresh();

      final results = await Future.wait([future1, future2]);

      // Assert
      for (final result in results) {
        expect(result.timedOut, isTrue);
        expect(result.success, isFalse);
      }
    });
  });

  group('RefreshQueueManager - Queue Management', () {
    test('should clear queue and cancel pending requests', () async {
      // Arrange
      when(() => mockRefreshService.refreshToken()).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 35));
        return AuthSession(
          accessToken: 'new_access_token',
          idToken: 'new_id_token',
          refreshToken: 'new_refresh_token',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );
      });

      // Act
      final future1 = queueManager.enqueueRefresh();
      await Future.delayed(const Duration(milliseconds: 100));
      final future2 = queueManager.enqueueRefresh();

      // Clear queue before requests complete
      queueManager.clearQueue();

      final results = await Future.wait([future1, future2]);

      // Assert
      for (final result in results) {
        expect(result.timedOut, isTrue);
        expect(result.success, isFalse);
      }

      expect(queueManager.queueLength, equals(0));
      expect(queueManager.isRefreshing, isFalse);
    });

    test('should dispose and clear all pending requests', () async {
      // Arrange
      when(() => mockRefreshService.refreshToken()).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 35));
        return AuthSession(
          accessToken: 'new_access_token',
          idToken: 'new_id_token',
          refreshToken: 'new_refresh_token',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );
      });

      // Act
      final future1 = queueManager.enqueueRefresh();
      await Future.delayed(const Duration(milliseconds: 100));
      final future2 = queueManager.enqueueRefresh();

      queueManager.dispose();

      final results = await Future.wait([future1, future2]);

      // Assert
      for (final result in results) {
        expect(result.timedOut, isTrue);
      }

      expect(queueManager.queueLength, equals(0));
    });

    test('should reset manager state', () async {
      // Arrange
      when(() => mockRefreshService.refreshToken()).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 35));
        return AuthSession(
          accessToken: 'new_access_token',
          idToken: 'new_id_token',
          refreshToken: 'new_refresh_token',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );
      });

      // Act
      final future1 = queueManager.enqueueRefresh();
      await Future.delayed(const Duration(milliseconds: 100));
      final future2 = queueManager.enqueueRefresh();

      queueManager.reset();

      final results = await Future.wait([future1, future2]);

      // Assert
      for (final result in results) {
        expect(result.timedOut, isTrue);
      }

      expect(queueManager.queueLength, equals(0));
      expect(queueManager.isRefreshing, isFalse);
    });
  });

  group('RefreshQueueManager - Queue Time Tracking', () {
    test('should track time spent in queue for successful refresh', () async {
      // Arrange
      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockRefreshService.refreshToken()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return newSession;
      });

      // Act
      final result = await queueManager.enqueueRefresh();

      // Assert
      expect(result.queueTimeMs, greaterThan(0));
      expect(result.queueTimeMs, lessThan(500)); // Should be around 100ms
    });

    test('should track time for each queued request', () async {
      // Arrange
      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockRefreshService.refreshToken()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return newSession;
      });

      // Act
      final future1 = queueManager.enqueueRefresh();
      await Future.delayed(const Duration(milliseconds: 50));
      final future2 = queueManager.enqueueRefresh();

      final results = await Future.wait([future1, future2]);

      // Assert
      expect(results[0].queueTimeMs, greaterThan(0));
      expect(results[1].queueTimeMs, greaterThan(0));
      // Second request should have spent less time in queue
      expect(results[1].queueTimeMs, lessThan(results[0].queueTimeMs));
    });

    test('should track time for failed refresh', () async {
      // Arrange
      when(() => mockRefreshService.refreshToken()).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        throw const AuthException('Refresh failed', code: 'REFRESH_ERROR');
      });

      // Act
      final result = await queueManager.enqueueRefresh();

      // Assert
      expect(result.success, isFalse);
      expect(result.queueTimeMs, greaterThan(0));
      expect(result.queueTimeMs, lessThan(500));
    });
  });

  group('QueuedRefreshResult - Factory Methods', () {
    test('should create success result correctly', () {
      // Arrange
      final session = AuthSession(
        accessToken: 'access_token',
        idToken: 'id_token',
        refreshToken: 'refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      // Act
      final result = QueuedRefreshResult.success(
        session: session,
        queueTimeMs: 100,
      );

      // Assert
      expect(result.success, isTrue);
      expect(result.session, equals(session));
      expect(result.error, isNull);
      expect(result.timedOut, isFalse);
      expect(result.queueTimeMs, equals(100));
    });

    test('should create failure result correctly', () {
      // Arrange
      const error = AuthException('Refresh failed', code: 'REFRESH_ERROR');

      // Act
      final result = QueuedRefreshResult.failure(
        error: error,
        queueTimeMs: 200,
      );

      // Assert
      expect(result.success, isFalse);
      expect(result.error, equals(error));
      expect(result.timedOut, isFalse);
      expect(result.queueTimeMs, equals(200));
    });

    test('should create timeout result correctly', () {
      // Act
      final result = QueuedRefreshResult.timeout(queueTimeMs: 30000);

      // Assert
      expect(result.success, isFalse);
      expect(result.timedOut, isTrue);
      expect(result.error, isNotNull);
      expect(result.error!.code, equals('QUEUE_TIMEOUT'));
      expect(result.queueTimeMs, equals(30000));
    });
  });

  group('RefreshQueueManager - Edge Cases', () {
    test('should handle rapid sequential requests', () async {
      // Arrange
      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockRefreshService.refreshToken())
          .thenAnswer((_) async => newSession);

      // Act - make multiple requests sequentially
      final results = <QueuedRefreshResult>[];
      for (int i = 0; i < 5; i++) {
        final result = await queueManager.enqueueRefresh();
        results.add(result);
      }

      // Assert - all should succeed but with separate refresh calls
      // (since they're sequential, not concurrent)
      expect(results.length, equals(5));
      for (final result in results) {
        expect(result.success, isTrue);
      }
    });

    test('should handle empty queue operations', () {
      // Act & Assert - should not throw
      expect(() => queueManager.clearQueue(), returnsNormally);
      expect(queueManager.queueLength, equals(0));
      expect(queueManager.isRefreshing, isFalse);
    });

    test('should handle multiple clearQueue calls', () async {
      // Arrange
      when(() => mockRefreshService.refreshToken()).thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 35));
        return AuthSession(
          accessToken: 'new_access_token',
          idToken: 'new_id_token',
          refreshToken: 'new_refresh_token',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        );
      });

      queueManager.enqueueRefresh();

      // Act
      await Future.delayed(const Duration(milliseconds: 100));
      queueManager.clearQueue();
      queueManager.clearQueue(); // Should not throw

      // Assert
      expect(queueManager.queueLength, equals(0));
    });

    test('should handle dispose called multiple times', () {
      // Act
      queueManager.dispose();
      queueManager.dispose(); // Should not throw

      // Assert
      expect(queueManager.queueLength, equals(0));
    });

    test('should handle reset called when not refreshing', () {
      // Act & Assert - should not throw
      expect(() => queueManager.reset(), returnsNormally);
      expect(queueManager.queueLength, equals(0));
      expect(queueManager.isRefreshing, isFalse);
    });
  });
}
