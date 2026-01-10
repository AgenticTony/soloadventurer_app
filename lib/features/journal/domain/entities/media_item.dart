import 'package:soloadventurer/features/journal/domain/entities/shared_link.dart'; // For SyncStatus enum
import 'package:equatable/equatable.dart';

/// Represents a photo or video attached to a journal entry
class MediaItem extends Equatable {
  /// Unique identifier for the media item
  final String id;

  /// User ID who owns this media
  final String userId;

  /// Journal entry ID this media belongs to
  final String journalEntryId;

  /// Type of media
  final MediaType mediaType;

  /// Storage path in Supabase Storage
  final String storagePath;

  /// Original filename
  final String? originalFilename;

  /// File size in bytes
  final int? fileSize;

  /// MIME type
  final String? mimeType;

  /// Width of media (in pixels)
  final int? width;

  /// Height of media (in pixels)
  final int? height;

  /// Duration for videos (in seconds)
  final int? duration;

  /// Path to thumbnail image
  final String? thumbnailPath;

  /// Caption for the media
  final String? caption;

  /// Upload status
  final UploadStatus uploadStatus;

  /// Upload progress (0-100)
  final int uploadProgress;

  /// EXIF metadata from photos
  final Map<String, dynamic>? exifData;

  /// Whether this is the cover image for the entry
  final bool isCover;

  /// Order for displaying media in entry
  final int orderIndex;

  /// Sync status for offline support
  final SyncStatus syncStatus;

  /// When the media was last synced
  final DateTime? lastSyncedAt;

  /// When the media was created
  final DateTime createdAt;

  /// When the media was last updated
  final DateTime updatedAt;

  const MediaItem({
    required this.id,
    required this.userId,
    required this.journalEntryId,
    required this.mediaType,
    required this.storagePath,
    this.originalFilename,
    this.fileSize,
    this.mimeType,
    this.width,
    this.height,
    this.duration,
    this.thumbnailPath,
    this.caption,
    this.uploadStatus = UploadStatus.pending,
    this.uploadProgress = 0,
    this.exifData,
    this.isCover = false,
    this.orderIndex = 0,
    this.syncStatus = SyncStatus.synced,
    this.lastSyncedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        journalEntryId,
        mediaType,
        storagePath,
        originalFilename,
        fileSize,
        mimeType,
        width,
        height,
        duration,
        thumbnailPath,
        caption,
        uploadStatus,
        uploadProgress,
        exifData,
        isCover,
        orderIndex,
        syncStatus,
        lastSyncedAt,
        createdAt,
        updatedAt,
      ];

  /// Creates a copy of this media item with the given fields replaced
  MediaItem copyWith({
    String? id,
    String? userId,
    String? journalEntryId,
    MediaType? mediaType,
    String? storagePath,
    String? originalFilename,
    int? fileSize,
    String? mimeType,
    int? width,
    int? height,
    int? duration,
    String? thumbnailPath,
    String? caption,
    UploadStatus? uploadStatus,
    int? uploadProgress,
    Map<String, dynamic>? exifData,
    bool? isCover,
    int? orderIndex,
    SyncStatus? syncStatus,
    DateTime? lastSyncedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return MediaItem(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      journalEntryId: journalEntryId ?? this.journalEntryId,
      mediaType: mediaType ?? this.mediaType,
      storagePath: storagePath ?? this.storagePath,
      originalFilename: originalFilename ?? this.originalFilename,
      fileSize: fileSize ?? this.fileSize,
      mimeType: mimeType ?? this.mimeType,
      width: width ?? this.width,
      height: height ?? this.height,
      duration: duration ?? this.duration,
      thumbnailPath: thumbnailPath ?? this.thumbnailPath,
      caption: caption ?? this.caption,
      uploadStatus: uploadStatus ?? this.uploadStatus,
      uploadProgress: uploadProgress ?? this.uploadProgress,
      exifData: exifData ?? this.exifData,
      isCover: isCover ?? this.isCover,
      orderIndex: orderIndex ?? this.orderIndex,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Whether the upload is complete
  bool get isUploadComplete => uploadStatus == UploadStatus.completed;

  /// Whether the upload is in progress
  bool get isUploading => uploadStatus == UploadStatus.uploading;

  /// Whether the upload failed
  bool get uploadFailed => uploadStatus == UploadStatus.failed;

  /// Whether this is a video
  bool get isVideo => mediaType == MediaType.video;

  /// Whether this is a photo
  bool get isPhoto => mediaType == MediaType.photo;
}

/// Type of media
enum MediaType {
  photo,
  video,
}

/// Extension to convert MediaType to/from string
extension MediaTypeExtension on MediaType {
  String get value {
    switch (this) {
      case MediaType.photo:
        return 'photo';
      case MediaType.video:
        return 'video';
    }
  }

  static MediaType fromString(String value) {
    switch (value) {
      case 'photo':
        return MediaType.photo;
      case 'video':
        return MediaType.video;
      default:
        throw ArgumentError('Invalid MediaType value: $value');
    }
  }
}

/// Upload status for media
enum UploadStatus {
  /// Task is queued and waiting to be uploaded
  queued,

  /// Upload is in progress
  uploading,

  /// Upload completed successfully
  completed,

  /// Upload failed and will retry
  failed,

  /// Upload failed permanently and won't retry
  permanentFailure,

  /// Upload was paused
  paused,

  /// Upload was cancelled
  cancelled,

  /// Legacy: same as queued (for backward compatibility)
  pending,
}

/// Extension to convert UploadStatus to/from string
extension UploadStatusExtension on UploadStatus {
  String get value {
    switch (this) {
      case UploadStatus.queued:
        return 'queued';
      case UploadStatus.pending:
        return 'pending'; // Legacy support
      case UploadStatus.uploading:
        return 'uploading';
      case UploadStatus.completed:
        return 'completed';
      case UploadStatus.failed:
        return 'failed';
      case UploadStatus.permanentFailure:
        return 'permanent_failure';
      case UploadStatus.paused:
        return 'paused';
      case UploadStatus.cancelled:
        return 'cancelled';
    }
  }

  static UploadStatus fromString(String value) {
    switch (value) {
      case 'queued':
        return UploadStatus.queued;
      case 'pending':
        return UploadStatus.pending; // Legacy support
      case 'uploading':
        return UploadStatus.uploading;
      case 'completed':
        return UploadStatus.completed;
      case 'failed':
        return UploadStatus.failed;
      case 'permanent_failure':
        return UploadStatus.permanentFailure;
      case 'paused':
        return UploadStatus.paused;
      case 'cancelled':
        return UploadStatus.cancelled;
      default:
        throw ArgumentError('Invalid UploadStatus value: $value');
    }
  }

  /// Whether the upload is in a terminal state
  bool get isTerminal =>
      this == UploadStatus.completed ||
      this == UploadStatus.permanentFailure ||
      this == UploadStatus.cancelled;

  /// Whether the upload can be retried
  bool get canRetry =>
      this == UploadStatus.failed || this == UploadStatus.paused;

  /// Whether the upload is active
  bool get isActive =>
      this == UploadStatus.queued ||
      this == UploadStatus.pending ||
      this == UploadStatus.uploading;
}
