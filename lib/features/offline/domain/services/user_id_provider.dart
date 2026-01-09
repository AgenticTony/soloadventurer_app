import 'package:flutter/foundation.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_notifier_provider.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Service for providing the current user ID
///
/// This service abstracts away the details of how to get the current user ID
/// from the auth system, making it easier to mock in tests and change
/// the auth implementation in the future.
class UserIdProvider {
  /// Container for accessing providers
  final ProviderContainer _container;

  /// Creates a new [UserIdProvider]
  ///
  /// The [container] parameter is used to access Riverpod providers.
  /// In production, this will be the app's main container.
  /// In tests, this can be a test container with mocked providers.
  UserIdProvider(this._container);

  /// Gets the current user ID
  ///
  /// Returns the ID of the currently authenticated user, or an empty string
  /// if no user is authenticated.
  ///
  /// This method safely handles cases where:
  /// - No user is authenticated (returns empty string)
  /// - User is not available (returns empty string)
  String getCurrentUserId() {
    try {
      final authState = _container.read(authNotifierProvider);

      // With new AuthState pattern, we directly access fields
      if (authState.isAuthenticated && authState.user != null) {
        return authState.user!.id;
      }
      return '';
    } catch (e) {
      debugPrint('⚠️ Error getting current user ID: $e');
      return '';
    }
  }

  /// Whether there is a currently authenticated user
  bool get hasUser {
    return getCurrentUserId().isNotEmpty;
  }
}
