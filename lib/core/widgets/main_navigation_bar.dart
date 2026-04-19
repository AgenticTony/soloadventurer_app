import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Main bottom navigation bar for the app
///
/// Provides navigation between the main sections:
/// - Home
/// - Connections (matching)
/// - Journal
/// - Destinations
/// - Safety
/// - Profile
class MainNavigationBar extends StatelessWidget {
  const MainNavigationBar({
    super.key,
    required this.child,
  });

  final Widget child;

  /// Navigation destinations for the bottom nav bar
  static const List<NavigationDestination> destinations = [
    NavigationDestination(
      icon: Icon(Icons.home_outlined),
      selectedIcon: Icon(Icons.home),
      label: 'Home',
    ),
    NavigationDestination(
      icon: Icon(Icons.people_outline),
      selectedIcon: Icon(Icons.people),
      label: 'Connect',
    ),
    NavigationDestination(
      icon: Icon(Icons.book_outlined),
      selectedIcon: Icon(Icons.book),
      label: 'Journal',
    ),
    NavigationDestination(
      icon: Icon(Icons.explore_outlined),
      selectedIcon: Icon(Icons.explore),
      label: 'Discover',
    ),
    NavigationDestination(
      icon: Icon(Icons.shield_outlined),
      selectedIcon: Icon(Icons.shield),
      label: 'Safety',
    ),
    NavigationDestination(
      icon: Icon(Icons.person_outlined),
      selectedIcon: Icon(Icons.person),
      label: 'Profile',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: child,
      bottomNavigationBar: NavigationBar(
        destinations: destinations,
        selectedIndex: _calculateSelectedIndex(context),
        onDestinationSelected: (index) {
          _handleDestinationSelected(context, index);
        },
        height: 65,
      ),
    );
  }

  /// Calculate the currently selected index based on the current route
  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;

    // Map routes to indices
    if (location.startsWith('/home') || location == '/') {
      return 0;
    } else if (location.startsWith('/connect')) {
      return 1;
    } else if (location.startsWith('/journal')) {
      return 2;
    } else if (location.startsWith('/destinations')) {
      return 3;
    } else if (location.startsWith('/safety')) {
      return 4;
    } else if (location.startsWith('/profile')) {
      return 5;
    }

    // Default to home
    return 0;
  }

  /// Handle when a destination is selected
  void _handleDestinationSelected(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go('/home');
        break;
      case 1:
        context.go('/connect');
        break;
      case 2:
        context.go('/journal');
        break;
      case 3:
        context.go('/destinations');
        break;
      case 4:
        context.go('/safety');
        break;
      case 5:
        context.go('/profile');
        break;
    }
  }
}
