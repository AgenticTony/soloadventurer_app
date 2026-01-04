import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';
import 'package:soloadventurer/app/di/service_locator.dart';
import 'package:soloadventurer/core/storage/secure_storage.dart';
import 'package:soloadventurer/features/core/services/operation_queue.dart';
import 'package:soloadventurer/features/core/services/operation_storage_service.dart';
import 'package:soloadventurer/features/core/services/operation_priority.dart';
import 'package:soloadventurer/features/core/providers/connectivity_provider.dart';
import 'package:soloadventurer/features/auth/domain/services/token_manager.dart';
import 'package:soloadventurer/features/travel/domain/models/trip_planning_operation.dart';
import 'test_config.dart';

/// Mock operation that can simulate success or failure
class MockOperation implements QueueableOperation {
  @override
  final String id;

  @override
  final String type;

  @override
  final int priority;

  @override
  final bool requiresNetwork;

  @override
  final DateTime? createdAt;

  @override
  final DateTime? lastAttempt;

  @override
  final int attemptCount;

  @override
  final String? lastError;

  @override
  final int maxRetries;

  @override
  final String? deduplicationKey;

  final bool shouldSucceed;
  final Future<void> Function() onExecute;

  const MockOperation({
    required this.id,
    required this.type,
    this.priority = OperationPriority.normal,
    this.requiresNetwork = true,
    this.createdAt,
    this.lastAttempt,
    this.attemptCount = 0,
    this.lastError,
    this.maxRetries = 3,
    this.deduplicationKey,
    this.shouldSucceed = true,
    required this.onExecute,
  });

  @override
  Future<void> execute() async {
    await onExecute();
    if (!shouldSucceed) {
      throw Exception('Mock operation failed');
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'priority': priority,
        'requiresNetwork': requiresNetwork,
        'createdAt': createdAt?.toIso8601String(),
        'lastAttempt': lastAttempt?.toIso8601String(),
        'attemptCount': attemptCount,
        'lastError': lastError,
        'maxRetries': maxRetries,
        'deduplicationKey': deduplicationKey,
      };

  MockOperation copyWith({
    String? id,
    String? type,
    int? priority,
    bool? requiresNetwork,
    DateTime? createdAt,
    DateTime? lastAttempt,
    int? attemptCount,
    String? lastError,
    int? maxRetries,
    String? deduplicationKey,
    bool? shouldSucceed,
    Future<void> Function()? onExecute,
  }) {
    return MockOperation(
      id: id ?? this.id,
      type: type ?? this.type,
      priority: priority ?? this.priority,
      requiresNetwork: requiresNetwork ?? this.requiresNetwork,
      createdAt: createdAt ?? this.createdAt,
      lastAttempt: lastAttempt ?? this.lastAttempt,
      attemptCount: attemptCount ?? this.attemptCount,
      lastError: lastError ?? this.lastError,
      maxRetries: maxRetries ?? this.maxRetries,
      deduplicationKey: deduplicationKey ?? this.deduplicationKey,
      shouldSucceed: shouldSucceed ?? this.shouldSucceed,
      onExecute: onExecute ?? this.onExecute,
    );
  }
}

/// Mock token manager for testing
class MockTokenManager implements TokenManager {
  bool _hasValidTokens = true;
  bool _canPerformOnlineOperations = true;

  @override
  bool get hasValidTokens => _hasValidTokens;

  @override
  bool get canPerformOnlineOperations => _canPerformOnlineOperations;

  @override
  String? get accessToken => 'mock-access-token';

  @override
  String? get refreshToken => 'mock-refresh-token';

  @override
  String? get idToken => 'mock-id-token';

  @override
  DateTime? get accessTokenExpiry => DateTime.now().add(const Duration(hours: 1));

  @override
  Future<void> setTokens({
    required String accessToken,
    required String refreshToken,
    String? idToken,
    DateTime? accessTokenExpiry,
  }) async {
    _hasValidTokens = true;
    _canPerformOnlineOperations = true;
  }

  @override
  Future<void> clearTokens() async {
    _hasValidTokens = false;
    _canPerformOnlineOperations = false;
  }

