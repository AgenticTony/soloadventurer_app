import 'package:equatable/equatable.dart';
import 'trip.dart';

/// Represents a journal entry with rich text content
class JournalEntry extends Equatable {
  /// Unique identifier for the entry
  final String id;

  /// User ID who owns this entry
  final String userId;

  /// Trip ID if entry belongs to a trip
  final String? tripId;

  /// Title of the entry
  final String title;

  /// Rich text content (HTML/Markdown)
  final String content;

  /// Mood of the entry (e.g., "happy", "adventurous", "tired")
  final String? mood;

  /// Location name
  final String? locationName;

  /// Latitude coordinate
  final double? latitude;

  /// Longitude coordinate
  final double? longitude;

  /// Location accuracy in meters
  final double? locationAccuracy;

  /// Date of the entry
  final DateTime entryDate;

  /// Weather data (JSON)
  final Map<String, dynamic>? weatherData;

  /// Whether this entry is marked as favorite
  final bool isFavorite;

  /// Sync status for offline support
  final SyncStatus syncStatus;

  /// When the entry was last synced
  final DateTime? lastSyncedAt;

  /// When the entry was created
  final DateTime createdAt;

  /// When the entry was last updated
  final DateTime updatedAt;

  const JournalEntry({
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

  @override
  List<Object?> get props => [
        id,
        userId,
        tripId,
        title,
        content,
        mood,
        locationName,
        latitude,
        longitude,
        locationAccuracy,
        entryDate,
        weatherData,
        isFavorite,
        syncStatus,
        lastSyncedAt,
        createdAt,
        updatedAt,
      ];

  /// Creates a copy of this entry with the given fields replaced
  JournalEntry copyWith({
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
    return JournalEntry(
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

  /// Whether the entry has location data
  bool get hasLocation => latitude != null && longitude != null;

  /// Whether the entry has weather data
  bool get hasWeatherData => weatherData != null && weatherData!.isNotEmpty;
}
