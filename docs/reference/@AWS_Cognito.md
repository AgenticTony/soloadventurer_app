# AWS Cognito Documentation (Updated for 2026)

Official Documentation: [AWS Cognito Documentation](https://docs.aws.amazon.com/cognito/)

**Current Version:** AWS Amplify Flutter Gen 2 (2025)

AWS Cognito is Amazon's authentication and authorization service. For complete and up-to-date documentation, please refer to the official AWS Cognito documentation at https://docs.aws.amazon.com/cognito/

> **🚀 2026 Update:** This document now covers AWS Amplify Flutter Gen 2, modern authentication patterns, token refresh best practices, and latest security features.

## Key Documentation Links

### 1. **Amplify Flutter Gen 2**
   - [Set up Amplify Auth](https://docs.amplify.aws/flutter/build-a-backend/auth/set-up-auth/)
   - [Sign In](https://docs.amplify.aws/flutter/build-a-backend/auth/sign-in/)
   - [Sign Up](https://docs.amplify.aws/flutter/build-a-backend/auth/sign-up/)
   - [Manage User Sessions](https://docs.amplify.aws/flutter/build-a-backend/auth/manage-user-sessions/)

### 2. **AWS Cognito User Pools**
   - [What is Amazon Cognito User Pools?](https://docs.aws.amazon.com/cognito/latest/developerguide/cognito-user-identity-pools.html)
   - [Managing Users](https://docs.aws.amazon.com/cognito/latest/developerguide/managing-users.html)
   - [Authentication](https://docs.aws.amazon.com/cognito/latest/developerguide/authentication.html)

### 3. **Security & Best Practices**
   - [Security in Amazon Cognito](https://docs.aws.amazon.com/cognito/latest/developerguide/security.html)
   - [Token Management](https://docs.aws.amazon.com/cognito/latest/developerguide/amazon-cognito-user-pools-using-tokens-with-identity-providers.html)
   - [Security Best Practices](https://docs.aws.amazon.com/cognito/latest/developerguide/security-best-practices.html)

### 4. **SDK Integration**
   - [amplify_flutter Package](https://pub.dev/packages/amplify_flutter)
   - [amplify_auth_cognito Package](https://pub.dev/packages/amplify_auth_cognito)
   - [Amplify GitHub](https://github.com/aws-amplify/amplify-flutter)

---

## What's New in Amplify Gen 2 (2025)

### Key Features:
- **Type-safe APIs** - Fully generated models and APIs
- **Simplified configuration** - Declarative backend definitions
- **Better Flutter integration** - Native Flutter patterns
- **Enhanced security** - Improved token handling
- **Offline support** - Built-in sync capabilities
- **Better error handling** - More descriptive errors

---

## Core Components (2026 Edition)

### 1. User Pools (Amplify Auth)

- User directory for app users
- Built-in sign-up and sign-in functionality
- Social identity provider integration (Google, Apple, Facebook)
- Multi-factor authentication (MFA)
- Password recovery and verification
- User attributes and custom attributes

### 2. Token Types

- **Access Token** - JWT token for API authorization (expires in 1 hour)
- **ID Token** - JWT token containing user claims (expires in 1 hour)
- **Refresh Token** - Used to obtain new access/ID tokens (expires in 30-1000 days)
- **Device Key** - For remembering trusted devices

### 3. Authentication Methods

- **SRP (Secure Remote Password)** - Secure password authentication
- **USER_PASSWORD_AUTH** - Direct password authentication (simpler, less secure)
- **USER_SRP_AUTH** - SRP-based authentication (recommended)
- **Custom Auth** - Custom authentication challenges
- **Social Sign-in** - OAuth 2.0 providers

---

## Amplify Gen 2 Setup (2026)

### 1. Installation

```yaml
# pubspec.yaml
dependencies:
  amplify_flutter: ^2.0.0
  amplify_auth_cognito: ^2.0.0
```

### 2. Configuration

```dart
// lib/main.dart
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Configure Amplify
  await Amplify.init(
    plugins: [
      AmplifyAuthCognito(),
    ],
  );

  runApp(MyApp());
}
```

### 3. Backend Configuration (amplify/backend.ts)

```typescript
// amplify/backend.ts
import { defineAuth } from '@aws-amplify/backend';

export const auth = defineAuth({
  loginWith: {
    email: true,
    externalProviders: {
      google: {
        clientId: process.env.GOOGLE_CLIENT_ID,
      },
      apple: {
        clientId: {
          production: process.env.APPLE_CLIENT_ID_PROD,
        },
      },
      signOutUrl: 'http://localhost:3000/signout',
    },
  },
  userAttributes: {
    email: { required: true, mutable: false },
    name: { required: false, mutable: true },
    phoneNumber: { required: false, mutable: true },
    picture: { required: false, mutable: true },
  },
  multifactor: {
    mode: 'OPTIONAL',
    sms: true,
    totp: true,
  },
});
```

---

## Authentication Flow (Modern 2026)

### 1. Sign Up

```dart
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

Future<void> signUp({
  required String email,
  required String password,
  required String name,
}) async {
  try {
    final result = await Amplify.Auth.signUp(
      username: email,
      password: password,
      options: SignUpOptions(
        userAttributes: {
          AuthUserAttributeKey.email: email,
          AuthUserAttributeKey.name: name,
        },
      ),
    );

    if (result.isSignUpComplete) {
      // Auto-signed in
      debugPrint('Sign up complete!');
    } else {
      // Need confirmation
      debugPrint('Sign up incomplete: ${result.nextStep.signUpStep}');
    }
  } on AuthException catch (e) {
    debugPrint('Sign up failed: ${e.message}');
  }
}
```

### 2. Confirm Sign Up

```dart
Future<void> confirmSignUp({
  required String email,
  required String code,
}) async {
  try {
    final result = await Amplify.Auth.confirmSignUp(
      username: email,
      confirmationCode: code,
    );

    if (result.isSignUpComplete) {
      debugPrint('Sign up confirmed!');
    }
  } on AuthException catch (e) {
    debugPrint('Confirmation failed: ${e.message}');
  }
}
```

### 3. Sign In

```dart
Future<void> signIn({
  required String email,
  required String password,
}) async {
  try {
    final result = await Amplify.Auth.signIn(
      username: email,
      password: password,
    );

    if (result.isSignedIn) {
      debugPrint('Sign in successful!');
    }
  } on AuthException catch (e) {
    debugPrint('Sign in failed: ${e.message}');
  }
}
```

### 4. Social Sign-In (Google/Apple)

```dart
Future<void> signInWithGoogle() async {
  try {
    final result = await Amplify.Auth.signInWithWebUI(
      provider: AuthProvider.google,
    );

    if (result.isSignedIn) {
      debugPrint('Google sign-in successful!');
    }
  } on AuthException catch (e) {
    debugPrint('Google sign-in failed: ${e.message}');
  }
}
```

---

## Token Management (Modern 2026)

### 1. Get Current Session

```dart
Future<AuthSession?> getCurrentSession() async {
  try {
    final session = await Amplify.Auth.fetchAuthSession(
      options: const FetchAuthSessionOptions(getLatest: true),
    );

    final isSignedIn = session.isSignedIn;

    if (isSignedIn) {
      final tokens = session.userPoolTokens;

      return AuthSession(
        accessToken: tokens?.accessToken.raw,
        idToken: tokens?.idToken.raw,
        refreshToken: tokens?.refreshToken.raw,
        expiresAt: tokens?.accessToken.expiresAt,
      );
    }

    return null;
  } on AuthException catch (e) {
    debugPrint('Failed to get session: ${e.message}');
    return null;
  }
}
```

### 2. Automatic Token Refresh

```dart
class TokenRefreshService {
  Timer? _refreshTimer;

  void startTokenRefreshTimer() {
    // Check token expiration every 5 minutes
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => _checkAndRefreshToken(),
    );
  }

  Future<void> _checkAndRefreshToken() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession(
        options: const FetchAuthSessionOptions(getLatest: true),
      );

      final tokens = session.userPoolTokens;
      final expiration = tokens?.accessToken.expiresAt;

      if (expiration == null) return;

      // Refresh if expiring in less than 10 minutes
      if (expiration.difference(DateTime.now()) < const Duration(minutes: 10)) {
        await _refreshToken();
      }
    } on AuthException catch (e) {
      debugPrint('Token refresh check failed: ${e.message}');
    }
  }

  Future<void> _refreshToken() async {
    try {
      // Amplify automatically refreshes tokens when needed
      final session = await Amplify.Auth.fetchAuthSession(
        options: const FetchAuthSessionOptions(forceRefresh: true),
      );

      debugPrint('Token refreshed successfully!');
    } on AuthException catch (e) {
      debugPrint('Token refresh failed: ${e.message}');
    }
  }

  void stopTokenRefreshTimer() {
    _refreshTimer?.cancel();
  }
}
```

### 3. Sign Out

```dart
Future<void> signOut() async {
  try {
    await Amplify.Auth.signOut();
    debugPrint('Signed out successfully!');
  } on AuthException catch (e) {
    debugPrint('Sign out failed: ${e.message}');
  }
}
```

---

## Security Features (2026)

### 1. MFA (Multi-Factor Authentication)

```dart
// Enable MFA during sign up
Future<void> signUpWithMFA({
  required String email,
  required String password,
}) async {
  try {
    final result = await Amplify.Auth.signUp(
      username: email,
      password: password,
      options: SignUpOptions(
        userAttributes: {
          AuthUserAttributeKey.email: email,
        },
        // MFA will be handled automatically if configured
      ),
    );
  } on AuthException catch (e) {
    debugPrint('Sign up failed: ${e.message}');
  }
}
```

### 2. Remember Device

```dart
Future<void> rememberDevice() async {
  try {
    await Amplify.Auth.rememberDevice();
    debugPrint('Device remembered!');
  } on AuthException catch (e) {
    debugPrint('Failed to remember device: ${e.message}');
  }
}
```

### 3. Secure Token Storage

```dart
// Amplify Gen 2 handles secure storage automatically
// Tokens are stored in:
// - iOS: Keychain
// - Android: Encrypted SharedPreferences
// - Web: Encrypted LocalStorage

// Access tokens are never exposed to the app layer
// Use Amplify.API calls for authenticated requests
```

---

## Error Handling (Modern 2026)

### 1. Common Exceptions

```dart
try {
  await Amplify.Auth.signIn(
    username: email,
    password: password,
  );
} on UserNotConfirmedException catch (e) {
  // User needs to confirm account
  await _confirmUser(email);
} on NotAuthorizedException catch (e) {
  // Wrong password or user doesn't exist
  _showError('Invalid credentials');
} on UserNotFoundException catch (e) {
  // User doesn't exist
  _showError('User not found');
} on AuthException catch (e) {
  // Handle other auth errors
  _showError(e.message);
} on Exception catch (e) {
  // Handle unexpected errors
  _showError('An unexpected error occurred');
}
```

### 2. Error Recovery

```dart
Future<void> handleAuthError(AuthException error) async {
  switch (error.runtimeType) {
    case UserNotConfirmedException:
      // Redirect to confirmation screen
      await _navigateToConfirmation();
      break;

    case NotAuthorizedException:
      // Show sign in screen
      await _navigateToSignIn();
      break;

    case InvalidPasswordException:
    case PasswordPolicyViolationException:
      // Show password requirements
      _showPasswordRequirements();
      break;

    case InvalidParameterException:
      // Validate input
      _validateInput(error.message);
      break;

    case NetworkException:
      // Show retry option
      _showRetryDialog();
      break;

    default:
      // Show generic error
      _showError(error.message);
  }
}
```

---

## Best Practices (2026)

### 1. Token Lifecycle Management

```dart
class TokenManager {
  // ✅ DO: Let Amplify handle token refresh automatically
  Future<AuthSession?> getSession() async {
    final session = await Amplify.Auth.fetchAuthSession(
      options: const FetchAuthSessionOptions(getLatest: true),
    );
    return session.userPoolTokens != null
        ? AuthSession.fromCognitoSession(session)
        : null;
  }

  // ✅ DO: Force refresh when needed
  Future<void> forceRefresh() async {
    await Amplify.Auth.fetchAuthSession(
      options: const FetchAuthSessionOptions(forceRefresh: true),
    );
  }

  // ❌ DON'T: Manually store tokens in shared preferences
  // Amplify handles secure storage automatically
}
```

### 2. Session Validation

```dart
class SessionValidator {
  Future<bool> isSessionValid() async {
    try {
      final session = await Amplify.Auth.fetchAuthSession();

      if (!session.isSignedIn) {
        return false;
      }

      final tokens = session.userPoolTokens;
      final expiration = tokens?.accessToken.expiresAt;

      if (expiration == null) return false;

      // Check if token expires in less than 5 minutes
      return expiration.difference(DateTime.now()) > const Duration(minutes: 5);
    } on Exception {
      return false;
    }
  }
}
```

### 3. Auth State Monitoring

```dart
@riverpod
class AuthStateNotifier extends _$AuthStateNotifier {
  StreamSubscription<AuthHubEvent>? _authHubSubscription;

  @override
  AuthState build() {
    _subscribeToAuthEvents();
    return const AuthState.initial();
  }

  void _subscribeToAuthEvents() {
    _authHubSubscription?.cancel();

    _authHubSubscription = Amplify.Auth.listen(
      (AuthHubEvent event) {
        state = switch (event.type) {
          AuthHubType.signedIn => const AuthState.authenticated(),
          AuthHubType.signedOut => const AuthState.unauthenticated(),
          AuthHubType.sessionExpired => const AuthState.sessionExpired(),
          AuthHubType.tokenRefreshed => const AuthState.tokenRefreshed(),
          _ => state,
        };
      },
    );
  }

  @override
  void dispose() {
    _authHubSubscription?.cancel();
    super.dispose();
  }
}
```

---

## API Integration

### 1. Authenticated API Calls

```dart
class ApiService {
  Future<Map<String, dynamic>> get(String path) async {
    try {
      final restOperation = Amplify.API.get(
        'myApi',
        path,
      );

      final response = await restOperation.response;
      final data = await response.decode();

      return data as Map<String, dynamic>;
    } on ApiException catch (e) {
      debugPrint('API call failed: ${e.message}');
      rethrow;
    }
  }
}
```

### 2. Automatic Token Inclusion

```dart
// Amplify automatically includes auth tokens in API requests
// No manual header manipulation needed

Future<void> fetchProtectedData() async {
  try {
    final restOperation = Amplify.API.get(
      'myApi',
      '/protected',
    );

    final response = await restOperation.response;
    final data = await response.decode();

    debugPrint('Protected data: $data');
  } on ApiException catch (e) {
    if (e.statusCode == 401) {
      // Token expired - Amplify will attempt refresh automatically
      debugPrint('Unauthorized - session may be expired');
    }
    rethrow;
  }
}
```

---

## Testing (2026)

### 1. Mock Auth Service

```dart
class MockAuthService {
  Future<void> signIn(String email, String password) async {
    // Mock implementation for testing
    await Future.delayed(const Duration(milliseconds: 500));

    if (email == 'test@example.com' && password == 'password123') {
      // Simulate successful sign in
      return;
    }

    throw AuthException('Invalid credentials');
  }
}
```

### 2. Test Configuration

```dart
// amplify/configuration.dart
class TestAmplifyConfig {
  static const amplifyConfig = '''
  {
    "version": 1,
    "auth": {
      "plugins": {
        "awsCognitoAuthPlugin": {
          "IdentityManager": {
            "Default": {}
          },
          "CredentialsProvider": {
            "CognitoIdentity": {
              "Default": {
                "PoolId": "test-pool-id",
                "Region": "us-east-1"
              }
            }
          },
          "CognitoUserPool": {
            "Default": {
              "PoolId": "test-pool-id",
              "Region": "us-east-1",
              "AppClient": {
                "WebClient": {
                  "ClientId": "test-client-id"
                }
              }
            }
          },
          "Auth": {
            "Default": {
              "authenticationFlowType": "USER_SRP_AUTH"
            }
          }
        }
      }
    }
  }
  ''';
}
```

---

## Migration Guide

### From Amplify Gen 1 to Gen 2

**❌ OLD (Gen 1):**
```dart
// Manual configuration
final auth = AuthPlugin();

await Amplify.addPlugin(auth);
await Amplify.configure(amplifyconfig);

// Manual token handling
final session = await Amplify.Auth.fetchAuthSession();
final tokens = session.userPoolTokens;
```

**✅ NEW (Gen 2):**
```dart
// Declarative configuration
await Amplify.init(
  plugins: [
    AmplifyAuthCognito(),
  ],
);

// Automatic token refresh
final session = await Amplify.Auth.fetchAuthSession(
  options: const FetchAuthSessionOptions(getLatest: true),
);
```

---

## Resources

### Official
- [AWS Amplify Flutter Docs](https://docs.amplify.aws/flutter/)
- [AWS Cognito Docs](https://docs.aws.amazon.com/cognito/)
- [Amplify GitHub](https://github.com/aws-amplify/amplify-flutter)
- [API Reference](https://pub.dev/documentation/amplify_flutter/latest/)

### Packages
- [amplify_flutter](https://pub.dev/packages/amplify_flutter)
- [amplify_auth_cognito](https://pub.dev/packages/amplify_auth_cognito)
- [amplify_api](https://pub.dev/packages/amplify_api)

### Community
- [AWS Amplify Discord](https://discord.gg/amplify)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/aws-amplify)
- [GitHub Discussions](https://github.com/aws-amplify/amplify-flutter/discussions)

---

**Last Updated:** January 2026
**Amplify Version:** Gen 2.0+
**Flutter Version:** 3.27+
**Dart Version:** 3.3+

## Key Takeaways

### ✅ Modern Patterns (2026):
- Use **Amplify Gen 2** for type-safe APIs
- Let Amplify handle **automatic token refresh**
- Use **AuthHub** for auth state monitoring
- Store user data in **Riverpod providers**
- Implement **proper error boundaries**
- Use **MFA** for enhanced security

### ❌ Deprecated Patterns:
- Manual token storage in SharedPreferences
- Direct Cognito SDK usage (use Amplify)
- Manual token refresh logic (Amplify handles this)
- Storing access tokens insecurely
- Ignoring AuthHub events
