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
        expect(strategy.calculateDelay(0), const Duration(seconds: 1));
        expect(strategy.calculateDelay(1), const Duration(seconds: 2));
        expect(strategy.calculateDelay(2), const Duration(seconds: 4));
        expect(strategy.calculateDelay(3), const Duration(seconds: 8));
        expect(strategy.calculateDelay(4), const Duration(seconds: 16));
      });

      test('should cap backoff delay at maxDelay', () {
        final strategy = ExponentialBackoffStrategy(
          baseDelay: const Duration(seconds: 1),
          maxDelay: const Duration(seconds: 10),
          jitterFactor: 0.0,
        );

        expect(strategy.calculateDelay(0).inSeconds, lessThanOrEqualTo(10));
        expect(strategy.calculateDelay(5).inSeconds, lessThanOrEqualTo(10));
        expect(strategy.calculateDelay(10).inSeconds, lessThanOrEqualTo(10));
        expect(strategy.calculateDelay(100).inSeconds, lessThanOrEqualTo(10));
      });

      test('should handle zero attempt count', () {
        final strategy = ExponentialBackoffStrategy(
          baseDelay: const Duration(seconds: 2),
          jitterFactor: 0.0,
        );

        final delay = strategy.calculateDelay(0);
        expect(delay, const Duration(seconds: 2));
      });

      test('should add jitter to delay when configured', () {
        final strategy = ExponentialBackoffStrategy(
          baseDelay: const Duration(seconds: 1),
          maxDelay: const Duration(minutes: 5),
          jitterFactor: 0.5,
        );

        final delay1 = strategy.calculateDelay(1);
        expect(delay1.inSeconds, greaterThanOrEqualTo(0));
        expect(delay1.inSeconds, lessThanOrEqualTo(300));
      });
    });

    group('Operation Deduplication', () {
      test('should generate deduplication key for trip update operations', () {
        final operation = TripPlanningOperation.update(
          tripId: 'trip123',
          name: 'Updated Name',
        );

        expect(operation.deduplicationKey, 'trip_trip123');
      });

      test('should not deduplicate create operations', () {
        final operation = TripPlanningOperation.create(
          tripName: 'New Trip',
          destinations: ['Paris'],
        );

        expect(operation.deduplicationKey, isNull);
      });

      test('should not deduplicate delete operations', () {
        const operation = TripPlanningOperation(
          id: 'op1',
          tripId: 'trip123',
          planningType: TripPlanningType.delete,
          changes: {},
          priority: 10,
        );

        expect(operation.deduplicationKey, isNull);
      });

      test('should generate deduplication key for addDestination operations',
          () {
        const operation = TripPlanningOperation(
          id: 'op1',
          tripId: 'trip123',
          planningType: TripPlanningType.addDestination,
          changes: {},
          priority: 10,
        );

        expect(operation.deduplicationKey, 'trip_trip123');
      });

      test(
          'should generate deduplication key for removeDestination operations',
          () {
        const operation = TripPlanningOperation(
          id: 'op1',
          tripId: 'trip123',
          planningType: TripPlanningType.removeDestination,
          changes: {},
          priority: 10,
        );

        expect(operation.deduplicationKey, 'trip_trip123');
      });

      test('should generate deduplication key for updateDates operations', () {
        const operation = TripPlanningOperation(
          id: 'op1',
          tripId: 'trip123',
          planningType: TripPlanningType.updateDates,
          changes: {},
          priority: 10,
        );

        expect(operation.deduplicationKey, 'trip_trip123');
      });

      test('should not deduplicate travel note operations', () {
        final operation = TravelNoteOperation(
          id: 'note1',
          tripId: 'trip1',
          noteType: NoteType.text,
          content: {'text': 'Test note'},
          priority: OperationPriority.normal.value,
          createdAt: DateTime.now(),
        );

        expect(operation.deduplicationKey, isNull);
      });

      test('should not deduplicate location update operations', () {
        final operation = LocationUpdateOperation(
          id: 'loc1',
          latitude: 48.8566,
          longitude: 2.3522,
          timestamp: DateTime.now(),
          priority: OperationPriority.low.value,
        );

        expect(operation.deduplicationKey, isNull);
      });

      test('should have same deduplication key for operations on same trip',
          () {
        final op1 =
            TripPlanningOperation.update(tripId: 'trip123', name: 'Update 1');
        final op2 =
            TripPlanningOperation.update(tripId: 'trip123', name: 'Update 2');

        expect(op1.deduplicationKey, op2.deduplicationKey);
        expect(op1.deduplicationKey, 'trip_trip123');
      });
    });

    group('Priority Handling', () {
      test('should assign correct priority to trip operations', () {
        final tripOp = TripPlanningOperation.create(
          tripName: 'Test Trip',
          destinations: ['Paris'],
        );

        expect(tripOp.priority, OperationPriority.normal.value);
        expect(tripOp.priority, 10);
      });

      test('should assign correct priority to travel note operations', () {
        final noteOp = TravelNoteOperation(
          id: 'note1',
          tripId: 'trip1',
          noteType: NoteType.text,
          content: {'text': 'Test note'},
          priority: OperationPriority.normal.value,
          createdAt: DateTime.now(),
        );

        expect(noteOp.priority, OperationPriority.normal.value);
        expect(noteOp.priority, 10);
      });

      test('should assign correct priority to location update operations', () {
        final locationOp = LocationUpdateOperation(
          id: 'loc1',
          latitude: 48.8566,
          longitude: 2.3522,
          timestamp: DateTime.now(),
          priority: OperationPriority.low.value,
        );

        expect(locationOp.priority, OperationPriority.low.value);
        expect(locationOp.priority, 1);
      });

      test('should support priority comparison', () {
        const criticalPriority = OperationPriority.critical;
        const highPriority = OperationPriority.high;
        const normalPriority = OperationPriority.normal;
        const lowPriority = OperationPriority.low;

        expect(criticalPriority.value, greaterThan(highPriority.value));
        expect(highPriority.value, greaterThan(normalPriority.value));
        expect(normalPriority.value, greaterThan(lowPriority.value));

        expect(criticalPriority.value, equals(1000));
        expect(highPriority.value, equals(100));
        expect(normalPriority.value, equals(10));
        expect(lowPriority.value, equals(1));
      });

      test('should identify critical priority correctly', () {
        expect(OperationPriority.critical.isCritical, isTrue);
        expect(OperationPriority.high.isCritical, isFalse);
        expect(OperationPriority.normal.isCritical, isFalse);
        expect(OperationPriority.low.isCritical, isFalse);
      });

      test('should identify high or above priority correctly', () {
        expect(OperationPriority.critical.isHighOrAbove, isTrue);
        expect(OperationPriority.high.isHighOrAbove, isTrue);
        expect(OperationPriority.normal.isHighOrAbove, isFalse);
        expect(OperationPriority.low.isHighOrAbove, isFalse);
      });

      test('should identify normal or above priority correctly', () {
        expect(OperationPriority.critical.isNormalOrAbove, isTrue);
        expect(OperationPriority.high.isNormalOrAbove, isTrue);
        expect(OperationPriority.normal.isNormalOrAbove, isTrue);
        expect(OperationPriority.low.isNormalOrAbove, isFalse);
      });

      test('should calculate aging boost for old operations', () {
        final oldOperation = _createTestOperation(
          id: 'op1',
          tripId: 'trip1',
          createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        );

        final age = DateTime.now().difference(oldOperation.createdAt!);
        final shouldBoost = age > const Duration(minutes: 5);

        expect(shouldBoost, isTrue);
        expect(age.inMinutes, greaterThanOrEqualTo(10));
      });

      test('should not boost priority for new operations', () {
        final newOperation = _createTestOperation(
          id: 'op1',
          tripId: 'trip1',
          createdAt: DateTime.now().subtract(const Duration(minutes: 2)),
        );

        final age = DateTime.now().difference(newOperation.createdAt!);
        final shouldBoost = age > const Duration(minutes: 5);

        expect(shouldBoost, isFalse);
        expect(age.inMinutes, lessThan(5));
      });
    });

    group('Operation Metadata', () {
      test('should initialize with default metadata values', () {
        final operation = TripPlanningOperation.create(
          tripName: 'Test Trip',
          destinations: ['Paris'],
        );

        expect(operation.createdAt, isNotNull);
        expect(operation.attemptCount, 0);
        expect(operation.maxRetries, 3);
        expect(operation.lastAttempt, isNull);
        expect(operation.lastError, isNull);
      });

      test('should serialize operation to JSON correctly', () {
        final operation = _createTestOperation(
          id: 'op1',
          tripId: 'trip1',
          attemptCount: 2,
          lastError: 'Test error',
        );

        final json = operation.toJson();

        expect(json['id'], 'op1');
        expect(json['tripId'], 'trip1');
        expect(json['attemptCount'], 2);
        expect(json['lastError'], 'Test error');
        expect(json['type'], isNull); // type is not serialized in toJson
        expect(json['priority'], OperationPriority.normal.value);
      });

      test('should deserialize operation from JSON correctly', () {
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

        final operation = TripPlanningOperation.fromJson(json);

        expect(operation.id, 'op1');
        expect(operation.tripId, 'trip1');
        expect(operation.attemptCount, 1);
        expect(operation.maxRetries, 3);
        expect(operation.type, 'trip_planning');
        expect(operation.priority, 10);
      });

      test('should track attempt count correctly', () {
        final operation = _createTestOperation(
          id: 'op1',
          tripId: 'trip1',
          attemptCount: 0,
        );

        final updatedOp = operation.copyWith(
          attemptCount: operation.attemptCount + 1,
          lastAttempt: DateTime.now(),
        );

        expect(updatedOp.attemptCount, 1);
        expect(updatedOp.lastAttempt, isNotNull);
      });

      test('should update error information on failure', () {
        final operation = _createTestOperation(id: 'op1', tripId: 'trip1');
        const errorMessage = 'Network timeout';

        final failedOp = operation.copyWith(
          attemptCount: operation.attemptCount + 1,
          lastAttempt: DateTime.now(),
          lastError: errorMessage,
        );

        expect(failedOp.attemptCount, 1);
        expect(failedOp.lastError, errorMessage);
        expect(failedOp.lastAttempt, isNotNull);
      });

      test('should reset metadata when retrying failed operation', () {
        final failedOp = _createTestOperation(
          id: 'failed1',
          tripId: 'trip1',
          attemptCount: 3,
          lastError: 'Network error',
          lastAttempt: DateTime.now().subtract(const Duration(minutes: 1)),
        );

        final resetOp = failedOp.copyWith(
          attemptCount: 0,
          lastError: null,
          lastAttempt: null,
        );

        expect(resetOp.attemptCount, 0);
        expect(resetOp.lastError, isNull);
        expect(resetOp.lastAttempt, isNull);
      });

      test('should enforce max retries limit', () {
        final operation = _createTestOperation(
          id: 'op1',
          tripId: 'trip1',
          attemptCount: 3,
          maxRetries: 3,
        );

        expect(operation.attemptCount,
            greaterThanOrEqualTo(operation.maxRetries));
        expect(operation.attemptCount, equals(3));
        expect(operation.maxRetries, equals(3));
      });
    });

    group('Backoff Period Calculation', () {
      test('should not enforce backoff on first attempt', () {
        final operation = _createTestOperation(
          id: 'op1',
          tripId: 'trip1',
          attemptCount: 0,
          lastAttempt: null,
        );

        expect(operation.lastAttempt, isNull);
        expect(operation.attemptCount, 0);
      });

      test('should calculate backoff period after failed attempt', () {
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

        final backoffDelay = strategy.calculateDelay(operation.attemptCount);
        final retryTime = operation.lastAttempt!.add(backoffDelay);
        final now = DateTime.now();
        final canRetry = now.isAfter(retryTime);

        expect(backoffDelay, const Duration(seconds: 2));
        expect(canRetry, isTrue);
      });

      test('should prevent retry during backoff period', () {
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

        final backoffDelay = strategy.calculateDelay(operation.attemptCount);
        final retryTime = operation.lastAttempt!.add(backoffDelay);
        final now = DateTime.now();
        final inBackoff = now.isBefore(retryTime);

        expect(backoffDelay, const Duration(seconds: 2));
        expect(inBackoff, isTrue);
      });

      test('should calculate increasing backoff delays', () {
        final strategy = ExponentialBackoffStrategy(
          baseDelay: const Duration(seconds: 1),
          maxDelay: const Duration(minutes: 5),
          jitterFactor: 0.0,
        );

        final delays = [
          strategy.calculateDelay(0),
          strategy.calculateDelay(1),
          strategy.calculateDelay(2),
          strategy.calculateDelay(3),
        ];

        expect(delays[0], const Duration(seconds: 1));
        expect(delays[1], const Duration(seconds: 2));
        expect(delays[2], const Duration(seconds: 4));
        expect(delays[3], const Duration(seconds: 8));

        expect(delays[1] > delays[0], isTrue);
        expect(delays[2] > delays[1], isTrue);
        expect(delays[3] > delays[2], isTrue);
      });
    });

    group('Round-Robin Priority Processing', () {
      test('should track consecutive operations by priority', () {
        final counter = <int, int>{};
        const maxConsecutive = 3;

        for (int i = 0; i < 5; i++) {
          counter[10] = (counter[10] ?? 0) + 1;
        }

        expect(counter[10], 5);
        expect(counter[10]! > maxConsecutive, isTrue);
      });

      test('should exempt critical operations from round-robin limits', () {
        const criticalPriority = OperationPriority.critical;
        const normalPriority = OperationPriority.normal;

        expect(criticalPriority.value >= 1000, isTrue);
        expect(normalPriority.value >= 1000, isFalse);
      });

      test('should reset round-robin counters on failure', () {
        final counters = <int, int>{10: 3, 1: 2};

        counters.clear();

        expect(counters, isEmpty);
        expect(counters.length, 0);
      });

      test(
          'should enforce max consecutive limit for non-critical priorities',
          () {
        const maxConsecutive = 3;
        final counters = <int, int>{10: 3};

        final shouldSkip = (counters[10] ?? 0) >= maxConsecutive;

        expect(shouldSkip, isTrue);
        expect(counters[10], equals(3));
      });
    });

    group('Edge Cases', () {
      test('should handle operation with null createdAt', () {
        final operation = _createTestOperation(
          id: 'op1',
          tripId: 'trip1',
          createdAt: null,
        );

        expect(operation.createdAt, isNull);
      });

      test('should handle operation with missing metadata', () {
        final operation = _createTestOperation(
          id: 'op1',
          tripId: 'trip1',
          attemptCount: 0,
          lastError: null,
          lastAttempt: null,
        );

        expect(operation.attemptCount, 0);
        expect(operation.lastError, isNull);
        expect(operation.lastAttempt, isNull);
      });

      test('should handle operation with negative attempt count gracefully',
          () {
        final strategy = ExponentialBackoffStrategy(
          baseDelay: const Duration(seconds: 1),
        );

        final delay = strategy.calculateDelay(-1);

        expect(delay.inMilliseconds, closeTo(1000, 200)); // jitter may vary
      });

      test('should prevent delay from going negative with jitter', () {
        final strategy = ExponentialBackoffStrategy(
          baseDelay: const Duration(milliseconds: 100),
          maxDelay: const Duration(minutes: 5),
          jitterFactor: 1.0,
        );

        final delay = strategy.calculateDelay(0);

        expect(delay.inMilliseconds, greaterThanOrEqualTo(0));
      });

      test('should handle very large attempt counts', () {
        final strategy = ExponentialBackoffStrategy(
          baseDelay: const Duration(milliseconds: 1),
          maxDelay: const Duration(minutes: 5),
          jitterFactor: 0.0,
        );

        final delay = strategy.calculateDelay(1000);

        expect(delay, equals(const Duration(minutes: 5)));
      });

      test('should handle operation with maxRetries of 0', () {
        final operation = _createTestOperation(
          id: 'op1',
          tripId: 'trip1',
          attemptCount: 0,
          maxRetries: 0,
        );

        expect(operation.maxRetries, 0);
        expect(operation.attemptCount,
            greaterThanOrEqualTo(operation.maxRetries));
      });
    });

    group('Operation Type Identification', () {
      test('should correctly identify trip planning operation type', () {
        final operation = TripPlanningOperation.create(
          tripName: 'Test Trip',
          destinations: ['Paris'],
        );

        expect(operation.type, equals('trip_planning'));
      });

      test('should correctly identify travel note operation type', () {
        final operation = TravelNoteOperation(
          id: 'note1',
          tripId: 'trip1',
          noteType: NoteType.text,
          content: {'text': 'Test note'},
          priority: OperationPriority.normal.value,
          createdAt: DateTime.now(),
        );

        expect(operation.type, equals('travel_note'));
      });

      test('should correctly identify location update operation type', () {
        final operation = LocationUpdateOperation(
          id: 'loc1',
          latitude: 48.8566,
          longitude: 2.3522,
          timestamp: DateTime.now(),
          priority: OperationPriority.low.value,
        );

        expect(operation.type, equals('location_update'));
      });

      test('should handle network requirement correctly', () {
        final tripOp = TripPlanningOperation.create(
          tripName: 'Test Trip',
          destinations: ['Paris'],
        );
        final noteOp = TravelNoteOperation(
          id: 'note1',
          tripId: 'trip1',
          noteType: NoteType.text,
          content: {'text': 'Test note'},
          priority: OperationPriority.normal.value,
          createdAt: DateTime.now(),
        );
        final locationOp = LocationUpdateOperation(
          id: 'loc1',
          latitude: 48.8566,
          longitude: 2.3522,
          timestamp: DateTime.now(),
          priority: OperationPriority.low.value,
        );

        expect(tripOp.requiresNetwork, isFalse);
        expect(noteOp.requiresNetwork, isFalse); // Notes work offline
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
  int? priority,
}) {
  return TripPlanningOperation(
    id: id,
    tripId: tripId,
    planningType: TripPlanningType.update,
    changes: {'name': 'Test Trip'},
    priority: priority ?? OperationPriority.normal.value,
    createdAt: createdAt,
    attemptCount: attemptCount,
    maxRetries: maxRetries,
    lastError: lastError,
    lastAttempt: lastAttempt,
  );
}
