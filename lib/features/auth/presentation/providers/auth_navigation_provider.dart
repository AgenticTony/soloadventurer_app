import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter/material.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_notifier_provider.dart';
import 'package:soloadventurer/features/auth/presentation/state/auth_navigation_state.dart';
import 'package:soloadventurer/features/profile/presentation/routes/profile_routes.dart';
import 'package:soloadventurer/features/auth/presentation/routes/auth_routes.dart';
import 'package:soloadventurer/features/safety/presentation/routes/safety_routes.dart';
import '../../domain/services/token_manager.dart';

part 'auth_navigation_provider.g.dart';

/// Provider for handling auth-related navigation state
///
/// Uses Riverpod 3.0 @riverpod annotation with Notifier pattern.
/// Monitors auth state changes and handles navigation accordingly.
@riverpod
class AuthNavigation extends _$AuthNavigation {
  /// Get the current route
  String getCurrentRoute() {
    return state.currentRequest?.route ?? '/';
  }

  @override
  AuthNavigationState build() {
    // Listen to auth state changes
    ref.listen(authNotifierProvider, (previous, next) {
      final authState = next.value;
      if (authState == null) return;

      debugPrint('AuthNavigation: Auth state changed');
      debugPrint('AuthNavigation: Previous state: $previous');
      debugPrint('AuthNavigation: Next state: $authState');

      // Only navigate if we're not already on the target route
      final currentRoute = getCurrentRoute();

      // Email verification takes highest priority
      if (authState.requiresEmailVerification) {
        debugPrint('AuthNavigation: User needs verification');
        if (currentRoute != AuthRoutes.verifyEmail) {
          debugPrint('AuthNavigation: Navigating to verify email');
          navigateToVerification(authState.user?.email);
        } else {
          debugPrint('AuthNavigation: Already on verify email screen');
        }
        return; // Early return to prevent other navigation
      }

      // Password reset takes second priority
      if (authState.requiresPasswordReset) {
        debugPrint('AuthNavigation: Password reset required');
        if (currentRoute != AuthRoutes.confirmPasswordReset) {
          debugPrint('AuthNavigation: Navigating to confirm password reset');
          navigateToConfirmPasswordReset(authState.user?.email ?? '');
        } else {
          debugPrint(
              'AuthNavigation: Already on confirm password reset screen');
        }
        return; // Early return to prevent other navigation
      }

      // Only handle login/home navigation if no special states are active
      if (!authState.requiresEmailVerification &&
          !authState.requiresPasswordReset) {
        if (authState.isAuthenticated) {
          debugPrint('AuthNavigation: User is logged in, navigating to home');
          navigateToHome();
        } else {
          debugPrint(
              'AuthNavigation: User is not logged in, navigating to login');
          navigateToLogin(null);
        }
      }
    });

    // Listen to token manager state changes
    ref.listen(tokenManagerProvider, (previous, next) {
      if (next == FeatureAvailability.unauthorized) {
        _handleUnauthorized();
      }
    });

    return AuthNavigationState.initial();
  }

  /// Handle unauthorized state
  void _handleUnauthorized() {
    debugPrint('AuthNavigation: Handling unauthorized state');
    navigateToLogin(null);
  }

  /// Navigate to confirm password reset screen
  void navigateToConfirmPasswordReset(String email) {
    debugPrint(
        'AuthNavigation: Navigating to confirm password reset with email: $email');
    navigateTo(
      AuthRoutes.confirmPasswordReset,
      arguments: {'email': email},
    );
  }

  /// Check if navigation to a route is allowed
  bool _canNavigate(String route) {
    final authState = ref.read(authNotifierProvider).valueOrNull;
    if (authState == null) return false;

    switch (route) {
      case AuthRoutes.home:
        if (!authState.isAuthenticated) {
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
              'AuthNavigation: Blocking navigation to $route - email verification required');
          return false;
        }
        // Allow navigation to auth screens if not logged in
        if (!authState.isAuthenticated) return true;
        _setNavigationError('Already authenticated');
        return false;

      default:
        return true;
    }
  }

  /// Set navigation error
  void _setNavigationError(String message) {
    debugPrint('AuthNavigation: Setting error: $message');
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
        'AuthNavigation: Requesting navigation to $route with arguments: $arguments');

    // Clear any previous errors
    clearError();

    // Special handling for confirm password reset
    if (route == AuthRoutes.confirmPasswordReset) {
      debugPrint('AuthNavigation: Handling confirm password reset navigation');
      final email = arguments?['email'] as String?;
      if (email == null || email.isEmpty) {
        debugPrint('AuthNavigation: No email provided for password reset');
        // Instead of setting an error, just return without navigation
        return;
      }
    }

    // Check if navigation is allowed
    if (!_canNavigate(route)) {
      debugPrint('AuthNavigation: Navigation not allowed to $route');
      return;
    }

    // Run pre-navigation middleware
    _beforeNavigation(route, arguments);

    try {
      final request = AuthNavigationRequest(
        route: route,
        arguments: arguments,
      );

      debugPrint('AuthNavigation: Creating navigation request: $request');
      state = state.copyWith(
        currentRequest: request,
        history: [...state.history, request],
        error: null, // Clear any previous errors
      );
      debugPrint('AuthNavigation: New state after navigation: $state');

      // Run post-navigation middleware
      _afterNavigation(route);
    } catch (e) {
      debugPrint('AuthNavigation: Navigation failed: $e');
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

  // Safety feature navigation methods

  /// Navigate to safety hub screen
  void navigateToSafetyHub() {
    navigateTo(SafetyRoutes.safetyHub);
  }

  /// Navigate to trusted contacts screen
  void navigateToTrustedContacts() {
    navigateTo(SafetyRoutes.trustedContacts);
  }

  /// Navigate to add trusted contact screen
  void navigateToAddTrustedContact() {
    navigateTo(SafetyRoutes.addEditTrustedContact);
  }

  /// Navigate to edit trusted contact screen
  void navigateToEditTrustedContact(dynamic contact) {
    navigateTo(
      SafetyRoutes.editTrustedContact,
      arguments: {'contact': contact},
    );
  }

  /// Navigate to check-in home screen
  void navigateToCheckInHome() {
    navigateTo(SafetyRoutes.checkInHome);
  }

  /// Navigate to manual check-in screen
  void navigateToManualCheckIn({dynamic checkIn}) {
    navigateTo(
      SafetyRoutes.manualCheckIn,
      arguments: {'checkIn': checkIn},
    );
  }

  /// Navigate to schedule check-in screen
  void navigateToScheduleCheckIn({String? tripId}) {
    navigateTo(
      SafetyRoutes.scheduleCheckIn,
      arguments: {'tripId': tripId},
    );
  }

  /// Navigate to check-in history screen
  void navigateToCheckInHistory() {
    navigateTo(SafetyRoutes.checkInHistory);
  }

  /// Navigate to emergency SOS screen
  void navigateToEmergencySOS() {
    navigateTo(SafetyRoutes.emergencySOS);
  }

  /// Navigate to status update screen
  void navigateToStatusUpdate({String? initialStatus}) {
    navigateTo(
      SafetyRoutes.statusUpdate,
      arguments: {'initialStatus': initialStatus},
    );
  }

  /// Navigate to location sharing screen
  void navigateToLocationSharing() {
    navigateTo(SafetyRoutes.locationSharing);
  }
}

/// Global navigator key for handling navigation from providers
@riverpod
GlobalKey<NavigatorState> navigatorKey(NavigatorKeyRef ref) {
  return GlobalKey<NavigatorState>();
}
