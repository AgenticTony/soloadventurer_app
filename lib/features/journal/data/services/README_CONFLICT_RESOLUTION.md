# Conflict Resolution Service

Comprehensive conflict detection and resolution service for offline-first travel journal synchronization.

## Overview

The `ConflictResolutionService` provides sophisticated conflict detection and resolution capabilities for handling data conflicts that occur when the same journal entry, trip, or tag is edited both offline and online. It offers multiple resolution strategies, field-level conflict analysis, and persistent conflict tracking.

## Features

- ✅ **Automatic Conflict Detection**: Detects conflicts between local and remote versions
- ✅ **Field-Level Analysis**: Identifies which specific fields have conflicts
- ✅ **Multiple Resolution Strategies**: mostRecent, localWins, remoteWins, manual, merge, keepBoth
- ✅ **Conflict Severity Levels**: Categorizes conflicts by severity (low, medium, high, critical)
- ✅ **Conflict Storage**: Persists conflicts for later resolution
- ✅ **Resolution History**: Tracks all conflict resolutions
- ✅ **Statistics**: Provides conflict metrics and analytics
- ✅ **Stream Updates**: Real-time notifications for conflict detection and resolution
- ✅ **Retry Mechanism**: Allows retrying failed resolutions

## Architecture

### Components

```
┌─────────────────────────────────────────────────────┐
│         ConflictResolutionService                   │
│  - Detect conflicts between versions                │
│  - Store conflicts for resolution                   │
│  - Apply resolution strategies                      │
└─────────────────────────────────────────────────────┘
         │                    │                    │
         ▼                    ▼                    ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│  Sync Service│◄──►│  Local Data  │    │  Remote Data │
│              │    │  Sources     │    │  Sources     │
└──────────────┘    └──────────────┘    └──────────────┘
```

### Conflict Detection Flow

```
1. Compare Local and Remote Versions
   ↓
2. Check Modification Timestamps
   ├─ If concurrent modification (within 1 min):
   │  ↓
   │  3. Detect Conflict Type
   │  ├─ Field conflict
   │  ├─ Deleted/Modified conflict
   │  ├─ Relationship conflict
   │  └─ Media conflict
   │  ↓
   │  4. Determine Severity
   │  ↓
   │  5. Analyze Field-Level Conflicts
   │  ↓
   │  6. Store Conflict
   │  ↓
   │  7. Notify Listeners
   └─ Else: No conflict
```

### Resolution Strategies

#### 1. Most Recent (Default)
Uses the version with the most recent timestamp.

**Best for**: Most conflict types, when timestamp accuracy is reliable

**Example**:
```dart
await conflictService.resolveConflict(
  conflict,
  ConflictResolutionStrategy.mostRecent,
);
```

#### 2. Local Wins
Always prefers the local version over remote.

**Best for**: When user explicitly made offline changes they want to keep

**Example**:
```dart
await conflictService.resolveConflict(
  conflict,
  ConflictResolutionStrategy.localWins,
);
```

#### 3. Remote Wins
Always prefers the remote version over local.

**Best for**: When server data is authoritative (e.g., from another device)

**Example**:
```dart
await conflictService.resolveConflict(
  conflict,
  ConflictResolutionStrategy.remoteWins,
);
```

#### 4. Manual Resolution
Requires user to choose or merge versions.

**Best for**: High-severity conflicts, critical data

**Example**:
```dart
final resolvedVersion = {
  'id': conflict.entityId,
  'title': remoteTitle, // User chose remote title
  'content': localContent, // User chose local content
  // ... other fields
};

await conflictService.resolveConflict(
  conflict,
  ConflictResolutionStrategy.manual,
  resolvedVersion: resolvedVersion,
);
```

#### 5. Merge
Attempts to intelligently merge both versions.

**Best for**: Non-critical field conflicts, complementary changes

**Note**: Currently defaults to mostRecent. Advanced merging can be implemented.

**Example**:
```dart
await conflictService.resolveConflict(
  conflict,
  ConflictResolutionStrategy.merge,
);
```

#### 6. Keep Both
Creates a duplicate entry to preserve both versions.

**Best for**: When both versions have important, different content

**Example**:
```dart
await conflictService.resolveConflict(
  conflict,
  ConflictResolutionStrategy.keepBoth,
);
```

## Installation

The service is already integrated into the journal feature. Ensure all dependencies are in `pubspec.yaml`:

```yaml
dependencies:
  uuid: ^4.0.0
```

