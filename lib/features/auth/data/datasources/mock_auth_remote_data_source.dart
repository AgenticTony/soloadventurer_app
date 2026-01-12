import 'package:soloadventurer/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:soloadventurer/features/auth/data/models/user_model.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:soloadventurer/core/api/client/api_client.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/features/auth/data/models/auth_tokens.dart';
import 'package:soloadventurer/features/auth/data/models/credentials.dart';

/// Mock implementation of [AuthRemoteDataSource] for testing
class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  final ApiClient _apiClient;
  UserModel? _currentUser;
  bool _isAuthenticated = false;

  /// Creates a new [MockAuthRemoteDataSource]
  MockAuthRemoteDataSource(this._apiClient);

  @override
  Future<(UserModel, AuthSession)> signIn(String email, String password) async {
    if (_apiClient.isOffline) {
      throw const NetworkConnectivityException(
          message: 'No internet connection');
    }

    if (email == 'test@example.com' && password == 'password123') {
      _isAuthenticated = true;
      _currentUser = UserModel(
        id: 'test-user-id',
        email: email,
        username: email.split('@')[0],
        createdAt: DateTime.now(),
      );
      // Create a mock session with proper expiration
      final session = AuthSession(
        accessToken: 'mock-access-token',
        idToken: 'mock-id-token',
        refreshToken: 'mock-refresh-token',
        expiresAt: DateTime.now().add(const Duration(hours: 1)),
      );
      return (_currentUser!, session);
    }
    throw const AuthException('Invalid credentials');
  }

  @override
  Future<(UserModel, bool)> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      if (!email.contains('@')) {
        throw const AuthException('Invalid email format');
      }

      if (password.length < 6) {
        throw const AuthException('Password must be at least 6 characters');
      }

      if (name.isEmpty) {
        throw const AuthException('Name is required');
      }

      final user = UserModel(
        id: 'test-user-id',
        email: email,
        username: name.toLowerCase().replaceAll(' ', '_'),
        createdAt: DateTime.now(),
      );

      return (user, true); // Return true to indicate verification is needed
    } catch (e) {
      if (e is AuthException) {
        rethrow;
      }
      throw const AuthException('Registration failed');
    }
  }

  @override
  Future<void> signOut() async {
    _isAuthenticated = false;
    _currentUser = null;
  }

  @override
  Future<UserModel?> getCurrentUser() async {
    return _currentUser;
  }

  @override
  Future<void> forgotPassword(String email) async {
    if (_apiClient.isOffline) {
      throw const NetworkConnectivityException(
          message: 'No internet connection');
    }
    await Future.delayed(const Duration(seconds: 1));
    if (!email.contains('@')) {
      throw const AuthException('Invalid email format');
    }
    // In mock implementation, we just simulate sending the reset code
  }

  @override
  Future<void> verifyEmail(String code, String email) async {
    if (_apiClient.isOffline) {
      throw const NetworkConnectivityException(
          message: 'No internet connection');
    }
    await Future.delayed(const Duration(seconds: 1));
    if (code != '123456') {
      // Mock verification code
      throw const AuthException('Invalid verification code');
    }
  }

  @override
  Future<void> resendVerificationEmail() async {
    if (_apiClient.isOffline) {
      throw const NetworkConnectivityException(
          message: 'No internet connection');
    }
    await Future.delayed(const Duration(seconds: 1));
    // In mock implementation, we just simulate sending the email
  }

  @override
  Future<bool> isSignedIn() async {
    await Future.delayed(const Duration(seconds: 1));
    return _isAuthenticated;
  }

  @override
  Future<AuthSession> refreshToken() async {
    if (_apiClient.isOffline) {
      throw const NetworkConnectivityException(
          message: 'No internet connection');
    }

    if (!_isAuthenticated) {
      throw const AuthException('Not authenticated');
    }

    await Future.delayed(const Duration(seconds: 1));

    // Return a new mock session with refreshed tokens
    return AuthSession(
      accessToken:
          'refreshed_access_token_${DateTime.now().millisecondsSinceEpoch}',
      idToken: 'refreshed_id_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken:
          'refreshed_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      expiresAt: DateTime.now().add(const Duration(hours: 1)),
    );
  }

  @override
  Future<void> confirmForgotPassword(
      String email, String code, String newPassword) async {
    if (_apiClient.isOffline) {
      throw const NetworkConnectivityException(
          message: 'No internet connection');
    }
    await Future.delayed(const Duration(seconds: 1));
    if (code != '123456') {
      // Mock reset code
      throw const AuthException('Invalid reset code');
    }
    if (newPassword.length < 8) {
      throw const AuthException('Password must be at least 8 characters long');
    }
  }

  @override
  Future<void> adminSetUserPassword(String email, String newPassword,
      {bool permanent = false}) async {
    if (_apiClient.isOffline) {
      throw const NetworkConnectivityException(
          message: 'No internet connection');
    }
    await Future.delayed(const Duration(seconds: 1));
    if (!email.contains('@')) {
      throw const AuthException('Invalid email format');
    }
    if (newPassword.length < 8) {
      throw const AuthException('Password must be at least 8 characters long');
    }
  }

  @override
  Future<void> adminResetUserPassword(String email) async {
    if (_apiClient.isOffline) {
      throw const NetworkConnectivityException(
          message: 'No internet connection');
    }
    await Future.delayed(const Duration(seconds: 1));
    if (!email.contains('@')) {
      throw const AuthException('Invalid email format');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Simulate email validation
    if (!email.contains('@')) {
      throw const AuthException('Invalid email format');
    }
    // In a real implementation, this would send an email
    debugPrint('Password reset email sent to: $email');
  }

  @override
  Future<AuthTokens> refreshTokenWithString(String refreshToken) async {
    if (_apiClient.isOffline) {
      throw const NetworkConnectivityException(
          message: 'No internet connection');
    }

    if (!_isAuthenticated) {
      throw const AuthException('Not authenticated');
    }

    await Future.delayed(const Duration(seconds: 1));

    // Return new mock tokens
    return AuthTokens(
      accessToken:
          'refreshed_access_token_${DateTime.now().millisecondsSinceEpoch}',
      idToken: 'refreshed_id_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken:
          'refreshed_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      expiration: DateTime.now().add(const Duration(hours: 1)),
    );
  }

  @override
  Future<AuthTokens> reauthenticate(Credentials credentials) async {
    if (_apiClient.isOffline) {
      throw const NetworkConnectivityException(
          message: 'No internet connection');
    }

    await Future.delayed(const Duration(seconds: 1));

    // Validate credentials
    // Note: Credentials is a typedef, we can't access email/password directly
    // In production, this would validate against the actual credentials

    // Return new mock tokens
    return AuthTokens(
      accessToken:
          'reauth_access_token_${DateTime.now().millisecondsSinceEpoch}',
      idToken: 'reauth_id_token_${DateTime.now().millisecondsSinceEpoch}',
      refreshToken:
          'reauth_refresh_token_${DateTime.now().millisecondsSinceEpoch}',
      expiration: DateTime.now().add(const Duration(hours: 1)),
    );
  }

  @override
  Future<(String factorId, String qrCode, String secret)> setupMFA() async {
    if (_apiClient.isOffline) {
      throw const NetworkConnectivityException(
          message: 'No internet connection');
    }

    await Future.delayed(const Duration(seconds: 1));

    // Return mock MFA setup data
    return (
      'mock-factor-id-${DateTime.now().millisecondsSinceEpoch}',
      '<svg>Mock QR Code</svg>',
      'JBSWY3DPEHPK3PXP'
    );
  }

  @override
  Future<bool> verifyMFA(String code, {String? factorId}) async {
    if (_apiClient.isOffline) {
      throw const NetworkConnectivityException(
          message: 'No internet connection');
    }

    await Future.delayed(const Duration(seconds: 1));

    // Mock verification - accept any 6-digit code
    return code.length == 6 && int.tryParse(code) != null;
  }

  @override
  Future<void> disableMFA(String factorId) async {
    if (_apiClient.isOffline) {
      throw const NetworkConnectivityException(
          message: 'No internet connection');
    }

    await Future.delayed(const Duration(seconds: 1));
    // Mock disable MFA - nothing to do in mock
  }

  @override
  Future<List<String>> listMFAFactors() async {
    if (_apiClient.isOffline) {
      throw const NetworkConnectivityException(
          message: 'No internet connection');
    }

    await Future.delayed(const Duration(seconds: 1));
    // Return empty list for mock - no MFA factors enrolled by default
    return const [];
  }

  @override
  Future<void> deleteAccount() async {
    if (_apiClient.isOffline) {
      throw const NetworkConnectivityException(
          message: 'No internet connection');
    }

    await Future.delayed(const Duration(seconds: 1));

    // Mock delete account - clear local state
    _isAuthenticated = false;
    _currentUser = null;
  }
}
