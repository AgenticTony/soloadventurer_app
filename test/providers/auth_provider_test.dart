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
import 'package:soloadventurer/features/auth/presentation/providers/auth_notifier_provider.dart';
import 'package:soloadventurer/features/auth/presentation/state/auth_state.dart';
import 'package:soloadventurer/features/core/domain/services/logging_service.dart';
import 'package:soloadventurer/features/auth/domain/services/token_manager.dart';
import 'package:soloadventurer/app/providers/auth_service_providers.dart';
import 'package:soloadventurer/features/core/infrastructure/providers/core_providers.dart';

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
  TestWidgetsFlutterBinding.ensureInitialized();

  // Register fallback values for mocktail
  setUpAll(() {
    registerFallbackValue(
      LoginParams(email: 'test@test.com', password: 'password'),
    );
  });

  group('AuthNotifier - Riverpod AsyncNotifier Pattern', () {
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

      // Default: not signed in
      when(() => mockIsSignedIn()).thenAnswer((_) async => false);
      when(() => mockLoggingService.logAuthEvent(
            event: any(named: 'event'),
            status: any(named: 'status'),
            metadata: any(named: 'metadata'),
          )).thenReturn(null);
      when(() => mockLoggingService.logError(
            feature: any(named: 'feature'),
            error: any(named: 'error'),
            code: any(named: 'code'),
            metadata: any(named: 'metadata'),
            stackTrace: any(named: 'stackTrace'),
          )).thenReturn(null);

      container = ProviderContainer(overrides: [
        getCurrentUserUseCaseProvider.overrideWithValue(mockGetCurrentUser),
        isSignedInUseCaseProvider.overrideWithValue(mockIsSignedIn),
        loginUseCaseProvider.overrideWithValue(mockLoginUseCase),
        signUpUseCaseProvider.overrideWithValue(mockSignUp),
        signOutUseCaseProvider.overrideWithValue(mockSignOut),
        verifyEmailUseCaseProvider.overrideWithValue(mockVerifyEmail),
        resendVerificationEmailUseCaseProvider
            .overrideWithValue(mockResendVerificationEmail),
        forgotPasswordUseCaseProvider.overrideWithValue(mockForgotPassword),
        confirmPasswordResetUseCaseProvider
            .overrideWithValue(mockConfirmPasswordReset),
        loggingServiceProvider.overrideWithValue(mockLoggingService),
        tokenManagerProvider.overrideWith(() => _FakeTokenManager()),
      ]);
    });

    tearDown(() {
      container.dispose();
    });

    test('initial state is AsyncValue.data with unauthenticated AuthState',
        () async {
      // Wait for the async build to complete
      final state = await container.read(authProvider.future);
      expect(state.isAuthenticated, false);
      expect(state.user, isNull);
    });

    test('signIn updates state to authenticated on success', () async {
      final user = User(
        id: 'test-id',
        email: 'test@example.com',
        username: 'testuser',
        createdAt: DateTime.now(),
      );

      when(() => mockLoginUseCase(any())).thenAnswer((_) async => user);

      await container.read(authProvider.notifier).signIn('test@example.com', 'password');

      final state = await container.read(authProvider.future);
      expect(state.isAuthenticated, true);
      expect(state.user, user);
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
      when(() => mockSignOut()).thenAnswer((_) async => Future.value());

      await container.read(authProvider.notifier).signIn('test@example.com', 'pass');
      await container.read(authProvider.notifier).signOut();

      final state = await container.read(authProvider.future);
      expect(state.isAuthenticated, false);
      expect(state.user, isNull);
    });

    test('error state is set on signIn failure', () async {
      when(() => mockLoginUseCase(any()))
          .thenThrow(Exception('Invalid credentials'));

      await container.read(authProvider.notifier).signIn('test@example.com', 'wrong');

      final asyncState = container.read(authProvider);
      expect(asyncState.hasError, true);
      expect(asyncState.error.toString(), contains('Invalid credentials'));
    });

    test('state uses AsyncValue wrapper - NOT direct state access', () async {
      // This test validates that we're using AsyncValue, not direct state access
      final asyncState = container.read(authProvider);
      expect(asyncState, isA<AsyncValue<AuthState>>());
      expect(asyncState.hasValue, isA<bool>());
      expect(asyncState.hasError, isA<bool>());
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
      final future = container.read(authProvider.notifier).signIn('test@example.com', 'password');

      // Check that we're in loading state
      expect(container.read(authProvider).isLoading, true);

      // Wait for completion
      await future;

      // Check that we're done loading
      final finalState = container.read(authProvider);
      expect(finalState.isLoading, false);
      expect(finalState.hasValue, true);
      expect(finalState.value?.isAuthenticated, true);
    });
  });
}

// Fake TokenManager for testing purposes
class _FakeTokenManager extends TokenManager {
  @override
  FeatureAvailability build() => FeatureAvailability.fullyAvailable;

  @override
  Future<void> refreshState() async {}

  @override
  Future<void> initialize() async {}

  @override
  Future<void> refreshToken() async {}
}
