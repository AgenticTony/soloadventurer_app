import '../../domain/models/destination.dart';

/// Data Transfer Object for Destination API responses
///
/// Provides explicit mapping between GraphQL API responses and the [Destination]
/// domain model. Handles null safety and data transformation.
class DestinationDto {
  /// Unique identifier
  final String id;

  /// Destination name
  final String name;

  /// Detailed description
  final String? description;

  /// Location latitude
  final double? latitude;

  /// Location longitude
  final double? longitude;

  /// Country code (e.g., "JP", "US")
  final String? countryCode;

  /// Region/state/province
  final String? region;

  /// Overall safety score (1-10)
  final double? safetyScore;

  /// Detailed safety insights
  final List<Map<String, dynamic>>? safetyInsights;

  /// Solo suitability score (1-10)
  final double? soloSuitabilityScore;

  /// Individual solo suitability factors
  final Map<String, dynamic>? soloSuitabilityFactors;

  /// Budget level
  final String? budgetLevel;

  /// Activity level options available
  final List<String>? activityLevels;

  /// Tags/categories (e.g., ["beach", "mountain", "urban"])
  final List<String>? tags;

  /// Image URLs for the destination
  final List<String>? images;

  /// Cover/featured image
  final String? coverImageUrl;

  /// Popular activities at the destination
  final List<Map<String, dynamic>>? popularActivities;

  /// Best time to visit (e.g., "March to May", "Year-round")
  final String? bestTimeToVisit;

  /// Average daily cost estimate (in USD)
  final int? averageDailyCost;

  /// Currency code
  final String? currencyCode;

  /// Language spoken
  final String? language;

  /// Timezone
  final String? timezone;

  /// Whether this is a curated "hidden gem"
  final bool? isHiddenGem;

  /// Popularity score (0-1)
  final double? popularityScore;

  /// Created timestamp
  final String? createdAt;

  /// Updated timestamp
  final String? updatedAt;

  const DestinationDto({
    required this.id,
    required this.name,
    this.description,
    this.latitude,
    this.longitude,
    this.countryCode,
    this.region,
    this.safetyScore,
    this.safetyInsights,
    this.soloSuitabilityScore,
    this.soloSuitabilityFactors,
    this.budgetLevel,
    this.activityLevels,
    this.tags,
    this.images,
    this.coverImageUrl,
    this.popularActivities,
    this.bestTimeToVisit,
    this.averageDailyCost,
    this.currencyCode,
    this.language,
    this.timezone,
    this.isHiddenGem,
    this.popularityScore,
    this.createdAt,
    this.updatedAt,
  });

