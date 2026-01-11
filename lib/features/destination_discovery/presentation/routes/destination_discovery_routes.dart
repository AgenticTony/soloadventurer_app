import 'package:flutter/material.dart';
import 'package:soloadventurer/features/destination_discovery/presentation/screens/screens.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/destination_filter.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/destination.dart' hide BudgetLevel, ActivityLevel;

/// Destination discovery route names
class DestinationDiscoveryRoutes {
  /// Route for destination discovery home screen
  static const discovery = '/destinations';

  /// Route for destination detail screen
  /// Use pattern: /destinations/detail/:id
  static const destinationDetail = '/destinations/detail';

  /// Route for personalized recommendations screen
  static const recommendations = '/destinations/recommendations';

  /// Route for curated lists screen
  static const curatedLists = '/destinations/curated-lists';

  /// Route for curated list detail screen
  /// Use pattern: /destinations/curated-lists/detail/:id
  static const curatedListDetail = '/destinations/curated-lists/detail';

  /// Route for saved destinations screen
  static const savedDestinations = '/destinations/saved';

  /// Private constructor to prevent instantiation
}

/// Route handler for destination discovery screens
///
/// This class handles navigation and deep linking for all destination discovery screens.
/// It supports:
///
/// **Path-based Deep Links:**
/// - Direct navigation to specific resources using URL paths
/// - ID extraction from URL path segments
///
/// **Query Parameter Filters:**
/// - Pre-filtering destination search results from deep links
/// - Support for all filter parameters (budget, safety, activity, tags, etc.)
///
/// **Legacy Navigation:**
/// - Support for RouteSettings.arguments-based navigation
///
/// **Deep Link Examples:**
/// ```dart
/// // Navigate to destination detail
/// // /destinations/detail/123
/// Navigator.pushNamed(context, '/destinations/detail/123');
///
/// // Navigate to curated list detail
/// // /destinations/curated-lists/detail/456
/// Navigator.pushNamed(context, '/destinations/curated-lists/detail/456');
///
/// // Navigate to search with filters
/// // /destinations?budget=budget&activity=relaxed&tags=beach,urban
/// Navigator.pushNamed(context, '/destinations?q=beach&budget=budget&minSafety=7');
///
/// // Navigate to recommendations
/// Navigator.pushNamed(context, '/destinations/recommendations');
///
/// // Navigate to curated lists
/// Navigator.pushNamed(context, '/destinations/curated-lists');
///
/// // Navigate to saved destinations
/// Navigator.pushNamed(context, '/destinations/saved');
/// ```
///
/// **Query Parameter Reference:**
/// - `q`: Search query text
/// - `budget`: Budget level (budget, moderate, expensive)
/// - `minSafety`: Minimum safety score (1-10)
/// - `minSoloSuitability`: Minimum solo suitability score (1-10)
/// - `activity`: Activity level (relaxed, moderate, adventurous)
/// - `country`: Country code (e.g., JP, US, TH)
/// - `region`: Region name
/// - `tags`: Comma-separated tags (e.g., beach,urban,cultural)
/// - `hiddenGems`: true/false for hidden gems only
/// - `sortBy`: Sort order (popularity, safety, solo_suitability, budget_asc, budget_desc, newest, relevance)
///
/// All navigation uses [PageRouteBuilder] with fade transitions for consistent UX.
class DestinationDiscoveryRouter {
  /// Generate route for destination discovery screens
  ///
  /// Supports deep linking with URL path parameters and query parameters.
  ///
  /// **Deep link patterns:**
  /// - `/destinations/detail/:id` - Navigate to destination detail
  /// - `/destinations/curated-lists/detail/:id` - Navigate to curated list detail
  /// - `/destinations?budget=budget&activity=relaxed&tags=beach,urban` - Navigate to search with filters
  ///
  /// Returns null if the route is not handled, allowing other routers to process it.
  ///
  /// See [DestinationDiscoveryRouter] class documentation for detailed examples.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? '');
    final path = uri.path;
    final queryParameters = uri.queryParameters;

    Widget screen;

