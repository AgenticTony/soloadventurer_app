import 'package:equatable/equatable.dart';

/// Represents a trip that organizes journal entries
class Trip extends Equatable {
  /// Unique identifier for the trip
  final String id;

  /// User ID who owns this trip
  final String userId;

  /// Name of the trip
  final String name;

  /// Description of the trip
  final String? description;

  /// Cover image URL
  final String? coverImageUrl;

  /// Start date of the trip
  final DateTime startDate;

  /// End date of the trip (null if ongoing)
  final DateTime? endDate;

  /// Destination location
  final String? destination;

  /// Whether the trip is publicly visible
  final bool isPublic;

  /// Sync status for offline support
  final SyncStatus syncStatus;

  /// When the trip was last synced
  final DateTime? lastSyncedAt;

  /// When the trip was created
  final DateTime createdAt;

  /// When the trip was last updated
  final DateTime updatedAt;

  const Trip({
    required this.id,
    required this.userId,
    required this.name,
    this.description,
    this.coverImageUrl,
    required this.startDate,
    this.endDate,
    this.destination,
    this.isPublic = false,
    this.syncStatus = SyncStatus.synced,
    this.lastSyncedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        name,
        description,
        coverImageUrl,
        startDate,
        endDate,
        destination,
        isPublic,
        syncStatus,
        lastSyncedAt,
        createdAt,
        updatedAt,
      ];

  /// Creates a copy of this trip with the given fields replaced
  Trip copyWith({
    String? id,
    String? userId,
    String? name,
    String? description,
    String? coverImageUrl,
    DateTime? startDate,
    DateTime? endDate,
    String? destination,
    bool? isPublic,
    SyncStatus? syncStatus,
    DateTime? lastSyncedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Trip(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      name: name ?? this.name,
      description: description ?? this.description,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      destination: destination ?? this.destination,
      isPublic: isPublic ?? this.isPublic,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  /// Whether the trip is currently ongoing
  bool get isOngoing => endDate == null || DateTime.now().isBefore(endDate!);

  /// Duration of the trip
  Duration get duration {
    if (endDate == null) {
      return DateTime.now().difference(startDate);
    }
    return endDate!.difference(startDate);
  }
}

/// Sync status for offline support
enum SyncStatus {
  /// Entity is synced with server
  synced,

  /// Entity has pending changes to sync
  pending,

  /// Entity has a conflict that needs resolution
  conflict,

  /// Entity only exists offline
  offlineOnly,
}

/// Extension to convert SyncStatus to/from string
extension SyncStatusExtension on SyncStatus {
  String get value {
    switch (this) {
      case SyncStatus.synced:
        return 'synced';
      case SyncStatus.pending:
        return 'pending';
      case SyncStatus.conflict:
        return 'conflict';
      case SyncStatus.offlineOnly:
        return 'offline_only';
    }
  }

  static SyncStatus fromString(String value) {
    switch (value) {
      case 'synced':
        return SyncStatus.synced;
      case 'pending':
        return SyncStatus.pending;
      case 'conflict':
        return SyncStatus.conflict;
      case 'offline_only':
        return SyncStatus.offlineOnly;
      default:
        throw ArgumentError('Invalid SyncStatus value: $value');
    }
  }
}
