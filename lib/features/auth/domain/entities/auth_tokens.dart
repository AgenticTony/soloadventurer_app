class AuthTokens {
  final String accessToken;
  final String idToken;
  final String refreshToken;
  final DateTime expiration;

  const AuthTokens({
    required this.accessToken,
    required this.idToken,
    required this.refreshToken,
    required this.expiration,
  });

  factory AuthTokens.fromJson(Map<String, dynamic> json) {
    return AuthTokens(
      accessToken: json['accessToken'],
      idToken: json['idToken'],
      refreshToken: json['refreshToken'],
      expiration: DateTime.parse(json['expiration']),
    );
  }

  Map<String, dynamic> toJson() => {
        'accessToken': accessToken,
        'idToken': idToken,
        'refreshToken': refreshToken,
        'expiration': expiration.toIso8601String(),
      };
}
