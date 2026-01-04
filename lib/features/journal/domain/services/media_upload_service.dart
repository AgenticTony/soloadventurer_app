import 'dart:io';
import '../../data/models/upload_task.dart';
import '../entities/media_item.dart';

/// Result of an upload operation
class UploadResult {
  /// The upload task that was executed
  final UploadTask task;

  /// Whether the upload was successful
  final bool success;

  /// Error message if upload failed
  final String? error;

  /// Storage path of the uploaded file
  final String? storagePath;

  const UploadResult({
    required this.task,
    required this.success,
    this.error,
    this.storagePath,
  });

  /// Creates a successful upload result
  factory UploadResult.success({
    required UploadTask task,
    required String storagePath,
  }) {
    return UploadResult(
      task: task,
      success: true,
      storagePath: storagePath,
    );
  }

  /// Creates a failed upload result
  factory UploadResult.failure({
    required UploadTask task,
    required String error,
  }) {
    return UploadResult(
      task: task,
      success: false,
      error: error,
    );
  }
}

/// Configuration for upload operations
class UploadConfig {
  /// Maximum concurrent uploads
  final int maxConcurrentUploads;

  /// Maximum number of retry attempts
  final int maxRetries;

  /// Delay before retry (exponential backoff base)
  final Duration retryDelay;

  /// Maximum retry delay
  final Duration maxRetryDelay;

  /// Timeout for each upload
  final Duration uploadTimeout;

  /// Enable compression before upload
  final bool enableCompression;

  /// Chunk size for multipart uploads (bytes)
  final int chunkSize;

  /// Priority for uploads
  final int defaultPriority;

  /// Default configuration
  static const defaultConfig = UploadConfig(
    maxConcurrentUploads: 3,
    maxRetries: 3,
    retryDelay: Duration(seconds: 5),
    maxRetryDelay: Duration(minutes: 5),
    uploadTimeout: Duration(minutes: 5),
    enableCompression: true,
    chunkSize: 1024 * 1024, // 1 MB
    defaultPriority: 0,
  );

  /// Configuration for slow networks
  static const slowNetworkConfig = UploadConfig(
    maxConcurrentUploads: 1,
    maxRetries: 5,
    retryDelay: Duration(seconds: 10),
    maxRetryDelay: Duration(minutes: 10),
    uploadTimeout: Duration(minutes: 10),
    enableCompression: true,
    chunkSize: 512 * 1024, // 512 KB
    defaultPriority: 0,
  );

  const UploadConfig({
    this.maxConcurrentUploads = 3,
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 5),
    this.maxRetryDelay = const Duration(minutes: 5),
    this.uploadTimeout = const Duration(minutes: 5),
    this.enableCompression = true,
    this.chunkSize = 1024 * 1024,
    this.defaultPriority = 0,
  });
}

/// Callback for upload progress updates
typedef UploadProgressCallback = void Function(
  String taskId,
  int progress,
);

/// Callback for upload status changes
typedef UploadStatusCallback = void Function(
  UploadTask task,
);

/// Service responsible for managing background media uploads
///
/// This service handles:
/// - Queuing media uploads
/// - Processing uploads in the background
/// - Tracking upload progress
/// - Handling retries with exponential backoff
/// - Managing offline scenarios
/// - Persisting upload state
abstract class MediaUploadService {
  /// Get all upload tasks
  List<UploadTask> getTasks();

  /// Get tasks for a specific journal entry
  List<UploadTask> getTasksForEntry(String entryId);

  /// Get a specific task by ID
  UploadTask? getTask(String taskId);

  /// Add a new upload task to the queue
  ///
  /// [file] - The file to upload
  /// [mediaType] - Type of media (photo or video)
  /// [journalEntryId] - Associated journal entry ID
  /// [config] - Optional upload configuration
  /// [priority] - Priority for this upload (higher = earlier)
  ///
  /// Returns the created upload task
  Future<UploadTask> enqueueUpload({
    required File file,
    required MediaType mediaType,
    String? journalEntryId,
    UploadConfig? config,
    int? priority,
  });

  /// Add multiple upload tasks at once
  Future<List<UploadTask>> enqueueMultipleUploads({
    required List<File> files,
    required List<MediaType> mediaTypes,
    String? journalEntryId,
    UploadConfig? config,
    int? priority,
  });

  /// Start processing the upload queue
  Future<void> startUploads();

  /// Pause all uploads
  Future<void> pauseUploads();

  /// Resume paused uploads
  Future<void> resumeUploads();

  /// Cancel a specific upload task
  Future<void> cancelUpload(String taskId);

  /// Cancel all uploads
  Future<void> cancelAllUploads();

  /// Retry a failed upload
  Future<void> retryUpload(String taskId);

  /// Remove completed or failed tasks from queue
  Future<void> clearCompletedTasks();

  /// Clear all tasks from queue
  Future<void> clearAllTasks();

  /// Get upload progress for a task
  Stream<UploadTask> getTaskProgress(String taskId);

  /// Get overall upload queue status
  Stream<List<UploadTask>> getQueueStatus();

  /// Register a callback for progress updates
  void onProgressUpdate(UploadProgressCallback callback);

  /// Register a callback for status changes
  void onStatusChange(UploadStatusCallback callback);

  /// Unregister progress callback
  void removeProgressCallback(UploadProgressCallback callback);

  /// Unregister status callback
  void removeStatusCallback(UploadStatusCallback callback);

  /// Get current configuration
  UploadConfig get config;

  /// Update configuration
  void updateConfig(UploadConfig config);

  /// Get upload statistics
  UploadStatistics getStatistics();

  /// Initialize the service
  Future<void> initialize();

  /// Dispose the service and clean up resources
  Future<void> dispose();
}

/// Statistics about upload operations
class UploadStatistics {
  /// Total number of uploads ever attempted
  final int totalUploads;

  /// Number of successful uploads
  final int successfulUploads;

  /// Number of failed uploads
  final int failedUploads;

  /// Number of currently active uploads
  final int activeUploads;

  /// Total bytes uploaded
  final int totalBytesUploaded;

  /// Total bytes to upload (including pending)
  final int totalBytesToUpload;

  /// Average upload speed in bytes/second
  final double averageSpeed;

  /// Total time spent uploading
  final Duration totalUploadTime;

  const UploadStatistics({
    required this.totalUploads,
    required this.successfulUploads,
    required this.failedUploads,
    required this.activeUploads,
    required this.totalBytesUploaded,
    required this.totalBytesToUpload,
    required this.averageSpeed,
    required this.totalUploadTime,
  });

  /// Calculate success rate (0.0 to 1.0)
  double get successRate {
    if (totalUploads == 0) return 0.0;
    return successfulUploads / totalUploads;
  }

  /// Calculate overall progress (0.0 to 1.0)
  double get overallProgress {
    if (totalBytesToUpload == 0) return 0.0;
    return totalBytesUploaded / totalBytesToUpload;
  }

  @override
  String toString() {
    return 'UploadStatistics('
        'total: $totalUploads, '
        'successful: $successfulUploads, '
        'failed: $failedUploads, '
        'active: $activeUploads, '
        'progress: ${(overallProgress * 100).toStringAsFixed(1)}%, '
        'successRate: ${(successRate * 100).toStringAsFixed(1)}%, '
        'avgSpeed: ${(averageSpeed / 1024).toStringAsFixed(1)} KB/s'
        ')';
  }
}
