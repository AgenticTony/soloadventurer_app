# Error Handling Reference

## Overview

This document provides a comprehensive reference for handling authentication-related errors in the SoloAdventurer app. It covers error types, categorization, user messages, recovery actions, and best practices.

## Table of Contents

- [Error Categories](#error-categories)
- [Error Types](#error-types)
- [AuthErrorHandler Service](#autherrorhandler-service)
- [Error UI Components](#error-ui-components)
- [Handling Errors in UI](#handling-errors-in-ui)
- [Best Practices](#best-practices)

## Error Categories

Errors are categorized into five main categories for appropriate handling:

### 1. Network Errors

Temporary network issues that can be resolved by retrying.

**Characteristics**:
- User's internet connection is unstable or unavailable
- Server is temporarily unreachable
- DNS resolution failures

**Handling Strategy**: ✅ **Auto-retry with exponential backoff**

### 2. Credential Errors

Issues with user credentials that require user action.

**Characteristics**:
- Invalid email or password
- User account doesn't exist
- Email not verified

**Handling Strategy**: ❌ **No retry - prompt user to correct credentials**

### 3. Token Errors

Authentication token issues that can often be resolved automatically.

**Characteristics**:
- Access token expired
- Refresh token expired
- Invalid token format

**Handling Strategy**: ⚠️ **Conditional retry - auto-refresh or re-authenticate**

### 4. Rate Limit Errors

Server-side rate limiting to prevent abuse.

**Characteristics**:
- Too many login attempts
- Too many API requests
- Temporary throttling

**Handling Strategy**: ⏸️ **Wait before retrying**

### 5. Server Errors

Server-side issues that are temporary and can be retried.

**Characteristics**:
- Internal server error (500)
- Service unavailable (503)
- Gateway timeout (504)

**Handling Strategy**: ✅ **Auto-retry with exponential backoff**

## Error Types

### Network Errors

#### NetworkConnectivityException

```dart
NetworkConnectivityException(
  message: 'No internet connection',
  code: 'network_connectivity',
)
```

**User Message**: "You're not connected to the internet. Please check your connection and try again."

**Recovery Actions**:
1. Check internet connection
2. Wait for connection to be restored
3. Retry the operation

#### NetworkTimeoutException

```dart
NetworkTimeoutException(
  message: 'Request timed out',
  code: 'network_timeout',
)
```

**User Message**: "The request timed out. Please check your connection and try again."

**Recovery Actions**:
1. Check internet connection speed
2. Retry the operation

### Credential Errors

#### InvalidCredentialsException

```dart
AuthException(
  message: 'Invalid email or password',
  code: 'INVALID_CREDENTIALS',
)
```

**User Message**: "The email or password you entered is incorrect. Please try again."

**Recovery Actions**:
1. Re-enter email and password
2. Check for typos
3. Use "Forgot Password" if needed
4. Ensure caps lock is off

#### UserNotFoundException

```dart
AuthException(
  message: 'User not found',
  code: 'USER_NOT_FOUND',
)
```

**User Message**: "We couldn't find an account with that email. Would you like to sign up?"

**Recovery Actions**:
1. Verify email address is correct
2. Sign up for a new account
3. Use a different email address

#### EmailNotVerifiedException

```dart
AuthException(
  message: 'Email not verified',
  code: 'EMAIL_NOT_VERIFIED',
)
```

**User Message**: "Please verify your email address before signing in. Check your inbox for a verification link."

**Recovery Actions**:
1. Check email inbox for verification link
2. Resend verification email
3. Check spam folder
4. Verify email address is correct

### Token Errors

#### TokenExpiredException

```dart
AuthException(
  message: 'Token expired',
  code: 'TOKEN_EXPIRED',
)
```

**User Message**: "Your session has expired. We're refreshing it now..." (auto-refresh)

**Recovery Actions**:
1. **Automatic**: Token is refreshed in background
2. If auto-refresh fails, prompt user to log in again

#### RefreshTokenExpiredException

```dart
AuthException(
  message: 'Refresh token expired',
  code: 'REFRESH_TOKEN_EXPIRED',
)
```

**User Message**: "Your session has expired. Please sign in again to continue."

**Recovery Actions**:
1. Navigate to login screen
2. User must authenticate again

### Rate Limit Errors

#### RateLimitExceededException

```dart
AuthException(
  message: 'Rate limit exceeded',
  code: 'RATE_LIMIT_EXCEEDED',
  retryAfter: Duration(seconds: 60),
)
```

**User Message**: "You've made too many attempts. Please wait 1 minute before trying again."

**Recovery Actions**:
1. Wait for the specified time
2. Retry after waiting period
3. Contact support if this persists

### Server Errors

#### InternalServerErrorException

```dart
AuthException(
  message: 'Internal server error',
  code: 'SERVER_ERROR_500',
)
```

**User Message**: "Something went wrong on our end. Please try again."

**Recovery Actions**:
1. Retry the operation (automatic)
2. Wait a moment and try again
3. Contact support if issue persists

#### ServiceUnavailableException

```dart
AuthException(
  message: 'Service unavailable',
  code: 'SERVER_ERROR_503',
)
```

**User Message**: "Our service is temporarily unavailable. Please try again in a few minutes."

**Recovery Actions**:
1. Wait and retry
2. Check status page for outages
3. Contact support

## AuthErrorHandler Service

The `AuthErrorHandler` service provides centralized error handling for authentication errors.

### Features

- ✅ Error categorization (5 categories)
- ✅ User-friendly error messages
- ✅ Actionable recovery steps
- ✅ Logging for debugging
- ✅ Retry decision logic

### API Reference

```dart
class AuthErrorHandler {
  /// Categorizes an error into one of 5 categories
  AuthErrorCategory categorize(dynamic error);

  /// Gets a user-friendly error message
  String getUserMessage(AuthException error);

  /// Gets recovery steps for an error
  List<String> getRecoverySteps(AuthException error);

  /// Determines if an error should be retried
  bool shouldRetry(AuthException error);

  /// Logs an error with context
  void logError(AuthException error, {String? context});
}
```

### Usage Example

```dart
final errorHandler = AuthErrorHandler();

try {
  await authRepository.signInWithEmailAndPassword(email, password);
} catch (e) {
  if (e is AuthException) {
    // Categorize the error
    final category = errorHandler.categorize(e);

    // Get user-friendly message
    final userMessage = errorHandler.getUserMessage(e);

    // Get recovery steps
    final recoverySteps = errorHandler.getRecoverySteps(e);

    // Determine if we should retry
    final shouldRetry = errorHandler.shouldRetry(e);

    // Log for debugging
    errorHandler.logError(e, context: 'Login flow');

    // Show error to user
    showErrorSnackBar(
      message: userMessage,
      recoverySteps: recoverySteps,
      onRetry: shouldRetry ? () => retryLogin() : null,
    );
  }
}
```

### Error Categories Enum

```dart
enum AuthErrorCategory {
  /// Temporary network issues (auto-retry)
  network,

  /// Invalid credentials (no retry)
  credentials,

  /// Token issues (conditional retry)
  token,

  /// Rate limiting (wait before retry)
  rateLimit,

  /// Server errors (auto-retry)
  server,
}
```

## Error UI Components

### 1. AuthErrorDisplay Widget

A reusable widget for displaying authentication errors in forms.

```dart
AuthErrorDisplay(
  error: authException,
  onRetry: () => retryOperation(),
)
```

**Features**:
- Shows error icon and message
- Displays recovery steps
- Retry button (if error is retryable)
- Dismissible

### 2. AuthErrorBanner Widget

A non-intrusive banner for showing errors at the top of the screen.

```dart
AuthErrorBanner(
  error: authException,
  onDismiss: () => dismissError(),
  onRetry: () => retryOperation(),
)
```

**Features**:
- Material Design banner style
- Shows error summary
- Retry action button
- Dismissible

### 3. AuthRetryButton Widget

A specialized button for retrying failed operations with countdown timer.

```dart
AuthRetryButton(
  onPressed: () => retryOperation(),
  attemptNumber: currentAttempt,
  maxAttempts: 3,
)
```

**Features**:
- Countdown timer with exponential backoff
- Shows attempt number ("Attempt 2 of 3")
- Automatically disabled during countdown
- Cancel button

### 4. Error Screens

Dedicated screens for severe error scenarios:

#### SessionExpiredScreen

Shown when user's session has expired and cannot be refreshed.

```dart
SessionExpiredScreen(
  onSignInAgain: () => navigateToLogin(),
  onCancel: () => navigateToHome(),
)
```

#### NetworkErrorScreen

Shown when network connectivity is lost.

```dart
NetworkErrorScreen(
  onRetry: () => retryOperation(),
  onContinueOffline: () => enableOfflineMode(),
  isOffline: true,
)
```

#### CredentialsErrorScreen

Shown when credentials are invalid.

```dart
CredentialsErrorScreen(
  error: authException,
  onTryAgain: () => goBackToLogin(),
  onForgotPassword: () => navigateToForgotPassword(),
  onSignUp: () => navigateToSignUp(),
)
```

#### RateLimitErrorScreen

Shown when rate limit is exceeded.

```dart
RateLimitErrorScreen(
  retryAfter: Duration(minutes: 5),
  onRetry: () => retryOperation(),
)
```

## Handling Errors in UI

### Pattern 1: Try-Catch with Error Display

```dart
Future<void> _handleLogin() async {
  setState(() => _isLoading = true);

  try {
    await ref.read(authProvider.notifier).signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );
    // Navigate to home on success
  } catch (e) {
    if (e is AuthException) {
      setState(() {
        _error = e;
      });
    }
  } finally {
    setState(() => _isLoading = false);
  }
}

// In build method
if (_error != null) {
  AuthErrorDisplay(
    error: _error!,
    onRetry: () => _handleLogin(),
  )
}
```

### Pattern 2: Error Banner

```dart
// In your widget state
AuthException? _error;

void _showError(AuthException error) {
  setState(() => _error = error);
}

void _dismissError() {
  setState(() => _error = null);
}

// In build method
Stack(
  children: [
    // Your main content
    _buildContent(),

    // Error banner on top
    if (_error != null)
      Positioned(
        top: 0,
        left: 0,
        right: 0,
        child: AuthErrorBanner(
          error: _error!,
          onDismiss: _dismissError,
          onRetry: () => _retryOperation(),
        ),
      ),
  ],
)
```

### Pattern 3: Navigation to Error Screen

```dart
Future<void> _handleLogin() async {
  try {
    await ref.read(authProvider.notifier).signIn(
      email: _emailController.text,
      password: _passwordController.text,
    );
  } on AuthException catch (e) {
    final category = AuthErrorHandler().categorize(e);

    if (category == AuthErrorCategory.credentials) {
      // Navigate to credentials error screen
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (_) => CredentialsErrorScreen(
            error: e,
            onTryAgain: () => Navigator.pop(context),
            onForgotPassword: () => _navigateToForgotPassword(),
          ),
        ),
      );
    }
  }
}
```

### Pattern 4: Silent Retry with Notification

```dart
Future<void> _refreshToken() async {
  try {
    await ref.read(authProvider.notifier).refreshToken();
  } catch (e) {
    if (e is AuthException) {
      final category = AuthErrorHandler().categorize(e);

      if (category == AuthErrorCategory.network) {
        // Silent retry with exponential backoff
        await Future.delayed(Duration(seconds: 1));
        await _refreshToken();
      } else if (category == AuthErrorCategory.token) {
        // Show non-intrusive notification
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Session expired. Please sign in again.'),
            action: SnackBarAction(
              label: 'Sign In',
              onPressed: () => _navigateToLogin(),
            ),
          ),
        );
      }
    }
  }
}
```

## Best Practices

### DO ✅

1. **Always catch specific exceptions**
   ```dart
   try {
     await authOperation();
   } on AuthException catch (e) {
     // Handle auth-specific errors
   } on NetworkException catch (e) {
     // Handle network errors
   }
   ```

2. **Use AuthErrorHandler for consistent error messages**
   ```dart
   final userMessage = errorHandler.getUserMessage(error);
   showSnackBar(userMessage);
   ```

3. **Log errors for debugging**
   ```dart
   errorHandler.logError(error, context: 'Login flow');
   ```

4. **Provide recovery actions**
   ```dart
   showErrorDialog(
     message: userMessage,
     actions: [
       TextButton(
         onPressed: () => retryOperation(),
         child: Text('Retry'),
       ),
     ],
   );
   ```

5. **Check error category before retrying**
   ```dart
   if (errorHandler.shouldRetry(error)) {
     await retryOperation();
   }
   ```

6. **Use appropriate UI component for error severity**
   - Minor errors: Banner or SnackBar
   - Recoverable errors: Error display with retry
   - Severe errors: Dedicated error screen

7. **Never log sensitive information**
   ```dart
   // ❌ Bad
   debugPrint('Error: ${error.password}');

   // ✅ Good
   debugPrint('Error: ${error.message}');
   ```

### DON'T ❌

1. **Don't catch all exceptions indiscriminately**
   ```dart
   // ❌ Bad
   try {
     await authOperation();
   } catch (e) {
     // Too generic
   }

   // ✅ Good
   try {
     await authOperation();
   } on AuthException catch (e) {
     // Handle auth errors
   }
   ```

2. **Don't show technical error messages to users**
   ```dart
   // ❌ Bad
   showSnackBar('Error: INVALID_CREDENTIALS (code: 401)');

   // ✅ Good
   showSnackBar(errorHandler.getUserMessage(error));
   ```

3. **Don't retry indefinitely**
   ```dart
   // ❌ Bad
   while (failed) {
     await retry();
   }

   // ✅ Good
   for (int i = 0; i < maxRetries; i++) {
     await retry();
   }
   ```

4. **Don't ignore errors**
   ```dart
   // ❌ Bad
   try {
     await authOperation();
   } catch (e) {
     // Silently ignored
   }

   // ✅ Good
   try {
     await authOperation();
   } catch (e) {
     handleError(e);
   }
   ```

5. **Don't block UI with error dialogs for minor issues**
   ```dart
   // ❌ Bad - Using dialog for network timeout
   showDialog(
     context: context,
     builder: (_) => AlertDialog(
       title: Text('Network Timeout'),
     ),
   );

   // ✅ Good - Using banner for network timeout
   showSnackBar(
     'Request timed out. Retrying...',
     duration: Duration(seconds: 2),
   );
   ```

## Error Recovery Flow

```
┌──────────────────┐
│ Error Occurs     │
└────────┬─────────┘
         │
         ▼
┌──────────────────┐
│ Categorize Error │
└────────┬─────────┘
         │
    ┌────┴────┬─────────┬─────────┬─────────┐
    ▼         ▼         ▼         ▼         ▼
┌────────┐ ┌────────┐ ┌──────┐ ┌────────┐ ┌──────┐
│Network │ │Credent│ │Token │ │Rate    │ │Server│
│        │ │  ials │ │      │ │ Limit  │ │      │
└───┬────┘ └───┬────┘ └───┬──┘ └───┬────┘ └───┬──┘
    │          │          │          │          │
    ▼          ▼          ▼          ▼          ▼
┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐ ┌────────┐
│Auto    │ │Show    │ │Auto    │ │Wait    │ │Auto    │
│Retry   │ │Error   │ │Refresh │ │& Retry │ │Retry   │
│w/Backoff│ │Screen  │ │or Login│ │        │ │w/Backoff│
└────────┘ └────────┘ └────────┘ └────────┘ └────────┘
```

---

**Document Version**: 1.0
**Last Updated**: 2026-01-04
**Maintainer**: SoloAdventurer Team
