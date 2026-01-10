import '../../domain/models/curated_list.dart';
import 'destination_dto.dart';

/// Data Transfer Object for CuratedList API responses
///
/// Provides explicit mapping between GraphQL API responses and the [CuratedList]
/// domain model. Handles nested destination lists and enum conversion.
class CuratedListDto {
  /// Unique identifier
  final String id;

  /// List name
  final String name;

  /// List description
  final String? description;

  /// Type of curated list
  final String? type;

  /// Destinations in this list
  final List<Map<String, dynamic>>? destinations;

  /// Cover image URL
  final String? coverImageUrl;

  /// Additional images
  final List<String>? images;

  /// Curator/author name
  final String? curatorName;

  /// Curator/author image URL
  final String? curatorImageUrl;

  /// Number of destinations in the list
  final int? destinationCount;

  /// Whether this list is featured
  final bool? isFeatured;

  /// Display order for sorting
  final int? displayOrder;

  /// Tags for the list
  final List<String>? tags;

  /// Average safety score across destinations
  final double? averageSafetyScore;

  /// Average solo suitability score
  final double? averageSoloSuitabilityScore;

  /// Budget range (e.g., "budget-friendly", "luxury")
  final String? budgetRange;

  /// Best time to visit for destinations in this list
  final String? bestTimeToVisit;

  /// Recommended duration
  final String? recommendedDuration;

  /// View count
  final int? viewCount;

  /// Save count
  final int? saveCount;

  /// Created timestamp
  final String? createdAt;

  /// Updated timestamp
  final String? updatedAt;

  /// Published timestamp
  final String? publishedAt;

  /// Whether the list is published
  final bool? isPublished;

  const CuratedListDto({
    required this.id,
    required this.name,
    this.description,
    this.type,
    this.destinations,
    this.coverImageUrl,
    this.images,
    this.curatorName,
    this.curatorImageUrl,
    this.destinationCount,
    this.isFeatured,
    this.displayOrder,
    this.tags,
    this.averageSafetyScore,
    this.averageSoloSuitabilityScore,
    this.budgetRange,
    this.bestTimeToVisit,
    this.recommendedDuration,
    this.viewCount,
    this.saveCount,
    this.createdAt,
    this.updatedAt,
    this.publishedAt,
    this.isPublished,
  });

  /// Creates a [CuratedListDto] from JSON data (GraphQL response)
  factory CuratedListDto.fromJson(Map<String, dynamic> json) {
    return CuratedListDto(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      type: json['type'] as String?,
      destinations: (json['destinations'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      coverImageUrl: json['coverImageUrl'] as String?,
      images: (json['images'] as List?)?.map((e) => e as String).toList(),
      curatorName: json['curatorName'] as String?,
      curatorImageUrl: json['curatorImageUrl'] as String?,
      destinationCount: json['destinationCount'] as int?,
      isFeatured: json['isFeatured'] as bool?,
      displayOrder: json['displayOrder'] as int?,
      tags: (json['tags'] as List?)?.map((e) => e as String).toList(),
      averageSafetyScore: (json['averageSafetyScore'] as num?)?.toDouble(),
      averageSoloSuitabilityScore:
          (json['averageSoloSuitabilityScore'] as num?)?.toDouble(),
      budgetRange: json['budgetRange'] as String?,
      bestTimeToVisit: json['bestTimeToVisit'] as String?,
      recommendedDuration: json['recommendedDuration'] as String?,
      viewCount: json['viewCount'] as int?,
      saveCount: json['saveCount'] as int?,
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
      publishedAt: json['publishedAt'] as String?,
      isPublished: json['isPublished'] as bool?,
    );
  }

  /// Converts the DTO to a [CuratedList] domain model
  ///
  /// Handles null values by providing sensible defaults where appropriate.
  CuratedList toDomain() {
    return CuratedList(
      id: id,
      name: name,
      description: description ?? '',
      type:
          type != null ? _parseCuratedListType(type!) : CuratedListType.custom,
      destinations: destinations != null
          ? DestinationDto.fromJsonList(destinations!)
              .map((dto) => dto.toDomain())
              .toList()
          : [],
      coverImageUrl: coverImageUrl,
      images: images ?? [],
      curatorName: curatorName ?? 'SoloAdventurer',
      curatorImageUrl: curatorImageUrl,
      destinationCount: destinationCount ?? destinations?.length ?? 0,
      isFeatured: isFeatured ?? false,
      displayOrder: displayOrder ?? 0,
      tags: tags ?? [],
      averageSafetyScore: averageSafetyScore ?? 0.0,
      averageSoloSuitabilityScore: averageSoloSuitabilityScore ?? 0.0,
      budgetRange: budgetRange,
      bestTimeToVisit: bestTimeToVisit,
      recommendedDuration: recommendedDuration,
      viewCount: viewCount ?? 0,
      saveCount: saveCount ?? 0,
      createdAt:
          createdAt != null ? DateTime.parse(createdAt!) : DateTime.now(),
      updatedAt:
          updatedAt != null ? DateTime.parse(updatedAt!) : DateTime.now(),
      publishedAt: publishedAt != null ? DateTime.parse(publishedAt!) : null,
      isPublished: isPublished ?? false,
    );
  }

  /// Parses curated list type string to enum
  CuratedListType _parseCuratedListType(String value) {
    // Convert string to snake_case for matching
    final normalizedValue = value.toLowerCase().replaceAll('-', '_');

    switch (normalizedValue) {
      case 'popular_solo':
        return CuratedListType.popularSolo;
      case 'hidden_gems':
        return CuratedListType.hiddenGems;
      case 'budget_friendly':
        return CuratedListType.budgetFriendly;
      case 'adventure':
        return CuratedListType.adventure;
      case 'cultural':
        return CuratedListType.cultural;
      case 'beach':
        return CuratedListType.beach;
      case 'urban':
        return CuratedListType.urban;
      case 'nature':
        return CuratedListType.nature;
      case 'food':
        return CuratedListType.food;
      case 'wellness':
        return CuratedListType.wellness;
      case 'seasonal':
        return CuratedListType.seasonal;
      default:
        return CuratedListType.custom;
    }
  }

  /// Converts a list of JSON objects to a list of [CuratedListDto]s
  static List<CuratedListDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => CuratedListDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Converts a list of [CuratedListDto]s to domain models
  static List<CuratedList> toDomainList(List<CuratedListDto> dtos) {
    return dtos.map((dto) => dto.toDomain()).toList();
  }
}