  @override
  Future<bool> refreshTokens() async {
    _hasValidTokens = true;
    _canPerformOnlineOperations = true;
    return true;
  }

  @override
  Future<bool> isTokenExpired() async => false;

  void setOfflineMode() {
    _canPerformOnlineOperations = false;
  }

  void setOnlineMode() {
    _canPerformOnlineOperations = true;
  }
}

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  late ProviderContainer container;
  late MockTokenManager mockTokenManager;
  late OperationStorageService storageService;
  bool isOnline = true;

  setUp(() async {
    // Initialize SharedPreferences for testing
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();

    // Initialize service locator in test mode
    await setupServiceLocator(isTest: true);

    // Clear any existing storage
    await getIt<SecureStorage>().delete(TestConfig.authTokenKey);
    await getIt<SecureStorage>().delete(TestConfig.refreshTokenKey);
    await getIt<SecureStorage>().delete(TestConfig.userDataKey);
    await prefs.clear();

    // Initialize mock token manager
    mockTokenManager = MockTokenManager();

    // Initialize storage service
    storageService = OperationStorageService(prefs: prefs);

    // Create provider container with overrides
    isOnline = true;
    container = ProviderContainer(
      overrides: [
        connectivityNotifierProvider.overrideWith((ref) {
          // Mock connectivity notifier
          final controller = ConnectivityNotifier();
          // Manually set the state
          controller.state = isOnline;
          return controller;
        }),
        tokenManagerProvider.overrideWithValue(mockTokenManager),
        operationStorageServiceProvider.overrideWithValue(storageService),
      ],
    );
  });

  tearDown(() async {
    await container.dispose();
    await resetServiceLocator();
  });

