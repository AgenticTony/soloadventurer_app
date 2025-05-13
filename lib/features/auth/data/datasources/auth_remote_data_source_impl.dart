import 'package:flutter/foundation.dart';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:soloadventurer/features/auth/data/models/user_model.dart';
import 'package:soloadventurer/features/auth/domain/entities/auth_tokens.dart';
import 'package:soloadventurer/features/auth/domain/entities/credentials.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final CognitoUserPool _userPool;
  CognitoUser? _cognitoUser;
  CognitoUserSession? _session;
  int _failedAttempts = 0;
  DateTime? _lastFailedAttempt;

  AuthRemoteDataSourceImpl({
    required CognitoUserPool userPool,
  }) : _userPool = userPool;

  /// Maps Cognito exceptions to domain-specific AuthExceptions
  /// Enhanced with comprehensive AWS Cognito error codes
  AuthException _mapCognitoException(Exception e) {
    final errorMessage =
        (e is CognitoUserException ? (e.message ?? '') : e.toString())
            .toLowerCase();

    // Extract error code from message if possible
    String? errorCode;
    final errorCodeMatch = RegExp(r'\b([A-Z][a-zA-Z]+Exception)\b')
        .firstMatch(e is CognitoUserException ? e.message ?? '' : e.toString());
    if (errorCodeMatch != null) {
      errorCode = errorCodeMatch.group(1);
    }

    debugPrint('Mapping Cognito error: $errorMessage');
    debugPrint('Extracted error code: $errorCode');

    // Handle specific AWS Cognito error codes first (most precise)
    if (errorCode != null) {
      switch (errorCode) {
        case 'UserNotFoundException':
          return const AuthException(
            'No account found with this email address.',
            code: 'USER_NOT_FOUND',
          );

        case 'NotAuthorizedException':
          return const AuthException(
            'Incorrect email or password. Please try again.',
            code: 'INVALID_CREDENTIALS',
          );

        case 'UserNotConfirmedException':
          return const AuthException(
            'Please verify your email address before signing in.',
            code: 'EMAIL_NOT_VERIFIED',
          );

        case 'PasswordResetRequiredException':
          return const AuthException(
            'You need to reset your password before continuing.',
            code: 'PASSWORD_RESET_REQUIRED',
          );

        case 'LimitExceededException':
          return const AuthException(
            'Too many attempts. Please try again later.',
            code: 'RATE_LIMIT_EXCEEDED',
          );

        case 'TooManyRequestsException':
          return const AuthException(
            'Too many requests. Please try again later.',
            code: 'TOO_MANY_REQUESTS',
          );

        case 'InvalidPasswordException':
          return const AuthException(
            'Password does not meet the requirements. Please use a stronger password.',
            code: 'INVALID_PASSWORD',
          );

        case 'CodeMismatchException':
          return const AuthException(
            'Invalid verification code. Please try again.',
            code: 'INVALID_CODE',
          );

        case 'ExpiredCodeException':
          return const AuthException(
            'Verification code has expired. Please request a new code.',
            code: 'EXPIRED_CODE',
          );

        case 'InvalidParameterException':
          return const AuthException(
            'Invalid parameter provided. Please check your input.',
            code: 'INVALID_PARAMETER',
          );

        case 'MFAMethodNotFoundException':
          return const AuthException(
            'MFA method not found. Please set up MFA for your account.',
            code: 'MFA_METHOD_NOT_FOUND',
          );

        case 'SoftwareTokenMFANotFoundException':
          return const AuthException(
            'Software token MFA not found. Please set up MFA for your account.',
            code: 'SOFTWARE_TOKEN_MFA_NOT_FOUND',
          );

        case 'AliasExistsException':
          return const AuthException(
            'This email is already associated with another account.',
            code: 'EMAIL_EXISTS',
          );

        case 'InternalErrorException':
          return const AuthException(
            'An internal error occurred. Please try again later.',
            code: 'INTERNAL_ERROR',
          );
      }
    }

    // Fallback to message pattern matching for older SDK versions or unhandled codes

    // User not found cases
    if (_containsAny(errorMessage, [
      'user does not exist',
      'user not found',
      'username/client id combination not found',
      'usernotfoundexception'
    ])) {
      return const AuthException(
        'No account found with this email address.',
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
      return const AuthException(
        'Incorrect email or password. Please try again.',
        code: 'INVALID_CREDENTIALS',
      );
    }

    // Email verification
    if (_containsAny(
        errorMessage, ['user is not confirmed', 'usernotconfirmedexception'])) {
      return const AuthException(
        'Please verify your email address before signing in.',
        code: 'EMAIL_NOT_VERIFIED',
      );
    }

    // Password reset required
    if (_containsAny(errorMessage,
        ['password reset required', 'passwordresetrequiredexception'])) {
      return const AuthException(
        'You need to reset your password before continuing.',
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

    // Network issues
    if (_containsAny(
        errorMessage, ['network', 'connection', 'timeout', 'unreachable'])) {
      return const AuthException(
        'Network error. Please check your internet connection and try again.',
        code: 'NETWORK_ERROR',
      );
    }

    // Session expired
    if (_containsAny(errorMessage, ['invalid session'])) {
      return const AuthException('Session expired. Please sign in again.');
    }

    debugPrint('Unhandled Cognito error: $errorMessage');
    return AuthException(
      'Authentication failed: ${e is CognitoUserException ? e.message : e.toString()}',
      code: 'AUTHENTICATION_FAILED',
    );
  }

  /// Helper method to check if a string contains any of the given patterns
  bool _containsAny(String source, List<String> patterns) {
    return patterns.any((pattern) => source.contains(pattern));
  }

  // This method is not part of the interface
  @override
  Future<AuthTokens> refreshTokenWithString(String refreshToken) async {
    try {
      _cognitoUser ??= CognitoUser('', _userPool);
      _session =
          await _cognitoUser!.refreshSession(CognitoRefreshToken(refreshToken));

      final accessToken = _session!.getAccessToken().getJwtToken() ?? '';
      final idToken = _session!.getIdToken().getJwtToken() ?? '';
      final refreshTokenValue = _session!.getRefreshToken()?.getToken() ?? '';
      final expiration = _session!.getAccessToken().getExpiration();

      return AuthTokens(
        accessToken: accessToken,
        idToken: idToken,
        refreshToken: refreshTokenValue,
        expiration: DateTime.fromMillisecondsSinceEpoch(expiration * 1000),
      );
    } on CognitoUserException catch (e) {
      throw _mapCognitoException(e);
    }
  }

  @override
  Future<AuthSession> refreshToken() async {
    if (_cognitoUser == null || _session?.getRefreshToken() == null) {
      throw const AuthException('No refresh token available');
    }

    try {
      _session =
          await _cognitoUser!.refreshSession(_session!.getRefreshToken()!);

      return AuthSession(
        accessToken: _session!.getAccessToken().getJwtToken()!,
        idToken: _session!.getIdToken().getJwtToken()!,
        refreshToken: _session!.getRefreshToken()!.getToken()!,
        expiresAt: DateTime.fromMillisecondsSinceEpoch(
          _session!.getAccessToken().getExpiration() * 1000,
        ),
      );
    } on CognitoUserException catch (e) {
      throw _mapCognitoException(e);
    }
  }

  // This method is not part of the interface
  @override
  Future<AuthTokens> reauthenticate(Credentials credentials) async {
    try {
      _cognitoUser = CognitoUser(credentials.username, _userPool);
      final authDetails = AuthenticationDetails(
        username: credentials.username,
        password: credentials.password,
      );

      _session = await _cognitoUser!.authenticateUser(authDetails);

      final accessToken = _session!.getAccessToken().getJwtToken() ?? '';
      final idToken = _session!.getIdToken().getJwtToken() ?? '';
      final refreshTokenValue = _session!.getRefreshToken()?.getToken() ?? '';
      final expiration = _session!.getAccessToken().getExpiration();

      return AuthTokens(
        accessToken: accessToken,
        idToken: idToken,
        refreshToken: refreshTokenValue,
        expiration: DateTime.fromMillisecondsSinceEpoch(expiration * 1000),
      );
    } on CognitoUserException catch (e) {
      throw _mapCognitoException(e);
    }
  }

  // This is an additional method not in the interface
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

  @override
  Future<void> signOut() async {
    await _cognitoUser?.signOut();
    _cognitoUser = null;
    _session = null;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    if (_cognitoUser == null) return null;

    final attributes = await _cognitoUser!.getUserAttributes();
    final email = _cognitoUser!.username ?? '';
    final name = _getAttributeValue(attributes, 'name', email);

    return UserModel(
      id: email,
      email: email,
      username: name,
      createdAt: DateTime.now(),
      lastLoginAt: DateTime.now(),
    );
  }

  @override
  Future<bool> isSignedIn() async {
    return _cognitoUser != null && _session?.isValid() == true;
  }

  @override
  Future<void> verifyEmail(String code, String email) async {
    try {
      _cognitoUser ??= CognitoUser(email, _userPool);
      await _cognitoUser!.verifyAttribute('email', code);
    } on CognitoUserException catch (e) {
      throw _mapCognitoException(e);
    }
  }

  @override
  Future<void> resendVerificationEmail() async {
    if (_cognitoUser == null) {
      throw const AuthException('No user session found');
    }

    try {
      await _cognitoUser!.getAttributeVerificationCode('email');
    } on CognitoUserException catch (e) {
      throw _mapCognitoException(e);
    }
  }

  @override
  Future<(UserModel, bool)> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final userAttributes = [
        CognitoUserAttribute(name: 'email', value: email),
        CognitoUserAttribute(name: 'name', value: name),
      ];

      // Convert CognitoUserAttribute to AttributeArg
      final attributeArgs = userAttributes
          .map((attr) => AttributeArg(name: attr.name, value: attr.value ?? ''))
          .toList();

      final result = await _userPool.signUp(email, password,
          userAttributes: attributeArgs);

      return (
        UserModel(
          id: email,
          email: email,
          username: name,
          createdAt: DateTime.now(),
          lastLoginAt: DateTime.now(),
        ),
        result.userConfirmed!
      );
    } on CognitoClientException catch (e) {
      throw _mapCognitoException(e);
    }
  }

  @override
  Future<(UserModel, String)> signIn(String email, String password) async {
    try {
      _cognitoUser = CognitoUser(email, _userPool);
      final authDetails = AuthenticationDetails(
        username: email,
        password: password,
      );

      _session = await _cognitoUser!.authenticateUser(authDetails);

      final tokens = AuthTokens(
        accessToken: _session!.getAccessToken().getJwtToken()!,
        idToken: _session!.getIdToken().getJwtToken()!,
        refreshToken: _session!.getRefreshToken()!.getToken()!,
        expiration: DateTime.fromMillisecondsSinceEpoch(
          _session!.getAccessToken().getExpiration() * 1000,
        ),
      );

      final user = await getCurrentUser();

      return (user!, tokens.refreshToken);
    } on CognitoUserException catch (e) {
      throw _mapCognitoException(e);
    }
  }

  String _getAttributeValue(List<CognitoUserAttribute>? attributes,
      String attributeName, String defaultValue) {
    if (attributes == null) return defaultValue;
    final attribute = attributes.firstWhere(
      (attr) => attr.name == attributeName,
      orElse: () =>
          CognitoUserAttribute(name: attributeName, value: defaultValue),
    );
    return attribute.value!;
  }
}
