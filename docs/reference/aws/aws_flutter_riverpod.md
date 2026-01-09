# AWS Cognito Flutter and Riverpod Integration Guide

## AWS Cognito Flutter Implementation

### Token Management with AWS Cognito

The AWS Cognito Identity SDK for Flutter provides robust token management capabilities through the `CognitoUserSession` class. Here's how to implement token refresh:

```dart
class TokenManager {
  final CognitoUserPool _userPool;
  CognitoUser? _cognitoUser;
  CognitoUserSession? _session;

  Future<void> refreshToken() async {
    if (_cognitoUser == null || _session == null) {
      throw AuthException('No authenticated user');
    }

    try {
      final refreshToken = _session!.getRefreshToken();
      if (refreshToken == null) {
        throw AuthException('No refresh token available');
      }

      _session = await _cognitoUser!.refreshSession(refreshToken);
      if (_session == null) {
        throw AuthException('Failed to refresh session');
      }

      // Return new session tokens
      return AuthSession(
        accessToken: _session!.getAccessToken().getJwtToken()!,
        idToken: _session!.getIdToken().getJwtToken()!,
        refreshToken: _session!.getRefreshToken()!.getToken()!,
        expiresAt: DateTime.fromMillisecondsSinceEpoch(
          _session!.getAccessToken().getExpiration() * 1000,
        ),
      );
    } catch (e) {
      throw AuthException('Failed to refresh token: ${e.toString()}');
    }
  }
}
```

### Error Handling

AWS Cognito provides specific exceptions for different authentication scenarios:

```dart
try {
  session = await cognitoUser.authenticateUser(authDetails);
} on CognitoUserNewPasswordRequiredException catch (e) {
  // Handle new password required
} on CognitoUserMfaRequiredException catch (e) {
  // Handle MFA required
} on CognitoUserTotpRequiredException catch (e) {
  // Handle TOTP required
} on CognitoUserCustomChallengeException catch (e) {
  // Handle custom challenge
} on CognitoUserConfirmationNecessaryException catch (e) {
  // Handle confirmation necessary
} on CognitoClientException catch (e) {
  // Handle wrong credentials
}
```

## Riverpod Integration

### Token Management with Riverpod

Riverpod provides reactive state management for token handling:

```dart
@riverpod
class TokenNotifier extends _$TokenNotifier {
  @override
  AsyncValue<AuthSession?> build() => const AsyncValue.data(null);

  Future<void> refreshToken() async {
    state = const AsyncValue.loading();
    try {
      final newSession = await ref.read(tokenManagerProvider).refreshToken();
      state = AsyncValue.data(newSession);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void clearSession() {
    state = const AsyncValue.data(null);
  }
}
```

### UI Integration

Combine AWS Cognito with Riverpod in your UI:

```dart
class TokenRefreshIndicator extends ConsumerWidget {
  final Widget child;

  const TokenRefreshIndicator({
    Key? key,
    required this.child,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final tokenState = ref.watch(tokenNotifierProvider);

    return tokenState.when(
      data: (session) => child,
      loading: () => const LoadingOverlay(),
      error: (error, stack) => TokenExpiredDialog(),
    );
  }
}
```

## Best Practices

1. **Token Refresh Strategy**:

   - Implement automatic refresh before token expiration
   - Use exponential backoff for retry attempts
   - Handle offline scenarios gracefully

2. **Security**:

   - Store tokens securely using platform-specific secure storage
   - Clear tokens on sign out
   - Implement proper error handling for token expiration

3. **State Management**:

   - Use Riverpod providers to manage authentication state
   - Implement proper state transitions
   - Handle loading and error states appropriately

4. **UI/UX**:
   - Show loading indicators during token refresh
   - Provide clear feedback for authentication errors
   - Implement smooth re-authentication flows

## Common Patterns

1. **Silent Token Refresh**:

```dart
@riverpod
class TokenRefresh extends _$TokenRefresh {
  Timer? _refreshTimer;

  @override
  void build() {
    ref.onDispose(() => _refreshTimer?.cancel());
    _scheduleTokenRefresh();
  }

  void _scheduleTokenRefresh() {
    final session = ref.read(tokenNotifierProvider).value;
    if (session == null) return;

    final refreshAt = session.expiresAt
        .subtract(const Duration(minutes: 5));

    _refreshTimer = Timer(
      refreshAt.difference(DateTime.now()),
      () => ref.read(tokenNotifierProvider.notifier).refreshToken(),
    );
  }
}
```

2. **Error Recovery**:

```dart
@riverpod
class TokenErrorHandler extends _$TokenErrorHandler {
  int _attempts = 0;
  static const maxAttempts = 3;

  @override
  void build() {
    ref.listen(tokenNotifierProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stack) => _handleError(error),
      );
    });
  }

  Future<void> _handleError(Object error) async {
    if (_attempts >= maxAttempts) {
      ref.read(authNavigationProvider.notifier).navigateToLogin();
      return;
    }

    _attempts++;
    await Future.delayed(Duration(seconds: pow(2, _attempts)));
    ref.read(tokenNotifierProvider.notifier).refreshToken();
  }
}
```

3. **User Feedback**:

```dart
@riverpod
class AuthenticationState extends _$AuthenticationState {
  @override
  void build() {
    ref.listen(tokenNotifierProvider, (previous, next) {
      next.whenOrNull(
        error: (error, _) => _showError(error),
        loading: () => _showLoading(),
      );
    });
  }

  void _showError(Object error) {
    if (error is TokenExpiredException) {
      showDialog(
        context: context,
        builder: (_) => const TokenExpiredDialog(),
      );
    }
  }
}
```
