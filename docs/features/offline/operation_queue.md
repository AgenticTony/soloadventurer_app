# Operation Queue System

## Overview and Purpose

The Operation Queue system provides a reliable, persistent queue for executing network operations, particularly in offline-first scenarios. It ensures that user actions are never lost, even when the device is offline or the server is temporarily unavailable.

### Key Features

- **Persistence**: Operations survive app restarts and device reboots
- **Retry Logic**: Failed operations retry with exponential backoff
- **Deduplication**: Redundant operations automatically replace older versions
- **Priority Processing**: Critical operations (like SOS) execute before normal operations
- **Offline Support**: Queue operations when offline, execute when online
- **User Control**: View, retry, or clear failed operations through the UI

### Use Cases

- **Travelers**: Queue trip updates on flights, sync when WiFi is available
- **Poor Connectivity**: Areas with spotty network coverage won't lose data
- **Server Outages**: Continue using the app during downtime, sync when restored
- **Background Sync**: Seamlessly sync data without user intervention

---

## Architecture

### System Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     Operation Queue System                    │
├─────────────────────────────────────────────────────────────┤
│                                                               │
│  ┌─────────────┐    ┌──────────────┐    ┌──────────────┐   │
│  │   Service   │───▶│   Storage    │───▶│   SharedPreferences│
│  │   Provider  │    │   Service    │    │   (Pending/Failed) │
│  └─────────────┘    └──────────────┘    └──────────────┘   │
│         │                   │                                 │
│         ▼                   ▼                                 │
│  ┌──────────────────────────────────────────────────────┐   │
│  │              Operation Queue (Riverpod)              │   │
│  │  • Pending Operations Queue (Priority Sorted)        │   │
│  │  • Failed Operations List                           │   │
│  │  • Retry Strategy (Exponential Backoff)             │   │
│  │  • Processing Timer (30s intervals)                 │   │
│  └──────────────────────────────────────────────────────┘   │
│         │                                                     │
│         ▼                                                     │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         QueueableOperation Interface                  │   │
│  │  • id, type, priority                                │   │
│  │  • requiresNetwork, deduplicationKey                 │   │
│  │  • retry metadata (attemptCount, lastError, etc.)    │   │
│  └──────────────────────────────────────────────────────┘   │
│         │                                                     │
│         ▼                                                     │
│  ┌──────────────────────────────────────────────────────┐   │
│  │         Operation Implementations                      │   │
│  │  • TripPlanningOperation                             │   │
│  │  • TravelNoteOperation                               │   │
│  │  • LocationUpdateOperation                           │   │
│  └──────────────────────────────────────────────────────┘   │
│                                                               │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────┐  │
│  │  UI Screen   │    │  Status      │    │  Riverpod    │  │
│  │  (Queue      │    │  Indicator   │    │  Provider    │  │
│  │   Display)   │    │  (Badge)     │    │  (State)     │  │
│  └──────────────┘    └──────────────┘    └──────────────┘  │
│                                                               │
└─────────────────────────────────────────────────────────────┘
```

### Component Relationships

```
OperationQueue (Riverpod Provider)
    │
    ├─── Uses ───▶ OperationStorageService
    │                   │
    │                   ├─── savePendingOperations()
    │                   ├─── saveFailedOperations()
    │                   └─── loadOperations()
    │
    ├─── Uses ───▶ RetryStrategy
    │                   │
    │                   ├─── ExponentialBackoffStrategy
    │                   ├─── FixedDelayStrategy
    │                   └─── LinearBackoffStrategy
    │
    ├─── Uses ───▶ ConnectivityProvider (Network Status)
    │
    ├─── Uses ───▶ TokenManagerProvider (Auth Status)
    │
    └─── Manages ───▶ QueueableOperation
                            │
                            ├─── TripPlanningOperation
                            ├─── TravelNoteOperation
                            └─── LocationUpdateOperation
```

### Data Flow

**Adding an Operation:**
```
User Action
    │
    ▼
