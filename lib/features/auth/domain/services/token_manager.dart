import 'dart:async';
import 'dart:math';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../models/auth_session.dart';
import '../../data/providers/auth_data_providers.dart';
import '../../../core/domain/services/connectivity_service.dart';
import '../../../core/data/services/connectivity_service_impl.dart';

part 'token_manager.g.dart';

enum FeatureAvailability {
  fullyAvailable, // Online with valid tokens
  offlineWithCache, // Offline but has valid cached data
  offlineNoCache, // Offline with no cached data
  tokenExpired, // Needs reauthentication
  unauthorized // Never authenticated
}

/// Manages authentication tokens and their lifecycle according to AWS Cognito specifications
@riverpod
class TokenManager extends _$TokenManager {
  Timer? _refreshTimer;
  Timer? _recoveryTimer;
  AuthSession? _cachedSession;
  int _refreshAttempts = 0;
  static const int _maxRefreshAttempts = 5;
  static const Duration _baseDelay = Duration(seconds: 1);
  static const Duration _refreshThreshold = Duration(minutes: 5);

  @override
  FeatureAvailability build() {
    // Watch connectivity changes through our service
    final connectivityService = ref.watch(connectivityServiceImplProvider);

    // Setup connectivity monitoring
    connectivityService.onConnectivityChanged.listen((status) async {
      if (status == NetworkStatus.connected) {
        // Try to refresh tokens when we regain connectivity
        await refreshToken();
      }
      // Update state based on new connectivity
      state = _determineAvailability(status == NetworkStatus.connected);
    });

    // Initialize and setup refresh timer
    ref.onDispose(() {
      _refreshTimer?.cancel();
      _recoveryTimer?.cancel();
    });

    // Return initial state, initialization will update it
    return FeatureAvailability.unauthorized;
  }

  Future<void> initialize() async {
    try {
      final storage = ref.read(authLocalDataSourceProvider);
      final connectivityService = ref.read(connectivityServiceImplProvider);

      // Load cached session
      final accessToken = await storage.getAuthToken();
      final idToken = await storage.getIdToken();
      final refreshToken = await storage.getRefreshToken();
      final expiresAt = await storage.getTokenExpiration();

      if (accessToken != null &&
          idToken != null &&
          refreshToken != null &&
          expiresAt != null) {
        _cachedSession = AuthSession(
          accessToken: accessToken,
          idToken: idToken,
          refreshToken: refreshToken,
          expiresAt: expiresAt,
        );

        // Setup refresh timer if we have a valid session
        _scheduleTokenRefresh();
      }

      // Get current connectivity status
      final networkStatus = await connectivityService.checkConnectivity();

      // Update state based on loaded session and connectivity
      state = _determineAvailability(networkStatus == NetworkStatus.connected);
    } catch (e) {
      debugPrint('Failed to initialize session: $e');
      state = FeatureAvailability.unauthorized;
    }
  }

  FeatureAvailability _determineAvailability(bool isOnline) {
    if (_cachedSession == null) {
      return FeatureAvailability.unauthorized;
    }

    final hasValidTokens = _cachedSession!.expiresAt
        .isAfter(DateTime.now().add(_refreshThreshold));

    if (isOnline && hasValidTokens) {
      return FeatureAvailability.fullyAvailable;
    } else if (!isOnline && hasValidTokens) {
      return FeatureAvailability.offlineWithCache;
    } else if (!isOnline) {
      return FeatureAvailability.offlineNoCache;
    } else {
      return FeatureAvailability.tokenExpired;
    }
  }

  Duration _getBackoffDelay() {
    if (_refreshAttempts == 0) return Duration.zero;
    final delay = _baseDelay * pow(2, _refreshAttempts - 1);
    return delay + Duration(milliseconds: Random().nextInt(1000)); // Add jitter
  }

  void _scheduleTokenRefresh() {
    _refreshTimer?.cancel();

    if (_cachedSession == null) return;

    // Schedule refresh at 75% of token lifetime per AWS best practices
    final tokenLifetime = _cachedSession!.expiresAt.difference(DateTime.now());
    final refreshAt = DateTime.now().add(tokenLifetime * 0.75);

    if (refreshAt.isAfter(DateTime.now())) {
      final delay = refreshAt.difference(DateTime.now());
      _refreshTimer = Timer(delay, refreshToken);
      debugPrint('Token refresh scheduled for ${refreshAt.toIso8601String()}');
    } else {
      // Token is already past refresh point
      refreshToken();
    }
  }

  void _scheduleRecoveryAttempt() {
    _recoveryTimer?.cancel();
    final delay = _getBackoffDelay();
    _recoveryTimer = Timer(delay, refreshToken);
    debugPrint('Recovery attempt scheduled in ${delay.inSeconds} seconds');
  }

  Future<void> refreshToken() async {
    final connectivityService = ref.read(connectivityServiceImplProvider);
    final isOnline = await connectivityService.hasConnectivity;

    if (!isOnline) {
      // Don't attempt refresh when offline
      return;
    }

    try {
      final storage = ref.read(authLocalDataSourceProvider);
      final remote = ref.read(authRemoteDataSourceProvider);
      final refreshToken = await storage.getRefreshToken();

      if (refreshToken == null) {
        state = FeatureAvailability.unauthorized;
        return;
      }

      if (_refreshAttempts >= _maxRefreshAttempts) {
        await clearSession();
        return;
      }

      // Apply exponential backoff
      final backoffDelay = _getBackoffDelay();
      if (backoffDelay > Duration.zero) {
        await Future.delayed(backoffDelay);
      }

      final newSession = await remote.refreshToken();
      await storage.saveAuthData(
        newSession.accessToken,
        newSession.refreshToken,
        expiresAt: newSession.expiresAt,
        idToken: newSession.idToken,
      );

      _cachedSession = newSession;
      _refreshAttempts = 0; // Reset attempts on success
      _scheduleTokenRefresh();

      // Get current connectivity status
      final networkStatus = await connectivityService.checkConnectivity();
      state = _determineAvailability(networkStatus == NetworkStatus.connected);
    } catch (e) {
      _refreshAttempts++;
      debugPrint('Token refresh failed (attempt $_refreshAttempts): $e');

      if (_refreshAttempts < _maxRefreshAttempts) {
        _scheduleRecoveryAttempt();
      }
    }
  }

  Future<void> clearSession() async {
    final storage = ref.read(authLocalDataSourceProvider);
    await storage.clearAuthData();
    _cachedSession = null;
    _refreshTimer?.cancel();
    _recoveryTimer?.cancel();
    _refreshAttempts = 0;
    state = FeatureAvailability.unauthorized;
  }

  // Public methods for feature checks
  bool get canPerformOnlineOperations =>
      state == FeatureAvailability.fullyAvailable;

  bool get hasValidTokens =>
      _cachedSession?.expiresAt
          .isAfter(DateTime.now().add(_refreshThreshold)) ??
      false;

  bool get isOffline =>
      state == FeatureAvailability.offlineWithCache ||
      state == FeatureAvailability.offlineNoCache;
}
