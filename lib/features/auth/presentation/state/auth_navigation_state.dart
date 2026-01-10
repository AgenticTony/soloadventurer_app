import 'package:equatable/equatable.dart';

/// Represents a navigation request in the auth flow
class AuthNavigationRequest extends Equatable {
  /// The route to navigate to
  final String route;

  /// Arguments to pass to the route
  final Map<String, dynamic>? arguments;

  /// Whether this navigation request has been handled
  final bool handled;

  /// Whether this is a back navigation request
  final bool isBack;

  /// Creates a new [AuthNavigationRequest]
  const AuthNavigationRequest({
    required this.route,
    this.arguments,
    this.handled = false,
    this.isBack = false,
  });

  /// Creates a copy of this request with the given fields replaced
  AuthNavigationRequest copyWith({
    String? route,
    Map<String, dynamic>? arguments,
    bool? handled,
    bool? isBack,
  }) {
    return AuthNavigationRequest(
      route: route ?? this.route,
      arguments: arguments ?? this.arguments,
      handled: handled ?? this.handled,
      isBack: isBack ?? this.isBack,
    );
  }

  @override
  List<Object?> get props => [route, arguments, handled, isBack];

  @override
  String toString() {
    return 'AuthNavigationRequest{route: $route, arguments: $arguments, handled: $handled, isBack: $isBack}';
  }
}

/// Represents the current state of auth navigation
class AuthNavigationState extends Equatable {
  /// The current navigation request, if any
  final AuthNavigationRequest? currentRequest;

  /// The navigation history
  final List<AuthNavigationRequest> history;

  /// Any error that occurred during navigation
  final String? error;

  /// Whether navigation is in progress
  final bool isNavigating;

  /// Creates a new [AuthNavigationState]
  const AuthNavigationState({
    this.currentRequest,
    this.history = const [],
    this.error,
    this.isNavigating = false,
  });

  /// Initial navigation state
  factory AuthNavigationState.initial() => const AuthNavigationState();

  /// Creates a copy of this state with the given fields replaced
  AuthNavigationState copyWith({
    AuthNavigationRequest? currentRequest,
    List<AuthNavigationRequest>? history,
    String? error,
    bool? isNavigating,
  }) {
    return AuthNavigationState(
      currentRequest: currentRequest ?? this.currentRequest,
      history: history ?? this.history,
      error: error ?? this.error,
      isNavigating: isNavigating ?? this.isNavigating,
    );
  }

  @override
  List<Object?> get props => [currentRequest, history, error, isNavigating];

  @override
  String toString() {
    return 'AuthNavigationState{currentRequest: $currentRequest, historyLength: ${history.length}, error: $error, isNavigating: $isNavigating}';
  }
}
