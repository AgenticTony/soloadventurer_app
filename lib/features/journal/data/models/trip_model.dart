import 'package:soloadventurer/features/journal/domain/entities/trip.dart';

/// Data layer representation of [Trip] entity
class TripModel {
  final String id;
  final String userId;
  final String name;
  final String? description;
  final String? coverImageUrl;
  final DateTime startDate;
  final DateTime? endDate;
  final String? destination;
  final bool isPublic;
  final SyncStatus syncStatus;
  final DateTime? lastSyncedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const TripModel({
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

  /// Creates a [TripModel] from a domain [Trip] entity
  factory TripModel.fromEntity(Trip trip) {
    return TripModel(
      id: trip.id,
      userId: trip.userId,
      name: trip.name,
      description: trip.description,
      coverImageUrl: trip.coverImageUrl,
      startDate: trip.startDate,
      endDate: trip.endDate,
      destination: trip.destination,
      isPublic: trip.isPublic,
      syncStatus: trip.syncStatus,
      lastSyncedAt: trip.lastSyncedAt,
      createdAt: trip.createdAt,
      updatedAt: trip.updatedAt,
    );
  }

  /// Converts this [TripModel] to a domain [Trip] entity
  Trip toEntity() {
    return Trip(
      id: id,
      userId: userId,
      name: name,
      description: description,
      coverImageUrl: coverImageUrl,
      startDate: startDate,
      endDate: endDate,
      destination: destination,
      isPublic: isPublic,
      syncStatus: syncStatus,
      lastSyncedAt: lastSyncedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Creates a [TripModel] from JSON map (Supabase format)
  factory TripModel.fromJson(Map<String, dynamic> json) {
    return TripModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      coverImageUrl: json['cover_image_url'] as String?,
      startDate: DateTime.parse(json['start_date'] as String),
      endDate: json['end_date'] != null
          ? DateTime.parse(json['end_date'] as String)
          : null,
      destination: json['destination'] as String?,
      isPublic: json['is_public'] as bool? ?? false,
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

  /// Converts this [TripModel] to JSON map (Supabase format)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'name': name,
      'description': description,
      'cover_image_url': coverImageUrl,
      'start_date': startDate.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'destination': destination,
      'is_public': isPublic,
      'sync_status': syncStatus.value,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates a copy of this TripModel with the given fields replaced
  TripModel copyWith({
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
    return TripModel(
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
}