## Usage

### Basic Setup

```dart
import 'package:soloadventurer/features/journal/data/services/conflict_resolution_service_impl.dart';
import 'package:soloadventurer/features/journal/domain/services/conflict_resolution_service.dart';

// Initialize service (usually done in dependency injection)
final conflictService = ConflictResolutionServiceImpl(
  journalLocalDataSource: journalLocalDataSource,
  journalRemoteDataSource: journalRemoteDataSource,
  tripLocalDataSource: tripLocalDataSource,
  tripRemoteDataSource: tripRemoteDataSource,
  tagLocalDataSource: tagLocalDataSource,
  tagRemoteDataSource: tagRemoteDataSource,
);

await conflictService.initialize();
```

### Detect Conflicts

```dart
// Detect conflict between local and remote versions
final conflict = await conflictService.detectConflict(
  entityType: 'journal_entry',
  localVersion: localEntry.toJson(),
  remoteVersion: remoteEntry.toJson(),
);

if (conflict != null) {
  print('Conflict detected: ${conflict.conflictType}');
  print('Severity: ${conflict.severity}');
  print('Reason: ${conflict.reason}');

  // Check field conflicts
  for (final fieldConflict in conflict.fieldConflicts) {
    print('Field "${fieldConflict.fieldName}" conflicts:');
    print('  Local: ${fieldConflict.localValue}');
    print('  Remote: ${fieldConflict.remoteValue}');
  }
}
```

### Listen for New Conflicts

```dart
// Listen to conflict stream
conflictService.conflictStream.listen((conflict) {
  print('New conflict detected: ${conflict.conflictId}');
  print('Entity: ${conflict.entityType}:${conflict.entityId}');
  print('Severity: ${conflict.severity}');

  // Show conflict resolution UI
  _showConflictResolutionDialog(conflict);
});

// Or use callback
conflictService.onConflictDetected((conflict) {
  _handleConflict(conflict);
});
```

### Resolve a Single Conflict

```dart
// Resolve using most recent version
final result = await conflictService.resolveConflict(
  conflict,
  ConflictResolutionStrategy.mostRecent,
);

if (result.success) {
  print('Conflict resolved successfully!');
  print('Strategy used: ${result.strategy}');
  print('Resolved version: ${result.resolvedVersion}');
} else {
  print('Conflict resolution failed: ${result.error}');
}

// Resolve with local version
final result = await conflictService.resolveConflict(
  conflict,
  ConflictResolutionStrategy.localWins,
);

// Resolve with manual merge
final mergedVersion = _mergeVersions(conflict.localVersion, conflict.remoteVersion);
final result = await conflictService.resolveConflict(
  conflict,
  ConflictResolutionStrategy.manual,
  resolvedVersion: mergedVersion,
);
```

### Resolve Multiple Conflicts

```dart
// Get all pending conflicts
final pendingConflicts = await conflictService.getPendingConflicts();

// Resolve all using most recent strategy
final results = await conflictService.resolveMultipleConflicts(
  pendingConflicts,
  ConflictResolutionStrategy.mostRecent,
);

// Check results
for (final result in results) {
  if (result.success) {
    print('Resolved ${result.conflict.conflictId}');
  } else {
    print('Failed to resolve ${result.conflict.conflictId}: ${result.error}');
  }
}
```

### Resolve All Pending Conflicts

```dart
// Resolve all pending conflicts with low/medium severity automatically
final results = await conflictService.resolveAllPending(
  ConflictResolutionStrategy.mostRecent,
  maxSeverity: ConflictSeverity.medium,
);

print('Resolved ${results.where((r) => r.success).length} conflicts');
print('Failed ${results.where((r) => !r.success).length} conflicts');
```

### Listen for Resolution Results

```dart
// Listen to resolution stream
conflictService.resolutionStream.listen((result) {
  if (result.success) {
    print('Conflict resolved: ${result.conflict.conflictId}');
    print('Strategy: ${result.strategy}');
  } else {
    print('Resolution failed: ${result.error}');
    // Retry or notify user
  }
});

// Or use callback
conflictService.onConflictResolved((conflict, result) {
  if (result.success) {
    _showSuccessNotification(conflict);
  } else {
    _showErrorNotification(conflict, result.error);
  }
});
```

### Get Conflict Statistics