  /// Creates a [DestinationDto] from JSON data (GraphQL response)
  ///
  /// The JSON structure typically comes from a GraphQL API response. This method
  /// handles type casting and null safety for all fields.
  ///
  /// Example JSON structure:
  /// ```json
  /// {
  ///   "id": "123",
  ///   "name": "Tokyo",
  ///   "description": "A vibrant city...",
  ///   "latitude": 35.6762,
  ///   "longitude": 139.6503,
  ///   "countryCode": "JP",
  ///   "safetyScore": 8.5,
  ///   "budgetLevel": "expensive",
  ///   "tags": ["urban", "cultural", "food"],
  ///   "createdAt": "2024-01-01T00:00:00Z"
  /// }
  /// ```
  factory DestinationDto.fromJson(Map<String, dynamic> json) {
    return DestinationDto(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      countryCode: json['countryCode'] as String?,
      region: json['region'] as String?,
      safetyScore: (json['safetyScore'] as num?)?.toDouble(),
      safetyInsights: (json['safetyInsights'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      soloSuitabilityScore: (json['soloSuitabilityScore'] as num?)?.toDouble(),
      soloSuitabilityFactors:
          json['soloSuitabilityFactors'] as Map<String, dynamic>?,
      budgetLevel: json['budgetLevel'] as String?,
      activityLevels:
          (json['activityLevels'] as List?)?.map((e) => e as String).toList(),
      tags: (json['tags'] as List?)?.map((e) => e as String).toList(),
      images: (json['images'] as List?)?.map((e) => e as String).toList(),
      coverImageUrl: json['coverImageUrl'] as String?,
      popularActivities: (json['popularActivities'] as List?)
          ?.map((e) => e as Map<String, dynamic>)
          .toList(),
      bestTimeToVisit: json['bestTimeToVisit'] as String?,
      averageDailyCost: json['averageDailyCost'] as int?,
      currencyCode: json['currencyCode'] as String?,
      language: json['language'] as String?,
      timezone: json['timezone'] as String?,
      isHiddenGem: json['isHiddenGem'] as bool?,
      popularityScore: (json['popularityScore'] as num?)?.toDouble(),
      createdAt: json['createdAt'] as String?,
      updatedAt: json['updatedAt'] as String?,
    );
  }

  /// Converts the DTO to a [Destination] domain model
  ///
  /// This method transforms the API response DTO into a domain model with:
  /// - Null safety handling and sensible defaults
  /// - String to enum conversions for budget/activity levels
  /// - JSON parsing for nested objects
  /// - DateTime parsing for timestamp fields
  ///
  /// **Default values for null fields:**
  /// - `description`: empty string
  /// - `latitude/longitude`: 0.0
  /// - `safetyScore/soloSuitabilityScore`: 5.0
  /// - `budgetLevel`: BudgetLevel.moderate
  /// - `activityLevels`: [ActivityLevel.moderate]
  /// - `tags/images`: empty list
  /// - `isHiddenGem`: false
  /// - `popularityScore`: 0.5
  /// - `createdAt/updatedAt`: DateTime.now()
  ///
  /// Example:
  /// ```dart
  /// final dto = DestinationDto.fromJson(apiResponse);
  /// final destination = dto.toDomain();
  /// print(destination.name); // "Tokyo"
  /// print(destination.safetyScore); // 8.5 (or 5.0 if null)
  /// ```
  Destination toDomain() {
    return Destination(
      id: id,
      name: name,
      description: description ?? '',
      latitude: latitude ?? 0.0,
      longitude: longitude ?? 0.0,
      countryCode: countryCode ?? '',
      region: region,
      safetyScore: safetyScore ?? 5.0,
      safetyInsights: safetyInsights
              ?.map((json) => SafetyInsight.fromJson(json))
              .toList() ??
          [],
      soloSuitabilityScore: soloSuitabilityScore ?? 5.0,
      soloSuitabilityFactors: soloSuitabilityFactors != null
          ? SoloSuitabilityFactors.fromJson(soloSuitabilityFactors!)
          : const SoloSuitabilityFactors(
              safety: 5.0,
              nightlife: 5.0,
              walkability: 5.0,
              accommodation: 5.0,
              soloDining: 5.0,
              communication: 5.0,
              overall: 5.0,
            ),
      budgetLevel: budgetLevel != null
          ? _parseBudgetLevel(budgetLevel!)
          : BudgetLevel.moderate,
      activityLevels: activityLevels != null
          ? activityLevels!.map(_parseActivityLevel).toList()
          : [ActivityLevel.moderate],
      tags: tags ?? [],
      images: images ?? [],
      coverImageUrl: coverImageUrl,
      popularActivities:
          popularActivities?.map((json) => Activity.fromJson(json)).toList() ??
              [],
      bestTimeToVisit: bestTimeToVisit,
      averageDailyCost: averageDailyCost,
      currencyCode: currencyCode,
      language: language,
      timezone: timezone,
      isHiddenGem: isHiddenGem ?? false,
      popularityScore: popularityScore ?? 0.5,
      createdAt:
          createdAt != null ? DateTime.parse(createdAt!) : DateTime.now(),
      updatedAt:
          updatedAt != null ? DateTime.parse(updatedAt!) : DateTime.now(),
    );
  }

  /// Parses budget level string to enum
  ///
  /// Performs case-insensitive parsing of budget level strings.
  /// Returns [BudgetLevel.moderate] for unknown values (default fallback).
  ///
  /// Valid values: "budget", "moderate", "expensive"
  BudgetLevel _parseBudgetLevel(String value) {
    switch (value.toLowerCase()) {
      case 'budget':
        return BudgetLevel.budget;
      case 'moderate':
        return BudgetLevel.moderate;
      case 'expensive':
        return BudgetLevel.expensive;
      default:
        return BudgetLevel.moderate;
    }
  }

  /// Parses activity level string to enum
  ///
  /// Performs case-insensitive parsing of activity level strings.
  /// Returns [ActivityLevel.moderate] for unknown values (default fallback).
  ///
  /// Valid values: "relaxed", "moderate", "adventurous"
  ActivityLevel _parseActivityLevel(String value) {
    switch (value.toLowerCase()) {
      case 'relaxed':
        return ActivityLevel.relaxed;
      case 'moderate':
        return ActivityLevel.moderate;
      case 'adventurous':
        return ActivityLevel.adventurous;
      default:
        return ActivityLevel.moderate;
    }
  }

  /// Converts a list of JSON objects to a list of [DestinationDto]s
  ///
  /// Useful for parsing GraphQL list responses.
  ///
  /// Example:
  /// ```dart
  /// final jsonList = jsonResponse['searchDestinations'] as List;
  /// final dtos = DestinationDto.fromJsonList(jsonList);
  /// print(dtos.length); // Number of destinations
  /// ```
  static List<DestinationDto> fromJsonList(List<dynamic> jsonList) {
    return jsonList
        .map((json) => DestinationDto.fromJson(json as Map<String, dynamic>))
        .toList();
  }

  /// Converts a list of [DestinationDto]s to domain models
  ///
  /// Convenience method for bulk conversion of DTOs to domain models.
  ///
  /// Example:
  /// ```dart
  /// final dtos = DestinationDto.fromJsonList(jsonResponse);
  /// final destinations = DestinationDto.toDomainList(dtos);
  /// // destinations is now List<Destination>
  /// ```
  static List<Destination> toDomainList(List<DestinationDto> dtos) {
    return dtos.map((dto) => dto.toDomain()).toList();
  }
}
