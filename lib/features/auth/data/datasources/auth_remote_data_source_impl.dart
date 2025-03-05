import 'package:flutter/foundation.dart';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_remote_data_source.dart';

/// Implementation of [AuthRemoteDataSource] using AWS Cognito
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final CognitoUserPool _userPool;
  CognitoUser? _cognitoUser;
  int _failedAttempts = 0;
  DateTime? _lastFailedAttempt;

  /// Creates a new [AuthRemoteDataSourceImpl]
  AuthRemoteDataSourceImpl({
    required CognitoUserPool userPool,
  }) : _userPool = userPool;

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
}
