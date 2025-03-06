import 'package:soloadventurer/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:soloadventurer/features/auth/data/models/user_model.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:flutter/foundation.dart';
import 'package:soloadventurer/core/api/client/api_client.dart';

/// Mock implementation of [AuthRemoteDataSource] for testing
class MockAuthRemoteDataSource implements AuthRemoteDataSource {
  final ApiClient _apiClient;
  UserModel? _currentUser;
  bool _isAuthenticated = false;

  /// Creates a new [MockAuthRemoteDataSource]
  MockAuthRemoteDataSource(this._apiClient);

  @override
  Future<(UserModel, String)> signIn(String email, String password) async {
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
      return (_currentUser!, 'mock-auth-token');
    }
    throw AuthException('Invalid credentials');
  }

  @override
  Future<(UserModel, bool)> register({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      if (!email.contains('@')) {
        throw AuthException('Invalid email format');
      }

      if (password.length < 6) {
        throw AuthException('Password must be at least 6 characters');
      }

      if (name.isEmpty) {
        throw AuthException('Name is required');
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
      throw AuthException('Registration failed');
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
      throw AuthException('Invalid email format');
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
      throw AuthException('Invalid verification code');
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
  Future<void> refreshToken() async {
    if (!_isAuthenticated) {
      throw AuthException('Not authenticated');
    }
    await Future.delayed(const Duration(seconds: 1));
    // Mock token refresh - in a real implementation this would refresh the token
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
      throw AuthException('Invalid reset code');
    }
    if (newPassword.length < 8) {
      throw AuthException('Password must be at least 8 characters long');
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
      throw AuthException('Invalid email format');
    }
    if (newPassword.length < 8) {
      throw AuthException('Password must be at least 8 characters long');
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
      throw AuthException('Invalid email format');
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Simulate email validation
    if (!email.contains('@')) {
      throw AuthException('Invalid email format');
    }
    // In a real implementation, this would send an email
    debugPrint('Password reset email sent to: $email');
  }
}