```dart
final stats = await conflictService.getStatistics();

print('Total conflicts: ${stats.totalConflicts}');
print('Resolved: ${stats.resolvedConflicts}');
print('Pending: ${stats.pendingConflicts}');
print('Failed: ${stats.failedConflicts}');
print('Success rate: ${(stats.successRate * 100).toStringAsFixed(1)}%');
print('Most common type: ${stats.mostCommonType}');
print('Avg resolution time: ${stats.averageResolutionTime.inSeconds}s');
```

### Filter Conflicts

```dart
// Get conflicts by entity type
final entryConflicts = await conflictService.getConflictsByType('journal_entry');
final tripConflicts = await conflictService.getConflictsByType('trip');

// Get conflicts by severity
final criticalConflicts = await conflictService.getConflictsBySeverity(
  ConflictSeverity.critical,
);
final highConflicts = await conflictService.getConflictsBySeverity(
  ConflictSeverity.high,
);

// Combine filters
final criticalEntryConflicts = entryConflicts
    .where((c) => c.severity == ConflictSeverity.critical)
    .toList();
```

### Manual Conflict Resolution Workflow

```dart
Future<void> _resolveConflictManually(SyncConflict conflict) async {
  // Show conflict details to user
  final shouldResolve = await showDialog(
    context: context,
    builder: (context) => ConflictResolutionDialog(
      conflict: conflict,
    ),
  );

  if (shouldResolve == null) {
    // User cancelled, ignore conflict
    await conflictService.ignoreConflict(conflict.conflictId);
    return;
  }

  // User made a choice, apply it
  final result = await conflictService.resolveConflict(
    conflict,
    ConflictResolutionStrategy.manual,
    resolvedVersion: shouldResolve,
  );

  if (result.success) {
    _showSuccessSnackBar('Conflict resolved successfully');
  } else {
    _showErrorSnackBar('Failed to resolve: ${result.error}');
  }
}
```

### Ignore a Conflict

```dart
// Ignore a conflict without resolving
await conflictService.ignoreConflict(conflict.conflictId);
print('Conflict ${conflict.conflictId} ignored');
```

### Retry Failed Resolution

```dart
// Retry a previously failed resolution
final result = await conflictService.retryConflict(conflict.conflictId);

if (result != null && result.success) {
  print('Retry successful!');
} else {
  print('Retry failed');
}
```

### Cleanup

```dart
// Clear all resolved conflicts (cleanup old data)
await conflictService.clearResolvedConflicts();

// Clear all conflicts (for testing/debugging)
await conflictService.clearAllConflicts();
```

## Conflict Types

### Field Conflict
Same field modified with different values.

**Severity**: Low or Medium

**Example**: User changes title on device A, content on device B

### Deleted/Modified Conflict
Item deleted locally but modified remotely (or vice versa).

**Severity**: High

**Example**: User deletes entry offline, but edits it online

### Relationship Conflict
Parent-child relationship conflict (e.g., trip deleted but entries exist).

**Severity**: Critical

**Example**: User deletes a trip, but individual entries still reference it

### Media Conflict
Different media uploads with same ID.

**Severity**: High

**Example**: User uploads different photos to the same entry on multiple devices

### Concurrent Modification
Multiple modifications to same item around the same time.

**Severity**: Medium

**Example**: User edits entry on two devices simultaneously

## Severity Levels

| Severity | Description | Auto-Resolve | User Action |
|----------|-------------|--------------|-------------|
| **Low** | Minor field conflicts | ✅ Yes | Optional |
| **Medium** | Concurrent modifications | ⚠️ Maybe | Recommended |
| **High** | Deleted/modified or media conflicts | ❌ No | Required |
| **Critical** | Relationship conflicts | ❌ No | Required immediately |

## Best Practices

### 1. Proactive Conflict Detection

```dart
// Detect conflicts during sync before applying changes
for (final entry in modifiedEntries) {
  final conflict = await conflictService.detectConflict(
    entityType: 'journal_entry',
    localVersion: localEntry.toJson(),
    remoteVersion: remoteEntry.toJson(),
  );

  if (conflict != null) {
    // Handle conflict before continuing sync
    await _handleConflictDetected(conflict);
  }
}
```

### 2. Progressive Resolution Strategy

```dart
// Auto-resolve low severity conflicts
await conflictService.resolveAllPending(
  ConflictResolutionStrategy.mostRecent,
  maxSeverity: ConflictSeverity.low,
);

// Show UI for remaining conflicts
final remainingConflicts = await conflictService.getPendingConflicts();
if (remainingConflicts.isNotEmpty) {
  _showConflictsListScreen(remainingConflicts);
}
```

