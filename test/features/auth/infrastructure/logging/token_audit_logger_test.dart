import 'package:flutter_test/flutter_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/features/auth/infrastructure/logging/token_audit_logger.dart';
import 'package:soloadventurer/features/core/domain/services/logging_service.dart';

void main() {
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
  });

  tearDown(() {
    container.dispose();
  });

  group('TokenAuditLogger', () {
    test('should provide a LoggingService instance', () {
      final logger = container.read(tokenAuditLoggerProvider);
      expect(logger, isA<LoggingService>());
    });

    test('should log token events without throwing', () {
      final logger = container.read(tokenAuditLoggerProvider);

      // Should not throw
      expect(
        () => logger.logTokenEvent(
          event: 'test_event',
          status: 'success',
          metadata: {'test_key': 'test_value'},
        ),
        returnsNormally,
      );
    });

    test('should log errors without throwing', () {
      final logger = container.read(tokenAuditLoggerProvider);

      expect(
        () => logger.logError(
          feature: 'test_feature',
          error: 'test_error',
          code: 'test_code',
          metadata: {'test_key': 'test_value'},
        ),
        returnsNormally,
      );
    });

    test('should log state transitions without throwing', () {
      final logger = container.read(tokenAuditLoggerProvider);

      expect(
        () => logger.logStateTransition(
          feature: 'test_feature',
          fromState: 'old_state',
          toState: 'new_state',
          metadata: {'test_key': 'test_value'},
        ),
        returnsNormally,
      );
    });

    test('should log auth events without throwing', () {
      final logger = container.read(tokenAuditLoggerProvider);

      expect(
        () => logger.logAuthEvent(
          event: 'test_auth_event',
          status: 'success',
          metadata: {'test_key': 'test_value'},
        ),
        returnsNormally,
      );
    });

    test('should handle token rotation logging via dynamic calls', () {
      final logger = container.read(tokenAuditLoggerProvider);
      final now = DateTime.now();

      final oldSession = AuthSession(
        accessToken: 'old_token',
        idToken: 'old_id_token',
        refreshToken: 'old_refresh',
        expiresAt: now,
      );

      final newSession = AuthSession(
        accessToken: 'new_token',
        idToken: 'new_id_token',
        refreshToken: 'new_refresh',
        expiresAt: now.add(const Duration(hours: 1)),
      );

      // logTokenRotation may or may not exist on LoggingService - test dynamic call
      expect(
        () => (logger as dynamic).logTokenRotation(
          oldSession: oldSession,
          newSession: newSession,
          reason: 'test_rotation',
        ),
        returnsNormally,
      );
    });

    test('should handle token blacklist logging via dynamic calls', () {
      final logger = container.read(tokenAuditLoggerProvider);

      expect(
        () => (logger as dynamic).logTokenBlacklist(
          token: 'test_token',
          reason: 'test_blacklist',
          expiryTime: DateTime.now(),
        ),
        returnsNormally,
      );
    });
  });
}
