import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/core/security/security_manager.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:flutter/foundation.dart';

/// Implementation of [AuthRepository] that coordinates between local and remote data sources
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final SecurityManager securityManager;

  /// Creates a new [AuthRepositoryImpl] with the given data sources
  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.securityManager,
  });

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Check for rate limiting
      await securityManager.checkLoginAttempts();

      final (user, token) = await remoteDataSource.signIn(email, password);

      // Check if this is a new device
      if (!await securityManager.isKnownDevice()) {
        // In a real app, you might want to require additional verification here
        await securityManager.registerDevice();
      }

      // With Cognito, we don't need to store refresh tokens as the SDK handles that
      await localDataSource.saveAuthData(token, token);
      await localDataSource.cacheUser(user);
      await securityManager.resetLoginAttempts();
      return user;
    } on AuthException {
      // Record the failed attempt but preserve the original error
      await securityManager.recordFailedLoginAttempt();
      rethrow;
    } catch (e) {
      await securityManager.recordFailedLoginAttempt();
      throw AuthException('Failed to sign in: ${e.toString()}');
    }
  }

  @override
  Future<(User, bool)> register({
    required String email,
    required String password,
    required String name,
  }) async {
    debugPrint('AuthRepositoryImpl: Starting registration');
    debugPrint('AuthRepositoryImpl: Registering with email: $email');

    final (user, needsVerification) = await remoteDataSource.register(
      email: email,
      password: password,
      name: name,
    );

    debugPrint(
        'AuthRepositoryImpl: Registration successful, caching user data');
    // Cache the user data even though they're not fully verified yet
    await localDataSource.cacheUser(user);

    debugPrint(
        'AuthRepositoryImpl: User cached, needs verification: $needsVerification');
    return (user, needsVerification);
  }

  @override
  Future<void> signOut() async {
    try {
      await remoteDataSource.signOut();
    } finally {
      await localDataSource.clearCache();
      // Don't remove the device from known devices, but clear other security data
      await securityManager.resetLoginAttempts();
    }
  }

  @override
  Future<User?> getCurrentUser() async {
    try {
      // First try to get user from cache
      final cachedUser = await localDataSource.getCachedUser();
      if (cachedUser != null &&
          await localDataSource.hasValidSession() &&
          await securityManager.isKnownDevice()) {
        return cachedUser;
      }

      // If not in cache or session invalid, try to get from remote
      final remoteUser = await remoteDataSource.getCurrentUser();
      if (remoteUser != null) {
        await localDataSource.cacheUser(remoteUser);
      }
      return remoteUser;
    } catch (e) {
      return null;
    }
  }

  @override
  Future<bool> isAuthenticated() async {
    try {
      if (!await securityManager.isKnownDevice()) {
        return false;
      }

      if (!await localDataSource.hasValidSession()) {
        return false;
      }

      final user = await getCurrentUser();
      return user != null;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await remoteDataSource.sendPasswordResetEmail(email);
  }

  @override
  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await remoteDataSource.confirmForgotPassword(email, code, newPassword);
  }

  @override
  Future<String?> getAccessToken() async {
    if (!await securityManager.isKnownDevice()) {
      return null;
    }

    if (!await localDataSource.hasValidSession()) {
      return null;
    }
    return localDataSource.getAuthToken();
  }

  @override
  Future<User> updateUserProfile({
    String? name,
    String? email,
    String? photoUrl,
  }) async {
    // This would typically call a remote endpoint to update the user profile
    // For now, we'll just return the current user
    final currentUser = await getCurrentUser();
    if (currentUser == null) {
      throw AuthException('No authenticated user');
    }
    return currentUser;
  }

  @override
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    // Not implemented yet
    throw UnimplementedError('Password change not implemented yet');
  }

  @override
  Future<void> verifyEmail(String code, String email) async {
    debugPrint('AuthRepositoryImpl: Starting email verification');
    debugPrint('AuthRepositoryImpl: Verifying email: $email');

    // Get cached user to ensure we have the right context
    final cachedUser = await localDataSource.getCachedUser();
    debugPrint('AuthRepositoryImpl: Cached user: $cachedUser');

    if (cachedUser?.email != email) {
      debugPrint(
          'AuthRepositoryImpl: Warning - Verification email does not match cached user');
    }

    try {
      await remoteDataSource.verifyEmail(code, email);
      debugPrint('AuthRepositoryImpl: Email verification successful');

      // After successful verification, try to get fresh user data
      try {
        final verifiedUser = await remoteDataSource.getCurrentUser();
        if (verifiedUser != null) {
          await localDataSource.cacheUser(verifiedUser);
          debugPrint(
              'AuthRepositoryImpl: Updated cached user after verification');
        } else if (cachedUser != null) {
          // If we can't get fresh data, use cached user but mark as verified
          debugPrint(
              'AuthRepositoryImpl: Using cached user data after verification');
          await localDataSource.cacheUser(cachedUser);
        } else {
          throw AuthException('No user data available after verification');
        }
      } catch (e) {
        debugPrint('AuthRepositoryImpl: Failed to get fresh user data: $e');
        if (cachedUser != null) {
          // If getting fresh data fails, use cached user
          debugPrint('AuthRepositoryImpl: Falling back to cached user data');
          await localDataSource.cacheUser(cachedUser);
        } else {
          throw AuthException(
              'Failed to maintain user state after verification');
        }
      }
    } catch (e) {
      debugPrint('AuthRepositoryImpl: Email verification failed: $e');
      throw AuthException('Failed to verify email: ${e.toString()}');
    }
  }

  @override
  Future<void> resendVerificationEmail() async {
    await remoteDataSource.resendVerificationEmail();
  }

  @override
  Future<String> enableTwoFactor() async {
    throw UnimplementedError(
        'Two-factor authentication is not supported with Cognito');
  }

  @override
  Future<void> disableTwoFactor(String code) async {
    throw UnimplementedError(
        'Two-factor authentication is not supported with Cognito');
  }

  @override
  Future<void> verifyTwoFactor(String code) async {
    throw UnimplementedError(
        'Two-factor authentication is not supported with Cognito');
  }

  @override
  Future<bool> refreshToken() async {
    await remoteDataSource.refreshToken();
    return true;
  }

  /// Get list of known devices for the current user
  Future<List<Map<String, dynamic>>> getKnownDevices() {
    return securityManager.getKnownDevices();
  }

  /// Remove a device from the list of known devices
  Future<void> removeDevice(String deviceId) {
    return securityManager.removeDevice(deviceId);
  }

  /// Get security event history
  Future<List<Map<String, dynamic>>> getSecurityEvents() {
    return securityManager.getSecurityEvents();
  }

  /// Handle authentication exceptions
  AppException _handleAuthException(dynamic error) {
    if (error is AppException) {
      return error;
    }

    return UnknownException(
      message: error.toString(),
    );
  }

  @override
  Future<bool> isSignedIn() async {
    try {
      if (!await securityManager.isKnownDevice()) {
        return false;
      }

      final user = await getCurrentUser();
      return user != null && await localDataSource.hasValidSession();
    } catch (e) {
      return false;
    }
  }
}
