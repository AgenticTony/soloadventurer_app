import 'package:freezed_annotation/freezed_annotation.dart';

part 'auth_session.freezed.dart';
part 'auth_session.g.dart';

/// Represents an authentication session with tokens and expiration
@freezed
class AuthSession with _$AuthSession {
  const factory AuthSession({
    required String accessToken,
    required String idToken,
    required String refreshToken,
    required DateTime expiresAt,
  }) = _AuthSession;

  factory AuthSession.fromJson(Map<String, dynamic> json) =>
      _$AuthSessionFromJson(json);
}
