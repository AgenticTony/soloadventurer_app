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
  late ProviderContainer container;
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

    container = ProviderContainer(
      overrides: [
        getCurrentUserProvider.overrideWithValue(mockGetCurrentUser),
        isSignedInProvider.overrideWithValue(mockIsSignedIn),
        loginProvider.overrideWithValue(mockLoginUseCase),
        signUpProvider.overrideWithValue(mockSignUp),
        signOutProvider.overrideWithValue(mockSignOut),
        verifyEmailProvider.overrideWithValue(mockVerifyEmail),
        resendVerificationEmailProvider
            .overrideWithValue(mockResendVerificationEmail),
        forgotPasswordProvider.overrideWithValue(mockForgotPassword),
        confirmPasswordResetProvider
            .overrideWithValue(mockConfirmPasswordReset),
        loggingServiceProvider.overrideWithValue(mockLoggingService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  group('AuthProvider', () {
    test('initial state is loading', () {
      final state = container.read(authStateProvider);
      expect(state.value, AuthState.loading());
    });

    test('initialize sets initial state when not signed in', () async {
      when(() => mockIsSignedIn.call()).thenAnswer((_) async => false);
      when(() => mockGetCurrentUser.call()).thenAnswer((_) async => null);

      await container.read(authStateProvider.notifier).initialize();

      final state = container.read(authStateProvider);
      expect(state.value, AuthState.initial());
    });

    test('initialize sets authenticated state when signed in', () async {
      final user = User(
        id: '1',
        email: 'test@test.com',
        username: 'test',
        createdAt: DateTime.now(),
      );

      when(() => mockIsSignedIn.call()).thenAnswer((_) async => true);
      when(() => mockGetCurrentUser.call()).thenAnswer((_) async => user);

      await container.read(authStateProvider.notifier).initialize();

      final state = container.read(authStateProvider);
      expect(state.value, AuthState.authenticated(user));
    });

    test('signIn updates state on success', () async {
      final user = User(
        id: '1',
        email: 'test@test.com',
        username: 'test',
        createdAt: DateTime.now(),
      );

      when(() => mockLoginUseCase.call(any(), any()))
          .thenAnswer((_) async => user);

      await container
          .read(authStateProvider.notifier)
          .signIn('test@test.com', 'password');

      final state = container.read(authStateProvider);
      expect(state.value, AuthState.authenticated(user));
    });

    test('signIn updates state on error', () async {
      when(() => mockLoginUseCase.call(any(), any()))
          .thenThrow(Exception('Invalid credentials'));

      await container
          .read(authStateProvider.notifier)
          .signIn('test@test.com', 'password');

      final state = container.read(authStateProvider);
      expect(state.value, AuthState.error('Invalid credentials'));
    });

    test('signOut updates state on success', () async {
      when(() => mockSignOut.call()).thenAnswer((_) async {});

      await container.read(authStateProvider.notifier).signOut();

      final state = container.read(authStateProvider);
      expect(state.value, AuthState.initial());
    });

    test('signOut updates state on error', () async {
      when(() => mockSignOut.call()).thenThrow(Exception('Sign out failed'));

      await container.read(authStateProvider.notifier).signOut();

      final state = container.read(authStateProvider);
      expect(state.value, AuthState.error('Sign out failed'));
    });
  });
}
