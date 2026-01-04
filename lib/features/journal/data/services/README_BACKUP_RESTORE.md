# Backup & Restore Service

Comprehensive backup and restore functionality for the travel journal feature.

## Overview

The backup and restore service allows users to:
- Create complete backups of all journal data (entries, trips, tags, media)
- Restore data from backup files
- Optional encryption for backup security
- Configurable compression levels
- Data integrity verification
- Conflict resolution during restore
- Progress tracking for long operations

## Architecture

The service follows Clean Architecture principles:

```
lib/features/journal/
├── domain/
│   └── services/
│       └── backup_service.dart           # Domain service interface
├── data/
│   └── services/
│       ├── backup_service_impl.dart      # Service implementation
│       └── README_BACKUP_RESTORE.md      # This file
└── presentation/
    ├── providers/
    │   └── backup_providers.dart         # Riverpod state management
    └── widgets/
        └── backup_restore_widget.dart    # UI components
```

## Installation

### Dependencies

The service requires the following packages (already in `pubspec.yaml`):

```yaml
dependencies:
  archive: ^3.6.1          # ZIP file creation/extraction
  encrypt: ^5.0.3          # Encryption/decryption
  crypto: ^3.0.3           # Checksum calculation
  path_provider: ^2.1.4    # File system access
  package_info_plus: ^8.3.0 # App version info
  intl: ^0.19.0            # Date formatting
```

### Setup

No additional setup is required. The service is initialized through Riverpod providers.

## Features

### Backup Features

- **Complete Data Backup**: Backs up all journal entries, trips, tags, and media files
- **Optional Encryption**: Password-protect backups using AES encryption
- **Configurable Compression**: Choose compression level (0-9) for file size vs. speed
- **Integrity Verification**: Optional checksum verification after backup creation
- **Progress Tracking**: Real-time progress updates with stage information
- **Size Estimation**: Preview backup size before creating it

### Restore Features

- **Smart Restore Modes**: Merge with existing data or replace all
- **Conflict Resolution**: Multiple strategies for handling conflicts
  - Keep newest version
  - Keep existing version
  - Keep backup version
  - Keep both versions
- **Pre-Restore Backup**: Automatically backup current data before restoring
- **Data Validation**: Verify backup integrity before restoring
- **Selective Restore**: Choose which entity types to restore
- **Progress Tracking**: Real-time updates during restore process

### Security

- **AES Encryption**: 256-bit AES encryption in CBC mode
- **Password Protection**: Optional password for backup access
- **Checksum Verification**: SHA-256 checksums for data integrity
- **Secure Storage**: Backups stored in app's private directory

## Usage

### Basic Backup

```dart
// Create a default backup
final backupService = ref.read(backupServiceProvider);

final result = await backupService.createBackup(
  config: BackupConfig.defaultConfig,
  onProgress: (progress) {
    print('Backup: ${(progress.progress * 100).toStringAsFixed(1)}%');
  },
);

if (result.success) {
  print('Backup created: ${result.backupPath}');
  print('Size: ${result.fileSizeReadable}');
  print('Duration: ${result.duration}');
}
```

### Encrypted Backup

```dart
// Create an encrypted backup
final result = await backupService.createBackup(
  config: BackupConfig(
    includeMedia: true,
    encrypt: true,
    encryptionPassword: 'my_secure_password_123',
    compressionLevel: 9,
    verifyIntegrity: true,
  ),
);

if (result.success && result.isEncrypted) {
  print('Encrypted backup created');
}
```

### Quick Backup (No Media)

```dart
// Quick backup without media files
final result = await backupService.createBackup(
  config: BackupConfig.quickBackupConfig,
);
```

### Restore Backup

```dart
// Restore with merge mode
final result = await backupService.restoreBackup(
  backupPath: '/path/to/backup.zip',
  config: RestoreConfig.safeRestoreConfig,
  onProgress: (progress) {
    print('Restore: ${(progress.progress * 100).toStringAsFixed(1)}%');
  },
);

if (result.success) {
  print('Restored ${result.entriesRestored} entries');
  print('Conflicts: ${result.conflictCount}');
  print('Skipped: ${result.skippedCount}');
}
```

### Encrypted Backup Restore

```dart
// Restore encrypted backup
final result = await backupService.restoreBackup(
  backupPath: '/path/to/encrypted_backup.zip',
  config: RestoreConfig(
    mode: RestoreMode.merge,
    conflictResolution: ConflictResolution.keepNewest,
    encryptionPassword: 'my_secure_password_123',
    backupBeforeRestore: true,
  ),
);
```

### Get Backup Information

```dart
// Get info about a backup file
final info = await backupService.getBackupInfo('/path/to/backup.zip');

print('Created: ${info.createdAt}');
print('Entries: ${info.entryCount}');
print('Trips: ${info.tripCount}');
print('Media: ${info.mediaCount}');
print('Size: ${info.fileSizeReadable}');
print('Encrypted: ${info.isEncrypted}');
```

