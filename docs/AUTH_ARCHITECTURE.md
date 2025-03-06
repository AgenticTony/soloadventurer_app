# Authentication Architecture

## Overview

This document details the authentication implementation in SoloAdventurer using AWS Cognito and Riverpod. The architecture follows clean architecture principles while leveraging AWS Cognito's security features and Riverpod's state management capabilities.

## Authentication Flow

### 1. Sign In Flow

```dart
@riverpod
class AuthController extends _$AuthController {
  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await _authRepository.signIn(email, password);
      await _tokenManager.storeTokens(result.tokens);
      return result.user;
    });
  }
}
```

### 2. Token Management

```dart
@riverpod
class TokenManager extends _$TokenManager {
  static const _tokenRefreshThreshold = Duration(minutes: 45);

  Future<void> storeTokens(AuthTokens tokens) async {
    await _secureStorage.write(key: 'access_token', value: tokens.accessToken);
    await _secureStorage.write(key: 'refresh_token', value: tokens.refreshToken);
    _scheduleTokenRefresh();
  }

  void _scheduleTokenRefresh() {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(_tokenRefreshThreshold, (_) {
      _refreshTokenIfNeeded();
    });
  }
}
```

### 3. Session Management

```dart
@riverpod
class SessionManager extends _$SessionManager {
  Future<void> initialize() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final tokens = await _tokenManager.getStoredTokens();
      if (tokens != null) {
        await _validateAndRefreshTokens(tokens);
        return SessionState.authenticated;
      }
      return SessionState.unauthenticated;
    });
  }
}
```

## AWS Cognito Integration

### 1. Configuration

```dart
class CognitoConfig {
  static const userPoolId = 'your-user-pool-id';
  static const clientId = 'your-client-id';
  static const region = 'your-region';

  static const authenticationFlow = 'USER_PASSWORD_AUTH';
  static final userPool = CognitoUserPool(userPoolId, clientId);
}
```

### 2. Error Mapping

```dart
sealed class AuthError {
  final String message;
  final String code;
}

class UserNotFoundError extends AuthError {
  UserNotFoundError() : super(
    message: 'No account found with this email',
    code: 'USER_NOT_FOUND',
  );
}

class InvalidCredentialsError extends AuthError {
  InvalidCredentialsError() : super(
    message: 'Invalid email or password',
    code: 'INVALID_CREDENTIALS',
  );
}

class EmailNotVerifiedError extends AuthError {
  EmailNotVerifiedError() : super(
    message: 'Please verify your email address',
    code: 'EMAIL_NOT_VERIFIED',
  );
}
```

### 3. Token Lifecycle

```dart
class TokenLifecycle {
  final Duration accessTokenValidity = const Duration(hours: 1);
  final Duration refreshTokenValidity = const Duration(days: 30);

  bool shouldRefreshToken(String token) {
    final jwt = JWT.decode(token);
    final expiryTime = DateTime.fromMillisecondsSinceEpoch(jwt.expiryTime * 1000);
    final now = DateTime.now();
    return now.isAfter(expiryTime.subtract(const Duration(minutes: 5)));
  }
}
```

## State Management

### 1. Auth State

```dart
sealed class AuthState {
  const AuthState();
}

class Unauthenticated extends AuthState {
  const Unauthenticated();
}

class Authenticated extends AuthState {
  final UserModel user;
  final String token;

  const Authenticated({
    required this.user,
    required this.token,
  });
}

class AuthLoading extends AuthState {
  const AuthLoading();
}
```

### 2. Auth Controller

```dart
@riverpod
class AuthController extends _$AuthController {
  @override
  AsyncValue<AuthState> build() => const AsyncValue.data(Unauthenticated());

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final result = await _authRepository.signIn(email, password);
      return Authenticated(
        user: result.user,
        token: result.token,
      );
    });
  }

  Future<void> signOut() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      await _authRepository.signOut();
      return const Unauthenticated();
    });
  }
}
```

## Error Handling

### 1. Error Propagation

```dart
@riverpod
class ErrorHandler extends _$ErrorHandler {
  @override
  void build() {
    ref.listen(authStateProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stackTrace) {
          if (error is UserNotFoundError) {
            _showErrorDialog('Account not found');
          } else if (error is InvalidCredentialsError) {
            _showErrorDialog('Invalid credentials');
          } else if (error is EmailNotVerifiedError) {
            _navigateToVerification();
          }
        },
      );
    });
  }
}
```

### 2. Rate Limiting

```dart
class RateLimiter {
  final int maxAttempts;
  final Duration resetDuration;
  int _attempts = 0;
  DateTime? _lastAttemptTime;

  void checkRateLimit() {
    final now = DateTime.now();
    if (_lastAttemptTime != null &&
        now.difference(_lastAttemptTime!) > resetDuration) {
      _attempts = 0;
    }

    if (_attempts >= maxAttempts) {
      throw const AuthException(
        'Too many attempts. Please try again later.',
        code: 'RATE_LIMIT_EXCEEDED',
      );
    }

    _attempts++;
    _lastAttemptTime = now;
  }
}
```

## Testing Strategy

### 1. Unit Tests

```dart
void main() {
  group('AuthController', () {
    test('sign in success updates state to authenticated', () async {
      final container = ProviderContainer(
        overrides: [
          authRepositoryProvider.overrideWithValue(MockAuthRepository()),
        ],
      );

      final controller = container.read(authControllerProvider.notifier);
      await controller.signIn('test@example.com', 'password');

      expect(
        container.read(authControllerProvider),
        isA<AsyncData<Authenticated>>(),
      );
    });
  });
}
```

### 2. Integration Tests

```dart
void main() {
  testWidgets('full authentication flow', (tester) async {
    await tester.pumpWidget(const MyApp());

    // Enter credentials
    await tester.enterText(
      find.byKey(const Key('email_field')),
      'test@example.com',
    );
    await tester.enterText(
      find.byKey(const Key('password_field')),
      'password',
    );

    // Tap sign in button
    await tester.tap(find.byKey(const Key('sign_in_button')));
    await tester.pumpAndSettle();

    // Verify navigation to home screen
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
```

## Security Considerations

1. **Token Storage**

   - Access tokens stored in memory only
   - Refresh tokens stored in secure storage
   - No sensitive data in local storage

2. **Session Management**

   - Automatic token refresh
   - Session timeout handling
   - Secure logout process

3. **Error Handling**
   - Rate limiting
   - Secure error messages
   - Proper error logging

## References

- [AWS Cognito Documentation](https://docs.aws.amazon.com/cognito)
- [Riverpod Documentation](https://riverpod.dev)
- [Flutter Secure Storage](https://pub.dev/packages/flutter_secure_storage)
- [JWT Handling](https://pub.dev/packages/jwt_decoder)
