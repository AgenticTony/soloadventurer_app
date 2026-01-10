import '../../domain/models/saved_destination.dart';
import '../../domain/models/destination.dart';
import 'destination_dto.dart';

/// Data Transfer Object for SavedDestination API responses
///
/// Provides explicit mapping between GraphQL API responses and the [SavedDestination]
/// domain model. Handles nested destination objects and enum conversion.
class SavedDestinationDto {
  /// Unique identifier
  final String id;

  /// User ID who saved this destination
  final String userId;

  /// Destination data (nested object)
  final Map<String, dynamic>? destination;

  /// Save type (wishlist or trip)
  final String? saveType;

  /// Trip ID if saved to a trip
  final String? tripId;

  /// User notes for this saved destination
  final String? notes;

  /// Created timestamp
  final String? createdAt;

  /// Updated timestamp
  final String? updatedAt;

  const SavedDestinationDto({
    required this.id,
    required this.userId,
    this.destination,
    this.saveType,
    this.tripId,
    this.notes,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates a [SavedDestinationDto] from JSON data (GraphQL response)
  factory SavedDestinationDto.fromJson(Map<String, dynamic> json) {
    return SavedDestinationDto(
      id: json['id'] as String,
      userId: json['userId'] as String,
      destination: json['destination'] as Map<String, dynamic>?,
      saveType: json['saveType'] as String?,
      tripId: json['tripId'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  /// Converts the DTO to a [SavedDestination] domain model
  ///
  /// Handles null values by providing sensible defaults where appropriate.
  /// Throws [FormatException] if required fields are null.
  SavedDestination toDomain() {
    return SavedDestination(
      id: id,
      userId: userId,
      destination: destination != null
          ? DestinationDto.fromJson(destination!).toDomain()
          : throw const FormatException(
              'Destination data is required for SavedDestination',
            ),
      saveType:
          saveType != null ? _parseSaveType(saveType!) : SaveType.wishlist,
      tripId: tripId,
      notes: notes,
      createdAt:
          createdAt != null ? DateTime.parse(createdAt!) : DateTime.now(),
      updatedAt:
          updatedAt != null ? DateTime.parse(updatedAt!) : DateTime.now(),
    );
  }

  /// Parses save type string to enum
  SaveType _parseSaveType(String value) {
    switch (value.toUpperCase()) {
      case 'WISHLIST':
        return SaveType.wishlist;
      case 'TRIP':
        return SaveType.trip;
      default:
        return SaveType.wishlist;
    }
  }

  /// Converts a domain model to DTO for API requests
  ///
  /// This is used when sending data to the API (e.g., saveDestination mutation).
  /// Extracts the destination ID from the nested destination object.
  Map<String, dynamic> toApiRequest() {
    return {
      'userId': userId,
      'destinationId': destination?['id'] ?? '',
      'saveType': _saveTypeToString(saveType ?? 'WISHLIST'),
      if (tripId != null) 'tripId': tripId,
      if (notes != null) 'notes': notes,
    };
  }

  /// Converts save type enum to API string
  String _saveTypeToString(String saveType) {
    return saveType.toUpperCase();
  }

  /// Converts a list of JSON objects to a list of [SavedDestinationDto]s
  static List<SavedDestinationDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) =>
            SavedDestinationDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Converts a list of [SavedDestinationDto]s to domain models
  static List<SavedDestination> toDomainList(List<SavedDestinationDto> dtos) {
    return dtos.map((dto) => dto.toDomain()).toList();
  }

  /// Creates a DTO from a [SavedDestination] domain model
  ///
  /// Useful for preparing domain models for API requests.
  static SavedDestinationDto fromDomain(SavedDestination saved) {
    return SavedDestinationDto(
      id: saved.id,
      userId: saved.userId,
      destination: _destinationToMap(saved.destination),
      saveType: _saveTypeFromEnum(saved.saveType),
      tripId: saved.tripId,
      notes: saved.notes,
      createdAt: saved.createdAt.toIso8601String(),
      updatedAt: saved.updatedAt.toIso8601String(),
    );
  }

  /// Converts destination domain model to map for API
  static Map<String, dynamic> _destinationToMap(Destination destination) {
    return {
      'id': destination.id,
    };
  }

  /// Converts save type enum to string
  static String _saveTypeFromEnum(SaveType saveType) {
    switch (saveType) {
      case SaveType.wishlist:
        return 'WISHLIST';
      case SaveType.trip:
        return 'TRIP';
    }
  }
}
