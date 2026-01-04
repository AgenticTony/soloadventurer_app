import 'package:flutter/material.dart';
import 'package:soloadventurer/features/destination_discovery/presentation/screens/screens.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/destination_filter.dart';
import 'package:soloadventurer/features/destination_discovery/domain/models/destination.dart';

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
  const DestinationDiscoveryRoutes._();
}

/// Route handler for destination discovery screens
class DestinationDiscoveryRouter {
  /// Generate route for destination discovery screens
  /// Supports deep linking with URL path parameters and query parameters
  ///
  /// Deep link patterns:
  /// - /destinations/detail/:id - Navigate to destination detail
  /// - /destinations/curated-lists/detail/:id - Navigate to curated list detail
  /// - /destinations?budget=budget&activity=relaxed&tags=beach,urban - Navigate to search with filters
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    final uri = Uri.parse(settings.name ?? '');
    final path = uri.path;
    final queryParameters = uri.queryParameters;

    Widget screen;

    // Handle /destinations/detail/:id pattern
    if (path.startsWith('${DestinationDiscoveryRoutes.destinationDetail}/')) {
      final destinationId = path.substring('${DestinationDiscoveryRoutes.destinationDetail}/'.length);
      if (destinationId.isEmpty) {
        return _errorRoute(settings, 'Invalid destination ID');
      }
      screen = DestinationDetailScreen(destinationId: destinationId);
    }
    // Handle /destinations/curated-lists/detail/:id pattern
    else if (path.startsWith('${DestinationDiscoveryRoutes.curatedListDetail}/')) {
      final listId = path.substring('${DestinationDiscoveryRoutes.curatedListDetail}/'.length);
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
    }
    else if (path == DestinationDiscoveryRoutes.destinationDetail) {
      // Legacy support for arguments-based navigation
      final destinationId = settings.arguments as String?;
      if (destinationId == null) {
        return _errorRoute(settings, 'Missing destination ID');
      }
      screen = DestinationDetailScreen(destinationId: destinationId);
    }
    else if (path == DestinationDiscoveryRoutes.recommendations) {
      screen = const RecommendationsScreen();
    }
    else if (path == DestinationDiscoveryRoutes.curatedLists) {
      screen = const CuratedListsScreen();
    }
    else if (path == DestinationDiscoveryRoutes.curatedListDetail) {
      // Legacy support for arguments-based navigation
      final listId = settings.arguments as String?;
      if (listId == null) {
        return _errorRoute(settings, 'Missing curated list ID');
      }
      screen = CuratedListDetailScreen(listId: listId);
    }
    else if (path == DestinationDiscoveryRoutes.savedDestinations) {
      screen = const SavedDestinationsScreen();
    }
    else {
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
  /// Supported query parameters:
  /// - q: Search query
  /// - budget: Budget level (budget, moderate, expensive)
  /// - minSafety: Minimum safety score (1-10)
  /// - minSoloSuitability: Minimum solo suitability score (1-10)
  /// - activity: Activity level (relaxed, moderate, adventurous)
  /// - country: Country code (e.g., JP, US, TH)
  /// - region: Region name
  /// - tags: Comma-separated tags (e.g., beach,urban)
  /// - hiddenGems: true/false
  /// - sortBy: Sort order (popularity, safety, solo_suitability, budget_asc, budget_desc, newest, relevance)
  static DestinationFilter _parseFilterQueryParams(Map<String, String> params) {
    // Check if there are any filter parameters
    if (params.isEmpty) {
      return const DestinationFilter();
    }

    return DestinationFilter(
      searchQuery: params['q'],
      budgetLevel: _parseBudgetLevel(params['budget']),
      minSafetyScore: _parseDoubleParam(params['minSafety'], 1, 10),
      minSoloSuitabilityScore: _parseDoubleParam(params['minSoloSuitability'], 1, 10),
      activityLevel: _parseActivityLevel(params['activity']),
      countryCode: params['country'],
      region: params['region'],
      tags: params['tags']?.split(',').map((tag) => tag.trim()).where((tag) => tag.isNotEmpty).toList(),
      hiddenGemsOnly: params['hiddenGems']?.toLowerCase() == 'true',
      sortBy: _parseSortOrder(params['sortBy']),
    );
  }

  /// Parse budget level from string
  static BudgetLevel? _parseBudgetLevel(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'budget':
        return BudgetLevel.budget;
      case 'moderate':
        return BudgetLevel.moderate;
      case 'expensive':
        return BudgetLevel.expensive;
      default:
        return null;
    }
  }

  /// Parse activity level from string
  static ActivityLevel? _parseActivityLevel(String? value) {
    if (value == null) return null;
    switch (value.toLowerCase()) {
      case 'relaxed':
        return ActivityLevel.relaxed;
      case 'moderate':
        return ActivityLevel.moderate;
      case 'adventurous':
        return ActivityLevel.adventurous;
      default:
        return null;
    }
  }

  /// Parse sort order from string
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
  static double? _parseDoubleParam(String? value, double min, double max) {
    if (value == null) return null;
    final parsed = double.tryParse(value);
    if (parsed == null) return null;
    if (parsed < min || parsed > max) return null;
    return parsed;
  }

  /// Create an error route for invalid deep links
  static Route<dynamic> _errorRoute(RouteSettings settings, String errorMessage) {
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
  const DestinationDiscoveryRouter._();
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
