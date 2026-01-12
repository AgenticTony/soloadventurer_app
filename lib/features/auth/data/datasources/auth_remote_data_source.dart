import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:soloadventurer/features/auth/data/models/user_model.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:soloadventurer/features/auth/data/models/auth_tokens.dart';
import 'package:soloadventurer/features/auth/data/models/credentials.dart';

/// Remote data source for authentication operations
abstract class AuthRemoteDataSource {
  /// Register a new user
  Future<(UserModel, bool)> register({
    required String email,
    required String password,
    required String name,
  });

  /// Sign in with email and password
  /// Returns a tuple of (UserModel, AuthSession) with complete session data
  Future<(UserModel, AuthSession)> signIn(String email, String password);

  /// Sign out the current user
  Future<void> signOut();

  /// Get the current user
  Future<UserModel?> getCurrentUser();

  /// Check if a user is signed in
  Future<bool> isSignedIn();

  /// Refresh the authentication token
  Future<AuthSession> refreshToken();

  /// Verify email with confirmation code
  Future<void> verifyEmail(String code, String email);

  /// Resend verification email
  Future<void> resendVerificationEmail();

  /// Request a password reset for a user
  Future<void> forgotPassword(String email);

  /// Complete the password reset process
  Future<void> confirmForgotPassword(
      String email, String code, String newPassword);

  /// Admin API to set a user's password (temporary or permanent)
  Future<void> adminSetUserPassword(String email, String newPassword,
      {bool permanent = false});

  /// Admin API to initiate password reset
  Future<void> adminResetUserPassword(String email);

  /// Send password reset instructions via email
  Future<void> sendPasswordResetEmail(String email);

  /// Refreshes the authentication tokens using a refresh token
  /// Throws a [ServerException] if the refresh fails
  Future<AuthTokens> refreshTokenWithString(String refreshToken);

  /// Re-authenticates the user with their credentials
  /// Throws a [ServerException] if authentication fails
  Future<AuthTokens> reauthenticate(Credentials credentials);

  // ============================================================
  // MULTI-FACTOR AUTHENTICATION (MFA) - Supabase only
  // ============================================================

  /// Setup MFA for the current user
  ///
  /// Returns a tuple containing:
  /// - factorId: The ID of the enrolled factor
  /// - qrCode: SVG QR code for scanning with authenticator app
  /// - secret: The TOTP secret for manual entry
  Future<(String factorId, String qrCode, String secret)> setupMFA();

  /// Verify MFA code during setup or login
  ///
  /// Parameters:
  /// - code: The 6-digit TOTP code from authenticator app
  /// - factorId: The ID of the factor to verify (optional during login)
  ///
  /// Returns true if verification successful
  Future<bool> verifyMFA(String code, {String? factorId});

  /// Disable MFA for the current user
  ///
  /// Parameters:
  /// - factorId: The ID of the factor to disable
  Future<void> disableMFA(String factorId);

  /// List all enrolled MFA factors for the current user
  ///
  /// Returns a list of factor IDs that the user has enrolled
  Future<List<String>> listMFAFactors();

  // ============================================================
  // ACCOUNT MANAGEMENT
  // ============================================================

  /// Delete the current user's account
  ///
  /// Note: For Supabase, this requires calling an Edge Function
  /// since admin privileges (service role key) are needed.
  Future<void> deleteAccount();
}
