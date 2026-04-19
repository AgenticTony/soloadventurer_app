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
import 'package:soloadventurer/features/auth/presentation/providers/auth_notifier_provider.dart';
import 'package:soloadventurer/features/auth/domain/services/token_manager.dart';
import 'package:soloadventurer/app/providers/auth_service_providers.dart';
import 'package:soloadventurer/features/auth/presentation/state/auth_state.dart';
import 'package:soloadventurer/features/core/infrastructure/providers/core_providers.dart';
import 'package:soloadventurer/features/core/domain/services/logging_service.dart';
import 'package:soloadventurer/core/errors/exceptions.dart';

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
    registerFallbackValue(
      const VerifyEmailParams(code: '123456', email: 'test@test.com'),
    );
    registerFallbackValue(
      const ForgotPasswordParams(identifier: 'test@test.com'),
    );
    registerFallbackValue(
      const ConfirmPasswordResetParams(
        code: '123456',
        newPassword: 'newPassword',
        email: 'test@test.com',
      ),
    );
    registerFallbackValue(
      const SignUpParams(
        email: 'test@test.com',
        password: 'password',
        name: 'Test',
      ),
    );
  });

  group('AuthNotifier (AsyncNotifier with ProviderContainer)', () {
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

      // Setup default mock behaviors
      when(() => mockIsSignedIn()).thenAnswer((_) async => false);
      when(() => mockGetCurrentUser()).thenAnswer((_) async => null);
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
    });

    ProviderContainer createContainer() {
      // Note: ProviderContainer.test() requires Riverpod 3.x
      // Current project uses Riverpod 2.6.1, so we use manual disposal
      return ProviderContainer(
        overrides: [
          getCurrentUserUseCaseProvider.overrideWithValue(mockGetCurrentUser),
          isSignedInUseCaseProvider.overrideWithValue(mockIsSignedIn),
          loginUseCaseProvider.overrideWithValue(mockLoginUseCase),
          signOutUseCaseProvider.overrideWithValue(mockSignOut),
          signUpUseCaseProvider.overrideWithValue(mockSignUp),
          verifyEmailUseCaseProvider.overrideWithValue(mockVerifyEmail),
          resendVerificationEmailUseCaseProvider
              .overrideWithValue(mockResendVerificationEmail),
          forgotPasswordUseCaseProvider.overrideWithValue(mockForgotPassword),
          confirmPasswordResetUseCaseProvider
              .overrideWithValue(mockConfirmPasswordReset),
          loggingServiceProvider.overrideWithValue(mockLoggingService),
          // Override tokenManagerProvider to avoid initialization errors
          tokenManagerProvider.overrideWith(() => _FakeTokenManager()),
        ],
      );
    }

    group('build()', () {
      test('initial state is AsyncValue.data with initial AuthState', () async {
        // Arrange
        final container = createContainer();
        addTearDown(container.dispose);

        // Act - await the build to complete
        await container.read(authProvider.future);

        // Assert - read state after awaiting
        final authStateAsync = container.read(authProvider);
        expect(
          authStateAsync,
          isA<AsyncData<AuthState>>()
              .having((state) => state.value.isAuthenticated, 'isAuthenticated',
                  false)
              .having((state) => state.value.user, 'user', null),
        );
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

        final container = createContainer();
        addTearDown(container.dispose);

        // Act - await the build to complete
        await container.read(authProvider.future);

        // Assert - read state after awaiting
        final authStateAsync = container.read(authProvider);
        expect(
          authStateAsync,
          isA<AsyncData<AuthState>>()
              .having((state) => state.value.isAuthenticated, 'isAuthenticated',
                  true)
              .having((state) => state.value.user, 'user', user),
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

        final container = createContainer();
        addTearDown(container.dispose);

        // Act
        final future = container.read(authProvider.notifier).signIn(
              'test@test.com',
              'password',
            );

        // Assert - while loading (AsyncValue.loading() preserves previous value)
        final state = container.read(authProvider);
        expect(state.isLoading, isTrue);

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

        final container = createContainer();
        addTearDown(container.dispose);

        // Act
        await container.read(authProvider.notifier).signIn(
              'test@test.com',
              'password',
            );

        // Assert
        final authStateAsync = container.read(authProvider);
        expect(
          authStateAsync,
          isA<AsyncData<AuthState>>()
              .having((state) => state.value.isAuthenticated, 'isAuthenticated',
                  true)
              .having((state) => state.value.user, 'user', user),
        );
      });

      test('sets error state on sign in failure', () async {
        // Arrange
        when(() => mockLoginUseCase(any()))
            .thenThrow(Exception('Sign in failed'));

        final container = createContainer();
        addTearDown(container.dispose);

        // Act
        await container.read(authProvider.notifier).signIn(
              'test@test.com',
              'password',
            );

        // Assert
        final authStateAsync = container.read(authProvider);
        expect(
          authStateAsync,
          isA<AsyncError<AuthState>>()
              .having((state) => state.hasError, 'hasError', true)
              .having((state) => state.error.toString(), 'error',
                  contains('Sign in failed')),
        );
      });

      test('returns unverified state when user is not confirmed', () async {
        // Arrange
        when(() => mockLoginUseCase(any()))
            .thenThrow(const AuthException('UserNotConfirmedException'));

        final container = createContainer();
        addTearDown(container.dispose);

        // Act
        await container.read(authProvider.notifier).signIn(
              'test@test.com',
              'password',
            );

        // Assert
        final authStateAsync = container.read(authProvider);
        expect(
          authStateAsync,
          isA<AsyncData<AuthState>>().having(
              (state) => state.value.requiresEmailVerification,
              'requiresEmailVerification',
              true),
        );
      });
    });

    group('signUp', () {
      test('sets loading state while signing up', () async {
        // Arrange
        final user = User(
          id: '1',
          email: 'test@test.com',
          username: 'test',
          createdAt: DateTime.now(),
        );
        when(() => mockSignUp(any())).thenAnswer((_) async => (user, false));

        final container = createContainer();
        addTearDown(container.dispose);

        // Await initial build
        await container.read(authProvider.future);

        // Act
        final future = container.read(authProvider.notifier).signUp(
              email: 'test@test.com',
              password: 'password',
              name: 'Test',
            );

        // Assert - while loading (AsyncValue.loading() preserves previous value)
        final state = container.read(authProvider);
        expect(state.isLoading, isTrue);

        // Complete sign up
        await future;
      });

      test('sets authenticated state on successful sign up', () async {
        // Arrange
        final user = User(
          id: '1',
          email: 'test@test.com',
          username: 'test',
          createdAt: DateTime.now(),
        );
        when(() => mockSignUp(any())).thenAnswer((_) async => (user, false));

        final container = createContainer();
        addTearDown(container.dispose);

        // Await initial build
        await container.read(authProvider.future);

        // Act
        await container.read(authProvider.notifier).signUp(
              email: 'test@test.com',
              password: 'password',
              name: 'Test',
            );

        // Assert
        final authStateAsync = container.read(authProvider);
        expect(
          authStateAsync,
          isA<AsyncData<AuthState>>()
              .having((state) => state.value.isAuthenticated, 'isAuthenticated',
                  true)
              .having((state) => state.value.user, 'user', user),
        );
      });

      test('sets unverified state when email verification is required',
          () async {
        // Arrange
        final user = User(
          id: '1',
          email: 'test@test.com',
          username: 'test',
          createdAt: DateTime.now(),
        );
        when(() => mockSignUp(any())).thenAnswer((_) async => (user, true));

        final container = createContainer();
        addTearDown(container.dispose);

        // Await initial build
        await container.read(authProvider.future);

        // Act
        await container.read(authProvider.notifier).signUp(
              email: 'test@test.com',
              password: 'password',
              name: 'Test',
            );

        // Assert
        final authStateAsync = container.read(authProvider);
        expect(
          authStateAsync,
          isA<AsyncData<AuthState>>().having(
              (state) => state.value.requiresEmailVerification,
              'requiresEmailVerification',
              true),
        );
      });
    });

    group('signOut', () {
      test('sets loading state while signing out', () async {
        // Arrange
        when(() => mockSignOut()).thenAnswer((_) async {});

        final container = createContainer();
        addTearDown(container.dispose);

        // Act
        final future = container.read(authProvider.notifier).signOut();

        // Assert - while loading (AsyncValue.loading() preserves previous value)
        final state = container.read(authProvider);
        expect(state.isLoading, isTrue);

        // Complete sign out
        await future;
      });

      test('sets initial state on successful sign out', () async {
        // Arrange
        when(() => mockSignOut()).thenAnswer((_) async {});

        final container = createContainer();
        addTearDown(container.dispose);

        // Act
        await container.read(authProvider.notifier).signOut();

        // Assert
        final authStateAsync = container.read(authProvider);
        expect(
          authStateAsync,
          isA<AsyncData<AuthState>>()
              .having((state) => state.value.isAuthenticated, 'isAuthenticated',
                  false)
              .having((state) => state.value.user, 'user', null),
        );
      });

      test('sets error state on sign out failure', () async {
        // Arrange
        when(() => mockSignOut()).thenThrow(Exception('Sign out failed'));

        final container = createContainer();
        addTearDown(container.dispose);

        // Act
        await container.read(authProvider.notifier).signOut();

        // Assert
        final authStateAsync = container.read(authProvider);
        expect(
          authStateAsync,
          isA<AsyncError<AuthState>>()
              .having((state) => state.hasError, 'hasError', true)
              .having((state) => state.error.toString(), 'error',
                  contains('Sign out failed')),
        );
      });
    });

    group('verifyEmail', () {
      test('verifies email successfully', () async {
        // Arrange
        final user = User(
          id: '1',
          email: 'test@test.com',
          username: 'test',
          createdAt: DateTime.now(),
        );
        when(() => mockVerifyEmail(any()))
            .thenAnswer((_) async => Future.value());
        when(() => mockIsSignedIn()).thenAnswer((_) async => true);
        when(() => mockGetCurrentUser()).thenAnswer((_) async => user);

        final container = createContainer();
        addTearDown(container.dispose);

        // Act
        await container.read(authProvider.notifier).verifyEmail(
              '123456',
              'test@test.com',
            );

        // Assert
        final authStateAsync = container.read(authProvider);
        expect(
          authStateAsync,
          isA<AsyncData<AuthState>>()
              .having((state) => state.value.isAuthenticated, 'isAuthenticated',
                  true)
              .having((state) => state.value.user, 'user', user),
        );
      });
    });

    group('forgotPassword', () {
      test('requests password reset successfully', () async {
        // Arrange
        when(() => mockForgotPassword(any()))
            .thenAnswer((_) async => Future.value());

        final container = createContainer();
        addTearDown(container.dispose);

        // Act
        await container.read(authProvider.notifier).forgotPassword(
              'test@test.com',
            );

        // Assert
        final authStateAsync = container.read(authProvider);
        expect(
          authStateAsync,
          isA<AsyncData<AuthState>>().having(
              (state) => state.value.requiresPasswordReset,
              'requiresPasswordReset',
              true),
        );
      });
    });

    group('confirmPasswordReset', () {
      test('resets password successfully', () async {
        // Arrange
        when(() => mockConfirmPasswordReset(any()))
            .thenAnswer((_) async => Future.value());

        final container = createContainer();
        addTearDown(container.dispose);

        // Act
        await container.read(authProvider.notifier).confirmPasswordReset(
              code: '123456',
              newPassword: 'newPassword',
              email: 'test@test.com',
            );

        // Assert
        final authStateAsync = container.read(authProvider);
        expect(
          authStateAsync,
          isA<AsyncData<AuthState>>()
              .having((state) => state.value.isAuthenticated, 'isAuthenticated',
                  false)
              .having((state) => state.value.user, 'user', null),
        );
      });
    });

    group('resendVerificationEmail', () {
      test('resends verification email successfully', () async {
        // Arrange
        final user = User(
          id: '1',
          email: 'test@test.com',
          username: 'test',
          createdAt: DateTime.now(),
        );
        when(() => mockLoginUseCase(any())).thenAnswer((_) async => user);
        when(() => mockResendVerificationEmail())
            .thenAnswer((_) async => Future.value());
        when(() => mockIsSignedIn()).thenAnswer((_) async => true);
        when(() => mockGetCurrentUser()).thenAnswer((_) async => user);

        final container = createContainer();
        addTearDown(container.dispose);

        // First, sign in to set up the state with a user
        await container.read(authProvider.notifier).signIn(
              'test@test.com',
              'password',
            );

        // Act
        await container.read(authProvider.notifier).resendVerificationEmail();

        // Assert
        final authStateAsync = container.read(authProvider);
        expect(
          authStateAsync,
          isA<AsyncData<AuthState>>().having(
              (state) => state.value.requiresEmailVerification,
              'requiresEmailVerification',
              true),
        );
      });
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

