import 'package:flutter/material.dart';

class ProfileRouteAnalytics {
  static final List<RouteEvent> _events = [];
  static bool _isEnabled = true;

  static List<RouteEvent> get events => List.unmodifiable(_events);
  static bool get isEnabled => _isEnabled;

  static void enable() => _isEnabled = true;
  static void disable() => _isEnabled = false;
  static void clearEvents() => _events.clear();

  static void trackRouteChange(RouteEvent event) {
    if (!_isEnabled) return;
    _events.add(event);
    _logEvent(event);
  }

  static void _logEvent(RouteEvent event) {
    // For now, just log the event using debugPrint
    debugPrint('ROUTE EVENT: ${event.toString()}');
  }
}

class RouteEvent {
  final String routeName;
  final String? previousRoute;
  final DateTime timestamp;
  final Map<String, dynamic>? parameters;
  final Duration? duration;
  final bool isError;
  final String? errorMessage;

  RouteEvent({
    required this.routeName,
    this.previousRoute,
    DateTime? timestamp,
    this.parameters,
    this.duration,
    this.isError = false,
    this.errorMessage,
  }) : timestamp = timestamp ?? DateTime.now();

  @override
  String toString() {
    final buffer = StringBuffer();
    buffer.write('Route: $routeName');
    if (previousRoute != null) {
      buffer.write(' from: $previousRoute');
    }
    if (parameters != null && parameters!.isNotEmpty) {
      buffer.write(' params: $parameters');
    }
    if (duration != null) {
      buffer.write(' duration: ${duration!.inMilliseconds}ms');
    }
    if (isError) {
      buffer.write(' error: $errorMessage');
    }
    return buffer.toString();
  }
}

class ProfileRouteObserverWithAnalytics extends NavigatorObserver {
  DateTime? _routeStartTime;
  String? _currentRoute;

  @override
  void didPush(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _trackRouteStart(route, previousRoute);
  }

  @override
  void didReplace({Route<dynamic>? newRoute, Route<dynamic>? oldRoute}) {
    if (newRoute != null) {
      _trackRouteStart(newRoute, oldRoute);
    }
  }

  @override
  void didPop(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _trackRouteEnd(route, previousRoute);
  }

  @override
  void didRemove(Route<dynamic> route, Route<dynamic>? previousRoute) {
    _trackRouteEnd(route, previousRoute);
  }

  void _trackRouteStart(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (route.settings.name == null) return;

    _routeStartTime = DateTime.now();
    _currentRoute = route.settings.name;

    ProfileRouteAnalytics.trackRouteChange(
      RouteEvent(
        routeName: route.settings.name!,
        previousRoute: previousRoute?.settings.name,
        parameters: _extractParameters(route.settings.arguments),
      ),
    );
  }

  void _trackRouteEnd(Route<dynamic> route, Route<dynamic>? previousRoute) {
    if (_currentRoute == null || _routeStartTime == null) return;

    final duration = DateTime.now().difference(_routeStartTime!);
    ProfileRouteAnalytics.trackRouteChange(
      RouteEvent(
        routeName: _currentRoute!,
        previousRoute: previousRoute?.settings.name,
        duration: duration,
      ),
    );

    _routeStartTime = null;
    _currentRoute = null;
  }

  Map<String, dynamic>? _extractParameters(Object? arguments) {
    if (arguments == null) return null;
    if (arguments is Map<String, dynamic>) return arguments;
    return {'argument': arguments.toString()};
  }
}
