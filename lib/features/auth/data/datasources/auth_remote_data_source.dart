import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthException;
import 'package:soloadventurer/features/auth/data/models/user_model.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
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
  Future<(UserModel, String)> signIn(String email, String password);

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
  /// For Cognito, this requires admin API access.
  Future<void> deleteAccount();
}

/// Implementation of [AuthRemoteDataSource] using AWS Cognito and HTTP client
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final CognitoUserPool _userPool;
  final String _clientSecret;
  CognitoUser? _cognitoUser;
  CognitoUserSession? _session;
  int _failedAttempts = 0;
  DateTime? _lastFailedAttempt;
  static const int _maxFailedAttempts =
      5; // Same as AppConfig.awsConfig.maxFailedAttempts
  final http.Client _client;
  final String _baseUrl;

  /// Authentication flow types
  static const String USER_SRP_AUTH = 'USER_SRP_AUTH';
  static const String REFRESH_TOKEN_AUTH = 'REFRESH_TOKEN_AUTH';
  static const String CUSTOM_AUTH = 'CUSTOM_AUTH';

  /// Available authentication methods from Cognito
  static const String PASSWORD_AUTH = 'PASSWORD';
  static const String EMAIL_OTP_AUTH = 'EMAIL_OTP';
  static const String WEB_AUTHN = 'WEB_AUTHN';
  static const String SELECT_CHALLENGE = 'SELECT_MFA_TYPE';

  /// Token types for authorization
  static const String ACCESS_TOKEN = 'ACCESS';
  static const String ID_TOKEN = 'ID';
  static const String REFRESH_TOKEN = 'REFRESH';

  final List<String> _supportedAuthMethods = const ['USER_PASSWORD_AUTH'];

  /// Creates a new [AuthRemoteDataSourceImpl]
  AuthRemoteDataSourceImpl({
    required CognitoUserPool userPool,
    required String clientSecret,
    required http.Client client,
    required String baseUrl,
  })  : _userPool = userPool,
        _clientSecret = clientSecret,
        _client = client,
        _baseUrl = baseUrl;

  String _getUserId() {
    if (_cognitoUser == null) {
      throw AuthException(
        'No authenticated user',
        type: AuthErrorType.unauthorized,
      );
    }
    final username = _cognitoUser?.username;
    if (username == null || username.isEmpty) {
      throw AuthException(
        'Invalid user ID',
        type: AuthErrorType.unauthorized,
      );
    }
    return username;
  }

  String _getAttributeValue(
      List<CognitoUserAttribute>? attributes, String name) {
    if (attributes == null) {
      return '';
    }

    try {
      final attribute = attributes.firstWhere(
        (attr) => attr.getName() == name,
        orElse: () => CognitoUserAttribute(name: name, value: ''),
      );
      return attribute.getValue() ?? '';
    } catch (e) {
      return '';
    }
  }

  /// Get available authentication methods for a user
  Future<List<String>> _getAuthenticationOptions(String username) async {
    try {
      final authDetails = AuthenticationDetails(
        username: username,
        validationData: {'AuthFlow': 'USER_AUTH'},
      );

      try {
        await _cognitoUser!.initiateAuth(authDetails);
        // If we reach here without a challenge, default to password auth
        return [PASSWORD_AUTH];
      } on CognitoUserException catch (e) {
        // Check if this is a challenge selection response
        if (e.toString().contains('SELECT_MFA_TYPE')) {
          // Parse the error message to get challenge parameters
          final errorMsg = e.toString();
          final challengeParamsStart = errorMsg.indexOf('{');
          final challengeParamsEnd = errorMsg.lastIndexOf('}');

          if (challengeParamsStart != -1 && challengeParamsEnd != -1) {
            try {
              final challengeParamsJson = errorMsg.substring(
                  challengeParamsStart, challengeParamsEnd + 1);
              final Map<String, dynamic> params =
                  Map<String, dynamic>.from(json.decode(challengeParamsJson));

              final challenges =
                  params['AVAILABLE_CHALLENGES'] as String? ?? '';
              return challenges.isNotEmpty
                  ? challenges.split(',')
                  : [PASSWORD_AUTH];
            } catch (_) {
              // If parsing fails, return default
              return [PASSWORD_AUTH];
            }
          }
        }
        return [PASSWORD_AUTH];
      }
    } catch (e) {
      debugPrint('Error getting authentication options: $e');
      return [PASSWORD_AUTH]; // Fallback to password auth
    }
  }

  Future<void> _ensureValidSession() async {
    if (_session == null || !_session!.isValid()) {
      if (_cognitoUser != null && _session?.getRefreshToken() != null) {
        try {
          _session =
              await _cognitoUser!.refreshSession(_session!.getRefreshToken()!);
        } catch (e) {
          debugPrint('Failed to refresh session: $e');
          throw AuthException(
            'Session expired. Please sign in again.',
            type: AuthErrorType.tokenExpired,
          );
        }
      } else {
        throw AuthException(
          'No valid session. Please sign in.',
          type: AuthErrorType.unauthorized,
        );
      }
    }
  }

  Future<String?> _getToken(String tokenType) async {
    await _ensureValidSession();

    switch (tokenType) {
      case ACCESS_TOKEN:
        return _session?.getAccessToken().getJwtToken();
      case ID_TOKEN:
        return _session?.getIdToken().getJwtToken();
      case REFRESH_TOKEN:
        return _session?.getRefreshToken()?.getToken();
      default:
        return null;
    }
  }

  /// Register a new user
  @override
  Future<(UserModel, bool)> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      // Use email as the username for Cognito
      final username = email;

      // Add user attributes
      final userAttributes = [
        AttributeArg(name: 'email', value: email),
        AttributeArg(name: 'name', value: name),
      ];

      // Sign up the user
      final signUpResult = await _userPool.signUp(
        username,
        password,
        userAttributes: userAttributes,
      );

      // Create Cognito user instance
      _cognitoUser = CognitoUser(email, _userPool);

      // Create user model from response
      final user = UserModel(
        id: signUpResult.userSub ?? username,
        email: email,
        username: name,
        createdAt: DateTime.now(),
      );

      return (user, true); // true indicates verification is needed
    } on CognitoClientException catch (e) {
      throw AuthException(
        'Registration failed: ${e.message ?? 'An unknown error occurred'}',
        type: AuthErrorType.unknown,
      );
    } catch (e) {
      throw AuthException(
        'Registration failed: ${e.toString()}',
        type: AuthErrorType.unknown,
      );
    }
  }

  @override
  Future<(UserModel, String)> signIn(String email, String password) async {
    try {
      // Create a new Cognito user instance if needed
      _cognitoUser ??= CognitoUser(email, _userPool);

      // Check if the authentication method is supported
      if (!_supportedAuthMethods.contains('USER_PASSWORD_AUTH')) {
        throw AuthException(
          'Unsupported authentication method',
          type: AuthErrorType.unknown,
        );
      }

      // Attempt password authentication
      final authResult = await _handlePasswordAuth(email, password);
      if (authResult == null) {
        throw AuthException(
          'Authentication failed',
          type: AuthErrorType.unknown,
        );
      }

      // Store the session tokens and get user info
      await _storeSession(authResult);
      final user = await _getUserInfo();
      final accessToken = authResult.getAccessToken().getJwtToken();

      if (accessToken == null) {
        throw AuthException(
          'Failed to get access token',
          type: AuthErrorType.invalidToken,
        );
      }

      return (user, accessToken);
    } on CognitoUserException catch (e) {
      final errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('notauthorizedexception')) {
        throw AuthException(
          'Invalid email or password',
          type: AuthErrorType.invalidCredentials,
        );
      } else if (errorMessage.contains('usernotconfirmedexception')) {
        throw AuthException(
          'Email not verified. Please check your email for verification instructions.',
          type: AuthErrorType.emailNotVerified,
        );
      } else if (errorMessage.contains('passwordresetrequiredexception')) {
        throw AuthException(
          'Password reset required. Please reset your password.',
          type: AuthErrorType.passwordResetRequired,
        );
      } else if (errorMessage.contains('usernotfoundexception')) {
        throw AuthException(
          'No account found with this email address',
          type: AuthErrorType.userNotFound,
        );
      } else {
        throw AuthException(
          'Authentication failed: ${e.message}',
          type: AuthErrorType.unknown,
        );
      }
    } catch (e) {
      throw AuthException(
        'Authentication failed: $e',
        type: AuthErrorType.unknown,
      );
    }
  }

  Future<CognitoUserSession?> _handlePasswordAuth(
    String email,
    String password,
  ) async {
    try {
      final authDetails = AuthenticationDetails(
        username: email,
        password: password,
      );

      final session = await _cognitoUser!.authenticateUser(authDetails);

      if (session == null) {
        throw AuthException(
          'Failed to authenticate user',
          type: AuthErrorType.unknown,
        );
      }

      return session;
    } on CognitoUserException catch (e) {
      final errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('mfarequired')) {
        throw AuthException(
          'MFA authentication required',
          type: AuthErrorType.mfaRequired,
        );
      } else if (errorMessage.contains('smsmfarequired')) {
        throw AuthException(
          'SMS MFA authentication required',
          type: AuthErrorType.smsMfaRequired,
        );
      } else if (errorMessage.contains('newpasswordrequired')) {
        throw AuthException(
          'New password required',
          type: AuthErrorType.newPasswordRequired,
        );
      }

      rethrow;
    }
  }

  Future<void> _storeSession(CognitoUserSession session) async {
    _session = session;
    // Additional session storage logic here
  }

  Future<UserModel> _getUserInfo() async {
    if (_cognitoUser == null || _session == null) {
      throw AuthException(
        'No active session',
        type: AuthErrorType.notAuthorized,
      );
    }

    final attributesResult = await _cognitoUser!.getUserAttributes();
    final List<CognitoUserAttribute> attributes = attributesResult
            ?.where((attr) => attr.getName() != null && attr.getValue() != null)
            .map((attr) => CognitoUserAttribute(
                  name: attr.getName()!,
                  value: attr.getValue()!,
                ))
            .toList() ??
        [];

    final userId = _session!.getAccessToken().getJwtToken() ?? '';
    final email = _getAttributeValue(attributes, 'email');
    final name = _getAttributeValue(attributes, 'name') ?? email;

    return UserModel(
      id: userId,
      email: email,
      username: name,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }

  @override
  Future<void> signOut() async {
    try {
      // Global sign out to invalidate all sessions
      if (_cognitoUser != null) {
        final accessToken = await _getToken(ACCESS_TOKEN);
        if (accessToken != null) {
          await _cognitoUser!.globalSignOut();
        }
      }
    } catch (e) {
      debugPrint('Cognito sign out error: $e');
    } finally {
      // Always clear local session
      _cognitoUser = null;
      _session = null;
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      if (_cognitoUser == null || _session == null) {
        final lastUser = await _userPool.getCurrentUser();
        if (lastUser == null) {
          return null;
        }
        _cognitoUser = lastUser;

        // Try to get a valid session
        try {
          _session = await _cognitoUser!.getSession();
          await _ensureValidSession();
        } catch (e) {
          debugPrint('Failed to get/refresh session: $e');
          return null;
        }
      }

      final userId = _getUserId();
      final attributesResult = await _cognitoUser!.getUserAttributes();
      final List<CognitoUserAttribute> attributes = attributesResult
              ?.where(
                  (attr) => attr.getName() != null && attr.getValue() != null)
              .map((attr) => CognitoUserAttribute(
                    name: attr.getName()!,
                    value: attr.getValue()!,
                  ))
              .toList() ??
          [];

      final email = _getAttributeValue(attributes, 'email');
      final preferredUsername =
          _getAttributeValue(attributes, 'preferred_username');

      return UserModel(
        id: userId,
        email: email,
        username: preferredUsername,
        createdAt: DateTime.now(), // We'll get this from Cognito in production
      );
    } on CognitoUserException catch (e) {
      throw AuthException(
        'Failed to get current user: ${e.message}',
        type: AuthErrorType.unknown,
      );
    } catch (e) {
      debugPrint('Cognito get current user error: $e');
      return null;
    }
  }

  @override
  Future<bool> isSignedIn() async {
    try {
      if (_cognitoUser == null || _session == null) {
        return false;
      }
      await _ensureValidSession();
      return true;
    } catch (e) {
      debugPrint('Cognito isSignedIn error: $e');
      return false;
    }
  }

  @override
  Future<AuthSession> refreshToken() async {
    try {
      if (_cognitoUser == null || _session == null) {
        throw AuthException(
          'No authenticated user',
          type: AuthErrorType.unauthorized,
        );
      }

      final refreshToken = _session!.getRefreshToken();
      if (refreshToken == null) {
        throw AuthException(
          'No refresh token available',
          type: AuthErrorType.invalidToken,
        );
      }

      _session = await _cognitoUser!.refreshSession(refreshToken);
      if (_session == null) {
        throw AuthException(
          'Failed to refresh session',
          type: AuthErrorType.tokenExpired,
        );
      }

      return AuthSession(
        accessToken: _session!.getAccessToken().getJwtToken()!,
        idToken: _session!.getIdToken().getJwtToken()!,
        refreshToken: _session!.getRefreshToken()!.getToken()!,
        expiresAt: DateTime.fromMillisecondsSinceEpoch(
          _session!.getAccessToken().getExpiration() * 1000,
        ),
      );
    } catch (e) {
      debugPrint('Token refresh error: $e');
      throw AuthException(
        'Failed to refresh token: ${e.toString()}',
        type: AuthErrorType.unknown,
      );
    }
  }

  @override
  Future<void> verifyEmail(String code, String email) async {
    try {
      if (_cognitoUser == null) {
        throw AuthException(
          'No user to verify',
          type: AuthErrorType.userNotFound,
        );
      }

      await _cognitoUser!.confirmRegistration(code);
    } on CognitoUserException catch (e) {
      final errorMessage = e.message?.toLowerCase() ?? '';

      if (errorMessage.contains('expiredcode')) {
        throw AuthException(
          'Verification code has expired',
          type: AuthErrorType.codeExpired,
        );
      } else if (errorMessage.contains('codemismatch')) {
        throw AuthException(
          'Invalid verification code',
          type: AuthErrorType.invalidCode,
        );
      } else if (errorMessage.contains('notauthorized')) {
        throw AuthException(
          'Email already verified',
          type: AuthErrorType.notAuthorized,
        );
      }
      throw AuthException(
        'Failed to verify email: ${e.message}',
        type: AuthErrorType.unknown,
      );
    }
  }

  @override
  Future<void> resendVerificationEmail() async {
    try {
      if (_cognitoUser == null) {
        throw AuthException(
          'No user to verify',
          type: AuthErrorType.userNotFound,
        );
      }

      await _cognitoUser!.resendConfirmationCode();
    } on CognitoUserException catch (e) {
      final errorMessage = e.message?.toLowerCase() ?? '';

      if (errorMessage.contains('limitexceeded')) {
        throw AuthException(
          'Too many attempts. Please try again later',
          type: AuthErrorType.limitExceeded,
        );
      }
      throw AuthException(
        'Failed to resend verification email: ${e.message}',
        type: AuthErrorType.unknown,
      );
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    debugPrint('Starting password reset process for: $email');

    // Track failed attempts for rate limiting
    final now = DateTime.now();
    if (_lastFailedAttempt != null &&
        now.difference(_lastFailedAttempt!).inHours >= 1) {
      _failedAttempts = 0;
    }

    // Cognito allows between 5-20 attempts per hour
    if (_failedAttempts >= 5) {
      throw AuthException(
        'Too many password reset attempts. Please try again later.',
        type: AuthErrorType.limitExceeded,
      );
    }

    try {
      // Create a new Cognito user instance if needed
      _cognitoUser ??= CognitoUser(email, _userPool);

      await _cognitoUser!.forgotPassword();
      debugPrint('Password reset code sent successfully');
      _failedAttempts = 0;
    } on CognitoClientException catch (e) {
      debugPrint('Cognito forgot password error: $e');
      _failedAttempts++;
      _lastFailedAttempt = now;

      final errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('limitexceededexception')) {
        throw AuthException(
          'Too many password reset attempts. Please try again later.',
          type: AuthErrorType.limitExceeded,
        );
      } else if (errorMessage.contains('usernotfoundexception')) {
        throw AuthException(
          'No account found with this email address.',
          type: AuthErrorType.userNotFound,
        );
      } else {
        throw AuthException(
          'Failed to initiate password reset: ${e.message}',
          type: AuthErrorType.unknown,
        );
      }
    } catch (e) {
      debugPrint('Unexpected error during password reset: $e');
      _failedAttempts++;
      _lastFailedAttempt = now;
      throw AuthException(
        'Failed to initiate password reset: $e',
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
      // Create a new Cognito user instance if needed
      _cognitoUser ??= CognitoUser(email, _userPool);

      final result = await _cognitoUser!.confirmPassword(code, newPassword);
      if (!result) {
        throw AuthException(
          'Failed to reset password',
          type: AuthErrorType.resetFailed,
        );
      }
    } on CognitoClientException catch (e) {
      final errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('codemismatchexception')) {
        throw AuthException(
          'Invalid verification code. Please try again.',
          type: AuthErrorType.invalidCode,
        );
      } else if (errorMessage.contains('expiredcodexception')) {
        throw AuthException(
          'Verification code has expired. Please request a new code.',
          type: AuthErrorType.codeExpired,
        );
      } else if (errorMessage.contains('invalidpasswordexception')) {
        throw AuthException(
          'Password does not meet requirements: ${e.message}',
          type: AuthErrorType.invalidPassword,
        );
      } else {
        throw AuthException(
          'Failed to reset password: ${e.message}',
          type: AuthErrorType.resetFailed,
        );
      }
    } catch (e) {
      throw AuthException(
        'Failed to reset password: $e',
        type: AuthErrorType.unknown,
      );
    }
  }

  @override
  Future<void> adminSetUserPassword(String email, String newPassword,
      {bool permanent = false}) async {
    try {
      // Create a new Cognito user instance if needed
      _cognitoUser ??= CognitoUser(email, _userPool);

      // For admin operations, we'll use changePassword
      // In a real implementation, this would require admin credentials
      final bool success = await _cognitoUser!.changePassword(
        '', // Old password not needed for admin operations
        newPassword,
      );

      if (!success) {
        throw AuthException(
          'Failed to set password',
          type: AuthErrorType.adminSetPasswordError,
        );
      }
    } on CognitoClientException catch (e) {
      final errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('usernotfoundexception')) {
        throw AuthException(
          'User not found',
          type: AuthErrorType.userNotFound,
        );
      } else if (errorMessage.contains('invalidpasswordexception')) {
        throw AuthException(
          'Password does not meet requirements: ${e.message}',
          type: AuthErrorType.invalidPassword,
        );
      } else if (errorMessage.contains('notauthorizedexception')) {
        throw AuthException(
          'Not authorized to perform this action',
          type: AuthErrorType.notAuthorized,
        );
      } else {
        throw AuthException(
          'Failed to set password: ${e.message}',
          type: AuthErrorType.adminSetPasswordError,
        );
      }
    } catch (e) {
      throw AuthException(
        'Failed to set password: $e',
        type: AuthErrorType.unknown,
      );
    }
  }

  @override
  Future<void> adminResetUserPassword(String email) async {
    try {
      // Create a new Cognito user instance if needed
      _cognitoUser ??= CognitoUser(email, _userPool);

      // For admin operations, we'll use forgotPassword
      // In a real implementation, this would require admin credentials
      await _cognitoUser!.forgotPassword();
    } on CognitoClientException catch (e) {
      final errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('usernotfoundexception')) {
        throw AuthException(
          'User not found',
          type: AuthErrorType.userNotFound,
        );
      } else if (errorMessage.contains('notauthorizedexception')) {
        throw AuthException(
          'Not authorized to perform this action',
          type: AuthErrorType.notAuthorized,
        );
      } else {
        throw AuthException(
          'Failed to reset password: ${e.message}',
          type: AuthErrorType.adminResetPasswordError,
        );
      }
    } catch (e) {
      throw AuthException(
        'Failed to reset password: $e',
        type: AuthErrorType.unknown,
      );
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      final cognitoUser = CognitoUser(
        email,
        _userPool,
        clientSecret: _clientSecret,
      );
      await cognitoUser.forgotPassword();
    } on CognitoUserException catch (e) {
      final errorMessage = e.message?.toLowerCase() ?? '';

      if (errorMessage.contains('limitexceeded')) {
        throw AuthException(
          'Too many attempts. Please try again later',
          type: AuthErrorType.limitExceeded,
        );
      } else if (errorMessage.contains('usernotfound')) {
        throw AuthException(
          'No account found with this email',
          type: AuthErrorType.userNotFound,
        );
      }
      throw AuthException(
        'Failed to send password reset email: ${e.message}',
        type: AuthErrorType.unknown,
      );
    }
  }

  @override
  Future<AuthTokens> refreshTokenWithString(String refreshToken) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/auth/refresh'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $refreshToken',
        },
      );

      if (response.statusCode == 200) {
        return AuthTokens.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          message: 'Failed to refresh token',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw const ServerException(
        message: 'Network error during token refresh',
        statusCode: 500,
      );
    }
  }

  @override
  Future<AuthTokens> reauthenticate(Credentials credentials) async {
    try {
      final response = await _client.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode(credentials.toJson()),
      );

      if (response.statusCode == 200) {
        return AuthTokens.fromJson(
          json.decode(response.body) as Map<String, dynamic>,
        );
      } else {
        throw ServerException(
          message: 'Authentication failed',
          statusCode: response.statusCode,
        );
      }
    } catch (e) {
      throw const ServerException(
        message: 'Network error during authentication',
        statusCode: 500,
      );
    }
  }

  // ============================================================
  // MFA METHODS - Not supported by Cognito implementation
  // ============================================================

  @override
  Future<(String factorId, String qrCode, String secret)> setupMFA() {
    throw UnimplementedError(
      'MFA is not supported by the Cognito implementation. '
      'Use SupabaseAuthRemoteDataSourceImpl for MFA support.',
    );
  }

  @override
  Future<bool> verifyMFA(String code, {String? factorId}) {
    throw UnimplementedError(
      'MFA is not supported by the Cognito implementation. '
      'Use SupabaseAuthRemoteDataSourceImpl for MFA support.',
    );
  }

  @override
  Future<void> disableMFA(String factorId) {
    throw UnimplementedError(
      'MFA is not supported by the Cognito implementation. '
      'Use SupabaseAuthRemoteDataSourceImpl for MFA support.',
    );
  }

  @override
  Future<List<String>> listMFAFactors() {
    throw UnimplementedError(
      'MFA is not supported by the Cognito implementation. '
      'Use SupabaseAuthRemoteDataSourceImpl for MFA support.',
    );
  }

  @override
  Future<void> deleteAccount() {
    throw UnimplementedError(
      'Account deletion is not supported by the Cognito implementation. '
      'Use SupabaseAuthRemoteDataSourceImpl or implement server-side admin API.',
    );
  }
}

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
      debugPrint('SupabaseAuth: Starting sign up for $email');

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

      debugPrint('SupabaseAuth: Sign up successful, needs verification: $needsVerification');

      return (user, needsVerification);
    } catch (e) {
      debugPrint('SupabaseAuth: Error during sign up: $e');
      throw AuthException(
        'Registration failed: ${e.toString()}',
        type: AuthErrorType.unknown,
      );
    }
  }

  @override
  Future<(UserModel, String)> signIn(String email, String password) async {
    try {
      debugPrint('SupabaseAuth: Starting sign in for $email');

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
      final accessToken = response.session!.accessToken;

      debugPrint('SupabaseAuth: Sign in successful for user ${user.id}');

      return (user, accessToken);
    } catch (e) {
      debugPrint('SupabaseAuth: Error during sign in: $e');

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
      debugPrint('SupabaseAuth: Signing out');
      await client.auth.signOut();
      debugPrint('SupabaseAuth: Sign out successful');
    } catch (e) {
      debugPrint('SupabaseAuth: Error during sign out: $e');
      // Don't throw - sign out should always clear local state
    }
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    try {
      final session = client.auth.currentSession;
      if (session == null) {
        debugPrint('SupabaseAuth: No current user session');
        return null;
      }

      return _userModelFromUser(session.user);
    } catch (e) {
      debugPrint('SupabaseAuth: Error getting current user: $e');
      return null;
    }
  }

  @override
  Future<bool> isSignedIn() async {
    try {
      return client.auth.currentSession != null;
    } catch (e) {
      debugPrint('SupabaseAuth: Error checking signed in status: $e');
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
      debugPrint('SupabaseAuth: Error refreshing token: $e');
      throw AuthException(
        'Failed to refresh token: ${e.toString()}',
        type: AuthErrorType.tokenExpired,
      );
    }
  }

  @override
  Future<void> verifyEmail(String code, String email) async {
    try {
      debugPrint('SupabaseAuth: Verifying email with OTP: $code');

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

      debugPrint('SupabaseAuth: Email verification successful');
    } catch (e) {
      debugPrint('SupabaseAuth: Error during verify: $e');

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

      debugPrint('SupabaseAuth: Verification email resent');
    } catch (e) {
      debugPrint('SupabaseAuth: Error resending verification: $e');

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
      debugPrint('SupabaseAuth: Requesting password reset for $email');

      await client.auth.resetPasswordForEmail(email);

      debugPrint('SupabaseAuth: Password reset email sent');
    } catch (e) {
      debugPrint('SupabaseAuth: Error during forgot password: $e');

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
      debugPrint('SupabaseAuth: Confirming password reset');

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

      debugPrint('SupabaseAuth: Password reset successful');
    } catch (e) {
      debugPrint('SupabaseAuth: Error during confirm reset: $e');

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
      final (user, accessToken) = await signIn(
        credentials.username,
        credentials.password,
      );

      final session = client.auth.currentSession;
      if (session == null) {
        throw AuthException(
          'Re-authentication failed',
          type: AuthErrorType.unauthorized,
        );
      }

      return AuthTokens(
        accessToken: accessToken,
        idToken: session.accessToken, // Supabase uses accessToken for both
        refreshToken: session.refreshToken ?? '',
        expiration: session.expiresAt is DateTime
            ? (session.expiresAt as DateTime)
            : DateTime.now().add(const Duration(hours: 1)),
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
      debugPrint('SupabaseAuth: Starting MFA enrollment');

      // Step 1: Enroll a TOTP factor
      final response = await client.auth.mfa.enroll();

      if (response.totp == null) {
        throw AuthException(
          'Failed to enroll MFA factor',
          type: AuthErrorType.unknown,
        );
      }

      final factorId = response.id;
      final qrCode = response.totp!.qrCode ?? '';
      final secret = response.totp!.secret ?? '';

      debugPrint('SupabaseAuth: MFA enrollment successful, factorId: $factorId');

      return (factorId, qrCode, secret);
    } catch (e) {
      debugPrint('SupabaseAuth: Error during MFA enrollment: $e');
      throw AuthException(
        'Failed to setup MFA: ${e.toString()}',
        type: AuthErrorType.unknown,
      );
    }
  }

  @override
  Future<bool> verifyMFA(String code, {String? factorId}) async {
    try {
      debugPrint('SupabaseAuth: Verifying MFA code');

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
      final verifyResponse = await client.auth.mfa.verify(
        factorId: targetFactorId,
        challengeId: challengeId,
        code: code,
      );

      final success = verifyResponse != null;

      if (success) {
        debugPrint('SupabaseAuth: MFA verification successful');
      } else {
        debugPrint('SupabaseAuth: MFA verification failed');
      }

      return success;
    } catch (e) {
      debugPrint('SupabaseAuth: Error during MFA verification: $e');

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
      debugPrint('SupabaseAuth: Listing MFA factors');

      final response = await client.auth.mfa.listFactors();

      // Combine TOTP and phone factors
      final totpFactors = response.totp.map((f) => f.id).toList();
      final phoneFactors = response.phone.map((f) => f.id).toList();

      final allFactors = [...totpFactors, ...phoneFactors];

      debugPrint('SupabaseAuth: Found ${allFactors.length} MFA factors');

      return allFactors;
    } catch (e) {
      debugPrint('SupabaseAuth: Error listing MFA factors: $e');
      throw AuthException(
        'Failed to list MFA factors: ${e.toString()}',
        type: AuthErrorType.unknown,
      );
    }
  }

  @override
  Future<void> disableMFA(String factorId) async {
    try {
      debugPrint('SupabaseAuth: Disabling MFA factor: $factorId');

      // unenroll takes a single positional parameter (factorId as string)
      await client.auth.mfa.unenroll(factorId);

      debugPrint('SupabaseAuth: MFA factor disabled successfully');
    } catch (e) {
      debugPrint('SupabaseAuth: Error disabling MFA: $e');

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
      debugPrint('SupabaseAuth: Error getting TOTP factor: $e');
      return null;
    }
  }

  // ============================================================
  // ACCOUNT MANAGEMENT
  // ============================================================

  @override
  Future<void> deleteAccount() async {
    try {
      debugPrint('SupabaseAuth: Deleting user account');

      // Get current user ID before deleting
      final user = client.auth.currentUser;
      if (user == null) {
        throw const AuthException(
          'No authenticated user found',
          type: AuthErrorType.notAuthorized,
        );
      }

      final userId = user.id;

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

      debugPrint(
          'SupabaseAuth: Calling Edge Function to delete account: $userId');

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

      debugPrint('SupabaseAuth: Account deleted successfully');
    } catch (e) {
      debugPrint('SupabaseAuth: Error deleting account: $e');

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
