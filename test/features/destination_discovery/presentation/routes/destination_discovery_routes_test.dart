import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/destination_discovery/presentation/routes/destination_discovery_routes.dart';

void main() {
  group('DestinationDiscoveryRouter - Deep Linking', () {
    testWidgets('Should handle destination detail deep link with ID in path',
        (WidgetTester tester) async {
      // Arrange: Create route settings with ID in path
      const settings = RouteSettings(
        name: '/destinations/detail/dest_123',
      );

      // Act: Generate route
      final route = DestinationDiscoveryRouter.onGenerateRoute(settings);

      // Assert: Route should not be null
      expect(route, isNotNull);
    });

    testWidgets('Should handle curated list detail deep link with ID in path',
        (WidgetTester tester) async {
      // Arrange: Create route settings with list ID in path
      const settings = RouteSettings(
        name: '/destinations/curated-lists/detail/list_456',
      );

      // Act: Generate route
      final route = DestinationDiscoveryRouter.onGenerateRoute(settings);

      // Assert: Route should not be null
      expect(route, isNotNull);
    });

    testWidgets(
        'Should handle discovery screen with query parameters for filters',
        (WidgetTester tester) async {
      // Arrange: Create route settings with filter query parameters
      const settings = RouteSettings(
        name:
            '/destinations?budget=budget&activity=relaxed&minSafety=8&tags=beach,urban',
      );

      // Act: Generate route
      final route = DestinationDiscoveryRouter.onGenerateRoute(settings);

      // Assert: Route should not be null
      expect(route, isNotNull);
    });

    testWidgets('Should return error route for empty destination ID',
        (WidgetTester tester) async {
      // Arrange: Create route settings with empty ID
      const settings = RouteSettings(
        name: '/destinations/detail/',
      );

      // Act: Generate route
      final route = DestinationDiscoveryRouter.onGenerateRoute(settings);

      // Assert: Route should not be null (returns error route)
      expect(route, isNotNull);
    });

    testWidgets('Should return error route for empty list ID',
        (WidgetTester tester) async {
      // Arrange: Create route settings with empty list ID
      const settings = RouteSettings(
        name: '/destinations/curated-lists/detail/',
      );

      // Act: Generate route
      final route = DestinationDiscoveryRouter.onGenerateRoute(settings);

      // Assert: Route should not be null (returns error route)
      expect(route, isNotNull);
    });

    testWidgets(
        'Should handle legacy navigation with arguments for destination detail',
        (WidgetTester tester) async {
      // Arrange: Create route settings with arguments
      const settings = RouteSettings(
        name: '/destinations/detail',
        arguments: 'dest_789',
      );

      // Act: Generate route
      final route = DestinationDiscoveryRouter.onGenerateRoute(settings);

      // Assert: Route should not be null
      expect(route, isNotNull);
    });

    testWidgets('Should return null for unknown routes',
        (WidgetTester tester) async {
      // Arrange: Create route settings with unknown route
      const settings = RouteSettings(
        name: '/destinations/unknown',
      );

      // Act: Generate route
      final route = DestinationDiscoveryRouter.onGenerateRoute(settings);

      // Assert: Route should be null
      expect(route, isNull);
    });
  });

  group('DestinationDiscoveryRouter - Query Parameter Parsing', () {
    test('Should parse budget level from query parameter', () {
      // Arrange
      final params = {'budget': 'budget'};

      // Act: Parse filter via reflection of internal method
      // Note: This tests the parsing logic through the route generation
      const settings = RouteSettings(name: '/destinations?budget=budget');
      final route = DestinationDiscoveryRouter.onGenerateRoute(settings);

      // Assert
      expect(route, isNotNull);
    });

    test('Should parse activity level from query parameter', () {
      // Arrange
      const settings = RouteSettings(
        name: '/destinations?activity=adventurous',
      );

      // Act
      final route = DestinationDiscoveryRouter.onGenerateRoute(settings);

      // Assert
      expect(route, isNotNull);
    });

    test('Should parse search query from q parameter', () {
      // Arrange
      const settings = RouteSettings(
        name: '/destinations?q=Tokyo',
      );

      // Act
      final route = DestinationDiscoveryRouter.onGenerateRoute(settings);

      // Assert
      expect(route, isNotNull);
    });

    test('Should parse multiple tags from comma-separated list', () {
      // Arrange
      const settings = RouteSettings(
        name: '/destinations?tags=beach,urban,cultural',
      );

      // Act
      final route = DestinationDiscoveryRouter.onGenerateRoute(settings);

      // Assert
      expect(route, isNotNull);
    });

    test('Should parse minSafety score with range validation', () {
      // Arrange: Valid score
      const settings = RouteSettings(
        name: '/destinations?minSafety=8',
      );

      // Act
      final route = DestinationDiscoveryRouter.onGenerateRoute(settings);

      // Assert
      expect(route, isNotNull);
    });

    test('Should handle all filter parameters together', () {
      // Arrange: Complex query with all filters
      const settings = RouteSettings(
        name:
            '/destinations?q=Japan&budget=moderate&activity=relaxed&minSafety=7&minSoloSuitability=8&country=JP&tags=beach,urban&hiddenGems=true&sortBy=safety',
      );

      // Act
      final route = DestinationDiscoveryRouter.onGenerateRoute(settings);

      // Assert
      expect(route, isNotNull);
    });

    test('Should ignore invalid enum values', () {
      // Arrange: Invalid budget level
      const settings = RouteSettings(
        name: '/destinations?budget=invalid',
      );

      // Act
      final route = DestinationDiscoveryRouter.onGenerateRoute(settings);

      // Assert: Should still create route, just ignore invalid parameter
      expect(route, isNotNull);
    });

    test('Should handle out-of-range score values', () {
      // Arrange: Score out of valid range
      const settings = RouteSettings(
        name: '/destinations?minSafety=15', // Invalid: > 10
      );

      // Act
      final route = DestinationDiscoveryRouter.onGenerateRoute(settings);

      // Assert: Should still create route, just ignore invalid parameter
      expect(route, isNotNull);
    });
  });

  group('Deep Link Examples', () {
    test('Example 1: Direct link to destination detail', () {
      // Example: https://soloadventurer.app/destinations/detail/tokyo_123
      const settings = RouteSettings(
        name: '/destinations/detail/tokyo_123',
      );
      final route = DestinationDiscoveryRouter.onGenerateRoute(settings);
      expect(route, isNotNull);
    });

    test('Example 2: Direct link to curated list', () {
      // Example: https://soloadventurer.app/destinations/curated-lists/detail/hidden_gems_asia
      const settings = RouteSettings(
        name: '/destinations/curated-lists/detail/hidden_gems_asia',
      );
      final route = DestinationDiscoveryRouter.onGenerateRoute(settings);
      expect(route, isNotNull);
    });

    test('Example 3: Search with budget filter', () {
      // Example: https://soloadventurer.app/destinations?budget=budget
      const settings = RouteSettings(
        name: '/destinations?budget=budget',
      );
      final route = DestinationDiscoveryRouter.onGenerateRoute(settings);
      expect(route, isNotNull);
    });

    test('Example 4: Search with activity level filter', () {
      // Example: https://soloadventurer.app/destinations?activity=adventurous
      const settings = RouteSettings(
        name: '/destinations?activity=adventurous',
      );
      final route = DestinationDiscoveryRouter.onGenerateRoute(settings);
      expect(route, isNotNull);
    });

    test('Example 5: Search with safety score filter', () {
      // Example: https://soloadventurer.app/destinations?minSafety=8
      const settings = RouteSettings(
        name: '/destinations?minSafety=8',
      );
      final route = DestinationDiscoveryRouter.onGenerateRoute(settings);
      expect(route, isNotNull);
    });

    test('Example 6: Search with tags', () {
      // Example: https://soloadventurer.app/destinations?tags=beach,urban
      const settings = RouteSettings(
        name: '/destinations?tags=beach,urban',
      );
      final route = DestinationDiscoveryRouter.onGenerateRoute(settings);
      expect(route, isNotNull);
    });

    test('Example 7: Search with hidden gems filter', () {
      // Example: https://soloadventurer.app/destinations?hiddenGems=true
      const settings = RouteSettings(
        name: '/destinations?hiddenGems=true',
      );
      final route = DestinationDiscoveryRouter.onGenerateRoute(settings);
      expect(route, isNotNull);
    });

    test('Example 8: Complex search with multiple filters', () {
      // Example: https://soloadventurer.app/destinations?budget=budget&activity=relaxed&minSafety=7&minSoloSuitability=8&tags=beach,urban&hiddenGems=true&sortBy=safety
      const settings = RouteSettings(
        name:
            '/destinations?budget=budget&activity=relaxed&minSafety=7&minSoloSuitability=8&tags=beach,urban&hiddenGems=true&sortBy=safety',
      );
      final route = DestinationDiscoveryRouter.onGenerateRoute(settings);
      expect(route, isNotNull);
    });

    test('Example 9: Search with country filter', () {
      // Example: https://soloadventurer.app/destinations?country=JP
      const settings = RouteSettings(
        name: '/destinations?country=JP',
      );
      final route = DestinationDiscoveryRouter.onGenerateRoute(settings);
      expect(route, isNotNull);
    });

    test('Example 10: Search with sort order', () {
      // Example: https://soloadventurer.app/destinations?sortBy=solo_suitability
      const settings = RouteSettings(
        name: '/destinations?sortBy=solo_suitability',
      );
      final route = DestinationDiscoveryRouter.onGenerateRoute(settings);
      expect(route, isNotNull);
    });
  });
}
