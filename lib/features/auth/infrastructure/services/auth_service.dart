
/// Service for handling authentication operations
///
/// NOTE: This service has been stubbed out after removing AWS Cognito dependencies.
/// The actual authentication should be handled by SupabaseAuthRemoteDataSourceImpl
/// which uses Supabase's authentication system.
class AuthService {
  String? _token;
  String? _username;
  bool _isAuthenticated = false;

  /// Creates a new [AuthService]
  AuthService();

  /// Get the current authentication token
  String? get token => _token;

  /// Get the current username
  String? get username => _username;

  /// Check if a user is authenticated
  bool get isAuthenticated => _isAuthenticated;

  /// Initialize the auth service
  Future<void> initialize() async {
    // Stub: Check for existing session
  }

  /// Sign in with username and password
  Future<bool> signIn({
    required String username,
    required String password,
  }) async {
    throw UnimplementedError(
      'signIn is not implemented in AuthService. '
      'Use SupabaseAuthRemoteDataSourceImpl instead.',
    );
  }

  /// Refresh the current session
  Future<bool> refreshSession() async {
    throw UnimplementedError(
      'refreshSession is not implemented in AuthService. '
      'Use SupabaseAuthRemoteDataSourceImpl instead.',
    );
  }

  /// Sign out the current user
  Future<void> signOut() async {
    _token = null;
    _username = null;
    _isAuthenticated = false;
  }
}