Create Operation (e.g., TripPlanningOperation.update())
    │
    ▼
Queue.addOperation(operation)
    │
    ├─── Check for duplicate (if deduplicationKey exists)
    ├─── Replace duplicate OR add to queue
    ├─── Persist to storage
    └─── Process immediately if conditions are right
```

**Processing the Queue:**
```
Timer (every 30s) OR Manual Trigger
    │
    ▼
Queue.processQueue()
    │
    ├─── Check connectivity & auth status
    ├─── Sort operations by effective priority
    ├─── For each operation:
    │       │
    │       ├─── Can process? (online, auth, backoff period)
    │       ├─── Round-robin limit reached? (skip if yes)
    │       ├─── Max retries exceeded? (move to failed)
    │       ├─── Execute operation
    │       ├─── Success? Remove from queue
    │       └─── Failure? Update metadata, retry later
    │
    └─── Persist updated state
```

---

## How to Create Custom Operations

### Step 1: Implement the QueueableOperation Interface

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/operation_queue.dart';
import '../../../core/services/operation_priority.dart';

part 'my_custom_operation.freezed.dart';
part 'my_custom_operation.g.dart';

@freezed
class MyCustomOperation with _$MyCustomOperation implements QueueableOperation {
  const factory MyCustomOperation({
    required String id,
    required String type,
    @Default(OperationPriority.normal) int priority,
    DateTime? createdAt,
    DateTime? lastAttempt,
    @Default(0) int attemptCount,
    String? lastError,
    @Default(3) int maxRetries,
    // Add your custom fields here
    required String resourceId,
    required Map<String, dynamic> data,
  }) = _MyCustomOperation;

  factory MyCustomOperation.fromJson(Map<String, dynamic> json) =>
      _$MyCustomOperationFromJson(json);

  const MyCustomOperation._();
}
```

### Step 2: Define Factory Constructors

```dart
  /// Create a new custom operation
  factory MyCustomOperation.create({
    required String resourceId,
    required Map<String, dynamic> data,
  }) {
    return MyCustomOperation(
      id: const Uuid().v4(),
      type: 'my_custom_operation',
      resourceId: resourceId,
      data: data,
      createdAt: DateTime.now(),
    );
  }

  /// Update an existing resource
  factory MyCustomOperation.update({
    required String resourceId,
    required Map<String, dynamic> changes,
  }) {
    return MyCustomOperation(
      id: const Uuid().v4(),
      type: 'my_custom_operation',
      resourceId: resourceId,
      data: changes,
      createdAt: DateTime.now(),
    );
  }
```

### Step 3: Implement Required Interface Methods

```dart
  @override
  String get type => 'my_custom_operation';

  @override
  bool get requiresNetwork => true; // Set based on your needs

  @override
  String? get deduplicationKey {
    // Return deduplication key if applicable, null otherwise
    // Example: Deduplicate updates to the same resource
    return 'resource_$resourceId';
  }

  @override
  Future<void> execute() async {
    // Implement your operation logic here
    // This is where you make API calls, update local storage, etc.

    try {
      // Example: Make API call
      final response = await apiClient.updateResource(
        resourceId,
        data: data,
      );

      // Handle success
      if (response.isSuccessful) {
        debugPrint('Successfully executed operation $id');
        return;
      }

      // Handle failure - throw exception to trigger retry
      throw Exception('Operation failed: ${response.errorMessage}');
    } catch (e) {
      // Throw exception to trigger retry logic
      throw Exception('Failed to execute operation: $e');
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'resourceId': resourceId,
        'data': data,
        'priority': priority,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (lastAttempt != null) 'lastAttempt': lastAttempt!.toIso8601String(),
        'attemptCount': attemptCount,
        if (lastError != null) 'lastError': lastError,
        'maxRetries': maxRetries,
      };
```

### Step 4: Register Operation Type for Deserialization

Add your operation type to the `_deserializeOperation` method in `operation_queue.dart`:

