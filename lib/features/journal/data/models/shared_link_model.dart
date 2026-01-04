import 'package:soloadventurer/features/journal/domain/entities/shared_link.dart';

/// Model for [SharedLink] entity
class SharedLinkModel {
  /// Unique identifier for the shared link
  final String id;

  /// Trip ID that this link shares
  final String tripId;

  /// User ID who created this link
  final String userId;

  /// Unique slug/identifier for the share link
  final String slug;

  /// Whether the link has password protection
  final bool hasPassword;

  /// Whether the link is currently active
  final bool isActive;

  /// Optional expiration date
  final DateTime? expiresAt;

  /// Number of times the link has been viewed
  final int viewCount;

  /// Timestamp of the last view
  final DateTime? lastViewedAt;

  /// Sync status for offline support
  final String syncStatus;

  /// When the link was created
  final DateTime createdAt;

  /// When the link was last updated
  final DateTime updatedAt;

  const SharedLinkModel({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.slug,
    this.hasPassword = false,
    this.isActive = true,
    this.expiresAt,
    this.viewCount = 0,
    this.lastViewedAt,
    this.syncStatus = 'synced',
    required this.createdAt,
    required this.updatedAt,
  });

  /// Convert JSON to [SharedLinkModel]
  factory SharedLinkModel.fromJson(Map<String, dynamic> json) {
    return SharedLinkModel(
      id: json['id'] as String,
      tripId: json['trip_id'] as String,
      userId: json['user_id'] as String,
      slug: json['slug'] as String,
      hasPassword: json['has_password'] as bool? ?? false,
      isActive: json['is_active'] as bool? ?? true,
      expiresAt: json['expires_at'] != null
          ? DateTime.parse(json['expires_at'] as String)
          : null,
      viewCount: json['view_count'] as int? ?? 0,
      lastViewedAt: json['last_viewed_at'] != null
          ? DateTime.parse(json['last_viewed_at'] as String)
          : null,
      syncStatus: json['sync_status'] as String? ?? 'synced',
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
    );
  }

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'trip_id': tripId,
      'user_id': userId,
      'slug': slug,
      'has_password': hasPassword,
      'is_active': isActive,
      'expires_at': expiresAt?.toIso8601String(),
      'view_count': viewCount,
      'last_viewed_at': lastViewedAt?.toIso8601String(),
      'sync_status': syncStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert to [SharedLink] entity
  SharedLink toEntity() {
    return SharedLink(
      id: id,
      tripId: tripId,
      userId: userId,
      slug: slug,
      hasPassword: hasPassword,
      isActive: isActive,
      expiresAt: expiresAt,
      viewCount: viewCount,
      lastViewedAt: lastViewedAt,
      syncStatus: _parseSyncStatus(syncStatus),
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Convert [SharedLink] entity to [SharedLinkModel]
  static SharedLinkModel fromEntity(SharedLink link) {
    return SharedLinkModel(
      id: link.id,
      tripId: link.tripId,
      userId: link.userId,
      slug: link.slug,
      hasPassword: link.hasPassword,
      isActive: link.isActive,
      expiresAt: link.expiresAt,
      viewCount: link.viewCount,
      lastViewedAt: link.lastViewedAt,
      syncStatus: link.syncStatus.name,
      createdAt: link.createdAt,
      updatedAt: link.updatedAt,
    );
  }

  /// Parse sync status string to enum
  SyncStatus _parseSyncStatus(String status) {
    switch (status) {
      case 'synced':
        return SyncStatus.synced;
      case 'pending':
        return SyncStatus.pending;
      case 'conflict':
        return SyncStatus.conflict;
      case 'offline_only':
        return SyncStatus.offlineOnly;
      default:
        return SyncStatus.synced;
    }
  }

  /// Convert entity to map for database operations
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'trip_id': tripId,
      'user_id': userId,
      'slug': slug,
      'has_password': hasPassword ? 1 : 0,
      'is_active': isActive ? 1 : 0,
      'expires_at': expiresAt?.toIso8601String(),
      'view_count': viewCount,
      'last_viewed_at': lastViewedAt?.toIso8601String(),
      'sync_status': syncStatus,
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Convert database map to [SharedLinkModel]
  factory SharedLinkModel.fromMap(Map<String, dynamic> map) {
    return SharedLinkModel(
      id: map['id'] as String,
      tripId: map['trip_id'] as String,
      userId: map['user_id'] as String,
      slug: map['slug'] as String,
      hasPassword: (map['has_password'] as int) == 1,
      isActive: (map['is_active'] as int) == 1,
      expiresAt: map['expires_at'] != null
          ? DateTime.parse(map['expires_at'] as String)
          : null,
      viewCount: map['view_count'] as int,
      lastViewedAt: map['last_viewed_at'] != null
          ? DateTime.parse(map['last_viewed_at'] as String)
          : null,
      syncStatus: map['sync_status'] as String? ?? 'synced',
      createdAt: DateTime.parse(map['created_at'] as String),
      updatedAt: DateTime.parse(map['updated_at'] as String),
    );
  }

  /// Create a copy with the given fields replaced
  SharedLinkModel copyWith({
    String? id,
    String? tripId,
    String? userId,
    String? slug,
    bool? hasPassword,
    bool? isActive,
    DateTime? expiresAt,
    int? viewCount,
    DateTime? lastViewedAt,
    String? syncStatus,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return SharedLinkModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      userId: userId ?? this.userId,
      slug: slug ?? this.slug,
      hasPassword: hasPassword ?? this.hasPassword,
      isActive: isActive ?? this.isActive,
      expiresAt: expiresAt ?? this.expiresAt,
      viewCount: viewCount ?? this.viewCount,
      lastViewedAt: lastViewedAt ?? this.lastViewedAt,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
