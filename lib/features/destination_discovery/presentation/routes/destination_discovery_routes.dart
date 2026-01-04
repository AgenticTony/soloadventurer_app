import 'package:flutter/material.dart';
import 'package:soloadventurer/features/destination_discovery/presentation/screens/screens.dart';

/// Destination discovery route names
class DestinationDiscoveryRoutes {
  /// Route for destination discovery home screen
  static const discovery = '/destinations';

  /// Route for destination detail screen
  static const destinationDetail = '/destinations/detail';

  /// Route for personalized recommendations screen
  static const recommendations = '/destinations/recommendations';

  /// Route for curated lists screen
  static const curatedLists = '/destinations/curated-lists';

  /// Route for curated list detail screen
  static const curatedListDetail = '/destinations/curated-lists/detail';

  /// Route for saved destinations screen
  static const savedDestinations = '/destinations/saved';

  /// Private constructor to prevent instantiation
  const DestinationDiscoveryRoutes._();
}

/// Route handler for destination discovery screens
class DestinationDiscoveryRouter {
  /// Generate route for destination discovery screens
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    Widget screen;

    switch (settings.name) {
      case DestinationDiscoveryRoutes.discovery:
        screen = const DestinationDiscoveryScreen();
        break;
      case DestinationDiscoveryRoutes.destinationDetail:
        final destinationId = settings.arguments as String?;
        if (destinationId == null) {
          return null;
        }
        screen = DestinationDetailScreen(destinationId: destinationId);
        break;
      case DestinationDiscoveryRoutes.recommendations:
        screen = const RecommendationsScreen();
        break;
      case DestinationDiscoveryRoutes.curatedLists:
        screen = const CuratedListsScreen();
        break;
      case DestinationDiscoveryRoutes.curatedListDetail:
        final listId = settings.arguments as String?;
        if (listId == null) {
          return null;
        }
        screen = CuratedListDetailScreen(listId: listId);
        break;
      case DestinationDiscoveryRoutes.savedDestinations:
        screen = const SavedDestinationsScreen();
        break;
      default:
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

  /// Private constructor to prevent instantiation
  const DestinationDiscoveryRouter._();
}
