import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_error.dart';

void main() {
  group('SyncError', () {
    group('Constructor and Factory', () {
      test('should create a SyncError with required fields', () {
        final error = SyncError(
          errorId: 'error_123',
          type: SyncErrorType.network,
          severity: SyncErrorSeverity.medium,
          technicalMessage: 'Connection failed',
          userMessage: 'Network issue',
          suggestion: 'Check connection',
          occurredAt: DateTime.now(),
        );

        expect(error.errorId, 'error_123');
        expect(error.type, SyncErrorType.network);
        expect(error.severity, SyncErrorSeverity.medium);
        expect(error.technicalMessage, 'Connection failed');
        expect(error.userMessage, 'Network issue');
        expect(error.suggestion, 'Check connection');
      });

      test('should create SyncError from Exception with network error', () {
        final exception = Exception('SocketException: Connection refused');
        final error = SyncError.fromException(
          exception: exception,
          entityType: 'trip',
          entityId: 'trip_123',
          operationType: 'update',
        );

        expect(error.type, SyncErrorType.network);
        expect(error.severity, SyncErrorSeverity.medium);
        expect(error.entityType, 'trip');
        expect(error.entityId, 'trip_123');
        expect(error.operationType, 'update');
        expect(error.isRetryable, true);
      });

      test('should create SyncError from Exception with timeout', () {
        final exception = Exception('TimeoutException after 30 seconds');
        final error = SyncError.fromException(exception: exception);

        expect(error.type, SyncErrorType.timeout);
        expect(error.severity, SyncErrorSeverity.low);
        expect(error.isRetryable, true);
      });

      test('should create SyncError from Exception with 401', () {
        final exception = Exception('UnauthorizedException: 401');
        final error = SyncError.fromException(exception: exception);

        expect(error.type, SyncErrorType.authentication);
        expect(error.severity, SyncErrorSeverity.high);
        expect(error.statusCode, 401);
        expect(error.isRetryable, false);
      });

      test('should create SyncError from Exception with 403', () {
        final exception = Exception('ForbiddenException: 403');
        final error = SyncError.fromException(exception: exception);

        expect(error.type, SyncErrorType.authentication);
        expect(error.severity, SyncErrorSeverity.high);
        expect(error.statusCode, 403);
        expect(error.isRetryable, false);
      });

      test('should create SyncError from Exception with 404', () {
        final exception = Exception('NotFoundException: 404');
        final error = SyncError.fromException(exception: exception);

        expect(error.type, SyncErrorType.notFound);
        expect(error.severity, SyncErrorSeverity.high);
        expect(error.statusCode, 404);
        expect(error.isRetryable, false);
      });

      test('should create SyncError from Exception with 409', () {
        final exception = Exception('ConflictException: 409');
        final error = SyncError.fromException(exception: exception);

        expect(error.type, SyncErrorType.conflict);
        expect(error.severity, SyncErrorSeverity.medium);
        expect(error.statusCode, 409);
        expect(error.isRetryable, false);
      });

      test('should create SyncError from Exception with 422', () {
        final exception = Exception('ValidationException: 422');
        final error = SyncError.fromException(exception: exception);

        expect(error.type, SyncErrorType.validation);
        expect(error.severity, SyncErrorSeverity.high);
        expect(error.statusCode, 422);
        expect(error.isRetryable, false);
      });

      test('should create SyncError from Exception with 429', () {
        final exception = Exception('RateLimitedException: 429');
        final error = SyncError.fromException(exception: exception);

        expect(error.type, SyncErrorType.rateLimited);
        expect(error.severity, SyncErrorSeverity.medium);
        expect(error.statusCode, 429);
        expect(error.isRetryable, true);
      });

      test('should create SyncError from Exception with 507', () {
        final exception = Exception('QuotaExceededException: 507');
        final error = SyncError.fromException(exception: exception);

        expect(error.type, SyncErrorType.quotaExceeded);
        expect(error.severity, SyncErrorSeverity.high);
        expect(error.isRetryable, false);
      });

      test('should create SyncError from Exception with 500', () {
        final exception = Exception('ServerException: 500');
        final error = SyncError.fromException(exception: exception);

        expect(error.type, SyncErrorType.server);
        expect(error.severity, SyncErrorSeverity.medium);
        expect(error.isRetryable, true);
      });

      test('should create SyncError from Exception with unknown error', () {
        final exception = Exception('Unknown error occurred');
        final error = SyncError.fromException(exception: exception);

        expect(error.type, SyncErrorType.unknown);
        expect(error.severity, SyncErrorSeverity.medium);
        expect(error.isRetryable, true);
      });
    });

    group('Computed Properties', () {
      test('should calculate age correctly', () {
        final occurredAt = DateTime.now().subtract(const Duration(minutes: 5));
        final error = SyncError(
          errorId: 'error_123',
          type: SyncErrorType.network,
          severity: SyncErrorSeverity.medium,
          technicalMessage: 'Error',
          userMessage: 'Error',
          suggestion: 'Fix',
          occurredAt: occurredAt,
        );

        expect(error.age.inMinutes, greaterThanOrEqualTo(5));
        expect(error.age.inMinutes, lessThan(6));
      });

      test('shouldNotify should be true for high severity', () {
        final error = SyncError(
          errorId: 'error_123',
          type: SyncErrorType.authentication,
          severity: SyncErrorSeverity.high,
          technicalMessage: 'Error',
          userMessage: 'Error',
          suggestion: 'Fix',
          occurredAt: DateTime.now(),
        );

        expect(error.shouldNotify, true);
      });

      test('shouldNotify should be false for medium severity', () {
        final error = SyncError(
          errorId: 'error_123',
          type: SyncErrorType.network,
          severity: SyncErrorSeverity.medium,
          technicalMessage: 'Error',
          userMessage: 'Error',
          suggestion: 'Fix',
          occurredAt: DateTime.now(),
        );

        expect(error.shouldNotify, false);
      });

      test('shouldNotify should be false for low severity', () {
        final error = SyncError(
          errorId: 'error_123',
          type: SyncErrorType.timeout,
          severity: SyncErrorSeverity.low,
          technicalMessage: 'Error',
          userMessage: 'Error',
          suggestion: 'Fix',
          occurredAt: DateTime.now(),
        );

        expect(error.shouldNotify, false);
      });
    });

    group('copyWith', () {
      test('should create a copy with updated fields', () {
        final original = SyncError(
          errorId: 'error_123',
          type: SyncErrorType.network,
          severity: SyncErrorSeverity.medium,
          technicalMessage: 'Original',
          userMessage: 'Original',
          suggestion: 'Original',
          occurredAt: DateTime.now(),
        );

        final copy = original.copyWith(
          retryCount: 5,
          severity: SyncErrorSeverity.high,
        );

        expect(copy.errorId, original.errorId);
        expect(copy.type, original.type);
        expect(copy.severity, SyncErrorSeverity.high);
        expect(copy.retryCount, 5);
        expect(copy.technicalMessage, original.technicalMessage);
      });

      test('should create a copy with all fields updated', () {
        final original = SyncError(
          errorId: 'error_123',
          type: SyncErrorType.network,
          severity: SyncErrorSeverity.medium,
          technicalMessage: 'Original',
          userMessage: 'Original',
          suggestion: 'Original',
          occurredAt: DateTime.now(),
        );

        final newTime = DateTime.now();
        final copy = original.copyWith(
          errorId: 'error_456',
          type: SyncErrorType.server,
          severity: SyncErrorSeverity.high,
          technicalMessage: 'Updated',
          userMessage: 'Updated',
          suggestion: 'Updated',
          retryCount: 3,
          isRetryable: false,
          occurredAt: newTime,
        );

        expect(copy.errorId, 'error_456');
        expect(copy.type, SyncErrorType.server);
        expect(copy.severity, SyncErrorSeverity.high);
        expect(copy.technicalMessage, 'Updated');
        expect(copy.retryCount, 3);
        expect(copy.isRetryable, false);
        expect(copy.occurredAt, newTime);
      });
    });

    group('JSON Serialization', () {
      test('should serialize to JSON correctly', () {
        final occurredAt = DateTime.utc(2024, 1, 15, 10, 30);
        final error = SyncError(
          errorId: 'error_123',
          type: SyncErrorType.network,
          severity: SyncErrorSeverity.medium,
          code: 'ERR_001',
          technicalMessage: 'Connection failed',
          userMessage: 'Network issue',
          suggestion: 'Check connection',
          statusCode: 500,
          entityType: 'trip',
          entityId: 'trip_123',
          operationType: 'update',
          retryCount: 2,
          isRetryable: true,
          occurredAt: occurredAt,
          details: const {'key': 'value'},
        );

        final json = error.toJson();

        expect(json['errorId'], 'error_123');
        expect(json['type'], 'network');
        expect(json['severity'], 'medium');
        expect(json['code'], 'ERR_001');
        expect(json['technicalMessage'], 'Connection failed');
        expect(json['userMessage'], 'Network issue');
        expect(json['suggestion'], 'Check connection');
        expect(json['statusCode'], 500);
        expect(json['entityType'], 'trip');
        expect(json['entityId'], 'trip_123');
        expect(json['operationType'], 'update');
        expect(json['retryCount'], 2);
        expect(json['isRetryable'], true);
        expect(json['occurredAt'], '2024-01-15T10:30:00.000Z');
        expect(json['details'], {'key': 'value'});
      });

      test('should deserialize from JSON correctly', () {
        final json = {
          'errorId': 'error_123',
          'type': 'network',
          'severity': 'medium',
          'code': 'ERR_001',
          'technicalMessage': 'Connection failed',
          'userMessage': 'Network issue',
          'suggestion': 'Check connection',
          'statusCode': 500,
          'entityType': 'trip',
          'entityId': 'trip_123',
          'operationType': 'update',
          'retryCount': 2,
          'isRetryable': true,
          'occurredAt': '2024-01-15T10:30:00.000Z',
          'details': {'key': 'value'},
        };

        final error = SyncError.fromJson(json);

        expect(error.errorId, 'error_123');
        expect(error.type, SyncErrorType.network);
        expect(error.severity, SyncErrorSeverity.medium);
        expect(error.code, 'ERR_001');
        expect(error.technicalMessage, 'Connection failed');
        expect(error.userMessage, 'Network issue');
        expect(error.suggestion, 'Check connection');
        expect(error.statusCode, 500);
        expect(error.entityType, 'trip');
        expect(error.entityId, 'trip_123');
        expect(error.operationType, 'update');
        expect(error.retryCount, 2);
        expect(error.isRetryable, true);
        expect(error.occurredAt, DateTime.utc(2024, 1, 15, 10, 30));
        expect(error.details, {'key': 'value'});
      });

      test('should round-trip through JSON', () {
        final original = SyncError(
          errorId: 'error_123',
          type: SyncErrorType.conflict,
          severity: SyncErrorSeverity.high,
          technicalMessage: 'Conflict detected',
          userMessage: 'User message',
          suggestion: 'Suggestion',
          statusCode: 409,
          entityType: 'travelNote',
          entityId: 'note_456',
          operationType: 'delete',
          retryCount: 1,
          isRetryable: false,
          occurredAt: DateTime.now(),
          details: const {'field': 'value'},
        );

        final json = original.toJson();
        final restored = SyncError.fromJson(json);

        expect(restored.errorId, original.errorId);
        expect(restored.type, original.type);
        expect(restored.severity, original.severity);
        expect(restored.technicalMessage, original.technicalMessage);
        expect(restored.userMessage, original.userMessage);
        expect(restored.suggestion, original.suggestion);
        expect(restored.statusCode, original.statusCode);
        expect(restored.entityType, original.entityType);
        expect(restored.entityId, original.entityId);
        expect(restored.operationType, original.operationType);
        expect(restored.retryCount, original.retryCount);
        expect(restored.isRetryable, original.isRetryable);
        expect(restored.occurredAt, original.occurredAt);
        expect(restored.details, original.details);
      });
    });

    group('toString', () {
      test('should include key information', () {
        final error = SyncError(
          errorId: 'error_123',
          type: SyncErrorType.network,
          severity: SyncErrorSeverity.medium,
          technicalMessage: 'Error',
          userMessage: 'User message',
          suggestion: 'Suggestion',
          occurredAt: DateTime.now(),
        );

        final str = error.toString();

        expect(str, contains('error_123'));
        expect(str, contains('SyncErrorType.network'));
        expect(str, contains('SyncErrorSeverity.medium'));
        expect(str, contains('User message'));
      });
    });
  });

  group('SyncErrorType', () {
    test('should have all expected values', () {
      expect(SyncErrorType.values.length, greaterThan(0));
      expect(SyncErrorType.values.contains(SyncErrorType.network), true);
      expect(SyncErrorType.values.contains(SyncErrorType.authentication), true);
      expect(SyncErrorType.values.contains(SyncErrorType.server), true);
      expect(SyncErrorType.values.contains(SyncErrorType.validation), true);
      expect(SyncErrorType.values.contains(SyncErrorType.conflict), true);
      expect(SyncErrorType.values.contains(SyncErrorType.timeout), true);
      expect(SyncErrorType.values.contains(SyncErrorType.notFound), true);
      expect(SyncErrorType.values.contains(SyncErrorType.rateLimited), true);
      expect(SyncErrorType.values.contains(SyncErrorType.quotaExceeded), true);
      expect(SyncErrorType.values.contains(SyncErrorType.unknown), true);
    });
  });

  group('SyncErrorSeverity', () {
    test('should have all expected values', () {
      expect(SyncErrorSeverity.values.length, 3);
      expect(SyncErrorSeverity.values.contains(SyncErrorSeverity.low), true);
      expect(SyncErrorSeverity.values.contains(SyncErrorSeverity.medium), true);
      expect(SyncErrorSeverity.values.contains(SyncErrorSeverity.high), true);
    });
  });

  group('SyncErrorResult', () {
    test('should create success result', () {
      final result = SyncErrorResult.success(
        successCount: 10,
        totalCount: 10,
      );

      expect(result.isSuccess, true);
      expect(result.error, null);
      expect(result.successCount, 10);
      expect(result.failureCount, 0);
      expect(result.totalCount, 10);
      expect(result.isPartial, false);
      expect(result.successRate, 100.0);
    });

    test('should create failure result', () {
      final error = SyncError(
        errorId: 'error_123',
        type: SyncErrorType.network,
        severity: SyncErrorSeverity.medium,
        technicalMessage: 'Error',
        userMessage: 'Error',
        suggestion: 'Fix',
        occurredAt: DateTime.now(),
      );

      final result = SyncErrorResult.failure(
        error: error,
        failureCount: 5,
        totalCount: 5,
      );

      expect(result.isSuccess, false);
      expect(result.error, error);
      expect(result.successCount, 0);
      expect(result.failureCount, 5);
      expect(result.totalCount, 5);
      expect(result.isPartial, false);
      expect(result.successRate, 0.0);
    });

    test('should create partial result', () {
      final error = SyncError(
        errorId: 'error_123',
        type: SyncErrorType.network,
        severity: SyncErrorSeverity.medium,
        technicalMessage: 'Error',
        userMessage: 'Error',
        suggestion: 'Fix',
        occurredAt: DateTime.now(),
      );

      final result = SyncErrorResult.partial(
        error: error,
        successCount: 7,
        failureCount: 3,
        totalCount: 10,
      );

      expect(result.isSuccess, false);
      expect(result.error, error);
      expect(result.successCount, 7);
      expect(result.failureCount, 3);
      expect(result.totalCount, 10);
      expect(result.isPartial, true);
      expect(result.successRate, 70.0);
    });

    test('should calculate success rate correctly', () {
      final result1 = SyncErrorResult.partial(
        error: SyncError(
          errorId: 'e',
          type: SyncErrorType.unknown,
          severity: SyncErrorSeverity.medium,
          technicalMessage: 'E',
          userMessage: 'U',
          suggestion: 'S',
          occurredAt: DateTime.now(),
        ),
        successCount: 3,
        failureCount: 2,
        totalCount: 5,
      );

      expect(result1.successRate, 60.0);

      final result2 = SyncErrorResult.partial(
        error: SyncError(
          errorId: 'e',
          type: SyncErrorType.unknown,
          severity: SyncErrorSeverity.medium,
          technicalMessage: 'E',
          userMessage: 'U',
          suggestion: 'S',
          occurredAt: DateTime.now(),
        ),
        successCount: 0,
        failureCount: 10,
        totalCount: 10,
      );

      expect(result2.successRate, 0.0);
    });

    test('should handle zero total count', () {
      final result = SyncErrorResult.success(
        successCount: 0,
        totalCount: 0,
      );

      expect(result.successRate, 0.0);
    });
  });
}
