import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'dart:io';
import '../../domain/services/backup_service.dart';
import '../../data/services/backup_service_impl.dart';
import '../../domain/repositories/journal_repository.dart';
import '../../domain/repositories/trip_repository.dart';
import '../../domain/repositories/tag_repository.dart';
import 'journal_entry_providers.dart';
import 'trip_providers.dart';
import 'tag_providers.dart';

part 'backup_providers.g.dart';

/// Provider for the backup service
@Riverpod(keepAlive: true)
BackupService backupService(Ref ref) {
  final journalRepository = ref.watch(journalRepositoryProvider);
  final tripRepository = ref.watch(tripRepositoryProvider);
  final tagRepository = ref.watch(tagRepositoryProvider);

  return BackupServiceImpl(
    journalRepository: journalRepository,
    tripRepository: tripRepository,
    tagRepository: tagRepository,
  );
}

/// State for backup operations
class BackupState {
  /// Current status of backup
  final BackupStatus status;

  /// Progress information (0.0 to 1.0)
  final double progress;

  /// Current stage of backup
  final BackupStage? stage;

  /// Current item being processed
  final String? currentItem;

  /// Total items to process
  final int totalItems;

  /// Items processed so far
  final int processedItems;

  /// Backup result if available
  final BackupResult? result;

  /// Error message if backup failed
  final String? error;

  /// Timestamp when backup started
  final DateTime? startedAt;

  /// Timestamp when backup completed
  final DateTime? completedAt;

  const BackupState({
    this.status = BackupStatus.idle,
    this.progress = 0.0,
    this.stage,
    this.currentItem,
    this.totalItems = 0,
    this.processedItems = 0,
    this.result,
    this.error,
    this.startedAt,
    this.completedAt,
  });

  /// Whether backup is currently in progress
  bool get isBackingUp => status == BackupStatus.backingUp;

  /// Whether backup completed successfully
  bool get isSuccess => status == BackupStatus.success;

  /// Whether backup failed
  bool get isFailed => status == BackupStatus.failed;

  /// Whether backup is idle (not started)
  bool get isIdle => status == BackupStatus.idle;

  /// Get duration of backup
  Duration? get backupDuration {
    if (startedAt == null || completedAt == null) return null;
    return completedAt!.difference(startedAt!);
  }

