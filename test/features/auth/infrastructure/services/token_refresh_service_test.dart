import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/token_refresh_service.dart';

class MockAuthRepository extends Mock implements AuthRepository {}

void main() {
  late MockAuthRepository mockAuthRepository;
  late TokenRefreshService refreshService;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    refreshService = TokenRefreshService(
      authRepository: mockAuthRepository,
    );
  });

  tearDown(() {
    refreshService.dispose();
  });

  group('TokenRefreshService - Basic Operations', () {
    test('should successfully refresh token on first attempt', () async {
      // Arrange
      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenAnswer((_) async => newSession);

      // Act
      final result = await refreshService.refreshToken();

      // Assert
      expect(result.accessToken, equals('new_access_token'));
      expect(result.idToken, equals('new_id_token'));
      expect(result.refreshToken, equals('new_refresh_token'));
      verify(() => mockAuthRepository.performBasicTokenRefresh()).called(1);
    });

    test('should set isRefreshing flag correctly', () async {
      // Arrange
      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return newSession;
      });

      // Act
      final future = refreshService.refreshToken();

      // Assert - should be refreshing while operation is in progress
      expect(refreshService.isRefreshing, isTrue);

      await future;

      // Assert - should no longer be refreshing after completion
      expect(refreshService.isRefreshing, isFalse);
    });

    test('should emit status events during refresh', () async {
      // Arrange
      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenAnswer((_) async => newSession);

      final statusEvents = <TokenRefreshResult>[];
      final subscription = refreshService.statusStream.listen(statusEvents.add);

      // Act
      await refreshService.refreshToken();

      // Assert
      expect(statusEvents.isNotEmpty, isTrue);
      expect(statusEvents.last.status, equals(TokenRefreshStatus.success));

      await subscription.cancel();
    });

    test('should handle auth exception and throw', () async {
      // Arrange
      const error = AuthException('Refresh failed', code: 'REFRESH_ERROR');

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenThrow(error);

      // Act & Assert
      expect(
        () => refreshService.refreshToken(),
        throwsA(equals(error)),
      );
    });

    test('should wrap unexpected errors in AuthException', () async {
      // Arrange
      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenThrow(Exception('Unexpected error'));

      // Act & Assert
      expect(
        () => refreshService.refreshToken(),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('TokenRefreshService - Mutex Pattern', () {
    test('should prevent concurrent refresh attempts', () async {
      // Arrange
      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return newSession;
      });

      // Act - start multiple concurrent refreshes
      final future1 = refreshService.refreshToken();
      await Future.delayed(const Duration(milliseconds: 10));
      final future2 = refreshService.refreshToken();
      await Future.delayed(const Duration(milliseconds: 10));
      final future3 = refreshService.refreshToken();

      final results = await Future.wait([future1, future2, future3]);

      // Assert - all should return the same session
      for (final result in results) {
        expect(result.accessToken, equals('new_access_token'));
      }

      // Verify only one refresh was performed
      verify(() => mockAuthRepository.performBasicTokenRefresh()).called(1);
    });

    test('should wait for in-progress refresh to complete', () async {
      // Arrange
      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      int callCount = 0;
      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenAnswer((_) async {
        callCount++;
        await Future.delayed(const Duration(milliseconds: 100));
        return newSession;
      });

      // Act - start first refresh and wait a bit
      final future1 = refreshService.refreshToken();
      await Future.delayed(const Duration(milliseconds: 20));

      // Start second refresh while first is in progress
      final future2 = refreshService.refreshToken();

      await Future.wait([future1, future2]);

      // Assert - should have called refresh only once
      expect(callCount, equals(1));
    });

    test('should allow new refresh after previous completes', () async {
      // Arrange
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
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenAnswer((_) async => session1)
          .thenAnswer((_) async => session2);

      // Act - perform sequential refreshes
      final result1 = await refreshService.refreshToken();
      expect(refreshService.isRefreshing, isFalse);

      final result2 = await refreshService.refreshToken();

      // Assert
      expect(result1.accessToken, equals('access_token_1'));
      expect(result2.accessToken, equals('access_token_2'));
      verify(() => mockAuthRepository.performBasicTokenRefresh()).called(2);
    });
  });

  group('TokenRefreshService - Exponential Backoff', () {
    test('should retry with exponential backoff on retryable error', () async {
      // Arrange
      const networkError = AuthException(
        'Network error',
        code: 'NETWORK_ERROR',
      );

      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenThrow(networkError)
          .thenThrow(networkError)
          .thenAnswer((_) async => newSession);

      // Act
      final stopwatch = Stopwatch()..start();
      final result = await refreshService.refreshToken();
      stopwatch.stop();

      // Assert
      expect(result.accessToken, equals('new_access_token'));

      // Verify retries happened with exponential backoff
      // Expected: 1000ms (1st retry) + 2000ms (2nd retry) = 3000ms total
      // Allow some tolerance for test execution time
      expect(stopwatch.elapsedMilliseconds, greaterThan(2800));
      expect(stopwatch.elapsedMilliseconds, lessThan(3500));

      verify(() => mockAuthRepository.performBasicTokenRefresh()).called(3);
    });

    test('should calculate correct backoff delays', () async {
      // Act & Assert
      // This tests the private method indirectly through the retry behavior
      // Expected backoff: 1s, 2s, 4s, 8s, 16s, 32s max

      const error = AuthException('Network error', code: 'NETWORK_ERROR');
      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      // Setup to fail twice then succeed
      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenThrow(error)
          .thenThrow(error)
          .thenAnswer((_) async => newSession);

      final stopwatch = Stopwatch()..start();
      await refreshService.refreshToken();
      stopwatch.stop();

      // 2 retries should result in ~1000ms + ~2000ms = ~3000ms total delay
      expect(stopwatch.elapsedMilliseconds, greaterThan(2800));
      expect(stopwatch.elapsedMilliseconds, lessThan(3500));
    });

    test('should not retry on non-retryable errors', () async {
      // Arrange
      const credentialError = AuthException(
        'Invalid credentials',
        code: 'INVALID_CREDENTIALS',
      );

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenThrow(credentialError);

      final stopwatch = Stopwatch()..start();

      // Act & Assert
      expect(
        () => refreshService.refreshToken(),
        throwsA(equals(credentialError)),
      );

      stopwatch.stop();

      // Should fail immediately without retry delay
      expect(stopwatch.elapsedMilliseconds, lessThan(100));

      // Should only call once (no retries)
      verify(() => mockAuthRepository.performBasicTokenRefresh()).called(1);
    });

    test('should retry on network timeout errors', () async {
      // Arrange
      const timeoutError = AuthException(
        'Request timeout',
        code: 'network_timeout',
      );

      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenThrow(timeoutError)
          .thenAnswer((_) async => newSession);

      // Act
      final result = await refreshService.refreshToken();

      // Assert
      expect(result.accessToken, equals('new_access_token'));
      verify(() => mockAuthRepository.performBasicTokenRefresh()).called(2);
    });

    test('should exhaust max retry attempts', () async {
      // Arrange
      const error = AuthException('Network error', code: 'NETWORK_ERROR');

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenThrow(error);

      // Act & Assert
      expect(
        () => refreshService.refreshToken(),
        throwsA(isA<AuthException>()),
      );

      // Should attempt 3 times total (1 initial + 2 retries)
      verify(() => mockAuthRepository.performBasicTokenRefresh()).called(3);
    });

    test('should return max retries exceeded error after all attempts fail',
        () async {
      // Arrange
      const error = AuthException('Network error', code: 'NETWORK_ERROR');

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenThrow(error);

      // Act & Assert
      final thrownError = await expectLater(
        () => refreshService.refreshToken(),
        throwsA(isA<AuthException>()),
      );

      // Verify the error is about max retries
      expect(thrownError.toString(), contains('MAX_RETRIES_EXCEEDED'));
    });
  });

  group('TokenRefreshService - Status Stream', () {
    test('should emit in-progress status at start of refresh', () async {
      // Arrange
      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenAnswer((_) async => newSession);

      final statusEvents = <TokenRefreshResult>[];
      final subscription = refreshService.statusStream.listen(statusEvents.add);

      // Act
      await refreshService.refreshToken();

      // Assert
      expect(statusEvents.isNotEmpty, isTrue);
      expect(
        statusEvents.any((e) => e.status == TokenRefreshStatus.inProgress),
        isTrue,
      );

      await subscription.cancel();
    });

    test('should emit success status on successful refresh', () async {
      // Arrange
      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenAnswer((_) async => newSession);

      final statusEvents = <TokenRefreshResult>[];
      final subscription = refreshService.statusStream.listen(statusEvents.add);

      // Act
      await refreshService.refreshToken();

      // Assert
      expect(statusEvents.isNotEmpty, isTrue);
      expect(statusEvents.last.status, equals(TokenRefreshStatus.success));
      expect(statusEvents.last.session, equals(newSession));
      expect(statusEvents.last.attemptNumber, equals(1));

      await subscription.cancel();
    });

    test('should emit failure status on failed refresh', () async {
      // Arrange
      const error = AuthException('Refresh failed', code: 'REFRESH_ERROR');

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenThrow(error);

      final statusEvents = <TokenRefreshResult>[];
      final subscription = refreshService.statusStream.listen(statusEvents.add);

      // Act
      await expectLater(
        () => refreshService.refreshToken(),
        throwsA(equals(error)),
      );

      // Assert
      expect(statusEvents.isNotEmpty, isTrue);
      expect(statusEvents.last.status, equals(TokenRefreshStatus.failure));
      expect(statusEvents.last.error, equals(error));

      await subscription.cancel();
    });

    test('should emit multiple in-progress events during retries', () async {
      // Arrange
      const error = AuthException('Network error', code: 'NETWORK_ERROR');

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenThrow(error)
          .thenThrow(error)
          .thenThrow(error);

      final statusEvents = <TokenRefreshResult>[];
      final subscription = refreshService.statusStream.listen(statusEvents.add);

      // Act
      await expectLater(
        () => refreshService.refreshToken(),
        throwsA(isA<AuthException>()),
      );

      // Assert
      // Should have 3 in-progress events (one for each attempt)
      final inProgressEvents = statusEvents
          .where((e) => e.status == TokenRefreshStatus.inProgress)
          .toList();
      expect(inProgressEvents.length, equals(3));

      // Verify attempt numbers are correct
      expect(inProgressEvents[0].attemptNumber, equals(1));
      expect(inProgressEvents[1].attemptNumber, equals(2));
      expect(inProgressEvents[2].attemptNumber, equals(3));

      await subscription.cancel();
    });

    test('should include attempt number in status events', () async {
      // Arrange
      const error = AuthException('Network error', code: 'NETWORK_ERROR');

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenThrow(error)
          .thenThrow(error)
          .thenThrow(error);

      final statusEvents = <TokenRefreshResult>[];
      final subscription = refreshService.statusStream.listen(statusEvents.add);

      // Act
      await expectLater(
        () => refreshService.refreshToken(),
        throwsA(isA<AuthException>()),
      );

      // Assert
      for (final event in statusEvents) {
        expect(event.attemptNumber, greaterThan(0));
        expect(event.attemptNumber, lessThanOrEqualTo(3));
      }

      await subscription.cancel();
    });

    test('should include total delay in status events', () async {
      // Arrange
      const error = AuthException('Network error', code: 'NETWORK_ERROR');

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenThrow(error)
          .thenThrow(error)
          .thenThrow(error);

      final statusEvents = <TokenRefreshResult>[];
      final subscription = refreshService.statusStream.listen(statusEvents.add);

      // Act
      await expectLater(
        () => refreshService.refreshToken(),
        throwsA(isA<AuthException>()),
      );

      // Assert - final event should have accumulated delay from retries
      final finalEvent = statusEvents.last;
      expect(finalEvent.totalDelayMs, greaterThan(0));

      await subscription.cancel();
    });

    test('should broadcast to multiple listeners', () async {
      // Arrange
      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenAnswer((_) async => newSession);

      final events1 = <TokenRefreshResult>[];
      final events2 = <TokenRefreshResult>[];

      final sub1 = refreshService.statusStream.listen(events1.add);
      final sub2 = refreshService.statusStream.listen(events2.add);

      // Act
      await refreshService.refreshToken();

      // Assert
      expect(events1, isNotEmpty);
      expect(events2, isNotEmpty);
      expect(events1.length, equals(events2.length));

      await sub1.cancel();
      await sub2.cancel();
    });
  });

  group('TokenRefreshService - Cancel and Dispose', () {
    test('should cancel in-progress refresh', () async {
      // Arrange
      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return newSession;
      });

      // Act
      final future = refreshService.refreshToken();
      expect(refreshService.isRefreshing, isTrue);

      refreshService.cancelRefresh();

      // Assert
      expect(refreshService.isRefreshing, isFalse);

      // The future should throw a cancelled error
      await expectLater(
        () => future,
        throwsA(isA<AuthException>()),
      );
    });

    test('should emit cancelled status when refresh is cancelled', () async {
      // Arrange
      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return newSession;
      });

      final statusEvents = <TokenRefreshResult>[];
      final subscription = refreshService.statusStream.listen(statusEvents.add);

      // Act
      final future = refreshService.refreshToken();
      await Future.delayed(const Duration(milliseconds: 10));
      refreshService.cancelRefresh();

      await expectLater(() => future, throwsA(isA<AuthException>()));

      // Assert
      expect(
        statusEvents.any((e) => e.status == TokenRefreshStatus.cancelled),
        isTrue,
      );

      await subscription.cancel();
    });

    test('should close status stream on dispose', () async {
      // Arrange
      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenAnswer((_) async => newSession);

      // Act
      refreshService.dispose();

      // Assert - stream should be closed
      expect(refreshService.statusStream, emitsDone);
    });

    test('should cancel in-progress refresh and close stream on dispose',
        () async {
      // Arrange
      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return newSession;
      });

      // Act
      final future = refreshService.refreshToken();
      await Future.delayed(const Duration(milliseconds: 10));

      refreshService.dispose();

      // Assert
      expect(refreshService.isRefreshing, isFalse);
      await expectLater(() => future, throwsA(isA<AuthException>()));
    });

    test('should reset service state', () async {
      // Arrange
      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return newSession;
      });

      // Act
      final future = refreshService.refreshToken();
      await Future.delayed(const Duration(milliseconds: 10));

      refreshService.reset();

      // Assert
      expect(refreshService.isRefreshing, isFalse);

      // The future should complete with an error
      await expectLater(() => future, throwsA(isA<AuthException>()));
    });

    test('should handle multiple dispose calls', () {
      // Act & Assert - should not throw
      expect(() => refreshService.dispose(), returnsNormally);
      expect(() => refreshService.dispose(), returnsNormally);
    });

    test('should handle cancel when no refresh is in progress', () {
      // Act & Assert - should not throw
      expect(() => refreshService.cancelRefresh(), returnsNormally);
      expect(refreshService.isRefreshing, isFalse);
    });
  });

  group('TokenRefreshService - Edge Cases', () {
    test('should handle rapid sequential refresh requests', () async {
      // Arrange
      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenAnswer((_) async => newSession);

      // Act - make multiple sequential requests
      final results = <AuthSession>[];
      for (int i = 0; i < 5; i++) {
        final result = await refreshService.refreshToken();
        results.add(result);
      }

      // Assert - all should succeed
      expect(results.length, equals(5));
      for (final result in results) {
        expect(result.accessToken, equals('new_access_token'));
      }

      // Each should result in a separate refresh call (since they're sequential, not concurrent)
      verify(() => mockAuthRepository.performBasicTokenRefresh()).called(5);
    });

    test('should handle empty session with correct error', () async {
      // Arrange - simulate a refresh that returns null session
      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenAnswer((_) async => AuthSession(
                accessToken: '',
                idToken: '',
                refreshToken: '',
                expiresAt: DateTime.now(),
              ));

      // Act - should complete without throwing
      final result = await refreshService.refreshToken();

      // Assert
      expect(result, isNotNull);
    });

    test('should handle reset followed by new refresh', () async {
      // Arrange
      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenAnswer((_) async => newSession);

      // Act
      refreshService.reset();
      final result = await refreshService.refreshToken();

      // Assert
      expect(result.accessToken, equals('new_access_token'));
      expect(refreshService.isRefreshing, isFalse);
    });

    test('should handle concurrent calls with different error types', () async {
      // Arrange
      const networkError =
          AuthException('Network error', code: 'NETWORK_ERROR');
      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenThrow(networkError)
          .thenAnswer((_) async => newSession);

      // Act - start concurrent calls
      final future1 = refreshService.refreshToken();
      await Future.delayed(const Duration(milliseconds: 10));
      final future2 = refreshService.refreshToken();

      final results = await Future.wait([
        future1.then((_) => 'success'),
        future2.then((_) => 'success'),
      ]).catchError((e) => ['error', 'error']);

      // Assert - both should get the same final result (success after retry)
      expect(results, contains('success'));
    });
  });

  group('TokenRefreshService - Error Classification', () {
    test('should not retry on INVALID_CREDENTIALS', () async {
      // Arrange
      const error = AuthException(
        'Invalid credentials',
        code: 'INVALID_CREDENTIALS',
      );

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenThrow(error);

      // Act & Assert
      await expectLater(
        () => refreshService.refreshToken(),
        throwsA(equals(error)),
      );

      verify(() => mockAuthRepository.performBasicTokenRefresh()).called(1);
    });

    test('should not retry on USER_NOT_FOUND', () async {
      // Arrange
      const error = AuthException(
        'User not found',
        code: 'USER_NOT_FOUND',
      );

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenThrow(error);

      // Act & Assert
      await expectLater(
        () => refreshService.refreshToken(),
        throwsA(equals(error)),
      );

      verify(() => mockAuthRepository.performBasicTokenRefresh()).called(1);
    });

    test('should not retry on EMAIL_NOT_VERIFIED', () async {
      // Arrange
      const error = AuthException(
        'Email not verified',
        code: 'EMAIL_NOT_VERIFIED',
      );

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenThrow(error);

      // Act & Assert
      await expectLater(
        () => refreshService.refreshToken(),
        throwsA(equals(error)),
      );

      verify(() => mockAuthRepository.performBasicTokenRefresh()).called(1);
    });

    test('should retry on unknown error codes', () async {
      // Arrange
      const error = AuthException(
        'Unknown error',
        code: 'UNKNOWN_ERROR',
      );

      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenThrow(error)
          .thenAnswer((_) async => newSession);

      // Act
      final result = await refreshService.refreshToken();

      // Assert
      expect(result.accessToken, equals('new_access_token'));
      verify(() => mockAuthRepository.performBasicTokenRefresh()).called(2);
    });

    test('should retry on error with null code', () async {
      // Arrange
      const error = AuthException('Some error');

      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenThrow(error)
          .thenAnswer((_) async => newSession);

      // Act
      final result = await refreshService.refreshToken();

      // Assert
      expect(result.accessToken, equals('new_access_token'));
      verify(() => mockAuthRepository.performBasicTokenRefresh()).called(2);
    });
  });

  group('TokenRefreshResult - Factory Methods', () {
    test('should create success result correctly', () {
      // Arrange
      final session = AuthSession(
        accessToken: 'access_token',
        idToken: 'id_token',
        refreshToken: 'refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      // Act
      final result = TokenRefreshResult.success(
        session: session,
        attemptNumber: 2,
        totalDelayMs: 3000,
      );

      // Assert
      expect(result.status, equals(TokenRefreshStatus.success));
      expect(result.session, equals(session));
      expect(result.error, isNull);
      expect(result.attemptNumber, equals(2));
      expect(result.totalDelayMs, equals(3000));
    });

    test('should create failure result correctly', () {
      // Arrange
      const error = AuthException('Refresh failed', code: 'REFRESH_ERROR');

      // Act
      final result = TokenRefreshResult.failure(
        error: error,
        attemptNumber: 3,
        totalDelayMs: 7000,
      );

      // Assert
      expect(result.status, equals(TokenRefreshStatus.failure));
      expect(result.error, equals(error));
      expect(result.session, isNull);
      expect(result.attemptNumber, equals(3));
      expect(result.totalDelayMs, equals(7000));
    });

    test('should create in-progress result correctly', () {
      // Act
      final result = TokenRefreshResult.inProgress(attemptNumber: 1);

      // Assert
      expect(result.status, equals(TokenRefreshStatus.inProgress));
      expect(result.session, isNull);
      expect(result.error, isNull);
      expect(result.attemptNumber, equals(1));
      expect(result.totalDelayMs, equals(0));
    });

    test('should create cancelled result correctly', () {
      // Act
      final result = TokenRefreshResult.cancelled();

      // Assert
      expect(result.status, equals(TokenRefreshStatus.cancelled));
      expect(result.session, isNull);
      expect(result.error, isNull);
      expect(result.attemptNumber, equals(0));
      expect(result.totalDelayMs, equals(0));
    });

    test('should provide meaningful toString', () {
      // Arrange
      final result = TokenRefreshResult.success(
        session: AuthSession(
          accessToken: 'token',
          idToken: 'id',
          refreshToken: 'refresh',
          expiresAt: DateTime.now().add(const Duration(hours: 1)),
        ),
        attemptNumber: 1,
        totalDelayMs: 1000,
      );

      // Act
      final str = result.toString();

      // Assert
      expect(str, contains('TokenRefreshResult'));
      expect(str, contains('success'));
      expect(str, contains('1'));
      expect(str, contains('1000'));
    });
  });

  group('TokenRefreshStatus - Enum Values', () {
    test('should have correct enum values', () {
      // Assert
      expect(TokenRefreshStatus.values.length, equals(4));
      expect(
          TokenRefreshStatus.values, contains(TokenRefreshStatus.inProgress));
      expect(TokenRefreshStatus.values, contains(TokenRefreshStatus.success));
      expect(TokenRefreshStatus.values, contains(TokenRefreshStatus.failure));
      expect(TokenRefreshStatus.values, contains(TokenRefreshStatus.cancelled));
    });
  });
}
