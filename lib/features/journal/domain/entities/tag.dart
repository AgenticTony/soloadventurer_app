import 'package:equatable/equatable.dart';
import 'package:soloadventurer/features/journal/domain/entities/shared_link.dart';

/// Represents a custom tag for categorizing journal entries
class Tag extends Equatable {
  /// Unique identifier for the tag
  final String id;

  /// User ID who owns this tag
  final String userId;

  /// Name of the tag
  final String name;

  /// Hex color code for display
  final String? color;

  /// Icon name/emoji
  final String? icon;

  /// Number of times this tag has been used
  final int usageCount;

  /// Sync status for offline support
  final SyncStatus syncStatus;

  /// When the tag was created
  final DateTime createdAt;

  const Tag({
    required this.id,
    required this.userId,
    required this.name,
    this.color,
    this.icon,
    this.usageCount = 0,
    this.syncStatus = SyncStatus.synced,
    required this.createdAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        color,
        icon,
        usageCount,
        syncStatus,
        createdAt,
      ];

  /// Creates a copy of this tag with the given fields replaced
  Tag copyWith({
    String? id,
    String? userId,
    String? name,
    String? color,
    String? icon,
    int? usageCount,
    SyncStatus? syncStatus,
    DateTime? createdAt,
  }) {
    return Tag(
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

  /// Whether the tag has a color
  bool get hasColor => color != null && color!.isNotEmpty;

  /// Whether the tag has an icon
  bool get hasIcon => icon != null && icon!.isNotEmpty;

  /// Whether the tag has been used
  bool get isUsed => usageCount > 0;
}
