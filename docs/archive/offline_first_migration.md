# Offline-First Migration Guide

## Overview

This guide provides comprehensive instructions for migrating existing SoloAdventurer users to the new offline-first architecture. The migration process ensures that existing users' data is safely transferred to the local database and properly synchronized with the server.

## Table of Contents

- [Migration Strategy](#migration-strategy)
- [Pre-Migration Checklist](#pre-migration-checklist)
- [Database Migration](#database-migration)
- [Initial Data Sync](#initial-data-sync)
- [Handling Stale Data](#handling-stale-data)
- [User Experience During Migration](#user-experience-during-migration)
- [Rollback Plan](#rollback-plan)
- [Testing Checklist](#testing-checklist)
- [Post-Migration Monitoring](#post-migration-monitoring)
- [Troubleshooting](#troubleshooting)

---

## Migration Strategy

### High-Level Approach

The migration strategy follows a **phased rollout approach** with the following key principles:

1. **Zero Data Loss**: All existing user data must be preserved
2. **Backward Compatibility**: Old app versions continue working during rollout
3. **Progressive Enhancement**: Users get offline-first features gradually
4. **Seamless Experience**: Migration should be invisible to users
5. **Rollback Ready**: Ability to revert if critical issues arise

### Migration Phases

```
Phase 1: Feature Flag (Week 1)
├─ Enable offline-first for internal testers
├─ Monitor for issues
└─ Fix critical bugs

Phase 2: Beta Rollout (Week 2-3)
├─ 10% of users get offline-first
├─ Monitor metrics and error rates
└─ Adjust based on feedback

Phase 3: Gradual Rollout (Week 4-5)
├─ Increase to 50% of users
├─ Continue monitoring
└─ Address any issues

Phase 4: Full Rollout (Week 6)
├─ 100% of users on offline-first
├─ Deprecate old API endpoints
└─ Complete migration
```

### Technical Architecture

The migration uses **dual-mode operation** during rollout:

```dart
// Feature flag configuration
class OfflineFirstConfig {
  static bool get isEnabled =>
    RemoteConfigService.getBoolean('offline_first_enabled') ??
    false;

  static double get rolloutPercentage =>
    RemoteConfigService.getDouble('offline_first_rollout') ??
    0.0;
}

// User eligibility check
class MigrationEligibility {
  static bool isUserMigrated(User user) {
    return user.preferences['offline_first_enabled'] == true;
  }

  static bool shouldMigrateUser(User user) {
    if (!OfflineFirstConfig.isEnabled) return false;

    final rollout = OfflineFirstConfig.rolloutPercentage;
    final userHash = _hashUserId(user.id) % 100;

    return userHash < rollout;
  }
}
```

---

## Pre-Migration Checklist

### Infrastructure Readiness

- [ ] **Database Migration Scripts**
  - [ ] Test migration scripts on staging database
  - [ ] Verify schema compatibility
  - [ ] Document rollback procedures
  - [ ] Create backup procedures

- [ ] **API Changes**
  - [ ] Add versioning to API endpoints
  - [ ] Implement backward compatibility layer
  - [ ] Add migration-specific endpoints
  - [ ] Test with old and new app versions

- [ ] **Monitoring & Alerts**
  - [ ] Set up migration progress dashboard
  - [ ] Configure error rate alerts
  - [ ] Set up sync failure monitoring
  - [ ] Create user impact metrics

- [ ] **Feature Flags**
  - [ ] Configure remote feature flags
  - [ ] Test flag enable/disable
  - [ ] Set up rollout percentage controls
  - [ ] Create emergency kill switch

### Data Validation

- [ ] **Audit Existing Data**
  - [ ] Check for data inconsistencies
  - [ ] Identify orphaned records
  - [ ] Verify data integrity
  - [ ] Estimate data volumes

- [ ] **Backup Strategy**
  - [ ] Create full database backup
  - [ ] Test backup restoration
  - [ ] Document backup retention policy
  - [ ] Set up automated backups

---

## Database Migration

### Schema Version Management

The database uses Drift ORM's built-in migration system:

```dart
// Current schema version
static const int schemaVersion = 1;

// Migration strategy
@override
MigrationStrategy get migration {
  return MigrationStrategy(
    onCreate: (Migrator m) async {
      await m.createAll();
    },
    onUpgrade: (Migrator m, int from, int to) async {
      // Handle future schema migrations
      if (from == 1 && to == 2) {
        // Example: Add new column
        await m.addColumn(trips, trips.newColumn);
      }
    },
  );
}
```

### Initial Database Creation

For existing users, the database is created on first launch:

```dart
// Database initialization with migration support
class DatabaseService {
  Future<bool> initialize() async {
    try {
      // Check if user has existing data
      final hasExistingData = await _checkExistingUserData();

      if (hasExistingData) {
        // Trigger initial data migration
        await _migrateExistingUserData();
      }

      // Initialize database
      _database = AppDatabase();
      _isInitialized = true;

      return true;
    } catch (e) {
      // Handle initialization errors
      await _handleInitializationError(e);
      return false;
    }
  }
}
```

### Migration State Tracking

Track migration state to handle interruptions gracefully:

```dart
// Migration state stored in shared preferences
class MigrationState {
  static const String _keyMigrationStatus = 'migration_status';
  static const String _keyMigrationVersion = 'migration_version';
  static const String _keyMigrationTimestamp = 'migration_timestamp';

  Future<void> setMigrationStarted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMigrationStatus, 'started');
    await prefs.setInt(_keyMigrationVersion, DateTime.now().millisecondsSinceEpoch);
  }

  Future<void> setMigrationCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyMigrationStatus, 'completed');
    await prefs.setInt(_keyMigrationTimestamp, DateTime.now().millisecondsSinceEpoch);
  }

  Future<bool> isMigrationInProgress() async {
    final prefs = await SharedPreferences.getInstance();
    final status = prefs.getString(_keyMigrationStatus);
    return status == 'started';
  }

  Future<bool> isMigrationCompleted() async {
    final prefs = await SharedPreferences.getInstance();
    final status = prefs.getString(_keyMigrationStatus);
    return status == 'completed';
  }
}
```

---

## Initial Data Sync

### Sync Strategy Overview

The initial sync follows a **prioritized download approach**:

1. **Critical Data First**: User profile, authentication tokens
2. **Active Trips**: Current and upcoming trips
3. **Historical Data**: Past trips and journals
4. **Reference Data**: Caches, preferences, settings

### Download Sync Implementation

```dart
class InitialSyncService {
  final SyncManager _syncManager;
  final ConnectivityService _connectivity;

  /// Performs initial sync for existing user
  Future<SyncResult> performInitialSync() async {
    // Check connectivity
    if (!await _connectivity.isConnected) {
      return SyncResult.needsConnection();
    }

    try {
      // Phase 1: Sync user profile
      await _syncUserProfile();

      // Phase 2: Sync active trips (last 90 days)
      await _syncActiveTrips();

      // Phase 3: Sync historical data
      await _syncHistoricalData();

      // Phase 4: Sync reference data
      await _syncReferenceData();

      return SyncResult.success();
    } catch (e) {
      return SyncResult.failure(e.toString());
    }
  }

  Future<void> _syncUserProfile() async {
    // Fetch user profile from server
    final profile = await _apiService.getUserProfile();

    // Save to local database
    await _database.usersDao.insertOrUpdateUser(profile);

    // Update sync metadata
    await _database.syncMetadataDao.updateMetadata(
      entityType: 'user',
      entityId: profile.id,
      lastSyncedAt: DateTime.now(),
      isSynced: true,
    );
  }

  Future<void> _syncActiveTrips() async {
    final ninetyDaysAgo = DateTime.now().subtract(const Duration(days: 90));

    // Fetch active trips from server
    final trips = await _apiService.getTrips(
      startDate: ninetyDaysAgo,
      status: ['active', 'upcoming'],
    );

    // Batch insert trips
    await _database.transaction(() async {
      for (final trip in trips) {
        await _database.tripsDao.insertTrip(trip);

        // Sync trip's journals
        final journals = await _apiService.getJournals(tripId: trip.id);
        for (final journal in journals) {
          await _database.journalsDao.insertJournal(journal);
        }
      }
    });
  }

  Future<void> _syncHistoricalData() async {
    // Fetch older trips in batches to avoid overwhelming the app
    int offset = 0;
    const batchSize = 50;

    while (true) {
      final trips = await _apiService.getTrips(
        offset: offset,
        limit: batchSize,
        status: ['completed'],
      );

      if (trips.isEmpty) break;

      await _database.transaction(() async {
        for (final trip in trips) {
          await _database.tripsDao.insertTrip(trip);
        }
      });

      offset += batchSize;

      // Yield to allow UI updates
      await Future.delayed(const Duration(milliseconds: 100));
    }
  }

  Future<void> _syncReferenceData() async {
    // Sync cached data, preferences, etc.
    final preferences = await _apiService.getUserPreferences();
    await _database.usersDao.updatePreferences(preferences);
  }
}
```

### Incremental Download for Large Datasets

For users with large amounts of data:

```dart
class IncrementalSyncService {
  /// Syncs data in batches to avoid blocking the UI
  Future<void> performIncrementalSync() async {
    final syncQueue = SyncQueue();

    // Queue all sync operations
    await syncQueue.enqueue(
      SyncOperation(
        type: SyncOperationType.download,
        entityType: 'trip',
        priority: SyncPriority.high,
      ),
    );

    // Process queue in background
    await syncQueue.process(
      onProgress: (current, total) {
        // Update progress indicator
        _updateProgress(current, total);
      },
    );
  }
}
```

### Sync Progress Indication

Keep users informed during initial sync:

```dart
class SyncProgressDialog extends StatelessWidget {
  final int current;
  final int total;
  final String currentOperation;

  @override
  Widget build(BuildContext context) {
    final progress = total > 0 ? current / total : 0.0;

    return AlertDialog(
      title: const Text('Preparing Offline Mode'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(currentOperation),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: progress),
          const SizedBox(height: 8),
          Text('$current of $total items synced'),
        ],
      ),
    );
  }
}
```

---

## Handling Stale Data

### Detecting Stale Data

Stale data is data that exists on the server but hasn't been synced locally:

```dart
class StaleDataDetector {
  /// Detects stale data by comparing server and local timestamps
  Future<List<StaleDataItem>> detectStaleData() async {
    final staleItems = <StaleDataItem>[];

    // Check for stale trips
    final localTrips = await _database.tripsDao.getAllTrips();
    for (final trip in localTrips) {
      final serverTrip = await _apiService.getTrip(trip.id);

      if (serverTrip != null &&
          serverTrip.updatedAt.isAfter(trip.updatedAt)) {
        staleItems.add(StaleDataItem(
          entityType: 'trip',
          entityId: trip.id,
          localTimestamp: trip.updatedAt,
          serverTimestamp: serverTrip.updatedAt,
        ));
      }
    }

    return staleItems;
  }
}
```

### Conflict Resolution Strategy

When stale data is detected, use **server-wins** by default for initial migration:

```dart
class MigrationConflictResolver {
  Future<void> resolveStaleData(List<StaleDataItem> staleItems) async {
    for (final item in staleItems) {
      // Fetch latest data from server
      final serverData = await _apiService.getEntity(
        type: item.entityType,
        id: item.entityId,
      );

      if (serverData != null) {
        // Update local database with server data
        await _updateLocalEntity(item.entityType, serverData);

        // Mark as synced
        await _markAsSynced(item.entityType, item.entityId);
      }
    }
  }
}
```

### Data Validation After Sync

Verify data integrity after migration:

```dart
class DataValidator {
  Future<ValidationResult> validateMigratedData() async {
    final issues = <ValidationIssue>[];

    // Check for missing required fields
    final trips = await _database.tripsDao.getAllTrips();
    for (final trip in trips) {
      if (trip.title.isEmpty) {
        issues.add(ValidationIssue(
          type: IssueType.missingRequiredField,
          entity: 'trip',
          entityId: trip.id,
          field: 'title',
        ));
      }
    }

    // Check referential integrity
    final journals = await _database.journalsDao.getAllJournals();
    for (final journal in journals) {
      final tripExists = await _database.tripsDao
          .tripExists(journal.tripId);

      if (!tripExists) {
        issues.add(ValidationIssue(
          type: IssueType.orphanedRecord,
          entity: 'journal',
          entityId: journal.id,
          details: 'Parent trip ${journal.tripId} not found',
        ));
      }
    }

    return ValidationResult(
      totalRecords: trips.length + journals.length,
      issueCount: issues.length,
      issues: issues,
    );
  }
}
```

---

## User Experience During Migration

### Migration Flow

```
┌─────────────────────────────────────────────────────────────┐
│                     App Launch                              │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       ▼
            ┌──────────────────────┐
            │  Check Migration     │
            │      Status          │
            └──────────┬───────────┘
                       │
          ┌────────────┴────────────┐
          │                         │
          ▼                         ▼
  ┌───────────────┐         ┌───────────────┐
  │  Not Started  │         │   In Progress │
  │  or Failed    │         │      │        │
  └───────┬───────┘         └───────┬───────┘
          │                         │
          ▼                         ▼
  ┌───────────────┐         ┌───────────────┐
  │  Show Welcome │         │  Show Progress │
  │   Screen      │         │    Dialog      │
  └───────┬───────┘         └───────┬───────┘
          │                         │
          ▼                         ▼
  ┌───────────────┐         ┌───────────────┐
  │  Start        │         │  Resume       │
  │  Migration    │         │  Migration    │
  └───────┬───────┘         └───────┬───────┘
          │                         │
          └────────────┬────────────┘
                       │
                       ▼
            ┌──────────────────────┐
            │  Show Migration      │
            │  Progress            │
            └──────────┬───────────┘
                       │
                       ▼
            ┌──────────────────────┐
            │  Migration Complete  │
            │  Show Success Screen │
            └──────────────────────┘
```

### Welcome Screen

```dart
class MigrationWelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Welcome to Offline Mode')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Great news! SoloAdventurer now works offline.',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            const Text(
              'We need to prepare your device for offline access. '
              'This will download your trips and journals to your phone.',
            ),
            const SizedBox(height: 24),
            const Text('What this means:'),
            const BulletPoint('Access your trips without internet'),
            const BulletPoint('Make changes while offline'),
            const BulletPoint('Automatic sync when connected'),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () => _startMigration(context),
              child: const Text('Get Started'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### Progress Dialog

```dart
class MigrationProgressDialog extends StatefulWidget {
  @override
  _MigrationProgressDialogState createState() =>
      _MigrationProgressDialogState();
}

class _MigrationProgressDialogState extends State<MigrationProgressDialog> {
  String _currentPhase = 'Initializing...';
  int _currentItem = 0;
  int _totalItems = 0;

  @override
  void initState() {
    super.initState();
    _startMigration();
  }

  Future<void> _startMigration() async {
    final migrationService = MigrationService();

    migrationService.progressStream.listen((progress) {
      setState(() {
        _currentPhase = progress.phase;
        _currentItem = progress.current;
        _totalItems = progress.total;
      });
    });

    await migrationService.migrate();

    if (mounted) {
      Navigator.of(context).pop();
      _showCompleteDialog();
    }
  }

  void _showCompleteDialog() {
    showDialog(
      context: context,
      builder: (context) => MigrationCompleteDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final progress = _totalItems > 0 ? _currentItem / _totalItems : 0.0;

    return AlertDialog(
      title: const Text('Preparing Offline Mode'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(_currentPhase),
          const SizedBox(height: 16),
          LinearProgressIndicator(value: progress),
          if (_totalItems > 0) ...[
            const SizedBox(height: 8),
            Text('$_currentItem of $_totalItems'),
          ],
        ],
      ),
    );
  }
}
```

### Completion Screen

```dart
class MigrationCompleteDialog extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('You\'re All Set!'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.check_circle, size: 64, color: Colors.green),
          const SizedBox(height: 16),
          const Text(
            'SoloAdventurer is now ready for offline use.',
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          const Text(
            'Your trips and journals are stored on your device. '
            'Changes will sync automatically when you\'re online.',
            textAlign: TextAlign.center,
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Got it'),
        ),
      ],
    );
  }
}
```

---

## Rollback Plan

### Rollback Triggers

Consider rollback if any of these conditions occur:

- **Error Rate**: Sync error rate exceeds 5% for 24 hours
- **Data Loss**: Any confirmed data loss incidents
- **Performance**: App startup time increases by > 50%
- **Crashes**: Crash rate increases by > 2x
- **User Complaints**: Significant negative user feedback

### Rollback Procedure

#### Step 1: Disable Feature Flag

```bash
# Via AWS App Config or Firebase Remote Config
aws appconfig start-deployment \
  --application-id solo-adventurer \
  --environment-id production \
  --configuration-profile-id offline-first-config \
  --deployment-strategy-id immediate-rollback \
  --configuration-content '{"offline_first_enabled": false}'
```

#### Step 2: Revert API Changes

- Keep backward compatibility endpoints active
- Switch traffic to legacy API endpoints
- Monitor old API performance

#### Step 3: Clear Local Databases

```dart
class RollbackService {
  Future<void> performRollback() async {
    // Close database connection
    await DatabaseService.instance.close();

    // Delete local database
    await DatabaseService.instance.delete();

    // Clear migration flags
    await MigrationState.clear();

    // Restart app (platform-specific)
    await _restartApp();
  }
}
```

#### Step 4: Restore User Data

If users made changes while offline:

```dart
class DataRestoreService {
  /// Collects pending changes before rollback
  Future<void> collectPendingChanges() async {
    final pendingOps = await _database.syncQueueDao
        .getPendingOperations();

    for (final op in pendingOps) {
      try {
        // Try to sync pending changes
        await _syncOperation(op);
      } catch (e) {
        // Log unsynced changes
        await _logUnsyncedChange(op, e);
      }
    }
  }
}
```

### Rollback Communication

Inform users about rollback:

```dart
class RollbackNotification {
  void showRollbackNotice(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Update Available'),
        content: const Text(
          'We\'re working to improve your experience. '
          'The app will return to online mode temporarily.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
```

---

## Testing Checklist

### Pre-Migration Testing

#### Unit Tests

- [ ] **Database Migration**
  - [ ] Test database creation from scratch
  - [ ] Test migration from version 0 to 1
  - [ ] Test migration interruption and recovery
  - [ ] Test corrupt database handling

- [ ] **Initial Sync**
  - [ ] Test sync with no existing data
  - [ ] Test sync with existing data
  - [ ] Test sync interruption
  - [ ] Test sync failure scenarios

- [ ] **Conflict Resolution**
  - [ ] Test stale data detection
  - [ ] Test server-wins resolution
  - [ ] Test client-wins resolution
  - [ ] Test manual resolution flow

#### Integration Tests

- [ ] **End-to-End Migration**
  - [ ] Test full migration flow
  - [ ] Test migration state persistence
  - [ ] Test app restart during migration
  - [ ] Test network loss during migration

- [ ] **API Compatibility**
  - [ ] Test with old app version
  - [ ] Test with new app version
  - [ ] Test mixed version scenarios
  - [ ] Test API versioning

#### Performance Tests

- [ ] **Large Dataset Migration**
  - [ ] Test with 1000+ trips
  - [ ] Test with 10000+ journal entries
  - [ ] Measure migration time
  - [ ] Monitor memory usage

- [ ] **Concurrent Users**
  - [ ] Test with 100+ concurrent migrations
  - [ ] Monitor server load
  - [ ] Test database connection pooling
  - [ ] Check for race conditions

### Manual Testing

#### Test Scenarios

- [ ] **New User Onboarding**
  - [ ] Fresh install with no data
  - [ ] Account creation flow
  - [ ] Initial data setup
  - [ ] First sync completion

- [ ] **Existing User Migration**
  - [ ] User with < 10 trips
  - [ ] User with 10-50 trips
  - [ ] User with 50-100 trips
  - [ ] User with 100+ trips

- [ ] **Edge Cases**
  - [ ] Migration interrupted by app close
  - [ ] Migration interrupted by network loss
  - [ ] Migration with low storage space
  - [ ] Migration with corrupted local data

#### Device Testing

- [ ] **iOS Devices**
  - [ ] iPhone 8 (older device)
  - [ ] iPhone 13 (mid-range)
  - [ ] iPhone 15 Pro (latest)
  - [ ] iPad (tablet)

- [ ] **Android Devices**
  - [ ] Low-end Android device
  - [ ] Mid-range Android device
  - [ ] High-end Android device
  - [ ] Android tablet

- [ ] **Network Conditions**
  - [ ] Fast WiFi (> 50 Mbps)
  - [ ] Slow WiFi (< 5 Mbps)
  - [ ] 4G Cellular
  - [ ] 3G Cellular
  - [ ] Intermittent connection

### Automated Testing

```dart
// Migration test suite
void main() {
  group('Migration Tests', () {
    testWidgets('Complete migration flow', (tester) async {
      // Setup test environment
      await tester.pumpWidget(MigrationTestApp());

      // Trigger migration
      await tester.tap(find.text('Get Started'));
      await tester.pumpAndSettle();

      // Verify completion
      expect(find.text('You\'re All Set!'), findsOneWidget);
    });

    test('Migration with network interruption', () async {
      final migrationService = MigrationService();

      // Simulate network failure
      when(connectivity.isConnected)
          .thenAnswer((_) async => false);

      final result = await migrationService.migrate();

      expect(result.isSuccess, false);
      expect(result.error, contains('No internet connection'));
    });

    test('Large dataset migration performance', () async {
      // Seed test database with 1000 trips
      await seedTestDatabase(tripCount: 1000);

      final stopwatch = Stopwatch()..start();
      await MigrationService().migrate();
      stopwatch.stop();

      // Should complete in under 2 minutes
      expect(stopwatch.elapsedMilliseconds, lessThan(120000));
    });
  });
}
```

---

## Post-Migration Monitoring

### Key Metrics to Track

#### User Engagement

- **Migration Completion Rate**: % of users who completed migration
- **Migration Time**: Average time to complete migration
- **User Retention**: % of users who continue using app after migration
- **Feature Usage**: % of users actively using offline features

#### Technical Metrics

- **Sync Success Rate**: % of sync operations that succeed
- **Sync Time**: Average time for sync operations
- **Error Rate**: % of migration operations that fail
- **Database Size**: Average database size per user
- **Storage Usage**: % of users with storage warnings

#### Error Tracking

Monitor for these errors:

```dart
class MigrationMetrics {
  void trackMigrationEvent(String event, Map<String, dynamic> properties) {
    AnalyticsService.track('migration_$event', properties);
  }

  void trackMigrationError(String error, StackTrace stackTrace) {
    AnalyticsService.trackError(
      'migration_error',
      error: error,
      stackTrace: stackTrace,
    );
  }

  void trackSyncPerformance(Duration duration, int recordCount) {
    AnalyticsService.track('sync_performance', {
      'duration_ms': duration.inMilliseconds,
      'record_count': recordCount,
      'records_per_second': recordCount / duration.inSeconds,
    });
  }
}
```

### Health Checks

Implement periodic health checks:

```dart
class MigrationHealthCheck {
  Future<HealthReport> performHealthCheck() async {
    final issues = <HealthIssue>[];

    // Check database integrity
    final dbHealth = await _checkDatabaseHealth();
    if (!dbHealth.isHealthy) {
      issues.add(dbHealth);
    }

    // Check sync status
    final syncHealth = await _checkSyncHealth();
    if (!syncHealth.isHealthy) {
      issues.add(syncHealth);
    }

    // Check storage space
    final storageHealth = await _checkStorageHealth();
    if (!storageHealth.isHealthy) {
      issues.add(storageHealth);
    }

    return HealthReport(
      isHealthy: issues.isEmpty,
      issues: issues,
    );
  }
}
```

### Alerting Configuration

Set up alerts for critical issues:

```yaml
# CloudWatch Alarms (example)
alerts:
  - name: HighMigrationFailureRate
    metric: MigrationFailureRate
    threshold: 5
    comparison: GreaterThanThreshold
    period: 300
    evaluationPeriods: 1

  - name: SlowMigrationTime
    metric: MigrationTimeP95
    threshold: 120
    comparison: GreaterThanThreshold
    period: 3600
    evaluationPeriods: 2

  - name: HighSyncErrorRate
    metric: SyncErrorRate
    threshold: 10
    comparison: GreaterThanThreshold
    period: 300
    evaluationPeriods: 1
```

---

## Troubleshooting

### Common Issues

#### Issue: Migration Stuck at Progress

**Symptoms**: Progress dialog shows same percentage for > 5 minutes

**Diagnosis**:
```dart
// Check if migration is actually stuck or just slow
final migrationState = await MigrationState.getStatus();
final lastUpdate = migrationState.lastUpdateTime;
final isStuck = DateTime.now().difference(lastUpdate) > Duration(minutes: 5);
```

**Solutions**:
1. Check network connectivity
2. Check server logs for errors
3. Verify API response times
4. Consider restarting migration

#### Issue: Out of Storage Space

**Symptoms**: Migration fails with storage error

**Diagnosis**:
```dart
final storageInfo = await DeviceStorage.getStorageInfo();
if (storageInfo.availableBytes < requiredBytes) {
  // Not enough space
}
```

**Solutions**:
1. Calculate required storage upfront
2. Show user-friendly storage warning
3. Offer option to sync less data
4. Provide link to device settings

#### Issue: Database Corruption

**Symptoms**: Migration fails with database error

**Diagnosis**:
```dart
try {
  await database.customSelect('SELECT COUNT(*) FROM trips').get();
} catch (e) {
  // Database is corrupted
}
```

**Solutions**:
1. Delete corrupted database
2. Restart migration
3. Log corruption for analysis
4. Consider automatic recovery

### Debug Tools

#### Migration Debug Mode

```dart
class MigrationDebugger {
  static const bool isDebugEnabled =
      kDebugMode && kDebugMode;

  static void log(String message) {
    if (isDebugEnabled) {
      debugPrint('[Migration] $message');
    }
  }

  static void logError(String error, StackTrace stackTrace) {
    if (isDebugEnabled) {
      debugPrint('[Migration ERROR] $error');
      debugPrint(stackTrace.toString());
    }
  }
}
```

#### Diagnostic Information

```dart
class MigrationDiagnostics {
  Future<Map<String, dynamic>> getDiagnostics() async {
    return {
      'app_version': await PackageInfo.fromScope().then((info) => info.version),
      'database_path': await _getDatabasePath(),
      'database_size': await _getDatabaseSize(),
      'migration_status': await MigrationState.getStatus(),
      'sync_metadata': await _getSyncMetadata(),
      'storage_info': await _getStorageInfo(),
      'network_info': await _getNetworkInfo(),
    };
  }
}
```

### Support Escalation

When to escalate to engineering:

- **Critical**: Data loss confirmed
- **High**: > 5% failure rate for > 1 hour
- **Medium**: Performance degradation > 50%
- **Low**: User complaints increase > 2x

Escalation template:

```markdown
## Migration Issue Report

**Severity**: [Critical/High/Medium/Low]
**Started**: [Timestamp]
**Affected Users**: [Count/Percentage]

### Symptoms
[Describe what's happening]

### Metrics
- Migration Success Rate: [X]%
- Average Migration Time: [X] seconds
- Error Rate: [X]%
- Top Error: [Error message]

### Reproduction Steps
1. [Step 1]
2. [Step 2]
3. [Step 3]

### Current Impact
[Describe user impact]

### Proposed Actions
1. [Action 1]
2. [Action 2]
3. [Action 3]
```

---

## Summary

This migration guide provides a comprehensive approach to migrating existing SoloAdventurer users to the offline-first architecture. Key points:

### Success Criteria

✅ **Zero Data Loss**: All user data preserved during migration
✅ **Seamless Experience**: Migration is invisible to users
✅ **Performance**: No significant performance degradation
✅ **Reliability**: > 95% migration success rate
✅ **Rollback Ready**: Ability to revert if issues arise

### Next Steps

1. **Review this guide** with the engineering team
2. **Set up infrastructure** (feature flags, monitoring, alerts)
3. **Run pre-migration tests** (unit, integration, performance)
4. **Execute phased rollout** (10% → 50% → 100%)
5. **Monitor metrics** and respond to issues
6. **Complete rollout** and deprecate old system

### Resources

- [Offline-First Architecture](../OFFLINE_FIRST_ARCHITECTURE.md)
- [Developer Guide](../developer_guide/offline_first_development.md)
- [User Guide](../user_guide/offline_mode.md)
- [API Documentation](https://api.soloadventurer.com/docs)
- [Monitoring Dashboard](https://dashboard.soloadventurer.com)

---

**Last Updated**: 2026-01-05
**Version**: 1.0
**Maintained By**: Platform Team
