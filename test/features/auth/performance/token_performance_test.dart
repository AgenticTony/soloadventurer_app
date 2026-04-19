import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:riverpod/riverpod.dart';
import 'package:soloadventurer/features/auth/domain/services/token_blacklist_manager.dart';
import 'package:soloadventurer/features/auth/domain/services/token_manager.dart';
import 'package:vm_service/vm_service_io.dart';
import 'dart:developer' as developer;

extension ListSort<T extends num> on List<T> {
  List<T> sorted() {
    final copy = [...this];
    copy.sort();
    return copy;
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late TokenManager manager;
  late TokenBlacklistManager blacklistManager;
  late ProviderContainer container;

  setUp(() {
    container = ProviderContainer();
    blacklistManager = container.read(tokenBlacklistManagerProvider.notifier);
    manager = container.read(tokenManagerProvider.notifier);
  });

  tearDown(() {
    container.dispose();
  });

  group('Token Performance Tests', () {
    test('Token Validation Latency', () async {
      const int iterations = 1000;
      final stopwatch = Stopwatch()..start();

      for (var i = 0; i < iterations; i++) {
        manager.hasValidTokens;
      }

      stopwatch.stop();
      final averageLatency = stopwatch.elapsedMicroseconds / iterations;

      print('Average token validation latency: $averageLatencyμs');
      expect(averageLatency, lessThan(1000)); // Less than 1ms per validation
    });

    test('Blacklist Lookup Speed', () async {
      const int tokenCount = 10000;
      final tokens = List.generate(tokenCount, (i) => 'test_token_$i');

      // Add tokens to blacklist
      final stopwatch = Stopwatch()..start();
      for (final token in tokens) {
        blacklistManager.blacklistToken(token);
      }
      stopwatch.stop();

      final averageAddTime = stopwatch.elapsedMicroseconds / tokenCount;
      print('Average blacklist add time: $averageAddTimeμs');

      // Test lookup speed
      stopwatch.reset();
      stopwatch.start();
      for (final token in tokens) {
        blacklistManager.isTokenBlacklisted(token);
      }
      stopwatch.stop();

      final averageLookupTime = stopwatch.elapsedMicroseconds / tokenCount;
      print('Average blacklist lookup time: $averageLookupTimeμs');
      expect(averageLookupTime, lessThan(500)); // Less than 500μs per lookup
    });

    test('Concurrent Token Operations', () async {
      const int concurrentOperations = 100;
      final futures = <Future>[];

      final stopwatch = Stopwatch()..start();

      for (var i = 0; i < concurrentOperations; i++) {
        futures.add(Future(() async {
          blacklistManager.blacklistToken('concurrent_token_$i');
          blacklistManager.isTokenBlacklisted('concurrent_token_$i');
          // Note: We don't have a direct removeFromBlacklist method, tokens are automatically removed after expiry
        }));
      }

      await Future.wait(futures);
      stopwatch.stop();

      final averageOperationTime =
          stopwatch.elapsedMicroseconds / concurrentOperations;
      print('Average concurrent operation time: $averageOperationTimeμs');
      expect(averageOperationTime,
          lessThan(5000)); // Less than 5ms per operation set
    });

    test('Memory Usage Under Load', () async {
      int initialMemory;
      try {
        initialMemory = await _getMemoryUsage();
      } catch (e) {
        // VM service not available in this test runner; skip memory check
        print('Skipping memory usage test: $e');
        return;
      }
      const operationCount = 50000;

      // Perform a high number of operations
      for (var i = 0; i < operationCount; i++) {
        blacklistManager.blacklistToken('memory_test_token_$i');
        if (i % 2 == 0) {
          blacklistManager.isTokenBlacklisted('memory_test_token_$i');
        }
      }

      final finalMemory = await _getMemoryUsage();
      final memoryDelta = finalMemory - initialMemory;

      print('Memory usage delta: ${memoryDelta ~/ 1024}KB');
      expect(
          memoryDelta, lessThan(50 * 1024 * 1024)); // Less than 50MB increase
    });
  });
}

Future<int> _getMemoryUsage() async {
  final info = await developer.Service.getInfo();
  if (info.serverUri == null) {
    throw Exception(
        'VM service protocol not available. Run with --enable-vm-service flag.');
  }

  final serviceClient = await vmServiceConnectUri(info.serverUri.toString());
  final vm = await serviceClient.getVM();
  final isolate = vm.isolates!.first;
  final memoryUsage = await serviceClient.getMemoryUsage(isolate.id!);
  return memoryUsage.heapUsage ?? 0;
}
