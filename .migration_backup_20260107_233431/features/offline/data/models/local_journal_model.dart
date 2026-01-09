import 'dart:convert';
import 'package:soloadventurer/features/offline/infrastructure/database/database.dart';

/// Local data model for Journal that represents the database entity
///
/// This model wraps the [LocalJournal] database class with additional functionality
/// for JSON serialization, entity conversion, and sync tracking.
///
/// Note: A domain Journal entity does not exist yet, so this model serves
/// as both the data layer representation and the de facto domain entity.
class LocalJournalModel {
  static const int maxTitleLength = 200;
  static const int maxContentLength = 10000;
  static const int maxMoodLength = 50;
  static const int maxLocationLength = 100;
  static const int maxTagsCount = 20;
  static const int maxImagesCount = 50;

  final String id;
  final String tripId;
  final String userId;
  final String title;
  final String content;
  final DateTime? entryDate;
  final String? mood;
  final String? location;
  final List<String>? imageUrls;
  final List<String>? tags;
  final DateTime createdAt;
  final DateTime updatedAt;

  // ==============================================================================
  // SYNC FIELDS
  // ==============================================================================

  /// Whether this record has been synced with the server
  final bool isSynced;

  /// Whether this record has local modifications pending sync
  final bool hasPendingChanges;

  /// Version number for conflict resolution
  final int version;

  /// Soft delete flag - true if deleted locally pending sync
  final bool isDeleted;

  /// Last successful sync timestamp
  final DateTime? lastSyncedAt;

  const LocalJournalModel({
    required this.id,
    required this.tripId,
    required this.userId,
    required this.title,
    required this.content,
    this.entryDate,
    this.mood,
    this.location,
    this.imageUrls,
    this.tags,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.hasPendingChanges = false,
    this.version = 1,
    this.isDeleted = false,
    this.lastSyncedAt,
  });

  /// Creates a [LocalJournalModel] from a [LocalJournal] database entity
  factory LocalJournalModel.fromDatabase(LocalJournal localJournal) {
    return LocalJournalModel(
      id: localJournal.id,
      tripId: localJournal.tripId,
      userId: localJournal.userId,
      title: localJournal.title,
      content: localJournal.content,
      entryDate: localJournal.entryDate,
      mood: localJournal.mood,
      location: localJournal.location,
      imageUrls: localJournal.imageUrls != null
          ? List<String>.from(localJournal.imageUrls!)
          : null,
      tags: localJournal.tags != null
          ? List<String>.from(localJournal.tags!)
          : null,
      createdAt: localJournal.createdAt,
      updatedAt: localJournal.updatedAt,
      isSynced: localJournal.isSynced,
      hasPendingChanges: localJournal.hasPendingChanges,
      version: localJournal.version,
      isDeleted: localJournal.isDeleted,
      lastSyncedAt: localJournal.lastSyncedAt,
    );
  }

