import 'dart:typed_data';
import '../entities/journal_entry.dart';
import '../entities/trip.dart';
import '../entities/media_item.dart';
import '../entities/tag.dart';

/// Configuration for backup operations
class BackupConfig {
  /// Whether to include media files (photos/videos)
  final bool includeMedia;

  /// Whether to encrypt the backup
  final bool encrypt;

  /// Encryption password (required if encrypt is true)
  final String? encryptionPassword;

  /// Compression level (0-9, where 9 is maximum compression)
  final int compressionLevel;

  /// Whether to verify data integrity after backup
  final bool verifyIntegrity;

  /// Maximum size of backup in bytes (null for unlimited)
  final int? maxBackupSize;

  /// Whether to include deleted items in backup
  final bool includeDeleted;

  /// Custom filename for the backup (without extension)
  final String? customFilename;

  /// Default configuration
  static const defaultConfig = BackupConfig(
    includeMedia: true,
    encrypt: false,
    compressionLevel: 6,
    verifyIntegrity: true,
    includeDeleted: false,
  );

  /// Configuration for full backup (with media and encryption)
  static const fullBackupConfig = BackupConfig(
    includeMedia: true,
    encrypt: true,
    compressionLevel: 9,
    verifyIntegrity: true,
    includeDeleted: false,
  );

  /// Configuration for quick backup (no media, no encryption)
  static const quickBackupConfig = BackupConfig(
    includeMedia: false,
    encrypt: false,
    compressionLevel: 3,
    verifyIntegrity: true,
    includeDeleted: false,
  );

  const BackupConfig({
    this.includeMedia = true,
    this.encrypt = false,
    this.encryptionPassword,
    this.compressionLevel = 6,
    this.verifyIntegrity = true,
    this.maxBackupSize,
    this.includeDeleted = false,
    this.customFilename,
  });

  /// Validate configuration
  bool get isValid {
    if (encrypt && encryptionPassword == null) {
      return false;
    }
    if (encrypt && encryptionPassword!.length < 8) {
      return false;
    }
    if (compressionLevel < 0 || compressionLevel > 9) {
      return false;
    }
    return true;
  }
}

/// Configuration for restore operations
class RestoreConfig {
  /// Whether to merge with existing data or replace all
  final RestoreMode mode;

  /// How to handle conflicts
  final ConflictResolution conflictResolution;

  /// Whether to restore media files
  final bool restoreMedia;

  /// Whether to verify data integrity before restoring
  final bool verifyBeforeRestore;

  /// Password for encrypted backups
  final String? encryptionPassword;

  /// Whether to create a backup before restoring
  final bool backupBeforeRestore;

  /// Which entities to restore (null = all)
  final Set<RestoreEntityType>? entitiesToRestore;

  /// Default configuration
  static const defaultConfig = RestoreConfig(
    mode: RestoreMode.merge,
    conflictResolution: ConflictResolution.keepNewest,
    restoreMedia: true,
    verifyBeforeRestore: true,
    backupBeforeRestore: true,
  );

  /// Configuration for safe restore (backup first, merge)
  static const safeRestoreConfig = RestoreConfig(
    mode: RestoreMode.merge,
    conflictResolution: ConflictResolution.keepNewest,
    restoreMedia: true,
    verifyBeforeRestore: true,
    backupBeforeRestore: true,
  );

  /// Configuration for full restore (replace all)
  static const fullRestoreConfig = RestoreConfig(
    mode: RestoreMode.replace,
    conflictResolution: ConflictResolution.keepBackup,
    restoreMedia: true,
    verifyBeforeRestore: true,
    backupBeforeRestore: false,
  );

  const RestoreConfig({
    this.mode = RestoreMode.merge,
    this.conflictResolution = ConflictResolution.keepNewest,
    this.restoreMedia = true,
    this.verifyBeforeRestore = true,
    this.encryptionPassword,
    this.backupBeforeRestore = true,
    this.entitiesToRestore,
  });
}

/// Restore mode
enum RestoreMode {
  /// Merge backup data with existing data
  merge,

  /// Replace all existing data with backup data
  replace,

  /// Preview what would be restored without actually restoring
  preview,
}

/// Conflict resolution strategy for restore
enum ConflictResolution {
  /// Keep the newest version (based on updated_at timestamp)
  keepNewest,

  /// Keep the existing version
  keepExisting,

  /// Keep the backup version
  keepBackup,

  /// Keep both versions (create duplicates)
  keepBoth,

