import 'package:soloadventurer/features/journal/domain/entities/journal_entry.dart';

/// Data layer representation of [JournalEntry] entity
class JournalEntryModel {
  final String id;
  final String userId;
  final String? tripId;
  final String title;
  final String content;
  final String? mood;
  final String? locationName;
  final double? latitude;
  final double? longitude;
  final double? locationAccuracy;
  final DateTime entryDate;
  final Map<String, dynamic>? weatherData;
  final bool isFavorite;
  final SyncStatus syncStatus;
  final DateTime? lastSyncedAt;
  final DateTime createdAt;
  final DateTime updatedAt;

  const JournalEntryModel({
    required this.id,
    required this.userId,
    this.tripId,
    required this.title,
    required this.content,
    this.mood,
    this.locationName,
    this.latitude,
    this.longitude,
    this.locationAccuracy,
    required this.entryDate,
    this.weatherData,
    this.isFavorite = false,
    this.syncStatus = SyncStatus.synced,
    this.lastSyncedAt,
    required this.createdAt,
    required this.updatedAt,
  });

  /// Creates a [JournalEntryModel] from a domain [JournalEntry] entity
  factory JournalEntryModel.fromEntity(JournalEntry entry) {
    return JournalEntryModel(
      id: entry.id,
      userId: entry.userId,
      tripId: entry.tripId,
      title: entry.title,
      content: entry.content,
      mood: entry.mood,
      locationName: entry.locationName,
      latitude: entry.latitude,
      longitude: entry.longitude,
      locationAccuracy: entry.locationAccuracy,
      entryDate: entry.entryDate,
      weatherData: entry.weatherData,
      isFavorite: entry.isFavorite,
      syncStatus: entry.syncStatus,
      lastSyncedAt: entry.lastSyncedAt,
      createdAt: entry.createdAt,
      updatedAt: entry.updatedAt,
    );
  }

  /// Converts this [JournalEntryModel] to a domain [JournalEntry] entity
  JournalEntry toEntity() {
    return JournalEntry(
      id: id,
      userId: userId,
      tripId: tripId,
      title: title,
      content: content,
      mood: mood,
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
      locationAccuracy: locationAccuracy,
      entryDate: entryDate,
      weatherData: weatherData,
      isFavorite: isFavorite,
      syncStatus: syncStatus,
      lastSyncedAt: lastSyncedAt,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Creates a [JournalEntryModel] from JSON map (Supabase format)
  factory JournalEntryModel.fromJson(Map<String, dynamic> json) {
    return JournalEntryModel(
      id: json['id'] as String,
      userId: json['user_id'] as String,
      tripId: json['trip_id'] as String?,
      title: json['title'] as String,
      content: json['content'] as String,
      mood: json['mood'] as String?,
      locationName: json['location_name'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      locationAccuracy: (json['location_accuracy'] as num?)?.toDouble(),
      entryDate: DateTime.parse(json['entry_date'] as String),
      weatherData: json['weather_data'] as Map<String, dynamic>?,
      isFavorite: json['is_favorite'] as bool? ?? false,
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

  /// Converts this [JournalEntryModel] to JSON map (Supabase format)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'trip_id': tripId,
      'title': title,
      'content': content,
      'mood': mood,
      'location_name': locationName,
      'latitude': latitude,
      'longitude': longitude,
      'location_accuracy': locationAccuracy,
      'entry_date': entryDate.toIso8601String(),
      'weather_data': weatherData,
      'is_favorite': isFavorite,
      'sync_status': syncStatus.value,
      'last_synced_at': lastSyncedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
      'updated_at': updatedAt.toIso8601String(),
    };
  }

  /// Creates a copy of this JournalEntryModel with the given fields replaced
  JournalEntryModel copyWith({
    String? id,
    String? userId,
    String? tripId,
    String? title,
    String? content,
    String? mood,
    String? locationName,
    double? latitude,
    double? longitude,
    double? locationAccuracy,
    DateTime? entryDate,
    Map<String, dynamic>? weatherData,
    bool? isFavorite,
    SyncStatus? syncStatus,
    DateTime? lastSyncedAt,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return JournalEntryModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      tripId: tripId ?? this.tripId,
      title: title ?? this.title,
      content: content ?? this.content,
      mood: mood ?? this.mood,
      locationName: locationName ?? this.locationName,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      locationAccuracy: locationAccuracy ?? this.locationAccuracy,
      entryDate: entryDate ?? this.entryDate,
      weatherData: weatherData ?? this.weatherData,
      isFavorite: isFavorite ?? this.isFavorite,
      syncStatus: syncStatus ?? this.syncStatus,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}
