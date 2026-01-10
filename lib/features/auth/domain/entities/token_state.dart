import 'package:freezed_annotation/freezed_annotation.dart';

part 'token_state.freezed.dart';

@freezed
class TokenState with _$TokenState {
  const factory TokenState.valid({
    required String accessToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) = ValidTokenState;

  const factory TokenState.expired({
    required String refreshToken,
  }) = ExpiredTokenState;

  const factory TokenState.refreshing({
    required String refreshToken,
  }) = RefreshingTokenState;

  const factory TokenState.error({
    required String message,
    required bool requiresReauthentication,
  }) = ErrorTokenState;

  const factory TokenState.empty() = EmptyTokenState;
}