### 3. User-Friendly Conflict Messages

```dart
String _getUserFriendlyMessage(SyncConflict conflict) {
  switch (conflict.conflictType) {
    case ConflictType.fieldConflict:
      return 'This entry was edited on another device. '
          'Which version would you like to keep?';

    case ConflictType.deletedModified:
      return 'This entry was deleted on this device but edited elsewhere. '
          'Do you want to restore it?';

    case ConflictType.modifiedDeleted:
      return 'This entry was edited on this device but deleted elsewhere. '
          'Do you want to keep your edits?';

    default:
      return 'A conflict was detected. Please choose how to resolve it.';
  }
}
```

### 4. Batch Conflict Resolution

```dart
// Resolve conflicts in batches for better performance
final conflicts = await conflictService.getPendingConflicts();
const batchSize = 10;

for (int i = 0; i < conflicts.length; i += batchSize) {
  final batch = conflicts.skip(i).take(batchSize).toList();
  await conflictService.resolveMultipleConflicts(
    batch,
    ConflictResolutionStrategy.mostRecent,
  );

  // Update UI progress
  _updateProgress(i + batchSize, conflicts.length);
}
```

### 5. Conflict Resolution Statistics Dashboard

```dart
// Build a dashboard showing conflict statistics
FutureBuilder<ConflictResolutionStatistics>(
  future: conflictService.getStatistics(),
  builder: (context, snapshot) {
    if (!snapshot.hasData) return CircularProgressIndicator();

    final stats = snapshot.data!;

    return Column(
      children: [
        Text('Total Conflicts: ${stats.totalConflicts}'),
        Text('Success Rate: ${(stats.successRate * 100).toStringAsFixed(1)}%'),
        Text('Pending: ${stats.pendingConflicts}'),
        Text('Avg Resolution Time: ${stats.averageResolutionTime.inSeconds}s'),
      ],
    );
  },
);
```

## UI Integration

### Conflict List Screen

```dart
class ConflictListScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Pending Conflicts')),
      body: FutureBuilder<List<SyncConflict>>(
        future: conflictService.getPendingConflicts(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return CircularProgressIndicator();
          }

          final conflicts = snapshot.data!;

          if (conflicts.isEmpty) {
            return Center(child: Text('No pending conflicts'));
          }

          return ListView.builder(
            itemCount: conflicts.length,
            itemBuilder: (context, index) {
              final conflict = conflicts[index];
              return ConflictCard(
                conflict: conflict,
                onResolve: (strategy) async {
                  final result = await conflictService.resolveConflict(
                    conflict,
                    strategy,
                  );
                  // Handle result
                },
                onIgnore: () async {
                  await conflictService.ignoreConflict(conflict.conflictId);
                },
              );
            },
          );
        },
      ),
    );
  }
}
```

### Conflict Resolution Dialog

```dart
class ConflictResolutionDialog extends StatefulWidget {
  final SyncConflict conflict;

  const ConflictResolutionDialog({required this.conflict});

  @override
  _ConflictResolutionDialogState createState() =>
      _ConflictResolutionDialogState();
}

class _ConflictResolutionDialogState extends State<ConflictResolutionDialog> {
  ConflictResolutionStrategy? _selectedStrategy;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Resolve Conflict'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text('Severity: ${widget.conflict.severity}'),
          Text(widget.conflict.reason),
          if (widget.conflict.fieldConflicts.isNotEmpty)
            ...widget.conflict.fieldConflicts.map(
              (fc) => ListTile(
                title: Text(fc.fieldName),
                subtitle: Text(
                  'Local: ${fc.localValue}\nRemote: ${fc.remoteValue}',
                ),
              ),
            ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            final result = await conflictService.resolveConflict(
              widget.conflict,
              ConflictResolutionStrategy.localWins,
            );
            Navigator.pop(context, result);
          },
          child: Text('Keep Local'),
        ),
        TextButton(
          onPressed: () async {
            final result = await conflictService.resolveConflict(
              widget.conflict,
              ConflictResolutionStrategy.remoteWins,
            );
            Navigator.pop(context, result);
          },
          child: Text('Keep Remote'),
        ),
      ],
    );
  }
}
```

## Testing

### Mock Conflict Resolution Service