```dart
  QueueableOperation? _deserializeOperation(Map<String, dynamic> data) {
    try {
      final type = data['type'] as String?;

      if (type == null) {
        debugPrint('OperationQueue: Missing type in operation data');
        return null;
      }

      // Dispatch to appropriate factory based on type
      switch (type) {
        case 'trip_planning':
          return TripPlanningOperation.fromJson(data);
        case 'travel_note':
          return TravelNoteOperation.fromJson(data);
        case 'location_update':
          return LocationUpdateOperation.fromJson(data);
        case 'my_custom_operation':  // Add your operation here
          return MyCustomOperation.fromJson(data);
        default:
          debugPrint('OperationQueue: Unknown operation type: $type');
          return null;
      }
    } catch (e, stackTrace) {
      debugPrint('OperationQueue: Error deserializing operation: $e');
      debugPrint('Stack trace: $stackTrace');
      return null;
    }
  }
```

### Step 5: Add Support for Metadata Updates

If your operation needs retry support, add it to the `_updateAttemptMetadata` and `_resetAttemptMetadata` methods:

```dart
  QueueableOperation _updateAttemptMetadata(
    QueueableOperation operation,
    String? error,
  ) {
    if (operation is MyCustomOperation) {
      return operation.copyWith(
        lastAttempt: DateTime.now(),
        attemptCount: operation.attemptCount + 1,
        lastError: error,
      );
    }
    // ... other operation types
  }

  QueueableOperation _resetAttemptMetadata(QueueableOperation operation) {
    if (operation is MyCustomOperation) {
      return operation.copyWith(
        lastAttempt: null,
        attemptCount: 0,
        lastError: null,
      );
    }
    // ... other operation types
  }
```

### Step 6: Using Your Custom Operation

```dart
// Create an instance of the operation queue
final operationQueue = ref.read(operationQueueProvider);

// Create and queue your custom operation
final operation = MyCustomOperation.update(
  resourceId: 'resource-123',
  changes: {'status': 'active'},
);

await operationQueue.addOperation(operation);
```

---

## Priority Levels

### Priority Hierarchy

The operation queue uses four priority levels with exponential spacing (1000, 100, 10, 1) to allow for dynamic adjustment and intermediate priorities:

```dart
enum OperationPriority {
  critical(1000),  // Emergency operations
  high(100),       // Important operations
  normal(10),      // Standard operations
  low(1),          // Background operations
}
```

### When to Use Each Priority

#### **Critical Priority (1000)**
**Use for:**
- SOS/emergency alerts
- Safety-critical operations
- Time-sensitive security operations

**Behavior:**
- Always processed before any other priority
- Exempt from round-robin limits
- Executes immediately when conditions allow

**Example:**
```dart
class SOSOperation implements QueueableOperation {
  @override
  int get priority => OperationPriority.critical.value;
}
```

#### **High Priority (100)**
**Use for:**
- Authentication operations (login, logout)
- Payment transactions
- User-initiated actions that block other work
- Data synchronization requested by user

**Behavior:**
- Processed after critical but before normal/low
- Subject to round-robin limits (max 3 consecutive)
- Should complete within 1-2 processing cycles

**Example:**
```dart
class AuthenticationOperation implements QueueableOperation {
  @override
  int get priority => OperationPriority.high.value;
}
```

#### **Normal Priority (10)**
**Use for:**
- Trip planning updates
- Travel note creation/updates
- Data synchronization (automatic)
- Content uploads

**Behavior:**
- Default for most user operations
- Processed when no higher priority work exists
- Subject to round-robin limits

**Example:**
```dart
class TripPlanningOperation implements QueueableOperation {
  @override
  int get priority => OperationPriority.normal.value;
}
```

#### **Low Priority (1)**
**Use for:**
- Location updates (high frequency, low urgency)
- Analytics tracking
- Background data refresh
- Logging/metrics uploads

**Behavior:**
- Processed only when no higher priority work exists
- Can be delayed significantly during busy periods
- May be batched for efficiency

