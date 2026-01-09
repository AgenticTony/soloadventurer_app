import 'package:soloadventurer/features/journal/domain/entities/media_item.dart';

/// Data layer representation of [MediaItem] entity
class MediaItemModel {
  final String id;
  final String userId;
  final String journalEntryId;
  final MediaType mediaType;
  final String storagePath;
  final String? originalFilename;
  final int? fileSize;
  final String? mimeType;
  final int? width;
  final int? height;
  final int? duration;
  final String? thumbnailPath;
  final String? caption;
  final UploadStatus uploadStatus;
  final int uploadProgress;
  final Map<String, dynamic>? exifData;
  final bool isCover;
  final int orderIndex;
  final SyncStatus syncStatus;
  final DateTime? lastSyncedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const MediaItemModel({
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

  /// Creates a [MediaItemModel] from a domain [MediaItem] entity
  factory MediaItemModel.fromEntity(MediaItem media) {
    return MediaItemModel(
      id: media.id,
      userId: media.userId,
      journalEntryId: media.journalEntryId,
      mediaType: media.mediaType,
      storagePath: media.storagePath,
      originalFilename: media.originalFilename,
      fileSize: media.fileSize,
      mimeType: media.mimeType,
      width: media.width,
      height: media.height,
      duration: media.duration,
      thumbnailPath: media.thumbnailPath,
      caption: media.caption,
      uploadStatus: media.uploadStatus,
      uploadProgress: media.uploadProgress,
      exifData: media.exifData,
      isCover: media.isCover,
      orderIndex: media.orderIndex,
      syncStatus: media.syncStatus,
      lastSyncedAt: media.lastSyncedAt,
      createdAt: media.createdAt,
      updatedAt: media.updatedAt,
    );
  }

  /// Converts this [MediaItemModel] to a domain [MediaItem] entity
  MediaItem toEntity() {
    return MediaItem(
      id: id,
      userId: userId,
      journalEntryId: journalEntryId,
      mediaType: mediaType,
      storagePath: storagePath,
      originalFilename: originalFilename,
      fileSize: fileSize,
      mimeType: mimeType,
      width: width,
      height: height,
      duration: duration,
      thumbnailPath: thumbnailPath,
      caption: caption,
      uploadStatus: uploadStatus,
      uploadProgress: uploadProgress,
      exifData: exifData,
      isCover: isCover,
      orderIndex: orderIndex,
      syncStatus: syncStatus,
      lastSyncedAt: lastSyncedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Creates a [MediaItemModel] from JSON map (Supabase format)
  factory MediaItemModel.fromJson(Map<String, dynamic> json) {
    return MediaItemModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      journalEntryId: json['journal_entry_id'] as String,
      mediaType: MediaTypeExtension.fromString(
        json['media_type'] as String,
      ),
      storagePath: json['storage_path'] as String,
      originalFilename: json['original_filename'] as String?,
      fileSize: json['file_size'] as int?,
      mimeType: json['mime_type'] as String?,
      width: json['width'] as int?,
      height: json['height'] as int?,
      duration: json['duration'] as int?,
      thumbnailPath: json['thumbnail_path'] as String?,
      caption: json['caption'] as String?,
      uploadStatus: UploadStatusExtension.fromString(
        json['upload_status'] as String? ?? 'pending',
      ),
      uploadProgress: json['upload_progress'] as int? ?? 0,
      exifData: json['exif_data'] as Map<String, dynamic>?,
      isCover: json['is_cover'] as bool? ?? false,
      orderIndex: json['order_index'] as int? ?? 0,
      syncStatus: SyncStatusExtension.fromString(
        json['sync_status'] as String? ?? 'synced',
      ),
      lastSyncedAt: json['last_synced_at'] != null
          ? DateTime.parse(json['last_synced_at'] as String)
          : null,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Converts this [MediaItemModel] to JSON map (Supabase format)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'journal_entry_id': journalEntryId,
      'media_type': mediaType.value,
      'storage_path': storagePath,
      'original_filename': originalFilename,
      'file_size': fileSize,
      'mime_type': mimeType,
      'width': width,
      'height': height,
      'duration': duration,
      'thumbnail_path': thumbnailPath,
      'caption': caption,
      'upload_status': uploadStatus.value,
      'upload_progress': uploadProgress,
      'exif_data': exifData,
      'is_cover': isCover,
      'order_index': orderIndex,
      'sync_status': syncStatus.value,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates a copy of this MediaItemModel with the given fields replaced
  MediaItemModel copyWith({
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
    return MediaItemModel(
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
}
