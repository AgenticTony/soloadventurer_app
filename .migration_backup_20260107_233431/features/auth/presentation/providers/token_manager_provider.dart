import 'dart:async';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/entities/token_state.dart';
import '../../domain/repositories/auth_repository.dart';

part 'token_manager_provider.g.dart';

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
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final session = await _authRepository.getCurrentSession();
      if (session == null) return const TokenState.empty();

      final expiresAt = DateTime.now().add(
        Duration(seconds: session.accessToken.expiresIn),
      );

      _scheduleTokenRefresh(expiresAt);

      return TokenState.valid(
        accessToken: session.accessToken.jwtToken,
        refreshToken: session.refreshToken.token,
        expiresAt: expiresAt,
      );
    });
  }

  Future<void> refreshToken() async {
    final currentState = state.value;
    if (currentState == null) return;

    // Extract refresh token using Dart 3 switch expression
    final refreshToken = switch (currentState) {
      ValidTokenState(:final refreshToken) => refreshToken,
      ExpiredTokenState(:final refreshToken) => refreshToken,
      RefreshingTokenState(:final refreshToken) => refreshToken,
      _ => null,
    };
    if (refreshToken == null) return;

    state = AsyncValue.data(TokenState.refreshing(refreshToken: refreshToken));

    state = await AsyncValue.guard(() async {
      try {
        final session = await _authRepository.refreshSession(refreshToken);
        if (session == null) {
          return const TokenState.error(
            message: 'Failed to refresh token',
            requiresReauthentication: true,
          );
        }

        final expiresAt = DateTime.now().add(
          Duration(seconds: session.accessToken.expiresIn),
        );

        _scheduleTokenRefresh(expiresAt);

        return TokenState.valid(
          accessToken: session.accessToken.jwtToken,
          refreshToken: session.refreshToken.token,
          expiresAt: expiresAt,
        );
      } on CognitoClientException catch (e) {
        return TokenState.error(
          message: e.message ?? 'Unknown error occurred',
          requiresReauthentication: e.name == 'NotAuthorizedException',
        );
      }
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
