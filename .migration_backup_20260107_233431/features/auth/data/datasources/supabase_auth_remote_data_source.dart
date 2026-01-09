import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:soloadventurer/features/auth/data/models/user_model.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/core/errors/exceptions.dart' as app_exceptions;
import 'package:soloadventurer/core/errors/auth_exception.dart' as auth_exceptions;
import 'package:soloadventurer/core/errors/auth_error_type.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:soloadventurer/features/auth/data/models/auth_tokens.dart';
import 'package:soloadventurer/features/auth/data/models/credentials.dart';

/// Supabase implementation of [AuthRemoteDataSource]
///
/// This implementation provides the same interface as the AWS Cognito implementation
/// but uses Supabase for authentication. This allows swapping between AWS and
/// Supabase by changing the provider without affecting the rest of the application.
class SupabaseAuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final SupabaseClient _client;
  final http.Client _httpClient;
  final String _baseUrl;

  /// Creates a new [SupabaseAuthRemoteDataSourceImpl]
  ///
  /// The [baseUrl] is used for any custom API endpoints (for future use)
  SupabaseAuthRemoteDataSourceImpl({
    required SupabaseClient client,
    required http.Client httpClient,
    String baseUrl = '',
  })  : _client = client,
        _httpClient = httpClient,
        _baseUrl = baseUrl;

  /// Maps Supabase error messages to [AuthErrorType]
  ///
  /// This helper keeps Supabase-specific error parsing contained
  /// within the data source layer, preventing leak of implementation
  /// details to the domain and presentation layers.
  AuthErrorType _mapSupabaseError(dynamic error) {
    final message = error.toString().toLowerCase();

    // Credential errors
    if (message.contains('invalid login credentials') ||
        message.contains('invalid_credentials') ||
        message.contains('email_password_mismatch')) {
      return AuthErrorType.invalidCredentials;
    }

    // User not found
    if (message.contains('user not found') ||
        message.contains('user_not_found')) {
      return AuthErrorType.userNotFound;
    }

    // Email already in use
    if (message.contains('already registered') ||
        message.contains('user already exists') ||
        message.contains('email_exists') ||
        message.contains('duplicate')) {
      return AuthErrorType.emailAlreadyInUse;
    }

    // Rate limiting
    if (message.contains('rate limit') ||
        message.contains('too many requests') ||
        message.contains('too_many_requests')) {
      return AuthErrorType.rateLimited;
    }

    // Unauthorized/JWT issues
    if (message.contains('jwt') ||
        message.contains('unauthorized') ||
        message.contains('invalid_token') ||
        message.contains('expired_token') ||
        message.contains('token_expired')) {
      return AuthErrorType.unauthorized;
    }

    // Network errors
    if (message.contains('network') ||
        message.contains('connection') ||
        message.contains('timeout') ||
        message.contains('socket')) {
      return AuthErrorType.network;
    }

    // Server errors
    if (message.contains('server') ||
        message.contains('internal') ||
        message.contains('500') ||
        message.contains('502') ||
        message.contains('503')) {
      return AuthErrorType.server;
    }

    return AuthErrorType.unknown;
  }

  /// Helper: Convert Supabase User to UserModel
  UserModel _mapToModel(User user) {
    // Extract name from metadata, fallback to email username, fallback to email
    final name = user.userMetadata?['name'] as String? ??
        user.userMetadata?['full_name'] as String? ??
        user.userMetadata?['username'] as String? ??
        user.email?.split('@')[0] ??
        '';

    return UserModel(
      id: user.id,
      email: user.email ?? '',
      username: name,
      createdAt: DateTime.tryParse(user.createdAt) ?? DateTime.now(),
      lastLoginAt: DateTime.now(), // Supabase doesn't track last login by default
    );
  }

  /// Helper: Convert Supabase Session to AuthSession
  AuthSession _mapSessionToAuthSession(Session session) {
    // Supabase's expiresAt is in seconds since epoch, need to convert to DateTime
    final expiresAt = session.expiresAt != null
        ? DateTime.fromMillisecondsSinceEpoch(session.expiresAt! * 1000)
        : DateTime.now().add(const Duration(hours: 1));

    return AuthSession(
      accessToken: session.accessToken,
      idToken: session.accessToken, // Supabase uses access token for both
      refreshToken: session.refreshToken ?? '',
      expiresAt: expiresAt,
    );
  }

  @override
  Future<(UserModel, bool)> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final response = await _client.auth.signUp(
        email: email,
        password: password,
        data: {
          'name': name,
          'username': name,
        },
        emailRedirectTo: dotenv.env['OAUTH_CALLBACK_URL'],
      );

      if (response.user == null) {
        throw const auth_exceptions.AuthException(
          message: 'Registration failed',
          type: AuthErrorType.unknown,
        );
      }

      final user = _mapToModel(response.user!);

      // Check if email verification is required
      // In Supabase, by default email confirmation might be disabled
      // If enabled, the user will need to verify
      final needsVerification = response.user!.emailConfirmedAt == null;

      return (user, needsVerification);
    } on auth_exceptions.AuthException {
      // Re-throw our app's AuthException
      rethrow;
    } catch (e) {
      throw auth_exceptions.AuthException(
        message: 'Registration failed: ${e.toString()}',
        type: _mapSupabaseError(e),
      );
    }
  }

  @override
  Future<(UserModel, String)> signIn(String email, String password) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null || response.session == null) {
        throw const auth_exceptions.AuthException(
          message: 'Authentication failed',
          type: AuthErrorType.invalidCredentials,
        );
      }

      // Check if email is verified (if verification is enabled)
      if (response.user!.emailConfirmedAt == null) {
        throw const auth_exceptions.AuthException(
          message: 'Please verify your email before signing in',
          type: AuthErrorType.unauthorized,
        );
      }

      final user = _mapToModel(response.user!);
      final accessToken = response.session!.accessToken;

      return (user, accessToken);
    } on auth_exceptions.AuthException {
      // Re-throw our app's AuthException
      rethrow;
    } catch (e) {
      throw auth_exceptions.AuthException(
        message: 'Authentication failed: ${e.toString()}',
        type: _mapSupabaseError(e),
      );
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      debugPrint('Supabase sign out error: $e');
      // Always clear local state even if remote sign out fails
      // The app will handle local cleanup
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      // Note: currentUser is a property, not a Future in supabase_flutter
      final response = _client.auth.currentUser;

      if (response == null) {
        return null;
      }

      return _mapToModel(response);
    } catch (e) {
      debugPrint('Supabase get current user error: $e');
      return null;
    }
  }

  @override
  Future<bool> isSignedIn() async {
    try {
      // Note: currentUser is a property, not a Future in supabase_flutter
      final response = _client.auth.currentUser;
      return response != null;
    } catch (e) {
      debugPrint('Supabase isSignedIn error: $e');
      return false;
    }
  }

  @override
  Future<AuthSession> refreshToken() async {
    try {
      final response = await _client.auth.refreshSession();

      if (response.session == null) {
        throw const auth_exceptions.AuthException(
          message: 'Failed to refresh token',
          type: AuthErrorType.unauthorized,
        );
      }

      return _mapSessionToAuthSession(response.session!);
    } catch (e) {
      debugPrint('Supabase token refresh error: $e');
      throw auth_exceptions.AuthException(
        message: 'Failed to refresh token: ${e.toString()}',
        type: _mapSupabaseError(e),
      );
    }
  }

  @override
  Future<void> verifyEmail(String code, String email) async {
    try {
      await _client.auth.verifyOTP(
        email: email,
        token: code,
        type: OtpType.email,
      );
    } on auth_exceptions.AuthException {
      // Re-throw our app's AuthException
      rethrow;
    } catch (e) {
      final message = e.toString().toLowerCase();

      if (message.contains('expired') || message.contains('invalid')) {
        throw const auth_exceptions.AuthException(
          message: 'Invalid or expired verification code',
          type: AuthErrorType.unauthorized,
        );
      }

      if (message.contains('already confirmed')) {
        throw const auth_exceptions.AuthException(
          message: 'Email already verified',
          type: AuthErrorType.unauthorized,
        );
      }

      throw auth_exceptions.AuthException(
        message: 'Verification failed: ${e.toString()}',
        type: _mapSupabaseError(e),
      );
    }
  }

  @override
  Future<void> resendVerificationEmail() async {
    try {
      // Supabase automatically sends verification email on signup
      // To resend, we need to use the resend API
      final currentUser = _client.auth.currentUser;
      if (currentUser != null) {
        // This will send a new verification email
        await _client.auth.updateUser(
          UserAttributes(data: {'resend_verification_email': true}),
        );
      }
    } catch (e) {
      debugPrint('Supabase resend verification error: $e');
      throw const auth_exceptions.AuthException(
        message: 'Failed to resend verification email',
        type: AuthErrorType.unknown,
      );
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email,
        redirectTo: dotenv.env['OAUTH_CALLBACK_URL'],
      );
    } catch (e) {
      debugPrint('Supabase forgot password error: $e');
      throw const auth_exceptions.AuthException(
        message: 'Failed to initiate password reset',
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
      // First verify the OTP (this is the code sent to email)
      await _client.auth.verifyOTP(
        email: email,
        token: code,
        type: OtpType.email,
      );

      // Then update the password
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      final message = e.toString().toLowerCase();

      if (message.contains('invalid') || message.contains('expired')) {
        throw const auth_exceptions.AuthException(
          message: 'Invalid or expired reset code',
          type: AuthErrorType.unauthorized,
        );
      }

      if (message.contains('password')) {
        throw const auth_exceptions.AuthException(
          message: 'Password does not meet requirements',
          type: AuthErrorType.invalidCredentials,
        );
      }

      throw auth_exceptions.AuthException(
        message: 'Password reset failed: ${e.toString()}',
        type: _mapSupabaseError(e),
      );
    }
  }

  @override
  Future<void> adminSetUserPassword(
    String email,
    String newPassword, {
    bool permanent = false,
  }) async {
    // Supabase doesn't have direct admin password reset like Cognito
    // This would require a Supabase Edge Function or service role key
    // For now, we'll use the user context (user must be logged in)
    try {
      await _client.auth.updateUser(
        UserAttributes(password: newPassword),
      );
    } catch (e) {
      debugPrint('Supabase admin set password error: $e');
      throw const auth_exceptions.AuthException(
        message: 'Failed to update password',
        type: AuthErrorType.unknown,
      );
    }
  }

  @override
  Future<void> adminResetUserPassword(String email) async {
    // Use forgotPassword for now
    // True admin reset would require Edge Function with service role
    await forgotPassword(email);
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await forgotPassword(email);
  }

  @override
  Future<AuthTokens> refreshTokenWithString(String refreshToken) async {
    try {
      final response = await _client.auth.refreshSession();

      if (response.session == null) {
        throw const app_exceptions.ServerException(
          message: 'Failed to refresh token',
          code: 'refresh_failed',
        );
      }

      // Convert expiresAt (seconds) to DateTime
      final expiration = response.session!.expiresAt != null
          ? DateTime.fromMillisecondsSinceEpoch(response.session!.expiresAt! * 1000)
          : DateTime.now().add(const Duration(hours: 1));

      return AuthTokens(
        accessToken: response.session!.accessToken,
        idToken: response.session!.accessToken,
        refreshToken: response.session!.refreshToken ?? '',
        expiration: expiration,
      );
    } catch (e) {
      debugPrint('Supabase refresh token error: $e');
      throw const app_exceptions.ServerException(
        message: 'Failed to refresh token',
        code: 'server_error',
      );
    }
  }

  @override
  Future<AuthTokens> reauthenticate(Credentials credentials) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: credentials.username,
        password: credentials.password,
      );

      if (response.session == null) {
        throw const app_exceptions.ServerException(
          message: 'Re-authentication failed',
          code: 'auth_failed',
        );
      }

      // Convert expiresAt (seconds) to DateTime
      final expiration = response.session!.expiresAt != null
          ? DateTime.fromMillisecondsSinceEpoch(response.session!.expiresAt! * 1000)
          : DateTime.now().add(const Duration(hours: 1));

      return AuthTokens(
        accessToken: response.session!.accessToken,
        idToken: response.session!.accessToken,
        refreshToken: response.session!.refreshToken ?? '',
        expiration: expiration,
      );
    } catch (e) {
      debugPrint('Supabase re-authentication error: $e');
      throw const app_exceptions.ServerException(
        message: 'Re-authentication failed',
        code: 'server_error',
      );
    }
  }
}
