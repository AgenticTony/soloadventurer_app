import 'dart:convert';
import 'package:soloadventurer/features/offline/infrastructure/database/database.dart';
import 'package:soloadventurer/features/travel/domain/models/trip.dart';

/// Local data model for Trip that represents the database entity
///
/// This model wraps the [LocalTrip] database class with additional functionality
/// for JSON serialization, entity conversion, and sync tracking.
class LocalTripModel {
  static const int maxTitleLength = 100;
  static const int maxDescriptionLength = 1000;
  static const int maxDestinationLength = 100;

  final String id;
  final String userId;
  final String title;
  final String? description;
  final DateTime startDate;
  final DateTime endDate;
  final String destination;
  final double? latitude;
  final double? longitude;
  final String status;
  final int budget;
  final String? coverImageUrl;
  final List<String>? travelCompanionIds;
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

  const LocalTripModel({
    required this.id,
    required this.userId,
    required this.title,
    this.description,
    required this.startDate,
    required this.endDate,
    required this.destination,
    this.latitude,
    this.longitude,
    required this.status,
    required this.budget,
    this.coverImageUrl,
    this.travelCompanionIds,
    required this.createdAt,
    required this.updatedAt,
    this.isSynced = false,
    this.hasPendingChanges = false,
    this.version = 1,
    this.isDeleted = false,
    this.lastSyncedAt,
  });

  /// Creates a [LocalTripModel] from a [LocalTrip] database entity
  factory LocalTripModel.fromDatabase(LocalTrip localTrip) {
    return LocalTripModel(
      id: localTrip.id,
      userId: localTrip.userId,
      title: localTrip.title,
      description: localTrip.description,
      startDate: localTrip.startDate,
      endDate: localTrip.endDate,
      destination: localTrip.destination,
      latitude: localTrip.latitude,
      longitude: localTrip.longitude,
      status: localTrip.status,
      budget: localTrip.budget,
      coverImageUrl: localTrip.coverImageUrl,
      travelCompanionIds: localTrip.travelCompanionIds != null
          ? List<String>.from(jsonDecode(localTrip.travelCompanionIds!))
          : null,
      createdAt: localTrip.createdAt,
      updatedAt: localTrip.updatedAt,
      isSynced: localTrip.isSynced,
      hasPendingChanges: localTrip.hasPendingChanges,
      version: localTrip.version,
      isDeleted: localTrip.isDeleted,
      lastSyncedAt: localTrip.lastSyncedAt,
    );
  }

  /// Converts this [LocalTripModel] to a [Trip] domain entity
  ///
  /// Note: Sync fields are not included in the domain entity
  /// as they are infrastructure concerns.
  Trip toDomainEntity() {
    return Trip(
      id: id,
      userId: userId,
      title: title,
      description: description,
      startDate: startDate,
      endDate: endDate,
      destination: destination,
      latitude: latitude,
      longitude: longitude,
      status: status,
      budget: budget,
      coverImageUrl: coverImageUrl,
      travelCompanionIds: travelCompanionIds,
      createdAt: createdAt,
      updatedAt: updatedAt,
    );
  }

  /// Creates a [LocalTripModel] from a [Trip] domain entity
  ///
  /// Use this when creating a new local record from server data
  factory LocalTripModel.fromDomainEntity(Trip trip) {
    return LocalTripModel(
      id: trip.id,
      userId: trip.userId,
      title: trip.title,
      description: trip.description,
      startDate: trip.startDate,
      endDate: trip.endDate,
      destination: trip.destination,
      latitude: trip.latitude,
      longitude: trip.longitude,
      status: trip.status,
      budget: trip.budget,
      coverImageUrl: trip.coverImageUrl,
      travelCompanionIds: trip.travelCompanionIds,
      createdAt: trip.createdAt,
      updatedAt: trip.updatedAt,
      isSynced: true, // Server data is already synced
      hasPendingChanges: false,
      version: 1,
      isDeleted: false,
      lastSyncedAt: DateTime.now(),
    );
  }