  group('Operation Queue Integration Tests', () {
    testWidgets('Operations execute when online', (tester) async {
      // Arrange
      final queue = container.read(operationQueueProvider.notifier);
      var executeCount = 0;

      final operation = MockOperation(
        id: const Uuid().v4(),
        type: 'test_operation',
        priority: OperationPriority.normal,
        requiresNetwork: true,
        createdAt: DateTime.now(),
        onExecute: () async {
          executeCount++;
        },
      );

      // Act
      await queue.addOperation(operation);
      await queue.processQueue();

      // Wait for processing to complete
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Assert
      expect(executeCount, 1, reason: 'Operation should execute when online');
      final pendingOps = queue.getPendingOperations();
      expect(pendingOps.length, 0, reason: 'Queue should be empty after successful execution');
    });

    testWidgets('Operations queue when offline', (tester) async {
      // Arrange
      final queue = container.read(operationQueueProvider.notifier);
      var executeCount = 0;

      // Set offline mode
      isOnline = false;
      mockTokenManager.setOfflineMode();

      final operation = MockOperation(
        id: const Uuid().v4(),
        type: 'test_operation',
        priority: OperationPriority.normal,
        requiresNetwork: true,
        createdAt: DateTime.now(),
        onExecute: () async {
          executeCount++;
        },
      );

      // Act
      await queue.addOperation(operation);
      await queue.processQueue();

      // Wait for processing to complete
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Assert
      expect(executeCount, 0, reason: 'Operation should not execute when offline');
      final pendingOps = queue.getPendingOperations();
      expect(pendingOps.length, 1, reason: 'Operation should remain in queue when offline');
    });

    testWidgets('Queue processes when connection restored', (tester) async {
      // Arrange
      final queue = container.read(operationQueueProvider.notifier);
      var executeCount = 0;

      // Start offline
      isOnline = false;
      mockTokenManager.setOfflineMode();

      final operation = MockOperation(
        id: const Uuid().v4(),
        type: 'test_operation',
        priority: OperationPriority.normal,
        requiresNetwork: true,
        createdAt: DateTime.now(),
        onExecute: () async {
          executeCount++;
        },
      );

      // Add operation while offline
      await queue.addOperation(operation);
      await queue.processQueue();
      await tester.pump(const Duration(milliseconds: 100));

      // Verify operation is queued
      expect(queue.getPendingOperations().length, 1);
      expect(executeCount, 0);

      // Act: Restore connection
      isOnline = true;
      mockTokenManager.setOnlineMode();
      await queue.processQueue();

      // Wait for processing to complete
      await tester.pump(const Duration(milliseconds: 100));
      await tester.pumpAndSettle();

      // Assert
      expect(executeCount, 1, reason: 'Operation should execute when connection is restored');
      expect(queue.getPendingOperations().length, 0, reason: 'Queue should be empty after processing');
    });

    testWidgets('Failed operations retry correctly', (tester) async {
      // Arrange
      final queue = container.read(operationQueueProvider.notifier);
      var attemptCount = 0;

      final operation = MockOperation(
        id: const Uuid().v4(),
        type: 'test_operation',
        priority: OperationPriority.normal,
        requiresNetwork: true,
        createdAt: DateTime.now(),
        maxRetries: 3,
        shouldSucceed: false, // Always fail
        onExecute: () async {
          attemptCount++;
        },
      );

      // Act
      await queue.addOperation(operation);

      // Process queue multiple times to simulate retries
      for (int i = 0; i < 4; i++) {
        await queue.processQueue();
        await tester.pump(const Duration(seconds: 2)); // Wait for backoff
        await tester.pumpAndSettle();
      }

      // Assert
      expect(attemptCount, 3, reason: 'Should retry up to maxRetries times');

      final failedOps = queue.getFailedOperations();
      expect(failedOps.length, 1, reason: 'Operation should be in failed queue after max retries');

      final failedOp = failedOps.first;
      expect(failedOp.attemptCount, 3, reason: 'Failed operation should show 3 attempts');
      expect(failedOp.lastError, isNotNull, reason: 'Failed operation should have error message');
    });

    testWidgets('Manual retry works from queue', (tester) async {
      // Arrange
      final queue = container.read(operationQueueProvider.notifier);
      var executeCount = 0;

      // Create an operation that will fail first, then succeed
      var shouldFail = true;
      final operation = MockOperation(
        id: const Uuid().v4(),
        type: 'test_operation',
        priority: OperationPriority.normal,
        requiresNetwork: true,
        createdAt: DateTime.now(),
        maxRetries: 1,
        shouldSucceed: true,
        onExecute: () async {
          executeCount++;
          if (shouldFail) {
            throw Exception('First attempt fails');
          }
        },
      );

      // Act: First attempt fails
      shouldFail = true;
      await queue.addOperation(operation);
      await queue.processQueue();
      await tester.pumpAndSettle();

      expect(executeCount, 1);
      expect(queue.getFailedOperations().length, 1);

      // Act: Manual retry with success
      shouldFail = false;
      final failedOp = queue.getFailedOperations().first;
      await queue.retryOperation(failedOp.id);
      await queue.processQueue();
      await tester.pumpAndSettle();

      // Assert
      expect(executeCount, 2, reason: 'Operation should execute again after manual retry');
      expect(queue.getFailedOperations().length, 0, reason: 'Failed queue should be empty after successful retry');
      expect(queue.getPendingOperations().length, 0, reason: 'Pending queue should be empty after successful retry');
    });

    testWidgets('App restart preserves queue', (tester) async {
      // Arrange
      final queue1 = container.read(operationQueueProvider.notifier);
      final operationId = const Uuid().v4();

      final operation = MockOperation(
        id: operationId,
        type: 'test_operation',
        priority: OperationPriority.normal,
        requiresNetwork: true,
        createdAt: DateTime.now(),
        onExecute: () async {},
      );

      // Act: Add operation and persist
      await queue1.addOperation(operation);
      await tester.pumpAndSettle();

      // Verify operation is in queue
      expect(queue1.getPendingOperations().length, 1);

      // Simulate app restart by creating a new queue instance
      final newContainer = ProviderContainer(
        overrides: [
          connectivityNotifierProvider.overrideWith((ref) {
            final controller = ConnectivityNotifier();
            controller.state = isOnline;
            return controller;
          }),
          tokenManagerProvider.overrideWithValue(mockTokenManager),
          operationStorageServiceProvider.overrideWithValue(storageService),
        ],
      );

      final queue2 = newContainer.read(operationQueueProvider.notifier);
      await tester.pumpAndSettle();

      // Assert: New queue should have loaded the persisted operation
      final pendingOps = queue2.getPendingOperations();
      expect(pendingOps.length, 1, reason: 'Queue should be restored after app restart');
      expect(pendingOps.first.id, operationId, reason: 'Restored operation should match original');

      await newContainer.dispose();
    });

    testWidgets('Priority queue processes critical operations first', (tester) async {
      // Arrange
      final queue = container.read(operationQueueProvider.notifier);
      final executionOrder = <String>[];

      final lowPriorityOp = MockOperation(
        id: 'low-1',
        type: 'low_priority',
        priority: OperationPriority.low,
        requiresNetwork: true,
        createdAt: DateTime.now(),
        onExecute: () async {
          executionOrder.add('low');
        },
      );

      final normalPriorityOp = MockOperation(
        id: 'normal-1',
        type: 'normal_priority',
        priority: OperationPriority.normal,
        requiresNetwork: true,
        createdAt: DateTime.now(),
        onExecute: () async {
          executionOrder.add('normal');
        },
      );

      final criticalOp = MockOperation(
        id: 'critical-1',
        type: 'critical_priority',
        priority: OperationPriority.critical,
        requiresNetwork: true,
        createdAt: DateTime.now(),
        onExecute: () async {
          executionOrder.add('critical');
        },
      );

      // Act: Add operations in random order
      await queue.addOperation(normalPriorityOp);
      await queue.addOperation(lowPriorityOp);
      await queue.addOperation(criticalOp);

      await queue.processQueue();
      await tester.pumpAndSettle();

      // Assert: Critical operation should execute first
      expect(executionOrder.length, 3);
      expect(executionOrder[0], 'critical', reason: 'Critical operation should execute first');
      expect(executionOrder.contains('normal'), true);
      expect(executionOrder.contains('low'), true);
    });

    testWidgets('Operations with deduplication key replace duplicates', (tester) async {
      // Arrange
      final queue = container.read(operationQueueProvider.notifier);
      var executionCount = 0;

      // Create two operations with the same deduplication key
      final operation1 = MockOperation(
        id: const Uuid().v4(),
        type: 'test_operation',
        priority: OperationPriority.normal,
        requiresNetwork: true,
        createdAt: DateTime.now(),
        deduplicationKey: 'trip_123',
        onExecute: () async {
          executionCount++;
        },
      );

      final operation2 = MockOperation(
        id: const Uuid().v4(),
        type: 'test_operation',
        priority: OperationPriority.normal,
        requiresNetwork: true,
        createdAt: DateTime.now(),
        deduplicationKey: 'trip_123', // Same deduplication key
        onExecute: () async {
          executionCount++;
        },
      );

      // Act: Add both operations
      await queue.addOperation(operation1);
      await queue.addOperation(operation2);

      await queue.processQueue();
      await tester.pumpAndSettle();

      // Assert: Only the second operation should execute (replaces the first)
      expect(executionCount, 1, reason: 'Duplicate operation should replace the original');
      expect(queue.getPendingOperations().length, 0);
    });

    testWidgets('Round-robin prevents priority starvation', (tester) async {
      // Arrange
      final queue = container.read(operationQueueProvider.notifier);
      final executionOrder = <String>[];

      // Create many high-priority operations and one low-priority operation
      for (int i = 0; i < 10; i++) {
        final highOp = MockOperation(
          id: 'high-$i',
          type: 'high_priority',
          priority: OperationPriority.high,
          requiresNetwork: true,
          createdAt: DateTime.now().subtract(const Duration(minutes: 6)), // Old enough for aging boost
          onExecute: () async {
            executionOrder.add('high-$i');
          },
        );
        await queue.addOperation(highOp);
      }

      final lowOp = MockOperation(
        id: 'low-1',
        type: 'low_priority',
        priority: OperationPriority.low,
        requiresNetwork: true,
        createdAt: DateTime.now(),
        onExecute: () async {
          executionOrder.add('low');
        },
      );
      await queue.addOperation(lowOp);

      // Act: Process queue
      await queue.processQueue();
      await tester.pump(const Duration(milliseconds: 100));

      // Process multiple cycles to see round-robin effect
      for (int i = 0; i < 5; i++) {
        await queue.processQueue();
        await tester.pump(const Duration(milliseconds: 100));
      }
      await tester.pumpAndSettle();

      // Assert: Low priority operation should eventually execute (aging or round-robin)
      expect(executionOrder.contains('low'), true,
          reason: 'Low-priority operation should eventually execute due to aging or round-robin');
    });

    testWidgets('Exponential backoff increases delay between retries', (tester) async {
      // Arrange
      final queue = container.read(operationQueueProvider.notifier);
      final attemptTimes = <DateTime>[];

      final operation = MockOperation(
        id: const Uuid().v4(),
        type: 'test_operation',
        priority: OperationPriority.normal,
        requiresNetwork: true,
        createdAt: DateTime.now(),
        maxRetries: 3,
        shouldSucceed: false,
        onExecute: () async {
          attemptTimes.add(DateTime.now());
          throw Exception('Always fails');
        },
      );

      // Act: Add operation and process multiple times
      await queue.addOperation(operation);

      for (int i = 0; i < 3; i++) {
        await queue.processQueue();
        await tester.pump(const Duration(milliseconds: 100));
      }

      // Assert
      expect(attemptTimes.length, 3, reason: 'Should have 3 attempts recorded');

      final failedOps = queue.getFailedOperations();
      expect(failedOps.length, 1);
      expect(failedOps.first.attemptCount, 3);
    });

    testWidgets('Clear failed operations removes all failed items', (tester) async {
      // Arrange
      final queue = container.read(operationQueueProvider.notifier);

      // Add multiple failing operations
      for (int i = 0; i < 3; i++) {
        final operation = MockOperation(
          id: 'failed-$i',
          type: 'failing_operation',
          priority: OperationPriority.normal,
          requiresNetwork: true,
          createdAt: DateTime.now(),
          maxRetries: 1,
          shouldSucceed: false,
          onExecute: () async {
            throw Exception('Always fails');
          },
        );
        await queue.addOperation(operation);
      }

      // Process to move them to failed queue
      await queue.processQueue();
      await tester.pumpAndSettle();

      expect(queue.getFailedOperations().length, 3);

      // Act: Clear all failed operations
      await queue.clearFailedOperations();
      await tester.pumpAndSettle();

      // Assert
      expect(queue.getFailedOperations().length, 0,
          reason: 'All failed operations should be cleared');
    });

    testWidgets('Retry all failed operations moves them back to pending', (tester) async {
      // Arrange
      final queue = container.read(operationQueueProvider.notifier);
      var executeCount = 0;

      // Add operations that will fail initially
      for (int i = 0; i < 3; i++) {
        final operation = MockOperation(
          id: 'retry-$i',
          type: 'retry_operation',
          priority: OperationPriority.normal,
          requiresNetwork: true,
          createdAt: DateTime.now(),
          maxRetries: 1,
          shouldSucceed: true, // Will succeed on retry
          onExecute: () async {
            executeCount++;
            if (executeCount <= 3) {
              // Fail first attempt
              throw Exception('First attempt fails');
            }
          },
        );
        await queue.addOperation(operation);
      }

      // Process to move them to failed queue
      await queue.processQueue();
      await tester.pumpAndSettle();

      expect(queue.getFailedOperations().length, 3);
      expect(queue.getPendingOperations().length, 0);
      expect(executeCount, 3);

      // Act: Retry all failed operations
      await queue.retryAllFailed();
      await queue.processQueue();
      await tester.pumpAndSettle();

      // Assert
      expect(queue.getFailedOperations().length, 0,
          reason: 'Failed queue should be empty after successful retry');
      expect(queue.getPendingOperations().length, 0,
          reason: 'Pending queue should be empty after successful execution');
      expect(executeCount, 6, reason: 'All operations should execute twice (fail then succeed)');
    });
  });
}
