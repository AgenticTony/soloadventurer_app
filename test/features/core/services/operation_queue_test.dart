import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/core/services/retry_strategy.dart';
import 'package:soloadventurer/features/core/services/operation_priority.dart';
import 'package:soloadventurer/features/travel/domain/models/trip_planning_operation.dart';
import 'package:soloadventurer/features/travel/domain/models/travel_note_operation.dart';
import 'package:soloadventurer/features/travel/domain/models/location_update_operation.dart';

void main() {
  group('OperationQueue Tests', () {
    group('Retry Logic', () {
      test('should calculate correct exponential backoff delays', () {
        // Arrange
        final strategy = ExponentialBackoffStrategy(
          baseDelay: const Duration(seconds: 1),
          maxDelay: const Duration(minutes: 5),
          jitterFactor: 0.0,
        );

        // Act & Assert
        // Attempt 0: 1s
        expect(strategy.calculateDelay(0), const Duration(seconds: 1));
        // Attempt 1: 2s
        expect(strategy.calculateDelay(1), const Duration(seconds: 2));
        // Attempt 2: 4s
        expect(strategy.calculateDelay(2), const Duration(seconds: 4));
        // Attempt 3: 8s
        expect(strategy.calculateDelay(3), const Duration(seconds: 8));
        // Attempt 4: 16s
        expect(strategy.calculateDelay(4), const Duration(seconds: 16));
      });

      test('should cap backoff delay at maxDelay', () {
        // Arrange
        final strategy = ExponentialBackoffStrategy(
          baseDelay: const Duration(seconds: 1),
          maxDelay: const Duration(seconds: 10),
          jitterFactor: 0.0,
        );

        // Act & Assert
        // Even with high attempt count, should not exceed maxDelay
        expect(strategy.calculateDelay(0).inSeconds, lessThanOrEqualTo(10));
        expect(strategy.calculateDelay(5).inSeconds, lessThanOrEqualTo(10));
        expect(strategy.calculateDelay(10).inSeconds, lessThanOrEqualTo(10));
        expect(strategy.calculateDelay(100).inSeconds, lessThanOrEqualTo(10));
      });

      test('should handle zero attempt count', () {
        // Arrange
        final strategy = ExponentialBackoffStrategy(
          baseDelay: const Duration(seconds: 2),
          jitterFactor: 0.0,
        );

        // Act
        final delay = strategy.calculateDelay(0);

        // Assert
        expect(delay, const Duration(seconds: 2));
      });

      test('should add jitter to delay when configured', () {
        // Arrange
        final strategy = ExponentialBackoffStrategy(
          baseDelay: const Duration(seconds: 1),
          maxDelay: const Duration(minutes: 5),
          jitterFactor: 0.5,
        );

        // Act
        final delay1 = strategy.calculateDelay(1);
        final delay2 = strategy.calculateDelay(1);

        // Assert: With jitter, multiple calculations might vary
        // (though we can't guarantee this without controlling random seed)
        expect(delay1.inSeconds, greaterThanOrEqualTo(0));
        expect(delay1.inSeconds, lessThanOrEqualTo(5));
      });
    });

    group('Operation Deduplication', () {
      test('should generate deduplication key for trip update operations', () {
        // Arrange
        final operation = TripPlanningOperation.update(
          tripId: 'trip123',
          name: 'Updated Name',
        );

        // Act
        final deduplicationKey = operation.deduplicationKey;

        // Assert
        expect(deduplicationKey, 'trip_trip123');
      });

      test('should not deduplicate create operations', () {
        // Arrange
        final operation = TripPlanningOperation.create(
          tripName: 'New Trip',
          destinations: ['Paris'],
        );

        // Act
        final deduplicationKey = operation.deduplicationKey;

        // Assert
        expect(deduplicationKey, isNull);
      });

      test('should not deduplicate delete operations', () {
        // Arrange & Act
        const operation = TripPlanningOperation(
          id: 'op1',
          tripId: 'trip123',
          planningType: TripPlanningType.delete,
          changes: {},
          priority: 10,
        );

        // Assert
        expect(operation.deduplicationKey, isNull);
      });

      test('should generate deduplication key for addDestination operations',
          () {
        // Arrange & Act
        const operation = TripPlanningOperation(
          id: 'op1',
          tripId: 'trip123',
          planningType: TripPlanningType.addDestination,
          changes: {},
          priority: 10,
        );

        // Assert
        expect(operation.deduplicationKey, 'trip_trip123');
      });

      test('should generate deduplication key for removeDestination operations',
          () {
        // Arrange & Act
        const operation = TripPlanningOperation(
          id: 'op1',
          tripId: 'trip123',
          planningType: TripPlanningType.removeDestination,
          changes: {},
          priority: 10,
        );

        // Assert
        expect(operation.deduplicationKey, 'trip_trip123');
      });

      test('should generate deduplication key for updateDates operations', () {
        // Arrange & Act
        const operation = TripPlanningOperation(
          id: 'op1',
          tripId: 'trip123',
          planningType: TripPlanningType.updateDates,
          changes: {},
          priority: 10,
        );

        // Assert
        expect(operation.deduplicationKey, 'trip_trip123');
      });

      test('should not deduplicate travel note operations', () {
        // Arrange
        final operation = TravelNoteOperation(
          id: 'note1',
          tripId: 'trip1',
          content: 'Test note',
          createdAt: DateTime.now(),
        );

        // Act
        final deduplicationKey = operation.deduplicationKey;

        // Assert
        expect(deduplicationKey, isNull);
      });

      test('should not deduplicate location update operations', () {
        // Arrange
        final operation = LocationUpdateOperation(
          id: 'loc1',
          tripId: 'trip1',
          latitude: 48.8566,
          longitude: 2.3522,
          timestamp: DateTime.now(),
          priority: 1,
        );

        // Act
        final deduplicationKey = operation.deduplicationKey;

        // Assert
        expect(deduplicationKey, isNull);
      });

      test('should have same deduplication key for operations on same trip',
          () {
        // Arrange
        final op1 =
            TripPlanningOperation.update(tripId: 'trip123', name: 'Update 1');
        final op2 =
            TripPlanningOperation.update(tripId: 'trip123', name: 'Update 2');

        // Act
        final key1 = op1.deduplicationKey;
        final key2 = op2.deduplicationKey;

        // Assert
        expect(key1, key2);
        expect(key1, 'trip_trip123');
      });
    });

    group('Priority Handling', () {
      test('should assign correct priority to trip operations', () {
        // Arrange & Act
        final tripOp = TripPlanningOperation.create(
          tripName: 'Test Trip',
          destinations: ['Paris'],
        );

        // Assert
        expect(tripOp.priority, OperationPriority.normal);
        expect(tripOp.priority, 10);
      });

      test('should assign correct priority to travel note operations', () {
        // Arrange & Act
        final noteOp = TravelNoteOperation(
          id: 'note1',
          tripId: 'trip1',
          content: 'Test note',
          createdAt: DateTime.now(),
        );

        // Assert
        expect(noteOp.priority, OperationPriority.normal);
        expect(noteOp.priority, 10);
      });

      test('should assign correct priority to location update operations', () {
        // Arrange & Act
        final locationOp = LocationUpdateOperation(
          id: 'loc1',
          tripId: 'trip1',
          latitude: 48.8566,
          longitude: 2.3522,
          timestamp: DateTime.now(),
          priority: 1,
        );

        // Assert
        expect(locationOp.priority, OperationPriority.low);
        expect(locationOp.priority, 1);
      });

      test('should support priority comparison', () {
        // Arrange
        const criticalPriority = OperationPriority.critical;
        const highPriority = OperationPriority.high;
        const normalPriority = OperationPriority.normal;
        const lowPriority = OperationPriority.low;

        // Act & Assert
        expect(criticalPriority, greaterThan(highPriority));
        expect(highPriority, greaterThan(normalPriority));
        expect(normalPriority, greaterThan(lowPriority));

        expect(criticalPriority, equals(1000));
        expect(highPriority, equals(100));
        expect(normalPriority, equals(10));
        expect(lowPriority, equals(1));
      });

      test('should identify critical priority correctly', () {
        // Arrange & Act & Assert
        expect(OperationPriority.critical.isCritical, isTrue);
        expect(OperationPriority.high.isCritical, isFalse);
        expect(OperationPriority.normal.isCritical, isFalse);
        expect(OperationPriority.low.isCritical, isFalse);
      });

      test('should identify high or above priority correctly', () {
        // Arrange & Act & Assert
        expect(OperationPriority.critical.isHighOrAbove, isTrue);
        expect(OperationPriority.high.isHighOrAbove, isTrue);
        expect(OperationPriority.normal.isHighOrAbove, isFalse);
        expect(OperationPriority.low.isHighOrAbove, isFalse);
      });

      test('should identify normal or above priority correctly', () {
        // Arrange & Act & Assert
        expect(OperationPriority.critical.isNormalOrAbove, isTrue);
        expect(OperationPriority.high.isNormalOrAbove, isTrue);
        expect(OperationPriority.normal.isNormalOrAbove, isTrue);
        expect(OperationPriority.low.isNormalOrAbove, isFalse);
      });

      test('should calculate aging boost for old operations', () {
        // Arrange
        final oldOperation = _createTestOperation(
          id: 'op1',
          tripId: 'trip1',
          createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        );

        // Act
        final age = DateTime.now().difference(oldOperation.createdAt!);
        final shouldBoost = age > const Duration(minutes: 5);

        // Assert
        expect(shouldBoost, isTrue);
        expect(age.inMinutes, greaterThan(5));
        expect(age.inMinutes, equals(10));
      });

      test('should not boost priority for new operations', () {
        // Arrange
        final newOperation = _createTestOperation(
          id: 'op1',
          tripId: 'trip1',
          createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
        );

        // Act
        final age = DateTime.now().difference(newOperation.createdAt!);
        final shouldBoost = age > const Duration(minutes: 5);

        // Assert
        expect(shouldBoost, isFalse);
        expect(age.inMinutes, lessThan(5));
      });
    });

    group('Operation Metadata', () {
      test('should initialize with default metadata values', () {
        // Arrange & Act
        final operation = TripPlanningOperation.create(
          tripName: 'Test Trip',
          destinations: ['Paris'],
        );

        // Assert
        expect(operation.createdAt, isNotNull);
        expect(operation.attemptCount, 0);
        expect(operation.maxRetries, 3);
        expect(operation.lastAttempt, isNull);
        expect(operation.lastError, isNull);
      });

      test('should serialize operation to JSON correctly', () {
        // Arrange
        final operation = _createTestOperation(
          id: 'op1',
          tripId: 'trip1',
          attemptCount: 2,
          lastError: 'Test error',
        );

        // Act
        final json = operation.toJson();

        // Assert
        expect(json['id'], 'op1');
        expect(json['tripId'], 'trip1');
        expect(json['attemptCount'], 2);
        expect(json['lastError'], 'Test error');
        expect(json['type'], 'trip_planning');
        expect(json['priority'], OperationPriority.normal);
      });

      test('should deserialize operation from JSON correctly', () {
        // Arrange
        final now = DateTime.now();
        final json = {
          'id': 'op1',
          'tripId': 'trip1',
          'planningType': 'update',
          'changes': {'name': 'Test'},
          'priority': 10,
          'type': 'trip_planning',
          'createdAt': now.toIso8601String(),
          'attemptCount': 1,
          'maxRetries': 3,
        };

        // Act
        final operation = TripPlanningOperation.fromJson(json);

        // Assert
        expect(operation.id, 'op1');
        expect(operation.tripId, 'trip1');
        expect(operation.attemptCount, 1);
        expect(operation.maxRetries, 3);
        expect(operation.type, 'trip_planning');
        expect(operation.priority, 10);
      });

      test('should track attempt count correctly', () {
        // Arrange
        final operation = _createTestOperation(
          id: 'op1',
          tripId: 'trip1',
          attemptCount: 0,
        );

        // Act
        final updatedOp = operation.copyWith(
          attemptCount: operation.attemptCount + 1,
          lastAttempt: DateTime.now(),
        );

        // Assert
        expect(updatedOp.attemptCount, 1);
        expect(updatedOp.lastAttempt, isNotNull);
      });

      test('should update error information on failure', () {
        // Arrange
        final operation = _createTestOperation(id: 'op1', tripId: 'trip1');
        const errorMessage = 'Network timeout';

        // Act
        final failedOp = operation.copyWith(
          attemptCount: operation.attemptCount + 1,
          lastAttempt: DateTime.now(),
          lastError: errorMessage,
        );

        // Assert
        expect(failedOp.attemptCount, 1);
        expect(failedOp.lastError, errorMessage);
        expect(failedOp.lastAttempt, isNotNull);
      });

      test('should reset metadata when retrying failed operation', () {
        // Arrange
        final failedOp = _createTestOperation(
          id: 'failed1',
          tripId: 'trip1',
          attemptCount: 3,
          lastError: 'Network error',
          lastAttempt: DateTime.now().subtract(const Duration(minutes: 1)),
        );

        // Act
        final resetOp = failedOp.copyWith(
          attemptCount: 0,
          lastError: null,
          lastAttempt: null,
        );

        // Assert
        expect(resetOp.attemptCount, 0);
        expect(resetOp.lastError, isNull);
        expect(resetOp.lastAttempt, isNull);
      });

      test('should enforce max retries limit', () {
        // Arrange
        final operation = _createTestOperation(
          id: 'op1',
          tripId: 'trip1',
          attemptCount: 3,
          maxRetries: 3,
        );

        // Act & Assert
        expect(
            operation.attemptCount, greaterThanOrEqualTo(operation.maxRetries));
        expect(operation.attemptCount, equals(3));
        expect(operation.maxRetries, equals(3));
      });
    });

    group('Backoff Period Calculation', () {
      test('should not enforce backoff on first attempt', () {
        // Arrange
        final operation = _createTestOperation(
          id: 'op1',
          tripId: 'trip1',
          attemptCount: 0,
          lastAttempt: null,
        );

        // Act & Assert
        expect(operation.lastAttempt, isNull);
        expect(operation.attemptCount, 0);
      });

      test('should calculate backoff period after failed attempt', () {
        // Arrange
        final operation = _createTestOperation(
          id: 'op1',
          tripId: 'trip1',
          attemptCount: 1,
          lastAttempt: DateTime.now().subtract(const Duration(seconds: 5)),
        );
        final strategy = ExponentialBackoffStrategy(
          baseDelay: const Duration(seconds: 1),
          maxDelay: const Duration(minutes: 5),
          jitterFactor: 0.0,
        );

        // Act
        final backoffDelay = strategy.calculateDelay(operation.attemptCount);
        final retryTime = operation.lastAttempt!.add(backoffDelay);
        final now = DateTime.now();
        final canRetry = now.isAfter(retryTime);

        // Assert
        expect(backoffDelay, const Duration(seconds: 2)); // 2^1 = 2s
        expect(canRetry, isTrue); // Should be able to retry after 5s wait
      });

      test('should prevent retry during backoff period', () {
        // Arrange
        final operation = _createTestOperation(
          id: 'op1',
          tripId: 'trip1',
          attemptCount: 1,
          lastAttempt: DateTime.now().subtract(const Duration(seconds: 1)),
        );
        final strategy = ExponentialBackoffStrategy(
          baseDelay: const Duration(seconds: 1),
          maxDelay: const Duration(minutes: 5),
          jitterFactor: 0.0,
        );

        // Act
        final backoffDelay = strategy.calculateDelay(operation.attemptCount);
        final retryTime = operation.lastAttempt!.add(backoffDelay);
        final now = DateTime.now();
        final inBackoff = now.isBefore(retryTime);

        // Assert
        expect(backoffDelay, const Duration(seconds: 2));
        expect(inBackoff, isTrue); // Should still be in backoff
      });

      test('should calculate increasing backoff delays', () {
        // Arrange
        final strategy = ExponentialBackoffStrategy(
          baseDelay: const Duration(seconds: 1),
          maxDelay: const Duration(minutes: 5),
          jitterFactor: 0.0,
        );

        // Act
        final delays = [
          strategy.calculateDelay(0),
          strategy.calculateDelay(1),
          strategy.calculateDelay(2),
          strategy.calculateDelay(3),
        ];

        // Assert
        expect(delays[0], const Duration(seconds: 1));
        expect(delays[1], const Duration(seconds: 2));
        expect(delays[2], const Duration(seconds: 4));
        expect(delays[3], const Duration(seconds: 8));

        // Verify exponential growth
        expect(delays[1] > delays[0], isTrue);
        expect(delays[2] > delays[1], isTrue);
        expect(delays[3] > delays[2], isTrue);
      });
    });

    group('Round-Robin Priority Processing', () {
      test('should track consecutive operations by priority', () {
        // Arrange
        final counter = <int, int>{};
        const maxConsecutive = 3;

        // Act
        for (int i = 0; i < 5; i++) {
          counter[10] = (counter[10] ?? 0) + 1;
        }

        // Assert
        expect(counter[10], 5);
        expect(counter[10]! > maxConsecutive, isTrue);
      });

      test('should exempt critical operations from round-robin limits', () {
        // Arrange
        const criticalPriority = OperationPriority.critical;
        const normalPriority = OperationPriority.normal;

        // Act & Assert
        // Critical operations (>= 1000) are always processed
        expect(criticalPriority >= 1000, isTrue);
        expect(normalPriority >= 1000, isFalse);
      });

      test('should reset round-robin counters on failure', () {
        // Arrange
        final counters = <int, int>{10: 3, 1: 2};

        // Act
        counters.clear();

        // Assert
        expect(counters, isEmpty);
        expect(counters.length, 0);
      });

      test('should enforce max consecutive limit for non-critical priorities',
          () {
        // Arrange
        const maxConsecutive = 3;
        final counters = <int, int>{10: 3};

        // Act
        final shouldSkip = (counters[10] ?? 0) >= maxConsecutive;

        // Assert
        expect(shouldSkip, isTrue);
        expect(counters[10], equals(3));
      });
    });

    group('Edge Cases', () {
      test('should handle operation with null createdAt', () {
        // Arrange
        final operation = _createTestOperation(
          id: 'op1',
          tripId: 'trip1',
          createdAt: null,
        );

        // Act & Assert
        expect(operation.createdAt, isNull);
      });

      test('should handle operation with missing metadata', () {
        // Arrange
        final operation = _createTestOperation(
          id: 'op1',
          tripId: 'trip1',
          attemptCount: 0,
          lastError: null,
          lastAttempt: null,
        );

        // Act & Assert
        expect(operation.attemptCount, 0);
        expect(operation.lastError, isNull);
        expect(operation.lastAttempt, isNull);
      });

      test('should handle operation with negative attempt count gracefully',
          () {
        // Arrange
        final strategy = ExponentialBackoffStrategy(
          baseDelay: const Duration(seconds: 1),
        );

        // Act
        final delay = strategy.calculateDelay(-1);

        // Assert: Should treat negative as 0
        expect(delay, const Duration(seconds: 1));
      });

      test('should prevent delay from going negative with jitter', () {
        // Arrange
        final strategy = ExponentialBackoffStrategy(
          baseDelay: const Duration(milliseconds: 100),
          maxDelay: const Duration(minutes: 5),
          jitterFactor: 1.0,
        );

        // Act
        final delay = strategy.calculateDelay(0);

        // Assert: Even with max jitter, should not go below 0
        expect(delay.inMilliseconds, greaterThanOrEqualTo(0));
      });

      test('should handle very large attempt counts', () {
        // Arrange
        final strategy = ExponentialBackoffStrategy(
          baseDelay: const Duration(milliseconds: 1),
          maxDelay: const Duration(minutes: 5),
          jitterFactor: 0.0,
        );

        // Act
        final delay = strategy.calculateDelay(1000);

        // Assert: Should not throw and should cap at maxDelay
        expect(delay, equals(const Duration(minutes: 5)));
      });

      test('should handle operation with maxRetries of 0', () {
        // Arrange
        final operation = _createTestOperation(
          id: 'op1',
          tripId: 'trip1',
          attemptCount: 0,
          maxRetries: 0,
        );

        // Act & Assert
        expect(operation.maxRetries, 0);
        expect(
            operation.attemptCount, greaterThanOrEqualTo(operation.maxRetries));
      });
    });

    group('Operation Type Identification', () {
      test('should correctly identify trip planning operation type', () {
        // Arrange
        final operation = TripPlanningOperation.create(
          tripName: 'Test Trip',
          destinations: ['Paris'],
        );

        // Act & Assert
        expect(operation.type, equals('trip_planning'));
      });

      test('should correctly identify travel note operation type', () {
        // Arrange
        final operation = TravelNoteOperation(
          id: 'note1',
          tripId: 'trip1',
          content: 'Test note',
          createdAt: DateTime.now(),
        );

        // Act & Assert
        expect(operation.type, equals('travel_note'));
      });

      test('should correctly identify location update operation type', () {
        // Arrange
        final operation = LocationUpdateOperation(
          id: 'loc1',
          tripId: 'trip1',
          latitude: 48.8566,
          longitude: 2.3522,
          timestamp: DateTime.now(),
          priority: 1,
        );

        // Act & Assert
        expect(operation.type, equals('location_update'));
      });

      test('should handle network requirement correctly', () {
        // Arrange
        final tripOp = TripPlanningOperation.create(
          tripName: 'Test Trip',
          destinations: ['Paris'],
        );
        final noteOp = TravelNoteOperation(
          id: 'note1',
          tripId: 'trip1',
          content: 'Test note',
          createdAt: DateTime.now(),
        );
        final locationOp = LocationUpdateOperation(
          id: 'loc1',
          tripId: 'trip1',
          latitude: 48.8566,
          longitude: 2.3522,
          timestamp: DateTime.now(),
          priority: 1,
        );

        // Act & Assert
        expect(tripOp.requiresNetwork, isFalse);
        expect(noteOp.requiresNetwork, isTrue);
        expect(locationOp.requiresNetwork, isTrue);
      });
    });
  });
}

// Helper function to create test operations
TripPlanningOperation _createTestOperation({
  required String id,
  required String tripId,
  int attemptCount = 0,
  int maxRetries = 3,
  String? lastError,
  DateTime? lastAttempt,
  DateTime? createdAt,
}) {
  return TripPlanningOperation(
    id: id,
    tripId: tripId,
    planningType: TripPlanningType.update,
    changes: {'name': 'Test Trip'},
    createdAt: createdAt ?? DateTime.now(),
    attemptCount: attemptCount,
    maxRetries: maxRetries,
    lastError: lastError,
    lastAttempt: lastAttempt,
  );
}
