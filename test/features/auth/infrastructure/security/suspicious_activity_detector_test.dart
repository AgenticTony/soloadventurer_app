import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';
import 'package:soloadventurer/core/security/security_manager.dart';
import 'package:soloadventurer/features/auth/infrastructure/security/suspicious_activity_detector.dart';
import 'package:soloadventurer/features/core/domain/services/logging_service.dart';
import 'package:soloadventurer/features/core/infrastructure/monitoring/aws_cloudwatch_monitoring.dart';
import 'package:soloadventurer/features/auth/infrastructure/logging/token_audit_logger.dart';

class MockSecurityManager extends Mock implements SecurityManager {
  @override
  SecurityManager build() => this;
}

class MockLoggingService extends Mock implements LoggingService {}

class MockAwsCloudWatchMonitoring extends Mock
    implements AwsCloudWatchMonitoring {}

void main() {
  late ProviderContainer container;
  late MockSecurityManager mockSecurityManager;
  late MockLoggingService mockTokenAuditLogger;
  late MockAwsCloudWatchMonitoring mockMonitoring;
  late SuspiciousActivityDetector detector;

  setUp(() {
    mockSecurityManager = MockSecurityManager();
    mockTokenAuditLogger = MockLoggingService();
    mockMonitoring = MockAwsCloudWatchMonitoring();

    container = ProviderContainer(
      overrides: [
        securityManagerProvider.overrideWith(() => mockSecurityManager),
        tokenAuditLoggerProvider.overrideWithValue(mockTokenAuditLogger),
        awsCloudWatchMonitoringProvider.overrideWithValue(mockMonitoring),
      ],
    );

    // Initialize the detector
    detector = container.read(suspiciousActivityDetectorProvider.notifier);

    // Register fallback values
    registerFallbackValue({});
  });

  tearDown(() {
    container.dispose();
  });

  group('SuspiciousActivityDetector - Location Change Detection', () {
    test('should detect rapid location changes within time window', () {
      const userId = 'test_user';
      final now = DateTime.now();

      // Simulate multiple location changes
      for (var i = 0; i < 10; i++) {
        detector.detectSuspiciousLogins(
          userId: userId,
          location: 'Location_$i',
          latitude: i * 10.0,
          longitude: i * 10.0,
          loginAttemptTime: now.add(Duration(hours: i)),
        );
      }

      verify(() => mockTokenAuditLogger.logTokenEvent(
            event: 'rapid_location_changes',
            status: 'medium',
            metadata: any(named: 'metadata'),
          )).called(1);

      verify(() => mockMonitoring.recordMetric(
            'RapidLocationChanges',
            1.0,
            dimensions: any(named: 'dimensions'),
          )).called(1);
    });

    test('should detect impossible travel speeds', () {
      const userId = 'test_user';
      final now = DateTime.now();

      // First login from New York
      detector.detectSuspiciousLogins(
        userId: userId,
        location: 'New York',
        latitude: 40.7128,
        longitude: -74.0060,
        loginAttemptTime: now,
      );

      // Second login from Tokyo just 1 hour later (impossible travel speed)
      detector.detectSuspiciousLogins(
        userId: userId,
        location: 'Tokyo',
        latitude: 35.6762,
        longitude: 139.6503,
        loginAttemptTime: now.add(const Duration(hours: 1)),
      );

      verify(() => mockTokenAuditLogger.logTokenEvent(
            event: 'impossible_travel_detected',
            status: 'critical',
            metadata: any(named: 'metadata'),
          )).called(1);

      verify(() => mockSecurityManager.revokeAllTokens(userId)).called(1);
    });
  });

  group('SuspiciousActivityDetector - Token Usage Monitoring', () {
    test('should detect suspicious token refresh patterns', () {
      const userId = 'test_user';
      const tokenId = 'test_token';
      final now = DateTime.now();

      // Simulate multiple token refreshes within a short time
      for (var i = 0; i < 21; i++) {
        detector.detectSuspiciousTokenUsage(
          userId: userId,
          tokenId: tokenId,
          refreshTime: now.add(Duration(minutes: i * 2)),
        );
      }

      verify(() => mockTokenAuditLogger.logTokenEvent(
            event: 'suspicious_token_refreshes',
            status: 'high',
            metadata: any(named: 'metadata'),
          )).called(1);
    });

    test('should detect concurrent token usage', () {
      const userId = 'test_user';
      const tokenId = 'test_token';
      final now = DateTime.now();

      // Simulate concurrent usage from multiple devices
      for (var i = 0; i < 4; i++) {
        detector.detectSuspiciousTokenUsage(
          userId: userId,
          tokenId: tokenId,
          refreshTime: now,
        );
      }

      verify(() => mockTokenAuditLogger.logTokenEvent(
            event: 'concurrent_token_usage',
            status: 'high',
            metadata: any(named: 'metadata'),
          )).called(1);

      verify(() => mockMonitoring.recordMetric(
            'ConcurrentTokenUsage',
            1.0,
            dimensions: any(named: 'dimensions'),
          )).called(1);
    });
  });

  group('SuspiciousActivityDetector - API Usage Monitoring', () {
    test('should detect suspicious request rates', () {
      const userId = 'test_user';
      final now = DateTime.now();

      // Simulate high request rate
      for (var i = 0; i < 301; i++) {
        detector.detectSuspiciousApiUsage(
          userId: userId,
          endpoint: '/api/test',
          requestTime: now.add(Duration(seconds: i)),
        );
      }

      verify(() => mockTokenAuditLogger.logTokenEvent(
            event: 'suspicious_request_rate',
            status: 'high',
            metadata: any(named: 'metadata'),
          )).called(1);

      verify(() => mockSecurityManager.rateLimit(
            userId,
            any(),
          )).called(1);
    });

    test('should detect suspicious sensitive endpoint access', () {
      const userId = 'test_user';
      const sensitiveEndpoint = '/api/sensitive';
      final now = DateTime.now();

      when(() => mockSecurityManager.isSensitiveEndpoint(sensitiveEndpoint))
          .thenReturn(true);

      // Simulate multiple sensitive endpoint accesses
      for (var i = 0; i < 21; i++) {
        detector.detectSuspiciousApiUsage(
          userId: userId,
          endpoint: sensitiveEndpoint,
          requestTime: now.add(Duration(minutes: i * 2)),
        );
      }

      verify(() => mockTokenAuditLogger.logTokenEvent(
            event: 'suspicious_sensitive_endpoint_access',
            status: 'high',
            metadata: any(named: 'metadata'),
          )).called(1);

      verify(() => mockMonitoring.recordMetric(
            'HighSensitiveEndpointAccess',
            1.0,
            dimensions: any(named: 'dimensions'),
          )).called(1);
    });
  });

  group('SuspiciousActivityDetector - History Management', () {
    test('should reset user history correctly', () {
      const userId = 'test_user';
      final now = DateTime.now();

      // Add some history
      detector.detectSuspiciousLogins(
        userId: userId,
        location: 'Test Location',
        latitude: 0.0,
        longitude: 0.0,
        loginAttemptTime: now,
      );

      detector.detectSuspiciousApiUsage(
        userId: userId,
        endpoint: '/api/test',
        requestTime: now,
      );

      // Reset history
      detector.resetHistory(userId);

      // Verify history is reset by checking no events are triggered for new activities
      detector.detectSuspiciousLogins(
        userId: userId,
        location: 'New Location',
        latitude: 1.0,
        longitude: 1.0,
        loginAttemptTime: now.add(const Duration(minutes: 1)),
      );

      verifyNever(() => mockTokenAuditLogger.logTokenEvent(
            event: 'rapid_location_changes',
            status: any(named: 'status'),
            metadata: any(named: 'metadata'),
          ));
    });

    test('should reset token history correctly', () {
      const userId = 'test_user';
      const tokenId = 'test_token';
      final now = DateTime.now();

      // Add some token history
      for (var i = 0; i < 3; i++) {
        detector.detectSuspiciousTokenUsage(
          userId: userId,
          tokenId: tokenId,
          refreshTime: now.add(Duration(minutes: i)),
        );
      }

      // Reset token history
      detector.resetTokenHistory(tokenId);

      // Verify history is reset by checking no events are triggered for new activities
      detector.detectSuspiciousTokenUsage(
        userId: userId,
        tokenId: tokenId,
        refreshTime: now.add(const Duration(minutes: 10)),
      );

      verifyNever(() => mockTokenAuditLogger.logTokenEvent(
            event: 'concurrent_token_usage',
            status: any(named: 'status'),
            metadata: any(named: 'metadata'),
          ));
    });
  });
}