  /// Copy with method
  BackupState copyWith({
    BackupStatus? status,
    double? progress,
    BackupStage? stage,
    String? currentItem,
    int? totalItems,
    int? processedItems,
    BackupResult? result,
    String? error,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return BackupState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      stage: stage ?? this.stage,
      currentItem: currentItem ?? this.currentItem,
      totalItems: totalItems ?? this.totalItems,
      processedItems: processedItems ?? this.processedItems,
      result: result ?? this.result,
      error: error ?? this.error,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  String toString() {
    return 'BackupState(status: $status, progress: ${(progress * 100).toStringAsFixed(1)}%, '
        'stage: $stage, item: $processedItems/$totalItems)';
  }
}

/// Status of backup operation
enum BackupStatus {
  /// No backup in progress
  idle,

  /// Backup is in progress
  backingUp,

  /// Backup completed successfully
  success,

  /// Backup failed
  failed,
}

/// Notifier for backup state management
@riverpod
class BackupNotifier extends _$BackupNotifier {
  @override
  BackupState build() {
    return const BackupState();
  }

  /// Create a backup with the specified configuration
  Future<void> createBackup({
    BackupConfig? config,
    String? outputPath,
  }) async {
    final service = ref.read(backupServiceProvider);

    state = state.copyWith(
      status: BackupStatus.backingUp,
      startedAt: DateTime.now(),
      error: null,
      result: null,
    );

    try {
      final effectiveConfig = config ?? BackupConfig.defaultConfig;

      final result = await service.createBackup(
        config: effectiveConfig,
        onProgress: (progress) {
          state = state.copyWith(
            progress: progress.progress,
            stage: progress.stage,
            currentItem: progress.currentItem,
            totalItems: progress.totalItems,
            processedItems: progress.processedItems,
          );
        },
        outputPath: outputPath,
      );

      state = state.copyWith(
        status: BackupStatus.success,
        progress: 1.0,
        result: result,
        completedAt: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        status: BackupStatus.failed,
        error: e.toString(),
        completedAt: DateTime.now(),
      );
      rethrow;
    }
  }

  /// Reset the state to idle
  void reset() {
    state = const BackupState();
  }

  /// Clear the error but keep other state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// State for restore operations
class RestoreState {
  /// Current status of restore
  final RestoreStatus status;

  /// Progress information (0.0 to 1.0)
  final double progress;

  /// Current stage of restore
  final RestoreStage? stage;

  /// Current item being processed
  final String? currentItem;

  /// Total items to restore
  final int totalItems;

  /// Items restored so far
  final int processedItems;

  /// Restore result if available
  final RestoreResult? result;

  /// Error message if restore failed
  final String? error;

  /// Timestamp when restore started
  final DateTime? startedAt;

  /// Timestamp when restore completed
  final DateTime? completedAt;

  const RestoreState({
    this.status = RestoreStatus.idle,
    this.progress = 0.0,
    this.stage,
    this.currentItem,
    this.totalItems = 0,
    this.processedItems = 0,
    this.result,
    this.error,
    this.startedAt,
    this.completedAt,
  });

  /// Whether restore is currently in progress
  bool get isRestoring => status == RestoreStatus.restoring;

  /// Whether restore completed successfully
  bool get isSuccess => status == RestoreStatus.success;

  /// Whether restore failed
  bool get isFailed => status == RestoreStatus.failed;

  /// Whether restore is idle (not started)
  bool get isIdle => status == RestoreStatus.idle;

  /// Get duration of restore
  Duration? get restoreDuration {
    if (startedAt == null || completedAt == null) return null;
    return completedAt!.difference(startedAt!);
  }

  /// Copy with method
  RestoreState copyWith({
    RestoreStatus? status,
    double? progress,
    RestoreStage? stage,
    String? currentItem,
    int? totalItems,
    int? processedItems,
    RestoreResult? result,
    String? error,
    DateTime? startedAt,
    DateTime? completedAt,
  }) {
    return RestoreState(
      status: status ?? this.status,
      progress: progress ?? this.progress,
      stage: stage ?? this.stage,
      currentItem: currentItem ?? this.currentItem,
      totalItems: totalItems ?? this.totalItems,
      processedItems: processedItems ?? this.processedItems,
      result: result ?? this.result,
      error: error ?? this.error,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  String toString() {
    return 'RestoreState(status: $status, progress: ${(progress * 100).toStringAsFixed(1)}%, '
        'stage: $stage, item: $processedItems/$totalItems)';
  }
}

/// Status of restore operation
enum RestoreStatus {
  /// No restore in progress
  idle,

  /// Restore is in progress
  restoring,

  /// Restore completed successfully
  success,

  /// Restore failed
  failed,
}

/// Notifier for restore state management
@riverpod
class RestoreNotifier extends _$RestoreNotifier {
  @override
  RestoreState build() {
    return const RestoreState();
  }

  /// Restore from a backup file
  Future<void> restoreBackup({
    required String backupPath,
    RestoreConfig? config,
  }) async {
    final service = ref.read(backupServiceProvider);

    state = state.copyWith(
      status: RestoreStatus.restoring,
      startedAt: DateTime.now(),
      error: null,
      result: null,
    );

    try {
      final effectiveConfig = config ?? RestoreConfig.defaultConfig;

      final result = await service.restoreBackup(
        backupPath: backupPath,
        config: effectiveConfig,
        onProgress: (progress) {
          state = state.copyWith(
            progress: progress.progress,
            stage: progress.stage,
            currentItem: progress.currentItem,
            totalItems: progress.totalItems,
            processedItems: progress.processedItems,
          );
        },
      );

      state = state.copyWith(
        status: RestoreStatus.success,
        progress: 1.0,
        result: result,
        completedAt: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(
        status: RestoreStatus.failed,
        error: e.toString(),
        completedAt: DateTime.now(),
      );
      rethrow;
    }
  }

  /// Reset the state to idle
  void reset() {
    state = const RestoreState();
  }

  /// Clear the error but keep other state
  void clearError() {
    state = state.copyWith(error: null);
  }
}

/// Provider for available backups list
@riverpod
Future<List<BackupInfo>> availableBackups(Ref ref) async {
  final service = ref.watch(backupServiceProvider);
  return await service.getAvailableBackups();
}

/// Provider for estimated backup size
@riverpod
Future<int> estimatedBackupSize(
  Ref ref, {
  bool includeMedia = true,
}) async {
  final service = ref.watch(backupServiceProvider);
  return await service.estimateBackupSize(includeMedia: includeMedia);
}

/// Provider for backup directory path
@riverpod
Future<String> backupDirectoryPath(Ref ref) async {
  final service = ref.watch(backupServiceProvider);
  return await service.getBackupDirectory();
}

/// Family provider for getting info about a specific backup
@riverpod
Future<BackupInfo> backupInfo(Ref ref, String backupPath) async {
  final service = ref.watch(backupServiceProvider);
  return await service.getBackupInfo(backupPath);
}
