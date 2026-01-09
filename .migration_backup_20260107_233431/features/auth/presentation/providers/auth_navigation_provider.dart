import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/app/router/go_router_service.dart';
import 'package:soloadventurer/features/auth/presentation/state/auth_navigation_state.dart';

part 'auth_navigation_provider.g.dart';

/// Provider for GoRouterService (kept for DI compatibility)
@Riverpod(keepAlive: true)
GoRouterService goRouterService(Ref ref) {
  throw UnimplementedError('goRouterServiceProvider must be overridden');
}

/// Notifier for handling auth-related navigation
///
/// This notifier provides convenience methods for navigating to various
/// screens in the app. With go_router, auth redirects are handled automatically,
/// so this class focuses on programmatic navigation from UI elements.
///
/// With go_router, most auth navigation is handled automatically by the
/// router's redirect logic. This provider now serves as a convenience
/// layer for programmatic navigation from UI elements and providers.
@riverpod
class AuthNavigationNotifier extends _$AuthNavigationNotifier {
  @override
  AuthNavigationState build() {
    final goRouterService = ref.watch(goRouterServiceProvider);
    _router = goRouterService;
    return AuthNavigationState.initial();
  }

  late final GoRouterService _router;

  // ============================================================
  // AUTH ROUTES
  // ============================================================

  /// Navigate to login screen
  void navigateToLogin() {
    _router.go('/login');
  }

  /// Navigate to signup screen
  void navigateToSignup() {
    _router.go('/signup');
  }

  /// Navigate to home screen
  void navigateToHome() {
    _router.go('/home');
  }

  /// Navigate to forgot password screen
  void navigateToForgotPassword() {
    _router.go('/forgot-password');
  }

  /// Navigate to verify email screen
  void navigateToVerification(String? email) {
    final query = email != null ? '?email=$email' : '';
    _router.go('/verify-email$query');
  }

  /// Navigate to confirm password reset screen
  void navigateToConfirmPasswordReset(String email) {
    _router.go('/confirm-password-reset?email=$email');
  }

  // ============================================================
  // PROFILE ROUTES
  // ============================================================

  /// Navigate to profile screen
  void navigateToProfile() {
    _router.go('/profile');
  }

  /// Navigate to profile edit screen
  void navigateToProfileEdit({bool isInitialSetup = false}) {
    final query = isInitialSetup ? '?isInitialSetup=true' : '';
    _router.go('/edit-profile$query');
  }

  // ============================================================
  // SAFETY ROUTES
  // ============================================================

  /// Navigate to safety hub screen
  void navigateToSafetyHub() {
    _router.go('/safety');
  }

  /// Navigate to trusted contacts screen
  void navigateToTrustedContacts() {
    _router.go('/safety/trusted-contacts');
  }

  /// Navigate to add trusted contact screen
  void navigateToAddTrustedContact() {
    _router.push('/safety/trusted-contacts/add');
  }

  /// Navigate to edit trusted contact screen
  void navigateToEditTrustedContact(dynamic contact) {
    _router.push('/safety/trusted-contacts/edit', extra: contact);
  }

  /// Navigate to check-in home screen
  void navigateToCheckInHome() {
    _router.go('/safety/check-ins');
  }

  /// Navigate to manual check-in screen
  void navigateToManualCheckIn({dynamic checkIn}) {
    _router.push('/safety/check-ins/manual', extra: checkIn);
  }

  /// Navigate to schedule check-in screen
  void navigateToScheduleCheckIn({String? tripId}) {
    final query = tripId != null ? '?tripId=$tripId' : '';
    _router.push('/safety/check-ins/schedule$query');
  }

  /// Navigate to check-in history screen
  void navigateToCheckInHistory() {
    _router.push('/safety/check-ins/history');
  }

  /// Navigate to emergency SOS screen
  void navigateToEmergencySOS() {
    _router.go('/safety/emergency');
  }

  /// Navigate to status update screen
  void navigateToStatusUpdate({String? initialStatus}) {
    final query = initialStatus != null ? '?initialStatus=$initialStatus' : '';
    _router.push('/safety/status-update$query');
  }

  /// Navigate to location sharing screen
  void navigateToLocationSharing() {
    _router.go('/safety/location-sharing');
  }

  // ============================================================
  // UTILITY METHODS
  // ============================================================

  /// Navigate back
  void navigateBack() {
    _router.pop();
  }

  /// Get the current route
  String? getCurrentRoute() {
    return _router.currentLocation;
  }

  /// Clear any navigation errors
  void clearError() {
    if (state.error != null) {
      state = state.copyWith(error: null);
    }
  }
}
