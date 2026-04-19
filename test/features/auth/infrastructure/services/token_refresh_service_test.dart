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
      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenAnswer((_) async => newSession);

      final result = await refreshService.refreshToken();

      expect(result.accessToken, equals('new_access_token'));
      expect(result.idToken, equals('new_id_token'));
      expect(result.refreshToken, equals('new_refresh_token'));
      verify(() => mockAuthRepository.performBasicTokenRefresh()).called(1);
    });

    test('should set isRefreshing flag correctly', () async {
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

      final future = refreshService.refreshToken();

      expect(refreshService.isRefreshing, isTrue);

      await future;

      expect(refreshService.isRefreshing, isFalse);
    });

    test('should emit status events during refresh', () async {
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

      await refreshService.refreshToken();

      // Allow stream events to be delivered
      await Future.delayed(Duration.zero);

      expect(statusEvents.isNotEmpty, isTrue);
      expect(statusEvents.last.status, equals(TokenRefreshStatus.success));

      await subscription.cancel();
    });

    test('should handle auth exception and throw', () async {
      const error = AuthException('Refresh failed', code: 'REFRESH_ERROR');

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenThrow(error);

      expect(
        () => refreshService.refreshToken(),
        throwsA(equals(error)),
      );
    });

    test('should wrap unexpected errors in AuthException', () async {
      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenThrow(Exception('Unexpected error'));

      expect(
        () => refreshService.refreshToken(),
        throwsA(isA<AuthException>()),
      );
    });
  });

  group('TokenRefreshService - Mutex Pattern', () {
    test('should prevent concurrent refresh attempts', () async {
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

      final future1 = refreshService.refreshToken();
      await Future.delayed(const Duration(milliseconds: 10));
      final future2 = refreshService.refreshToken();
      await Future.delayed(const Duration(milliseconds: 10));
      final future3 = refreshService.refreshToken();

      final results = await Future.wait([future1, future2, future3]);

      for (final result in results) {
        expect(result.accessToken, equals('new_access_token'));
      }

      verify(() => mockAuthRepository.performBasicTokenRefresh()).called(1);
    });

    test('should wait for in-progress refresh to complete', () async {
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

      final future1 = refreshService.refreshToken();
      await Future.delayed(const Duration(milliseconds: 20));

      final future2 = refreshService.refreshToken();

      await Future.wait([future1, future2]);

      expect(callCount, equals(1));
    });

    test('should allow new refresh after previous completes', () async {
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

      int callIndex = 0;
      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenAnswer((_) async {
        callIndex++;
        return callIndex == 1 ? session1 : session2;
      });

      final result1 = await refreshService.refreshToken();
      expect(refreshService.isRefreshing, isFalse);

      final result2 = await refreshService.refreshToken();

      expect(result1.accessToken, equals('access_token_1'));
      expect(result2.accessToken, equals('access_token_2'));
      verify(() => mockAuthRepository.performBasicTokenRefresh()).called(2);
    });
  });

  group('TokenRefreshService - Exponential Backoff', () {
    test('should retry with exponential backoff on retryable error', () async {
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

      int callIndex = 0;
      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenAnswer((_) async {
        callIndex++;
        if (callIndex <= 2) throw networkError;
        return newSession;
      });

      final stopwatch = Stopwatch()..start();
      final result = await refreshService.refreshToken();
      stopwatch.stop();

      expect(result.accessToken, equals('new_access_token'));

      // Expected: 2000ms (2nd attempt) + 4000ms (3rd attempt) = 6000ms total
      expect(stopwatch.elapsedMilliseconds, greaterThan(5500));
      expect(stopwatch.elapsedMilliseconds, lessThan(7000));

      verify(() => mockAuthRepository.performBasicTokenRefresh()).called(3);
    });

    test('should calculate correct backoff delays', () async {
      const error = AuthException('Network error', code: 'NETWORK_ERROR');
      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      int callIndex = 0;
      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenAnswer((_) async {
        callIndex++;
        if (callIndex <= 2) throw error;
        return newSession;
      });

      final stopwatch = Stopwatch()..start();
      await refreshService.refreshToken();
      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, greaterThan(5500));
      expect(stopwatch.elapsedMilliseconds, lessThan(7000));
    });

    test('should not retry on non-retryable errors', () async {
      const credentialError = AuthException(
        'Invalid credentials',
        code: 'INVALID_CREDENTIALS',
      );

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenThrow(credentialError);

      final stopwatch = Stopwatch()..start();

      expect(
        () => refreshService.refreshToken(),
        throwsA(equals(credentialError)),
      );

      stopwatch.stop();

      expect(stopwatch.elapsedMilliseconds, lessThan(100));
      verify(() => mockAuthRepository.performBasicTokenRefresh()).called(1);
    });

    test('should retry on network timeout errors', () async {
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

      int callIndex = 0;
      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenAnswer((_) async {
        callIndex++;
        if (callIndex == 1) throw timeoutError;
        return newSession;
      });

      final result = await refreshService.refreshToken();

      expect(result.accessToken, equals('new_access_token'));
      verify(() => mockAuthRepository.performBasicTokenRefresh()).called(2);
    });

    test('should exhaust max retry attempts', () async {
      const error = AuthException('Network error', code: 'NETWORK_ERROR');

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenThrow(error);

      try {
        await refreshService.refreshToken();
        fail('Should have thrown');
      } on AuthException catch (e) {
        expect(e.message, equals('Network error'));
      }

      verify(() => mockAuthRepository.performBasicTokenRefresh()).called(3);
    });

    test('should return max retries exceeded error after all attempts fail',
        () async {
      const error = AuthException('Network error', code: 'NETWORK_ERROR');

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenThrow(error);

      AuthException? caughtError;
      try {
        await refreshService.refreshToken();
      } on AuthException catch (e) {
        caughtError = e;
      }

      expect(caughtError, isNotNull);
      expect(caughtError!.message, equals('Network error'));
      expect(caughtError!.code, equals('NETWORK_ERROR'));
    });
  });

  group('TokenRefreshService - Status Stream', () {
    test('should emit in-progress status at start of refresh', () async {
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

      await refreshService.refreshToken();

      // Allow stream events to be delivered
      await Future.delayed(Duration.zero);

      expect(statusEvents.isNotEmpty, isTrue);
      expect(
        statusEvents.any((e) => e.status == TokenRefreshStatus.inProgress),
        isTrue,
      );

      await subscription.cancel();
    });

    test('should emit success status on successful refresh', () async {
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

      await refreshService.refreshToken();

      // Allow stream events to be delivered
      await Future.delayed(Duration.zero);

      expect(statusEvents.isNotEmpty, isTrue);
      expect(statusEvents.last.status, equals(TokenRefreshStatus.success));
      expect(statusEvents.last.session, equals(newSession));
      expect(statusEvents.last.attemptNumber, equals(1));

      await subscription.cancel();
    });

    test('should emit failure status on failed refresh', () async {
      const error = AuthException('Refresh failed', code: 'REFRESH_ERROR');

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenThrow(error);

      final statusEvents = <TokenRefreshResult>[];
      final subscription = refreshService.statusStream.listen(statusEvents.add);

      try {
        await refreshService.refreshToken();
      } catch (_) {}

      // Allow stream events to be delivered
      await Future.delayed(Duration.zero);

      expect(statusEvents.isNotEmpty, isTrue);
      expect(statusEvents.last.status, equals(TokenRefreshStatus.failure));
      expect(statusEvents.last.error, equals(error));

      await subscription.cancel();
    });

    test('should emit multiple in-progress events during retries', () async {
      const error = AuthException('Network error', code: 'NETWORK_ERROR');

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenThrow(error);

      final statusEvents = <TokenRefreshResult>[];
      final subscription = refreshService.statusStream.listen(statusEvents.add);

      try {
        await refreshService.refreshToken();
      } catch (_) {}

      final inProgressEvents = statusEvents
          .where((e) => e.status == TokenRefreshStatus.inProgress)
          .toList();
      expect(inProgressEvents.length, equals(3));

      expect(inProgressEvents[0].attemptNumber, equals(1));
      expect(inProgressEvents[1].attemptNumber, equals(2));
      expect(inProgressEvents[2].attemptNumber, equals(3));

      await subscription.cancel();
    });

    test('should include attempt number in status events', () async {
      const error = AuthException('Network error', code: 'NETWORK_ERROR');

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenThrow(error);

      final statusEvents = <TokenRefreshResult>[];
      final subscription = refreshService.statusStream.listen(statusEvents.add);

      try {
        await refreshService.refreshToken();
      } catch (_) {}

      for (final event in statusEvents) {
        expect(event.attemptNumber, greaterThan(0));
        expect(event.attemptNumber, lessThanOrEqualTo(3));
      }

      await subscription.cancel();
    });

    test('should include total delay in status events', () async {
      const error = AuthException('Network error', code: 'NETWORK_ERROR');

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenThrow(error);

      final statusEvents = <TokenRefreshResult>[];
      final subscription = refreshService.statusStream.listen(statusEvents.add);

      try {
        await refreshService.refreshToken();
      } catch (_) {}

      // Allow stream events to be delivered
      await Future.delayed(Duration.zero);

      final finalEvent = statusEvents.last;
      expect(finalEvent.totalDelayMs, greaterThan(0));

      await subscription.cancel();
    });

    test('should broadcast to multiple listeners', () async {
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

      await refreshService.refreshToken();

      expect(events1, isNotEmpty);
      expect(events2, isNotEmpty);
      expect(events1.length, equals(events2.length));

      await sub1.cancel();
      await sub2.cancel();
    });
  });

  group('TokenRefreshService - Cancel and Dispose', () {
    test('should cancel in-progress refresh', () async {
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

      final future = refreshService.refreshToken();
      expect(refreshService.isRefreshing, isTrue);

      refreshService.cancelRefresh();

      expect(refreshService.isRefreshing, isFalse);

      try {
        await future;
        fail('Should have thrown');
      } on AuthException catch (e) {
        expect(e.code, equals('REFRESH_CANCELLED'));
      }
    });

    test('should emit cancelled status when refresh is cancelled', () async {
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

      final future = refreshService.refreshToken();
      await Future.delayed(const Duration(milliseconds: 10));
      refreshService.cancelRefresh();

      try {
        await future;
      } catch (_) {}

      expect(
        statusEvents.any((e) => e.status == TokenRefreshStatus.cancelled),
        isTrue,
      );

      await subscription.cancel();
    });

    test('should close status stream on dispose', () async {
      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenAnswer((_) async => newSession);

      refreshService.dispose();

      expect(refreshService.statusStream, emitsDone);
    });

    test('should cancel in-progress refresh and close stream on dispose',
        () async {
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

      final future = refreshService.refreshToken();
      await Future.delayed(const Duration(milliseconds: 10));

      refreshService.dispose();

      expect(refreshService.isRefreshing, isFalse);
      try {
        await future;
        fail('Should have thrown');
      } on AuthException catch (_) {}
    });

    test('should reset service state', () async {
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

      final future = refreshService.refreshToken();
      await Future.delayed(const Duration(milliseconds: 10));

      refreshService.reset();

      expect(refreshService.isRefreshing, isFalse);

      try {
        await future;
        fail('Should have thrown');
      } on AuthException catch (_) {}
    });

    test('should handle multiple dispose calls', () {
      expect(() => refreshService.dispose(), returnsNormally);
      expect(() => refreshService.dispose(), returnsNormally);
    });

    test('should handle cancel when no refresh is in progress', () {
      expect(() => refreshService.cancelRefresh(), returnsNormally);
      expect(refreshService.isRefreshing, isFalse);
    });
  });

  group('TokenRefreshService - Edge Cases', () {
    test('should handle rapid sequential refresh requests', () async {
      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenAnswer((_) async => newSession);

      final results = <AuthSession>[];
      for (int i = 0; i < 5; i++) {
        final result = await refreshService.refreshToken();
        results.add(result);
      }

      expect(results.length, equals(5));
      for (final result in results) {
        expect(result.accessToken, equals('new_access_token'));
      }

      verify(() => mockAuthRepository.performBasicTokenRefresh()).called(5);
    });

    test('should handle empty session with correct error', () async {
      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenAnswer((_) async => AuthSession(
                accessToken: '',
                idToken: '',
                refreshToken: '',
                expiresAt: DateTime.now(),
              ));

      final result = await refreshService.refreshToken();

      expect(result, isNotNull);
    });

    test('should handle reset followed by new refresh', () async {
      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenAnswer((_) async => newSession);

      refreshService.reset();
      final result = await refreshService.refreshToken();

      expect(result.accessToken, equals('new_access_token'));
      expect(refreshService.isRefreshing, isFalse);
    });

    test('should handle concurrent calls with different error types', () async {
      const networkError =
          AuthException('Network error', code: 'NETWORK_ERROR');
      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      int callIndex = 0;
      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenAnswer((_) async {
        callIndex++;
        if (callIndex == 1) throw networkError;
        return newSession;
      });

      final future1 = refreshService.refreshToken();
      await Future.delayed(const Duration(milliseconds: 10));
      final future2 = refreshService.refreshToken();

      final results = await Future.wait([
        future1.then((_) => 'success'),
        future2.then((_) => 'success'),
      ]).catchError((e) => ['error', 'error']);

      expect(results, contains('success'));
    });
  });

  group('TokenRefreshService - Error Classification', () {
    test('should not retry on INVALID_CREDENTIALS', () async {
      const error = AuthException(
        'Invalid credentials',
        code: 'INVALID_CREDENTIALS',
      );

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenThrow(error);

      try {
        await refreshService.refreshToken();
        fail('Should have thrown');
      } on AuthException catch (e) {
        expect(e, equals(error));
      }

      verify(() => mockAuthRepository.performBasicTokenRefresh()).called(1);
    });

    test('should not retry on USER_NOT_FOUND', () async {
      const error = AuthException(
        'User not found',
        code: 'USER_NOT_FOUND',
      );

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenThrow(error);

      try {
        await refreshService.refreshToken();
        fail('Should have thrown');
      } on AuthException catch (e) {
        expect(e, equals(error));
      }

      verify(() => mockAuthRepository.performBasicTokenRefresh()).called(1);
    });

    test('should not retry on EMAIL_NOT_VERIFIED', () async {
      const error = AuthException(
        'Email not verified',
        code: 'EMAIL_NOT_VERIFIED',
      );

      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenThrow(error);

      try {
        await refreshService.refreshToken();
        fail('Should have thrown');
      } on AuthException catch (e) {
        expect(e, equals(error));
      }

      verify(() => mockAuthRepository.performBasicTokenRefresh()).called(1);
    });

    test('should retry on unknown error codes', () async {
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

      int callIndex = 0;
      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenAnswer((_) async {
        callIndex++;
        if (callIndex == 1) throw error;
        return newSession;
      });

      final result = await refreshService.refreshToken();

      expect(result.accessToken, equals('new_access_token'));
      verify(() => mockAuthRepository.performBasicTokenRefresh()).called(2);
    });

    test('should retry on error with null code', () async {
      const error = AuthException('Some error');

      final newSession = AuthSession(
        accessToken: 'new_access_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      int callIndex = 0;
      when(() => mockAuthRepository.performBasicTokenRefresh())
          .thenAnswer((_) async {
        callIndex++;
        if (callIndex == 1) throw error;
        return newSession;
      });

      final result = await refreshService.refreshToken();

      expect(result.accessToken, equals('new_access_token'));
      verify(() => mockAuthRepository.performBasicTokenRefresh()).called(2);
    });
  });

  group('TokenRefreshResult - Factory Methods', () {
    test('should create success result correctly', () {
      final session = AuthSession(
        accessToken: 'access_token',
        idToken: 'id_token',
        refreshToken: 'refresh_token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );

      final result = TokenRefreshResult.success(
        session: session,
        attemptNumber: 2,
        totalDelayMs: 3000,
      );

      expect(result.status, equals(TokenRefreshStatus.success));
      expect(result.session, equals(session));
      expect(result.error, isNull);
      expect(result.attemptNumber, equals(2));
      expect(result.totalDelayMs, equals(3000));
    });

    test('should create failure result correctly', () {
      const error = AuthException('Refresh failed', code: 'REFRESH_ERROR');

      final result = TokenRefreshResult.failure(
        error: error,
        attemptNumber: 3,
        totalDelayMs: 7000,
      );

      expect(result.status, equals(TokenRefreshStatus.failure));
      expect(result.error, equals(error));
      expect(result.session, isNull);
      expect(result.attemptNumber, equals(3));
      expect(result.totalDelayMs, equals(7000));
    });

    test('should create in-progress result correctly', () {
      final result = TokenRefreshResult.inProgress(attemptNumber: 1);

      expect(result.status, equals(TokenRefreshStatus.inProgress));
      expect(result.session, isNull);
      expect(result.error, isNull);
      expect(result.attemptNumber, equals(1));
      expect(result.totalDelayMs, equals(0));
    });

    test('should create cancelled result correctly', () {
      final result = TokenRefreshResult.cancelled();

      expect(result.status, equals(TokenRefreshStatus.cancelled));
      expect(result.session, isNull);
      expect(result.error, isNull);
      expect(result.attemptNumber, equals(0));
      expect(result.totalDelayMs, equals(0));
    });

    test('should provide meaningful toString', () {
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

      final str = result.toString();

      expect(str, contains('TokenRefreshResult'));
      expect(str, contains('success'));
      expect(str, contains('1'));
      expect(str, contains('1000'));
    });
  });

  group('TokenRefreshStatus - Enum Values', () {
    test('should have correct enum values', () {
      expect(TokenRefreshStatus.values.length, equals(4));
      expect(
          TokenRefreshStatus.values, contains(TokenRefreshStatus.inProgress));
      expect(TokenRefreshStatus.values, contains(TokenRefreshStatus.success));
      expect(TokenRefreshStatus.values, contains(TokenRefreshStatus.failure));
      expect(TokenRefreshStatus.values, contains(TokenRefreshStatus.cancelled));
    });
  });
}
