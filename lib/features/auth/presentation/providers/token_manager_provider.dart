import 'dart:async';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/token_state.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../data/providers/auth_data_providers.dart';

part 'token_manager_provider.g.dart';

/// DEPRECATED: This presentation layer TokenManager is deprecated.
///
/// Please use the domain layer TokenManager instead:
/// `lib/features/auth/domain/services/token_manager.dart`
///
/// The domain TokenManager uses FeatureAvailability enum and is properly
/// initialized in bootstrap. This presentation layer wrapper is kept for
/// backward compatibility but should not be used for new code.
@Deprecated(
  'Use domain TokenManager from lib/features/auth/domain/services/token_manager.dart instead. '
  'This wrapper is deprecated and will be removed in a future version.',
)
@riverpod
class TokenManager extends _$TokenManager {
  late final AuthRepository _authRepository;
  Timer? _refreshTimer;
  static const _refreshBuffer = Duration(minutes: 5);

  @override
  AsyncValue<TokenState> build() {
    _authRepository = ref.read(authRepositoryProvider);
    ref.onDispose(() {
      _refreshTimer?.cancel();
    });
    return const AsyncValue.data(TokenState.empty());
  }

  Future<void> initializeToken() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // TODO: Implement proper token initialization
      // The current AuthRepository doesn't expose sessions directly
      // For now, return empty state
      return const TokenState.empty();
    });
  }

  Future<void> refreshToken() async {
    final currentState = state.value;
    if (currentState == null) return;

    // Only refresh if we have a refresh token
    final refreshToken = currentState.mapOrNull(
      valid: (state) => state.refreshToken,
      expired: (state) => state.refreshToken,
      refreshing: (state) => state.refreshToken,
    );
    if (refreshToken == null) return;

    state = AsyncValue.data(TokenState.refreshing(refreshToken: refreshToken));

    state = await AsyncValue.guard(() async {
      // TODO: Implement proper token refresh
      // The current AuthRepository doesn't expose refreshSession
      // For now, return error state requiring reauthentication
      return const TokenState.error(
        message: 'Token refresh not yet implemented',
        requiresReauthentication: true,
      );
    });
  }

  void _scheduleTokenRefresh(DateTime expiresAt) {
    _refreshTimer?.cancel();

    final refreshAt = expiresAt.subtract(_refreshBuffer);
    final now = DateTime.now();

    if (refreshAt.isBefore(now)) {
      // Token is already close to expiration, refresh immediately
      refreshToken();
    } else {
      _refreshTimer = Timer(refreshAt.difference(now), refreshToken);
    }
  }

  void clearToken() {
    _refreshTimer?.cancel();
    state = const AsyncValue.data(TokenState.empty());
  }
}
