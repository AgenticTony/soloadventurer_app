import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/domain/providers/auth_providers.dart';
import 'package:soloadventurer/features/auth/presentation/state/auth_navigation_state.dart';
import 'package:soloadventurer/features/profile/presentation/routes/profile_routes.dart';
import 'package:soloadventurer/features/auth/presentation/routes/auth_routes.dart';
import 'package:flutter/material.dart';
import '../../domain/services/token_manager.dart';

/// Provider for handling auth-related navigation state
final authNavigationProvider =
    StateNotifierProvider<AuthNavigationNotifier, AuthNavigationState>((ref) {
  return AuthNavigationNotifier(ref);
});

/// Notifier for handling auth-related navigation
class AuthNavigationNotifier extends StateNotifier<AuthNavigationState> {
  final Ref _ref;

  /// Creates a new [AuthNavigationNotifier]
  AuthNavigationNotifier(this._ref) : super(AuthNavigationState.initial()) {
    // Listen to auth state changes
    _ref.listen(authStateProvider, (previous, next) {
      debugPrint('AuthNavigationNotifier: Auth state changed');
      debugPrint('AuthNavigationNotifier: Previous state: $previous');
      debugPrint('AuthNavigationNotifier: Next state: $next');

      // Only navigate if we're not already on the target route
      final currentRoute = getCurrentRoute();

      // Email verification takes highest priority
      if (next.requiresEmailVerification) {
        debugPrint('AuthNavigationNotifier: User needs verification');
        if (currentRoute != AuthRoutes.verifyEmail) {
          debugPrint('AuthNavigationNotifier: Navigating to verify email');
          navigateToVerification(next.user?.email);
        } else {
          debugPrint('AuthNavigationNotifier: Already on verify email screen');
        }
        return; // Early return to prevent other navigation
      }

      // Password reset takes second priority
      if (next.requiresPasswordReset) {
        debugPrint('AuthNavigationNotifier: Password reset required');
        if (currentRoute != AuthRoutes.confirmPasswordReset) {
          debugPrint(
              'AuthNavigationNotifier: Navigating to confirm password reset');
          navigateToConfirmPasswordReset(next.user?.email ?? '');
        } else {
          debugPrint(
              'AuthNavigationNotifier: Already on confirm password reset screen');
        }
        return; // Early return to prevent other navigation
      }

      // Only handle login/home navigation if no special states are active
      if (!next.requiresEmailVerification && !next.requiresPasswordReset) {
        if (next.isLoggedIn) {
          debugPrint(
              'AuthNavigationNotifier: User is logged in, navigating to home');
          navigateToHome();
        } else {
          debugPrint(
              'AuthNavigationNotifier: User is not logged in, navigating to login');
          navigateToLogin(null);
        }
      }
    });

    // Listen to token manager state changes
    _ref.listen(tokenManagerProvider, (previous, next) {
      if (next == FeatureAvailability.unauthorized) {
        _handleUnauthorized();
      }
    });
  }

  /// Get the current route
  String getCurrentRoute() {
    return state.currentRequest?.route ?? '/';
  }

  /// Handle unauthorized state
  void _handleUnauthorized() {
    debugPrint('AuthNavigationNotifier: Handling unauthorized state');
    navigateToLogin(null);
  }

  /// Navigate to confirm password reset screen
  void navigateToConfirmPasswordReset(String email) {
    debugPrint(
        'AuthNavigationNotifier: Navigating to confirm password reset with email: $email');
    navigateTo(
      AuthRoutes.confirmPasswordReset,
      arguments: {'email': email},
    );
  }

  /// Check if navigation to a route is allowed
  bool _canNavigate(String route) {
    final authState = _ref.read(authStateProvider);

    switch (route) {
      case AuthRoutes.home:
        if (!authState.isLoggedIn) {
          _setNavigationError('Authentication required to access home');
          return false;
        }
        return true;

      case AuthRoutes.verifyEmail:
        // Always allow navigation to verify email if verification is required
        if (authState.requiresEmailVerification) return true;
        // Also allow if we have a user that needs verification
        if (authState.user != null) return true;
        return false;

      case AuthRoutes.login:
      case AuthRoutes.signup:
      case AuthRoutes.forgotPassword:
        // Block navigation to auth screens if user needs verification
        if (authState.requiresEmailVerification) {
          debugPrint(
              'AuthNavigationNotifier: Blocking navigation to $route - email verification required');
          return false;
        }
        // Allow navigation to auth screens if not logged in
        if (!authState.isLoggedIn) return true;
        _setNavigationError('Already authenticated');
        return false;

      default:
        return true;
    }
  }

  /// Set navigation error
  void _setNavigationError(String message) {
    debugPrint('AuthNavigationNotifier: Setting error: $message');
    // Only set the error if it's different from the current error
    if (state.error != message) {
      state = state.copyWith(error: message);
    }
  }

  /// Clear navigation error
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }

  /// Pre-navigation middleware
  void _beforeNavigation(String route, Map<String, dynamic>? arguments) {
    state = state.copyWith(isNavigating: true);
  }

  /// Post-navigation middleware
  void _afterNavigation(String route, {bool success = true}) {
    state = state.copyWith(isNavigating: false);
  }

  /// Navigate to verification screen
  void navigateToVerification(String? email) {
    navigateTo(
      AuthRoutes.verifyEmail,
      arguments: {'email': email},
    );
  }

  /// Navigate to login screen
  void navigateToLogin(BuildContext? context) {
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

  /// Navigate to profile screen
  void navigateToProfile() {
    navigateTo(ProfileRoutes.profile);
  }

  /// Request navigation to a specific route (internal use)
  void navigateTo(String route, {Map<String, dynamic>? arguments}) {
    debugPrint(
        'AuthNavigationNotifier: Requesting navigation to $route with arguments: $arguments');

    // Clear any previous errors
    clearError();

    // Special handling for confirm password reset
    if (route == AuthRoutes.confirmPasswordReset) {
      debugPrint(
          'AuthNavigationNotifier: Handling confirm password reset navigation');
      final email = arguments?['email'] as String?;
      if (email == null || email.isEmpty) {
        debugPrint(
            'AuthNavigationNotifier: No email provided for password reset');
        // Instead of setting an error, just return without navigation
        return;
      }
    }

    // Check if navigation is allowed
    if (!_canNavigate(route)) {
      debugPrint('AuthNavigationNotifier: Navigation not allowed to $route');
      return;
    }

    // Run pre-navigation middleware
    _beforeNavigation(route, arguments);

    try {
      final request = AuthNavigationRequest(
        route: route,
        arguments: arguments,
      );

      debugPrint(
          'AuthNavigationNotifier: Creating navigation request: $request');
      state = state.copyWith(
        currentRequest: request,
        history: [...state.history, request],
        error: null, // Clear any previous errors
      );
      debugPrint('AuthNavigationNotifier: New state after navigation: $state');

      // Run post-navigation middleware
      _afterNavigation(route);
    } catch (e) {
      debugPrint('AuthNavigationNotifier: Navigation failed: $e');
      _setNavigationError('Failed to navigate: ${e.toString()}');
      // Run post-navigation middleware with failure status
      _afterNavigation(route, success: false);
    }
  }

  /// Mark the current navigation request as handled
  void markCurrentRequestHandled() {
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
    if (state.history.isEmpty) {
      return;
    }

    final previousRequest = state.history[state.history.length - 2];
    navigateTo(previousRequest.route, arguments: previousRequest.arguments);
  }
}

/// Global navigator key for handling navigation from providers
final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>();
});
