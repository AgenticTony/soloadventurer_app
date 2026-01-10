import 'package:equatable/equatable.dart';
import '../../domain/entities/media_item.dart';

/// Represents a media upload task in the queue
class UploadTask extends Equatable {
  /// Unique identifier for the task
  final String id;

  /// Local file path to upload
  final String filePath;

  /// Type of media (photo or video)
  final MediaType mediaType;

  /// Associated journal entry ID
  final String? journalEntryId;

  /// Current upload status
  final UploadStatus status;

  /// Upload progress (0-100)
  final int progress;

  /// Number of retry attempts
  final int retryCount;

  /// Maximum number of retries allowed
  final int maxRetries;

  /// Error message if upload failed
  final String? errorMessage;

  /// Storage path after successful upload
  final String? storagePath;

  /// File size in bytes
  final int fileSize;

  /// Timestamp when task was created
  final DateTime createdAt;

  /// Timestamp when upload started
  final DateTime? startedAt;

  /// Timestamp when upload completed or failed
  final DateTime? completedAt;

  /// Timestamp for next retry attempt
  final DateTime? retryAt;

  /// Task priority (higher = earlier upload)
  final int priority;

  /// Whether to compress before upload
  final bool compressBeforeUpload;

  /// Compressed file path (if compression was done)
  final String? compressedFilePath;

  /// Creates a new [UploadTask]
  const UploadTask({
    required this.id,
    required this.filePath,
    required this.mediaType,
    this.journalEntryId,
    required this.status,
    this.progress = 0,
    this.retryCount = 0,
    this.maxRetries = 3,
    this.errorMessage,
    this.storagePath,
    required this.fileSize,
    required this.createdAt,
    this.startedAt,
    this.completedAt,
    this.retryAt,
    this.priority = 0,
    this.compressBeforeUpload = true,
    this.compressedFilePath,
  });

  /// Creates a copy with modified fields
  UploadTask copyWith({
    String? id,
    String? filePath,
    MediaType? mediaType,
    String? journalEntryId,
    UploadStatus? status,
    int? progress,
    int? retryCount,
    int? maxRetries,
    String? errorMessage,
    String? storagePath,
    int? fileSize,
    DateTime? createdAt,
    DateTime? startedAt,
    DateTime? completedAt,
    DateTime? retryAt,
    int? priority,
    bool? compressBeforeUpload,
    String? compressedFilePath,
  }) {
    return UploadTask(
      id: id ?? this.id,
      filePath: filePath ?? this.filePath,
      mediaType: mediaType ?? this.mediaType,
      journalEntryId: journalEntryId ?? this.journalEntryId,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      retryCount: retryCount ?? this.retryCount,
      maxRetries: maxRetries ?? this.maxRetries,
      errorMessage: errorMessage,
      storagePath: storagePath ?? this.storagePath,
      fileSize: fileSize ?? this.fileSize,
      createdAt: createdAt ?? this.createdAt,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      retryAt: retryAt ?? this.retryAt,
      priority: priority ?? this.priority,
      compressBeforeUpload: compressBeforeUpload ?? this.compressBeforeUpload,
      compressedFilePath: compressedFilePath ?? this.compressedFilePath,
    );
  }

  /// Convert to JSON for persistence
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'file_path': filePath,
      'media_type': mediaType.value,
      'journal_entry_id': journalEntryId,
      'status': status.value,
      'progress': progress,
      'retry_count': retryCount,
      'max_retries': maxRetries,
      'error_message': errorMessage,
      'storage_path': storagePath,
      'file_size': fileSize,
      'created_at': createdAt.toIso8601String(),
      'started_at': startedAt?.toIso8601String(),
      'completed_at': completedAt?.toIso8601String(),
      'retry_at': retryAt?.toIso8601String(),
      'priority': priority,
      'compress_before_upload': compressBeforeUpload,
      'compressed_file_path': compressedFilePath,
    };
  }

  /// Create from JSON
  factory UploadTask.fromJson(Map<String, dynamic> json) {
    return UploadTask(
      id: json['id'] as String,
      filePath: json['file_path'] as String,
      mediaType: MediaTypeExtension.fromString(json['media_type'] as String),
      journalEntryId: json['journal_entry_id'] as String?,
      status: UploadStatusExtension.fromString(json['status'] as String),
      progress: json['progress'] as int? ?? 0,
      retryCount: json['retry_count'] as int? ?? 0,
      maxRetries: json['max_retries'] as int? ?? 3,
      errorMessage: json['error_message'] as String?,
      storagePath: json['storage_path'] as String?,
      fileSize: json['file_size'] as int? ?? 0,
      createdAt: DateTime.parse(json['created_at'] as String),
      startedAt: json['started_at'] != null
          ? DateTime.parse(json['started_at'] as String)
          : null,
      completedAt: json['completed_at'] != null
          ? DateTime.parse(json['completed_at'] as String)
          : null,
      retryAt: json['retry_at'] != null
          ? DateTime.parse(json['retry_at'] as String)
          : null,
      priority: json['priority'] as int? ?? 0,
      compressBeforeUpload: json['compress_before_upload'] as bool? ?? true,
      compressedFilePath: json['compressed_file_path'] as String?,
    );
  }

  /// Whether the task should retry now
  bool get shouldRetry {
    if (status != UploadStatus.failed || retryCount >= maxRetries) {
      return false;
    }
    if (retryAt == null) {
      return true;
    }
    return DateTime.now().isAfter(retryAt!);
  }

  /// Whether the task is ready to upload
  bool get isReady {
    return status == UploadStatus.queued ||
        (status == UploadStatus.failed && shouldRetry);
  }

  /// Whether the upload is complete
  bool get isComplete => status == UploadStatus.completed;

  /// Whether the upload has failed permanently
  bool get hasPermanentlyFailed => status == UploadStatus.permanentFailure;

  /// Calculate duration of upload
  Duration? get uploadDuration {
    if (startedAt == null || completedAt == null) {
      return null;
    }
    return completedAt!.difference(startedAt!);
  }

  /// Get the current file path to upload (compressed or original)
  String get currentFilePath {
    return compressedFilePath ?? filePath;
  }

  @override
  List<Object?> get props => [
        id,
        filePath,
        mediaType,
        journalEntryId,
        status,
        progress,
        retryCount,
        maxRetries,
        errorMessage,
        storagePath,
        fileSize,
        createdAt,
        startedAt,
        completedAt,
        retryAt,
        priority,
        compressBeforeUpload,
        compressedFilePath,
      ];

  @override
  String toString() {
    return 'UploadTask(id: $id, status: $status, progress: $progress%, '
        'mediaType: $mediaType, retryCount: $retryCount/$maxRetries)';
  }
}
