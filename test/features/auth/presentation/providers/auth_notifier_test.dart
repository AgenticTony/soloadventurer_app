import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/auth/domain/usecases/login.dart';
import 'package:soloadventurer/features/auth/domain/usecases/get_current_user.dart';
import 'package:soloadventurer/features/auth/domain/usecases/is_signed_in.dart';
import 'package:soloadventurer/features/auth/domain/usecases/sign_out.dart';
import 'package:soloadventurer/features/auth/domain/usecases/sign_up.dart';
import 'package:soloadventurer/features/auth/domain/usecases/refresh_token.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_notifier.dart';
import 'package:soloadventurer/features/auth/presentation/state/auth_state.dart';
import 'package:soloadventurer/features/profile/domain/usecases/create_profile_use_case.dart';
import 'package:soloadventurer/features/profile/domain/entities/profile.dart';

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockGetCurrentUser extends Mock implements GetCurrentUser {}

class MockIsSignedIn extends Mock implements IsSignedIn {}

class MockSignUp extends Mock implements SignUp {}

class MockSignOut extends Mock implements SignOut {}

class MockRefreshToken extends Mock implements RefreshToken {}

class MockCreateProfileUseCase extends Mock implements CreateProfileUseCase {}

class FakeProfile extends Fake implements Profile {}

