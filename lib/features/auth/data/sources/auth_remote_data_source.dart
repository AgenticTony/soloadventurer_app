import 'package:soloadventurer/core/api/client/api_client.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';

/// API endpoints for authentication
class AuthEndpoints {
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String confirm = '/auth/confirm';
  static const String resendCode = '/auth/resend-code';
  static const String refreshToken = '/auth/refresh-token';
  static const String forgotPassword = '/auth/forgot-password';
  static const String resetPassword = '/auth/reset-password';
  static const String changePassword = '/auth/change-password';
  static const String userProfile = '/user/profile';
}

/// Interface for remote authentication data source
abstract class AuthRemoteDataSource {
  /// Sign in with email and password
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  });

  /// Sign up with email and password
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String username,
  });

  /// Confirm sign up with confirmation code
  Future<void> confirmSignUp({
    required String email,
    required String confirmationCode,
  });

  /// Resend confirmation code
  Future<void> resendConfirmationCode({
    required String email,
  });

  /// Refresh authentication token
  Future<Map<String, dynamic>> refreshToken({
    required String refreshToken,
  });

  /// Request password reset
  Future<void> forgotPassword({
    required String email,
  });

  /// Confirm password reset
  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  });

  /// Get user profile
  Future<User> getUserProfile();

  /// Update user profile
  Future<User> updateUserProfile({
    String? username,
    String? email,
  });

  /// Change password
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  });
}

/// Implementation of [AuthRemoteDataSource] using API client
class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final ApiClient _apiClient;

  /// Creates a new [AuthRemoteDataSourceImpl] with the given [ApiClient]
  AuthRemoteDataSourceImpl({required ApiClient apiClient})
      : _apiClient = apiClient;

  @override
  Future<Map<String, dynamic>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      return await _apiClient.post(
        AuthEndpoints.login,
        data: {
          'email': email,
          'password': password,
        },
      );
    } catch (e) {
      throw _handleAuthException(e, 'Failed to sign in');
    }
  }

  @override
  Future<Map<String, dynamic>> signUp({
    required String email,
    required String password,
    required String username,
  }) async {
    try {
      return await _apiClient.post(
        AuthEndpoints.register,
        data: {
          'email': email,
          'password': password,
          'username': username,
        },
      );
    } catch (e) {
      throw _handleAuthException(e, 'Failed to sign up');
    }
  }

  @override
  Future<void> confirmSignUp({
    required String email,
    required String confirmationCode,
  }) async {
    try {
      await _apiClient.post(
        AuthEndpoints.confirm,
        data: {
          'email': email,
          'code': confirmationCode,
        },
      );
    } catch (e) {
      throw _handleAuthException(e, 'Failed to confirm sign up');
    }
  }

  @override
  Future<void> resendConfirmationCode({
    required String email,
  }) async {
    try {
      await _apiClient.post(
        AuthEndpoints.resendCode,
        data: {
          'email': email,
        },
      );
    } catch (e) {
      throw _handleAuthException(e, 'Failed to resend confirmation code');
    }
  }

  @override
  Future<Map<String, dynamic>> refreshToken({
    required String refreshToken,
  }) async {
    try {
      return await _apiClient.post(
        AuthEndpoints.refreshToken,
        data: {
          'refreshToken': refreshToken,
        },
      );
    } catch (e) {
      throw _handleAuthException(e, 'Failed to refresh token');
    }
  }

  @override
  Future<void> forgotPassword({
    required String email,
  }) async {
    try {
      await _apiClient.post(
        AuthEndpoints.forgotPassword,
        data: {
          'email': email,
        },
      );
    } catch (e) {
      throw _handleAuthException(e, 'Failed to request password reset');
    }
  }

  @override
  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    try {
      await _apiClient.post(
        AuthEndpoints.resetPassword,
        data: {
          'email': email,
          'code': code,
          'newPassword': newPassword,
        },
      );
    } catch (e) {
      throw _handleAuthException(e, 'Failed to reset password');
    }
  }

  @override
  Future<User> getUserProfile() async {
    try {
      final data = await _apiClient.get(AuthEndpoints.userProfile);

      return _mapToUser(data);
    } catch (e) {
      throw _handleAuthException(e, 'Failed to get user profile');
    }
  }

  @override
  Future<User> updateUserProfile({
    String? username,
    String? email,
  }) async {
    try {
      final data = <String, dynamic>{};
      if (username != null) data['username'] = username;
      if (email != null) data['email'] = email;

      final responseData = await _apiClient.put(
        AuthEndpoints.userProfile,
        data: data,
      );

      return _mapToUser(responseData);
    } catch (e) {
      throw _handleAuthException(e, 'Failed to update user profile');
    }
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      await _apiClient.post(
        AuthEndpoints.changePassword,
        data: {
          'currentPassword': currentPassword,
          'newPassword': newPassword,
        },
      );
    } catch (e) {
      throw _handleAuthException(e, 'Failed to change password');
    }
  }

  /// Map API response to User entity
  ///
  /// Throws [ServerException] if required fields are missing
  User _mapToUser(Map<String, dynamic> data) {
    try {
      return User(
        id: data['id'] as String,
        email: data['email'] as String,
        username: data['username'] as String,
        createdAt: DateTime.parse(data['createdAt'] as String),
        lastLoginAt: data['lastLoginAt'] != null
            ? DateTime.parse(data['lastLoginAt'] as String)
            : null,
      );
    } catch (e) {
      throw const ServerException(
        message: 'Invalid user data received from server',
      );
    }
  }

  /// Handle authentication exceptions
  AppException _handleAuthException(dynamic error, String defaultMessage) {
    if (error is AppException) {
      return error;
    }

    return UnknownException(message: defaultMessage);
  }
}
