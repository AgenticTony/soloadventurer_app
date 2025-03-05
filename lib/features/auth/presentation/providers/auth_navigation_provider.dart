import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_provider.dart';
import 'package:soloadventurer/features/auth/presentation/state/auth_navigation_state.dart';
import 'package:soloadventurer/features/profile/presentation/routes/profile_routes.dart';

/// Provider for handling auth-related navigation state
final authNavigationProvider =
    StateNotifierProvider<AuthNavigationNotifier, AuthNavigationState>((ref) {
  return AuthNavigationNotifier(ref);
});

/// Constants for auth navigation routes
class AuthRoutes {
  static const verifyEmail = '/verify-email';
  static const login = '/login';
  static const signup = '/signup';
  static const home = '/home';
  static const forgotPassword = '/forgot-password';
}

/// Notifier for handling auth-related navigation
class AuthNavigationNotifier extends StateNotifier<AuthNavigationState> {
  final Ref _ref;

  /// Creates a new [AuthNavigationNotifier]
  AuthNavigationNotifier(this._ref) : super(AuthNavigationState.initial()) {
    // Listen to auth state changes
    _ref.listen(authProvider, (previous, next) {
      if (next.needsVerification && next.user != null) {
        navigateToVerification(next.user?.email);
      }
    });
  }

  /// Check if navigation to a route is allowed
  bool _canNavigate(String route) {
    final authState = _ref.read(authProvider);

    switch (route) {
      case AuthRoutes.home:
        if (!authState.isAuthenticated) {
          _setNavigationError('Authentication required to access home');
          return false;
        }
        return true;

      case AuthRoutes.verifyEmail:
        if (!authState.needsVerification) {
          _setNavigationError('No verification needed');
          return false;
        }
        return true;

      case AuthRoutes.login:
      case AuthRoutes.signup:
      case AuthRoutes.forgotPassword:
        if (authState.isAuthenticated) {
          _setNavigationError('Already authenticated');
          return false;
        }
        return true;

      default:
        return true;
    }
  }

  /// Set navigation error
  void _setNavigationError(String message) {
    state = state.copyWith(error: message);
    print('[Navigation Debug] Error: $message');
  }

  /// Clear navigation error
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  /// Pre-navigation middleware
  void _beforeNavigation(String route, Map<String, dynamic>? arguments) {
    print(
        '[Navigation Debug] Before navigation to $route with arguments: $arguments');
    state = state.copyWith(isNavigating: true);
  }

  /// Post-navigation middleware
  void _afterNavigation(String route, {bool success = true}) {
    print('[Navigation Debug] After navigation to $route (success: $success)');
    state = state.copyWith(isNavigating: false);
  }

  /// Navigate to verification screen
  void navigateToVerification(String? email) {
    print('[Navigation Debug] Requesting navigation to verification screen');
    navigateTo(
      AuthRoutes.verifyEmail,
      arguments: {'email': email},
    );
  }

  /// Navigate to login screen
  void navigateToLogin() {
    navigateTo(AuthRoutes.login);
  }

  /// Navigate to signup screen
  void navigateToSignup() {
    navigateTo(AuthRoutes.signup);
  }

  /// Navigate to home screen
  void navigateToHome() {
    navigateTo(AuthRoutes.home);
  }

  /// Navigate to forgot password screen
  void navigateToForgotPassword() {
    navigateTo(AuthRoutes.forgotPassword);
  }

  /// Navigate to profile edit screen
  void navigateToProfileEdit({bool isInitialSetup = false}) {
    navigateTo(
      ProfileRoutes.editProfile,
      arguments: {'isInitialSetup': isInitialSetup},
    );
  }

  /// Request navigation to a specific route (internal use)
  void navigateTo(String route, {Map<String, dynamic>? arguments}) {
    print(
        '[Navigation Debug] Requesting navigation to $route with arguments: $arguments');

    // Clear any previous errors
    clearError();

    // Check if navigation is allowed
    if (!_canNavigate(route)) {
      return;
    }

    // Run pre-navigation middleware
    _beforeNavigation(route, arguments);

    try {
      final request = AuthNavigationRequest(
        route: route,
        arguments: arguments,
      );

      state = state.copyWith(
        currentRequest: request,
        history: [...state.history, request],
      );

      // Run post-navigation middleware
      _afterNavigation(route);
    } catch (e) {
      _setNavigationError('Failed to navigate: ${e.toString()}');
      _afterNavigation(route, success: false);
    }
  }

  /// Mark the current navigation request as handled
  void markCurrentRequestHandled() {
    print('[Navigation Debug] Marking current request as handled');
    if (state.currentRequest == null) return;

    final handledRequest = state.currentRequest!.copyWith(handled: true);
    state = state.copyWith(
      currentRequest: handledRequest,
      history: [
        ...state.history.sublist(0, state.history.length - 1),
        handledRequest
      ],
    );
  }

  /// Request back navigation
  void navigateBack() {
    print('[Navigation Debug] Requesting back navigation');
    if (state.history.isEmpty) {
      _setNavigationError('No previous route to navigate back to');
      return;
    }

    // Get the previous route from history
    final previousRequests =
        state.history.where((request) => !request.isBack).toList();

    if (previousRequests.length < 2) {
      _setNavigationError('No previous route to navigate back to');
      return;
    }

    final previousRequest = previousRequests[previousRequests.length - 2];

    // Check if we can navigate to the previous route
    if (!_canNavigate(previousRequest.route)) {
      return;
    }

    // Run pre-navigation middleware
    _beforeNavigation(previousRequest.route, previousRequest.arguments);

    try {
      final backRequest = AuthNavigationRequest(
        route: previousRequest.route,
        arguments: previousRequest.arguments,
        isBack: true,
      );

      state = state.copyWith(
        currentRequest: backRequest,
        history: [...state.history, backRequest],
      );

      // Run post-navigation middleware
      _afterNavigation(previousRequest.route);
    } catch (e) {
      _setNavigationError('Failed to navigate back: ${e.toString()}');
      _afterNavigation(previousRequest.route, success: false);
    }
  }

  /// Clear the current navigation request
  void clearCurrentRequest() {
    print('[Navigation Debug] Clearing current request');
    state = state.copyWith(currentRequest: null);
  }

  /// Get the current route
  String? getCurrentRoute() {
    return state.currentRequest?.route;
  }

  /// Check if there's a pending navigation request
  bool hasPendingRequest() {
    return state.currentRequest != null && !state.currentRequest!.handled;
  }
}
