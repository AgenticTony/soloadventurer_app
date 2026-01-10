import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_history_entry.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_status.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_error.dart';

void main() {
  group('SyncHistoryEntry', () {
    group('Factory Constructors', () {
      test('start() creates entry with syncing status', () {
        final now = DateTime.now();
        final entry = SyncHistoryEntry.start(
          id: 'test-id',
          isManual: true,
          connectionType: 'wifi',
        );

        expect(entry.id, 'test-id');
        expect(entry.status, SyncOperationStatus.syncing);
        expect(entry.isManual, isTrue);
        expect(entry.connectionType, 'wifi');
        expect(
            entry.startedAt.isAfter(now.subtract(const Duration(seconds: 1))),
            isTrue);
        expect(entry.completedAt, isNull);
        expect(entry.successCount, 0);
        expect(entry.failureCount, 0);
        expect(entry.totalCount, 0);
      });

      test('success() creates entry with success status', () {
        final startedAt = DateTime.now().subtract(const Duration(minutes: 5));
        final entry = SyncHistoryEntry.success(
          id: 'test-id',
          startedAt: startedAt,
          successCount: 10,
          failureCount: 2,
          totalCount: 12,
          isManual: false,
          connectionType: 'mobile',
        );

        expect(entry.id, 'test-id');
        expect(entry.status, SyncOperationStatus.success);
        expect(entry.isManual, isFalse);
        expect(entry.connectionType, 'mobile');
        expect(entry.startedAt, startedAt);
        expect(entry.completedAt, isNotNull);
        expect(entry.successCount, 10);
        expect(entry.failureCount, 2);
        expect(entry.totalCount, 12);
        expect(entry.duration, isNotNull);
      });

      test('failure() creates entry with failure status and error', () {
        final startedAt = DateTime.now().subtract(const Duration(minutes: 5));
        final error = SyncError(
          errorId: 'error-1',
          type: SyncErrorType.network,
          severity: SyncErrorSeverity.high,
          technicalMessage: 'Connection timeout',
          userMessage: 'Network error occurred',
          occurredAt: DateTime.now(),
        );

        final entry = SyncHistoryEntry.failure(
          id: 'test-id',
          startedAt: startedAt,
          successCount: 5,
          failureCount: 7,
          totalCount: 12,
          error: error,
          isManual: true,
        );

        expect(entry.id, 'test-id');
        expect(entry.status, SyncOperationStatus.failed);
        expect(entry.isManual, isTrue);
        expect(entry.startedAt, startedAt);
        expect(entry.completedAt, isNotNull);
        expect(entry.successCount, 5);
        expect(entry.failureCount, 7);
        expect(entry.totalCount, 12);
        expect(entry.error, error);
        expect(entry.duration, isNotNull);
      });
    });

    group('Computed Properties', () {
      test('duration returns null when completedAt is null', () {
        final entry = SyncHistoryEntry.start(id: 'test-id');
        expect(entry.duration, isNull);
      });

      test('duration returns correct duration when completedAt is set',
          () async {
        final startedAt = DateTime.now();
        await Future.delayed(const Duration(milliseconds: 100));
        final completedAt = DateTime.now();

        final entry = SyncHistoryEntry(
          id: 'test-id',
          status: SyncOperationStatus.success,
          startedAt: startedAt,
          completedAt: completedAt,
        );

        expect(entry.duration, isNotNull);
        expect(entry.duration!.inMilliseconds, greaterThan(90));
      });

      test('successRate returns null when totalCount is 0', () {
        final entry = SyncHistoryEntry.start(id: 'test-id');
        expect(entry.successRate, isNull);
      });

      test('successRate returns correct percentage', () {
        final entry = SyncHistoryEntry(
          id: 'test-id',
          status: SyncOperationStatus.success,
          startedAt: DateTime.now(),
          completedAt: DateTime.now(),
          successCount: 8,
          failureCount: 2,
          totalCount: 10,
        );

        expect(entry.successRate, 0.8);
      });

      test('isSuccessful returns true only for success status', () {
        final successEntry = SyncHistoryEntry(
          id: 'test-1',
          status: SyncOperationStatus.success,
          startedAt: DateTime.now(),
        );
        final failedEntry = SyncHistoryEntry(
          id: 'test-2',
          status: SyncOperationStatus.failed,
          startedAt: DateTime.now(),
        );

        expect(successEntry.isSuccessful, isTrue);
        expect(failedEntry.isSuccessful, isFalse);
      });

      test('isFailed returns true only for failed status', () {
        final successEntry = SyncHistoryEntry(
          id: 'test-1',
          status: SyncOperationStatus.success,
          startedAt: DateTime.now(),
        );
        final failedEntry = SyncHistoryEntry(
          id: 'test-2',
          status: SyncOperationStatus.failed,
          startedAt: DateTime.now(),
        );

        expect(successEntry.isFailed, isFalse);
        expect(failedEntry.isFailed, isTrue);
      });

      test('isInProgress returns true only for syncing status', () {
        final syncingEntry = SyncHistoryEntry(
          id: 'test-1',
          status: SyncOperationStatus.syncing,
          startedAt: DateTime.now(),
        );
        final successEntry = SyncHistoryEntry(
          id: 'test-2',
          status: SyncOperationStatus.success,
          startedAt: DateTime.now(),
        );

        expect(syncingEntry.isInProgress, isTrue);
        expect(successEntry.isInProgress, isFalse);
      });
    });

    group('copyWith', () {
      test('creates copy with updated fields', () {
        final original = SyncHistoryEntry.start(id: 'test-id');
        final updated = original.copyWith(
          status: SyncOperationStatus.success,
          successCount: 5,
        );

        expect(updated.id, original.id);
        expect(updated.status, SyncOperationStatus.success);
        expect(updated.successCount, 5);
        expect(updated.startedAt, original.startedAt);
      });

      test('clearError flag removes error', () {
        final error = SyncError(
          errorId: 'error-1',
          type: SyncErrorType.network,
          severity: SyncErrorSeverity.high,
          technicalMessage: 'Error',
          userMessage: 'Error',
          occurredAt: DateTime.now(),
        );

        final original = SyncHistoryEntry(
          id: 'test-id',
          status: SyncOperationStatus.failed,
          startedAt: DateTime.now(),
          error: error,
        );

        final updated = original.copyWith(clearError: true);

        expect(updated.error, isNull);
      });
    });

    group('JSON Serialization', () {
      test('toJson and fromJson round-trip correctly', () {
        final startedAt = DateTime(2026, 1, 5, 12, 0, 0);
        final completedAt = DateTime(2026, 1, 5, 12, 5, 0);
        final error = SyncError(
          errorId: 'error-1',
          type: SyncErrorType.network,
          severity: SyncErrorSeverity.high,
          technicalMessage: 'Connection timeout',
          userMessage: 'Network error',
          occurredAt: DateTime.now(),
        );

        final original = SyncHistoryEntry(
          id: 'test-id',
          status: SyncOperationStatus.failed,
          startedAt: startedAt,
          completedAt: completedAt,
          successCount: 5,
          failureCount: 7,
          totalCount: 12,
          error: error,
          isManual: true,
          connectionType: 'wifi',
        );

        final json = original.toJson();
        final restored = SyncHistoryEntry.fromJson(json);

        expect(restored, isNotNull);
        expect(restored!.id, original.id);
        expect(restored.status, original.status);
        expect(restored.startedAt, original.startedAt);
        expect(restored.completedAt, original.completedAt);
        expect(restored.successCount, original.successCount);
        expect(restored.failureCount, original.failureCount);
        expect(restored.totalCount, original.totalCount);
        expect(restored.isManual, original.isManual);
        expect(restored.connectionType, original.connectionType);
        expect(restored.error, isNotNull);
        expect(restored.error!.errorId, error.errorId);
        expect(restored.error!.type, error.type);
      });

      test('fromJson returns null for invalid JSON', () {
        expect(SyncHistoryEntry.fromJson({}), isNull);
        expect(SyncHistoryEntry.fromJson({'id': 'test'}), isNull);
      });

      test('toJsonString and fromJsonString round-trip correctly', () {
        final entries = [
          SyncHistoryEntry.success(
            id: 'test-1',
            startedAt: DateTime(2026, 1, 5),
            successCount: 10,
            failureCount: 0,
            totalCount: 10,
          ),
          SyncHistoryEntry.failure(
            id: 'test-2',
            startedAt: DateTime(2026, 1, 4),
            successCount: 0,
            failureCount: 5,
            totalCount: 5,
            error: SyncError(
              errorId: 'error-1',
              type: SyncErrorType.network,
              severity: SyncErrorSeverity.high,
              technicalMessage: 'Error',
              userMessage: 'Error',
              occurredAt: DateTime.now(),
            ),
          ),
        ];

        final jsonString = SyncHistoryEntry.toJsonString(entries);
        final restored = SyncHistoryEntry.fromJsonString(jsonString);

        expect(restored, hasLength(2));
        expect(restored[0].id, 'test-1');
        expect(restored[1].id, 'test-2');
      });

      test('fromJsonString returns empty list for invalid JSON', () {
        expect(SyncHistoryEntry.fromJsonString('invalid'), isEmpty);
        expect(SyncHistoryEntry.fromJsonString('[]'), isEmpty);
      });
    });

    group('toString', () {
      test('includes all relevant fields', () {
        final entry = SyncHistoryEntry.start(
          id: 'test-id',
          isManual: true,
          connectionType: 'wifi',
        );

        final str = entry.toString();
        expect(str, contains('test-id'));
        expect(str, contains('syncing'));
        expect(str, contains('true'));
        expect(str, contains('wifi'));
      });
    });
  });
}
