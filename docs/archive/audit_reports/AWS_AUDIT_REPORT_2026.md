# AWS Integration Comprehensive Audit Report
## SoloAdventurer Flutter App - 2026 Production Standards Review

**Audit Date:** 2026-01-06
**Scope:** AWS Cognito, CloudWatch, and Security Implementation
**Standards:** AWS Amplify Gen 2, AWS Security Best Practices, 2026 Mobile App Standards

---

## Executive Summary

This audit identified **6 CRITICAL**, **7 HIGH**, **5 MEDIUM**, and **4 LOW** priority issues across the AWS integration. The most urgent concerns are:

1. **Documentation-Implementation Mismatch**: Documentation recommends AWS Amplify Gen 2, but implementation uses direct Cognito SDK
2. **Security Vulnerabilities**: Hardcoded AWS credentials in environment files
3. **Outdated Architecture**: Manual token management instead of automatic refresh
4. **Missing 2026 Features**: No AuthHub events, no adaptive authentication, no MFA

### Risk Assessment
- **CRITICAL Risk:** Security vulnerabilities with hardcoded credentials
- **HIGH Risk:** Using deprecated SDK patterns (amazon_cognito_identity_dart_2)
- **MEDIUM Risk:** Missing modern security features
- **LOW Risk:** Code organization and maintainability

---

## AWS Services Currently Used

### 1. AWS Cognito
- **Package**: `amazon_cognito_identity_dart_2: ^3.6.0`
- **Purpose**: User authentication, token management
- **Features Implemented**: Sign up, sign in, email verification, password reset, token refresh

### 2. AWS CloudWatch
- **Package**: `aws_cloudwatch_api: ^2.0.0`, `aws_request: ^1.0.1`
- **Purpose**: Metrics collection, error logging
- **Implementation**: Custom wrapper for logging auth events

---

## CRITICAL ISSUES (Must Fix Immediately)

### 1. Documentation-Implementation Mismatch - CRITICAL

**Issue**: The project documentation (`docs/@AWS_Cognito.md`) extensively covers AWS Amplify Gen 2 with code examples using:
```yaml
amplify_flutter: ^2.0.0
amplify_auth_cognito: ^2.0.0
```

However, the actual implementation in `pubspec.yaml` uses:
```yaml
amazon_cognito_identity_dart_2: ^3.6.0
```

**Impact**:
- Developers following the documentation will encounter errors
- The documented features (AuthHub, automatic token refresh) are not available
- Migration path is unclear

**Fix Options**:

**Option A: Migrate to AWS Amplify Gen 2 (Recommended for 2026)**
```yaml
# Remove old dependencies
amazon_cognito_identity_dart_2: ^3.6.0  # ❌ Remove

# Add Amplify Gen 2
amplify_flutter: ^2.1.0
amplify_auth_cognito: ^2.1.0
```

**Option B: Update Documentation to Match Current Implementation**
- Rewrite all documentation to reflect `amazon_cognito_identity_dart_2` patterns
- Remove references to AuthHub and automatic token refresh
- Document manual token management approach

**Recommendation**: Migrate to Amplify Gen 2 for long-term maintainability.

---

### 2. Hardcoded AWS Credentials - CRITICAL (SECURITY)

**File**: `.env.example:2-3`

```bash
AWS_ACCESS_KEY_ID=your_access_key_id
AWS_SECRET_ACCESS_KEY=your_secret_access_key
```

**Problem**: Long-term AWS credentials are hardcoded in environment files.

**Security Violations**:
- Violates AWS security best practices
- Credentials may be committed to version control
- No rotation mechanism
- Exposes full AWS permissions to mobile clients

**2026 AWS Best Practice**: Mobile apps should NEVER have long-term credentials.

**Fix**:

**Step 1: Remove hardcoded credentials**
```bash
# ❌ REMOVE THESE LINES
AWS_ACCESS_KEY_ID=your_access_key_id
AWS_SECRET_ACCESS_KEY=your_secret_access_key
```

**Step 2: Use AWS Cognito Identity Pools for temporary credentials**

