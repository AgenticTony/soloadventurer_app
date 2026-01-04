# Sync Service

Comprehensive bidirectional synchronization service for offline-first travel journal functionality.

## Overview

The `SyncService` provides bidirectional synchronization between local SQLite storage and remote Supabase database for:
- Journal entries
- Media items (photos and videos)
- Trips
- Tags

## Features

- ✅ **Bidirectional Sync**: Upload local changes and download remote changes
- ✅ **Conflict Resolution**: Detect and resolve conflicts when data is modified both locally and remotely
- ✅ **Progress Tracking**: Real-time progress updates during sync operations
- ✅ **Network Awareness**: Automatic sync when connectivity is restored
- ✅ **Batch Processing**: Efficient batch operations for large datasets
- ✅ **Configurable Strategies**: Multiple conflict resolution strategies
- ✅ **Offline-First**: Works seamlessly offline and syncs when connected

## Architecture

### Components

```
┌─────────────────────────────────────────────────────┐
│                   SyncService                       │
│  - Coordinates sync operations                     │
│  - Manages sync state                              │
│  - Handles conflict resolution                     │
└─────────────────────────────────────────────────────┘
         │                    │                    │
         ▼                    ▼                    ▼
┌──────────────┐    ┌──────────────┐    ┌──────────────┐
│  Local Data  │    │   Conflict   │    │  Remote Data │
│  Sources     │◄──►│  Resolution  │◄──►│  Sources     │
│  (SQLite)    │    │              │    │  (Supabase)  │
└──────────────┘    └──────────────┘    └──────────────┘
```

### Sync Flow

```
1. Check Connectivity
   ↓
2. Fetch Pending Items (sync_status = 'pending')
   ↓
3. For Each Pending Item:
   ├─ Check if exists remotely
   ├─ If NO: Upload to remote
   ├─ If YES: Detect conflict
   │  ├─ Use configured resolution strategy
   │  └─ Update both local and remote
   └─ Mark as synced
   ↓
4. Fetch Remote Changes
   ↓
5. For Each Remote Change:
   ├─ Check if exists locally
   ├─ If NO: Create locally
   ├─ If YES: Check timestamps
   │  └─ Update if remote is newer
   └─ Mark as synced
   ↓
6. Update Statistics
```

## Installation

The service is already integrated into the journal feature. Ensure all dependencies are in `pubspec.yaml`:

```yaml
dependencies:
  supabase_flutter: ^2.0.0
  connectivity_plus: ^5.0.0
  sqflite: ^2.3.0
```

## Usage

### Basic Setup

```dart
import 'package:soloadventurer/features/journal/data/services/sync_service_impl.dart';
import 'package:soloadventurer/features/journal/domain/services/sync_service.dart';

// Initialize service (usually done in dependency injection)
final syncService = SyncServiceImpl(
  journalLocalDataSource: journalLocalDataSource,
  journalRemoteDataSource: journalRemoteDataSource,
  tripLocalDataSource: tripLocalDataSource,
  tripRemoteDataSource: tripRemoteDataSource,
  tagLocalDataSource: tagLocalDataSource,
  tagRemoteDataSource: tagRemoteDataSource,
  connectivityService: connectivityService,
);

await syncService.initialize();
```

### Perform Full Sync

```dart
// Sync all data (entries, media, trips, tags)
final result = await syncService.syncAll();

if (result.success) {
  print('Sync completed successfully!');
  print('Uploaded: ${result.uploadedCount} items');
  print('Downloaded: ${result.downloadedCount} items');
  print('Conflicts: ${result.conflictCount} items');
} else {
  print('Sync failed: ${result.errors}');
}
```

### Quick Sync (Pending Items Only)

```dart
// Faster sync that only processes pending items
final result = await syncService.syncPending();

print('Synced ${result.uploadedCount + result.downloadedCount} pending items');
```

### Directional Sync

```dart
// Upload only local changes
final uploadResult = await syncService.uploadChanges();

// Download only remote changes
final downloadResult = await syncService.downloadChanges();

// Sync entries only
final entriesResult = await syncService.syncEntries(
  SyncDirection.bidirectional,
);

// Sync trips only (upload to remote)
final tripsResult = await syncService.syncTrips(
  SyncDirection.upload,
);
```

### Monitor Progress

```dart
// Listen to progress stream
syncService.progressStream.listen((progress) {
  print('Sync progress: ${(progress.progress * 100).toStringAsFixed(1)}%');
  print('Synced: ${progress.syncedItems}/${progress.totalItems}');
  print('Conflicts: ${progress.conflictItems}');
  print('Failed: ${progress.failedItems}');
});

// Or use callback
syncService.onProgressUpdate((progress) {
  // Update UI progress bar
  updateProgressBar(progress.progress);
});
```

### Handle Conflicts

