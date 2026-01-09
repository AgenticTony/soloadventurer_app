import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/auth_service.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/session_manager.dart';

/// A mock implementation of [AuthService] for testing.
class MockAuthService extends Mock {
  bool _isAuthenticated = false;
  String? _username;

  @override
  bool get isAuthenticated => _isAuthenticated;

  @override
  String? get username => _username;

  @override
  Future<bool> signIn({
    required String username,
    required String password,
  }) async {
    return super.noSuchMethod(
          Invocation.method(
            #signIn,
            [],
            {
              #username: username,
              #password: password,
            },
          ),
        ) as bool? ??
        false;
  }

  @override
  Future<bool> signUp({
    required String username,
    required String password,
    required String email,
    String? firstName,
    String? lastName,
    String? displayName,
  }) async {
    return super.noSuchMethod(
          Invocation.method(
            #signUp,
            [],
            {
              #username: username,
              #password: password,
              #email: email,
              #firstName: firstName,
              #lastName: lastName,
              #displayName: displayName,
            },
          ),
        ) as bool? ??
        false;
  }

  @override
  Future<bool> signOut() async {
    return super.noSuchMethod(
          Invocation.method(#signOut, []),
        ) as bool? ??
        false;
  }

  @override
  Future<bool> refreshSession() async {
    return super.noSuchMethod(
          Invocation.method(#refreshSession, []),
        ) as bool? ??
        false;
  }

  @override
  Future<bool> forgotPassword({required String username}) async {
    return super.noSuchMethod(
          Invocation.method(#forgotPassword, [], {#username: username}),
        ) as bool? ??
        false;
  }

  @override
  Future<bool> confirmForgotPassword({
    required String confirmationCode,
    required String newPassword,
  }) async {
    return super.noSuchMethod(
          Invocation.method(
            #confirmForgotPassword,
            [],
            {
              #confirmationCode: confirmationCode,
              #newPassword: newPassword,
            },
          ),
        ) as bool? ??
        false;
  }

  @override
  Future<bool> confirmSignUp({
    required String username,
    required String confirmationCode,
  }) async {
    return super.noSuchMethod(
          Invocation.method(
            #confirmSignUp,
            [],
            {
              #username: username,
              #confirmationCode: confirmationCode,
            },
          ),
        ) as bool? ??
        false;
  }

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
  @override
  Future<void> startSession() async {
    return super.noSuchMethod(
      Invocation.method(#startSession, []),
    );
  }

  @override
  Future<void> endSession() async {
    return super.noSuchMethod(
      Invocation.method(#endSession, []),
    );
  }

  /// Sets up the mock for a successful session start.
  void setupSuccessfulSessionStart() {
    when(() => startSession()).thenAnswer((_) async {
      return;
    });
  }

  /// Sets up the mock for a successful session end.
  void setupSuccessfulSessionEnd() {
    when(() => endSession()).thenAnswer((_) async {
      return;
    });
  }

  /// Sets up the mock for a failed session operation.
  void setupFailedSessionOperation(String errorMessage) {
    when(() => startSession()).thenThrow(Exception(errorMessage));
    when(() => endSession()).thenThrow(Exception(errorMessage));
  }
}