**Example:**
```dart
class LocationUpdateOperation implements QueueableOperation {
  @override
  int get priority => OperationPriority.low.value;
}
```

### Dynamic Priority Adjustment

The queue automatically boosts priorities to prevent starvation:

**Aging Mechanism:**
- Operations waiting > 5 minutes get +20 priority boost
- Old low-priority operations can eventually surpass newer normal-priority operations
- Ensures no operation is stuck indefinitely

**Example:**
```dart
// Initial priority: Low (1)
// After 5 minutes: 21 (1 + 20)
// After 10 minutes: Can still be processed ahead of newer normal operations (10)
```

**Priority Comparison:**
```dart
final critical = OperationPriority.critical;
final normal = OperationPriority.normal;

// Check if one priority is higher
if (critical.isHigherThan(normal)) {
  print('Critical will process before normal');
}

// Dynamic adjustment
final boosted = normal.boost(by: 5);
print(boosted); // 15 (10 + 5)
```

---

## Deduplication Strategies

### What is Deduplication?

Deduplication prevents redundant operations from being queued. When a new operation is added with a deduplication key matching an existing operation, the older operation is replaced with the newer one.

### How Deduplication Works

```dart
// User updates trip name
final op1 = TripPlanningOperation.update(tripId: 'trip-123', name: 'Paris Trip');
await queue.addOperation(op1);

// User updates trip again before first update syncs
final op2 = TripPlanningOperation.update(tripId: 'trip-123', name: 'Paris Vacation');
await queue.addOperation(op2);

// Result: Only op2 is in the queue (op1 was replaced)
// This prevents sending outdated data to the server
```

### Deduplication Keys

The `deduplicationKey` getter in `QueueableOperation` determines if deduplication applies:

```dart
String? get deduplicationKey {
  // Return a key to enable deduplication
  // Return null to disable deduplication
  return 'resource_$resourceId';
}
```

### Strategies for Different Operation Types

#### **1. Update Operations (Deduplicate)**
**When to use:** Multiple updates to the same resource

**Example:** Trip updates, note edits

```dart
@override
String? get deduplicationKey {
  // Deduplicate all updates to the same trip
  if (planningType == TripPlanningType.update) {
    return 'trip_$tripId';
  }
  return null;
}
```

**Rationale:** Only the latest data matters. Sending stale updates wastes bandwidth.

#### **2. Create Operations (No Deduplication)**
**When to use:** Each operation is unique

**Example:** Creating a new trip, adding a note

```dart
@override
String? get deduplicationKey {
  // Don't deduplicate - each create is unique
  return null;
}
```

**Rationale:** Creating multiple trips or notes is intentional. Don't lose user data.

#### **3. Time-Series Data (No Deduplication)**
**When to use:** Sequential data points

**Example:** Location updates, analytics events

```dart
@override
String? get deduplicationKey {
  // Don't deduplicate - each update represents a point in time
  return null;
}
```

**Rationale:** Location updates form a history. Losing updates breaks the timeline.

### Best Practices

1. **Use Stable Keys**: Deduplication keys should be stable and deterministic
   ```dart
   // Good
   return 'trip_$tripId';

   // Bad (includes timestamp, defeats purpose)
   return 'trip_${tripId}_${DateTime.now().millisecondsSinceEpoch}';
   ```

2. **Consider User Intent**: Does replacing the old operation lose important data?
   - Trip updates: Latest data is most important (deduplicate)
   - Travel notes: All content matters (no deduplication)

3. **Document Your Strategy**: Clearly explain why deduplication is or isn't used
   ```dart
   @override
   String? get deduplicationKey {
     // Deduplicate updates to ensure only latest data is synced
     // Each update replaces previous state, so old updates are irrelevant
     if (planningType == TripPlanningType.update) {
       return 'trip_$tripId';
     }
     return null;
   }
   ```

4. **Test Edge Cases**: What happens when operations have the same key but different data?
   - Verify that the newer operation fully replaces the older one
   - Ensure no data is lost that the user expects to persist

### Operation Deduplication Examples