```dart
// Listen for conflicts
syncService.conflictStream.listen((conflict) {
  print('Conflict detected for ${conflict.entityType}:${conflict.entityId}');
  print('Local modified: ${conflict.localUpdatedAt}');
  print('Remote modified: ${conflict.remoteUpdatedAt}');

  // Show conflict resolution UI
  showConflictDialog(conflict);
});

// Or use callback
syncService.onConflictDetected((conflict) {
  // Handle conflict
  _handleConflict(conflict);
});

// Resolve a conflict manually
Future<void> _handleConflict(SyncConflict conflict) async {
  // User chooses local version
  await syncService.resolveConflict(
    conflict,
    ConflictResolutionStrategy.localWins,
  );

  // Or user chooses remote version
  await syncService.resolveConflict(
    conflict,
    ConflictResolutionStrategy.remoteWins,
  );

  // Or user provides merged version
  final mergedVersion = _mergeVersions(
    conflict.localVersion,
    conflict.remoteVersion,
  );

  await syncService.resolveConflict(
    conflict,
    ConflictResolutionStrategy.manual,
    resolvedVersion: mergedVersion,
  );
}
```

### Custom Sync Configuration

```dart
final customConfig = SyncConfig(
  batchSize: 100,
  batchDelay: 200,
  maxRetries: 5,
  operationTimeout: const Duration(minutes: 1),
  syncMedia: true,
  autoResolveConflicts: true,
  conflictResolutionStrategy: ConflictResolutionStrategy.mostRecent,
  syncPendingOnly: false,
);

final result = await syncService.syncAll(customConfig);
```

### Cancel Sync

```dart
// Cancel ongoing sync operation
await syncService.cancelSync();
```

### Get Statistics

```dart
final stats = syncService.getStatistics();

print('Total syncs: ${stats.totalSyncs}');
print('Success rate: ${(stats.successRate * 100).toStringAsFixed(1)}%');
print('Average duration: ${stats.averageDuration.inSeconds}s');
print('Last sync: ${stats.lastSyncTime}');
```

## Configuration Options

### SyncConfig

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `batchSize` | int | 50 | Number of items to process per batch |
| `batchDelay` | int | 100 | Delay between batches (ms) |
| `maxRetries` | int | 3 | Maximum retry attempts for failed items |
| `operationTimeout` | Duration | 30s | Timeout for individual operations |
| `syncMedia` | bool | true | Whether to sync media files |
| `autoResolveConflicts` | bool | false | Auto-resolve conflicts using strategy |
| `conflictStrategy` | ConflictResolutionStrategy | mostRecent | Strategy for auto-resolution |
| `syncPendingOnly` | bool | false | Only sync pending items |

### Predefined Configurations

```dart
// Default config (balanced)
SyncConfig.defaultConfig

// Quick sync (pending only, fast)
SyncConfig.quickConfig

// Full sync (everything, slower)
SyncConfig.fullConfig
```

### Conflict Resolution Strategies

```dart
enum ConflictResolutionStrategy {
  // Use most recently updated version
  mostRecent,

  // Always prefer local changes
  localWins,

  // Always prefer remote changes
  remoteWins,

  // Require manual resolution
  manual,
}
```

## Sync Status Values

Each item (entry, media, trip, tag) has a `sync_status` field:

- **`synced`**: Item is synchronized between local and remote
- **`pending`**: Item has local changes pending upload
- **`conflict`**: Item has a conflict requiring resolution
- **`offline_only`**: Item exists only locally (never synced)

## Best Practices

### 1. Sync on Connectivity Changes

```dart
connectivityService.onConnectivityChanged.listen((status) {
  if (status == NetworkStatus.connected && syncService.hasPendingItems) {
    // Auto-sync when connection is restored
    syncService.syncPending();
  }
});
```

### 2. Background Periodic Sync

```dart
Timer.periodic(const Duration(minutes: 15), (_) {
  if (!syncService.isSyncing) {
    syncService.syncPending();
  }
});
```

### 3. Sync on App Lifecycle Events

```dart
// Sync when app resumes
appLifecycleListener.onStateChange = (state) {
  if (state == AppLifecycleState.resumed) {
    syncService.syncPending();
  }
};
```

### 4. Show Sync Status in UI

```dart
// Build sync status indicator
Widget buildSyncStatusIndicator() {
  return StreamBuilder<SyncProgress>(
    stream: syncService.progressStream,
    builder: (context, snapshot) {
      if (syncService.isSyncing) {
        final progress = snapshot.data;
        return LinearProgressIndicator(
          value: progress?.progress ?? 0.0,
        );
      }
      return const Icon(Icons.cloud_done);
    },
  );
}
```

### 5. Handle Large Media Syncs Separately

```dart
// Quick sync without media
await syncService.syncAll(SyncConfig.quickConfig);

// Then sync media in background
if (connectivityService.hasConnectivitySync) {
  unawaited(syncService.syncMedia());
}
```

### 6. Error Recovery

