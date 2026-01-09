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
  static const _minTokenValidity = Duration(minutes: 5);

  @override
  FeatureAvailability build() {
    // Initialize with unauthorized state
    print('TokenManager: Initializing with unauthorized state');
    return FeatureAvailability.unauthorized;
  }

  Future<void> initialize() async {
    print('TokenManager: Starting initialization');
    final newState = await _calculateCurrentState();
    state = newState;
    print('TokenManager: Initialized with state: $newState');
    _scheduleTokenRefresh();
  }

  Future<FeatureAvailability> _calculateCurrentState() async {
    print('TokenManager: Calculating current state');
    print('TokenManager: Online status: ${_connectivityService.isOnline}');

    final tokens = await _secureStorage.getStoredTokens();
    final hasValidTokens = tokens != null && await _validateTokens(tokens);

    print('TokenManager: Has valid tokens: $hasValidTokens');

    if (!_connectivityService.isOnline) {
      return hasValidTokens
          ? FeatureAvailability.offlineWithCache
          : FeatureAvailability.unauthorized;
    }

    return hasValidTokens
        ? FeatureAvailability.fullyAvailable
        : FeatureAvailability.unauthorized;
  }

  void _handleConnectivityChange(bool isOnline) async {
    print('TokenManager: Connectivity changed - Online: $isOnline');
    final newState = await _calculateCurrentState();
    print('TokenManager: New state after connectivity change: $newState');

    if (newState != state) {
      state = newState;
      if (isOnline && newState == FeatureAvailability.fullyAvailable) {
        _scheduleTokenRefresh();
      }
    }
  }

  Future<bool> _validateTokens(AuthTokens tokens) async {
    final jwt = JWT.decode(tokens.accessToken);
    final expiryTime = DateTime.fromMillisecondsSinceEpoch(jwt.expiryTime * 1000);
    final now = DateTime.now();
    return now.isBefore(expiryTime.subtract(_minTokenValidity));
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

### User Feedback Implementation

```dart
// In LoginScreen
ref.listen(authStateProvider, (previous, next) {
  if (next.error?.isNotEmpty == true && mounted) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(next.error!),
        backgroundColor: Theme.of(context).colorScheme.error,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
});
```

### Error Message Standardization

For security and user experience, error messages are standardized:

1. Authentication Failures

   - "Unable to sign in. Please check your email and password."
   - Avoids revealing whether email or password was incorrect

2. Email Verification

   - Clear guidance when verification is needed
   - Success confirmation without revealing sensitive information

3. Loading States
   - Visual indicators during operations
   - Disabled inputs during processing
   - Clear feedback on operation status

### Error Recovery

1. Automatic Recovery

   - Retry with exponential backoff for transient failures
   - Automatic redirect to appropriate screens based on state

2. User-Initiated Recovery
   - Clear error messages with action guidance
   - Easy access to recovery flows (password reset, resend verification)

### Implementation Guidelines

1. Security First

   - Never reveal sensitive information in error messages
   - Use generic messages for authentication failures
   - Log detailed errors server-side only

2. User Experience

   - Show errors inline where possible
   - Provide clear next steps
   - Maintain context during error recovery

3. Error Propagation
   - Use AsyncValue for consistent error handling
   - Proper error mapping in data sources
   - Centralized error handling in state management

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
