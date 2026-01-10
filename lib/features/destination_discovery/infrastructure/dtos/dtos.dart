/// Data Transfer Objects for Destination Discovery feature
///
/// This library provides DTOs for mapping between GraphQL API responses
/// and domain models. DTOs handle null safety, data transformation, and
/// provide a clear boundary between the infrastructure and domain layers.
///
/// Usage:
/// ```dart
/// import 'package:soloadventurer/features/destination_discovery/infrastructure/dtos/dtos.dart';
///
/// // Parse API response
/// final dto = DestinationDto.fromJson(apiResponse);
/// final destination = dto.toDomain();
///
/// // Convert list of responses
/// final destinations = DestinationDto.toDomainList(
///   DestinationDto.fromJsonList(apiResponseList),
/// );
/// ```
library;

// Destination DTOs
export 'destination_dto.dart';
export 'saved_destination_dto.dart';
export 'curated_list_dto.dart';
export 'personalized_recommendation_dto.dart';
