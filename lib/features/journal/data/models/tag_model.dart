import 'package:soloadventurer/features/journal/domain/entities/tag.dart';
import 'package:soloadventurer/features/journal/domain/entities/shared_link.dart';

/// Data layer representation of [Tag] entity
class TagModel {
  final String id;
  final String userId;
  final String name;
  final String? color;
  final String? icon;
  final int usageCount;
  final SyncStatus syncStatus;
  final DateTime createdAt;

  const TagModel({
    required this.id,
    required this.userId,
    required this.name,
    this.color,
    this.icon,
    this.usageCount = 0,
    this.syncStatus = SyncStatus.synced,
    required this.createdAt,
  });

  /// Creates a [TagModel] from a domain [Tag] entity
  factory TagModel.fromEntity(Tag tag) {
    return TagModel(
      id: tag.id,
      userId: tag.userId,
      name: tag.name,
      color: tag.color,
      icon: tag.icon,
      usageCount: tag.usageCount,
      syncStatus: tag.syncStatus,
      createdAt: tag.createdAt,
    );
  }

  /// Converts this [TagModel] to a domain [Tag] entity
  Tag toEntity() {
    return Tag(
      id: id,
      userId: userId,
      name: name,
      color: color,
      icon: icon,
      usageCount: usageCount,
      syncStatus: syncStatus,
      createdAt: createdAt,
    );
  }

  /// Creates a [TagModel] from JSON map (Supabase format)
  factory TagModel.fromJson(Map<String, dynamic> json) {
    return TagModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      color: json['color'] as String?,
      icon: json['icon'] as String?,
      usageCount: json['usage_count'] as int? ?? 0,
      syncStatus: json['sync_status'] != null
          ? SyncStatusExtension.fromString(json['sync_status'] as String)
          : SyncStatus.synced,
      createdAt: DateTime.parse(json['created_at'] as String),
    );
  }

  /// Converts this [TagModel] to JSON map (Supabase format)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'color': color,
      'icon': icon,
      'usage_count': usageCount,
      'sync_status': syncStatus.value,
      'created_at': createdAt.toIso8601String(),
    };
  }

  /// Creates a copy of this TagModel with the given fields replaced
  TagModel copyWith({
    String? id,
    String? userId,
    String? name,
    String? color,
    String? icon,
    int? usageCount,
    SyncStatus? syncStatus,
    DateTime? createdAt,
  }) {
    return TagModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      color: color ?? this.color,
      icon: icon ?? this.icon,
      usageCount: usageCount ?? this.usageCount,
      syncStatus: syncStatus ?? this.syncStatus,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
