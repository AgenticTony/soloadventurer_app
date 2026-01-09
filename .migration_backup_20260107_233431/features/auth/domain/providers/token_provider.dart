import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';
import 'package:soloadventurer/features/auth/domain/models/auth_session.dart';
import 'package:soloadventurer/app/providers/auth_service_providers.dart';

part 'token_provider.g.dart';

/// Token refresh threshold (15 minutes before expiry)
const _tokenRefreshThreshold = Duration(minutes: 15);

/// Re-export of authRepositoryProvider from app/providers/auth_service_providers.dart
/// The authRepositoryProvider is now defined in app/providers/auth_service_providers.dart
final authRepositoryProvider = authRepositoryProvider;

/// Token provider that manages token lifecycle
@Riverpod(keepAlive: true)
class TokenNotifier extends _$TokenNotifier {
  Timer? _refreshTimer;

  @override
  AsyncValue<AuthSession?> build() {
    final authRepository = ref.watch(authRepositoryProvider);
    _authRepository = authRepository;
    _initialize();
    return const AsyncValue.data(null);
  }

  late final AuthRepository _authRepository;

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

/// Provider for the current access token
@riverpod
String? accessToken(Ref ref) {
  return ref.watch(tokenNotifierProvider).value?.accessToken;
}

/// Provider for token validity
@riverpod
bool hasValidTokens(Ref ref) {
  final session = ref.watch(tokenNotifierProvider).value;
  if (session == null) return false;
  return DateTime.now().isBefore(session.expiresAt);
}
