# Authentication System Troubleshooting Guide

## Overview

This guide helps developers diagnose and fix common issues with the authentication system in the SoloAdventurer app. It includes symptoms, causes, diagnostic steps, and solutions for each issue.

## Table of Contents

- [Quick Diagnostics](#quick-diagnostics)
- [Common Issues](#common-issues)
- [Debugging Tools](#debugging-tools)
- [Performance Issues](#performance-issues)
- [Testing Issues](#testing-issues)
- [Getting Help](#getting-help)

## Quick Diagnostics

### Health Check Script

Run this diagnostic script to check the overall health of the authentication system:

```dart
Future<void> runAuthHealthCheck(WidgetRef ref) async {
  print('=== Authentication Health Check ===\n');

  // 1. Check Auth Provider
  final authState = ref.read(authProvider);
  print('✓ Auth Provider: ${authState.isAuthenticated ? "Authenticated" : "Not authenticated"}');

  // 2. Check Session Storage
  final sessionManager = ref.read(persistentSessionManagerProvider);
  final hasSession = await sessionManager.hasValidSession();
  print('✓ Session Storage: ${hasSession ? "Has valid session" : "No valid session"}');

  if (hasSession) {
    final session = await sessionManager.loadSession();
    if (session != null) {
      print('  - Token expires in: ${session.timeUntilExpiration.inMinutes} minutes');
      print('  - Is expired: ${session.isExpired}');
    }
  }

  // 3. Check Token Refresh Service
  final refreshService = ref.read(tokenRefreshServiceProvider);
  print('✓ Token Refresh Service: ${refreshService.isRefreshing ? "Refreshing" : "Idle"}');

  // 4. Check Offline State
  final offlineManager = ref.read(offlineAuthManagerProvider);
  print('✓ Offline State: ${offlineManager.currentState}');
  print('  - Is offline: ${offlineManager.isOffline}');
  print('  - Has cached data: ${offlineManager.hasCachedData}');

  // 5. Check Network Connectivity
  final connectivityService = ref.read(connectivityServiceProvider);
  final networkStatus = await connectivityService.checkConnectivity();
  print('✓ Network Status: ${networkStatus}');

  print('\n=== Health Check Complete ===');
}
```

### Common Symptoms and Quick Fixes

| Symptom | Quick Fix |
|---------|-----------|
| User logged out unexpectedly | Check token expiration, verify refresh logic |
| API calls return 401 | Check AuthInterceptor, verify token storage |
| App crashes on login | Check AWS Cognito configuration |
| Can't stay logged in | Check PersistentSessionManager |
| Slow login performance | Check network, verify API response time |
| Offline mode not working | Check ConnectivityService, verify offline state |

## Common Issues

### Issue 1: User Logged Out Unexpectedly

**Symptoms**:
- User is logged out without clicking logout
- Happens after app backgrounding/foregrounding
- Happens after device reboot

**Possible Causes**:
1. Token expired and refresh failed
2. Session corrupted in storage
3. App lifecycle issue with refresh scheduler
4. Refresh token expired

**Diagnosis**:

```dart
// Check session storage
final sessionManager = ref.read(persistentSessionManagerProvider);
final session = await sessionManager.loadSession();

if (session == null) {
  print('No session found in storage');
  // Check if it was cleared or never saved
} else if (session.isExpired) {
  print('Session expired at: ${session.expiresAt}');
  print('Time since expiration: ${DateTime.now().difference(session.expiresAt)}');

  // Check if refresh token is still valid
  final validationResult = await sessionManager.validateSessionForRestoration();
  print('Validation action: ${validationResult.action}');
}
```

**Solutions**:

1. **Check refresh token validity**:
   ```dart
   // Refresh tokens are valid for 30 days
   // If expired, user must re-authenticate
   final validationResult = await sessionManager.validateSessionForRestoration();
   if (validationResult.action == SessionValidationAction.reauthenticate) {
     // Navigate to login
   }
   ```

2. **Verify refresh scheduler is running**:
   ```dart
   final scheduler = ref.read(backgroundRefreshSchedulerProvider);
   // Should be started after login
   await scheduler.start(session);
   ```

3. **Check for storage corruption**:
   ```dart
   try {
     final session = await sessionManager.loadSession();
   } catch (e) {
     print('Storage corrupted: $e');
     await sessionManager.clearSession();
     // Navigate to login
   }
   ```

### Issue 2: API Calls Return 401 Errors

**Symptoms**:
- All API calls return 401 Unauthorized
- User appears logged in but API fails
- Happens after token expires

**Possible Causes**:
1. AuthInterceptor not adding token
2. Token expired and not refreshing
3. Token storage issue
4. Token format invalid

**Diagnosis**:

```dart
// Check if token exists
final sessionManager = ref.read(persistentSessionManagerProvider);
final token = await sessionManager.getAccessToken();

print('Access token: ${token != null ? "Present" : "Missing"}');
if (token != null) {
  print('Token length: ${token.length}');
  print('Token format: ${token.startsWith('eyJ') ? "JWT" : "Unknown"}');
}

// Check token expiration
final session = await sessionManager.loadSession();
if (session != null) {
  print('Token expired: ${session.isExpired}');
  print('Expires in: ${session.timeUntilExpiration.inMinutes} minutes');
}
```

**Solutions**:

1. **Verify AuthInterceptor is registered**:
   ```dart
   // In dio initialization
   final dio = Dio();
   dio.interceptors.add(AuthInterceptor(
     authRepository: authRepository,
   ));
   ```

2. **Trigger manual refresh**:
   ```dart
   try {
     final newSession = await ref.read(authProvider.notifier).refreshToken();
     print('Token refreshed successfully');
   } catch (e) {
     print('Refresh failed: $e');
   }
   ```

3. **Check TokenRefreshService logs**:
   ```dart
   // Check if refresh is being attempted
   final refreshService = ref.read(tokenRefreshServiceProvider);
   print('Is refreshing: ${refreshService.isRefreshing}');
   ```

### Issue 3: Login Fails with Network Error

**Symptoms**:
- Login fails with "No internet connection"
- Other apps work fine
- Happens consistently

**Possible Causes**:
1. ConnectivityService not detecting network
2. AWS Cognito endpoint unreachable
3. DNS resolution issue
4. Firewall blocking requests

**Diagnosis**:

```dart
// Check network status
final connectivityService = ref.read(connectivityServiceProvider);
final status = await connectivityService.checkConnectivity();
print('Network status: $status');

// Test connectivity
try {
  final response = await dio.get('https://www.google.com');
  print('Internet connectivity: OK');
} catch (e) {
  print('Internet connectivity: FAILED - $e');
}

// Test Cognito endpoint
try {
  final response = await dio.get('https://cognito-idp.{region}.amazonaws.com');
  print('Cognito endpoint: REACHABLE');
} catch (e) {
  print('Cognito endpoint: UNREACHABLE - $e');
}
```

**Solutions**:

1. **Check device network settings**:
   - Ensure WiFi/Mobile data is enabled
   - Try switching between WiFi and Mobile data
   - Check if other apps can access internet

2. **Verify AWS Cognito configuration**:
   ```dart
   // Check region and user pool ID
   final userPoolId = 'us-east-1_ABC123';
   final region = 'us-east-1';
   // Ensure these match your AWS Cognito setup
   ```

3. **Test with different network**:
   - Try different WiFi network
   - Try mobile hotspot
   - Disable VPN if enabled

### Issue 4: Can't Stay Logged In After App Restart

**Symptoms**:
- User must log in every time app starts
- Session not persisting across app restarts
- Session lost on app backgrounding

**Possible Causes**:
1. PersistentSessionManager not saving session
2. Secure storage not persisting data
3. Session cleared on app background
4. AuthProvider not restoring session

**Diagnosis**:

```dart
// After login, check if session is saved
await authRepository.signIn(email, password);

final sessionManager = ref.read(persistentSessionManagerProvider);
final hasSession = await sessionManager.hasValidSession();
print('Session saved: $hasSession');

// Try loading session
final session = await sessionManager.loadSession();
print('Session loaded: ${session != null}');
if (session != null) {
  print('Session valid: ${!session.isExpired}');
}

// Check AuthProvider initialization
await ref.read(authProvider.notifier).initialize();
final authState = ref.read(authProvider);
print('Authenticated after init: ${authState.isAuthenticated}');
```

**Solutions**:

1. **Verify session is saved after login**:
   ```dart
   Future<User> signInWithEmailAndPassword(String email, String password) async {
     final user = await _cognitoUser.signIn(email, password);

     // Save session!
     final session = AuthSession(...);
     await _persistentSessionManager.saveSession(session);

     return user;
   }
   ```

2. **Verify AuthProvider restores session**:
   ```dart
   @override
   Future<void> initialize() async {
     final validationResult = await _persistentSessionManager.validateSessionForRestoration();

     switch (validationResult.action) {
       case SessionValidationAction.valid:
         state = state.copyWith(
           isAuthenticated: true,
           session: validationResult.session,
         );
         break;
       // ... handle other cases
     }
   }
   ```

3. **Check secure storage permissions**:
   - iOS: Check Keychain entitlements
   - Android: Check Keyystore permissions

### Issue 5: Slow Login Performance

**Symptoms**:
- Login takes > 3 seconds
- App freezes during login
- UI blocks on authentication

**Possible Causes**:
1. Slow network connection
2. AWS Cognito response slow
3. Too many operations on main thread
4. Not using async/await properly

**Diagnosis**:

```dart
final stopwatch = Stopwatch()..start();

try {
  // Time login operation
  final user = await authRepository.signIn(email, password);
  stopwatch.stop();
  print('Login duration: ${stopwatch.elapsedMilliseconds}ms');

  if (stopwatch.elapsedMilliseconds > 3000) {
    print('WARNING: Login is slow!');
  }
} catch (e) {
  stopwatch.stop();
  print('Login failed after ${stopwatch.elapsedMilliseconds}ms');
}
```

**Solutions**:

1. **Profile network requests**:
   ```dart
   (dio.httpClientAdapter as DefaultHttpClientAdapter).onHttpClientCreate = (client) {
     client.badCertificateCallback = (cert, host, port) => false;
     return client;
   };
   ```

2. **Use loading indicators**:
   ```dart
   setState(() => _isLoading = true);
   try {
     await authRepository.signIn(email, password);
   } finally {
     setState(() => _isLoading = false);
   }
   ```

3. **Optimize session storage**:
   ```dart
   // PersistentSessionManager has caching built-in
   // First load: from storage (~500ms)
   // Subsequent loads: from cache (~1ms)
   ```

### Issue 6: Offline Mode Not Working

**Symptoms**:
- Offline indicator not showing
- Can't access cached data when offline
- App crashes when offline

**Possible Causes**:
1. OfflineAuthManager not initialized
2. ConnectivityService not detecting offline state
3. Cached data not available
4. Offline mode not enabled

**Diagnosis**:

```dart
// Check OfflineAuthManager initialization
final offlineManager = ref.read(offlineAuthManagerProvider);
await offlineManager.initialize();

print('Offline state: ${offlineManager.currentState}');
print('Is offline: ${offlineManager.isOffline}');
print('Has cached data: ${offlineManager.hasCachedData}');

// Check cached data info
final cachedDataInfo = await offlineManager.getCachedDataInfo();
print('Cached user profile: ${cachedDataInfo.userProfile != null}');
print('Cache is fresh: ${cachedDataInfo.isFresh}');
print('Last cached: ${cachedDataInfo.lastCachedAt}');
```

**Solutions**:

1. **Initialize OfflineAuthManager on app startup**:
   ```dart
   @override
   void initState() {
     super.initState();
     WidgetsBinding.instance.addPostFrameCallback((_) {
       ref.read(offlineAuthManagerProvider).initialize();
     });
   }
   ```

2. **Cache data when online**:
   ```dart
   // Fetch and cache user data
   final user = await authRepository.getCurrentUser();
   await _localDataSource.cacheUserData({
     'id': user.id,
     'email': user.email,
     'cached_at': DateTime.now().toIso8601String(),
   });
   ```

3. **Show offline indicator**:
   ```dart
   final offlineState = ref.watch(offlineStateProvider);
   return offlineState.when(
     data: (state) {
       if (state != OfflineAuthState.online) {
         return OfflineIndicator(
           isOffline: true,
           child: Content(),
         );
       }
       return Content();
     },
     loading: () => LoadingIndicator(),
     error: (_, __) => ErrorWidget(),
   );
   ```

## Debugging Tools

### Enable Debug Logging

```dart
// In main.dart, enable debug logging
void main() {
  FlutterError.onError = (details) {
    FlutterError.presentError(details);
    debugPrint('Flutter Error: ${details.exception}');
  };

  runApp(MyApp());
}
```

### Monitor Auth Events

```dart
// Listen to auth state changes
ref.listen<AuthState>(authProvider, (previous, next) {
  print('Auth State Changed:');
  print('  Is Authenticated: ${next.isAuthenticated}');
  print('  User: ${next.user?.email}');
  print('  Is Loading: ${next.isLoading}');
  print('  Error: ${next.error?.message}');
});

// Listen to offline state changes
ref.listen<OfflineAuthState?>(offlineStateProvider, (previous, next) {
  print('Offline State Changed: $previous -> $next');
});

// Listen to token refresh events
ref.listen(tokenRefreshServiceProvider, (previous, next) {
  print('Token Refresh Status: $next');
});
```

### Token Inspector

```dart
class TokenInspector {
  static void inspectToken(String token) {
    if (!token.startsWith('eyJ')) {
      print('Not a JWT token');
      return;
    }

    // Decode JWT (without verification for debugging only)
    final parts = token.split('.');
    if (parts.length != 3) {
      print('Invalid JWT format');
      return;
    }

    // Decode payload
    final payload = utf8.decode(base64Url.decode(parts[1]));
    final claims = jsonDecode(payload);

    print('JWT Claims:');
    claims.forEach((key, value) {
      print('  $key: $value');
    });
  }
}

// Usage
final session = await sessionManager.loadSession();
if (session != null) {
  TokenInspector.inspectToken(session.accessToken);
}
```

### Session Logger

```dart
class SessionLogger {
  static Future<void> logSessionState(WidgetRef ref) async {
    print('=== Session State ===');

    // Auth State
    final authState = ref.read(authProvider);
    print('Auth State:');
    print('  Authenticated: ${authState.isAuthenticated}');
    print('  User: ${authState.user?.email}');
    print('  Loading: ${authState.isLoading}');

    // Session Storage
    final sessionManager = ref.read(persistentSessionManagerProvider);
    final session = await sessionManager.loadSession();
    print('\nSession Storage:');
    print('  Has Session: ${session != null}');
    if (session != null) {
      print('  Expires At: ${session.expiresAt}');
      print('  Time Until Expiration: ${session.timeUntilExpiration.inMinutes} min');
      print('  Is Expired: ${session.isExpired}');
      print('  Is Expiring Soon: ${session.isExpiringSoon}');
    }

    // Token Refresh Service
    final refreshService = ref.read(tokenRefreshServiceProvider);
    print('\nToken Refresh Service:');
    print('  Is Refreshing: ${refreshService.isRefreshing}');

    // Offline State
    final offlineManager = ref.read(offlineAuthManagerProvider);
    print('\nOffline State:');
    print('  State: ${offlineManager.currentState}');
    print('  Is Offline: ${offlineManager.isOffline}');
    print('  Has Cached Data: ${offlineManager.hasCachedData}');

    print('==================');
  }
}

// Usage
await SessionLogger.logSessionState(ref);
```

## Performance Issues

### Measuring Auth Performance

```dart
class AuthPerformanceMonitor {
  static Future<void> measureLogin(
    Future<void> Function() loginOperation,
  ) async {
    final timings = <String, int>{};

    final stopwatch = Stopwatch()..start();

    try {
      // Network request
      final networkStart = stopwatch.elapsedMilliseconds;
      await loginOperation();
      timings['network'] = stopwatch.elapsedMilliseconds - networkStart;

      // Session save
      final saveStart = stopwatch.elapsedMilliseconds;
      // Session saving happens inside loginOperation
      timings['sessionSave'] = stopwatch.elapsedMilliseconds - saveStart;

      // State update
      final stateUpdateStart = stopwatch.elapsedMilliseconds;
      // State update happens automatically
      timings['stateUpdate'] = stopwatch.elapsedMilliseconds - stateUpdateStart;
    } catch (e) {
      print('Login failed: $e');
    } finally {
      stopwatch.stop();
      timings['total'] = stopwatch.elapsedMilliseconds;
    }

    print('Login Performance:');
    timings.forEach((operation, duration) {
      print('  $operation: ${duration}ms');
    });

    // Check if performance is acceptable
    if (timings['total']! > 3000) {
      print('WARNING: Login is slow (>3 seconds)');
    }
  }
}

// Usage
await AuthPerformanceMonitor.measureLogin(
  () => authRepository.signIn(email, password),
);
```

### Performance Benchmarks

| Operation | Target | Acceptable | Poor |
|-----------|--------|------------|------|
| Login | < 3s | < 5s | > 5s |
| Token Refresh | < 1s | < 2s | > 2s |
| Session Restoration | < 500ms | < 1s | > 1s |
| Logout | < 500ms | < 1s | > 1s |

## Testing Issues

### Common Test Failures

#### Issue: Mock Provider Not Found

**Error**: `StateError: Provider not found`

**Solution**:
```dart
// Override the provider in tests
await tester.pumpWidget(
  ProviderScope(
    overrides: [
      authProvider.overrideWith((ref) {
        return MockAuthNotifier();
      }),
    ],
    child: MyApp(),
  ),
);
```

#### Issue: Async Operations Not Completing

**Error**: Test timeout or state not updating

**Solution**:
```dart
// Use pumpAndSettle for async operations
await tester.tap(find.byKey(Key('login-button')));
await tester.pumpAndSettle(); // Wait for all async operations

// Verify state
expect(find.byType(HomeScreen), findsOneWidget);
```

#### Issue: Timer/Ticker Issues

**Error**: `Timer or ticker still active after test`

**Solution**:
```dart
tearDown(() {
  // Dispose any active timers
  ref.read(tokenRefreshServiceProvider).dispose();
  ref.read(backgroundRefreshSchedulerProvider).dispose();
});
```

## Getting Help

### Before Asking for Help

1. **Run the health check**:
   ```dart
   await runAuthHealthCheck(ref);
   ```

2. **Collect logs**:
   ```dart
   // Enable debug logging
   // Reproduce the issue
   // Copy all console output
   ```

3. **Gather system info**:
   ```dart
   print('App Version: ${PackageInfo.fromPlatform()}');
   print('OS: ${Platform.operatingSystem} ${Platform.operatingSystemVersion}');
   print('Network Status: ${connectivityService.checkConnectivity()}');
   ```

4. **Check known issues**:
   - Review this troubleshooting guide
   - Check GitHub issues
   - Search existing error messages

### Creating a Bug Report

When creating a bug report, include:

1. **Description**: What happened and what you expected
2. **Steps to reproduce**: Minimal reproduction steps
3. **Logs**: Full console output with debug logging enabled
4. **System info**:
   - App version
   - OS version
   - Device model
5. **Health check output**: Results from `runAuthHealthCheck()`

**Example Bug Report**:

```
**Issue**: User logged out unexpectedly after app backgrounding

**Steps to Reproduce**:
1. Login successfully
2. Background the app (press home button)
3. Wait 5 minutes
4. Return to app
5. User is on login screen

**Expected Behavior**: User should still be logged in

**Actual Behavior**: User is logged out and sees login screen

**Health Check Output**:
=== Authentication Health Check ===
✓ Auth Provider: Not authenticated
✓ Session Storage: Has valid session
  - Token expires in: 45 minutes
  - Is expired: false
✓ Token Refresh Service: Idle
✓ Offline State: online
✓ Network Status: connected
=== Health Check Complete ===

**Logs**:
[Include full console output]

**System Info**:
- App Version: 1.0.0
- OS: iOS 16.0
- Device: iPhone 13 Pro
```

---

**Document Version**: 1.0
**Last Updated**: 2026-01-04
**Maintainer**: SoloAdventurer Team