#### **Trip Planning Operation**

```dart
@override
String? get deduplicationKey {
  // Update operations to the same trip are deduplicated
  if (planningType == TripPlanningType.update ||
      planningType == TripPlanningType.addDestination ||
      planningType == TripPlanningType.removeDestination ||
      planningType == TripPlanningType.updateDates) {
    return 'trip_$tripId';
  }
  // Create and delete are unique - don't deduplicate
  return null;
}
```

#### **Travel Note Operation**

```dart
@override
String? get deduplicationKey {
  // Each note is unique user-generated content
  // Don't deduplicate to prevent data loss
  return null;
}
```

#### **Location Update Operation**

```dart
@override
String? get deduplicationKey {
  // Location updates are time-series data
  // Each update represents location at a specific point in time
  // Don't deduplicate to maintain complete history
  return null;
}
```

---

## Retry Configuration

### Retry Strategy Overview

Failed operations automatically retry with exponential backoff. The queue uses the `ExponentialBackoffStrategy` by default:

```dart
final retryStrategy = const ExponentialBackoffStrategy(
  baseDelay: Duration(seconds: 1),
  maxDelay: Duration(minutes: 5),
  jitterFactor: 0.1,
);
```

### How Exponential Backoff Works

**Formula:** `min(baseDelay * 2^attemptCount + jitter, maxDelay)`

**Example with default settings:**
```
Attempt 0 (initial): Execute immediately
Attempt 1: Wait 1s (1 * 2^0)
Attempt 2: Wait 2s (1 * 2^1)
Attempt 3: Wait 4s (1 * 2^2)
Attempt 4: Wait 8s (1 * 2^3)
...
Attempt 10+: Capped at 5 minutes max
```

**Jitter:** Random ±10% variation to prevent thundering herd problem
- Prevents multiple operations from retrying simultaneously
- Reduces server load spikes

### Retry Metadata

Each operation tracks retry information:

```dart
class QueueableOperation {
  /// Number of times this operation has been attempted
  int get attemptCount;

  /// Timestamp of the last execution attempt
  DateTime? get lastAttempt;

  /// Error message from the last failed attempt
  String? get lastError;

  /// Maximum number of retry attempts allowed
  int get maxRetries;
}
```

### Retry Flow

```
Operation Fails
    │
    ▼
Increment attemptCount
    │
    ▼
Record error in lastError
    │
    ▼
Check: attemptCount >= maxRetries?
    │
    ├─── YES ──▶ Move to Failed Queue (manual retry required)
    │
    └─── NO ───▶ Calculate backoff delay
                     │
                     ▼
                Wait in backoff period
                     │
                     ▼
                Retry on next processing cycle
```

### Available Retry Strategies

#### **ExponentialBackoffStrategy (Default)**

**Best for:** Most network operations, API calls

**Characteristics:**
- Delay increases exponentially with each attempt
- Jitter prevents synchronized retries
- Caps at maxDelay to prevent excessive waits

**Configuration:**
```dart
const ExponentialBackoffStrategy(
  baseDelay: Duration(seconds: 1),  // Starting delay
  maxDelay: Duration(minutes: 5),   // Maximum delay
  jitterFactor: 0.1,                // 10% random variation
)
```

**Delays:** 1s → 2s → 4s → 8s → 16s → 32s → 64s → 128s → 256s → 300s (capped)

#### **FixedDelayStrategy**

**Best for:** Operations that should retry at regular intervals

**Characteristics:**
- Constant delay between retries
- Predictable retry timing
- No jitter

**Configuration:**
```dart
const FixedDelayStrategy(
  delay: Duration(seconds: 5),
)
```

**Delays:** 5s → 5s → 5s → 5s → ...

#### **LinearBackoffStrategy**

**Best for:** Less aggressive backoff than exponential

**Characteristics:**
- Delay increases linearly with each attempt
- Jitter prevents synchronized retries
- Caps at maxDelay

