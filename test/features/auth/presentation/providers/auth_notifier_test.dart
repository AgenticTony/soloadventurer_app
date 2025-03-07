import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/domain/entities/user.dart';
import 'package:soloadventurer/features/auth/domain/usecases/get_current_user.dart';
import 'package:soloadventurer/features/auth/domain/usecases/is_signed_in.dart';
import 'package:soloadventurer/features/auth/domain/usecases/login.dart';
import 'package:soloadventurer/features/auth/domain/usecases/sign_out.dart';
import 'package:soloadventurer/features/auth/domain/usecases/sign_up.dart';
import 'package:soloadventurer/features/auth/domain/usecases/verify_email.dart';
import 'package:soloadventurer/features/auth/domain/usecases/resend_verification_email.dart'
    as resend;
import 'package:soloadventurer/features/auth/domain/usecases/forgot_password.dart';
import 'package:soloadventurer/features/auth/domain/usecases/confirm_password_reset.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_provider.dart';
import 'package:soloadventurer/features/auth/presentation/state/auth_state.dart';
import 'package:soloadventurer/features/core/domain/services/logging_service.dart';

class MockGetCurrentUser extends Mock implements GetCurrentUser {}

class MockIsSignedIn extends Mock implements IsSignedIn {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockSignUp extends Mock implements SignUp {}

class MockSignOut extends Mock implements SignOut {}

class MockVerifyEmail extends Mock implements VerifyEmail {}

class MockResendVerificationEmail extends Mock
    implements resend.ResendVerificationEmail {}

class MockForgotPassword extends Mock implements ForgotPassword {}

class MockConfirmPasswordReset extends Mock implements ConfirmPasswordReset {}

class MockLoggingService extends Mock implements LoggingService {}

void main() {
  group('AuthNotifier', () {
    late MockGetCurrentUser mockGetCurrentUser;
    late MockIsSignedIn mockIsSignedIn;
    late MockLoginUseCase mockLoginUseCase;
    late MockSignUp mockSignUp;
    late MockSignOut mockSignOut;
    late MockVerifyEmail mockVerifyEmail;
    late MockResendVerificationEmail mockResendVerificationEmail;
    late MockForgotPassword mockForgotPassword;
    late MockConfirmPasswordReset mockConfirmPasswordReset;
    late MockLoggingService mockLoggingService;
    late AuthNotifier authNotifier;

    setUp(() {
      mockGetCurrentUser = MockGetCurrentUser();
      mockIsSignedIn = MockIsSignedIn();
      mockLoginUseCase = MockLoginUseCase();
      mockSignUp = MockSignUp();
      mockSignOut = MockSignOut();
      mockVerifyEmail = MockVerifyEmail();
      mockResendVerificationEmail = MockResendVerificationEmail();
      mockForgotPassword = MockForgotPassword();
      mockConfirmPasswordReset = MockConfirmPasswordReset();
      mockLoggingService = MockLoggingService();

      authNotifier = AuthNotifier(
        getCurrentUser: mockGetCurrentUser,
        isSignedIn: mockIsSignedIn,
        login: mockLoginUseCase,
        signUp: mockSignUp,
        signOut: mockSignOut,
        verifyEmail: mockVerifyEmail,
        resendVerificationEmail: mockResendVerificationEmail,
        forgotPassword: mockForgotPassword,
        confirmPasswordReset: mockConfirmPasswordReset,
        logger: mockLoggingService,
      );
    });

    test('initial state is AsyncValue.data with initial AuthState', () {
      expect(
        authNotifier.state,
        isA<AsyncValue<AuthState>>()
            .having((state) => state.value?.isAuthenticated, 'isAuthenticated',
                false)
            .having((state) => state.value?.user, 'user', null),
      );
    });

    group('initialize', () {
      test('sets loading state while initializing', () async {
        // Arrange
        when(() => mockIsSignedIn()).thenAnswer((_) async => false);

        // Act
        final future = authNotifier.initialize();

        // Assert
        expect(authNotifier.state, const AsyncValue<AuthState>.loading());

        // Complete initialization
        await future;
      });

      test('sets authenticated state when user is signed in', () async {
        // Arrange
        final user = User(
          id: '1',
          email: 'test@test.com',
          username: 'test',
          createdAt: DateTime.now(),
        );
        when(() => mockIsSignedIn()).thenAnswer((_) async => true);
        when(() => mockGetCurrentUser()).thenAnswer((_) async => user);

        // Act
        await authNotifier.initialize();

        // Assert
        expect(
          authNotifier.state,
          isA<AsyncValue<AuthState>>()
              .having((state) => state.value?.isAuthenticated,
                  'isAuthenticated', true)
              .having((state) => state.value?.user, 'user', user),
        );
      });

      test('sets initial state when user is not signed in', () async {
        // Arrange
        when(() => mockIsSignedIn()).thenAnswer((_) async => false);

        // Act
        await authNotifier.initialize();

        // Assert
        expect(
          authNotifier.state,
          isA<AsyncValue<AuthState>>()
              .having((state) => state.value?.isAuthenticated,
                  'isAuthenticated', false)
              .having((state) => state.value?.user, 'user', null),
        );
      });
    });

    group('signIn', () {
      test('sets loading state while signing in', () async {
        // Arrange
        final user = User(
          id: '1',
          email: 'test@test.com',
          username: 'test',
          createdAt: DateTime.now(),
        );
        when(() => mockLoginUseCase(any())).thenAnswer((_) async => user);

        // Act
        final future = authNotifier.signIn('test@test.com', 'password');

        // Assert
        expect(authNotifier.state, const AsyncValue<AuthState>.loading());

        // Complete sign in
        await future;
      });

      test('sets authenticated state on successful sign in', () async {
        // Arrange
        final user = User(
          id: '1',
          email: 'test@test.com',
          username: 'test',
          createdAt: DateTime.now(),
        );
        when(() => mockLoginUseCase(any())).thenAnswer((_) async => user);

        // Act
        await authNotifier.signIn('test@test.com', 'password');

        // Assert
        expect(
          authNotifier.state,
          isA<AsyncValue<AuthState>>()
              .having((state) => state.value?.isAuthenticated,
                  'isAuthenticated', true)
              .having((state) => state.value?.user, 'user', user),
        );
      });

      test('sets error state on sign in failure', () async {
        // Arrange
        when(() => mockLoginUseCase(any()))
            .thenThrow(Exception('Sign in failed'));

        // Act
        await authNotifier.signIn('test@test.com', 'password');

        // Assert
        expect(
          authNotifier.state,
          isA<AsyncValue<AuthState>>()
              .having((state) => state.hasError, 'hasError', true)
              .having((state) => state.error.toString(), 'error',
                  contains('Sign in failed')),
        );
      });
    });

    group('signOut', () {
      test('sets loading state while signing out', () async {
        // Arrange
        when(() => mockSignOut()).thenAnswer((_) async {});

        // Act
        final future = authNotifier.signOut();

        // Assert
        expect(authNotifier.state, const AsyncValue<AuthState>.loading());

        // Complete sign out
        await future;
      });

      test('sets initial state on successful sign out', () async {
        // Arrange
        when(() => mockSignOut()).thenAnswer((_) async {});

        // Act
        await authNotifier.signOut();

        // Assert
        expect(
          authNotifier.state,
          isA<AsyncValue<AuthState>>()
              .having((state) => state.value?.isAuthenticated,
                  'isAuthenticated', false)
              .having((state) => state.value?.user, 'user', null),
        );
      });

      test('sets error state on sign out failure', () async {
        // Arrange
        when(() => mockSignOut()).thenThrow(Exception('Sign out failed'));

        // Act
        await authNotifier.signOut();

        // Assert
        expect(
          authNotifier.state,
          isA<AsyncValue<AuthState>>()
              .having((state) => state.hasError, 'hasError', true)
              .having((state) => state.error.toString(), 'error',
                  contains('Sign out failed')),
        );
      });
    });
  });
}
