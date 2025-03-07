import 'package:flutter/foundation.dart';
import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import '../../domain/models/auth_session.dart';
import '../../../../features/core/errors/exceptions.dart';

/// Service for handling authentication operations with AWS Cognito
class AuthService {
  final CognitoUserPool _userPool;
  CognitoUser? _cognitoUser;
  CognitoUserSession? _session;

  /// Creates a new [AuthService] with the given user pool
  AuthService({
    required CognitoUserPool userPool,
  }) : _userPool = userPool;

  /// Get the current authentication token
  String? get token => _session?.getAccessToken().getJwtToken();

  /// Get the current username
  String? get username => _cognitoUser?.username;

  /// Check if a user is authenticated
  bool get isAuthenticated => _session?.isValid() ?? false;

  /// Initialize the auth service
  Future<void> initialize() async {
    // Check for existing session
    if (_cognitoUser != null) {
      try {
        _session = await _cognitoUser!.getSession();
      } catch (e) {
        debugPrint('Failed to restore session: $e');
      }
    }
  }

  /// Sign in with username and password
  Future<bool> signIn({
    required String username,
    required String password,
  }) async {
    try {
      debugPrint('Attempting to sign in user: $username');
      _cognitoUser = CognitoUser(username, _userPool);

      final authDetails = AuthenticationDetails(
        username: username,
        password: password,
      );

      _session = await _cognitoUser!.authenticateUser(authDetails);

      if (_session == null) {
        throw const AuthException(
          'Unable to sign in. Please try again.',
          code: 'AUTHENTICATION_FAILED',
        );
      }

      debugPrint('Sign in successful');
      return true;
    } catch (e) {
      debugPrint('Sign in failed: $e');
      _session = null;
      _cognitoUser = null;
      return false;
    }
  }

  /// Refresh the current session
  Future<bool> refreshSession() async {
    if (_cognitoUser == null || _session == null) {
      return false;
    }

    try {
      _session =
          await _cognitoUser!.refreshSession(_session!.getRefreshToken()!);
      return _session?.isValid() ?? false;
    } catch (e) {
      debugPrint('Failed to refresh session: $e');
      return false;
    }
  }

  /// Sign out the current user
  Future<void> signOut() async {
    try {
      await _cognitoUser?.signOut();
    } finally {
      _session = null;
      _cognitoUser = null;
    }
  }
}
