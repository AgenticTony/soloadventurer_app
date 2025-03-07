import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:soloadventurer/features/core/config/app_config.dart';
import 'package:soloadventurer/features/auth/data/models/user_model.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'dart:math';
import 'dart:convert';

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
}

/// Implementation of [AuthRemoteDataSource] using AWS Cognito
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final CognitoUserPool _userPool;
  CognitoUser? _cognitoUser;
  String? _lastUsername;
  CognitoUserSession? _session;
  int _failedAttempts = 0;
  DateTime? _lastFailedAttempt;
  static const int _maxFailedAttempts =
      5; // Same as AppConfig.awsConfig.maxFailedAttempts

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

  /// Creates a new [AuthRemoteDataSourceImpl]
  AuthRemoteDataSourceImpl({
    required CognitoUserPool userPool,
  }) : _userPool = userPool;

  Future<void> _handleFailedAttempt() async {
    _failedAttempts++;
    if (_failedAttempts >= _maxFailedAttempts) {
      final backoffDuration = Duration(
          seconds: pow(2, _failedAttempts - _maxFailedAttempts).toInt());
      await Future.delayed(backoffDuration);
    }
  }

  void _resetFailedAttempts() {
    _failedAttempts = 0;
    _lastFailedAttempt = null;
  }

  String _getUserId() {
    if (_cognitoUser == null) {
      throw AuthException('No authenticated user');
    }
    final username = _cognitoUser?.username;
    if (username == null || username.isEmpty) {
      throw AuthException('Invalid user ID');
    }
    return username;
  }

  String _getAttributeValue(List<CognitoUserAttribute>? attributes,
      String attributeName, String defaultValue) {
    if (attributes == null) return defaultValue;

    try {
      final attr = attributes.firstWhere(
        (attr) => attr.name == attributeName,
        orElse: () =>
            CognitoUserAttribute(name: attributeName, value: defaultValue),
      );
      return attr.getValue() ?? defaultValue;
    } catch (e) {
      return defaultValue;
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
      // Try to refresh the session using refresh token if available
      if (_cognitoUser != null && _session?.getRefreshToken() != null) {
        try {
          _session =
              await _cognitoUser!.refreshSession(_session!.getRefreshToken()!);
        } catch (e) {
          debugPrint('Failed to refresh session: $e');
          throw AuthException('Session expired. Please sign in again.');
        }
      } else {
        throw AuthException('No valid session. Please sign in.');
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

      // Store the email for verification
      _lastUsername = email;
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
      );
    } catch (e) {
      throw AuthException('Registration failed: ${e.toString()}');
    }
  }

  @override
  Future<(UserModel, String)> signIn(String email, String password) async {
    try {
      debugPrint('Attempting to sign in user: $email');
      _cognitoUser = CognitoUser(email, _userPool);

      // Get available authentication methods
      final authMethods = await _getAuthenticationOptions(email);

      if (authMethods.contains(PASSWORD_AUTH)) {
        return _handlePasswordAuth(email, password);
      }

      throw const AuthException(
        'Unsupported authentication method',
        code: 'UNSUPPORTED_AUTH',
      );
    } on CognitoUserException catch (e) {
      debugPrint('Cognito error during sign in: $e');
      if (e.toString().contains('NotAuthorizedException')) {
        await _handleFailedAttempt();
        throw const AuthException(
          'Wrong password. Please try again.',
          code: 'INVALID_CREDENTIALS',
        );
      } else if (e.toString().contains('UserNotConfirmedException')) {
        throw const AuthException(
          'Please verify your email address',
          code: 'EMAIL_NOT_VERIFIED',
        );
      } else if (e.toString().contains('PasswordResetRequiredException')) {
        throw const AuthException(
          'Password reset required. Please reset your password',
          code: 'PASSWORD_RESET_REQUIRED',
        );
      } else if (e.toString().contains('UserNotFoundException')) {
        throw const AuthException(
          'No account found with this email',
          code: 'USER_NOT_FOUND',
        );
      }

      if (!e.toString().contains('Too many failed attempts')) {
        await _handleFailedAttempt();
      }
      throw AuthException(
        'Wrong password. Please try again.',
        code: 'COGNITO_ERROR',
      );
    } catch (e) {
      debugPrint('Sign in error: $e');
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException(
        'Wrong password. Please try again.',
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  Future<(UserModel, String)> _handlePasswordAuth(
      String identifier, String password) async {
    try {
      debugPrint('Handling password authentication for: $identifier');

      // Initialize SRP authentication
      final srpAuthDetails = AuthenticationDetails(
        username: identifier,
        password: password,
        validationData: {'AuthFlow': USER_SRP_AUTH},
      );

      try {
        debugPrint('Attempting to authenticate user...');
        _session = await _cognitoUser!.authenticateUser(srpAuthDetails);
        debugPrint('Authentication successful');
      } on CognitoUserException catch (e) {
        debugPrint('Authentication error: $e');
        if (e.toString().contains('SOFTWARE_TOKEN_MFA')) {
          throw const AuthException(
            'MFA is required. Please set up MFA in your account settings.',
            code: 'MFA_REQUIRED',
          );
        } else if (e.toString().contains('SMS_MFA')) {
          throw const AuthException(
            'SMS verification is required. Please verify your phone number.',
            code: 'SMS_MFA_REQUIRED',
          );
        } else if (e.toString().contains('NEW_PASSWORD_REQUIRED')) {
          debugPrint('User requires password reset (imported user)');
          throw const AuthException(
            'Your password needs to be reset. Please use the "Forgot Password" option to set a new password.',
            code: 'NEW_PASSWORD_REQUIRED',
          );
        } else if (e.toString().contains('NotAuthorizedException')) {
          await _handleFailedAttempt();
          throw const AuthException(
            'Wrong password. Please try again.',
            code: 'INVALID_CREDENTIALS',
          );
        }
        // Handle any other Cognito exceptions
        await _handleFailedAttempt();
        throw AuthException(
          'Wrong password. Please try again.',
          code: 'COGNITO_ERROR',
        );
      }

      await _ensureValidSession();

      debugPrint('Getting user attributes...');
      final attributes = await _cognitoUser!.getUserAttributes();
      final userId = _getUserId();
      final email = _getAttributeValue(attributes, 'email', userId);
      final name = _getAttributeValue(attributes, 'name', email);

      debugPrint('Creating user model...');
      final user = UserModel(
        id: userId,
        email: email,
        username: name,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      final accessToken = await _getToken(ACCESS_TOKEN);
      if (accessToken == null || accessToken.isEmpty) {
        throw AuthException('Failed to get access token');
      }

      debugPrint('Sign in successful');
      _resetFailedAttempts();
      return (user, accessToken);
    } catch (e) {
      debugPrint('Authentication error: $e');
      if (e is! AuthException ||
          !e.toString().contains('Too many failed attempts')) {
        await _handleFailedAttempt();
      }
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException(
        'Wrong password. Please try again.',
        code: 'AUTHENTICATION_FAILED',
      );
    }
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
      final attributes = await _cognitoUser!.getUserAttributes();

      final email = _getAttributeValue(attributes, 'email', userId);
      final preferredUsername =
          _getAttributeValue(attributes, 'preferred_username', email);

      return UserModel(
        id: userId,
        email: email,
        username: preferredUsername,
        createdAt: DateTime.now(), // We'll get this from Cognito in production
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
        throw AuthException('No authenticated user');
      }

      final refreshToken = _session!.getRefreshToken();
      if (refreshToken == null) {
        throw AuthException('No refresh token available');
      }

      _session = await _cognitoUser!.refreshSession(refreshToken);
      if (_session == null) {
        throw AuthException('Failed to refresh session');
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
      throw AuthException('Failed to refresh token: ${e.toString()}');
    }
  }

  @override
  Future<void> verifyEmail(String code, String email) async {
    debugPrint('Starting email verification process');
    debugPrint('Provided email: $email');
    debugPrint('Current Cognito user: ${_cognitoUser?.username}');
    debugPrint('Last username from registration: $_lastUsername');

    try {
      // Use existing Cognito user from registration if available
      if (_cognitoUser == null || _cognitoUser?.username != email) {
        if (_lastUsername == email) {
          debugPrint('Using stored Cognito user from registration');
          _cognitoUser = CognitoUser(_lastUsername!, _userPool);
        } else {
          debugPrint('Creating new Cognito user instance');
          _cognitoUser = CognitoUser(email, _userPool);
          _lastUsername = email; // Store for future use
        }
      }

      debugPrint('Attempting to confirm registration');
      final result = await _cognitoUser!.confirmRegistration(code);
      debugPrint('Confirmation result: $result');

      if (!result) {
        throw AuthException('Email verification failed');
      }
      debugPrint('Email verification successful');
    } on CognitoUserException catch (e) {
      debugPrint('Cognito verification error: $e');
      final errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('notauthorizedexception')) {
        throw AuthException(
            'Invalid verification attempt - please try registering again');
      } else if (errorMessage.contains('expired')) {
        throw AuthException(
            'Verification code has expired. Please request a new code.');
      } else if (errorMessage.contains('code mismatch')) {
        throw AuthException('Invalid verification code. Please try again.');
      } else if (errorMessage.contains('usernotfoundexception')) {
        throw AuthException('User not found. Please try registering again.');
      } else {
        throw AuthException('Failed to verify email: ${e.message}');
      }
    } catch (e) {
      debugPrint('Unexpected error during verification: $e');
      throw AuthException('Failed to verify email: $e');
    }
  }

  @override
  Future<void> resendVerificationEmail() async {
    debugPrint('Starting resend verification process');
    debugPrint('Last username (email) stored: $_lastUsername');
    debugPrint('Current Cognito user: ${_cognitoUser?.username}');

    if (_cognitoUser == null && _lastUsername != null) {
      debugPrint('Recreating Cognito user instance with email: $_lastUsername');
      _cognitoUser = CognitoUser(_lastUsername!, _userPool);
    } else if (_cognitoUser == null && _lastUsername == null) {
      debugPrint('No Cognito user or email available');
      throw AuthException('No user to verify - please try registering again');
    }

    try {
      await _cognitoUser!.resendConfirmationCode();
      debugPrint('Verification code resent successfully');
    } catch (e) {
      debugPrint('Cognito resend verification error: $e');
      throw AuthException('Failed to resend verification code');
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
      throw const AuthException(
        'Too many password reset attempts. Please try again later.',
        code: 'RESET_ATTEMPT_LIMIT',
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
        throw const AuthException(
          'Too many password reset attempts. Please try again later.',
          code: 'RESET_ATTEMPT_LIMIT',
        );
      } else if (errorMessage.contains('usernotfoundexception')) {
        throw const AuthException(
          'No account found with this email address.',
          code: 'USER_NOT_FOUND',
        );
      } else {
        throw AuthException(
          'Failed to initiate password reset: ${e.message}',
          code: 'FORGOT_PASSWORD_ERROR',
        );
      }
    } catch (e) {
      debugPrint('Unexpected error during password reset: $e');
      _failedAttempts++;
      _lastFailedAttempt = now;
      throw AuthException(
        'Failed to initiate password reset: $e',
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  @override
  Future<void> confirmForgotPassword(
    String email,
    String code,
    String newPassword,
  ) async {
    debugPrint('Confirming password reset for: $email');

    try {
      // Create a new Cognito user instance if needed
      _cognitoUser ??= CognitoUser(email, _userPool);

      final result = await _cognitoUser!.confirmPassword(code, newPassword);
      debugPrint('Password reset confirmation result: $result');

      if (!result) {
        throw const AuthException(
          'Failed to reset password',
          code: 'RESET_FAILED',
        );
      }
      debugPrint('Password reset successful');
    } on CognitoClientException catch (e) {
      debugPrint('Cognito confirm password error: $e');
      final errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('codemismatchexception')) {
        throw const AuthException(
          'Invalid verification code. Please try again.',
          code: 'INVALID_CODE',
        );
      } else if (errorMessage.contains('expiredcodexception')) {
        throw const AuthException(
          'Verification code has expired. Please request a new code.',
          code: 'CODE_EXPIRED',
        );
      } else if (errorMessage.contains('invalidpasswordexception')) {
        throw AuthException(
          'Password does not meet requirements: ${e.message}',
          code: 'INVALID_PASSWORD',
        );
      } else {
        throw AuthException(
          'Failed to reset password: ${e.message}',
          code: 'RESET_PASSWORD_ERROR',
        );
      }
    } catch (e) {
      debugPrint('Unexpected error during password reset confirmation: $e');
      throw AuthException(
        'Failed to reset password: $e',
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  @override
  Future<void> adminSetUserPassword(String email, String newPassword,
      {bool permanent = false}) async {
    debugPrint('Starting admin password set for user: $email');
    debugPrint('Setting ${permanent ? 'permanent' : 'temporary'} password');

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
        throw const AuthException(
          'Failed to set password',
          code: 'ADMIN_SET_PASSWORD_ERROR',
        );
      }
      debugPrint('Password set successfully');
    } on CognitoClientException catch (e) {
      debugPrint('Cognito admin set password error: $e');
      final errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('usernotfoundexception')) {
        throw const AuthException(
          'User not found',
          code: 'USER_NOT_FOUND',
        );
      } else if (errorMessage.contains('invalidpasswordexception')) {
        throw AuthException(
          'Password does not meet requirements: ${e.message}',
          code: 'INVALID_PASSWORD',
        );
      } else if (errorMessage.contains('notauthorizedexception')) {
        throw const AuthException(
          'Not authorized to perform this action',
          code: 'NOT_AUTHORIZED',
        );
      } else {
        throw AuthException(
          'Failed to set password: ${e.message}',
          code: 'ADMIN_SET_PASSWORD_ERROR',
        );
      }
    } catch (e) {
      debugPrint('Unexpected error during admin password set: $e');
      throw AuthException(
        'Failed to set password: $e',
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  @override
  Future<void> adminResetUserPassword(String email) async {
    debugPrint('Starting admin password reset for user: $email');

    try {
      // Create a new Cognito user instance if needed
      _cognitoUser ??= CognitoUser(email, _userPool);

      // For admin operations, we'll use forgotPassword
      // In a real implementation, this would require admin credentials
      await _cognitoUser!.forgotPassword();
      debugPrint('Admin password reset initiated successfully');
    } on CognitoClientException catch (e) {
      debugPrint('Cognito admin reset password error: $e');
      final errorMessage = e.toString().toLowerCase();

      if (errorMessage.contains('usernotfoundexception')) {
        throw const AuthException(
          'User not found',
          code: 'USER_NOT_FOUND',
        );
      } else if (errorMessage.contains('notauthorizedexception')) {
        throw const AuthException(
          'Not authorized to perform this action',
          code: 'NOT_AUTHORIZED',
        );
      } else {
        throw AuthException(
          'Failed to reset password: ${e.message}',
          code: 'ADMIN_RESET_PASSWORD_ERROR',
        );
      }
    } catch (e) {
      debugPrint('Unexpected error during admin password reset: $e');
      throw AuthException(
        'Failed to reset password: $e',
        code: 'UNKNOWN_ERROR',
      );
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    debugPrint('Sending password reset email to: $email');
    try {
      // Create a new Cognito user instance if needed
      _cognitoUser ??= CognitoUser(email, _userPool);
      await _cognitoUser!.forgotPassword();
      debugPrint('Password reset email sent successfully');
    } catch (e) {
      debugPrint('Error sending password reset email: $e');
      throw AuthException('Failed to send password reset email: $e');
    }
  }
}
