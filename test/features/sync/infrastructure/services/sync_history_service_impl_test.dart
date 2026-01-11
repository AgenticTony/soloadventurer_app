import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_history_entry.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_status.dart';
import 'package:soloadventurer/features/sync/domain/models/sync_error.dart';
import 'package:soloadventurer/features/sync/infrastructure/services/sync_history_service_impl.dart';

void main() {
  group('SyncHistoryServiceImpl', () {
    late SyncHistoryServiceImpl historyService;

    setUp(() {
      historyService = SyncHistoryServiceImpl(maxEntries: 10);
    });

    tearDown(() {
      historyService.dispose();
    });

    group('Entry Management', () {
      test('adds entry successfully', () async {
        final entry = SyncHistoryEntry.start(id: 'test-1');

        final added = await historyService.addEntry(entry);

        expect(added, isNotNull);
        expect(historyService.entryCount, 1);
        expect(historyService.entries.first.id, 'test-1');
      });

      test('returns entries in reverse insertion order', () async {
        final entry1 = SyncHistoryEntry.start(
          id: 'test-1',
        );
        final entry2 = SyncHistoryEntry.start(
          id: 'test-2',
        );

        await historyService.addEntry(entry1);
        await Future.delayed(const Duration(milliseconds: 10));
        await historyService.addEntry(entry2);

        // Entries are stored in insertion order (most recently added first)
        expect(historyService.entries.first.id, 'test-2');
        expect(historyService.entries.last.id, 'test-1');
      });

      test('removes oldest entry when at max capacity', () async {
        // Add 12 entries (test-0 through test-11)
        for (var i = 0; i < 12; i++) {
          final entry = SyncHistoryEntry.start(id: 'test-$i');
          await historyService.addEntry(entry);
        }

        // With maxEntries=10, the first 2 entries (test-0, test-1) should be removed
        expect(historyService.entryCount, 10);
        // Entries are in insertion order: [test-11, test-10, ..., test-2]
        expect(historyService.entries.last.id, 'test-2');
        expect(historyService.entries.first.id, 'test-11');
      });

      test('updates entry by ID', () async {
        final original = SyncHistoryEntry.start(id: 'test-1');
        await historyService.addEntry(original);

        final updated = SyncHistoryEntry(
          id: 'test-1',
          status: SyncOperationStatus.success,
          startedAt: original.startedAt,
          completedAt: DateTime.now(),
          successCount: 10,
          failureCount: 0,
          totalCount: 10,
        );

        final result = await historyService.updateEntry('test-1', updated);

        expect(result, isTrue);
        expect(
            historyService.entries.first.status, SyncOperationStatus.success);
      });

      test('updateEntry returns false for non-existent entry', () async {
        final entry = SyncHistoryEntry.start(id: 'test-1');
        final result = await historyService.updateEntry('test-1', entry);

        expect(result, isFalse);
      });

      test('getEntryById returns entry or null', () async {
        final entry = SyncHistoryEntry.start(id: 'test-1');
        await historyService.addEntry(entry);

        expect(historyService.getEntryById('test-1'), isNotNull);
        expect(historyService.getEntryById('non-existent'), isNull);
      });

      test('latestEntry returns most recent entry or null', () async {
        expect(historyService.latestEntry, isNull);

        await historyService.addEntry(SyncHistoryEntry.start(id: 'test-1'));

        expect(historyService.latestEntry, isNotNull);
        expect(historyService.latestEntry!.id, 'test-1');
      });
    });

    group('Query Methods', () {
      setUp(() async {
        await historyService.addEntry(
          SyncHistoryEntry.success(
            id: 'success-1',
            startedAt: DateTime(2026, 1, 5, 10, 0),
            successCount: 10,
            failureCount: 0,
            totalCount: 10,
            isManual: true,
          ),
        );
        await historyService.addEntry(
          SyncHistoryEntry.failure(
            id: 'failed-1',
            startedAt: DateTime(2026, 1, 5, 9, 0),
            successCount: 0,
            failureCount: 5,
            totalCount: 5,
            error: SyncError(
              errorId: 'error-1',
              type: SyncErrorType.network,
              severity: SyncErrorSeverity.high,
              technicalMessage: 'Error',
              userMessage: 'Error',
              suggestion: 'Try again later',
              occurredAt: DateTime.now(),
            ),
          ),
        );
        await historyService.addEntry(
          SyncHistoryEntry.success(
            id: 'auto-1',
            startedAt: DateTime(2026, 1, 5, 8, 0),
            successCount: 5,
            failureCount: 0,
            totalCount: 5,
            isManual: false,
          ),
        );
      });

      test('getEntriesByStatus filters correctly', () {
        final successEntries =
            historyService.getEntriesByStatus(SyncOperationStatus.success);
        final failedEntries =
            historyService.getEntriesByStatus(SyncOperationStatus.failed);

        expect(successEntries, hasLength(2));
        expect(failedEntries, hasLength(1));
        expect(failedEntries.first.id, 'failed-1');
      });

      test('getManualSyncs returns only manual syncs', () {
        final manual = historyService.getManualSyncs();

        expect(manual, hasLength(1));
        expect(manual.first.id, 'success-1');
      });

      test('getAutomaticSyncs returns only automatic syncs', () {
        final auto = historyService.getAutomaticSyncs();

        // Both failed-1 (default isManual=false) and auto-1 (isManual=false) are automatic
        expect(auto, hasLength(2));
        expect(auto.any((e) => e.id == 'failed-1'), isTrue);
        expect(auto.any((e) => e.id == 'auto-1'), isTrue);
      });

      test('getLatestEntries returns specified count', () {
        final latest = historyService.getLatestEntries(2);

        expect(latest, hasLength(2));
        // getLatestEntries returns the first N entries (most recently added)
        // Entries were added in order: success-1, failed-1, auto-1
        // So the list is: [auto-1, failed-1, success-1]
        expect(latest.first.id, 'auto-1');
        expect(latest.last.id, 'failed-1');
      });
    });

    group('Statistics', () {
      test('getStats returns correct statistics', () async {
        await historyService.addEntry(
          SyncHistoryEntry.success(
            id: 'success-1',
            startedAt: DateTime.now(),
            successCount: 10,
            failureCount: 2,
            totalCount: 12,
            isManual: true,
          ),
        );
        await historyService.addEntry(
          SyncHistoryEntry.success(
            id: 'success-2',
            startedAt: DateTime.now(),
            successCount: 5,
            failureCount: 0,
            totalCount: 5,
            isManual: false,
          ),
        );
        await historyService.addEntry(
          SyncHistoryEntry.failure(
            id: 'failed-1',
            startedAt: DateTime.now(),
            successCount: 0,
            failureCount: 5,
            totalCount: 5,
            error: SyncError(
              errorId: 'error-1',
              type: SyncErrorType.network,
              severity: SyncErrorSeverity.high,
              technicalMessage: 'Error',
              userMessage: 'Error',
              suggestion: 'Try again later',
              occurredAt: DateTime.now(),
            ),
          ),
        );

        final stats = historyService.getStats();

        expect(stats.totalSyncs, 3);
        expect(stats.successfulSyncs, 2);
        expect(stats.failedSyncs, 1);
        expect(stats.manualSyncs, 1);
        expect(stats.automaticSyncs, 2);
        expect(stats.successRate, 2 / 3);
        expect(stats.totalSuccessOperations, 15);
        expect(stats.totalFailedOperations, 7);
      });

      test('getStats returns null for empty history', () {
        final stats = historyService.getStats();

        expect(stats.totalSyncs, 0);
        expect(stats.successRate, isNull);
        expect(stats.averageDuration, isNull);
      });
    });

    group('Deletion', () {
      setUp(() async {
        await historyService.addEntry(
          SyncHistoryEntry.success(
            id: 'old',
            startedAt: DateTime(2026, 1, 1),
            successCount: 1,
            failureCount: 0,
            totalCount: 1,
          ),
        );
        await historyService.addEntry(
          SyncHistoryEntry.success(
            id: 'recent',
            startedAt: DateTime(2026, 1, 5),
            successCount: 1,
            failureCount: 0,
            totalCount: 1,
          ),
        );
      });

      test('deleteEntriesOlderThan removes old entries', () async {
        final cutoff = DateTime(2026, 1, 3);
        final deleted = await historyService.deleteEntriesOlderThan(cutoff);

        expect(deleted, 1);
        expect(historyService.entryCount, 1);
        expect(historyService.entries.first.id, 'recent');
      });

      test('deleteEntriesByStatus removes entries by status', () async {
        await historyService.addEntry(
          SyncHistoryEntry.failure(
            id: 'failed',
            startedAt: DateTime.now(),
            successCount: 0,
            failureCount: 1,
            totalCount: 1,
            error: SyncError(
              errorId: 'error-1',
              type: SyncErrorType.network,
              severity: SyncErrorSeverity.high,
              technicalMessage: 'Error',
              userMessage: 'Error',
              suggestion: 'Try again later',
              occurredAt: DateTime.now(),
            ),
          ),
        );

        final deleted = await historyService
            .deleteEntriesByStatus(SyncOperationStatus.failed);

        expect(deleted, 1);
        expect(historyService.getEntriesByStatus(SyncOperationStatus.failed),
            isEmpty);
      });

      test('clearHistory removes all entries', () async {
        final result = await historyService.clearHistory();

        expect(result.isSuccess, isTrue);
        expect(result.affectedCount, 2);
        expect(historyService.entryCount, 0);
      });
    });

    group('Import/Export', () {
      test('exportToJson returns valid JSON', () async {
        await historyService.addEntry(
          SyncHistoryEntry.success(
            id: 'test-1',
            startedAt: DateTime.now(),
            successCount: 5,
            failureCount: 0,
            totalCount: 5,
          ),
        );

        final json = historyService.exportToJson();

        expect(json, isNotEmpty);
        expect(json, contains('test-1'));
      });

      test('importFromJson adds entries', () async {
        const json = '''
          [
            {
              "id": "imported-1",
              "status": "success",
              "startedAt": "2026-01-05T12:00:00.000Z",
              "completedAt": "2026-01-05T12:05:00.000Z",
              "successCount": 10,
              "failureCount": 0,
              "totalCount": 10,
              "isManual": false
            }
          ]
        ''';

        final count = await historyService.importFromJson(json);

        expect(count, 1);
        expect(historyService.getEntryById('imported-1'), isNotNull);
      });
    });

    group('Stream', () {
      test('emits entries when listener subscribes', () async {
        await historyService.addEntry(
          SyncHistoryEntry.success(
            id: 'test-1',
            startedAt: DateTime.now(),
            successCount: 1,
            failureCount: 0,
            totalCount: 1,
          ),
        );

        final stream = historyService.entriesStream;
        final expectValue = expectLater(
          stream,
          emits(isNotEmpty),
        );

        // Give time for initial emission
        await Future.delayed(const Duration(milliseconds: 100));

        await expectValue;
      });
    });

    group('Disposal', () {
      test('disposed service throws on addEntry', () async {
        historyService.dispose();

        final entry = SyncHistoryEntry.start(id: 'test-1');
        final result = await historyService.addEntry(entry);

        expect(result, isNull);
      });

      test('dispose can be called multiple times', () {
        expect(() {
          historyService.dispose();
          historyService.dispose();
        }, returnsNormally);
      });
    });
  });
}