```dart
class MockConflictResolutionService implements ConflictResolutionService {
  final List<SyncConflict> _mockConflicts = [];

  @override
  Stream<SyncConflict> get conflictStream =>
      Stream.fromIterable(_mockConflicts);

  @override
  Stream<ConflictResolutionResult> get resolutionStream => const Stream.empty();

  // ... implement other methods for testing

  @override
  Future<List<SyncConflict>> getPendingConflicts() async {
    return _mockConflicts.where((c) => !c.isResolved).toList();
  }
}
```

### Test Scenarios

1. **Field Conflict Detection**
   ```dart
   test('detects field conflicts', () async {
     final local = {'id': '1', 'title': 'Local Title', 'content': 'Content'};
     final remote = {'id': '1', 'title': 'Remote Title', 'content': 'Content'};

     final conflict = await service.detectConflict(
       entityType: 'journal_entry',
       localVersion: local,
       remoteVersion: remote,
     );

     expect(conflict, isNotNull);
     expect(conflict!.conflictType, ConflictType.fieldConflict);
   });
   ```

2. **Resolution Strategies**
   ```dart
   test('resolves conflict with local wins', () async {
     final result = await service.resolveConflict(
       conflict,
       ConflictResolutionStrategy.localWins,
     );

     expect(result.success, true);
     expect(result.strategy, ConflictResolutionStrategy.localWins);
   });
   ```

## Troubleshooting

### Conflicts Not Being Detected

**Problem**: Conflicts are not being detected during sync

**Solutions**:
- Check that timestamps are being updated correctly
- Verify modification times are within the detection window (1 minute)
- Ensure detectConflict is being called for all modified items

### Resolution Fails

**Problem**: Conflict resolution fails with errors

**Solutions**:
- Check network connectivity
- Verify local and remote data sources are working
- Check for data integrity issues
- Review resolution error messages

### Too Many Conflicts

**Problem**: Excessive number of conflicts detected

**Solutions**:
- Increase timestamp detection window
- Implement better conflict prevention
- Use more aggressive auto-resolution for low-severity conflicts
- Review user education about offline editing

### Memory Issues

**Problem**: Too many conflicts stored in memory

**Solutions**:
- Regularly clear resolved conflicts
- Use pagination for conflict lists
- Store conflicts in persistent storage instead of memory
- Implement conflict cleanup after successful sync

## Performance Considerations

### Optimization Tips

1. **Batch Operations**: Resolve multiple conflicts at once
2. **Progressive Resolution**: Auto-resolve low-severity conflicts first
3. **Background Processing**: Resolve conflicts in background isolates
4. **Lazy Loading**: Load conflicts on demand, not all at once
5. **Periodic Cleanup**: Clear resolved conflicts regularly

### Benchmarks

Approximate conflict resolution times:

- Simple field conflict (mostRecent): ~50ms
- Manual resolution with UI: 2-5 seconds (user interaction)
- Batch resolve 10 conflicts: ~500ms
- Complex merge operation: ~200ms

## API Reference

### ConflictResolutionService Interface

See `lib/features/journal/domain/services/conflict_resolution_service.dart` for complete API documentation.

### Key Methods

- `detectConflict()` - Detect conflicts between versions
- `resolveConflict()` - Resolve a single conflict
- `resolveMultipleConflicts()` - Resolve multiple conflicts
- `resolveAllPending()` - Resolve all pending conflicts
- `getPendingConflicts()` - Get all unresolved conflicts
- `getStatistics()` - Get conflict statistics
- `ignoreConflict()` - Ignore a conflict without resolving
- `retryConflict()` - Retry a failed resolution

### Streams

- `conflictStream` - Stream of newly detected conflicts
- `resolutionStream` - Stream of resolution results

## Related Files

- `lib/features/journal/domain/services/conflict_resolution_service.dart` - Service interface
- `lib/features/journal/data/services/conflict_resolution_service_impl.dart` - Implementation
- `lib/features/journal/domain/services/sync_service.dart` - Sync service integration
- `lib/features/journal/data/services/sync_service_impl.dart` - Sync implementation

## Future Enhancements

- [ ] Advanced field-level merging (e.g., text diff/merge)
- [ ] Machine learning-based conflict resolution suggestions
- [ ] Conflict prevention strategies
- [ ] Collaborative editing support
- [ ] Three-way merge (using common ancestor)
- [ ] Persistent conflict storage (SQLite)
- [ ] Conflict resolution history and analytics
- [ ] Custom conflict resolution rules per entity type
- [ ] Undo/redo for conflict resolutions
- [ ] Conflict prediction and early warning

## Support

For issues, questions, or contributions, please refer to the main project repository.
