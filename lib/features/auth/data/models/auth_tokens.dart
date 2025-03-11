/// Model class representing authentication tokens
class AuthTokens {
  final String accessToken;
  final String idToken;
  final String refreshToken;
  final DateTime expiration;

  AuthTokens({
    required this.accessToken,
    required this.idToken,
    required this.refreshToken,
    required this.expiration,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['access_token'] as String,
      idToken: json['id_token'] as String,
      refreshToken: json['refresh_token'] as String,
      expiration: DateTime.fromMillisecondsSinceEpoch(
        json['expiration'] as int,
      ),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'access_token': accessToken,
      'id_token': idToken,
      'refresh_token': refreshToken,
      'expiration': expiration.millisecondsSinceEpoch,
    };
  }
}