### List Available Backups

```dart
// Get all available backups
final backups = await backupService.getAvailableBackups();

for (final backup in backups) {
  print('${backup.createdAt}: ${backup.fileSizeReadable} - '
        '${backup.entryCount} entries');
}
```

### Estimate Backup Size

```dart
// Estimate size before creating backup
final estimatedSize = await backupService.estimateBackupSize(
  includeMedia: true,
);

print('Estimated size: ${(estimatedSize / (1024 * 1024)).toStringAsFixed(1)} MB');
```

### Validate Backup

```dart
// Validate backup integrity
final isValid = await backupService.validateBackup(
  '/path/to/backup.zip',
  password: 'password123',
);

if (isValid) {
  print('Backup is valid and integrity verified');
} else {
  print('Backup is invalid or checksum mismatch');
}
```

## Riverpod Integration

### State Management

The service provides Riverpod notifiers for state management:

```dart
// Watch backup state
final backupState = ref.watch(backupNotifierProvider);

if (backupState.isBackingUp) {
  return CircularProgressIndicator(value: backupState.progress);
} else if (backupState.isSuccess) {
  return Text('Backup: ${backupState.result!.backupPath}');
} else if (backupState.isFailed) {
  return Text('Error: ${backupState.error}');
}

// Create backup
await ref.read(backupNotifierProvider.notifier).createBackup(
  config: BackupConfig.defaultConfig,
);

// Watch restore state
final restoreState = ref.watch(restoreNotifierProvider);

if (restoreState.isRestoring) {
  return CircularProgressIndicator(value: restoreState.progress);
}

// Restore backup
await ref.read(restoreNotifierProvider.notifier).restoreBackup(
  backupPath: '/path/to/backup.zip',
  config: RestoreConfig.defaultConfig,
);
```

### Providers

Available providers:

```dart
// Service instance
backupServiceProvider

// Backup state management
backupNotifierProvider

// Restore state management
restoreNotifierProvider

// Available backups list
availableBackupsProvider

// Estimated backup size
estimatedBackupSizeProvider(includeMedia: true)

// Backup directory path
backupDirectoryPathProvider

// Specific backup info
backupInfoProvider(backupPath)
```

## UI Components

### BackupRestoreWidget

Complete UI widget for backup and restore functionality:

```dart
// Basic usage
BackupRestoreWidget(
  showBackup: true,
  showRestore: true,
  onBackupComplete: () {
    // Navigate or show success message
  },
  onRestoreComplete: () {
    // Refresh data
  },
)

// Backup only
BackupRestoreWidget(
  showBackup: true,
  showRestore: false,
)

// Restore only
BackupRestoreWidget(
  showBackup: false,
  showRestore: true,
)
```

## Configuration

### BackupConfig Options

```dart
BackupConfig(
  // Include media files (photos/videos)
  includeMedia: true,

  // Encrypt the backup
  encrypt: false,

  // Encryption password (required if encrypt=true)
  encryptionPassword: 'password123',

  // Compression level (0-9, higher = smaller but slower)
  compressionLevel: 6,

  // Verify integrity after creation
  verifyIntegrity: true,

  // Maximum backup size in bytes (null = unlimited)
  maxBackupSize: null,

  // Include soft-deleted items
  includeDeleted: false,

  // Custom filename (without extension)
  customFilename: 'my_backup',
)
```

### RestoreConfig Options

```dart
RestoreConfig(
  // Restore mode
  mode: RestoreMode.merge,

  // Conflict resolution strategy
  conflictResolution: ConflictResolution.keepNewest,

  // Restore media files
  restoreMedia: true,

  // Verify before restoring
  verifyBeforeRestore: true,

  // Password for encrypted backups
  encryptionPassword: 'password123',

  // Create backup before restore
  backupBeforeRestore: true,

  // Which entities to restore (null = all)
  entitiesToRestore: {
    RestoreEntityType.journalEntries,
    RestoreEntityType.trips,
    RestoreEntityType.tags,
  },
)
```

## Error Handling

The service throws `BackupException` for various error scenarios:

```dart
try {
  await backupService.createBackup(config: config);
} on BackupException catch (e) {
  switch (e.code) {
    case BackupErrorCode.backupCreationFailed:
      print('Failed to create backup: ${e.message}');
      break;
    case BackupErrorCode.insufficientStorage:
      print('Not enough storage space');
      break;
    case BackupErrorCode.encryptionFailed:
      print('Encryption failed');
      break;
    default:
      print('Backup error: ${e.message}');
  }
}
```

### Error Codes

- `backupCreationFailed`: General backup creation failure
- `restoreFailed`: General restore failure
- `invalidBackupFile`: Backup file is corrupted or invalid
- `encryptionFailed`: Encryption operation failed
- `decryptionFailed`: Decryption failed (wrong password?)
- `insufficientStorage`: Not enough storage space
- `checksumMismatch`: Backup integrity check failed
- `cancelled`: Operation was cancelled

