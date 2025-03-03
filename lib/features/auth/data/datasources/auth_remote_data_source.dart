import 'package:soloadventurer/core/api/client/api_client.dart';
import 'package:soloadventurer/features/auth/data/models/user_model.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:flutter/foundation.dart';

/// Interface for remote authentication operations
abstract class AuthRemoteDataSource {
  /// Sign in with email and password
  Future<(User, String, String, DateTime)> signIn(
      String email, String password);

  /// Register with email, password and name
  Future<(User, String, String, DateTime)> register(
      String email, String password, String name);

  /// Sign out the current user
  Future<void> signOut();

  /// Get the current user
  Future<User?> getCurrentUser();

  /// Refresh the authentication token
  Future<(String, DateTime)> refreshToken(String refreshToken);

  /// Request a password reset
  Future<void> forgotPassword(String email);

  /// Confirm password reset
  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  });

  /// Change password for authenticated user
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });

  /// Verify email address
  Future<void> verifyEmail(String code);

  /// Resend email verification code
  Future<void> resendVerificationEmail();

  /// Enable two-factor authentication
  Future<String> enableTwoFactor();

  /// Disable two-factor authentication
  Future<void> disableTwoFactor(String code);

  /// Verify two-factor authentication code
  Future<(String, String, DateTime)> verifyTwoFactor(String code);
}

/// Implementation of [AuthRemoteDataSource] using [ApiClient]
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _client;

  /// Creates a new [AuthRemoteDataSourceImpl] with the given API client
  const AuthRemoteDataSourceImpl({required ApiClient apiClient})
      : _client = apiClient;

  @override
  Future<(User, String, String, DateTime)> signIn(
      String email, String password) async {
    final response = await _client.post('/auth/login', data: {
      'email': email,
      'password': password,
    });

    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final token = data['token'] as String;
      final refreshToken = data['refresh_token'] as String;
      final expiresAt = DateTime.parse(data['expires_at'] as String);

      _client.setAuthToken(token);
      return (user, token, refreshToken, expiresAt);
    } else {
      throw AuthException('Invalid credentials');
    }
  }

  @override
  Future<(User, String, String, DateTime)> register(
      String email, String password, String name) async {
    debugPrint('AuthRemoteDataSource: Making registration API call');
    final response = await _client.post('/auth/register', data: {
      'email': email,
      'password': password,
      'username': name,
    });

    debugPrint(
        'AuthRemoteDataSource: API response status: ${response.statusCode}');
    if (response.statusCode == 201) {
      final data = response.data as Map<String, dynamic>;
      final user = UserModel.fromJson(data['user'] as Map<String, dynamic>);
      final token = data['token'] as String;
      final refreshToken = data['refresh_token'] as String;
      final expiresAt = DateTime.parse(data['expires_at'] as String);

      debugPrint('AuthRemoteDataSource: Setting auth token');
      _client.setAuthToken(token);
      debugPrint('AuthRemoteDataSource: Registration successful');
      return (user, token, refreshToken, expiresAt);
    } else {
      debugPrint(
          'AuthRemoteDataSource: Registration failed with status ${response.statusCode}');
      throw AuthException('Invalid credentials');
    }
  }

  @override
  Future<void> signOut() async {
    try {
      await _client.post('/auth/logout');
    } finally {
      _client.clearAuthToken();
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      final response = await _client.get('/auth/user');
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data as Map<String, dynamic>);
      }
    } catch (e) {
      return null;
    }
    return null;
  }

  @override
  Future<(String, DateTime)> refreshToken(String refreshToken) async {
    final response = await _client.post('/auth/refresh', data: {
      'refresh_token': refreshToken,
    });

    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      final newToken = data['token'] as String;
      final expiresAt = DateTime.parse(data['expires_at'] as String);
      _client.setAuthToken(newToken);
      return (newToken, expiresAt);
    } else {
      throw AuthException('Token refresh failed');
    }
  }

  @override
  Future<void> forgotPassword(String email) async {
    final response =
        await _client.post('/auth/forgot-password', data: {'email': email});
    if (response.statusCode != 200) {
      throw AuthException('Failed to send password reset email');
    }
  }

  @override
  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    final response = await _client.post('/auth/reset-password', data: {
      'email': email,
      'code': code,
      'new_password': newPassword,
    });

    if (response.statusCode != 200) {
      throw AuthException('Failed to reset password');
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    final response = await _client.post('/auth/change-password', data: {
      'current_password': currentPassword,
      'new_password': newPassword,
    });

    if (response.statusCode != 200) {
      throw AuthException('Failed to change password');
    }
  }

  @override
  Future<void> verifyEmail(String code) async {
    final response =
        await _client.post('/auth/verify-email', data: {'code': code});
    if (response.statusCode != 200) {
      throw AuthException('Failed to verify email');
    }
  }

  @override
  Future<void> resendVerificationEmail() async {
    final response = await _client.post('/auth/resend-verification');
    if (response.statusCode != 200) {
      throw AuthException('Failed to resend verification email');
    }
  }

  @override
  Future<String> enableTwoFactor() async {
    final response = await _client.post('/auth/2fa/enable');
    if (response.statusCode == 200) {
      return response.data['secret_key'] as String;
    } else {
      throw AuthException('Failed to enable two-factor authentication');
    }
  }

  @override
  Future<void> disableTwoFactor(String code) async {
    final response =
        await _client.post('/auth/2fa/disable', data: {'code': code});
    if (response.statusCode != 200) {
      throw AuthException('Failed to disable two-factor authentication');
    }
  }

  @override
  Future<(String, String, DateTime)> verifyTwoFactor(String code) async {
    final response =
        await _client.post('/auth/2fa/verify', data: {'code': code});
    if (response.statusCode == 200) {
      final data = response.data as Map<String, dynamic>;
      final token = data['token'] as String;
      final refreshToken = data['refresh_token'] as String;
      final expiresAt = DateTime.parse(data['expires_at'] as String);
      return (token, refreshToken, expiresAt);
    } else {
      throw AuthException('Invalid two-factor authentication code');
    }
  }
}