  /// Manually resolve conflicts
  manual,
}

/// Entity types for restore
enum RestoreEntityType {
  journalEntries,
  trips,
  tags,
  media,
}

/// Result of a backup operation
class BackupResult {
  /// Whether the backup was successful
  final bool success;

  /// Path to the backup file
  final String? backupPath;

  /// Number of entries backed up
  final int entryCount;

  /// Number of trips backed up
  final int tripCount;

  /// Number of tags backed up
  final int tagCount;

  /// Number of media files backed up
  final int mediaCount;

  /// Size of the backup file in bytes
  final int fileSize;

  /// Whether the backup is encrypted
  final bool isEncrypted;

  /// Duration of the backup operation
  final Duration duration;

  /// Error message if backup failed
  final String? errorMessage;

  /// Checksum for data integrity verification
  final String? checksum;

  /// When the backup was created
  final DateTime createdAt;

  const BackupResult({
    required this.success,
    this.backupPath,
    this.entryCount = 0,
    this.tripCount = 0,
    this.tagCount = 0,
    this.mediaCount = 0,
    this.fileSize = 0,
    this.isEncrypted = false,
    required this.duration,
    this.errorMessage,
    this.checksum,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? const Duration();

  /// Create a failed backup result
  factory BackupResult.failed({
    required String errorMessage,
    Duration duration = Duration.zero,
  }) {
    return BackupResult(
      success: false,
      errorMessage: errorMessage,
      duration: duration,
    );
  }

  /// Create a successful backup result
  factory BackupResult.success({
    required String backupPath,
    required int entryCount,
    required int tripCount,
    required int tagCount,
    required int mediaCount,
    required int fileSize,
    required bool isEncrypted,
    required Duration duration,
    String? checksum,
  }) {
    return BackupResult(
      success: true,
      backupPath: backupPath,
      entryCount: entryCount,
      tripCount: tripCount,
      tagCount: tagCount,
      mediaCount: mediaCount,
      fileSize: fileSize,
      isEncrypted: isEncrypted,
      duration: duration,
      checksum: checksum,
    );
  }

  /// Get file size in human-readable format
  String get fileSizeReadable {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

/// Result of a restore operation
class RestoreResult {
  /// Whether the restore was successful
  final bool success;

  /// Number of entries restored
  final int entriesRestored;

  /// Number of trips restored
  final int tripsRestored;

  /// Number of tags restored
  final int tagsRestored;

  /// Number of media files restored
  final int mediaRestored;

  /// Number of conflicts encountered
  final int conflictCount;

  /// Number of items skipped
  final int skippedCount;

  /// Path to the backup file created before restore (if any)
  final String? preRestoreBackupPath;

  /// Duration of the restore operation
  final Duration duration;

  /// Error message if restore failed
  final String? errorMessage;

  /// Details about what was restored
  final RestoreDetails? details;

  const RestoreResult({
    required this.success,
    this.entriesRestored = 0,
    this.tripsRestored = 0,
    this.tagsRestored = 0,
    this.mediaRestored = 0,
    this.conflictCount = 0,
    this.skippedCount = 0,
    this.preRestoreBackupPath,
    required this.duration,
    this.errorMessage,
    this.details,
  });

  /// Create a failed restore result
  factory RestoreResult.failed({
    required String errorMessage,
    Duration duration = Duration.zero,
  }) {
    return RestoreResult(
      success: false,
      errorMessage: errorMessage,
      duration: duration,
    );
  }

  /// Create a successful restore result
  factory RestoreResult.success({
    required int entriesRestored,
    required int tripsRestored,
    required int tagsRestored,
    required int mediaRestored,
    required int conflictCount,
    required int skippedCount,
    String? preRestoreBackupPath,
    required Duration duration,
    RestoreDetails? details,
  }) {
    return RestoreResult(
      success: true,
      entriesRestored: entriesRestored,
      tripsRestored: tripsRestored,
      tagsRestored: tagsRestored,
      mediaRestored: mediaRestored,
      conflictCount: conflictCount,
      skippedCount: skippedCount,
      preRestoreBackupPath: preRestoreBackupPath,
      duration: duration,
      details: details,
    );
  }

  /// Total number of items restored
  int get totalItemsRestored =>
      entriesRestored + tripsRestored + tagsRestored + mediaRestored;
}

/// Detailed information about what was restored
class RestoreDetails {
  final List<String> entryIds;
  final List<String> tripIds;
  final List<String> tagIds;
  final List<String> mediaIds;
  final List<String> conflictIds;
  final List<String> skippedIds;

  const RestoreDetails({
    this.entryIds = const [],
    this.tripIds = const [],
    this.tagIds = const [],
    this.mediaIds = const [],
    this.conflictIds = const [],
    this.skippedIds = const [],
  });
}

/// Progress of a backup operation
class BackupProgress {
  /// Current stage of backup
  final BackupStage stage;

  /// Progress from 0.0 to 1.0
  final double progress;

  /// Current item being processed
  final String? currentItem;

  /// Total number of items to process
  final int totalItems;

  /// Number of items processed so far
  final int processedItems;

  /// Current file size in bytes
  final int currentSize;

  /// Estimated time remaining
  final Duration? estimatedTimeRemaining;

  const BackupProgress({
    required this.stage,
    required this.progress,
    this.currentItem,
    this.totalItems = 0,
    this.processedItems = 0,
    this.currentSize = 0,
    this.estimatedTimeRemaining,
  });

  @override
  String toString() {
    return 'BackupProgress(stage: $stage, progress: ${(progress * 100).toStringAsFixed(1)}%, '
        'processed: $processedItems/$totalItems)';
  }
}

/// Stages of backup operation
enum BackupStage {
  initializing,
  gatheringData,
  compressingData,
  encryptingData,
  finalizing,
  completed,
  failed,
}

/// Progress of a restore operation
class RestoreProgress {
  /// Current stage of restore
  final RestoreStage stage;

  /// Progress from 0.0 to 1.0
  final double progress;

  /// Current item being processed
  final String? currentItem;

  /// Total number of items to process
  final int totalItems;

  /// Number of items processed so far
  final int processedItems;

  /// Estimated time remaining
  final Duration? estimatedTimeRemaining;

  const RestoreProgress({
    required this.stage,
    required this.progress,
    this.currentItem,
    this.totalItems = 0,
    this.processedItems = 0,
    this.estimatedTimeRemaining,
  });

  @override
  String toString() {
    return 'RestoreProgress(stage: $stage, progress: ${(progress * 100).toStringAsFixed(1)}%, '
        'processed: $processedItems/$totalItems)';
  }
}

/// Stages of restore operation
enum RestoreStage {
  initializing,
  validatingBackup,
  decryptingData,
  extractingData,
  restoringData,
  finalizing,
  completed,
  failed,
}

/// Information about a backup file
class BackupInfo {
  /// Backup file path
  final String path;

  /// When the backup was created
  final DateTime createdAt;

  /// Number of entries in backup
  final int entryCount;

  /// Number of trips in backup
  final int tripCount;

  /// Number of tags in backup
  final int tagCount;

  /// Number of media files in backup
  final int mediaCount;

  /// Size of backup file in bytes
  final int fileSize;

  /// Whether the backup is encrypted
  final bool isEncrypted;

  /// App version that created the backup
  final String? appVersion;

  /// Backup checksum
  final String? checksum;

  const BackupInfo({
    required this.path,
    required this.createdAt,
    required this.entryCount,
    required this.tripCount,
    required this.tagCount,
    required this.mediaCount,
    required this.fileSize,
    required this.isEncrypted,
    this.appVersion,
    this.checksum,
  });

  /// Create from JSON map
  factory BackupInfo.fromJson(Map<String, dynamic> json) {
    return BackupInfo(
      path: json['path'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      entryCount: json['entryCount'] as int,
      tripCount: json['tripCount'] as int,
      tagCount: json['tagCount'] as int,
      mediaCount: json['mediaCount'] as int,
      fileSize: json['fileSize'] as int,
      isEncrypted: json['isEncrypted'] as bool,
      appVersion: json['appVersion'] as String?,
      checksum: json['checksum'] as String?,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() {
    return {
      'path': path,
      'createdAt': createdAt.toIso8601String(),
      'entryCount': entryCount,
      'tripCount': tripCount,
      'tagCount': tagCount,
      'mediaCount': mediaCount,
      'fileSize': fileSize,
      'isEncrypted': isEncrypted,
      'appVersion': appVersion,
      'checksum': checksum,
    };
  }

  /// Get file size in human-readable format
  String get fileSizeReadable {
    if (fileSize < 1024) return '$fileSize B';
    if (fileSize < 1024 * 1024) return '${(fileSize / 1024).toStringAsFixed(1)} KB';
    if (fileSize < 1024 * 1024 * 1024) {
      return '${(fileSize / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(fileSize / (1024 * 1024 * 1024)).toStringAsFixed(2)} GB';
  }
}

/// Exception thrown by backup service
class BackupException implements Exception {
  /// Error message
  final String message;

  /// Error code
  final BackupErrorCode code;

  /// underlying error
  final dynamic error;

  const BackupException({
    required this.message,
    required this.code,
    this.error,
  });

  @override
  String toString() => 'BackupException: $message (code: $code)';

  /// Create exception for backup creation failure
  factory BackupException.backupCreationFailed(String message, [dynamic error]) {
    return BackupException(
      message: message,
      code: BackupErrorCode.backupCreationFailed,
      error: error,
    );
  }

  /// Create exception for restore failure
  factory BackupException.restoreFailed(String message, [dynamic error]) {
    return BackupException(
      message: message,
      code: BackupErrorCode.restoreFailed,
      error: error,
    );
  }

  /// Create exception for invalid backup file
  factory BackupException.invalidBackupFile(String message) {
    return BackupException(
      message: message,
      code: BackupErrorCode.invalidBackupFile,
    );
  }

  /// Create exception for encryption failure
  factory BackupException.encryptionFailed(String message, [dynamic error]) {
    return BackupException(
      message: message,
      code: BackupErrorCode.encryptionFailed,
      error: error,
    );
  }

  /// Create exception for decryption failure
  factory BackupException.decryptionFailed(String message, [dynamic error]) {
    return BackupException(
      message: message,
      code: BackupErrorCode.decryptionFailed,
      error: error,
    );
  }

  /// Create exception for insufficient storage
  factory BackupException.insufficientStorage({
    required int requiredBytes,
    required int availableBytes,
  }) {
    return BackupException(
      message: 'Insufficient storage space. Required: ${requiredBytes} bytes, '
          'Available: ${availableBytes} bytes',
      code: BackupErrorCode.insufficientStorage,
    );
  }

  /// Create exception for checksum verification failure
  factory BackupException.checksumMismatch() {
    return const BackupException(
      message: 'Backup checksum verification failed. Data may be corrupted.',
      code: BackupErrorCode.checksumMismatch,
    );
  }
}

/// Error codes for backup operations
enum BackupErrorCode {
  backupCreationFailed,
  restoreFailed,
  invalidBackupFile,
  encryptionFailed,
  decryptionFailed,
  insufficientStorage,
  checksumMismatch,
  cancelled,
}

/// Callback type for backup progress updates
typedef BackupProgressCallback = void Function(BackupProgress progress);

/// Callback type for restore progress updates
typedef RestoreProgressCallback = void Function(RestoreProgress progress);

/// Service for backing up and restoring journal data
abstract class BackupService {
  /// Create a backup of all journal data
  ///
  /// Returns [BackupResult] with backup information
  /// Throws [BackupException] if backup fails
  Future<BackupResult> createBackup({
    required BackupConfig config,
    BackupProgressCallback? onProgress,
    String? outputPath,
  });

  /// Restore journal data from a backup file
  ///
  /// Returns [RestoreResult] with restore information
  /// Throws [BackupException] if restore fails
  Future<RestoreResult> restoreBackup({
    required String backupPath,
    required RestoreConfig config,
    RestoreProgressCallback? onProgress,
  });

  /// Get information about a backup file without restoring it
  ///
  /// Returns [BackupInfo] with backup metadata
  /// Throws [BackupException] if backup file is invalid
  Future<BackupInfo> getBackupInfo(String backupPath);

  /// Validate a backup file's integrity
  ///
  /// Returns true if backup is valid and checksum matches
  /// Throws [BackupException] if backup file is invalid
  Future<bool> validateBackup(String backupPath, {String? password});

  /// Delete a backup file
  ///
  /// Returns true if backup was deleted successfully
  Future<bool> deleteBackup(String backupPath);

  /// Get list of available backup files
  ///
  /// Returns list of [BackupInfo] for all backups
  Future<List<BackupInfo>> getAvailableBackups();

  /// Get the default backup directory path
  Future<String> getBackupDirectory();

  /// Estimate the size of a backup before creating it
  ///
  /// Returns estimated size in bytes
  Future<int> estimateBackupSize({bool includeMedia = true});

  /// Cancel the current backup or restore operation
  Future<void> cancelOperation();

  /// Check if an operation is currently running
  bool get isOperating;

  /// Stream of backup progress updates
  Stream<BackupProgress>? get backupProgressStream;

  /// Stream of restore progress updates
  Stream<RestoreProgress>? get restoreProgressStream;
}
