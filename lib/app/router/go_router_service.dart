import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Service for programmatic navigation using go_router
///
/// This service provides methods to navigate programmatically from
/// providers, services, or other non-UI code that doesn't have access
/// to BuildContext.
class GoRouterService {
  /// The global navigator key for accessing the navigation state
  final GlobalKey<NavigatorState> navigatorKey;

  /// Creates a new [GoRouterService]
  GoRouterService({required this.navigatorKey});

  /// Get the GoRouter from the current context
  GoRouter? get _router {
    final context = navigatorKey.currentContext;
    if (context == null) return null;
    return GoRouter.of(context);
  }

  /// Navigate to a new location
  void go(String location, {Object? extra}) {
    _router?.go(location, extra: extra);
  }

  /// Push a new location onto the navigation stack
  Future<void> push(String location, {Object? extra}) async {
    await _router?.push(location, extra: extra);
  }

  /// Replace the current location
  void replace(String location, {Object? extra}) {
    _router?.replace(location, extra: extra);
  }

  /// Pop the current location
  void pop<T extends Object?>([T? result]) {
    _router?.pop(result);
  }

  /// Get the current location
  String? get currentLocation => _router?.state.matchedLocation;

  /// Check if we can pop
  bool canPop() => _router?.canPop() ?? false;
}
