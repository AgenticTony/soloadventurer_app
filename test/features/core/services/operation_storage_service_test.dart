import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:soloadventurer/features/core/services/operation_queue.dart';
import 'package:soloadventurer/features/core/services/operation_storage_service.dart';

void main() {
  group('OperationStorageService', () {
    late ProviderContainer container;
    late ProviderSubscription subscription;

    setUp(() {
      SharedPreferences.setMockInitialValues({});
      container = ProviderContainer();
      // Keep a subscription so auto-dispose doesn't kill the provider
      subscription = container.listen(
        operationStorageServiceProvider,
        (_, __) {},
        fireImmediately: true,
      );
    });

    tearDown(() {
      subscription.close();
      container.dispose();
    });

    OperationStorageService getService() {
      return container.read(operationStorageServiceProvider.notifier);
    }

    group('Save Operations', () {
      test('should save pending operations successfully', () async {
        // Wait for the service to initialize
        await container.read(operationStorageServiceProvider.future);

        final service = getService();
        final result = await service.savePendingOperations([]);

        expect(result, isTrue);
      });

      test('should save pending operations with data', () async {
        await container.read(operationStorageServiceProvider.future);

        final service = getService();
        final operations = List.generate(
          100,
          (i) => _createMockOperation('id_$i', 'type_$i'),
        );

        final result = await service.savePendingOperations(operations);

        expect(result, isTrue);
      });

      test('should clear storage when saving empty operation list', () async {
        await container.read(operationStorageServiceProvider.future);

        // Save something first
        final service = getService();
        await service.savePendingOperations([_createMockOperation('op1', 'test')]);

        // Clear with empty list
        final result = await service.savePendingOperations([]);

        expect(result, isTrue);
      });

      test('should save failed operations successfully', () async {
        await container.read(operationStorageServiceProvider.future);

        final service = getService();
        final result = await service.saveFailedOperations([]);

        expect(result, isTrue);
      });

      test('should handle large operation data', () async {
        await container.read(operationStorageServiceProvider.future);

        final service = getService();
        final operations = List.generate(
          100,
          (i) => _createMockOperation('id_$i', 'type_$i'),
        );
        final result = await service.savePendingOperations(operations);

        expect(result, isTrue);
      });
    });

    group('Load Operations', () {
      test('should load pending operations successfully', () async {
        await container.read(operationStorageServiceProvider.future);

        final service = getService();
        final operations = [
          _createMockOperation('op1', 'trip_planning'),
          _createMockOperation('op2', 'location_update'),
        ];
        await service.savePendingOperations(operations);

        final result = await service.loadOperations();

        expect(result.pendingOperations.length, 2);
        expect(result.pendingOperations[0]['id'], 'op1');
        expect(result.pendingOperations[1]['id'], 'op2');
        expect(result.hadCorruptedData, isFalse);
      });

      test('should handle missing operations data', () async {
        await container.read(operationStorageServiceProvider.future);

        final service = getService();
        final result = await service.loadOperations();

        expect(result.pendingOperations, isEmpty);
        expect(result.failedOperations, isEmpty);
        expect(result.hadCorruptedData, isFalse);
      });

      test('should handle corrupted data gracefully', () async {
        // Set up mock with corrupted data
        SharedPreferences.setMockInitialValues({
          'pending_operations': 'invalid json{{{',
          'operation_queue_version': 1,
        });

        final corruptedContainer = ProviderContainer();
        await corruptedContainer.read(operationStorageServiceProvider.future);

        final service =
            corruptedContainer.read(operationStorageServiceProvider.notifier);
        final result = await service.loadOperations();

        expect(result.pendingOperations, isEmpty);
        expect(result.hadCorruptedData, isTrue);
        expect(result.errorMessage, isNotNull);

        corruptedContainer.dispose();
      });

      test('should skip operations with missing required fields', () async {
        SharedPreferences.setMockInitialValues({
          'pending_operations':
              '[{"id":"op1","type":"trip_planning","priority":1},'
              '{"id":"op2","priority":1},'
              '{"type":"location_update"}]',
          'operation_queue_version': 1,
        });

        final corruptedContainer = ProviderContainer();
        // Keep provider alive with listen and fireImmediately
        final sub = corruptedContainer.listen<AsyncValue<void>>(
          operationStorageServiceProvider,
          (_, __) {},
          fireImmediately: true,
        );
        // Wait for the async build
        await Future<void>.delayed(const Duration(milliseconds: 200));
        final service =
            corruptedContainer.read(operationStorageServiceProvider.notifier);
        final result = await service.loadOperations();

        expect(result.pendingOperations.length, 1);
        expect(result.pendingOperations[0]['id'], 'op1');
        expect(result.hadCorruptedData, isTrue);

        sub.close();
        corruptedContainer.dispose();
      });

      test('should handle version mismatch', () async {
        SharedPreferences.setMockInitialValues({
          'operation_queue_version': 999,
        });

        final versionContainer = ProviderContainer();
        await versionContainer.read(operationStorageServiceProvider.future);

        final service =
            versionContainer.read(operationStorageServiceProvider.notifier);
        final result = await service.loadOperations();

        expect(result.pendingOperations, isEmpty);

        versionContainer.dispose();
      });
    });

    group('Clear Operations', () {
      test('should clear all operations successfully', () async {
        await container.read(operationStorageServiceProvider.future);

        final service = getService();
        await service.savePendingOperations([_createMockOperation('op1', 'test')]);
        await service.saveFailedOperations([_createMockOperation('op2', 'test')]);

        final result = await service.clearAllOperations();

        expect(result, isTrue);
      });
    });

    group('Storage Statistics', () {
      test('should return accurate storage statistics', () async {
        await container.read(operationStorageServiceProvider.future);

        final service = getService();
        await service.savePendingOperations([
          _createMockOperation('op1', 'test'),
          _createMockOperation('op2', 'test'),
        ]);
        await service.saveFailedOperations([_createMockOperation('op3', 'test')]);

        final stats = await service.getStorageStats();

        expect(stats['pendingCount'], 2);
        expect(stats['failedCount'], 1);
        expect(stats['totalSizeBytes'], greaterThan(0));
        expect(stats['lastSaveTime'], isNotNull);
      });

      test('should handle empty storage statistics', () async {
        await container.read(operationStorageServiceProvider.future);

        final service = getService();
        final stats = await service.getStorageStats();

        expect(stats['pendingCount'], 0);
        expect(stats['failedCount'], 0);
        expect(stats['totalSizeBytes'], 0);
        expect(stats['lastSaveTime'], isNull);
      });
    });

    group('Last Save Time', () {
      test('should return null if no save time exists', () async {
        await container.read(operationStorageServiceProvider.future);

        final service = getService();
        final result = service.getLastSaveTime();

        expect(result, isNull);
      });

      test('should return valid DateTime if save time exists', () async {
        await container.read(operationStorageServiceProvider.future);

        final service = getService();
        await service.savePendingOperations([]);

        final result = service.getLastSaveTime();

        expect(result, isNotNull);
      });
    });
  });
}

// Helper function to create mock operations
QueueableOperation _createMockOperation(String id, String type) {
  return _MockQueueableOperation(id, type);
}

// Mock implementation of QueueableOperation for testing
class _MockQueueableOperation implements QueueableOperation {
  @override
  final String id;

  @override
  final String type;

  @override
  int get priority => 1;

  @override
  bool get requiresNetwork => true;

  @override
  int get attemptCount => 0;

  @override
  DateTime? get createdAt => DateTime.now();

  @override
  String? get deduplicationKey => 'test_$id';

  @override
  DateTime? get lastAttempt => null;

  @override
  String? get lastError => null;

  @override
  int get maxRetries => 3;

  _MockQueueableOperation(this.id, this.type);

  @override
  Future<void> execute() async {}

  @override
  QueueableOperation resetForRetry() => this;

  @override
  QueueableOperation withAttemptMetadata({
    DateTime? lastAttempt,
    int? attemptCount,
    String? lastError,
  }) => this;

  @override
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'priority': priority,
      'requiresNetwork': requiresNetwork,
    };
  }
}