## Best Practices

### 1. Regular Backups

```dart
// Create periodic backups (e.g., weekly)
Future<void> scheduleWeeklyBackup() async {
  // Create backup with timestamp
  final timestamp = DateFormat('yyyyMMDD').format(DateTime.now());
  await backupService.createBackup(
    config: BackupConfig(
      customFilename: 'weekly_backup_$timestamp',
      includeMedia: true,
      encrypt: true,
      encryptionPassword: securePassword,
    ),
  );
}
```

### 2. Pre-Restore Backups

Always use `backupBeforeRestore: true` when restoring:

```dart
await backupService.restoreBackup(
  config: RestoreConfig(
    backupBeforeRestore: true,  // Always true in production
  ),
);
```

### 3. Password Security

Store encryption passwords securely:

```dart
// Use flutter_secure_storage for passwords
final secureStorage = FlutterSecureStorage();
final password = await secureStorage.read(key: 'backup_password');

await backupService.createBackup(
  config: BackupConfig(
    encrypt: true,
    encryptionPassword: password,
  ),
);
```

### 4. Error Recovery

```dart
try {
  await backupService.restoreBackup(
    backupPath: backupPath,
    config: config,
  );
} catch (e) {
  // Restore from pre-restore backup if available
  if (result.preRestoreBackupPath != null) {
    await backupService.restoreBackup(
      backupPath: result.preRestoreBackupPath!,
      config: RestoreConfig(
        mode: RestoreMode.replace,
      ),
    );
  }
}
```

### 5. Background Operations

For large backups, consider running in background:

```dart
// Use workmanager for scheduled backups
Workmanager().executeTask((task, inputData) {
  if (task == 'backupTask') {
    backupService.createBackup(
      config: BackupConfig.defaultConfig,
    );
    return true;
  }
  return false;
});
```

## Testing

### Unit Testing

```dart
test('creates backup successfully', () async {
  final result = await backupService.createBackup(
    config: BackupConfig.defaultConfig,
  );

  expect(result.success, true);
  expect(result.backupPath, isNotNull);
  expect(result.entryCount, greaterThan(0));
});
```

### Widget Testing

```dart
testWidgets('backup widget shows progress', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      child: BackupRestoreWidget(),
    ),
  );

  // Tap create backup button
  await tester.tap(find.text('Create Backup'));
  await tester.pump();

  // Verify progress indicator is shown
  expect(find.byType(LinearProgressIndicator), findsOneWidget);
});
```

## Troubleshooting

### Issue: Backup creation fails with "insufficient storage"

**Solution**: Check available storage and reduce backup size:

```dart
final availableSpace = await _getAvailableStorage();
final estimatedSize = await backupService.estimateBackupSize();

if (estimatedSize > availableSpace) {
  // Create backup without media
  await backupService.createBackup(
    config: BackupConfig(includeMedia: false),
  );
}
```

### Issue: Restore fails with "checksum mismatch"

**Solution**: The backup file is corrupted. Use a different backup:

```dart
final backups = await backupService.getAvailableBackups();
for (final backup in backups) {
  final isValid = await backupService.validateBackup(backup.path);
  if (isValid) {
    // Use this backup
    await backupService.restoreBackup(backupPath: backup.path);
    break;
  }
}
```

### Issue: Decryption fails

**Solution**: Verify password is correct:

```dart
try {
  await backupService.validateBackup(
    backupPath,
    password: password,
  );
} catch (e) {
  print('Wrong password or corrupted backup');
}
```

## Performance Considerations

### Backup Size Optimization

```dart
// For large journals, exclude media or use higher compression
final config = BackupConfig(
  includeMedia: false,  // Reduces size significantly
  compressionLevel: 9,  // Maximum compression
);
```

### Restore Speed

- Merge mode is faster than replace mode
- Skipping media files speeds up restore
- Lower conflict count = faster restore

### Memory Usage

The service streams data to avoid memory issues:
- Media files are loaded one at a time
- Progress updates are throttled
- Large files are processed in chunks

## Future Enhancements

Potential improvements for future versions:

1. **Cloud Backup Integration**
   - Automatic backup to cloud storage
   - Cross-device sync
   - Version history

2. **Incremental Backups**
   - Only backup changed data
   - Faster subsequent backups
   - Reduced storage requirements

3. **Backup Scheduling**
   - Automatic scheduled backups
   - Configurable retention policies
   - Smart backup triggers

4. **Advanced Encryption**
   - Multiple encryption algorithms
   - Key derivation functions
   - Hardware-backed key storage

5. **Differential Restore**
   - Restore only selected items
   - Preview restore changes
   - Rollback capability

6. **Backup Analytics**
   - Storage usage trends
   - Backup success rates
   - Restore history

## API Reference

See `backup_service.dart` for complete API documentation including:
- All enum types
- All data classes
- All service methods
- All callback types

## License

This feature is part of the SoloAdventurer application.
