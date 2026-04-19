import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:riverpod/riverpod.dart';
import 'package:soloadventurer/core/storage/secure_storage.dart';
import 'package:soloadventurer/features/auth/infrastructure/security/suspicious_activity_detector.dart';
import 'package:soloadventurer/features/auth/infrastructure/logging/token_audit_logger.dart';
import 'package:soloadventurer/features/core/domain/services/logging_service.dart';

class MockLoggingService extends Mock implements LoggingService {}

class FakeSecureStorage extends Fake implements SecureStorage {
  final Map<String, String> _store = {};

  @override
  Future<void> delete(String key) async => _store.remove(key);

  @override
  Future<String?> read(String key) async => _store[key];

  @override
  Future<void> write(String key, String value) async => _store[key] = value;

  @override
  Future<void> deleteAll() async => _store.clear();

  @override
  Future<bool> containsKey(String key) async => _store.containsKey(key);
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late MockLoggingService mockLoggingService;

  setUp(() {
    mockLoggingService = MockLoggingService();

    when(() => mockLoggingService.logTokenEvent(
          event: any(named: 'event'),
          status: any(named: 'status'),
          metadata: any(named: 'metadata'),
          stackTrace: any(named: 'stackTrace'),
        )).thenReturn(null);

    container = ProviderContainer(
      overrides: [
        secureStorageProvider.overrideWithValue(FakeSecureStorage()),
        tokenAuditLoggerProvider.overrideWithValue(mockLoggingService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('SuspiciousActivityDetector', () {
    test('should be created from provider', () {
      final detector = container.read(suspiciousActivityDetectorProvider);
      expect(detector, isNotNull);
    });

    test('should detect suspicious login attempts', () {
      final detector = container.read(suspiciousActivityDetectorProvider);

      // Make enough login attempts to trigger detection
      for (var i = 0; i < 5; i++) {
        detector.detectSuspiciousLogins(
          userId: 'test-user',
          loginAttemptTime: DateTime.now(),
          location: 'location-$i',
          latitude: 0.0 + i,
          longitude: 0.0 + i,
        );
      }

      verify(() => mockLoggingService.logTokenEvent(
            event: any(named: 'event'),
            status: any(named: 'status'),
            metadata: any(named: 'metadata'),
          )).called(greaterThanOrEqualTo(1));
    });

    test('should detect suspicious token refresh patterns', () {
      final detector = container.read(suspiciousActivityDetectorProvider);

      for (var i = 0; i < 20; i++) {
        detector.detectSuspiciousTokenUsage(
          userId: 'test-user',
          tokenId: 'test-token',
          refreshTime: DateTime.now(),
        );
      }

      verify(() => mockLoggingService.logTokenEvent(
            event: any(named: 'event'),
            status: any(named: 'status'),
            metadata: any(named: 'metadata'),
          )).called(greaterThanOrEqualTo(1));
    });

    test('should detect suspicious API request rates', () {
      final detector = container.read(suspiciousActivityDetectorProvider);

      for (var i = 0; i < 300; i++) {
        detector.detectSuspiciousApiUsage(
          userId: 'test-user',
          endpoint: '/api/test',
          requestTime: DateTime.now(),
        );
      }

      verify(() => mockLoggingService.logTokenEvent(
            event: any(named: 'event'),
            status: any(named: 'status'),
            metadata: any(named: 'metadata'),
          )).called(greaterThanOrEqualTo(1));
    });

    test('should reset history for a user', () {
      final detector = container.read(suspiciousActivityDetectorProvider);

      // Should not throw
      expect(() => detector.resetHistory('test-user'), returnsNormally);
    });

    test('should reset token history', () {
      final detector = container.read(suspiciousActivityDetectorProvider);

      // Should not throw
      expect(() => detector.resetTokenHistory('test-token'), returnsNormally);
    });
  });
}
