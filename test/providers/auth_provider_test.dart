import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mocktail/mocktail.dart';
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

// Mocks
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
  // Register fallback values for mocktail
  setUpAll(() {
    registerFallbackValue(
      LoginParams(email: 'test@test.com', password: 'password'),
    );
  });

  group('AuthNotifier - Riverpod StateNotifier Pattern', () {
    late AuthNotifier authNotifier;
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

    test('signIn updates state to authenticated on success', () async {
      final user = User(
        id: 'test-id',
        email: 'test@example.com',
        username: 'testuser',
        createdAt: DateTime.now(),
      );

      when(() => mockLoginUseCase(any())).thenAnswer((_) async => user);

      await authNotifier.signIn('test@example.com', 'password');

      expect(
        authNotifier.state,
        isA<AsyncValue<AuthState>>()
            .having((state) => state.value?.isAuthenticated, 'isAuthenticated',
                true)
            .having((state) => state.value?.user, 'user', user),
      );
    });

    test('signOut returns to initial state', () async {
      // Setup authenticated state first
      final user = User(
        id: 'test-id',
        email: 'test@example.com',
        username: 'testuser',
        createdAt: DateTime.now(),
      );

      when(() => mockLoginUseCase(any())).thenAnswer((_) async => user);

      await authNotifier.signIn('test@example.com', 'pass');

      when(() => mockSignOut()).thenAnswer((_) async => Future.value());

      await authNotifier.signOut();

      expect(
        authNotifier.state,
        isA<AsyncValue<AuthState>>()
            .having((state) => state.value?.isAuthenticated, 'isAuthenticated',
                false)
            .having((state) => state.value?.user, 'user', null),
      );
    });

    test('error state is set on signIn failure', () async {
      when(() => mockLoginUseCase(any()))
          .thenThrow(Exception('Invalid credentials'));

      await authNotifier.signIn('test@example.com', 'wrong');

      expect(
        authNotifier.state,
        isA<AsyncValue<AuthState>>()
            .having((state) => state.hasError, 'hasError', true)
            .having((state) => state.error.toString(), 'error',
                contains('Invalid credentials')),
      );
    });

    test('state uses AsyncValue wrapper - NOT direct state access', () {
      // This test validates that we're using AsyncValue, not direct state access
      // If someone changes to StateNotifier<AuthState>, this would fail
      expect(authNotifier.state, isA<AsyncValue<AuthState>>());

      // AsyncValue has these methods, raw state doesn't
      expect(authNotifier.state.hasValue, isA<bool>());
      expect(authNotifier.state.isLoading, isA<bool>());
      expect(authNotifier.state.hasError, isA<bool>());
    });

    test('AuthState is immutable - copyWith creates new instance', () {
      final state1 = AuthState.initial();
      final state2 = state1.copyWith(isAuthenticated: true);

      // These should be different instances
      expect(identical(state1, state2), false);

      // Original should be unchanged
      expect(state1.isAuthenticated, false);

      // New instance should have updated value
      expect(state2.isAuthenticated, true);
    });

    test('AsyncValue pattern - loading state during operation', () async {
      final user = User(
        id: 'test-id',
        email: 'test@example.com',
        username: 'testuser',
        createdAt: DateTime.now(),
      );

      // Create a delayed response
      when(() => mockLoginUseCase(any())).thenAnswer((_) async {
        await Future.delayed(const Duration(milliseconds: 100));
        return user;
      });

      // Start the operation
      final future = authNotifier.signIn('test@example.com', 'password');

      // Check that we're in loading state
      expect(authNotifier.state.isLoading, true);

      // Wait for completion
      await future;

      // Check that we're done loading
      expect(authNotifier.state.isLoading, false);
      expect(authNotifier.state.value?.isAuthenticated, true);
    });
  });
}
