import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/data/models/user_model.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_notifier_provider.dart';
import 'package:soloadventurer/features/auth/domain/usecases/get_current_user.dart';
import 'package:soloadventurer/features/auth/domain/usecases/is_signed_in.dart';
import 'package:soloadventurer/features/auth/domain/usecases/login.dart';
import 'package:soloadventurer/features/auth/domain/usecases/sign_up.dart';
import 'package:soloadventurer/features/auth/domain/usecases/sign_out.dart';
import 'package:soloadventurer/features/auth/domain/usecases/verify_email.dart';
import 'package:soloadventurer/features/auth/domain/usecases/forgot_password.dart';
import 'package:soloadventurer/features/auth/domain/usecases/confirm_password_reset.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';

// Mock use cases
class MockGetCurrentUser extends Mock implements GetCurrentUser {}

class MockIsSignedIn extends Mock implements IsSignedIn {}

class MockLoginUseCase extends Mock implements LoginUseCase {}

class MockSignUp extends Mock implements SignUp {}

class MockSignOut extends Mock implements SignOut {}

class MockVerifyEmail extends Mock implements VerifyEmail {}

class MockForgotPassword extends Mock implements ForgotPassword {}

class MockConfirmPasswordReset extends Mock implements ConfirmPasswordReset {}

