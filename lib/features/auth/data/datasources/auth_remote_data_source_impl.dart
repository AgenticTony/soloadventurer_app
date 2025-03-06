import 'package:flutter/foundation.dart';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:soloadventurer/features/auth/data/models/user_model.dart';

/// Implementation of [AuthRemoteDataSource] using AWS Cognito
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final CognitoUserPool _userPool;
  CognitoUser? _cognitoUser;
  CognitoUserSession? _session;
  int _failedAttempts = 0;
  DateTime? _lastFailedAttempt;

  static const String USER_SRP_AUTH = 'USER_SRP_AUTH';
  static const String ACCESS_TOKEN = 'ACCESS';

  /// Creates a new [AuthRemoteDataSourceImpl]
  AuthRemoteDataSourceImpl({
    required CognitoUserPool userPool,
  }) : _userPool = userPool;

  void _handleFailedAttempt() {
    final now = DateTime.now();
    if (_lastFailedAttempt != null &&
        now.difference(_lastFailedAttempt!).inMinutes >= 15) {
      _failedAttempts = 0;
    }
    _failedAttempts++;
    _lastFailedAttempt = now;
  }

  void _resetFailedAttempts() {
    _failedAttempts = 0;
    _lastFailedAttempt = null;
  }

  Future<void> _ensureValidSession() async {
    if (_session == null || !_session!.isValid()) {
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

  Future<String?> _getToken(String tokenType) async {
    await _ensureValidSession();
    switch (tokenType) {
      case ACCESS_TOKEN:
        return _session?.getAccessToken().getJwtToken();
      default:
        return null;
    }
  }

  /// Maps Cognito exceptions to domain-specific AuthExceptions
  AuthException _mapCognitoException(CognitoUserException e) {
    final errorMessage = (e.message ?? e.toString()).toLowerCase();
    debugPrint('Mapping Cognito error: $errorMessage');

    // User not found cases
    if (_containsAny(errorMessage, [
      'user does not exist',
      'user not found',
      'username/client id combination not found',
      'usernotfoundexception'
    ])) {
      return const AuthException(
        'No account found with this email address',
        code: 'USER_NOT_FOUND',
      );
    }

    // Authentication/password issues
    if (_containsAny(errorMessage, [
      'not authorized',
      'incorrect username or password',
      'password incorrect',
      'notauthorizedexception'
    ])) {
      _handleFailedAttempt();
      return const AuthException(
        'Incorrect password',
        code: 'INVALID_PASSWORD',
      );
    }

    // Email verification
    if (_containsAny(
        errorMessage, ['user is not confirmed', 'usernotconfirmedexception'])) {
      return const AuthException(
        'Please verify your email address',
        code: 'EMAIL_NOT_VERIFIED',
      );
    }

    // Password reset required
    if (_containsAny(errorMessage,
        ['password reset required', 'passwordresetrequiredexception'])) {
      return const AuthException(
        'Password reset required. Please reset your password',
        code: 'PASSWORD_RESET_REQUIRED',
      );
    }

    // Rate limiting
    if (_containsAny(errorMessage, ['limitexceededexception'])) {
      return const AuthException(
        'Too many attempts. Please try again later.',
        code: 'RATE_LIMIT_EXCEEDED',
      );
    }

    debugPrint('Unhandled Cognito error: $errorMessage');
    return AuthException(
      'Authentication failed: ${e.message}',
      code: 'AUTHENTICATION_FAILED',
    );
  }

  /// Helper method to check if a string contains any of the given patterns
  bool _containsAny(String source, List<String> patterns) {
    return patterns.any((pattern) => source.contains(pattern));
  }

  @override
  Future<(UserModel, String)> signIn(String email, String password) async {
    try {
      debugPrint('Attempting to sign in user: $email');
      _cognitoUser = CognitoUser(email, _userPool);

      final authDetails = AuthenticationDetails(
        username: email,
        password: password,
      );

      try {
        debugPrint('Authenticating user...');
        _session = await _cognitoUser!.authenticateUser(authDetails);

        if (_session == null) {
          throw const AuthException(
            'Unable to sign in. Please try again',
            code: 'AUTHENTICATION_FAILED',
          );
        }

        debugPrint('Authentication successful');
        final user = await _createUserModel(email);
        final token = await _getAccessToken();
        _resetFailedAttempts();
        return (user, token);
      } on CognitoUserException catch (e) {
        debugPrint('========= COGNITO ERROR DETAILS =========');
        debugPrint('Raw error: $e');
        debugPrint('Error type: ${e.runtimeType}');
        debugPrint('Error message: ${e.message}');
        debugPrint('=======================================');

        throw _mapCognitoException(e);
      }
    } catch (e) {
      debugPrint('Sign in error: $e');
      debugPrint('Error type: ${e.runtimeType}');
      if (e is AuthException) {
        rethrow;
      }
      throw AuthException(
        'Unable to sign in: $e',
        code: 'AUTHENTICATION_FAILED',
      );
    }
  }

  /// Creates a UserModel from the current authenticated user
  Future<UserModel> _createUserModel(String email) async {
    final attributes = await _cognitoUser!.getUserAttributes();
    final userId = _cognitoUser!.username ?? email;
    final name = _getAttributeValue(attributes, 'name', email);

    return UserModel(
      id: userId,
      email: email,
      username: name,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }

  /// Gets the current access token
  Future<String> _getAccessToken() async {
    return _session?.getAccessToken().getJwtToken() ?? '';
  }

  @override
  Future<(UserModel, bool)> register({
    required String email,
    required String password,
    required String name,
  }) async {
    throw UnimplementedError('register not implemented');
  }

  @override
  Future<void> signOut() async {
    throw UnimplementedError('signOut not implemented');
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    throw UnimplementedError('getCurrentUser not implemented');
  }

  @override
  Future<bool> isSignedIn() async {
    throw UnimplementedError('isSignedIn not implemented');
  }

  @override
  Future<AuthSession> refreshToken() async {
    try {
      await _ensureValidSession();
      return AuthSession(
        accessToken: await _getToken(ACCESS_TOKEN) ?? '',
        userId: _getUserId(),
      );
    } catch (e) {
      throw AuthException('Failed to refresh token: $e');
    }
  }

  @override
  Future<void> verifyEmail(String code, String email) async {
    throw UnimplementedError('verifyEmail not implemented');
  }

  @override
  Future<void> resendVerificationEmail() async {
    throw UnimplementedError('resendVerificationEmail not implemented');
  }

  @override
  Future<void> forgotPasswordSMS({
    required String email,
    required String phoneNumber,
  }) async {
    debugPrint('Starting SMS password reset process for: $email');

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

      // Get user attributes to verify phone number
      final attributes = await _cognitoUser!.getUserAttributes();
      final userPhoneNumber = attributes
          ?.firstWhere((attr) => attr.name == 'phone_number',
              orElse: () =>
                  CognitoUserAttribute(name: 'phone_number', value: ''))
          .value;

      // Verify phone number matches
      if (userPhoneNumber != phoneNumber) {
        throw const AuthException(
          'Phone number does not match our records',
          code: 'INVALID_PHONE_NUMBER',
        );
      }

      // Request password reset via SMS
      await _cognitoUser!.forgotPassword();

      debugPrint('Password reset code sent successfully via SMS');
      _failedAttempts = 0;
    } on CognitoClientException catch (e) {
      debugPrint('Cognito forgot password SMS error: $e');
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
      } else if (errorMessage.contains('invalidparameterexception')) {
        throw const AuthException(
          'Invalid phone number format.',
          code: 'INVALID_PHONE_NUMBER',
        );
      } else {
        throw AuthException(
          'Failed to initiate password reset: ${e.message}',
          code: 'FORGOT_PASSWORD_ERROR',
        );
      }
    } catch (e) {
      debugPrint('Unexpected error during SMS password reset: $e');
      _failedAttempts++;
      _lastFailedAttempt = now;
      throw AuthException(
        'Failed to initiate password reset: $e',
        code: 'UNKNOWN_ERROR',
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
    debugPrint('Setting password for user: $email');

    try {
      // Create a new Cognito user instance if needed
      _cognitoUser ??= CognitoUser(email, _userPool);

      // For admin operations, we'll use forgotPassword
      // In a real implementation, this would require admin credentials
      await _cognitoUser!.forgotPassword();
      debugPrint('Password reset initiated successfully');
    } on CognitoClientException catch (e) {
      debugPrint('Cognito admin set password error: $e');
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
