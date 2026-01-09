/// Represents an authentication session
class AuthSession {
  /// The access token for the session
  final String accessToken;

  /// The user ID associated with the session
  final String userId;

  /// Creates a new [AuthSession]
  const AuthSession({
    required this.accessToken,
    required this.userId,
  });
}