**Configuration:**
```dart
const LinearBackoffStrategy(
  baseDelay: Duration(seconds: 1),
  increment: Duration(seconds: 2),
  maxDelay: Duration(minutes: 1),
  jitterFactor: 0.1,
)
```

**Delays:** 1s → 3s → 5s → 7s → 9s → 11s → ...

### Configuring Retry Behavior

#### **Per-Operation Max Retries**

```dart
final operation = MyCustomOperation(
  id: const Uuid().v4(),
  maxRetries: 5,  // Custom max retries
  // ... other fields
);
```

#### **Global Retry Strategy**

To change the retry strategy for all operations, modify `operation_queue.dart`:

```dart
@riverpod
class OperationQueue extends _$OperationQueue {
  final RetryStrategy retryStrategy = const LinearBackoffStrategy(
    baseDelay: Duration(seconds: 2),
    increment: Duration(seconds: 3),
    maxDelay: Duration(minutes: 2),
    jitterFactor: 0.15,
  );
  // ...
}
```

### Backoff Period Enforcement

Operations in backoff period are skipped during processing:

```dart
bool _isInBackoffPeriod(QueueableOperation operation) {
  if (operation.lastAttempt == null || operation.attemptCount == 0) {
    return false; // No backoff for first attempt
  }

  final backoffDelay = retryStrategy.calculateDelay(operation.attemptCount);
  final retryTime = operation.lastAttempt!.add(backoffDelay);
  final now = DateTime.now();

  return now.isBefore(retryTime);
}
```

**Debug Output:**
```
Operation abc123 is in backoff period. Can retry in 45s
```

### Manual Retry

Users can manually retry failed operations through the UI:

```dart
// Retry a single failed operation
await operationQueue.retryOperation('operation-id');

// Retry all failed operations
await operationQueue.retryAllFailed();
```

When manually retrying:
- Operation moves from failed queue back to pending queue
- Attempt metadata reset to 0 (fresh start)
- Operation processes immediately on next cycle

---

## Integration Examples

### Example 1: Adding an Operation to the Queue

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/core/services/operation_queue.dart';
import '../../../features/travel/domain/models/trip_planning_operation.dart';

class TripUpdateScreen extends ConsumerWidget {
  Future<void> _updateTrip(WidgetRef ref, String tripId, String newName) async {
    // Create the operation
    final operation = TripPlanningOperation.update(
      tripId: tripId,
      name: newName,
    );

    // Add to queue
    final queue = ref.read(operationQueueProvider);
    await queue.addOperation(operation);

    // Show confirmation
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Trip update queued for sync')),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      onPressed: () => _updateTrip(ref, 'trip-123', 'Paris Adventure'),
      child: Text('Update Trip'),
    );
  }
}
```

### Example 2: Displaying Queue Status

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../features/core/providers/operation_queue_provider.dart';

class QueueStatusWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(operationQueueNotifierProvider);

    return Card(
      child: ListTile(
        leading: Icon(Icons.cloud_sync),
        title: Text('Sync Status'),
        subtitle: Text(
          '${state.pendingCount} pending, ${state.failedCount} failed',
        ),
        trailing: state.isProcessing
            ? CircularProgressIndicator()
            : Icon(Icons.check_circle),
      ),
    );
  }
}
```

### Example 3: Navigating to Queue Screen

```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Home'),
        actions: [
          // Queue status indicator in app bar
          Consumer(
            builder: (context, ref, child) {
              final state = ref.watch(operationQueueNotifierProvider);

              if (state.pendingCount == 0) {
                return SizedBox.shrink(); // Hide when empty
              }

              return IconButton(
                icon: Badge(
                  label: Text('${state.pendingCount}'),
                  child: Icon(Icons.cloud_sync),
                ),
                onPressed: () {
                  // Navigate to queue screen
                  context.push('/operation-queue');
                },
                tooltip: 'View queued operations',
              );
            },
          ),
        ],
      ),
    );
  }
}
```

### Example 4: Creating a Custom Operation with Deduplication

```dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/operation_queue.dart';
import '../../../core/services/operation_priority.dart';

part 'profile_update_operation.freezed.dart';
part 'profile_update_operation.g.dart';

@freezed
class ProfileUpdateOperation with _$ProfileUpdateOperation implements QueueableOperation {
  const factory ProfileUpdateOperation({
    required String id,
    required String userId,
    required Map<String, dynamic> updates,
    @Default(OperationPriority.high) int priority,
    DateTime? createdAt,
    DateTime? lastAttempt,
    @Default(0) int attemptCount,
    String? lastError,
    @Default(3) int maxRetries,
  }) = _ProfileUpdateOperation;

  factory ProfileUpdateOperation.fromJson(Map<String, dynamic> json) =>
      _$ProfileUpdateOperationFromJson(json);

  const ProfileUpdateOperation._();

  factory ProfileUpdateOperation.create({
    required String userId,
    required Map<String, dynamic> updates,
  }) {
    return ProfileUpdateOperation(
      id: const Uuid().v4(),
      userId: userId,
      updates: updates,
      priority: OperationPriority.high.value,
      createdAt: DateTime.now(),
    );
  }

  @override
  String get type => 'profile_update';

  @override
  bool get requiresNetwork => true;

  @override
  String? get deduplicationKey {
    // Deduplicate profile updates - only latest data matters
    return 'profile_$userId';
  }

  @override
  Future<void> execute() async {
    // Make API call to update profile
    final apiClient = ApiService();
    final response = await apiClient.updateProfile(userId, updates);

    if (!response.isSuccessful) {
      throw Exception('Failed to update profile: ${response.errorMessage}');
    }
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'type': type,
        'userId': userId,
        'updates': updates,
        'priority': priority,
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (lastAttempt != null) 'lastAttempt': lastAttempt!.toIso8601String(),
        'attemptCount': attemptCount,
        if (lastError != null) 'lastError': lastError,
        'maxRetries': maxRetries,
      };
}

// Usage
final operation = ProfileUpdateOperation.create(
  userId: 'user-123',
  updates: {'displayName': 'John Doe'},
);

await ref.read(operationQueueProvider).addOperation(operation);
```

### Example 5: Testing Queue Behavior

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:my_app/features/core/services/operation_queue.dart';

class MockOperation extends Mock implements QueueableOperation {}

