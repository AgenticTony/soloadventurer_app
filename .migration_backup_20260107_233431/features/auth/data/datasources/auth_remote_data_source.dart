import 'package:amazon_cognito_identity_dart_2/cognito.dart';
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
        message: 'No authenticated user',
        type: AuthErrorType.unauthorized,
      );
    }
    final username = _cognitoUser?.username;
    if (username == null || username.isEmpty) {
      throw AuthException(
        message: 'Invalid user ID',
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
            message: 'Session expired. Please sign in again.',
            type: AuthErrorType.tokenExpired,
          );
        }
      } else {
        throw AuthException(
          message: 'No valid session. Please sign in.',
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
        message:
            'Registration failed: ${e.message ?? 'An unknown error occurred'}',
        type: AuthErrorType.unknown,
      );
    } catch (e) {
      throw AuthException(
        message: 'Registration failed: ${e.toString()}',
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
          message: 'Unsupported authentication method',
          type: AuthErrorType.unknown,
        );
      }

      // Attempt password authentication
      final authResult = await _handlePasswordAuth(email, password);
      if (authResult == null) {
        throw AuthException(
          message: 'Authentication failed',
          type: AuthErrorType.unknown,
        );
      }

      // Store the session tokens and get user info
      await _storeSession(authResult);
      final user = await _getUserInfo();
      final accessToken = authResult.getAccessToken().getJwtToken();

      if (accessToken == null) {
        throw AuthException(
          message: 'Failed to get access token',
          type: AuthErrorType.invalidToken,
        );
      }

      return (user, accessToken);
    } on CognitoUserException catch (e) {
      final errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('notauthorizedexception')) {
        throw AuthException(
          message: 'Invalid email or password',
          type: AuthErrorType.invalidCredentials,
        );
      } else if (errorMessage.contains('usernotconfirmedexception')) {
        throw AuthException(
          message:
              'Email not verified. Please check your email for verification instructions.',
          type: AuthErrorType.emailNotVerified,
        );
      } else if (errorMessage.contains('passwordresetrequiredexception')) {
        throw AuthException(
          message: 'Password reset required. Please reset your password.',
          type: AuthErrorType.passwordResetRequired,
        );
      } else if (errorMessage.contains('usernotfoundexception')) {
        throw AuthException(
          message: 'No account found with this email address',
          type: AuthErrorType.userNotFound,
        );
      } else {
        throw AuthException(
          message: 'Authentication failed: ${e.message}',
          type: AuthErrorType.unknown,
        );
      }
    } catch (e) {
      throw AuthException(
        message: 'Authentication failed: $e',
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
          message: 'Failed to authenticate user',
          type: AuthErrorType.unknown,
        );
      }

      return session;
    } on CognitoUserException catch (e) {
      final errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('mfarequired')) {
        throw AuthException(
          message: 'MFA authentication required',
          type: AuthErrorType.mfaRequired,
        );
      } else if (errorMessage.contains('smsmfarequired')) {
        throw AuthException(
          message: 'SMS MFA authentication required',
          type: AuthErrorType.smsMfaRequired,
        );
      } else if (errorMessage.contains('newpasswordrequired')) {
        throw AuthException(
          message: 'New password required',
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
        message: 'No active session',
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
        message: 'Failed to get current user: ${e.message}',
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
          message: 'No authenticated user',
          type: AuthErrorType.unauthorized,
        );
      }

      final refreshToken = _session!.getRefreshToken();
      if (refreshToken == null) {
        throw AuthException(
          message: 'No refresh token available',
          type: AuthErrorType.invalidToken,
        );
      }

      _session = await _cognitoUser!.refreshSession(refreshToken);
      if (_session == null) {
        throw AuthException(
          message: 'Failed to refresh session',
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
        message: 'Failed to refresh token: ${e.toString()}',
        type: AuthErrorType.unknown,
      );
    }
  }

  @override
  Future<void> verifyEmail(String code, String email) async {
    try {
      if (_cognitoUser == null) {
        throw AuthException(
          message: 'No user to verify',
          type: AuthErrorType.userNotFound,
        );
      }

      await _cognitoUser!.confirmRegistration(code);
    } on CognitoUserException catch (e) {
      final errorMessage = e.message?.toLowerCase() ?? '';

      if (errorMessage.contains('expiredcode')) {
        throw AuthException(
          message: 'Verification code has expired',
          type: AuthErrorType.codeExpired,
        );
      } else if (errorMessage.contains('codemismatch')) {
        throw AuthException(
          message: 'Invalid verification code',
          type: AuthErrorType.invalidCode,
        );
      } else if (errorMessage.contains('notauthorized')) {
        throw AuthException(
          message: 'Email already verified',
          type: AuthErrorType.notAuthorized,
        );
      }
      throw AuthException(
        message: 'Failed to verify email: ${e.message}',
        type: AuthErrorType.unknown,
      );
    }
  }

  @override
  Future<void> resendVerificationEmail() async {
    try {
      if (_cognitoUser == null) {
        throw AuthException(
          message: 'No user to verify',
          type: AuthErrorType.userNotFound,
        );
      }

      await _cognitoUser!.resendConfirmationCode();
    } on CognitoUserException catch (e) {
      final errorMessage = e.message?.toLowerCase() ?? '';

      if (errorMessage.contains('limitexceeded')) {
        throw AuthException(
          message: 'Too many attempts. Please try again later',
          type: AuthErrorType.limitExceeded,
        );
      }
      throw AuthException(
        message: 'Failed to resend verification email: ${e.message}',
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
        message: 'Too many password reset attempts. Please try again later.',
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
          message: 'Too many password reset attempts. Please try again later.',
          type: AuthErrorType.limitExceeded,
        );
      } else if (errorMessage.contains('usernotfoundexception')) {
        throw AuthException(
          message: 'No account found with this email address.',
          type: AuthErrorType.userNotFound,
        );
      } else {
        throw AuthException(
          message: 'Failed to initiate password reset: ${e.message}',
          type: AuthErrorType.unknown,
        );
      }
    } catch (e) {
      debugPrint('Unexpected error during password reset: $e');
      _failedAttempts++;
      _lastFailedAttempt = now;
      throw AuthException(
        message: 'Failed to initiate password reset: $e',
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
          message: 'Failed to reset password',
          type: AuthErrorType.resetFailed,
        );
      }
    } on CognitoClientException catch (e) {
      final errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('codemismatchexception')) {
        throw AuthException(
          message: 'Invalid verification code. Please try again.',
          type: AuthErrorType.invalidCode,
        );
      } else if (errorMessage.contains('expiredcodexception')) {
        throw AuthException(
          message: 'Verification code has expired. Please request a new code.',
          type: AuthErrorType.codeExpired,
        );
      } else if (errorMessage.contains('invalidpasswordexception')) {
        throw AuthException(
          message: 'Password does not meet requirements: ${e.message}',
          type: AuthErrorType.invalidPassword,
        );
      } else {
        throw AuthException(
          message: 'Failed to reset password: ${e.message}',
          type: AuthErrorType.resetFailed,
        );
      }
    } catch (e) {
      throw AuthException(
        message: 'Failed to reset password: $e',
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
          message: 'Failed to set password',
          type: AuthErrorType.adminSetPasswordError,
        );
      }
    } on CognitoClientException catch (e) {
      final errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('usernotfoundexception')) {
        throw AuthException(
          message: 'User not found',
          type: AuthErrorType.userNotFound,
        );
      } else if (errorMessage.contains('invalidpasswordexception')) {
        throw AuthException(
          message: 'Password does not meet requirements: ${e.message}',
          type: AuthErrorType.invalidPassword,
        );
      } else if (errorMessage.contains('notauthorizedexception')) {
        throw AuthException(
          message: 'Not authorized to perform this action',
          type: AuthErrorType.notAuthorized,
        );
      } else {
        throw AuthException(
          message: 'Failed to set password: ${e.message}',
          type: AuthErrorType.adminSetPasswordError,
        );
      }
    } catch (e) {
      throw AuthException(
        message: 'Failed to set password: $e',
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
          message: 'User not found',
          type: AuthErrorType.userNotFound,
        );
      } else if (errorMessage.contains('notauthorizedexception')) {
        throw AuthException(
          message: 'Not authorized to perform this action',
          type: AuthErrorType.notAuthorized,
        );
      } else {
        throw AuthException(
          message: 'Failed to reset password: ${e.message}',
          type: AuthErrorType.adminResetPasswordError,
        );
      }
    } catch (e) {
      throw AuthException(
        message: 'Failed to reset password: $e',
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
          message: 'Too many attempts. Please try again later',
          type: AuthErrorType.limitExceeded,
        );
      } else if (errorMessage.contains('usernotfound')) {
        throw AuthException(
          message: 'No account found with this email',
          type: AuthErrorType.userNotFound,
        );
      }
      throw AuthException(
        message: 'Failed to send password reset email: ${e.message}',
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
}