    // Handle /destinations/detail/:id pattern
    if (path.startsWith('${DestinationDiscoveryRoutes.destinationDetail}/')) {
      final destinationId = path
          .substring('${DestinationDiscoveryRoutes.destinationDetail}/'.length);
      if (destinationId.isEmpty) {
        return _errorRoute(settings, 'Invalid destination ID');
      }
      screen = DestinationDetailScreen(destinationId: destinationId);
    }
    // Handle /destinations/curated-lists/detail/:id pattern
    else if (path
        .startsWith('${DestinationDiscoveryRoutes.curatedListDetail}/')) {
      final listId = path
          .substring('${DestinationDiscoveryRoutes.curatedListDetail}/'.length);
      if (listId.isEmpty) {
        return _errorRoute(settings, 'Invalid curated list ID');
      }
      screen = CuratedListDetailScreen(listId: listId);
    }
    // Handle exact route matches
    else if (path == DestinationDiscoveryRoutes.discovery) {
      // Parse query parameters for filters
      final filter = _parseFilterQueryParams(queryParameters);
      screen = DestinationDiscoveryScreen(initialFilter: filter);
    } else if (path == DestinationDiscoveryRoutes.destinationDetail) {
      // Legacy support for arguments-based navigation
      final destinationId = settings.arguments as String?;
      if (destinationId == null) {
        return _errorRoute(settings, 'Missing destination ID');
      }
      screen = DestinationDetailScreen(destinationId: destinationId);
    } else if (path == DestinationDiscoveryRoutes.recommendations) {
      screen = const RecommendationsScreen();
    } else if (path == DestinationDiscoveryRoutes.curatedLists) {
      screen = const CuratedListsScreen();
    } else if (path == DestinationDiscoveryRoutes.curatedListDetail) {
      // Legacy support for arguments-based navigation
      final listId = settings.arguments as String?;
      if (listId == null) {
        return _errorRoute(settings, 'Missing curated list ID');
      }
      screen = CuratedListDetailScreen(listId: listId);
    } else if (path == DestinationDiscoveryRoutes.savedDestinations) {
      screen = const SavedDestinationsScreen();
    } else {
      return null;
    }

    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => screen,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  /// Parse query parameters into a DestinationFilter
  ///
  /// Extracts and validates filter parameters from URL query strings.
  /// Invalid parameters are safely ignored without throwing errors.
  ///
  /// **Supported query parameters:**
  /// - `q`: Search query text
  /// - `budget`: Budget level (budget, moderate, expensive)
  /// - `minSafety`: Minimum safety score (1-10)
  /// - `minSoloSuitability`: Minimum solo suitability score (1-10)
  /// - `activity`: Activity level (relaxed, moderate, adventurous)
  /// - `country`: Country code (e.g., JP, US, TH)
  /// - `region`: Region name
  /// - `tags`: Comma-separated tags (e.g., beach,urban,cultural)
  /// - `hiddenGems`: true/false for hidden gems only
  /// - `sortBy`: Sort order (popularity, safety, solo_suitability, budget_asc, budget_desc, newest, relevance)
  ///
  /// **Example:**
  /// ```dart
  /// // URL: /destinations?q=beach&budget=budget&minSafety=7&tags=urban,cultural
  /// final params = {
  ///   'q': 'beach',
  ///   'budget': 'budget',
  ///   'minSafety': '7',
  ///   'tags': 'urban,cultural',
  /// };
  /// final filter = _parseFilterQueryParams(params);
  /// // Returns: DestinationFilter with searchQuery, budgetLevel, minSafetyScore, tags set
  /// ```
  ///
  /// Returns a [DestinationFilter] with parsed parameters. Invalid or unknown
  /// parameters are ignored. Numeric parameters are clamped to valid ranges.
  static DestinationFilter _parseFilterQueryParams(Map<String, String> params) {
    // Check if there are any filter parameters
    if (params.isEmpty) {
      return DestinationFilter();
    }

    return DestinationFilter(
      searchQuery: params['q'],
      budgetLevel: _parseBudgetLevel(params['budget']),
      minSafetyScore: _parseDoubleParam(params['minSafety'], 1, 10),
      minSoloSuitabilityScore:
          _parseDoubleParam(params['minSoloSuitability'], 1, 10),
      activityLevel: _parseActivityLevel(params['activity']),
      countryCode: params['country'],
      region: params['region'],
      tags: params['tags']
          ?.split(',')
          .map((tag) => tag.trim())
          .where((tag) => tag.isNotEmpty)
          .toList(),
      hiddenGemsOnly: params['hiddenGems']?.toLowerCase() == 'true',
      sortBy: _parseSortOrder(params['sortBy']) ?? DestinationSortOrder.popularity,
    );
  }