  /// Creates a [LocalTripModel] from JSON map
  ///
  /// Expected format matches the Trip domain entity JSON structure
  factory LocalTripModel.fromJson(Map<String, dynamic> json) {
    final title = json['title'] as String;
    final description = json['description'] as String?;
    final destination = json['destination'] as String;

    // Validate fields
    _validateTitle(title);
    if (description != null) _validateDescription(description);
    _validateDestination(destination);

    return LocalTripModel(
      id: json['id'] as String,
      userId: json['userId'] as String,
      title: title,
      description: description,
      startDate: DateTime.parse(json['startDate'] as String),
      endDate: DateTime.parse(json['endDate'] as String),
      destination: destination,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      status: json['status'] as String,
      budget: json['budget'] as int,
      coverImageUrl: json['coverImageUrl'] as String?,
      travelCompanionIds:
          (json['travelCompanionIds'] as List<dynamic>?)?.cast<String>(),
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

  /// Converts this [LocalTripModel] to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'startDate': startDate.toIso8601String(),
      'endDate': endDate.toIso8601String(),
      'destination': destination,
      'latitude': latitude,
      'longitude': longitude,
      'status': status,
      'budget': budget,
      'coverImageUrl': coverImageUrl,
      'travelCompanionIds': travelCompanionIds,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'isSynced': isSynced,
      'hasPendingChanges': hasPendingChanges,
      'version': version,
      'isDeleted': isDeleted,
      'lastSyncedAt': lastSyncedAt?.toIso8601String(),
    };
  }

  /// Creates a copy of this LocalTripModel with the given fields replaced
  LocalTripModel copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    DateTime? startDate,
    DateTime? endDate,
    String? destination,
    double? latitude,
    double? longitude,
    String? status,
    int? budget,
    String? coverImageUrl,
    List<String>? travelCompanionIds,
    DateTime? createdAt,
    DateTime? updatedAt,
    bool? isSynced,
    bool? hasPendingChanges,
    int? version,
    bool? isDeleted,
    DateTime? lastSyncedAt,
  }) {
    return LocalTripModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      destination: destination ?? this.destination,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      status: status ?? this.status,
      budget: budget ?? this.budget,
      coverImageUrl: coverImageUrl ?? this.coverImageUrl,
      travelCompanionIds: travelCompanionIds ?? this.travelCompanionIds,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      isSynced: isSynced ?? this.isSynced,
      hasPendingChanges: hasPendingChanges ?? this.hasPendingChanges,
      version: version ?? this.version,
      isDeleted: isDeleted ?? this.isDeleted,
      lastSyncedAt: lastSyncedAt ?? this.lastSyncedAt,
    );
  }

  /// Validates all fields of the trip
  void validate() {
    _validateTitle(title);
    if (description != null) _validateDescription(description!);
    _validateDestination(destination);
  }

  static void _validateTitle(String title) {
    if (title.isEmpty) {
      throw ArgumentError('Title cannot be empty');
    }
    if (title.length > maxTitleLength) {
      throw ArgumentError(
        'Title cannot exceed $maxTitleLength characters',
      );
    }
  }

  static void _validateDescription(String description) {
    if (description.length > maxDescriptionLength) {
      throw ArgumentError(
        'Description cannot exceed $maxDescriptionLength characters',
      );
    }
  }

  static void _validateDestination(String destination) {
    if (destination.isEmpty) {
      throw ArgumentError('Destination cannot be empty');
    }
    if (destination.length > maxDestinationLength) {
      throw ArgumentError(
        'Destination cannot exceed $maxDestinationLength characters',
      );
    }
  }

  /// Returns true if this trip needs to be synced with the server
  bool get needsSync => !isSynced || hasPendingChanges || isDeleted;

  /// Returns true if this trip is currently being synced
  bool get isSyncing => hasPendingChanges && !isSynced;

  // ==============================================================================
  // DATABASE CONVERSION HELPERS
  // ==============================================================================

  /// Converts this model to a JSON string suitable for database storage
  ///
  /// List fields are encoded as JSON strings since the database stores them
  /// in TextColumn fields.
  String? travelCompanionIdsToJson() {
    if (travelCompanionIds == null) return null;
    return jsonEncode(travelCompanionIds);
  }
}