```dart
try {
  final result = await syncService.syncAll();

  if (result.failedCount > 0) {
    // Some items failed to sync
    for (final error in result.errors) {
      logger.error('Sync error: $error');
    }

    // Show user notification
    showSnackBar(
      'Sync completed with ${result.failedCount} errors',
      action: SnackBarAction(
        label: 'Retry',
        onPressed: () => syncService.syncAll(),
      ),
    );
  }
} catch (e) {
  // Critical sync failure
  logger.error('Sync failed: $e');
  showSnackBar('Sync failed. Please try again later.');
}
```

## Testing

### Mock Sync Service

```dart
class MockSyncService implements SyncService {
  @override
  SyncProgress get currentProgress => const SyncProgress(totalItems: 0);

  @override
  Stream<SyncProgress> get progressStream =>
      Stream.value(const SyncProgress(totalItems: 0, syncedItems: 0));

  // ... implement other methods for testing
}

// Use in tests
final mockService = MockSyncService();
// Test your UI with mock service
```

### Test Scenarios

1. **Offline to Online Transition**
   - Create items offline
   - Simulate connection restored
   - Verify items sync correctly

2. **Conflict Resolution**
   - Modify same item locally and remotely
   - Verify conflict is detected
   - Test different resolution strategies

3. **Partial Sync Failure**
   - Simulate network error during sync
   - Verify retry mechanism works
   - Check failed items are retried

4. **Large Dataset**
   - Test with hundreds of entries
   - Verify batch processing works
   - Check performance and memory usage

## Troubleshooting

### Sync Takes Too Long

**Problem**: Sync operation is slow

**Solutions**:
- Use `SyncConfig.quickConfig` for faster syncs
- Reduce `batchSize` to process smaller batches
- Set `syncMedia: false` and sync media separately
- Check network connectivity

### Conflicts Not Resolving

**Problem**: Items remain in conflict state

**Solutions**:
- Check conflict resolution strategy
- Implement manual conflict resolution UI
- Verify timestamps are being updated correctly
- Check for clock sync issues between devices

### Memory Issues

**Problem**: App crashes during sync with large datasets

**Solutions**:
- Reduce `batchSize` (e.g., 20-30 items)
- Use pagination for remote queries
- Sync entities separately instead of full sync
- Clear cache between batches

### Media Sync Fails

**Problem**: Media items fail to sync

**Solutions**:
- Check file size limits
- Verify storage bucket permissions
- Ensure media compression is working
- Check network bandwidth
- Sync media separately from other entities

## Performance Considerations

### Optimization Tips

1. **Batch Operations**: Process items in batches to reduce memory usage
2. **Selective Sync**: Sync only changed entities (`syncPendingOnly: true`)
3. **Background Sync**: Run media syncs in background using isolates
4. **Compression**: Compress media before uploading
5. **Throttling**: Add delays between batches to avoid overwhelming server

### Benchmarks

Approximate sync times (on good 4G connection):

- 10 journal entries: ~2 seconds
- 100 journal entries: ~15 seconds
- 10 photos (compressed): ~10 seconds
- 10 videos (compressed): ~30 seconds

## API Reference

### SyncService Interface

See `lib/features/journal/domain/services/sync_service.dart` for complete API documentation.

### Key Methods

- `syncAll([SyncConfig?])` - Perform full sync
- `syncPending()` - Quick sync of pending items
- `syncEntries([direction, config])` - Sync entries only
- `syncMedia([direction, config])` - Sync media only
- `syncTrips([direction, config])` - Sync trips only
- `syncTags([direction, config])` - Sync tags only
- `uploadChanges()` - Upload local changes
- `downloadChanges()` - Download remote changes
- `resolveConflict(conflict, strategy)` - Resolve specific conflict
- `cancelSync()` - Cancel current sync
- `getStatistics()` - Get sync statistics

### Streams

- `progressStream` - Stream of sync progress updates
- `conflictStream` - Stream of detected conflicts

## Future Enhancements

- [ ] Incremental sync using timestamps
- [ ] Background sync with work manager
- [ ] Selective sync by date range
- [ ] Sync queue visualization in UI
- [ ] Conflict resolution history
- [ ] Sync performance analytics
- [ ] Delta sync for media files
- [ ] Multi-device sync awareness
- [ ] Collaborative editing support
- [ ] Sync conflict prediction

## Related Files

- `lib/features/journal/domain/services/sync_service.dart` - Service interface
- `lib/features/journal/data/services/sync_service_impl.dart` - Implementation
- `lib/features/journal/data/datasources/*_local_data_source*.dart` - Local data sources
- `lib/features/journal/data/datasources/*_remote_data_source*.dart` - Remote data sources
- `lib/features/journal/data/datasources/database_helper.dart` - Database schema
- `lib/features/core/domain/services/connectivity_service.dart` - Network monitoring

## Support

For issues, questions, or contributions, please refer to the main project repository.
