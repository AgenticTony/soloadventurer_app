import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:soloadventurer/features/auth/data/models/user_model.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/auth/data/models/auth_tokens.dart';
import 'package:soloadventurer/features/auth/data/models/credentials.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_remote_data_source.dart';

/// Implementation of [AuthRemoteDataSource] using Supabase Auth
///
/// Official Documentation Verified:
/// - https://supabase.com/docs/guides/getting-started/quickstarts/flutter
/// - https://supabase.com/docs/guides/auth
/// - Package: supabase_flutter ^2.0.0
///
/// Key implementation details based on official docs:
/// - signUp() for user registration
/// - signInWithPassword() for email/password authentication
/// - currentSession provides access to tokens
/// - Session persistence handled by supabase_flutter package
class SupabaseAuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  /// Get the Supabase client instance
  SupabaseClient get client => Supabase.instance.client;

  /// Helper method to convert Supabase User to UserModel
  UserModel _userModelFromUser(User user) {
    return UserModel(
      id: user.id,
      email: user.email ?? '',
      username: user.userMetadata?['name'] as String? ??
          ((user.email?.isNotEmpty ?? false) ? user.email!.split('@')[0] : 'User'),
      createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }

  /// Helper method to convert Supabase Session to AuthSession
  /// Note: Session doesn't have idToken directly, using accessToken as fallback
  AuthSession _authSessionFromSession(Session session) {
    return AuthSession(
      accessToken: session.accessToken,
      idToken: session.accessToken, // Supabase uses accessToken for both
      refreshToken: session.refreshToken ?? '',
      expiresAt: session.expiresAt is DateTime
          ? session.expiresAt as DateTime
          : DateTime.now().add(const Duration(hours: 1)),
    );
  }

  @override
  Future<(UserModel, bool)> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {

      final response = await client.auth.signUp(
        email: email,
        password: password,
        data: {'name': name},
      );

      if (response.user == null) {
        throw AuthException(
          'Registration failed',
          type: AuthErrorType.unknown,
        );
      }

      final user = _userModelFromUser(response.user!);

      // Supabase requires email verification by default
      // The user won't be fully signed in until verified
      final needsVerification = response.session == null;

      return (user, needsVerification);
    } catch (e) {
      throw AuthException(
        'Registration failed: ${e.toString()}',
        type: AuthErrorType.unknown,
      );
    }
  }

  @override
  Future<(UserModel, AuthSession)> signIn(String email, String password) async {
    try {

      final response = await client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.session == null || response.user == null) {
        throw AuthException(
          'Authentication failed',
          type: AuthErrorType.invalidCredentials,
        );
      }

      final user = _userModelFromUser(response.user!);
      final session = _authSessionFromSession(response.session!);

      return (user, session);
    } catch (e) {

      // Map Supabase auth errors to app-specific error types
      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('invalid') ||
          errorStr.contains('not found') ||
          errorStr.contains('wrong')) {
        throw AuthException(
          'Invalid email or password',
          type: AuthErrorType.invalidCredentials,
        );
      } else if (errorStr.contains('email not confirmed') ||
          errorStr.contains('not verified')) {
        throw AuthException(
          'Email not verified. Please check your email for verification instructions.',
          type: AuthErrorType.emailNotVerified,
        );
      }
      throw AuthException(
        'Authentication failed: ${e.toString()}',
        type: AuthErrorType.unknown,
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await client.auth.signOut();
    } catch (e) {
      // Don't throw - sign out should always clear local state
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final session = client.auth.currentSession;
      if (session == null) {
        return null;
      }

      return _userModelFromUser(session.user);
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isSignedIn() async {
    try {
      return client.auth.currentSession != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<AuthSession> refreshToken() async {
    try {
      final session = client.auth.currentSession;
      if (session == null) {
        throw AuthException(
          'No active session to refresh',
          type: AuthErrorType.unauthorized,
        );
      }

      // Supabase auto-refreshes tokens, but we can force a refresh
      await client.auth.refreshSession();
      final newSession = client.auth.currentSession;

      if (newSession == null) {
        throw AuthException(
          'Failed to refresh session',
          type: AuthErrorType.tokenExpired,
        );
      }

      return _authSessionFromSession(newSession);
    } catch (e) {
      throw AuthException(
        'Failed to refresh token: ${e.toString()}',
        type: AuthErrorType.tokenExpired,
      );
    }
  }

  @override
  Future<void> verifyEmail(String code, String email) async {
    try {

      // Supabase uses OTP (one-time password) for email verification
      final response = await client.auth.verifyOTP(
        email: email,
        token: code,
        type: OtpType.signup,
      );

      if (response.session == null) {
        throw AuthException(
          'Verification failed',
          type: AuthErrorType.invalidCode,
        );
      }

    } catch (e) {

      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('expired')) {
        throw AuthException(
          'Verification code has expired',
          type: AuthErrorType.codeExpired,
        );
      } else if (errorStr.contains('invalid')) {
        throw AuthException(
          'Invalid verification code',
          type: AuthErrorType.invalidCode,
        );
      }
      throw AuthException(
        'Failed to verify email: ${e.toString()}',
        type: AuthErrorType.unknown,
      );
    }
  }

  @override
  Future<void> resendVerificationEmail() async {
    try {
      final currentUser = client.auth.currentUser;
      if (currentUser == null || currentUser.email == null) {
        throw AuthException(
          'No user to resend verification email',
          type: AuthErrorType.userNotFound,
        );
      }

      // For Supabase, we need to use OTP for resending verification
      await client.auth.signInWithOtp(
        email: currentUser.email!,
      );

    } catch (e) {

      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('limit')) {
        throw AuthException(
          'Too many attempts. Please try again later',
          type: AuthErrorType.limitExceeded,
        );
      }
      throw AuthException(
        'Failed to resend verification email: ${e.toString()}',
        type: AuthErrorType.unknown,
      );
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {

      await client.auth.resetPasswordForEmail(email);

    } catch (e) {

      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('limit') || errorStr.contains('too many')) {
        throw AuthException(
          'Too many password reset attempts. Please try again later.',
          type: AuthErrorType.limitExceeded,
        );
      } else if (errorStr.contains('not found')) {
        throw AuthException(
          'No account found with this email address.',
          type: AuthErrorType.userNotFound,
        );
      }
      throw AuthException(
        'Failed to initiate password reset: ${e.toString()}',
        type: AuthErrorType.unknown,
      );
    }
  }

  @override
  Future<void> confirmForgotPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    try {

      // Supabase uses OTP for password reset confirmation
      await client.auth.verifyOTP(
        email: email,
        token: code,
        type: OtpType.recovery,
      );

      // After verifying the OTP, update the password
      final response = await client.auth.updateUser(
        UserAttributes(password: newPassword),
      );

      if (response.user == null) {
        throw AuthException(
          'Failed to reset password',
          type: AuthErrorType.resetFailed,
        );
      }

    } catch (e) {

      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('invalid') && errorStr.contains('code')) {
        throw AuthException(
          'Invalid verification code. Please try again.',
          type: AuthErrorType.invalidCode,
        );
      } else if (errorStr.contains('expired')) {
        throw AuthException(
          'Verification code has expired. Please request a new code.',
          type: AuthErrorType.codeExpired,
        );
      } else if (errorStr.contains('password')) {
        throw AuthException(
          'Password does not meet requirements: ${e.toString()}',
          type: AuthErrorType.invalidPassword,
        );
      }
      throw AuthException(
        'Failed to reset password: ${e.toString()}',
        type: AuthErrorType.resetFailed,
      );
    }
  }

  @override
  Future<void> adminSetUserPassword(
    String email,
    String newPassword, {
    bool permanent = false,
  }) async {
    // Admin operations require service role key
    // This should be called from a server-side function
    throw UnimplementedError(
      'Admin operations must be performed server-side with service role key',
    );
  }

  @override
  Future<void> adminResetUserPassword(String email) async {
    // Admin operations require service role key
    // This should be called from a server-side function
    throw UnimplementedError(
      'Admin operations must be performed server-side with service role key',
    );
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    // Alias for forgotPassword
    return forgotPassword(email);
  }

  @override
  Future<AuthTokens> refreshTokenWithString(String refreshToken) async {
    try {
      final response = await client.auth.refreshSession();

      final session = response.session;
      if (session == null) {
        throw AuthException(
          'Failed to refresh token',
          type: AuthErrorType.tokenExpired,
        );
      }

      return AuthTokens(
        accessToken: session.accessToken,
        idToken: session.accessToken, // Supabase uses accessToken for both
        refreshToken: session.refreshToken ?? '',
        expiration: session.expiresAt is DateTime
            ? (session.expiresAt as DateTime)
            : DateTime.now().add(const Duration(hours: 1)),
      );
    } catch (e) {
      throw AuthException(
        'Failed to refresh token: ${e.toString()}',
        type: AuthErrorType.tokenExpired,
      );
    }
  }

  @override
  Future<AuthTokens> reauthenticate(Credentials credentials) async {
    // Re-authenticate by signing in again
    try {
      final (user, authSession) = await signIn(
        credentials.username,
        credentials.password,
      );

      // Convert AuthSession to AuthTokens
      return AuthTokens(
        accessToken: authSession.accessToken,
        idToken: authSession.idToken,
        refreshToken: authSession.refreshToken,
        expiration: authSession.expiresAt,
      );
    } catch (e) {
      throw AuthException(
        'Re-authentication failed: ${e.toString()}',
        type: AuthErrorType.unauthorized,
      );
    }
  }

  // ============================================================
  // MULTI-FACTOR AUTHENTICATION (MFA) IMPLEMENTATION
  // ============================================================
  //
  // Official Supabase MFA Documentation:
  // - https://supabase.com/docs/guides/auth/auth-mfa
  // - https://supabase.com/docs/guides/auth/auth-mfa/totp
  //
  // MFA Flow:
  // 1. setupMFA() - Enroll a TOTP factor, returns QR code and secret
  // 2. verifyMFA() - Verify the TOTP code during setup or login
  // 3. listMFAFactors() - Get all enrolled factors for the user
  // 4. disableMFA() - Unenroll a factor by ID
  // ============================================================

  @override
  Future<(String factorId, String qrCode, String secret)> setupMFA() async {
    try {

      // Step 1: Enroll a TOTP factor
      final response = await client.auth.mfa.enroll();

      if (response.totp == null) {
        throw AuthException(
          'Failed to enroll MFA factor',
          type: AuthErrorType.unknown,
        );
      }

      final factorId = response.id;
      final qrCode = response.totp!.qrCode;
      final secret = response.totp!.secret;

      return (factorId, qrCode, secret);
    } catch (e) {
      throw AuthException(
        'Failed to setup MFA: ${e.toString()}',
        type: AuthErrorType.unknown,
      );
    }
  }

  @override
  Future<bool> verifyMFA(String code, {String? factorId}) async {
    try {

      // If no factorId provided, get the first available TOTP factor
      final targetFactorId = factorId ?? await _getFirstTOTPFactorId();

      if (targetFactorId == null) {
        throw AuthException(
          'No MFA factor found. Please setup MFA first.',
          type: AuthErrorType.mfaRequired,
        );
      }

      // Step 1: Create a challenge for the factor
      final challengeResponse = await client.auth.mfa.challenge(
        factorId: targetFactorId,
      );

      final challengeId = challengeResponse.id;

      // Step 2: Verify the code with the challenge
      await client.auth.mfa.verify(
        factorId: targetFactorId,
        challengeId: challengeId,
        code: code,
      );

      return true;
    } catch (e) {

      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('invalid') && errorStr.contains('code')) {
        throw AuthException(
          'Invalid verification code. Please try again.',
          type: AuthErrorType.invalidCode,
        );
      } else if (errorStr.contains('expired')) {
        throw AuthException(
          'Verification code has expired.',
          type: AuthErrorType.codeExpired,
        );
      }

      throw AuthException(
        'Failed to verify MFA: ${e.toString()}',
        type: AuthErrorType.unknown,
      );
    }
  }

  @override
  Future<List<String>> listMFAFactors() async {
    try {

      final response = await client.auth.mfa.listFactors();

      // Combine TOTP and phone factors
      final totpFactors = response.totp.map((f) => f.id).toList();
      final phoneFactors = response.phone.map((f) => f.id).toList();

      final allFactors = [...totpFactors, ...phoneFactors];

      return allFactors;
    } catch (e) {
      throw AuthException(
        'Failed to list MFA factors: ${e.toString()}',
        type: AuthErrorType.unknown,
      );
    }
  }

  @override
  Future<void> disableMFA(String factorId) async {
    try {

      // unenroll takes a single positional parameter (factorId as string)
      await client.auth.mfa.unenroll(factorId);

    } catch (e) {

      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('not found')) {
        throw AuthException(
          'MFA factor not found',
          type: AuthErrorType.notAuthorized,
        );
      }

      throw AuthException(
        'Failed to disable MFA: ${e.toString()}',
        type: AuthErrorType.unknown,
      );
    }
  }

  /// Helper method to get the first TOTP factor ID
  /// Returns null if no TOTP factors are enrolled
  Future<String?> _getFirstTOTPFactorId() async {
    try {
      final response = await client.auth.mfa.listFactors();

      if (response.totp.isEmpty) {
        return null;
      }

      return response.totp.first.id;
    } catch (e) {
      return null;
    }
  }

  // ============================================================
  // ACCOUNT MANAGEMENT
  // ============================================================

  @override
  Future<void> deleteAccount() async {
    try {

      // Get current user ID before deleting
      final user = client.auth.currentUser;
      if (user == null) {
        throw const AuthException(
          'No authenticated user found',
          type: AuthErrorType.notAuthorized,
        );
      }

      user.id;

      // ============================================================
      // IMPORTANT: Account deletion requires admin privileges
      // ============================================================
      // Supabase's auth.admin.deleteUser() requires service role key,
      // which should NEVER be exposed to client applications.
      //
      // The proper pattern is to call an Edge Function that:
      // 1. Validates the user's session
      // 2. Deletes the user's data (profile, storage files, etc.)
      // 3. Calls auth.admin.deleteUser() with service role key
      //
      // Edge Function: 'delete-user-account'
      // - Expected to return: { success: true } or { error: string }
      // ============================================================

      final response = await client.functions.invoke(
        'delete-user-account',
        method: HttpMethod.post,
      );

      final data = response.data;

      // Check for errors from Edge Function
      if (data == null) {
        throw AuthException(
          'Failed to delete account: No response from server',
          type: AuthErrorType.unknown,
        );
      }

      if (data['error'] != null) {
        throw AuthException(
          'Failed to delete account: ${data['error']}',
          type: AuthErrorType.unknown,
        );
      }

      if (data['success'] != true) {
        throw AuthException(
          'Failed to delete account: Unknown error',
          type: AuthErrorType.unknown,
        );
      }

    } catch (e) {

      final errorStr = e.toString().toLowerCase();
      if (errorStr.contains('not authenticated') ||
          errorStr.contains('not authorized')) {
        throw AuthException(
          'You must be logged in to delete your account',
          type: AuthErrorType.notAuthorized,
        );
      } else if (errorStr.contains('edge function') ||
          errorStr.contains('function not found')) {
        throw AuthException(
          'Account deletion service not available. Please contact support.',
          type: AuthErrorType.unknown,
        );
      }

      throw AuthException(
        'Failed to delete account: ${e.toString()}',
        type: AuthErrorType.unknown,
      );
    }
  }
}
