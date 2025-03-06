import 'package:soloadventurer/features/auth/domain/entities/user.dart';

/// Repository interface for authentication operations
abstract class AuthRepository {
  /// Register a new user with email and password
  Future<(User, bool)> register({
    required String email,
    required String password,
    required String name,
  });

  /// Sign in a user with email and password
  Future<User> signInWithEmailAndPassword(String email, String password);

  /// Sign out the current user
  Future<void> signOut();

  /// Get the current authenticated user
  Future<User?> getCurrentUser();

  /// Check if a user is currently authenticated
  Future<bool> isAuthenticated();

  /// Send password reset instructions via email
  Future<void> sendPasswordResetEmail(String email);

  /// Confirm a password reset with the given code and new password
  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  });

  /// Update the user profile
  Future<User> updateUserProfile({
    String? name,
    String? email,
    String? photoUrl,
  });

  /// Change the user's password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Verify the user's email
  Future<void> verifyEmail(String code, String email);

  /// Resend verification email
  Future<void> resendVerificationEmail();

  /// Enable two-factor authentication
  Future<String> enableTwoFactor();

  /// Disable two-factor authentication
  Future<void> disableTwoFactor(String code);

  /// Verify two-factor authentication
  Future<void> verifyTwoFactor(String code);

  /// Check if the user is signed in
  Future<bool> isSignedIn();

  /// Get the current access token
  Future<String?> getAccessToken();

  /// Refresh the authentication token
  Future<bool> refreshToken();

  /// Register a new user with email and password
  Future<User> registerWithEmailAndPassword(
      String email, String password, String username);
}