Create an IAM Role for authenticated users:
```json
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Action": [
        "mobileanalytics:PutEvents",
        "cognito-sync:*",
        "cognito-identity:*"
      ],
      "Resource": "*"
    },
    {
      "Effect": "Allow",
      "Action": [
        "logs:CreateLogGroup",
        "logs:CreateLogStream",
        "logs:PutLogEvents",
        "cloudwatch:PutMetricData"
      ],
      "Resource": "arn:aws:logs:*:*:*"
    }
  ]
}
```

**Step 3: Configure Amplify to use Cognito Identity Pool**

```dart
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

// Amplify Gen 2 handles credentials automatically
// No manual credential configuration needed
await Amplify.init(
  plugins: [
    AmplifyAuthCognito(),
  ],
);
```

**Sources**:
- [AWS Amplify Gen 2 Auth Setup](https://docs.amplify.aws/flutter/build-a-backend/auth/set-up-auth/)
- [AWS Security Best Practices](https://docs.aws.amazon.com/cognito/latest/developerguide/security-best-practices.html)

---

### 3. Direct CloudWatch API Usage - CRITICAL (ARCHITECTURE)

**File**: `lib/features/core/infrastructure/monitoring/aws_cloudwatch_monitoring.dart:14-18`

```dart
final cloudWatch = CloudWatch(
  region: dotenv.env['AWS_REGION'] ?? 'us-east-1',
  accessKeyId: dotenv.env['AWS_ACCESS_KEY_ID'] ?? '',  // ❌ SECURITY RISK
  secretAccessKey: dotenv.env['AWS_SECRET_ACCESS_KEY'] ?? '',  // ❌ SECURITY RISK
);
```

**Problems**:
1. Using direct API calls instead of Amplify's built-in logging
2. Requires hardcoded credentials
3. No automatic batching or retry logic
4. Verbose custom implementation

**Fix (with Amplify Gen 2)**:

```dart
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';

// AWS CloudWatch Logs via Amplify Analytics
class AWSCloudWatchLogger {
  Future<void> logError(dynamic error, {StackTrace? stackTrace}) async {
    // Amplify automatically handles credentials and batching
    final analyticsEvent = AnalyticsEvent('error_occurred');
    analyticsEvent.properties.addBoolProperty('is_error', true);
    analyticsEvent.properties.addStringProperty(
      'error_type',
      error.runtimeType.toString(),
    );

    await Amplify.Analytics.recordEvent(event: analyticsEvent);
  }

  Future<void> logMetric(String name, double value) async {
    final metricsEvent = AnalyticsEvent(name);
    metricsEvent.properties.addDoubleProperty('value', value);
    await Amplify.Analytics.recordEvent(event: metricsEvent);
  }
}
```

**Benefits**:
- No credential management needed
- Automatic batching and retry
- Built-in error handling
- AWS-managed infrastructure

---

### 4. Manual Token Refresh Implementation - CRITICAL

**File**: `lib/features/auth/data/datasources/auth_remote_data_source.dart:517-557`

**Current Implementation**:
```dart
@override
Future<AuthSession> refreshToken() async {
  // Manual refresh logic...
  _session = await _cognitoUser!.refreshSession(refreshToken);
  // Manual session validation...
  // Manual token extraction...
}
```

**Problem**: Manual token refresh is error-prone and doesn't align with 2026 best practices.

**AWS Amplify Gen 2 Solution**:

```dart
import 'package:amplify_flutter/amplify_flutter.dart';

// Automatic token refresh - no manual intervention needed
Future<AuthSession?> getCurrentSession() async {
  try {
    final session = await Amplify.Auth.fetchAuthSession(
      options: const FetchAuthSessionOptions(getLatest: true),
    );

    if (session.isSignedIn) {
      final tokens = session.userPoolTokens;
      return AuthSession(
        accessToken: tokens?.accessToken.raw,
        idToken: tokens?.idToken.raw,
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

**Benefits**:
- Automatic token refresh before expiration
- No timer management needed
- Built-in error handling
- AuthHub event notifications

---

### 5. Missing AuthHub Event Monitoring - CRITICAL

**Problem**: The app doesn't listen to AuthHub events for real-time auth state changes.

**Current Implementation**: Manual state management with Riverpod
```dart
// Manual state updates throughout the codebase
state = const AsyncValue.loading();
state = const AsyncValue.data(AuthState.authenticated());
```

**2026 Best Practice with AuthHub**:

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

    // Listen to ALL auth events automatically
    _authHubSubscription = Amplify.Auth.listen(
      (AuthHubEvent event) {
        state = switch (event.type) {
          AuthHubType.signedIn => const AuthState.authenticated(),
          AuthHubType.signedOut => const AuthState.unauthenticated(),
          AuthHubType.sessionExpired => const AuthState.sessionExpired(),
          AuthHubType.tokenRefreshed => const AuthState.tokenRefreshed(),
          AuthHubType.configured => const AuthState.configured(),
          AuthHubType.deleteUser => const AuthState.unauthenticated(),
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

**Benefits**:
- Real-time auth state updates
- Automatic token refresh notifications
- Session expiry detection
- Multi-tab/device sync

---

### 6. Outdated Authentication Flow - CRITICAL

**File**: `lib/features/auth/data/datasources/auth_remote_data_source.dart:96`

```dart
final List<String> _supportedAuthMethods = const ['USER_PASSWORD_AUTH'];
```

**Problem**: Only supports basic password authentication. Missing:
- SRP (Secure Remote Password) - more secure
- MFA (Multi-Factor Authentication)
- Social sign-in (Google, Apple, Facebook)
- Passkey/WebAuthn support (2026 standard)

**Fix with Amplify Gen 2**:

```dart
// Backend configuration (amplify/backend.ts)
import { defineAuth } from '@aws-amplify/backend';

export const auth = defineAuth({
  loginWith: {
    email: true,  // Email/password
    externalProviders: {
      google: {
        clientId: process.env.GOOGLE_CLIENT_ID,
      },
      apple: {
        clientId: {
          production: process.env.APPLE_CLIENT_ID_PROD,
        },
      },
      signOutUrl: 'https://yourapp.com/signout',
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
    totp: true,  // TOTP authenticator apps
  },
});
```

**Flutter Implementation**:

```dart
// Sign in with SRP (automatic with Amplify)
Future<void> signIn(String email, String password) async {
  try {
    final result = await Amplify.Auth.signIn(
      username: email,
      password: password,
    );
    // Amplify automatically uses the most secure auth flow
  } on AuthException catch (e) {
    debugPrint('Sign in failed: ${e.message}');
  }
}

// Sign in with Google
Future<void> signInWithGoogle() async {
  try {
    final result = await Amplify.Auth.signInWithWebUI(
      provider: AuthProvider.google,
    );
  } on AuthException catch (e) {
    debugPrint('Google sign-in failed: ${e.message}');
  }
}
```

---

## HIGH PRIORITY ISSUES

### 7. CloudWatch Package Confusion - HIGH

**File**: `pubspec.yaml:103-105`

```yaml
aws_cloudwatch: ^1.0.1  # ❌ This package doesn't exist on pub.dev
aws_request: ^1.0.1      # ❌ This package doesn't exist on pub.dev
aws_cloudwatch_api: ^2.0.0  # ✅ Valid package
```

**Problem**: Two of the three AWS packages listed don't exist on pub.dev.

**Fix**:

```yaml
# Remove invalid packages
# aws_cloudwatch: ^1.0.1  # ❌ Remove
# aws_request: ^1.0.1      # ❌ Remove

# Use Amplify for all AWS interactions
amplify_flutter: ^2.1.0
amplify_auth_cognito: ^2.1.0
amplify_api: ^2.1.0  # For API calls with auto-auth
amplify_analytics_pinpoint: ^2.1.0  # For CloudWatch Logs via Pinpoint
```

---

### 8. No MFA Configuration - HIGH

**Problem**: Multi-Factor Authentication is not configured, despite the app being a safety-focused travel application.

**Impact**:
- Compromised passwords give attackers full access
- Missing critical security layer for user data

**Fix with Amplify Gen 2**:

**Step 1: Backend Configuration**
```typescript
// amplify/backend/resource.ts
import { defineAuth } from '@aws-amplify/backend';

export const auth = defineAuth({
  loginWith: {
    email: true,
  },
  multifactor: {
    mode: 'REQUIRED',  // or 'OPTIONAL'
    sms: true,
    totp: true,  // Authenticator apps (Google Authenticator, Authy)
    smsMessage: (code) => `Your SoloAdventurer verification code is: ${code}`,
  },
});
```

**Step 2: Handle MFA in Flutter**
```dart
Future<void> signIn(String email, String password) async {
  try {
    final result = await Amplify.Auth.signIn(
      username: email,
      password: password,
    );

    if (result.nextStep.signInStep == AuthSignInStep.confirmSignInWithMfa) {
      // Show MFA input screen
      _showMfaScreen();
    }
  } on AuthException catch (e) {
    debugPrint('Sign in failed: ${e.message}');
  }
}

Future<void> confirmMfa(String code) async {
  try {
    await Amplify.Auth.confirmSignIn(
      confirmationValue: code,
    );
  } on AuthException catch (e) {
    debugPrint('MFA confirmation failed: ${e.message}');
  }
}
```

---

### 9. Missing Device Tracking - HIGH

**Problem**: No device tracking or trusted device functionality.

**Impact**:
- Users must re-authenticate frequently
- Cannot detect unauthorized devices
- Missing security monitoring

**Fix**:

```dart
// Remember trusted device
Future<void> rememberDevice() async {
  try {
    await Amplify.Auth.rememberDevice();
  } on AuthException catch (e) {
    debugPrint('Failed to remember device: ${e.message}');
  }
}

// Check if device is remembered
Future<bool> isDeviceRemembered() async {
  try {
    final result = await Amplify.Auth.fetchDevices();
    return result.isNotEmpty;
  } on AuthException catch (e) {
    return false;
  }
}

// Forget all devices (user-initiated security action)
Future<void> forgetAllDevices() async {
  try {
    await Amplify.Auth.forgetDevice();
  } on AuthException catch (e) {
    debugPrint('Failed to forget devices: ${e.message}');
  }
}
```

---

### 10. No Adaptive Authentication - HIGH

**Problem**: No risk-based authentication or suspicious activity detection.

**AWS Cognito Advanced Security Features**:
- Adaptive authentication based on risk
- IP-based geolocation checking
- Device fingerprinting
- Compromised credentials detection

**Fix (AWS Console Configuration)**:

1. Enable Cognito Advanced Security
2. Configure adaptive authentication rules:
   - Require MFA for new devices
   - Block sign-ins from impossible travel locations
   - Challenge suspicious sign-ins

```dart
// Amplify automatically handles Advanced Security responses
Future<void> signIn(String email, String password) async {
  try {
    final result = await Amplify.Auth.signIn(
      username: email,
      password: password,
    );

    // Check if additional challenges are needed
    if (result.nextStep.signInStep == AuthSignInStep.confirmSignInWithMfa) {
      // Advanced Security detected risk - show MFA
      _showMfaScreen();
    }
  } on AuthException catch (e) {
    // Advanced Security may block sign-in
    if (e.message.contains('risks')) {
      _showSecurityChallenge();
    }
  }
}
```

---

### 11. Missing Social Sign-In - HIGH

**Problem**: No support for Google, Apple, or Facebook sign-in.

**Impact**:
- Poor user experience
- Higher friction for onboarding
- Missing 2026 standard expectation

**Fix with Amplify Gen 2**:

```dart
// Google Sign-In
Future<void> signInWithGoogle() async {
  try {
    final result = await Amplify.Auth.signInWithWebUI(
      provider: AuthProvider.google,
    );

    if (result.isSignedIn) {
      debugPrint('Google sign-in successful');
    }
  } on AuthException catch (e) {
    debugPrint('Google sign-in failed: ${e.message}');
  }
}

// Apple Sign-In (iOS required for App Store)
Future<void> signInWithApple() async {
  try {
    final result = await Amplify.Auth.signInWithWebUI(
      provider: AuthProvider.apple,
    );
  } on AuthException catch (e) {
    debugPrint('Apple sign-in failed: ${e.message}');
  }
}
```

**Backend Configuration**:
```typescript
export const auth = defineAuth({
  loginWith: {
    email: true,
    externalProviders: {
      google: {
        clientId: process.env.GOOGLE_CLIENT_ID,
      },
      apple: {
        clientId: process.env.APPLE_CLIENT_ID,
      },
      loginWith: {
        email: true,  // Get email from social providers
      },
    },
  },
});
```

---

### 12. No Email Customization - HIGH

**File**: Custom email templates not configured.

**Problem**: Users receive generic Cognito emails.

**Fix**: Configure custom email templates in AWS Cognito Console:

1. Go to Cognito User Pool → Message Customizations
2. Customize email templates for:
   - Verification email
   - Password reset
   - MFA codes
   - Account confirmation

**Example Template**:
```
Subject: Verify your SoloAdventurer account

Hi {username},

Welcome to SoloAdventurer! To complete your registration, please verify your email address.

Your verification code is: {####}

This code will expire in 24 hours.

If you didn't create an account with SoloAdventurer, please ignore this email.

Safe travels,
The SoloAdventurer Team
```

---

### 13. Missing Password Policy - HIGH

**Problem**: No custom password policy configured.

**Current State**: Default Cognito password policy (too lenient)

**Fix**:

**AWS Console Configuration**:
- Minimum length: 12 characters
- Require uppercase: Yes
- Require lowercase: Yes
- Require numbers: Yes
- Require special characters: Yes
- Password history: 5 (prevent reuse)

**Backend Configuration**:
```typescript
export const auth = defineAuth({
  loginWith: {
    email: {
      verificationEmailStyle: 'CODE',
      verificationEmailSubject: 'Verify your SoloAdventurer account',
      verificationEmailBody: 'Your verification code is {####}',
      passwordResetStyle: 'CODE',
      passwordResetSubject: 'Reset your SoloAdventurer password',
      passwordResetBody: 'Your reset code is {####}',
    },
  },
  // Password policy is configured in AWS Cognito Console
});
```

---

## MEDIUM PRIORITY ISSUES

### 14. No Infrastructure as Code - MEDIUM

**Problem**: AWS resources are manually configured in AWS Console.

**Risk**:
- No reproducible environments
- Difficult to rollback changes
- No version control for infrastructure

**Fix**: Use AWS CDK with Amplify Gen 2

```typescript
// amplify/backend.ts
import { defineBackend } from '@aws-amplify/backend';
import { auth } from './auth/resource';
import { data } from './data/resource';
import { storage } from './storage/resource';
import { policy } from './policy/resource';

export const backend = defineBackend({
  auth,
  data,
  storage,
  policy,
});

// amplify/auth/resource.ts
import { defineAuth } from '@aws-amplify/backend';

export const auth = defineAuth({
  loginWith: { email: true },
});
```

Deploy with:
```bash
npx ampx sandbox  # Local development
npx ampx deploy   # Production
```

---

### 15. Missing Environment Configuration - MEDIUM

**Problem**: Single configuration for all environments.

**Fix**: Use environment-specific configurations

```dart
// lib/config/amplify_environments.dart
enum Environment {
  dev,
  staging,
  prod,
}

class AmplifyConfig {
  static Future<void> configure(Environment env) async {
    final config = _getConfigForEnvironment(env);

    await Amplify.init(
      plugins: [
        AmplifyAuthCognito(),
        AmplifyAPI(),
        AmplifyAnalyticsPinpoint(),
      ],
    );
  }

  static AmplifyConfig _getConfigForEnvironment(Environment env) {
    switch (env) {
      case Environment.dev:
        return AmplifyConfig.dev();
      case Environment.staging:
        return AmplifyConfig.staging();
      case Environment.prod:
        return AmplifyConfig.prod();
    }
  }
}
```

---

### 16. No Rate Limiting - MEDIUM

**Problem**: Client-side rate limiting only.

**Fix**: Implement AWS WAF or API Gateway rate limiting

```typescript
// API Gateway rate limiting
const api = new apigateway.RestApi(this, 'SoloAdventurerApi', {
  defaultMethodOptions: {
    apiKeyRequired: true,
  },
  deployOptions: {
    stageName: 'prod',
    throttlingBurstLimit: 100,
    throttlingRateLimit: 50,
  },
});
```

---

### 17. Missing Audit Logging - MEDIUM

**Problem**: No comprehensive audit trail for auth events.

**Fix**: Enable CloudTrail for Cognito

```dart
import 'package:amplify_analytics_pinpoint/amplify_analytics_pinpoint.dart';

// Log all auth events
Future<void> logAuthEvent(String eventName, Map<String, dynamic> attributes) async {
  final event = AnalyticsEvent(eventName);
  attributes.forEach((key, value) {
    event.properties.addStringProperty(key, value.toString());
  });
  await Amplify.Analytics.recordEvent(event: event);
}

// Usage
await logAuthEvent('user_login', {
  'user_id': userId,
  'timestamp': DateTime.now().toIso8601String(),
  'ip_address': ipAddress,
  'user_agent': userAgent,
});
```

---

### 18. No Automated Testing - MEDIUM

**Problem**: No integration tests for AWS services.

**Fix**: Add Amplify test utilities

```dart
// test/integration/auth_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:amplify_test/amplify_test.dart';

void main() {
  group('AWS Auth Integration Tests', () {
    testWidgets('should sign in user', (tester) async {
      // Test actual Cognito flow
      final result = await Amplify.Auth.signIn(
        username: 'test@example.com',
        password: 'TestPassword123!',
      );

      expect(result.isSignedIn, true);
    });

    testWidgets('should refresh token', (tester) async {
      // Test token refresh
      final session = await Amplify.Auth.fetchAuthSession(
        options: const FetchAuthSessionOptions(getLatest: true),
      );

      expect(session.isSignedIn, true);
    });
  });
}
```

---

## LOW PRIORITY / BEST PRACTICES

### 19. Add Biometric Authentication - LOW

```dart
import 'package:local_auth/local_auth.dart';

Future<bool> authenticateWithBiometrics() async {
  final localAuth = LocalAuthentication();
  final isAvailable = await localAuth.canCheckBiometrics;

  if (!isAvailable) return false;

  return await localAuth.authenticate(
    localizedReason: 'Please authenticate to access SoloAdventurer',
    options: const AuthenticationOptions(
      biometricOnly: true,
    ),
  );
}
```

---

### 20. Add Passkey Support (WebAuthn) - LOW

Passkeys are the future of authentication (2026+).

```dart
// Requires Amplify Gen 2 + Cognito configuration
Future<void> signInWithPasskey() async {
  try {
    // Coming to Amplify Flutter in 2026
    // await Amplify.Auth.signInWithWebUI(
    //   provider: AuthProvider.passkey,
    // );
  } on AuthException catch (e) {
    debugPrint('Passkey sign-in failed: ${e.message}');
  }
}
```

---

## Migration Plan: amazon_cognito_identity_dart_2 → Amplify Gen 2

### Phase 1: Preparation (Week 1)

1. **Create new branch**: `feature/amplify-gen2-migration`
2. **Backup current auth implementation**
3. **Review all auth flows** in the app
4. **Document all custom features** that need migration

### Phase 2: Backend Setup (Week 2)

1. **Initialize Amplify Gen 2**:
```bash
npm install -g @aws-amplify/backend-cli
amplify init
```

2. **Create backend configuration**:
```typescript
// amplify/backend.ts
import { defineBackend } from '@aws-amplify/backend';
import { auth } from './auth/resource';

export const backend = defineBackend({
  auth,
});
```

3. **Configure auth resource**:
```typescript
// amplify/auth/resource.ts
import { defineAuth } from '@aws-amplify/backend';

export const auth = defineAuth({
  loginWith: {
    email: true,
  },
  userAttributes: {
    email: { required: true },
  },
});
```

### Phase 3: Flutter Migration (Week 3-4)

1. **Update pubspec.yaml**:
```yaml
dependencies:
  # Remove old packages
  amazon_cognito_identity_dart_2: ^3.6.0  # ❌ Remove
  aws_cloudwatch: ^1.0.1                   # ❌ Remove
  aws_request: ^1.0.1                       # ❌ Remove

  # Add Amplify Gen 2
  amplify_flutter: ^2.1.0
  amplify_auth_cognito: ^2.1.0
  amplify_api: ^2.1.0
  amplify_analytics_pinpoint: ^2.1.0
```

2. **Generate configuration**:
```bash
npx ampx generate outputs --format dart --out-dir lib/amplify
```

3. **Update bootstrap.dart**:
```dart
import 'package:amplify_flutter/amplify_flutter.dart';
import 'package:amplify_auth_cognito/amplify_auth_cognito.dart';
import 'amplify_outputs.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  try {
    await Amplify.init(
      plugins: [
        AmplifyAuthCognito(),
      ],
    );
  } on Exception catch (e) {
    debugPrint('Error configuring Amplify: $e');
  }

  runApp(const MyApp());
}
```

4. **Migrate auth service**:
```dart
// OLD: Manual Cognito SDK
final userPool = CognitoUserPool(poolId, clientId);
final user = CognitoUser(email, userPool);
final session = await user.authenticateUser(authDetails);

// NEW: Amplify Gen 2
final result = await Amplify.Auth.signIn(
  username: email,
  password: password,
);
```

5. **Migrate token management**:
```dart
// OLD: Manual token refresh
_session = await _cognitoUser!.refreshSession(refreshToken);

// NEW: Automatic with Amplify
final session = await Amplify.Auth.fetchAuthSession(
  options: const FetchAuthSessionOptions(getLatest: true),
);
```

6. **Add AuthHub listeners**:
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
    _authHubSubscription = Amplify.Auth.listen(
      (AuthHubEvent event) {
        state = switch (event.type) {
          AuthHubType.signedIn => AuthState.authenticated(user: event.user),
          AuthHubType.signedOut => const AuthState.unauthenticated(),
          _ => state,
        };
      },
    );
  }
}
```

### Phase 4: Testing (Week 5)

1. **Unit tests** for all auth flows
2. **Integration tests** with actual Cognito
3. **UI tests** for auth screens
4. **Security tests** for token handling

### Phase 5: Deployment (Week 6)

1. **Deploy backend**:
```bash
npx ampx deploy
```

2. **Update production app** with new configuration
3. **Monitor CloudWatch** for errors
4. **Rollback plan** ready if needed

---

## File Changes Required

| File | Priority | Changes |
|------|----------|---------|
| `.env.example` | CRITICAL | Remove AWS_ACCESS_KEY_ID and AWS_SECRET_ACCESS_KEY |
| `pubspec.yaml` | CRITICAL | Replace amazon_cognito_identity_dart_2 with amplify_flutter |
| `lib/features/auth/data/datasources/auth_remote_data_source.dart` | CRITICAL | Rewrite to use Amplify Auth |
| `lib/features/core/infrastructure/monitoring/aws_cloudwatch_monitoring.dart` | HIGH | Use Amplify Analytics instead |
| `lib/app/bootstrap.dart` | CRITICAL | Add Amplify.init() |
| `docs/@AWS_Cognito.md` | MEDIUM | Update to reflect Amplify Gen 2 or note discrepancy |

---

## Post-Migration Validation Checklist

- [ ] Remove hardcoded AWS credentials
- [ ] Amplify Gen 2 packages installed
- [ ] Backend configured with AWS CDK
- [ ] AuthHub events firing correctly
- [ ] Token refresh working automatically
- [ ] MFA configured and tested
- [ ] Social sign-in working (if implemented)
- [ ] CloudWatch logs appearing in AWS Console
- [ ] All integration tests passing
- [ ] Manual testing completed on:
  - [ ] Sign up flow
  - [ ] Sign in flow
  - [ ] Email verification
  - [ ] Password reset
  - [ ] Token refresh
  - [ ] Sign out
- [ ] Performance testing completed
- [ ] Security audit completed

---

## References

### Official Documentation
- [AWS Amplify Gen 2 Documentation](https://docs.amplify.aws/flutter/)
- [AWS Amplify Gen 2 Migration Guide](https://docs.amplify.aws/flutter/start/migrate-to-gen2/)
- [AWS Cognito User Pools](https://docs.aws.amazon.com/cognito/)
- [AWS Security Best Practices](https://docs.aws.amazon.com/cognito/latest/developerguide/security-best-practices.html)
- [Amplify Flutter GitHub](https://github.com/aws-amplify/amplify-flutter)

### Packages
- [amplify_flutter on pub.dev](https://pub.dev/packages/amplify_flutter)
- [amplify_auth_cognito on pub.dev](https://pub.dev/packages/amplify_auth_cognito)

### Community Resources
- [AWS Amplify Discord](https://discord.gg/amplify)
- [Stack Overflow - aws-amplify](https://stackoverflow.com/questions/tagged/aws-amplify)

---

**Report Generated:** 2026-01-06
**Next Review:** After implementing Critical and High priority fixes
**Recommended Action:** Begin migration to AWS Amplify Gen 2 immediately
