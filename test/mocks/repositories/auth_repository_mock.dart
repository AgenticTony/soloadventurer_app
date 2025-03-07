import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/services/auth_service.dart';
import 'package:soloadventurer/services/session_manager.dart';

/// A mock implementation of [AuthService] for testing.
class MockAuthService extends Mock implements AuthService {
  bool _isAuthenticated = false;
  String? _username;

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  String? get username => _username;

  /// Sets up the mock for a successful sign-in.
  void setupSuccessfulSignIn(String username) {
    _isAuthenticated = true;
    _username = username;

    when(() => signIn(
          username: any(named: 'username'),
          password: any(named: 'password'),
        )).thenAnswer((_) async => true);
  }

  /// Sets up the mock for a failed sign-in.
  void setupFailedSignIn(String errorMessage) {
    _isAuthenticated = false;
    _username = null;

    when(() => signIn(
          username: any(named: 'username'),
          password: any(named: 'password'),
        )).thenThrow(Exception(errorMessage));
  }

  /// Sets up the mock for a successful sign-up.
  void setupSuccessfulSignUp() {
    when(() => signUp(
          username: any(named: 'username'),
          password: any(named: 'password'),
          email: any(named: 'email'),
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
          displayName: any(named: 'displayName'),
        )).thenAnswer((_) async => true);
  }

  /// Sets up the mock for a failed sign-up.
  void setupFailedSignUp(String errorMessage) {
    when(() => signUp(
          username: any(named: 'username'),
          password: any(named: 'password'),
          email: any(named: 'email'),
          firstName: any(named: 'firstName'),
          lastName: any(named: 'lastName'),
          displayName: any(named: 'displayName'),
        )).thenThrow(Exception(errorMessage));
  }

  /// Sets up the mock for a successful sign-out.
  void setupSuccessfulSignOut() {
    when(() => signOut()).thenAnswer((_) async {
      _isAuthenticated = false;
      _username = null;
      return true;
    });
  }

  /// Sets up the mock for a successful token refresh.
  void setupSuccessfulTokenRefresh() {
    when(() => refreshSession()).thenAnswer((_) async => true);
  }

  /// Sets up the mock for a failed token refresh.
  void setupFailedTokenRefresh(String errorMessage) {
    when(() => refreshSession()).thenThrow(Exception(errorMessage));
  }

  /// Sets up the mock for a successful password reset.
  void setupSuccessfulPasswordReset() {
    when(() => forgotPassword(username: any(named: 'username')))
        .thenAnswer((_) async => true);
    when(() => confirmForgotPassword(
          confirmationCode: any(named: 'confirmationCode'),
          newPassword: any(named: 'newPassword'),
        )).thenAnswer((_) async => true);
  }

  /// Sets up the mock for a failed password reset.
  void setupFailedPasswordReset(String errorMessage) {
    when(() => forgotPassword(username: any(named: 'username')))
        .thenThrow(Exception(errorMessage));
  }

  /// Sets up the mock for a successful confirmation code verification.
  void setupSuccessfulConfirmSignUp() {
    when(() => confirmSignUp(
          username: any(named: 'username'),
          confirmationCode: any(named: 'confirmationCode'),
        )).thenAnswer((_) async => true);
  }

  /// Sets up the mock for a failed confirmation code verification.
  void setupFailedConfirmSignUp(String errorMessage) {
    when(() => confirmSignUp(
          username: any(named: 'username'),
          confirmationCode: any(named: 'confirmationCode'),
        )).thenThrow(Exception(errorMessage));
  }
}

/// A mock implementation of [SessionManager] for testing.
class MockSessionManager extends Mock implements SessionManager {
  /// Sets up the mock for a successful session start.
  void setupSuccessfulSessionStart() {
    when(() => startSession()).thenAnswer((_) async {
      return null;
    });
  }

  /// Sets up the mock for a successful session end.
  void setupSuccessfulSessionEnd() {
    when(() => endSession()).thenAnswer((_) async {
      return null;
    });
  }

  /// Sets up the mock for a failed session operation.
  void setupFailedSessionOperation(String errorMessage) {
    when(() => startSession()).thenThrow(Exception(errorMessage));
    when(() => endSession()).thenThrow(Exception(errorMessage));
  }
}
