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

      final (user, token, refreshToken, expiresAt) =
          await remoteDataSource.signIn(email, password);

      // Check if this is a new device
      if (!await securityManager.isKnownDevice()) {
        // In a real app, you might want to require additional verification here
        await securityManager.registerDevice();
      }

      await localDataSource.saveAuthData(token, refreshToken,
          expiresAt: expiresAt);
      await localDataSource.cacheUser(user);
      await securityManager.resetLoginAttempts();
      return user;
    } catch (e) {
      await securityManager.recordFailedLoginAttempt();
      throw AuthException('Failed to sign in: ${e.toString()}');
    }
  }

  @override
  Future<User> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    try {
      debugPrint('AuthRepositoryImpl: Starting registration');
      final (user, token, refreshToken, expiresAt) =
          await remoteDataSource.register(email, password, name);

      debugPrint(
          'AuthRepositoryImpl: Registration successful, registering device');
      // Register this device as a known device
      await securityManager.registerDevice();

      debugPrint('AuthRepositoryImpl: Saving auth data and caching user');
      await localDataSource.saveAuthData(token, refreshToken,
          expiresAt: expiresAt);
      await localDataSource.cacheUser(user);
      debugPrint('AuthRepositoryImpl: Registration complete');
      return user;
    } catch (e) {
      debugPrint('AuthRepositoryImpl: Registration failed: $e');
      throw AuthException('Failed to register: ${e.toString()}');
    }
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
        return await refreshToken();
      }
      return true;
    } catch (e) {
      return false;
    }
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    await remoteDataSource.forgotPassword(email);
  }

  @override
  Future<void> confirmPasswordReset({
    required String email,
    required String code,
    required String newPassword,
  }) async {
    await remoteDataSource.confirmPasswordReset(
      email: email,
      code: code,
      newPassword: newPassword,
    );
  }

  @override
  Future<String?> getAccessToken() async {
    if (!await securityManager.isKnownDevice()) {
      return null;
    }

    if (!await localDataSource.hasValidSession()) {
      await refreshToken();
    }
    return localDataSource.getAuthToken();
  }

  @override
  Future<bool> refreshToken() async {
    try {
      if (!await securityManager.isKnownDevice()) {
        return false;
      }

      final refreshToken = await localDataSource.getRefreshToken();
      if (refreshToken == null) {
        return false;
      }

      final (newToken, expiresAt) =
          await remoteDataSource.refreshToken(refreshToken);
      await localDataSource.saveAuthData(newToken, refreshToken,
          expiresAt: expiresAt);
      return true;
    } catch (e) {
      await localDataSource.clearAuthData();
      return false;
    }
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
    if (!await securityManager.isKnownDevice()) {
      throw AuthException('Unknown device detected');
    }

    await remoteDataSource.changePassword(
      currentPassword: currentPassword,
      newPassword: newPassword,
    );
  }

  @override
  Future<void> verifyEmail(String code) async {
    await remoteDataSource.verifyEmail(code);
  }

  @override
  Future<void> resendVerificationEmail() async {
    await remoteDataSource.resendVerificationEmail();
  }

  @override
  Future<String> enableTwoFactor() async {
    if (!await securityManager.isKnownDevice()) {
      throw AuthException('Unknown device detected');
    }
    return await remoteDataSource.enableTwoFactor();
  }

  @override
  Future<void> disableTwoFactor(String code) async {
    if (!await securityManager.isKnownDevice()) {
      throw AuthException('Unknown device detected');
    }
    await remoteDataSource.disableTwoFactor(code);
  }

  @override
  Future<void> verifyTwoFactor(String code) async {
    final (token, refreshToken, expiresAt) =
        await remoteDataSource.verifyTwoFactor(code);
    await localDataSource.saveAuthData(token, refreshToken,
        expiresAt: expiresAt);
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