void main() {
  late MockLoginUseCase mockLogin;
  late MockGetCurrentUser mockGetCurrentUser;
  late MockIsSignedIn mockIsSignedIn;
  late MockSignUp mockSignUp;
  late MockSignOut mockSignOut;
  late MockRefreshToken mockRefreshToken;
  late MockCreateProfileUseCase mockCreateProfileUseCase;
  late AuthNotifier authNotifier;

  setUpAll(() {
    registerFallbackValue(
        LoginParams(email: 'test@example.com', password: 'password'));
    registerFallbackValue(SignUpParams(
        email: 'test@example.com', password: 'password', name: 'test'));
    registerFallbackValue(FakeProfile());
  });

  final testUser = User(
    id: '1',
    email: 'test@example.com',
    username: 'testuser',
    createdAt: DateTime(2024),
  );

  setUp(() {
    mockLogin = MockLoginUseCase();
    mockGetCurrentUser = MockGetCurrentUser();
    mockIsSignedIn = MockIsSignedIn();
    mockSignUp = MockSignUp();
    mockSignOut = MockSignOut();
    mockRefreshToken = MockRefreshToken();
    mockCreateProfileUseCase = MockCreateProfileUseCase();

    // Set up default mock responses
    when(() => mockIsSignedIn.call()).thenAnswer((_) async => false);
    when(() => mockGetCurrentUser.call()).thenAnswer((_) async => null);

    authNotifier = AuthNotifier(
      getCurrentUser: mockGetCurrentUser,
      isSignedIn: mockIsSignedIn,
      login: mockLogin,
      signUp: mockSignUp,
      signOut: mockSignOut,
      refreshToken: mockRefreshToken,
      createProfile: mockCreateProfileUseCase,
    );
  });

  test('initial state should be AuthState.initial()', () async {
    expect(authNotifier.state, AuthState.initial());
    await Future.delayed(Duration.zero); // Wait for _checkAuthState to complete
    expect(authNotifier.state, AuthState.initial());
  });

  group('_checkAuthState', () {
    test('should update state to authenticated when current user exists',
        () async {
      // Clear verifications from setUp
      clearInteractions(mockIsSignedIn);
      clearInteractions(mockGetCurrentUser);

      when(() => mockIsSignedIn.call()).thenAnswer((_) async => true);
      when(() => mockGetCurrentUser.call()).thenAnswer((_) async => testUser);

      // Call checkAuthState directly
      await authNotifier.checkAuthState();

      expect(authNotifier.state, AuthState.authenticated(testUser));
      verify(() => mockIsSignedIn.call()).called(1);
      verify(() => mockGetCurrentUser.call()).called(1);
    });

    test('should keep initial state when no current user exists', () async {
      // Clear verifications from setUp
      clearInteractions(mockIsSignedIn);
      clearInteractions(mockGetCurrentUser);

      when(() => mockIsSignedIn.call()).thenAnswer((_) async => false);

      // Call checkAuthState directly
      await authNotifier.checkAuthState();

      expect(authNotifier.state, AuthState.initial());
      verify(() => mockIsSignedIn.call()).called(1);
      verifyNever(() => mockGetCurrentUser.call());
    });

    test('should update state to error when getCurrentUser throws', () async {
      // Clear verifications from setUp
      clearInteractions(mockIsSignedIn);
      clearInteractions(mockGetCurrentUser);

      when(() => mockIsSignedIn.call()).thenAnswer((_) async => true);
      when(() => mockGetCurrentUser.call()).thenThrow(Exception('Test error'));

      // Call checkAuthState directly
      await authNotifier.checkAuthState();

      expect(authNotifier.state.error, 'Exception: Test error');
      verify(() => mockIsSignedIn.call()).called(1);
      verify(() => mockGetCurrentUser.call()).called(1);
    });
  });

  group('signIn', () {
    test('should update state to authenticated when login succeeds', () async {
      when(() => mockLogin.call(any())).thenAnswer((_) async => testUser);

      await authNotifier.signIn('test@example.com', 'password');

      expect(authNotifier.state, AuthState.authenticated(testUser));
      verify(() => mockLogin.call(any(
          that: predicate((LoginParams params) =>
              params.email == 'test@example.com' &&
              params.password == 'password')))).called(1);
    });

    test('should update state to error when login fails', () async {
      when(() => mockLogin.call(any()))
          .thenThrow(Exception('Invalid credentials'));

      await authNotifier.signIn('test@example.com', 'password');

      expect(authNotifier.state.error, 'Exception: Invalid credentials');
      verify(() => mockLogin.call(any(
          that: predicate((LoginParams params) =>
              params.email == 'test@example.com' &&
              params.password == 'password')))).called(1);
    });
  });

  group('signUp', () {
    const testEmail = 'test@example.com';
    const testPassword = 'password123';
    const testUsername = 'testuser';

    test(
        'should create profile and update state to authenticated when signup succeeds',
        () async {
      // Arrange
      when(() => mockSignUp.call(any())).thenAnswer((_) async => testUser);
      when(() => mockCreateProfileUseCase.call(any()))
          .thenAnswer((_) async => Profile(
                id: testUser.id,
                userId: testUser.id,
                displayName: testUsername,
                createdAt: DateTime.now(),
                updatedAt: DateTime.now(),
              ));

      // Act
      await authNotifier.signUp(
        email: testEmail,
        password: testPassword,
        name: testUsername,
      );

      // Assert
      verify(() => mockSignUp.call(any(
          that: predicate((SignUpParams params) =>
              params.email == testEmail &&
              params.password == testPassword &&
              params.username == testUsername)))).called(1);
      verify(() => mockCreateProfileUseCase.call(any())).called(1);
      expect(authNotifier.state, AuthState.authenticated(testUser));
    });

    test('should update state to error when signup fails', () async {
      when(() => mockSignUp.call(any()))
          .thenThrow(Exception('Email already exists'));

      await authNotifier.signUp(
        email: testEmail,
        password: testPassword,
        name: testUsername,
      );

      expect(authNotifier.state.error, 'Exception: Email already exists');
      verify(() => mockSignUp.call(any(
          that: predicate((SignUpParams params) =>
              params.email == testEmail &&
              params.password == testPassword &&
              params.username == testUsername)))).called(1);
      verifyNever(() => mockCreateProfileUseCase.call(any()));
    });
  });

  group('signOut', () {
    test('should update state to initial when signOut succeeds', () async {
      when(() => mockSignOut.call()).thenAnswer((_) async {});

      await authNotifier.signOut();

      expect(authNotifier.state, AuthState.initial());
      verify(() => mockSignOut.call()).called(1);
    });

    test('should update state to error when signOut fails', () async {
      when(() => mockSignOut.call()).thenThrow(Exception('Network error'));

      await authNotifier.signOut();

      expect(authNotifier.state.error, 'Exception: Network error');
      verify(() => mockSignOut.call()).called(1);
    });
  });

  group('clearError', () {
    test('should clear error from state', () async {
      when(() => mockLogin.call(any())).thenThrow(Exception('Test error'));

      await authNotifier.signIn('test@example.com', 'password');
      expect(authNotifier.state.error, 'Exception: Test error');

      authNotifier.clearError();
      expect(authNotifier.state.error, null);
    });
  });
}
