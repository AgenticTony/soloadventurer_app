/// Authentication error types aligned with Supabase Auth errors
///
/// These error types map to common Supabase authentication error scenarios
/// while providing type-safe error handling throughout the application.
///
/// Based on Supabase Auth error codes:
/// https://supabase.com/docs/guides/auth/debugging/error-codes
enum AuthErrorType {
  /// Invalid email/password combination
  /// Supabase codes: invalid_credentials, email_not_confirmed
  invalidCredentials,

  /// User account does not exist
  /// Supabase codes: user_not_found
  userNotFound,

  /// Email already registered to another account
  /// Supabase codes: user_already_exists, email_exists
  emailAlreadyInUse,

  /// Session is invalid or expired
  /// Supabase codes: invalid_token, expired_token, unauthorized
  unauthorized,

  /// Network connectivity issue or timeout
  /// Supabase codes: network_error, timeout
  network,

  /// Supabase internal server error
  /// Supabase codes: 500, 502, 503, server_error
  server,

  /// Too many authentication attempts
  /// Supabase codes: rate_limit, too_many_requests
  rateLimited,

  /// Unknown or unexpected error
  /// Fallback for errors that don't match other types
  unknown,
}
