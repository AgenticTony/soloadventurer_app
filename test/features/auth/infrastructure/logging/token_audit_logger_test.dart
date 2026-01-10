import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/features/auth/infrastructure/logging/token_audit_logger.dart';
import 'package:soloadventurer/features/core/infrastructure/monitoring/aws_cloudwatch_monitoring.dart';

class MockAwsCloudWatchMonitoring extends Mock
    implements AwsCloudWatchMonitoring {}

void main() {
  late ProviderContainer container;
  late MockAwsCloudWatchMonitoring mockMonitoring;

  setUp(() {
    mockMonitoring = MockAwsCloudWatchMonitoring();
    container = ProviderContainer(
      overrides: [
        awsCloudWatchMonitoringProvider.overrideWithValue(mockMonitoring),
      ],
    );

    // Register fallback values for non-nullable parameters
    registerFallbackValue({});
  });

  tearDown(() {
    container.dispose();
  });

  group('TokenAuditLogger - Event Logging', () {
    test('should log token events with metadata', () {
      final logger = container.read(tokenAuditLoggerProvider);

      when(() => mockMonitoring.recordEvent(
            any(),
            attributes: any(named: 'attributes'),
          )).thenAnswer((_) async {});

      logger.logTokenEvent(
        event: 'test_event',
        status: 'success',
        metadata: {'test_key': 'test_value'},
      );

      verify(() => mockMonitoring.recordEvent(
            'TokenOperation',
            attributes: any(named: 'attributes'),
          )).called(1);
    });

    test('should log token rotation events', () {
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

      when(() => mockMonitoring.recordEvent(
            any(),
            attributes: any(named: 'attributes'),
          )).thenAnswer((_) async {});

      (logger as dynamic).logTokenRotation(
        oldSession: oldSession,
        newSession: newSession,
        reason: 'test_rotation',
      );

      verify(() => mockMonitoring.recordEvent(
            'TokenOperation',
            attributes: any(named: 'attributes'),
          )).called(1);
    });

    test('should log token blacklist events', () {
      final logger = container.read(tokenAuditLoggerProvider);

      when(() => mockMonitoring.recordEvent(
            any(),
            attributes: any(named: 'attributes'),
          )).thenAnswer((_) async {});

      (logger as dynamic).logTokenBlacklist(
        token: 'test_token',
        reason: 'test_blacklist',
        expiryTime: DateTime.now(),
      );

      verify(() => mockMonitoring.recordEvent(
            'TokenOperation',
            attributes: any(named: 'attributes'),
          )).called(1);
    });

    test('should log token validation events', () {
      final logger = container.read(tokenAuditLoggerProvider);

      when(() => mockMonitoring.recordEvent(
            any(),
            attributes: any(named: 'attributes'),
          )).thenAnswer((_) async {});

      (logger as dynamic).logTokenValidation(
        isValid: true,
        reason: 'test_validation',
        additionalInfo: {'test_key': 'test_value'},
      );

      verify(() => mockMonitoring.recordEvent(
            'TokenOperation',
            attributes: any(named: 'attributes'),
          )).called(1);
    });
  });

  group('TokenAuditLogger - CloudWatch Integration', () {
    test('should record metrics for high-severity security events', () {
      final logger = container.read(tokenAuditLoggerProvider);

      when(() => mockMonitoring.recordEvent(
            any(),
            attributes: any(named: 'attributes'),
          )).thenAnswer((_) async {});

      when(() => mockMonitoring.recordMetric(
            any(),
            any(),
            dimensions: any(named: 'dimensions'),
          )).thenAnswer((_) async {});

      (logger as dynamic).logTokenSecurity(
        event: 'test_security_event',
        severity: 'high',
        threat: 'test_threat',
        securityContext: {'test_key': 'test_value'},
      );

      verify(() => mockMonitoring.recordEvent(
            'TokenOperation',
            attributes: any(named: 'attributes'),
          )).called(1);

      verify(() => mockMonitoring.recordMetric(
            'SecurityEvent',
            1.0,
            dimensions: any(named: 'dimensions'),
          )).called(1);
    });

    test('should not record metrics for low-severity security events', () {
      final logger = container.read(tokenAuditLoggerProvider);

      when(() => mockMonitoring.recordEvent(
            any(),
            attributes: any(named: 'attributes'),
          )).thenAnswer((_) async {});

      (logger as dynamic).logTokenSecurity(
        event: 'test_security_event',
        severity: 'low',
        threat: 'test_threat',
        securityContext: {'test_key': 'test_value'},
      );

      verify(() => mockMonitoring.recordEvent(
            'TokenOperation',
            attributes: any(named: 'attributes'),
          )).called(1);

      verifyNever(() => mockMonitoring.recordMetric(
            any(),
            any(),
            dimensions: any(named: 'dimensions'),
          ));
    });
  });

  group('TokenAuditLogger - Error Handling', () {
    test('should log errors with stack traces', () {
      final logger = container.read(tokenAuditLoggerProvider);

      when(() => mockMonitoring.recordEvent(
            any(),
            attributes: any(named: 'attributes'),
          )).thenAnswer((_) async {});

      when(() => mockMonitoring.recordMetric(
            any(),
            any(),
            dimensions: any(named: 'dimensions'),
          )).thenAnswer((_) async {});

      logger.logError(
        feature: 'test_feature',
        error: 'test_error',
        code: 'test_code',
        metadata: {'test_key': 'test_value'},
        stackTrace: StackTrace.current,
      );

      verify(() => mockMonitoring.recordEvent(
            'TokenOperation',
            attributes: any(named: 'attributes'),
          )).called(1);

      verify(() => mockMonitoring.recordMetric(
            'TokenError',
            1.0,
            dimensions: any(named: 'dimensions'),
          )).called(1);
    });

    test('should handle missing optional parameters', () {
      final logger = container.read(tokenAuditLoggerProvider);

      when(() => mockMonitoring.recordEvent(
            any(),
            attributes: any(named: 'attributes'),
          )).thenAnswer((_) async {});

      when(() => mockMonitoring.recordMetric(
            any(),
            any(),
            dimensions: any(named: 'dimensions'),
          )).thenAnswer((_) async {});

      logger.logError(
        feature: 'test_feature',
        error: 'test_error',
      );

      verify(() => mockMonitoring.recordEvent(
            'TokenOperation',
            attributes: any(named: 'attributes'),
          )).called(1);

      verify(() => mockMonitoring.recordMetric(
            'TokenError',
            1.0,
            dimensions: any(named: 'dimensions'),
          )).called(1);
    });
  });

  group('TokenAuditLogger - State Transitions', () {
    test('should log state transitions with metadata', () {
      final logger = container.read(tokenAuditLoggerProvider);

      when(() => mockMonitoring.recordEvent(
            any(),
            attributes: any(named: 'attributes'),
          )).thenAnswer((_) async {});

      logger.logStateTransition(
        feature: 'test_feature',
        fromState: 'old_state',
        toState: 'new_state',
        metadata: {'test_key': 'test_value'},
        stackTrace: StackTrace.current,
      );

      verify(() => mockMonitoring.recordEvent(
            'TokenOperation',
            attributes: any(named: 'attributes'),
          )).called(1);
    });
  });

  group('TokenAuditLogger - Auth Events', () {
    test('should log auth events with metadata', () {
      final logger = container.read(tokenAuditLoggerProvider);

      when(() => mockMonitoring.recordEvent(
            any(),
            attributes: any(named: 'attributes'),
          )).thenAnswer((_) async {});

      logger.logAuthEvent(
        event: 'test_auth_event',
        status: 'success',
        metadata: {'test_key': 'test_value'},
        stackTrace: StackTrace.current,
      );

      verify(() => mockMonitoring.recordEvent(
            'TokenOperation',
            attributes: any(named: 'attributes'),
          )).called(1);
    });
  });
}