void main() {
  test('Operation should retry with exponential backoff', () async {
    // Arrange
    final operation = MockOperation();
    when(() => operation.id).thenReturn('test-op');
    when(() => operation.attemptCount).thenReturn(2);
    when(() => operation.requiresNetwork).thenReturn(true);

    // Act
    final delay = queue.retryStrategy.calculateDelay(operation.attemptCount);

    // Assert
    expect(delay.inSeconds, greaterThanOrEqualTo(4)); // 2^2 = 4s
  });

  test('Duplicate operations should be replaced', () async {
    // Arrange
    final op1 = MockOperation();
    final op2 = MockOperation();

    when(() => op1.id).thenReturn('op-1');
    when(() => op2.id).thenReturn('op-2');
    when(() => op1.deduplicationKey).thenReturn('resource-123');
    when(() => op2.deduplicationKey).thenReturn('resource-123');

    // Act
    await queue.addOperation(op1);
    await queue.addOperation(op2);

    // Assert
    expect(queue.getPendingOperations().length, 1);
    expect(queue.getPendingOperations().first.id, 'op-2'); // Newer op replaced older
  });
}
```

---

## Troubleshooting

### Operations Not Processing

**Symptoms:** Operations stay in pending queue indefinitely

**Checks:**
1. Network connectivity: `ref.read(connectivityNotifierProvider)`
2. Authentication status: `ref.read(tokenManagerProvider).canPerformOnlineOperations`
3. Backoff period: Check `operation.lastAttempt` and `operation.attemptCount`
4. Processing status: `ref.read(operationQueueProvider).isProcessing`

**Debug Output:**
```dart
// Enable debug logging
debugPrint('Pending: ${queue.getPendingOperations().length}');
debugPrint('Failed: ${queue.getFailedOperations().length}');
debugPrint('Processing: ${queue.isProcessing}');
```

### Operations Always Failing

**Symptoms:** Operations move to failed queue immediately

**Common Causes:**
1. API endpoint incorrect or unavailable
2. Authentication token expired
3. Malformed request data

**Solutions:**
1. Check `operation.lastError` for specific error message
2. Verify API connectivity separately
3. Check token manager refresh logic

### High Memory Usage

**Symptoms:** App slows down with many operations

**Causes:** Queue accumulating operations without processing

**Solutions:**
1. Reduce operation frequency (e.g., batch location updates)
2. Lower priority for non-critical operations
3. Implement queue size limits and cleanup

```dart
// Example: Clear old failed operations
if (queue.getFailedOperations().length > 100) {
  await queue.clearFailedOperations();
}
```

---

## Performance Considerations

### Storage Limits

- **SharedPreferences**: ~1MB limit per key
- Large queues may exceed limits
- Consider SQLite for production apps with high operation volume

### Processing Frequency

- **Default**: Every 30 seconds
- More frequent = quicker sync but higher battery usage
- Less frequent = saves battery but delays sync

### Optimization Tips

1. **Batch Similar Operations**
   ```dart
   // Instead of 10 location updates per minute
   // Batch to 1 update per minute with all locations
   ```

2. **Use Appropriate Priorities**
   ```dart
   // Don't use critical priority for non-emergency operations
   // Prevents starvation of lower-priority operations
   ```

3. **Implement Cleanup**
   ```dart
   // Periodically clear old failed operations
   if (failedOperations.length > 50) {
     await clearFailedOperations();
   }
   ```

---

## API Reference

### OperationQueue

**Methods:**
- `addOperation(QueueableOperation operation)` - Add operation to queue
- `processQueue()` - Manually trigger queue processing
- `getPendingOperations()` - Get list of pending operations
- `getFailedOperations()` - Get list of failed operations
- `retryOperation(String id)` - Retry a specific failed operation
- `retryAllFailed()` - Retry all failed operations
- `clearFailedOperations()` - Clear all failed operations
- `removeFailedOperation(String id)` - Remove specific failed operation
- `isProcessing` - Check if queue is currently processing

### QueueableOperation Interface

**Properties:**
- `id` - Unique identifier
- `type` - Operation type for grouping
- `priority` - Priority value (higher = more important)
- `requiresNetwork` - Whether operation needs network
- `createdAt` - Creation timestamp
- `lastAttempt` - Last execution attempt
- `attemptCount` - Number of attempts
- `lastError` - Last error message
- `maxRetries` - Maximum retry attempts
- `deduplicationKey` - Optional deduplication key

**Methods:**
- `execute()` - Execute the operation
- `toJson()` - Serialize to JSON

### OperationPriority Enum

**Values:**
- `critical(1000)` - Emergency operations
- `high(100)` - Important operations
- `normal(10)` - Standard operations
- `low(1)` - Background operations

**Methods:**
- `isHigherThan(OperationPriority other)` - Compare priorities
- `isLowerThan(OperationPriority other)` - Compare priorities
- `boost({int by = 1})` - Increase priority
- `reduce({int by = 1})` - Decrease priority

---

## Additional Resources

- **Testing Guide:** See `testing_reference.md` for comprehensive testing documentation
- **Manual Testing Plan:** See `manual_testing_plan.md` for real-world test scenarios
- **Code Examples:** Check `lib/features/travel/domain/models/` for operation implementations
- **UI Components:** See `lib/features/core/presentation/screens/operation_queue_screen.dart`

---

## Changelog

### Version 1.0.0 (2025-01-04)
- Initial release
- Core queue functionality with persistence
- Exponential backoff retry strategy
- Operation deduplication
- Priority-based processing with aging and round-robin
- Failed operations management
- UI for queue monitoring and control
- Comprehensive testing (unit, integration, widget)
- Full documentation
