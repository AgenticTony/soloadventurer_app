import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/sync/domain/entities/sync_entity_type.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_operation.dart';

void main() {
  group('SyncOperation - Retry Logic', () {
    late SyncOperation operation;

    setUp(() {
      operation = SyncOperation.create(
        id: 'test-op-1',
        entityType: SyncEntityType.trip,
        data: const {'name': 'Test Trip'},
      );
    });

    group('shouldRetry', () {
      test('should return true when retry count is below default max (5)', () {
        expect(operation.shouldRetry(), true); // 0 < 5
        expect(operation.copyWith(retryCount: 1).shouldRetry(), true); // 1 < 5
        expect(operation.copyWith(retryCount: 4).shouldRetry(), true); // 4 < 5
      });

      test('should return false when retry count reaches default max', () {
        expect(operation.copyWith(retryCount: 5).shouldRetry(),
            false); // 5 is not < 5
        expect(operation.copyWith(retryCount: 6).shouldRetry(),
            false); // 6 is not < 5
      });

      test('should respect custom max attempts', () {
        expect(operation.shouldRetry(3), true); // 0 < 3
        expect(operation.copyWith(retryCount: 1).shouldRetry(3), true); // 1 < 3
        expect(operation.copyWith(retryCount: 2).shouldRetry(3), true); // 2 < 3
        expect(operation.copyWith(retryCount: 3).shouldRetry(3),
            false); // 3 is not < 3
        expect(operation.copyWith(retryCount: 4).shouldRetry(3),
            false); // 4 is not < 3
      });

      test('should handle edge cases', () {
        // Max attempts of 0 means no retries
        expect(operation.shouldRetry(0), false);

        // Max attempts of 1 means 1 retry (original attempt)
        expect(operation.shouldRetry(1), false); // 0 is not < 1, so no retry
        expect(operation.copyWith(retryCount: 1).shouldRetry(1), false);
      });
    });

    group('isReadyForRetry', () {
      test('should return true when nextRetryAt is null', () {
        expect(operation.isReadyForRetry, true);
      });

      test('should return true when nextRetryAt is in the past', () {
        final pastTime = DateTime.now().subtract(const Duration(seconds: 10));
        final opWithPastRetry = operation.copyWith(nextRetryAt: pastTime);

        expect(opWithPastRetry.isReadyForRetry, true);
      });

      test('should return false when nextRetryAt is in the future', () {
        final futureTime = DateTime.now().add(const Duration(seconds: 10));
        final opWithFutureRetry = operation.copyWith(nextRetryAt: futureTime);

        expect(opWithFutureRetry.isReadyForRetry, false);
      });

      test('should handle edge case of exactly now', () {
        final now = DateTime.now();
        // Due to timing, this might be just before or after
        final op = operation.copyWith(nextRetryAt: now);

        // Should be true or very close to true
        expect(op.isReadyForRetry || op.timeUntilRetry!.inMilliseconds < 100,
            true);
      });
    });

    group('timeUntilRetry', () {
      test('should return null when nextRetryAt is null', () {
        expect(operation.timeUntilRetry, null);
      });

      test('should return Duration.zero when retry time has passed', () {
        final pastTime = DateTime.now().subtract(const Duration(seconds: 10));
        final opWithPastRetry = operation.copyWith(nextRetryAt: pastTime);

        expect(opWithPastRetry.timeUntilRetry, Duration.zero);
      });

      test('should return positive duration when retry time is in the future',
          () {
        final futureTime = DateTime.now().add(const Duration(seconds: 30));
        final opWithFutureRetry = operation.copyWith(nextRetryAt: futureTime);

        final remaining = opWithFutureRetry.timeUntilRetry;
        expect(remaining, isNotNull);
        expect(remaining!.inSeconds, greaterThanOrEqualTo(29));
        expect(remaining.inSeconds, lessThanOrEqualTo(31));
      });

      test('should be accurate for short delays', () {
        final futureTime =
            DateTime.now().add(const Duration(milliseconds: 500));
        final op = operation.copyWith(nextRetryAt: futureTime);

        final remaining = op.timeUntilRetry;
        expect(remaining, isNotNull);
        expect(remaining!.inMilliseconds, greaterThan(400));
        expect(remaining.inMilliseconds, lessThan(600));
      });

      test('should be accurate for long delays', () {
        final futureTime = DateTime.now().add(const Duration(minutes: 5));
        final op = operation.copyWith(nextRetryAt: futureTime);

        final remaining = op.timeUntilRetry;
        expect(remaining, isNotNull);
        expect(remaining!.inMinutes, greaterThanOrEqualTo(4));
        expect(remaining.inMinutes, lessThanOrEqualTo(6));
      });
    });

    group('copyWith with retry fields', () {
      test('should create operation with updated retry count', () {
        const newRetryCount = 3;
        final updated = operation.copyWith(retryCount: newRetryCount);

        expect(updated.retryCount, newRetryCount);
        expect(updated.id, operation.id);
        expect(updated.entityType, operation.entityType);
      });

      test('should create operation with updated nextRetryAt', () {
        final nextRetry = DateTime(2026, 1, 5, 14, 30);
        final updated = operation.copyWith(nextRetryAt: nextRetry);

        expect(updated.nextRetryAt, nextRetry);
        expect(updated.retryCount, operation.retryCount);
        expect(updated.id, operation.id);
      });

      test('should create operation with both retry fields updated', () {
        const newRetryCount = 2;
        final nextRetry = DateTime(2026, 1, 5, 14, 30);
        final updated = operation.copyWith(
          retryCount: newRetryCount,
          nextRetryAt: nextRetry,
        );

        expect(updated.retryCount, newRetryCount);
        expect(updated.nextRetryAt, nextRetry);
      });

      test('should preserve nextRetryAt when only updating retryCount', () {
        final nextRetry = DateTime(2026, 1, 5, 14, 30);
        final withNextRetry = operation.copyWith(nextRetryAt: nextRetry);

        final updated = withNextRetry.copyWith(retryCount: 2);

        expect(updated.retryCount, 2);
        expect(updated.nextRetryAt, nextRetry);
      });
    });

    group('JSON serialization with retry fields', () {
      test('should serialize nextRetryAt to JSON', () {
        final nextRetry = DateTime(2026, 1, 5, 14, 30, 0);
        final op = operation.copyWith(
          retryCount: 2,
          nextRetryAt: nextRetry,
        );

        final json = op.toJson();

        expect(json['retryCount'], 2);
        expect(json['nextRetryAt'], '2026-01-05T14:30:00.000');
      });

      test('should serialize null nextRetryAt to JSON', () {
        final json = operation.toJson();

        expect(json['retryCount'], 0);
        expect(json['nextRetryAt'], null);
      });

      test('should deserialize nextRetryAt from JSON', () {
        final json = {
          'id': 'test-op-1',
          'entityType': 'trip',
          'operationType': 'create',
          'entityId': null,
          'data': {'name': 'Test Trip'},
          'createdAt': '2026-01-05T12:00:00.000',
          'retryCount': 3,
          'nextRetryAt': '2026-01-05T14:30:00.000',
          'priority': 50,
          'canBatch': false,
          'batchId': null,
          'version': null,
        };

        final op = SyncOperation.fromJson(json);

        expect(op.retryCount, 3);
        expect(op.nextRetryAt, DateTime(2026, 1, 5, 14, 30, 0));
      });

      test('should deserialize null nextRetryAt from JSON', () {
        final json = {
          'id': 'test-op-1',
          'entityType': 'trip',
          'operationType': 'create',
          'entityId': null,
          'data': {'name': 'Test Trip'},
          'createdAt': '2026-01-05T12:00:00.000',
          'retryCount': 0,
          'nextRetryAt': null,
          'priority': 50,
          'canBatch': false,
          'batchId': null,
          'version': null,
        };

        final op = SyncOperation.fromJson(json);

        expect(op.retryCount, 0);
        expect(op.nextRetryAt, null);
      });

      test('should handle missing nextRetryAt in JSON', () {
        final json = {
          'id': 'test-op-1',
          'entityType': 'trip',
          'operationType': 'create',
          'entityId': null,
          'data': {'name': 'Test Trip'},
          'createdAt': '2026-01-05T12:00:00.000',
          'retryCount': 0,
          'priority': 50,
          'canBatch': false,
          'batchId': null,
          'version': null,
        };

        final op = SyncOperation.fromJson(json);

        expect(op.retryCount, 0);
        expect(op.nextRetryAt, null);
      });

      test('should round-trip through JSON serialization', () {
        final nextRetry = DateTime(2026, 1, 5, 14, 30, 0);
        final original = operation.copyWith(
          retryCount: 3,
          nextRetryAt: nextRetry,
        );

        final json = original.toJson();
        final restored = SyncOperation.fromJson(json);

        expect(restored.id, original.id);
        expect(restored.entityType, original.entityType);
        expect(restored.retryCount, original.retryCount);
        expect(restored.nextRetryAt, original.nextRetryAt);
        expect(restored.priority, original.priority);
      });
    });

    group('Equatable with retry fields', () {
      test('should consider operations equal with same retry fields', () {
        final nextRetry = DateTime(2026, 1, 5, 14, 30);
        final op1 = operation.copyWith(
          retryCount: 2,
          nextRetryAt: nextRetry,
        );
        final op2 = operation.copyWith(
          retryCount: 2,
          nextRetryAt: nextRetry,
        );

        expect(op1, equals(op2));
        expect(op1.hashCode, equals(op2.hashCode));
      });

      test('should consider operations different with different retry counts',
          () {
        final op1 = operation.copyWith(retryCount: 1);
        final op2 = operation.copyWith(retryCount: 2);

        expect(op1, isNot(equals(op2)));
      });

      test('should consider operations different with different nextRetryAt',
          () {
        final nextRetry1 = DateTime(2026, 1, 5, 14, 30);
        final nextRetry2 = DateTime(2026, 1, 5, 15, 30);
        final op1 = operation.copyWith(nextRetryAt: nextRetry1);
        final op2 = operation.copyWith(nextRetryAt: nextRetry2);

        expect(op1, isNot(equals(op2)));
      });

      test('should consider operations different when one has null nextRetryAt',
          () {
        final nextRetry = DateTime(2026, 1, 5, 14, 30);
        final op1 = operation.copyWith(nextRetryAt: nextRetry);
        final op2 = operation.copyWith(nextRetryAt: null);

        expect(op1, isNot(equals(op2)));
      });
    });

    group('toString with retry fields', () {
      test('should include retry count and nextRetryAt in toString', () {
        final nextRetry = DateTime(2026, 1, 5, 14, 30, 0);
        final op = operation.copyWith(
          retryCount: 3,
          nextRetryAt: nextRetry,
        );

        final str = op.toString();

        expect(str, contains('retryCount: 3'));
        expect(str, contains('nextRetryAt: $nextRetry'));
      });

      test('should show null for nextRetryAt when not set', () {
        final str = operation.toString();

        expect(str, contains('retryCount: 0'));
        expect(str, contains('nextRetryAt: null'));
      });
    });
  });
}
