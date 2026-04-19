import 'package:graphql_flutter/graphql_flutter.dart';
import 'package:soloadventurer/core/errors/exceptions.dart' as app_exceptions;
import '../../domain/models/destination.dart' hide BudgetLevel, ActivityLevel;
import '../../domain/models/destination_filter.dart';
import '../../domain/models/curated_list.dart';
import '../../domain/models/personalized_recommendation.dart';
import '../../domain/models/saved_destination.dart';
import '../../domain/repositories/destination_repository.dart';
import '../graphql/destination_queries.dart';

/// Implementation of [DestinationRepository] using GraphQL API
///
/// This repository handles all destination data operations through GraphQL queries
/// and mutations, including search, retrieval, recommendations, curated lists, and
/// saved destinations management.
class DestinationRepositoryImpl implements DestinationRepository {
  /// GraphQL client for executing queries and mutations
  final GraphQLClient _graphQLClient;

  /// Creates a new [DestinationRepositoryImpl] with the given GraphQL client
  const DestinationRepositoryImpl({
    required GraphQLClient graphQLClient,
  }) : _graphQLClient = graphQLClient;

  @override
  Future<List<Destination>> searchDestinations(DestinationFilter filter) async {
    try {
      final result = await _graphQLClient.query(
        QueryOptions(
          document: gql(DestinationQueries.searchDestinations),
          variables: _buildFilterVariables(filter),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw _handleGraphQLException(result.exception);
      }

      final data = result.data?['searchDestinations'];
      if (data == null) {
        throw const app_exceptions.ServerException(
          message: 'No data returned from search',
        );
      }

      final destinations = (data as List)
          .map((json) => Destination.fromJson(json as Map<String, dynamic>))
          .toList();

      return destinations;
    } on app_exceptions.AppException {
      rethrow;
    } catch (e) {
      throw app_exceptions.ServerException(
          message: 'Failed to search destinations: ${e.toString()}');
    }
  }

  @override
  Future<Destination> getDestinationById(String id) async {
    try {
      final result = await _graphQLClient.query(
        QueryOptions(
          document: gql(DestinationQueries.getDestinationById),
          variables: {'id': id},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw _handleGraphQLException(result.exception);
      }

      final data = result.data?['getDestinationById'];
      if (data == null) {
        throw app_exceptions.NotFoundException(
          message: 'Destination not found with ID: $id',
        );
      }

      return Destination.fromJson(data as Map<String, dynamic>);
    } on app_exceptions.AppException {
      rethrow;
    } catch (e) {
      throw app_exceptions.ServerException(
          message: 'Failed to get destination: ${e.toString()}');
    }
  }

  @override
  Future<PersonalizedRecommendation> getPersonalizedRecommendations(
    String userId,
  ) async {
    try {
      final result = await _graphQLClient.query(
        QueryOptions(
          document: gql(DestinationQueries.getPersonalizedRecommendations),
          variables: {'userId': userId},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw _handleGraphQLException(result.exception);
      }

      final data = result.data?['getPersonalizedRecommendations'];
      if (data == null) {
        throw app_exceptions.NotFoundException(
          message: 'No recommendations found for user: $userId',
        );
      }

      return PersonalizedRecommendation.fromJson(data as Map<String, dynamic>);
    } on app_exceptions.AppException {
      rethrow;
    } catch (e) {
      throw app_exceptions.ServerException(
        message: 'Failed to get recommendations: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<CuratedList>> getCuratedLists() async {
    try {
      final result = await _graphQLClient.query(
        QueryOptions(
          document: gql(DestinationQueries.getCuratedLists),
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw _handleGraphQLException(result.exception);
      }

      final data = result.data?['getCuratedLists'];
      if (data == null) {
        throw const app_exceptions.ServerException(
          message: 'No curated lists data returned',
        );
      }

      final curatedLists = (data as List)
          .map((json) => CuratedList.fromJson(json as Map<String, dynamic>))
          .toList();

      return curatedLists;
    } on app_exceptions.AppException {
      rethrow;
    } catch (e) {
      throw app_exceptions.ServerException(
        message: 'Failed to get curated lists: ${e.toString()}',
      );
    }
  }

  @override
  Future<CuratedList> getCuratedListById(String id) async {
    try {
      final result = await _graphQLClient.query(
        QueryOptions(
          document: gql(DestinationQueries.getCuratedListById),
          variables: {'id': id},
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw _handleGraphQLException(result.exception);
      }

      final data = result.data?['getCuratedListById'];
      if (data == null) {
        throw app_exceptions.NotFoundException(
          message: 'Curated list not found with ID: $id',
        );
      }

      return CuratedList.fromJson(data as Map<String, dynamic>);
    } on app_exceptions.AppException {
      rethrow;
    } catch (e) {
      throw app_exceptions.ServerException(
        message: 'Failed to get curated list: ${e.toString()}',
      );
    }
  }

  @override
  Future<SavedDestination> saveDestination(SavedDestination saved) async {
    try {
      final result = await _graphQLClient.mutate(
        MutationOptions(
          document: gql(DestinationQueries.saveDestination),
          variables: {
            'userId': saved.userId,
            'destinationId': saved.destination.id,
            'saveType': _saveTypeToString(saved.saveType),
            'tripId': saved.tripId,
            'notes': saved.notes,
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw _handleGraphQLException(result.exception);
      }

      final data = result.data?['saveDestination'];
      if (data == null) {
        throw const app_exceptions.ServerException(
          message: 'Failed to save destination: No data returned',
        );
      }

      return SavedDestination.fromJson(data as Map<String, dynamic>);
    } on app_exceptions.AppException {
      rethrow;
    } catch (e) {
      throw app_exceptions.ServerException(
        message: 'Failed to save destination: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> unsaveDestination({
    required String destinationId,
    required String userId,
    SaveType? saveType,
  }) async {
    try {
      final result = await _graphQLClient.mutate(
        MutationOptions(
          document: gql(DestinationQueries.unsaveDestination),
          variables: {
            'destinationId': destinationId,
            'userId': userId,
            if (saveType != null) 'saveType': _saveTypeToString(saveType),
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw _handleGraphQLException(result.exception);
      }

      final success = result.data?['unsaveDestination']['success'] as bool?;
      if (success != true) {
        throw const app_exceptions.ServerException(
          message: 'Failed to unsave destination',
        );
      }
    } on app_exceptions.AppException {
      rethrow;
    } catch (e) {
      throw app_exceptions.ServerException(
        message: 'Failed to unsave destination: ${e.toString()}',
      );
    }
  }

  @override
  Future<List<SavedDestination>> getSavedDestinations(
    String userId, {
    SaveType? saveType,
  }) async {
    try {
      final result = await _graphQLClient.query(
        QueryOptions(
          document: gql(DestinationQueries.getSavedDestinations),
          variables: {
            'userId': userId,
            if (saveType != null) 'saveType': _saveTypeToString(saveType),
          },
          fetchPolicy: FetchPolicy.networkOnly,
        ),
      );

      if (result.hasException) {
        throw _handleGraphQLException(result.exception);
      }

      final data = result.data?['getSavedDestinations'];
      if (data == null) {
        throw const app_exceptions.ServerException(
          message: 'No saved destinations data returned',
        );
      }

      final savedDestinations = (data as List)
          .map(
              (json) => SavedDestination.fromJson(json as Map<String, dynamic>))
          .toList();

      return savedDestinations;
    } on app_exceptions.AppException {
      rethrow;
    } catch (e) {
      throw app_exceptions.ServerException(
        message: 'Failed to get saved destinations: ${e.toString()}',
      );
    }
  }

  /// Build query variables from destination filter
  ///
  /// Converts a [DestinationFilter] object into a map of GraphQL query variables.
  /// This method handles:
  /// - Enum to string conversions for GraphQL compatibility
  /// - Null value filtering (only includes non-null values)
  /// - Type mapping for all filter parameters
  ///
  /// The returned map is used directly in GraphQL query variables.
  ///
  /// Example:
  /// ```dart
  /// final filter = DestinationFilter(
  ///   searchQuery: 'beach',
  ///   budgetLevel: BudgetLevel.budget,
  ///   minSafetyScore: 7.0,
  /// );
  /// final variables = _buildFilterVariables(filter);
  /// // Returns: {
  /// //   'searchQuery': 'beach',
  /// //   'budgetLevel': 'BUDGET',
  /// //   'minSafetyScore': 7.0,
  /// //   'sortBy': 'RELEVANCE',
  /// //   'offset': 0,
  /// //   'limit': 20,
  /// // }
  /// ```
  Map<String, dynamic> _buildFilterVariables(DestinationFilter filter) {
    final variables = <String, dynamic>{
      'searchQuery': filter.searchQuery,
      'budgetLevel': filter.budgetLevel != null
          ? _budgetLevelToString(filter.budgetLevel!)
          : null,
      'minSafetyScore': filter.minSafetyScore,
      'minSoloSuitabilityScore': filter.minSoloSuitabilityScore,
      'activityLevel': filter.activityLevel != null
          ? _activityLevelToString(filter.activityLevel!)
          : null,
      'countryCode': filter.countryCode,
      'region': filter.region,
      'tags': filter.tags,
      'hiddenGemsOnly': filter.hiddenGemsOnly,
      'minPopularityScore': filter.minPopularityScore,
      'maxDailyCost': filter.maxDailyCost,
      'sortBy': _sortOrderToString(filter.sortBy),
      'offset': filter.offset,
      'limit': filter.limit,
    };

    // Remove null values to avoid sending unnecessary parameters to GraphQL
    variables.removeWhere((key, value) => value == null);

    return variables;
  }

  /// Convert BudgetLevel enum to GraphQL enum string
  String _budgetLevelToString(BudgetLevel level) {
    switch (level) {
      case BudgetLevel.budget:
        return 'BUDGET';
      case BudgetLevel.economy:
        return 'ECONOMY';
      case BudgetLevel.midRange:
        return 'MID_RANGE';
      case BudgetLevel.premium:
        return 'PREMIUM';
      case BudgetLevel.luxury:
        return 'LUXURY';
      case BudgetLevel.ultraLuxury:
        return 'ULTRA_LUXURY';
    }
  }

  /// Convert ActivityLevel enum to GraphQL enum string
  String _activityLevelToString(ActivityLevel level) {
    switch (level) {
      case ActivityLevel.relaxed:
        return 'RELAXED';
      case ActivityLevel.light:
        return 'LIGHT';
      case ActivityLevel.moderate:
        return 'MODERATE';
      case ActivityLevel.active:
        return 'ACTIVE';
      case ActivityLevel.intense:
        return 'INTENSE';
      case ActivityLevel.extreme:
        return 'EXTREME';
    }
  }

  /// Convert DestinationSortOrder enum to GraphQL enum string
  String _sortOrderToString(DestinationSortOrder order) {
    switch (order) {
      case DestinationSortOrder.popularity:
        return 'POPULARITY';
      case DestinationSortOrder.safety:
        return 'SAFETY';
      case DestinationSortOrder.soloSuitability:
        return 'SOLO_SUITABILITY';
      case DestinationSortOrder.budgetAsc:
        return 'BUDGET_ASC';
      case DestinationSortOrder.budgetDesc:
        return 'BUDGET_DESC';
      case DestinationSortOrder.newest:
        return 'NEWEST';
      case DestinationSortOrder.relevance:
        return 'RELEVANCE';
    }
  }

  /// Convert SaveType enum to GraphQL enum string
  String _saveTypeToString(SaveType type) {
    switch (type) {
      case SaveType.wishlist:
        return 'WISHLIST';
      case SaveType.trip:
        return 'TRIP';
    }
  }

  /// Handle GraphQL exceptions and convert to appropriate AppException
  ///
  /// This method centralizes GraphQL error handling and maps different types of
  /// exceptions to domain-specific [AppException] types. It handles:
  ///
  /// **Network Errors:**
  /// - Timeouts → [NetworkTimeoutException]
  /// - Connectivity issues → [NetworkConnectivityException]
  /// - Other network errors → [ServerException]
  ///
  /// **GraphQL Errors:**
  /// - BAD_REQUEST → [BadRequestException]
  /// - UNAUTHORIZED → [UnauthorizedException]
  /// - FORBIDDEN → [ForbiddenException]
  /// - NOT_FOUND → [NotFoundException]
  /// - VALIDATION_ERROR → [ValidationException] with error details
  /// - Other codes → [ServerException] with code
  ///
  /// Error codes are extracted from the GraphQL error extensions field.
  ///
  /// Example GraphQL error response structure:
  /// ```json
  /// {
  ///   "errors": [{
  ///     "message": "Invalid input",
  ///     "extensions": {
  ///       "code": "VALIDATION_ERROR",
  ///       "errors": {
  ///         "email": ["Invalid email format"]
  ///       }
  ///     }
  ///   }]
  /// }
  /// ```
  ///
  /// Returns an [AppException] subclass appropriate for the error type.
  app_exceptions.AppException _handleGraphQLException(OperationException? exception) {
    if (exception == null) {
      return const app_exceptions.UnknownException(
        message: 'Unknown GraphQL error occurred',
      );
    }

    final linkException = exception.linkException;
    if (linkException != null) {
      // Network-related errors
      if (linkException.toString().contains('timeout') ||
          linkException.toString().contains('SocketException')) {
        return const app_exceptions.NetworkTimeoutException(
          message: 'Request timeout. Please check your connection.',
        );
      }

      if (linkException.toString().contains('NetworkException') ||
          linkException.toString().contains('no internet')) {
        return const app_exceptions.NetworkConnectivityException(
          message: 'No internet connection. Please check your network.',
        );
      }

      return app_exceptions.ServerException(
        message: 'Network error: ${linkException.toString()}',
      );
    }

    // GraphQL errors (e.g., validation, business logic errors)
    final graphqlErrors = exception.graphqlErrors;
    if (graphqlErrors.isNotEmpty) {
      final firstError = graphqlErrors.first;
      final message = firstError.message;

      // Parse error code from extensions if available
      final code = firstError.extensions?['code'] as String?;

      // Map common GraphQL error codes to AppException types
      switch (code) {
        case 'BAD_REQUEST':
          return app_exceptions.BadRequestException(message: message);
        case 'UNAUTHORIZED':
          return app_exceptions.UnauthorizedException(message: message);
        case 'FORBIDDEN':
          return app_exceptions.ForbiddenException(message: message);
        case 'NOT_FOUND':
          return app_exceptions.NotFoundException(message: message);
        case 'VALIDATION_ERROR':
          return app_exceptions.ValidationException(
            message: message,
            errors: (firstError.extensions?['errors'] as Map<String, dynamic>?)
                    ?.map(
                  (key, value) => MapEntry(
                    key,
                    (value as List).map((e) => e.toString()).toList(),
                  ),
                ) ??
                {},
          );
        default:
          return app_exceptions.ServerException(message: message, code: code);
      }
    }

    return app_exceptions.ServerException(
      message: exception.toString(),
    );
  }
}