  /// Parse budget level from string
  ///
  /// Performs case-insensitive parsing of budget level strings.
  /// Returns null for null input or unknown values (silently ignored).
  ///
  /// Valid values: "budget", "moderate", "expensive" (mapped to filter equivalents)
  static FilterBudgetLevel? _parseBudgetLevel(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'budget':
        return FilterBudgetLevel.budget;
      case 'moderate':
        return FilterBudgetLevel.midRange;
      case 'expensive':
        return FilterBudgetLevel.luxury;
      default:
        return null;
    }
  }

  /// Parse activity level from string
  ///
  /// Performs case-insensitive parsing of activity level strings.
  /// Returns null for null input or unknown values (silently ignored).
  ///
  /// Valid values: "relaxed", "moderate", "adventurous" (mapped to filter equivalents)
  static FilterActivityLevel? _parseActivityLevel(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'relaxed':
        return FilterActivityLevel.relaxed;
      case 'moderate':
        return FilterActivityLevel.moderate;
      case 'adventurous':
        return FilterActivityLevel.active;
      default:
        return null;
    }
  }

  /// Parse sort order from string
  ///
  /// Performs case-insensitive parsing of sort order strings.
  /// Returns null for null input or unknown values (silently ignored).
  ///
  /// Valid values: "popularity", "safety", "solo_suitability", "budget_asc",
  /// "budget_desc", "newest", "relevance"
  static DestinationSortOrder? _parseSortOrder(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'popularity':
        return DestinationSortOrder.popularity;
      case 'safety':
        return DestinationSortOrder.safety;
      case 'solo_suitability':
        return DestinationSortOrder.soloSuitability;
      case 'budget_asc':
        return DestinationSortOrder.budgetAsc;
      case 'budget_desc':
        return DestinationSortOrder.budgetDesc;
      case 'newest':
        return DestinationSortOrder.newest;
      case 'relevance':
        return DestinationSortOrder.relevance;
      default:
        return null;
    }
  }

  /// Parse double parameter with range validation
  ///
  /// Parses a string to a double and validates it's within the specified range.
  /// Returns null if parsing fails or value is out of range (silently ignored).
  ///
  /// **Parameters:**
  /// - [value]: The string value to parse
  /// - [min]: Minimum valid value (inclusive)
  /// - [max]: Maximum valid value (inclusive)
  ///
  /// **Example:**
  /// ```dart
  /// _parseDoubleParam('7', 1, 10); // Returns 7.0
  /// _parseDoubleParam('0', 1, 10); // Returns null (out of range)
  /// _parseDoubleParam('invalid', 1, 10); // Returns null (parse error)
  /// ```
  static double? _parseDoubleParam(String? value, double min, double max) {
    if (value == null) return null;
    final parsed = double.tryParse(value);
    if (parsed == null) return null;
    if (parsed < min || parsed > max) return null;
    return parsed;
  }

  /// Create an error route for invalid deep links
  static Route<dynamic> _errorRoute(
      RouteSettings settings, String errorMessage) {
    return PageRouteBuilder(
      settings: settings,
      pageBuilder: (context, animation, secondaryAnimation) => _ErrorScreen(
        message: errorMessage,
      ),
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return FadeTransition(
          opacity: animation,
          child: child,
        );
      },
    );
  }

  /// Private constructor to prevent instantiation
}

/// Error screen for invalid deep links
class _ErrorScreen extends StatelessWidget {
  final String message;

  const _ErrorScreen({required this.message});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Error'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.error_outline,
                size: 64,
                color: Theme.of(context).colorScheme.error,
              ),
              const SizedBox(height: 16),
              Text(
                'Invalid Link',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 8),
              Text(
                message,
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.of(context).pushReplacementNamed(
                    DestinationDiscoveryRoutes.discovery,
                  );
                },
                icon: const Icon(Icons.explore),
                label: const Text('Explore Destinations'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