  /// Creates a [LocalJournalModel] from JSON map
  ///
  /// Expected format matches the API response structure
  factory LocalJournalModel.fromJson(Map<String, dynamic> json) {
    final title = json['title'] as String;
    final content = json['content'] as String;
    final mood = json['mood'] as String?;
    final location = json['location'] as String?;

    // Validate fields
    _validateTitle(title);
    _validateContent(content);
    if (mood != null) _validateMood(mood);
    if (location != null) _validateLocation(location);

    return LocalJournalModel(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      userId: json['userId'] as String,
      title: title,
      content: content,
      entryDate: json['entryDate'] != null
          ? DateTime.parse(json['entryDate'] as String)
          : null,
      mood: mood,
      location: location,
      imageUrls: (json['imageUrls'] as List<dynamic>?)?.cast<String>(),
      tags: (json['tags'] as List<dynamic>?)?.cast<String>(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      isSynced: json['isSynced'] as bool? ?? false,
      hasPendingChanges: json['hasPendingChanges'] as bool? ?? false,
      version: json['version'] as int? ?? 1,
      isDeleted: json['isDeleted'] as bool? ?? false,
      lastSyncedAt: json['lastSyncedAt'] != null
          ? DateTime.parse(json['lastSyncedAt'] as String)
          : null,
    );
  }

  /// Converts this [LocalJournalModel] to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'tripId': tripId,
      'userId': userId,
      'title': title,
      'content': content,
      'entryDate': entryDate?.toIso8601String(),
      'mood': mood,
      'location': location,
      'imageUrls': imageUrls,
      'tags': tags,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
      'hasPendingChanges': hasPendingChanges,
      'version': version,
      'isDeleted': isDeleted,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this LocalJournalModel with the given fields replaced
  LocalJournalModel copyWith({
    String? id,
    String? tripId,
    String? userId,
    String? title,
    String? content,
    DateTime? entryDate,
    String? mood,
    String? location,
    List<String>? imageUrls,
    List<String>? tags,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    bool? hasPendingChanges,
    int? version,
    bool? isDeleted,
    DateTime? lastSyncedAt,
  }) {
    return LocalJournalModel(
      id: id ?? this.id,
      tripId: tripId ?? this.tripId,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      content: content ?? this.content,
      entryDate: entryDate ?? this.entryDate,
      mood: mood ?? this.mood,
      location: location ?? this.location,
      imageUrls: imageUrls ?? this.imageUrls,
      tags: tags ?? this.tags,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      hasPendingChanges: hasPendingChanges ?? this.hasPendingChanges,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  /// Validates all fields of the journal
  void validate() {
    _validateTitle(title);
    _validateContent(content);
    if (mood != null) _validateMood(mood!);
    if (location != null) _validateLocation(location!);
    if (tags != null) _validateTags(tags!);
    if (imageUrls != null) _validateImageUrls(imageUrls!);
  }

  static void _validateTitle(String title) {
    if (title.isEmpty) {
      throw ArgumentError('Journal title cannot be empty');
    }
    if (title.length > maxTitleLength) {
      throw ArgumentError(
        'Journal title cannot exceed $maxTitleLength characters',
      );
    }
  }

  static void _validateContent(String content) {
    if (content.isEmpty) {
      throw ArgumentError('Journal content cannot be empty');
    }
    if (content.length > maxContentLength) {
      throw ArgumentError(
        'Journal content cannot exceed $maxContentLength characters',
      );
    }
  }

  static void _validateMood(String mood) {
    if (mood.length > maxMoodLength) {
      throw ArgumentError(
        'Mood cannot exceed $maxMoodLength characters',
      );
    }
  }

  static void _validateLocation(String location) {
    if (location.length > maxLocationLength) {
      throw ArgumentError(
        'Location cannot exceed $maxLocationLength characters',
      );
    }
  }

  static void _validateTags(List<String> tags) {
    if (tags.length > maxTagsCount) {
      throw ArgumentError(
        'Cannot have more than $maxTagsCount tags',
      );
    }
  }

  static void _validateImageUrls(List<String> imageUrls) {
    if (imageUrls.length > maxImagesCount) {
      throw ArgumentError(
        'Cannot have more than $maxImagesCount images',
      );
    }
  }

  /// Returns true if this journal needs to be synced with the server
  bool get needsSync => !isSynced || hasPendingChanges || isDeleted;

  /// Returns true if this journal is currently being synced
  bool get isSyncing => hasPendingChanges && !isSynced;

  // ==============================================================================
  // UTILITY METHODS
  // ==============================================================================

  /// Gets the entry date, defaulting to createdAt if not set
  DateTime get effectiveEntryDate => entryDate ?? createdAt;

  /// Returns a summary of the journal content (first 100 characters)
  String get summary {
    final cleanContent = content.replaceAll('\n', ' ');
    if (cleanContent.length <= 100) return cleanContent;
    return '${cleanContent.substring(0, 100)}...';
  }

  /// Checks if the journal has images
  bool get hasImages => imageUrls != null && imageUrls!.isNotEmpty;

  /// Checks if the journal has tags
  bool get hasTags => tags != null && tags!.isNotEmpty;

  /// Checks if the journal has a location
  bool get hasLocation => location != null && location!.isNotEmpty;

  /// Checks if the journal has a mood
  bool get hasMood => mood != null && mood!.isNotEmpty;
}
