import 'package:soloadventurer/core/errors/exceptions.dart';
import 'package:soloadventurer/core/storage/secure_storage_adapter.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_local_data_source.dart';
import 'package:soloadventurer/features/auth/data/datasources/auth_remote_data_source.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/refresh_queue_manager.dart';

/// Implementation of [AuthRepository] that coordinates between local and remote data sources
class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource remoteDataSource;
  final AuthLocalDataSource localDataSource;
  final SecurityManagerAdapter securityManager;
  final RefreshQueueManager? refreshQueueManager;

  /// Creates a new [AuthRepositoryImpl] with the given data sources
  ///
  /// The [refreshQueueManager] is optional. When provided, it enables
  /// robust token refresh with retry logic and queue management.
  /// When not provided, falls back to simple refresh without retries.
  const AuthRepositoryImpl({
    required this.remoteDataSource,
    required this.localDataSource,
    required this.securityManager,
    this.refreshQueueManager,
  });

  @override
  Future<User> signInWithEmailAndPassword(String email, String password) async {
    try {
      // Check for rate limiting
      await securityManager.checkLoginAttempts();

      final (user, session) = await remoteDataSource.signIn(email, password);

      // Check if this is a new device
      if (!await securityManager.isKnownDevice()) {
        // In a real app, you might want to require additional verification here
        await securityManager.registerDevice();
      }

      // Save complete session data including expiresAt
      try {
        await localDataSource.saveAuthData(
          session.accessToken,
          session.refreshToken,
          expiresAt: session.expiresAt,
          idToken: session.idToken,
        );
      } catch (storageError) {
        // Re-throw to fail the whole sign-in
        rethrow;
      }
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

    final (user, needsVerification) = await remoteDataSource.register(
      email: email,
      password: password,
      name: name,
    );

    // Cache the user data even though they're not fully verified yet
    await localDataSource.cacheUser(user);

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
      throw const AuthException('No authenticated user');
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

    // Get cached user to ensure we have the right context
    final cachedUser = await localDataSource.getCachedUser();

    if (cachedUser?.email != email) {
    }

    try {
      await remoteDataSource.verifyEmail(code, email);

      // After successful verification, try to get fresh user data
      try {
        final verifiedUser = await remoteDataSource.getCurrentUser();
        if (verifiedUser != null) {
          await localDataSource.cacheUser(verifiedUser);
        } else if (cachedUser != null) {
          // If we can't get fresh data, use cached user but mark as verified
          await localDataSource.cacheUser(cachedUser);
        } else {
          throw const AuthException(
              'No user data available after verification');
        }
      } catch (e) {
        if (cachedUser != null) {
          // If getting fresh data fails, use cached user
          await localDataSource.cacheUser(cachedUser);
        } else {
          throw const AuthException(
              'Failed to maintain user state after verification');
        }
      }
    } catch (e) {
      throw AuthException('Failed to verify email: ${e.toString()}');
    }
  }

  @override
  Future<void> resendVerificationEmail() async {
    await remoteDataSource.resendVerificationEmail();
  }

  @override
  Future<String> enableTwoFactor() async {
    try {

      // Setup MFA - returns (factorId, qrCode, secret)
      final (factorId, qrCode, secret) = await remoteDataSource.setupMFA();

      // Return the factorId for reference
      // The QR code and secret can be obtained from the data source if needed for UI
      return factorId;
    } catch (e) {
      throw AuthException('Failed to enable two-factor authentication: ${e.toString()}');
    }
  }

  @override
  Future<void> disableTwoFactor(String code) async {
    try {

      // Note: The interface parameter is named "code" but it's actually the factorId
      // This is a naming inconsistency in the original interface
      await remoteDataSource.disableMFA(code);

    } catch (e) {
      throw AuthException('Failed to disable two-factor authentication: ${e.toString()}');
    }
  }

  @override
  Future<void> verifyTwoFactor(String code) async {
    try {

      // Verify the MFA code
      final success = await remoteDataSource.verifyMFA(code);

      if (!success) {
        throw AuthException('Invalid verification code');
      }

    } catch (e) {
      throw AuthException('Failed to verify two-factor authentication: ${e.toString()}');
    }
  }

  @override
  Future<AuthSession> refreshToken() async {
    // Use RefreshQueueManager if available for robust refresh with retry logic
    if (refreshQueueManager != null) {
      try {
        final queuedResult = await refreshQueueManager!.enqueueRefresh();
        if (queuedResult.success && queuedResult.session != null) {
          // Update session storage after successful refresh
          await _saveSessionToStorage(queuedResult.session!);
          return queuedResult.session!;
        } else {
          throw queuedResult.error ??
              const AuthException(
                'Token refresh failed',
                code: 'REFRESH_FAILED',
              );
        }
      } on AuthException {
        rethrow;
      } catch (e) {
        throw AuthException('Failed to refresh token: ${e.toString()}');
      }
    }

    // Fallback to simple refresh without retry logic
    return performBasicTokenRefresh();
  }

  @override
  Future<AuthSession> performBasicTokenRefresh() async {
    try {
      final session = await remoteDataSource.refreshToken();
      await _saveSessionToStorage(session);
      return session;
    } catch (e) {
      throw AuthException('Failed to refresh token: ${e.toString()}');
    }
  }

  /// Saves the session tokens to local storage
  Future<void> _saveSessionToStorage(AuthSession session) async {
    await localDataSource.saveAuthData(
      session.accessToken,
      session.refreshToken,
      expiresAt: session.expiresAt,
      idToken: session.idToken,
    );
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

  @override
  Future<User> registerWithEmailAndPassword(
    String email,
    String password,
    String name,
  ) async {
    final (user, _) = await register(
      email: email,
      password: password,
      name: name,
    );
    return user;
  }

  @override
  Future<AuthSession?> getSession() async {
    try {
      // Check if user is authenticated
      if (!await securityManager.isKnownDevice()) {
        return null;
      }

      // Check if session is valid
      if (!await localDataSource.hasValidSession()) {
        return null;
      }

      // Get all session components
      final accessToken = await localDataSource.getAuthToken();
      final idToken = await localDataSource.getIdToken();
      final refreshToken = await localDataSource.getRefreshToken();
      final expiresAt = await localDataSource.getTokenExpiration();

      // Validate we have all required data
      if (accessToken == null || refreshToken == null || expiresAt == null) {
        return null;
      }

      // Construct and return AuthSession
      return AuthSession(
        accessToken: accessToken,
        idToken: idToken ?? '',
        refreshToken: refreshToken,
        expiresAt: expiresAt,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> deleteAccount() async {
    try {

      // Call remote data source to delete account
      // This will invoke an Edge Function for Supabase implementation
      await remoteDataSource.deleteAccount();

      // Sign out the user and clear local data
      await localDataSource.clearCache();
      await securityManager.resetLoginAttempts();

    } catch (e) {
      throw AuthException('Failed to delete account: ${e.toString()}');
    }
  }
}
