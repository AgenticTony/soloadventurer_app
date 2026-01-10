import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/core/utils/query_batcher.dart';

void main() {
  group('QueryBatcher', () {
    late QueryBatcher batcher;

    setUp(() {
      batcher = QueryBatcher(
        config: BatchConfig.defaultConfig,
        debug: false,
      );
    });

    tearDown(() {
      batcher.dispose();
    });

    test('should add query to pending list', () {
      expect(batcher.pendingCount, 0);

      batcher.add(
        key: 'test-query',
        query: () async => 'result',
      );

      expect(batcher.pendingCount, 1);
    });

    test('should execute single query', () async {
      final resultFuture = batcher.add<String>(
        key: 'test',
        query: () async => 'test-result',
      );

      final results = await batcher.execute();

      expect(results.length, 1);
      expect(results.containsKey('test'), true);

      final result = results['test']!;
      expect(result.success, true);
      expect(result.data, 'test-result');
      expect(result.key, 'test');

      final awaitedResult = await resultFuture;
      expect(awaitedResult.data, 'test-result');
    });

    test('should execute multiple queries in parallel', () async {
      final results = <String, BatchResult>{};

      // Add multiple queries
      for (int i = 0; i < 3; i++) {
        batcher.add<int>(
          key: 'query-$i',
          query: () async {
            await Future.delayed(const Duration(milliseconds: 10));
            return i * 2;
          },
        );
      }

      // Execute
      final executedResults = await batcher.execute();

      expect(executedResults.length, 3);

      for (int i = 0; i < 3; i++) {
        final result = executedResults['query-$i']!;
        expect(result.success, true);
        expect(result.data, i * 2);
      }
    });

    test('should handle query errors', () async {
      batcher.add<String>(
        key: 'failing-query',
        query: () async {
          throw Exception('Test error');
        },
      );

      final results = await batcher.execute();

      expect(results.length, 1);

      final result = results['failing-query']!;
      expect(result.success, false);
      expect(result.data, isNull);
      expect(result.error, isNotNull);
      expect(result.error, contains('Test error'));
    });

    test('should deduplicate queries with same key', () async {
      const config = BatchConfig(
        maxBatchSize: 10,
        maxWaitTime: const Duration(milliseconds: 100),
        deduplicate: true,
      );

      final batcher = QueryBatcher(config: config);

      // Add two queries with same key
      final result1 = batcher.add<String>(
        key: 'duplicate-key',
        query: () async => 'result-1',
      );

      final result2 = batcher.add<String>(
        key: 'duplicate-key',
        query: () async => 'result-2',
      );

      // Only one should be in pending
      expect(batcher.pendingCount, 1);

      final results = await batcher.execute();

      // Should only have one result
      expect(results.length, 1);
      expect(results.containsKey('duplicate-key'), true);

      // Both futures should complete with same result
      final awaited1 = await result1;
      final awaited2 = await result2;

      expect(awaited1.data, 'result-1');
      expect(awaited2.data, 'result-1');

      batcher.dispose();
    });

    test('should execute queries in priority order when priorities differ',
        () async {
      final executionOrder = <String>[];

      batcher.add<String>(
        key: 'low',
        priority: 10,
        query: () async {
          executionOrder.add('low');
          return 'low';
        },
      );

      batcher.add<String>(
        key: 'high',
        priority: 1,
        query: () async {
          executionOrder.add('high');
          return 'high';
        },
      );

      batcher.add<String>(
        key: 'medium',
        priority: 5,
        query: () async {
          executionOrder.add('medium');
          return 'medium';
        },
      );

      await batcher.execute();

      // Should execute in priority order
      expect(executionOrder, ['high', 'medium', 'low']);
    });

    test('should auto-execute when batch is full', () async {
      final batcher = QueryBatcher(
        config: const BatchConfig(
          maxBatchSize: 3,
          maxWaitTime: Duration(seconds: 10), // Long wait time
        ),
      );

      var executed = false;

      // Add queries up to max batch size
      for (int i = 0; i < 3; i++) {
        batcher.add<int>(
          key: 'query-$i',
          query: () async {
            executed = true;
            return i;
          },
        );
      }

      // Should auto-execute when batch is full
      await Future.delayed(const Duration(milliseconds: 100));

      expect(executed, true);
      expect(batcher.pendingCount, 0);

      batcher.dispose();
    });

    test('should cancel pending queries', () async {
      batcher.add<String>(
        key: 'query-1',
        query: () async => 'result-1',
      );

      batcher.add<String>(
        key: 'query-2',
        query: () async => 'result-2',
      );

      expect(batcher.pendingCount, 2);

      final cancelledCount = batcher.cancelPending();

      expect(cancelledCount, 2);
      expect(batcher.pendingCount, 0);
    });

    test('should track statistics correctly', () async {
      // Execute successful queries
      batcher.add<String>(
        key: 'success-1',
        query: () async => 'result-1',
      );

      batcher.add<String>(
        key: 'success-2',
        query: () async => 'result-2',
      );

      batcher.add<String>(
        key: 'failure',
        query: () async {
          throw Exception('Error');
        },
      );

      await batcher.execute();

      final stats = batcher.statistics;

      expect(stats.totalBatches, 1);
      expect(stats.totalQueries, 3);
      expect(stats.successfulQueries, 2);
      expect(stats.failedQueries, 1);
      expect(stats.successRate, 2 / 3);
      expect(stats.averageBatchSize, 3.0);
    });

    test('should clear statistics', () async {
      batcher.add<String>(
        key: 'test',
        query: () async => 'result',
      );

      await batcher.execute();

      expect(batcher.statistics.totalQueries, 1);

      batcher.clearStatistics();

      expect(batcher.statistics.totalQueries, 0);
      expect(batcher.statistics.totalBatches, 0);
    });

    test('should call onBatchExecuted callback', () async {
      var callbackCalled = false;
      BatchStatistics? capturedStats;

      final batcher = QueryBatcher(
        onBatchExecuted: (stats) {
          callbackCalled = true;
          capturedStats = stats;
        },
      );

      batcher.add<String>(
        key: 'test',
        query: () async => 'result',
      );

      await batcher.execute();

      expect(callbackCalled, true);
      expect(capturedStats, isNotNull);
      expect(capturedStats!.totalQueries, 1);

      batcher.dispose();
    });

    test('should throw error when adding after dispose', () async {
      batcher.dispose();

      expect(
        () => batcher.add<String>(
          key: 'test',
          query: () async => 'result',
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('should throw error when executing after dispose', () async {
      batcher.dispose();

      expect(
        () => batcher.execute(),
        throwsA(isA<StateError>()),
      );
    });

    test('should handle empty batch execution', () async {
      final results = await batcher.execute();

      expect(results, isEmpty);
      expect(results.length, 0);
    });
  });

  group('BatchConfig', () {
    test('should have default values', () {
      const config = BatchConfig();

      expect(config.maxBatchSize, 10);
      expect(config.maxWaitTime, const Duration(milliseconds: 100));
      expect(config.parallel, true);
      expect(config.maxConcurrency, 5);
      expect(config.deduplicate, true);
    });

    test('should use aggressive preset', () {
      const config = BatchConfig.aggressive;

      expect(config.maxBatchSize, 20);
      expect(config.maxWaitTime, const Duration(milliseconds: 200));
      expect(config.parallel, true);
    });

    test('should use immediate preset', () {
      const config = BatchConfig.immediate;

      expect(config.maxBatchSize, 5);
      expect(config.maxWaitTime, const Duration(milliseconds: 50));
    });

    test('should use sequential preset', () {
      const config = BatchConfig.sequential;

      expect(config.parallel, false);
    });
  });

  group('BatchResult', () {
    test('should create successful result', () {
      final result = BatchResult.success(
        key: 'test-key',
        data: 'test-data',
        duration: const Duration(milliseconds: 100),
      );

      expect(result.success, true);
      expect(result.data, 'test-data');
      expect(result.key, 'test-key');
      expect(result.duration, const Duration(milliseconds: 100));
      expect(result.error, isNull);
    });

    test('should create failure result', () {
      final result = BatchResult.failure<int>(
        key: 'test-key',
        error: 'Test error',
      );

      expect(result.success, false);
      expect(result.data, isNull);
      expect(result.key, 'test-key');
      expect(result.error, 'Test error');
      expect(result.duration, Duration.zero);
    });

    test('should format toString correctly', () {
      final result = BatchResult<String>(
        data: 'value',
        success: true,
        key: 'key',
        timestamp: DateTime(2024, 1, 1),
        duration: const Duration(milliseconds: 100),
      );

      final string = result.toString();

      expect(string, contains('key: key'));
      expect(string, contains('success: true'));
      expect(string, contains('100ms'));
    });
  });

  group('BatchStatistics', () {
    test('should calculate success rate correctly', () {
      const stats = BatchStatistics(
        totalBatches: 1,
        totalQueries: 10,
        successfulQueries: 8,
        failedQueries: 2,
        averageBatchSize: 10.0,
        totalExecutionTime: Duration(milliseconds: 1000),
        averageBatchTime: Duration(milliseconds: 1000),
      );

      expect(stats.successRate, 0.8);
    });

    test('should handle zero queries', () {
      const stats = BatchStatistics(
        totalBatches: 0,
        totalQueries: 0,
        successfulQueries: 0,
        failedQueries: 0,
        averageBatchSize: 0.0,
        totalExecutionTime: Duration.zero,
        averageBatchTime: Duration.zero,
      );

      expect(stats.successRate, 0.0);
    });

    test('should format toString correctly', () {
      const stats = BatchStatistics(
        totalBatches: 2,
        totalQueries: 20,
        successfulQueries: 18,
        failedQueries: 2,
        averageBatchSize: 10.0,
        totalExecutionTime: Duration(milliseconds: 2000),
        averageBatchTime: Duration(milliseconds: 1000),
      );

      final string = stats.toString();

      expect(string, contains('batches: 2'));
      expect(string, contains('queries: 20'));
      expect(string, contains('success: 18'));
      expect(string, contains('failed: 2'));
      expect(string, contains('90.0%')); // success rate
    });
  });
}