void main() {
  late MockGetCurrentUser mockGetCurrentUser;
  late MockIsSignedIn mockIsSignedIn;
  late MockLoginUseCase mockLoginUseCase;
  late MockSignUp mockSignUp;
  late MockSignOut mockSignOut;
  late MockVerifyEmail mockVerifyEmail;
  late MockForgotPassword mockForgotPassword;
  late MockConfirmPasswordReset mockConfirmPasswordReset;
  late ProviderContainer container;

  setUp(() async {
    mockGetCurrentUser = MockGetCurrentUser();
    mockIsSignedIn = MockIsSignedIn();
    mockLoginUseCase = MockLoginUseCase();
    mockSignUp = MockSignUp();
    mockSignOut = MockSignOut();
    mockVerifyEmail = MockVerifyEmail();
    mockForgotPassword = MockForgotPassword();
    mockConfirmPasswordReset = MockConfirmPasswordReset();

    // Register fallback values
    registerFallbackValue(const LoginParams(email: '', password: ''));
    registerFallbackValue(const SignUpParams(
      email: '',
      password: '',
      name: '',
    ));
    registerFallbackValue(const VerifyEmailParams(code: '', email: ''));
    registerFallbackValue(const ForgotPasswordParams(identifier: ''));
    registerFallbackValue(const ConfirmPasswordResetParams(
      code: '',
      newPassword: '',
      email: '',
    ));

    // Set up default mock behavior
    when(() => mockIsSignedIn()).thenAnswer((_) async => false);
    when(() => mockGetCurrentUser()).thenAnswer((_) async => null);

    container = ProviderContainer(
      overrides: [
        getCurrentUserProvider.overrideWithValue(mockGetCurrentUser),
        isSignedInProvider.overrideWithValue(mockIsSignedIn),
        loginUseCaseProvider.overrideWithValue(mockLoginUseCase),
        signUpProvider.overrideWithValue(mockSignUp),
        signOutProvider.overrideWithValue(mockSignOut),
        verifyEmailProvider.overrideWithValue(mockVerifyEmail),
        forgotPasswordProvider.overrideWithValue(mockForgotPassword),
        confirmPasswordResetProvider
            .overrideWithValue(mockConfirmPasswordReset),
      ],
    );

    // Wait for the auth notifier to initialize
    await Future.delayed(const Duration(milliseconds: 100));
  });

  tearDown(() {
    container.dispose();
  });

  group('Auth Flow Integration Tests', () {
    test('full authentication flow', () async {
      // Initial state should be unauthenticated
      final initialState = container.read(authNotifierProvider).value;
      expect(initialState, isNotNull);
      expect(initialState!.isLoggedIn, false);
      expect(initialState.user, isNull);
      expect(initialState.accessToken, isNull);
      expect(initialState.requiresEmailVerification, false);
      expect(initialState.requiresPasswordReset, false);

      // Set up sign in mock
      final user = UserModel(
        id: '1',
        email: 'test@test.com',
        username: 'test',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      when(() => mockIsSignedIn()).thenAnswer((_) async => true);
      when(() => mockGetCurrentUser()).thenAnswer((_) async => user);
      when(() => mockLoginUseCase(any())).thenAnswer((_) async => user);

      // Sign in
      await container
          .read(authNotifierProvider.notifier)
          .signIn('test@test.com', 'password');

      // Should be authenticated with token
      final authState = container.read(authNotifierProvider).value;
      expect(authState, isNotNull);
      expect(authState!.isLoggedIn, true);
      expect(authState.user?.email, 'test@test.com');
      expect(authState.isAuthenticated, true);

      // Sign out
      when(() => mockSignOut()).thenAnswer((_) async {});
      when(() => mockIsSignedIn()).thenAnswer((_) async => false);
      when(() => mockGetCurrentUser()).thenAnswer((_) async => null);

      await container.read(authNotifierProvider.notifier).signOut();

      // Should be unauthenticated
      final signedOutState = container.read(authNotifierProvider).value;
      expect(signedOutState, isNotNull);
      expect(signedOutState!.isLoggedIn, false);
      expect(signedOutState.user, isNull);
    });

    test('unverified user flow', () async {
      // Sign up with unverified user
      final user = UserModel(
        id: '1',
        email: 'test@test.com',
        username: 'test',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );

      when(() => mockSignUp(any())).thenAnswer((_) async => (user, true));

      await container.read(authNotifierProvider.notifier).signUp(
            email: 'test@test.com',
            password: 'password',
            name: 'Test User',
          );

      // Should be unverified
      final unverifiedState = container.read(authNotifierProvider).value;
      expect(unverifiedState, isNotNull);
      expect(unverifiedState!.requiresEmailVerification, true);
      expect(unverifiedState.user?.email, 'test@test.com');

      // Test email verification
      when(() => mockIsSignedIn()).thenAnswer((_) async => true);
      when(() => mockGetCurrentUser()).thenAnswer((_) async => user);
      when(() => mockVerifyEmail(any())).thenAnswer((_) async {});

      await container
          .read(authNotifierProvider.notifier)
          .verifyEmail('123456', 'test@test.com');

      // After verification, should be authenticated
      final verifiedState = container.read(authNotifierProvider).value;
      expect(verifiedState, isNotNull);
      expect(verifiedState!.isLoggedIn, true);
      expect(verifiedState.user?.email, 'test@test.com');
    });

    test('password reset flow', () async {
      // Request password reset
      when(() => mockForgotPassword(any())).thenAnswer((_) async {});

      await container
          .read(authNotifierProvider.notifier)
          .forgotPassword('test@test.com');

      // Should be in password reset state
      final resetState = container.read(authNotifierProvider).value;
      expect(resetState, isNotNull);
      expect(resetState!.requiresPasswordReset, true);
      expect(resetState.user?.email, 'test@test.com');

      // Confirm password reset
      when(() => mockConfirmPasswordReset(any())).thenAnswer((_) async {});

      await container.read(authNotifierProvider.notifier).confirmPasswordReset(
            code: '123456',
            newPassword: 'newpassword',
            email: 'test@test.com',
          );

      // Should return to initial state after password reset
      final completeState = container.read(authNotifierProvider).value;
      expect(completeState, isNotNull);
      expect(completeState!.requiresPasswordReset, false);
      expect(completeState.isLoggedIn, false);
    });

    test('loading and error states', () async {
      // Test loading state during sign in
      when(() => mockIsSignedIn()).thenAnswer((_) async => false);
      when(() => mockGetCurrentUser()).thenAnswer((_) async => null);
      when(() => mockLoginUseCase(any())).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 50));
        throw const AuthException('Invalid credentials');
      });

      // Start sign in - state should be loading
      final signInFuture = container
          .read(authNotifierProvider.notifier)
          .signIn('test@test.com', 'wrong');

      // Check loading state
      await Future.delayed(const Duration(milliseconds: 10));
      final loadingState = container.read(authNotifierProvider);
      expect(loadingState.isLoading, true);

      // Wait for error
      await signInFuture;

      // Should have error
      final errorState = container.read(authNotifierProvider);
      expect(errorState.hasError, true);
      expect(errorState.error, isA<AuthException>());
    });
  });
}
