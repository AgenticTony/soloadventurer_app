import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/app/di/service_locator.dart';

/// Token refresh threshold (15 minutes before expiry)
const _tokenRefreshThreshold = Duration(minutes: 15);

/// Token provider that manages token lifecycle
class TokenNotifier extends StateNotifier<AsyncValue<AuthSession?>> {
  final AuthRepository _authRepository;
  Timer? _refreshTimer;

  TokenNotifier({
    required AuthRepository authRepository,
  })  : _authRepository = authRepository,
        super(const AsyncValue.data(null)) {
    _initialize();
  }

  @override
  void dispose() {
    _refreshTimer?.cancel();
    super.dispose();
  }

  Future<void> _initialize() async {
    final user = await _authRepository.getCurrentUser();
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
      final session = await _authRepository.refreshToken();
      state = AsyncValue.data(session);
      _scheduleTokenRefresh();
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
      // Don't schedule refresh on error - let the auth system handle reauth
    }
  }

  void updateSession(AuthSession session) {
    state = AsyncValue.data(session);
    _scheduleTokenRefresh();
  }

  void clearSession() {
    _refreshTimer?.cancel();
    state = const AsyncValue.data(null);
  }
}

/// Provider for token management
final tokenProvider =
    StateNotifierProvider<TokenNotifier, AsyncValue<AuthSession?>>((ref) {
  return TokenNotifier(
    authRepository: getIt<AuthRepository>(),
  );
});

/// Provider for the current access token
final accessTokenProvider = Provider<String?>((ref) {
  return ref.watch(tokenProvider).value?.accessToken;
});

/// Provider for token validity
final hasValidTokensProvider = Provider<bool>((ref) {
  final session = ref.watch(tokenProvider).value;
  if (session == null) return false;
  return DateTime.now().isBefore(session.expiresAt);
});
