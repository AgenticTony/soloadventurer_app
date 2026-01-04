# Offline-First Architecture

## Overview

The SoloAdventurer app implements a comprehensive offline-first architecture that enables full functionality without internet connectivity. The architecture automatically synchronizes data when connectivity is restored, ensuring a seamless user experience for travelers in remote areas, during flights, or in regions with poor connectivity.

## Table of Contents

- [Core Principles](#core-principles)
- [Architecture Layers](#architecture-layers)
- [Database Schema](#database-schema)
- [Synchronization Engine](#synchronization-engine)
- [Conflict Resolution](#conflict-resolution)
- [Repository Pattern](#repository-pattern)
- [Data Flow](#data-flow)
- [Network Monitoring](#network-monitoring)
- [UI Components](#ui-components)
- [Integration Points](#integration-points)

## Core Principles

1. **Local-First Data Access**: All data reads优先 from local database for instant access
2. **Optimistic UI Updates**: User actions update UI immediately, synced in background
3. **Transparent Sync**: Synchronization happens automatically without user intervention
4. **Conflict-Aware**: Graceful handling of concurrent edits with multiple resolution strategies
5. **Resilient Operations**: Queued operations persist across app restarts
6. **Progressive Enhancement**: Full functionality offline, enhanced when online
7. **User Trust**: Clear indicators of sync status and data safety

## Architecture Layers

The offline-first architecture integrates cleanly with the existing clean architecture:

```
┌─────────────────────────────────────────────────────────────┐
│                    Presentation Layer                        │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐   │
│  │  Sync Status  │  │ Connectivity  │  │    Offline    │   │
│  │    Banner     │  │   Indicator   │  │    Banner     │   │
│  └───────────────┘  └───────────────┘  └───────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                      Domain Layer                            │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐   │
│  │ Sync Manager  │  │   Conflict    │  │ Connectivity  │   │
│  │               │  │   Resolver    │  │   Service     │   │
│  └───────────────┘  └───────────────┘  └───────────────┘   │
│  ┌───────────────┐  ┌───────────────┐                        │
│  │ Sync Queue    │  │ Offline-Aware │                        │
│  │   Service     │  │  Repositories │                        │
│  └───────────────┘  └───────────────┘                        │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                       Data Layer                             │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐   │
│  │   Local DB    │  │  Sync Queue   │  │   Remote API  │   │
│  │  (Drift/SQL)  │  │   Repository  │  │   (GraphQL)   │   │
│  └───────────────┘  └───────────────┘  └───────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                   Infrastructure Layer                       │
│  ┌───────────────┐  ┌───────────────┐  ┌───────────────┐   │
│  │ Connectivity  │  │ Background    │  │   Sync Queue  │   │
│  │  + Path       │  │   Sync        │  │   Processor   │   │
│  └───────────────┘  └───────────────┘  └───────────────┘   │
└─────────────────────────────────────────────────────────────┘
```

## Database Schema

### Design Decisions

The local database uses **Drift ORM** (formerly Moor) for type-safe SQL operations. Key design decisions:

1. **SQLite as Storage Engine**: Reliable, embedded, no external dependencies
2. **Sync Metadata in Tables**: Each entity table includes sync status fields
3. **Soft Deletes**: Records marked as deleted, purged after successful sync
4. **Version Vectors**: Each entity has a version number for conflict detection
5. **Comprehensive Indexing**: Optimized for common query patterns

### Entity Tables

#### Trips Table

```dart
class Trips extends Table {
  TextColumn get id => text()();
  TextColumn get userId => text()();
  TextColumn get title => text()();
  TextColumn get description => text().nullable()();
  DateTimeColumn get startDate => dateTime()();
  DateTimeColumn get endDate => dateTime()();
  TextColumn get destination => text()();
  RealColumn get latitude => real().nullable()();
  RealColumn get longitude => real().nullable()();
  TextColumn get status => text()();
  IntColumn get budget => integer()();
  TextColumn get coverImageUrl => text().nullable()();
  TextColumn get travelCompanionIds => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get updatedAt => dateTime()();

  // Sync fields
  BoolColumn get isSynced => boolean().withDefault(const Constant(false))();
  BoolColumn get hasPendingChanges => boolean().withDefault(const Constant(false))();
  IntColumn get version => integer().withDefault(const Constant(1))();
  BoolColumn get isDeleted => boolean().withDefault(const Constant(false))();
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
}
```

**Sync Field Explanations**:
- `isSynced`: True if record matches server state
- `hasPendingChanges`: True if locally modified since last sync
- `version`: Incremented on each server update (optimistic locking)
- `isDeleted`: Soft delete flag, record purged after successful sync
- `lastSyncedAt`: Timestamp of last successful sync

#### Journals Table

Similar structure to Trips with additional fields:
- `tripId`: Foreign key to parent trip
- `content`: Journal body text
- `mood`: Optional mood tag
- `location`: Optional location name
- `imageUrls`: JSON array of image URLs
- `tags`: JSON array of tags

#### Users Table

Caches user profile data from AWS Cognito + profile service:
- Profile information (username, display name, bio, avatar)
- Preferences stored as JSON
- Last login tracking
- Sync metadata for profile changes

#### SyncQueue Table

Queues operations for synchronization:

```dart
class SyncQueue extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get entityType => text()(); // 'trip', 'journal', 'user'
  TextColumn get entityId => text()();
  TextColumn get operation => text()(); // 'create', 'update', 'delete'
  TextColumn get data => text()(); // JSON payload
  TextColumn get priority => text()(); // 'high', 'normal', 'low'
  IntColumn get retryCount => integer().withDefault(const Constant(0))();
  IntColumn get maxRetries => integer().withDefault(const Constant(3))();
  TextColumn get status => text()(); // 'pending', 'processing', 'completed', 'failed'
  TextColumn get errorMessage => text().nullable()();
  DateTimeColumn get createdAt => dateTime()();
  DateTimeColumn get lastAttemptedAt => dateTime().nullable()();
  DateTimeColumn get completedAt => dateTime().nullable()();
  IntColumn get version => integer().nullable()();
}
```

**Queue Processing**:
1. Operations ordered by priority (high > normal > low) and creation time
2. Failed operations retried up to `maxRetries` times
3. Operations marked as 'processing' while being executed
4. Successfully completed operations retained for audit trail

#### SyncMetadata Table

Tracks synchronization state per entity type:

```dart
class SyncMetadataTable extends Table {
  TextColumn get entityType => text()(); // 'trips', 'journals', 'users'
  DateTimeColumn get lastSyncedAt => dateTime().nullable()();
  DateTimeColumn get lastSyncAttemptAt => dateTime().nullable()();
  TextColumn get lastSyncStatus => text().nullable()(); // 'success', 'failed', 'partial'
  TextColumn get lastSyncError => text().nullable()();
  TextColumn get syncToken => text().nullable'()(); // For incremental sync
  IntColumn get pendingCount => integer().withDefault(const Constant(0))();
  IntColumn get failedCount => integer().withDefault(const Constant(0))();
  DateTimeColumn get updatedAt => dateTime()();
}
```

### Indexes

Optimized indexes for common query patterns:

**Trips**:
- `idx_trips_user_id`: User's trips lookup
- `idx_trips_sync_status`: Finding unsynced records
- `idx_trips_deleted`: Soft-deleted records cleanup
- `idx_trips_user_active`: User's active trips (composite)

**Journals**:
- `idx_journals_trip_id`: Trip's journals lookup
- `idx_journals_user_id`: User's journals
- `idx_journals_sync_status`: Finding unsynced records
- `idx_journals_trip_active`: Trip's active journals (composite)
- `idx_journals_entry_date`: Chronological ordering

**SyncQueue**:
- `idx_sync_queue_pending`: Pending operations by priority
- `idx_sync_queue_failed`: Failed operations for retry
- `idx_sync_queue_entity`: Entity-specific operations
- `idx_sync_queue_retry`: Retry processing by attempt time

## Synchronization Engine

### Sync Manager

The `SyncManager` orchestrates all synchronization operations:

**Key Responsibilities**:
1. Coordinate upload and download sync phases
2. Ensure only one sync cycle runs at a time
3. Provide real-time sync status updates via stream
4. Trigger auto-sync when connectivity is restored
5. Handle sync errors gracefully with retry logic

**Sync Cycle**:

```dart
Future<SyncResult> startSync({bool force = false}) async {
  final stopwatch = Stopwatch()..start();

  // Phase 1: Upload local changes
  _updateStatus(SyncPhase.upload);
  final uploadedCount = await _uploadLocalChanges();

  // Phase 2: Download server changes
  _updateStatus(SyncPhase.download);
  final downloadedCount = await _downloadServerChanges();

  // Phase 3: Resolve conflicts
  _updateStatus(SyncPhase.conflictResolution);
  final conflictsResolved = await _resolveConflicts();

  // Phase 4: Finalize
  _updateStatus(SyncPhase.finalization);
  await _finalizeSync();

  stopwatch.stop();
  return SyncResult.success(
    uploadedCount: uploadedCount,
    downloadedCount: downloadedCount,
    conflictsResolved: conflictsResolved,
    duration: stopwatch.elapsed,
  );
}
```

**Sync States**:
- `idle`: Not actively syncing
- `syncing`: Sync in progress
- `error`: Sync encountered error
- `paused`: Sync paused (e.g., offline)

**Sync Phases**:
- `upload`: Pushing local changes to server
- `download`: Pulling server changes locally
- `conflictResolution`: Resolving conflicts
- `finalization`: Completing sync cycle

### Upload Sync (Local → Server)

1. **Fetch Pending Operations**: Query sync queue for pending operations
2. **Prioritize**: Sort by priority (high > normal > low) and creation time
3. **Execute**: Send mutations to server via GraphQL
4. **Handle Response**:
   - Success: Mark operation completed, update local entity
   - Failure: Increment retry count, queue for retry
   - Conflict: Trigger conflict resolution
5. **Clean Up**: Remove completed operations from queue

**Error Handling**:
- Network errors: Increment retry count, keep in queue
- Validation errors: Mark as failed, store error message
- Authentication errors: Trigger re-authentication flow
- Server errors: Retry with exponential backoff

### Download Sync (Server → Local)

1. **Check Incremental Sync**: Use sync token if available
2. **Fetch Changes**: Query server for changes since last sync
3. **Process Entities**:
   - New entities: Insert into local database
   - Updated entities: Update local database, preserve local changes if any
   - Deleted entities: Mark as deleted locally
4. **Update Metadata**: Update sync token and timestamps

**Incremental Sync Strategy**:
```dart
final syncToken = await _getSyncToken('trips');
final serverChanges = await _api.fetchTrips(since: syncToken);

for (final trip in serverChanges) {
  final local = await _localDb.getTrip(trip.id);
  if (local == null) {
    // New entity on server
    await _localDb.insertTrip(trip);
  } else if (local.hasPendingChanges) {
    // Local has uncommitted changes - trigger conflict
    await _conflictResolver.recordConflict(/* ... */);
  } else if (trip.version > local.version) {
    // Server has newer version
    await _localDb.updateTrip(trip);
  }
}
```

### Conflict Resolution

The offline-first architecture implements a sophisticated conflict resolution system:

**Conflict Types**:

1. **Concurrent Update**: Both client and server modified the same entity
2. **Delete-Modify**: Entity deleted on one side, modified on the other
3. **Duplicate Create**: Entity created offline but already exists on server
4. **Version Mismatch**: Client version doesn't match server version

**Resolution Strategies**:

1. **Last Write Wins** (Default): Choose version with most recent `updatedAt` timestamp
2. **Server Wins**: Always prefer server version (authoritative)
3. **Client Wins**: Always prefer local version (user's intent)
4. **Manual**: Require user intervention (for critical conflicts)

**Conflict Resolution Process**:

```dart
Future<ConflictResolutionResult> resolveAllConflicts() async {
  final conflicts = await getUnresolvedConflicts();
  var resolved = 0;
  var manualRequired = 0;
  var failed = 0;

  for (final conflict in conflicts) {
    final strategy = _selectStrategy(conflict);

    if (strategy == ConflictResolutionStrategy.manual) {
      manualRequired++;
      continue;
    }

    final success = await resolveConflict(conflict.id, strategy);
    if (success) {
      resolved++;
    } else {
      failed++;
    }
  }

  return ConflictResolutionResult(
    resolvedCount: resolved,
    manualResolutionRequired: manualRequired,
    failedCount: failed,
    pendingConflicts: conflicts.where((c) => !c.isResolved).toList(),
  );
}
```

**Strategy Selection Logic**:

```dart
ConflictResolutionStrategy _selectStrategy(Conflict conflict) {
  switch (conflict.type) {
    case ConflictType.concurrentUpdate:
      // Use last write wins for most concurrent updates
      return ConflictResolutionStrategy.lastWriteWins;

    case ConflictType.deleteModify:
      // Delete-modify requires manual resolution
      return ConflictResolutionStrategy.manual;

    case ConflictType.duplicateCreate:
      // For duplicates, prefer server version (it was created first)
      return ConflictResolutionStrategy.serverWins;

    case ConflictType.versionMismatch:
      // Version mismatch typically resolves with server wins
      return ConflictResolutionStrategy.serverWins;
  }
}
```

**Conflict Tracking**:
- All conflicts logged with timestamps and metadata
- Resolved conflicts retained for audit trail
- Unresolved conflicts surfaced to user for manual resolution
- Old conflicts automatically cleaned up after 30 days

## Repository Pattern

The `OfflineAwareRepository` base class provides offline-first functionality to all repositories:

### Read Operations (Local-First)

```dart
Future<Entity> getById(String id) async {
  // Step 1: Try local database
  final localModel = await readFromLocal(id);
  if (localModel != null) {
    return modelToEntity(localModel); // Return immediately
  }

  // Step 2: Not in local cache, check connectivity
  final isConnected = await _connectivityService.checkConnectivity();
  if (!isConnected.isConnected) {
    throw CacheException('Not available offline');
  }

  // Step 3: Fetch from remote API
  final remoteEntity = await executeRemoteFetch(id);

  // Step 4: Cache locally
  await writeToLocal(entityToModel(remoteEntity));

  return remoteEntity;
}
```

### Write Operations (Optimistic)

```dart
Future<RepositoryOperationResult<Entity>> create(CreateModel model) async {
  // Step 1: Generate temporary ID
  final tempId = _generateTemporaryId();

  // Step 2: Write to local database immediately
  final localModel = await writeToLocal(model, id: tempId);

  // Step 3: Check connectivity
  final isConnected = await _connectivityService.checkConnectivity();

  if (isConnected.isConnected) {
    // Online: Execute immediately
    try {
      final remoteEntity = await executeRemoteCreate(model);
      await writeToLocal(entityToModel(remoteEntity)); // Update with server ID
      return RepositoryOperationResult.immediate(remoteEntity);
    } catch (e) {
      // Remote failed, queue for sync
      await _queueOperation(/* ... */);
      return RepositoryOperationResult.queued(modelToEntity(localModel));
    }
  } else {
    // Offline: Queue for sync
    await _queueOperation(/* ... */);
    return RepositoryOperationResult.queued(modelToEntity(localModel));
  }
}
```

**Benefits**:
- **Instant UI Updates**: Local writes complete immediately
- **Resilience**: Operations queued if network fails
- **Optimistic UX**: Users see their changes right away
- **Transparent Sync**: Background sync processes queue

### Repository Implementation Example

```dart
class TripRepositoryImpl extends OfflineAwareRepository<Trip, LocalTrip, TripCreateInput, TripUpdateInput> {
  final TripRemoteDataSource _remoteDataSource;
  final TripDao _tripDao;

  TripRepositoryImpl({
    required ConnectivityService connectivityService,
    required SyncQueueService syncQueueService,
    required TripRemoteDataSource remoteDataSource,
    required TripDao tripDao,
  }) : _remoteDataSource = remoteDataSource,
       _tripDao = tripDao,
       super(connectivityService: connectivityService, syncQueueService: syncQueueService);

  @override
  String get entityType => 'trip';

  @override
  Trip entityToModel(Trip entity) => /* ... */;

  @override
  Trip modelToEntity(LocalTrip model) => /* ... */;

  @override
  Future<Trip> executeRemoteCreate(TripCreateInput model) async {
    return await _remoteDataSource.createTrip(model);
  }

  @override
  Future<Trip> executeRemoteUpdate(String id, TripUpdateInput model) async {
    return await _remoteDataSource.updateTrip(id, model);
  }

  // ... implement other abstract methods
}
```

## Data Flow

### Read Flow (Offline)

```
User Request
    ↓
Repository.getById()
    ↓
Local Database Query ←────────────────────┐
    ↓                                    │
Found? ──Yes──→ Return Entity            │
    ↓                                    │
   No                                    │
    ↓                                    │
Check Connectivity ──Offline──→ Throw Exception
    ↓
Online
    ↓
Remote API Call
    ↓
Cache Locally
    ↓
Return Entity
```

### Write Flow (Offline)

```
User Action (Create/Update/Delete)
    ↓
Repository Operation
    ↓
Write to Local Database (Immediate)
    ↓
Update UI (Optimistic)
    ↓
Check Connectivity
    ↓
    ├─ Online ──→ Execute Remote API
    │               ↓
    │           Success? ──Yes──→ Update Local with Server Response
    │               ↓
    │              No → Queue Operation
    │
    └─ Offline ──→ Queue Operation
                    ↓
                  Return Queued Result
```

### Sync Flow

```
Connectivity Restored / Manual Sync
    ↓
SyncManager.startSync()
    ↓
┌─────────────────────────────────────────┐
│ Phase 1: Upload Local Changes           │
│  - Fetch pending operations             │
│  - Execute mutations on server          │
│  - Handle conflicts                     │
│  - Update local state                   │
└─────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────┐
│ Phase 2: Download Server Changes        │
│  - Fetch changes since last sync        │
│  - Process new/updated entities         │
│  - Handle delete operations             │
│  - Update sync metadata                 │
└─────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────┐
│ Phase 3: Resolve Conflicts              │
│  - Detect concurrent edits              │
│  - Apply resolution strategies          │
│  - Flag manual resolution if needed     │
└─────────────────────────────────────────┘
    ↓
┌─────────────────────────────────────────┐
│ Phase 4: Finalization                   │
│  - Clean up completed operations        │
│  - Update sync tokens                   │
│  - Emit sync complete status            │
└─────────────────────────────────────────┘
    ↓
Sync Complete
```

## Network Monitoring

### Connectivity Service

The `ConnectivityService` monitors network state and provides real-time updates:

**Features**:
1. **Real-Time Monitoring**: Stream of connectivity changes
2. **Reachability Testing**: Actual HTTP requests to verify connectivity
3. **Connection Type**: Distinguish between WiFi, mobile, none
4. **Auto-Sync Trigger**: Initiates sync when connection restored

```dart
class ConnectivityServiceImpl implements ConnectivityService {
  final Connectivity _connectivity;

  @override
  Stream<ConnectivityStatus> get connectivityStatus async* {
    await for (final result in _connectivity.onConnectivityChanged) {
      final status = _mapConnectivityResult(result);
      yield status;

      // Trigger sync when connection restored
      if (status.isConnected) {
        _syncManager.startSync();
      }
    }
  }

  @override
  Future<ConnectivityStatus> checkConnectivity() async {
    final result = await _connectivity.checkConnectivity();
    final status = _mapConnectivityResult(result);

    // Verify actual reachability
    if (status.isConnected) {
      final reachable = await _verifyReachability();
      return reachable ? status : ConnectivityStatus.offline();
    }

    return status;
  }
}
```

**Connectivity States**:
- `online`: Full connectivity, server reachable
- `offline`: No connectivity
- `restored`: Just transitioned from offline to online

### Reachability Testing

Actual network verification beyond basic connectivity checks:

```dart
Future<bool> _verifyReachability() async {
  try {
    final response = await http.head(
      Uri.parse('$_healthCheckEndpoint'),
    ).timeout(
      const Duration(seconds: 5),
    );

    return response.statusCode == 200;
  } catch (e) {
    return false;
  }
}
```

## UI Components

### Sync Status Banner

Displays current sync state at the top of the screen:

**States**:
- **Syncing**: Shows progress spinner and operation count
- **Error**: Shows error message with retry button
- **Offline**: Shows "You're offline" banner
- **Success**: Briefly shows "All sync'd" message

```dart
class SyncStatusBanner extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(syncStatusProvider);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      color: _getBackgroundColor(syncStatus.state),
      child: syncStatus.isSyncing
          ? _buildSyncingContent(syncStatus)
          : syncStatus.hasError
              ? _buildErrorContent(syncStatus)
              : const SizedBox.shrink(),
    );
  }
}
```

### Connectivity Indicator

Small indicator in app bar showing network status:

```dart
Widget _buildConnectivityIndicator() {
  return Consumer(
    builder: (context, ref, child) {
      final connectivity = ref.watch(connectivityProvider);

      return Icon(
        connectivity.isConnected ? Icons.cloud_done : Icons.cloud_off,
        color: connectivity.isConnected ? Colors.green : Colors.red,
      );
    },
  );
}
```

### Offline Mode Banner

Full-width banner when offline:

```dart
class OfflineModeBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.orange.shade100,
      padding: const EdgeInsets.all(8),
      child: Row(
        children: [
          Icon(Icons.cloud_off, color: Colors.orange.shade700),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              'You\'re offline. Changes will sync when you reconnect.',
              style: TextStyle(color: Colors.orange.shade700),
            ),
          ),
        ],
      ),
    );
  }
}
```

### Sync Progress Dialog

Shows detailed sync progress:

```dart
class SyncProgressDialog extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncStatus = ref.watch(syncStatusProvider);

    return AlertDialog(
      title: Text('Syncing Data'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(_getPhaseLabel(syncStatus.phase)),
          if (syncStatus.currentOperation != null)
            Text(
              syncStatus.currentOperation!,
              style: Theme.of(context).textTheme.caption,
            ),
          SizedBox(height: 16),
          LinearProgressIndicator(value: syncStatus.progress),
        ],
      ),
    );
  }

  String _getPhaseLabel(SyncPhase phase) {
    switch (phase) {
      case SyncPhase.upload:
        return 'Uploading your changes...';
      case SyncPhase.download:
        return 'Downloading latest data...';
      case SyncPhase.conflictResolution:
        return 'Resolving conflicts...';
      case SyncPhase.finalization:
        return 'Finalizing sync...';
      default:
        return 'Syncing...';
    }
  }
}
```

### Sync Settings Screen

Configuration screen for sync behavior:

```dart
class SyncSettingsScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final syncSettings = ref.watch(syncSettingsProvider);

    return Scaffold(
      appBar: AppBar(title: Text('Sync Settings')),
      body: ListView(
        children: [
          SwitchListTile(
            title: Text('Auto-sync on WiFi only'),
            subtitle: Text('Save mobile data'),
            value: syncSettings.wifiOnly,
            onChanged: (value) => _updateSetting(ref, 'wifiOnly', value),
          ),
          SwitchListTile(
            title: Text('Background sync'),
            subtitle: Text('Sync when app is in background'),
            value: syncSettings.backgroundSync,
            onChanged: (value) => _updateSetting(ref, 'backgroundSync', value),
          ),
          ListTile(
            title: Text('Last sync'),
            subtitle: Text(_formatLastSync(syncSettings.lastSyncTime)),
          ),
          ListTile(
            title: Text('Pending operations'),
            subtitle: Text('${syncSettings.pendingCount} operations'),
            trailing: IconButton(
              icon: Icon(Icons.sync),
              onPressed: () => ref.read(syncManagerProvider).startSync(),
            ),
          ),
        ],
      ),
    );
  }
}
```

## Integration Points

### Dependency Injection

All offline-first components registered in `OfflineModule`:

```dart
class OfflineModule {
  static void registerDependencies(ServiceLocator sl) {
    // Phase 1: Connectivity
    sl.registerSingleton<ConnectivityService>(
      () => ConnectivityServiceImpl(connectivity: sl()),
    );

    // Phase 2: Local Database
    sl.registerSingleton<AppDatabase>(
      () => AppDatabase(),
    );

    // Phase 3: DAOs
    sl.registerFactory<TripDao>(() => TripDao(sl()));
    sl.registerFactory<JournalDao>(() => JournalDao(sl()));
    sl.registerFactory<UserDao>(() => UserDao(sl()));
    sl.registerFactory<SyncQueueDao>(() => SyncQueueDao(sl()));

    // Phase 4: Sync Queue
    sl.registerSingleton<SyncQueueService>(
      () => SyncQueueServiceImpl(syncQueueDao: sl()),
    );

    // Phase 5: Sync Manager
    sl.registerSingleton<SyncManager>(
      () => SyncManagerImpl(
        connectivityService: sl(),
        syncQueueService: sl(),
        conflictResolver: sl(),
      ),
    );

    // Phase 6: Repositories
    sl.registerFactory<TripRepository>(
      () => TripRepositoryImpl(
        connectivityService: sl(),
        syncQueueService: sl(),
        remoteDataSource: sl(),
        tripDao: sl(),
      ),
    );
  }
}
```

### GraphQL Integration

Sync engine integrates with existing GraphQL API:

```dart
class TripRemoteDataSource {
  final GraphQLClient _client;

  Future<Trip> createTrip(TripCreateInput input) async {
    final result = await _client.mutate(
      MutationOptions(
        document: gql('''
          mutation CreateTrip(\$input: TripCreateInput!) {
            createTrip(input: \$input) {
              id
              userId
              title
              description
              startDate
              endDate
              destination
              status
              budget
              createdAt
              updatedAt
              version
            }
          }
        '''),
        variables: {'input': input.toJson()},
      ),
    );

    if (result.hasException) {
      throw _handleGraphQLError(result.exception!);
    }

    return Trip.fromJson(result.data!['createTrip']);
  }
}
```

### Riverpod State Management

Offline-first state exposed via Riverpod providers:

```dart
@riverpod
SyncStatus syncStatus(SyncStatusRef ref) {
  final syncManager = ref.watch(syncManagerProvider);

  final subscription = syncManager.syncStatusStream.listen((status) {
    ref.state = status;
  });

  ref.onDispose(() => subscription.cancel());

  return syncManager.currentStatus;
}

@riverpod
class ConnectivityNotifier extends _$ConnectivityNotifier {
  late final ConnectivityService _service;

  @override
  ConnectivityStatus build() {
    _service = ref.watch(connectivityServiceProvider);
    _service.connectivityStatus.listen((status) => state = status);
    return _service.currentStatus;
  }
}
```

## Performance Considerations

### Database Optimization

1. **Indexes**: Strategic indexes on frequently queried columns
2. **Batch Operations**: Bulk inserts/updates where possible
3. **Connection Pooling**: Single database instance reused
4. **Query Optimization**: Use EXPLAIN QUERY PLAN for slow queries

### Sync Optimization

1. **Incremental Sync**: Only sync changed data using version tokens
2. **Delta Payloads**: Send only changed fields in mutations
3. **Compression**: Gzip compression for API requests/responses
4. **Priority Queue**: High-priority operations sync first
5. **Batching**: Group multiple operations in single API call

### Memory Management

1. **Stream Cancellation**: Properly dispose streams in onDispose
2. **Provider Scoping**: Use scoped providers where appropriate
3. **Image Caching**: Cache images locally to reduce network usage
4. **Database Cleanup**: Periodically purge old sync records

## Security Considerations

### Data Encryption

1. **Database Encryption**: Consider SQLCipher for encrypted local storage
2. **API Security**: HTTPS-only communication
3. **Token Management**: Secure storage of auth tokens in keychain
4. **Sensitive Data**: Avoid storing sensitive data in clear text

### Privacy

1. **Local Data Only**: User data stored locally, not shared
2. **User Consent**: Clear indicators when data is being synced
3. **Data Minimization**: Only sync necessary data
4. **Right to Delete**: Support for deleting local and remote data

## Testing Strategy

### Unit Tests

- **Database Layer**: Test CRUD operations, sync logic
- **Sync Engine**: Test conflict resolution, queue processing
- **Repository**: Test offline/online behavior, error handling

### Integration Tests

- **End-to-End Sync**: Test full sync cycle with mock server
- **Connectivity Changes**: Test behavior when connectivity changes
- **Conflict Scenarios**: Test various conflict resolution strategies

### Manual Testing

See `docs/OFFLINE_FIRST_TESTING.md` for comprehensive testing scenarios.

## Troubleshooting

### Common Issues

**Sync stuck in processing state**:
- Check network connectivity
- Verify server is reachable
- Restart sync cycle

**Conflicts not resolving**:
- Check conflict resolution strategy
- Review conflict logs
- Manually resolve if needed

**Local database out of sync**:
- Force full sync (clear sync token)
- Verify server data
- Check for version mismatches

### Debug Mode

Enable detailed sync logging:

```dart
void main() {
 _flutterLogs.detailedSyncLogs = true;
  runApp(MyApp());
}
```

## Future Enhancements

1. **Background Sync**: WorkManager integration for periodic sync
2. **Media Sync**: Offline photo/video upload/download
3. **Collaborative Editing**: Real-time collaborative features
4. **Sync Analytics**: Track sync performance metrics
5. **Smart Sync**: AI-powered sync scheduling based on usage patterns

## Related Documentation

- [ARCHITECTURE.md](ARCHITECTURE.md): Overall architecture
- [OFFLINE_FIRST_TESTING.md](OFFLINE_FIRST_TESTING.md): Testing guide
- [MIGRATION_GUIDE.md](MIGRATION_GUIDE.md): Migrating to offline-first
- [DEVELOPER_GUIDE.md](DEVELOPER_GUIDE.md): Developer instructions

## Changelog

### v1.0.0 (2026-01-05)
- Initial offline-first architecture implementation
- Local database with Drift ORM
- Sync queue and sync engine
- Conflict resolution
- Offline-aware repositories
- UI components for sync status
- Network monitoring
