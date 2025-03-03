import 'package:amazon_cognito_identity_dart_2/cognito.dart';
import 'package:flutter/foundation.dart';
import 'package:soloadventurer/services/secure_storage_service.dart';

class AuthService {
  static const String _userPoolId = 'us-east-1_vNhmt3a4G';
  static const String _clientId = '1g38ds6cnuf9cbtdatbbfom6hq';
  static const String _identityPoolId = '';
  static const String _region = 'us-east-1';

  late final CognitoUserPool _userPool;
  CognitoUser? _cognitoUser;
  CognitoUserSession? _session;
  final SecureStorageService _secureStorage = SecureStorageService();

  // Singleton pattern
  static final AuthService _instance = AuthService._internal();

  factory AuthService() {
    return _instance;
  }

  AuthService._internal() {
    _userPool = CognitoUserPool(_userPoolId, _clientId);
  }

  Future<void> initialize() async {
    try {
      final username = await _secureStorage.getUsername();

      if (username != null) {
        _cognitoUser = CognitoUser(username, _userPool);

        // Try to get session from keychain
        try {
          _session = await _cognitoUser!.getSession();
          if (_session != null && _session!.isValid()) {
            debugPrint('User has a valid session');
            // Store tokens in secure storage
            await _storeTokens(_session!);
          } else {
            debugPrint('Session is invalid or expired');
            _cognitoUser = null;
            _session = null;
            await _secureStorage.clearAuthData();
          }
        } catch (e) {
          debugPrint('Error getting session: $e');
          _cognitoUser = null;
          _session = null;
          await _secureStorage.clearAuthData();
        }
      }
    } catch (e) {
      debugPrint('Error initializing auth service: $e');
    }
  }

  Future<void> _storeTokens(CognitoUserSession session) async {
    await _secureStorage.storeAuthToken(session.accessToken.jwtToken ?? '');
    await _secureStorage.storeRefreshToken(session.refreshToken?.token ?? '');

    // Store additional token information if needed
    await _secureStorage.storeValue('id_token', session.idToken.jwtToken ?? '');
    await _secureStorage.storeValue('token_expiry',
        DateTime.now().add(const Duration(seconds: 3600)).toString());
  }

  bool get isAuthenticated => _session != null && _session!.isValid();

  String? get username => _cognitoUser?.username;

  String? get token => _session?.accessToken.jwtToken;

  Future<bool> signUp({
    required String username,
    required String password,
    required String email,
    required String firstName,
    required String lastName,
    required String displayName,
  }) async {
    try {
      final userAttributes = [
        AttributeArg(name: 'email', value: email),
        AttributeArg(name: 'given_name', value: firstName),
        AttributeArg(name: 'family_name', value: lastName),
        AttributeArg(name: 'custom:displayName', value: displayName),
      ];

      final result = await _userPool.signUp(
        username,
        password,
        userAttributes: userAttributes,
      );

      _cognitoUser = result.user;
      debugPrint('Sign up successful for user: ${result.user.username}');
      debugPrint('Confirmation required: ${result.userConfirmed == false}');

      // Store username temporarily for confirmation
      await _secureStorage.storeUsername(username);

      return true;
    } catch (e) {
      debugPrint('Error signing up: $e');
      // More detailed error information
      if (e is CognitoClientException) {
        debugPrint('Cognito error code: ${e.code}');
        debugPrint('Cognito error message: ${e.message}');
        debugPrint('Cognito error name: ${e.name}');
      }
      return false;
    }
  }

  Future<bool> confirmSignUp({
    required String username,
    required String confirmationCode,
  }) async {
    try {
      _cognitoUser = CognitoUser(username, _userPool);
      await _cognitoUser!.confirmRegistration(confirmationCode);
      debugPrint('Successfully confirmed registration for user: $username');
      return true;
    } catch (e) {
      debugPrint('Error confirming sign up: $e');
      // More detailed error information
      if (e is CognitoClientException) {
        debugPrint('Cognito error code: ${e.code}');
        debugPrint('Cognito error message: ${e.message}');
        debugPrint('Cognito error name: ${e.name}');
      }
      return false;
    }
  }

  Future<bool> signIn({
    required String username,
    required String password,
  }) async {
    try {
      _cognitoUser = CognitoUser(username, _userPool);
      final authDetails = AuthenticationDetails(
        username: username,
        password: password,
      );

      _session = await _cognitoUser!.authenticateUser(authDetails);

      if (_session != null && _session!.isValid()) {
        // Store tokens in secure storage
        await _storeTokens(_session!);

        // Store username in secure storage
        await _secureStorage.storeUsername(username);

        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('Error signing in: $e');
      return false;
    }
  }

  Future<bool> signOut() async {
    try {
      if (_cognitoUser != null) {
        await _cognitoUser!.signOut();
        _cognitoUser = null;
        _session = null;

        // Clear auth data from secure storage
        await _secureStorage.clearAuthData();
      }
      return true;
    } catch (e) {
      debugPrint('Error signing out: $e');
      return false;
    }
  }

  Future<bool> forgotPassword({required String username}) async {
    try {
      _cognitoUser = CognitoUser(username, _userPool);
      await _cognitoUser!.forgotPassword();
      return true;
    } catch (e) {
      debugPrint('Error initiating forgot password: $e');
      return false;
    }
  }

  Future<bool> confirmForgotPassword({
    required String confirmationCode,
    required String newPassword,
  }) async {
    try {
      if (_cognitoUser == null) {
        return false;
      }

      await _cognitoUser!.confirmPassword(
        confirmationCode,
        newPassword,
      );
      return true;
    } catch (e) {
      debugPrint('Error confirming new password: $e');
      return false;
    }
  }

  Future<bool> resendConfirmationCode({required String username}) async {
    try {
      _cognitoUser = CognitoUser(username, _userPool);
      await _cognitoUser!.resendConfirmationCode();
      debugPrint('Successfully resent confirmation code for user: $username');
      return true;
    } catch (e) {
      debugPrint('Error resending confirmation code: $e');
      // More detailed error information
      if (e is CognitoClientException) {
        debugPrint('Cognito error code: ${e.code}');
        debugPrint('Cognito error message: ${e.message}');
        debugPrint('Cognito error name: ${e.name}');
      }
      return false;
    }
  }

  Future<bool> refreshSession() async {
    try {
      if (_cognitoUser == null) {
        final username = await _secureStorage.getUsername();
        if (username == null) {
          return false;
        }
        _cognitoUser = CognitoUser(username, _userPool);
      }

      _session = await _cognitoUser!.getSession();
      if (_session != null && _session!.isValid()) {
        // Store refreshed tokens
        await _storeTokens(_session!);
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error refreshing session: $e');
      return false;
    }
  }
}
