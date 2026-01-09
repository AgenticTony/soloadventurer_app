import 'package:flutter/material.dart';
import 'package:soloadventurer/features/recommendations/presentation/screens/recommendations_screen.dart';

/// Routes for the recommendations feature
class RecommendationsRoutes {
  /// Path to the recommendations screen
  static const String recommendations = '/recommendations';

  /// Path to recommendations for a specific itinerary
  static String forItinerary(String itineraryId) =>
      '/itineraries/$itineraryId/recommendations';

  /// Creates the recommendations screen
  static Widget recommendationsScreen({required String itineraryId}) {
    return RecommendationsScreen(itineraryId: itineraryId);
  }

  /// Navigates to recommendations screen
  static Future<void> navigate(
    BuildContext context, {
    required String itineraryId,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => RecommendationsScreen(itineraryId: itineraryId),
      ),
    );
  }

  /// Route factory for go_router
  static Route<void>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case recommendations:
        return MaterialPageRoute(
          builder: (_) => const Placeholder(), // Would need itinerary ID
        );
      default:
        return null;
    }
  }

  /// Parses itinerary ID from route
  static String? parseItineraryId(String route) {
    // Extract itinerary ID from pattern: /itineraries/{id}/recommendations
    final match = RegExp(r'/itineraries/([^/]+)/recommendations').firstMatch(route);
    return match?.group(1);
  }
}
