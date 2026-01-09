import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/app/di/service_locator.dart';

part 'token_provider.g.dart';

/// Token refresh threshold (15 minutes before expiry)
const _tokenRefreshThreshold = Duration(minutes: 15);

/// Token provider that manages token lifecycle using Riverpod 3.0 @riverpod pattern
@riverpod
class TokenManager extends _$TokenManager {
  Timer? _refreshTimer;

  @override
  AsyncValue<AuthSession?> build() {
    ref.onDispose(() {
      _refreshTimer?.cancel();
    });

    // Initialize asynchronously
    _initialize();
    return const AsyncValue.data(null);
  }

  Future<void> _initialize() async {
    final authRepository = getIt<AuthRepository>();
    final user = await authRepository.getCurrentUser();
    if (user != null && user.hasValidTokens) {
      state = AsyncValue.data(AuthSession(
        accessToken: user.accessToken!,
        idToken: user.idToken!,
        refreshToken: user.refreshToken!,
        expiresAt: user.tokenExpiresAt!,
      ));
      _scheduleTokenRefresh();
    } else {
      state = const AsyncValue.data(null);
    }
  }

  void _scheduleTokenRefresh() {
    _refreshTimer?.cancel();
    final session = state.value;
    if (session == null) return;

    final timeUntilRefresh = session.expiresAt
        .subtract(_tokenRefreshThreshold)
        .difference(DateTime.now());

    if (timeUntilRefresh.isNegative) {
      _refreshTokens();
    } else {
      _refreshTimer = Timer(timeUntilRefresh, _refreshTokens);
    }
  }

  Future<void> _refreshTokens() async {
    try {
      final authRepository = getIt<AuthRepository>();
      final session = await authRepository.refreshToken();
      state = AsyncValue.data(session);
      _scheduleTokenRefresh();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      // Don't schedule refresh on error - let the auth system handle reauth
    }
  }

  /// Update the session manually (e.g., after login)
  void updateSession(AuthSession session) {
    state = AsyncValue.data(session);
    _scheduleTokenRefresh();
  }

  /// Clear the session (e.g., after logout)
  void clearSession() {
    _refreshTimer?.cancel();
    state = const AsyncValue.data(null);
  }
}

/// Provider alias for backward compatibility
const tokenProvider = tokenManagerProvider;

/// Provider for the current access token
@riverpod
String? accessToken(AccessTokenRef ref) {
  return ref.watch(tokenManagerProvider).value?.accessToken;
}

/// Provider for token validity
@riverpod
bool hasValidTokens(HasValidTokensRef ref) {
  final session = ref.watch(tokenManagerProvider).value;
  if (session == null) return false;
  return DateTime.now().isBefore(session.expiresAt);
}
