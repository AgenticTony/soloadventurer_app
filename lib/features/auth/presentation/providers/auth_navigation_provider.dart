import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_provider.dart';
import 'package:soloadventurer/features/auth/presentation/screens/verify_email_screen.dart';

/// Provider for handling auth-related navigation
final authNavigationProvider = Provider.autoDispose((ref) {
  return AuthNavigationNotifier(ref);
});

/// Notifier for handling auth-related navigation
class AuthNavigationNotifier {
  final Ref _ref;

  /// Creates a new [AuthNavigationNotifier]
  AuthNavigationNotifier(this._ref) {
    // Listen to auth state changes
    _ref.listen(authProvider, (previous, next) {
      if (next.needsVerification && next.user != null) {
        _handleVerificationNeeded(next.user?.email);
      }
    });
  }

  /// Navigate to verification screen when needed
  void _handleVerificationNeeded(String? email) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final context = _ref.read(navigatorKeyProvider).currentContext;
      if (context != null) {
        // Use pushReplacement to avoid stacking screens
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const VerifyEmailScreen(),
            settings: RouteSettings(
              name: '/verify-email',
              arguments: {
                'email': email,
                'preserveState':
                    true, // Flag to indicate state should be preserved
              },
            ),
          ),
        );
      }
    });
  }
}

/// Provider for the global navigator key
final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>();
});
