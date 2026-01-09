# Integration Guide for New Features

## Overview

This guide helps developers integrate the authentication system into new features in the SoloAdventurer app. It covers common patterns, best practices, and code examples for authentication in various scenarios.

## Table of Contents

- [Quick Start](#quick-start)
- [Protected Routes](#protected-routes)
- [API Calls with Auth](#api-calls-with-auth)
- [Offline Support](#offline-support)
- [Authentication State](#authentication-state)
- [Common Patterns](#common-patterns)
- [Testing](#testing)
- [Migration Guide](#migration-guide)

## Quick Start

### 1. Check Authentication Status

```dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_provider.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isLoading) {
      return CircularProgressIndicator();
    }

    if (!authState.isAuthenticated) {
      return LoginPromptWidget();
    }

    // User is authenticated, show protected content
    return ProtectedContentWidget();
  }
}
```

### 2. Get Current User

```dart
final authState = ref.watch(authProvider);
final user = authState.user;

if (user != null) {
  print('User: ${user.email}');
  print('Username: ${user.username}');
}
```

### 3. Make Authenticated API Calls

```dart
// The AuthInterceptor automatically adds the access token
final response = await dio.get('/api/user/profile');

// No manual token management needed!
```

## Protected Routes

### Pattern 1: Route Guard

Create a route guard to protect authenticated routes:

```dart
class ProtectedRoute extends ConsumerWidget {
  final String path;
  final Widget child;

  const ProtectedRoute({
    required this.path,
    required this.child,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (!authState.isAuthenticated) {
      // Redirect to login
      return RedirectToLoginRoute();
    }

    return child;
  }
}

// Usage
ProtectedRoute(
  path: '/dashboard',
  child: DashboardScreen(),
)
```

### Pattern 2: Middleware Guard

Use a middleware function to protect routes:

```dart
class AuthGuard {
  static bool canAccess(BuildContext context, WidgetRef ref) {
    final authState = ref.read(authProvider);
    return authState.isAuthenticated;
  }

  static void navigateToLogin(BuildContext context) {
    Navigator.of(context).pushNamed('/login');
  }
}

// Usage in routing
class MyRouter {
  static Route<dynamic>? generateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/dashboard':
        // Check authentication
        return MaterialPageRoute(
          builder: (context) {
            return Consumer(
              builder: (context, ref, _) {
                if (!AuthGuard.canAccess(context, ref)) {
                  AuthGuard.navigateToLogin(context);
                  return Container();
                }
                return DashboardScreen();
              },
            );
          },
        );
    }
  }
}
```

### Pattern 3: Auth Wrapper Widget

Create a wrapper widget that handles authentication:

```dart
class AuthWrapper extends ConsumerWidget {
  final Widget authenticatedChild;
  final Widget unauthenticatedChild;

  const AuthWrapper({
    required this.authenticatedChild,
    required this.unauthenticatedChild,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);

    if (authState.isAuthenticated) {
      return authenticatedChild;
    } else {
      return unauthenticatedChild;
    }
  }
}

// Usage
AuthWrapper(
  authenticatedChild: HomeScreen(),
  unauthenticatedChild: LoginScreen(),
)
```

## API Calls with Auth

### Automatic Token Management

The `AuthInterceptor` automatically:
1. Adds the access token to all API requests
2. Refreshes tokens when they expire (401 error)
3. Retries failed requests with fresh tokens

### Making Authenticated Requests

```dart
// In your repository or service
class UserRepository {
  final Dio _dio;

  Future<UserProfile> getUserProfile() async {
    try {
      final response = await _dio.get('/api/user/profile');
      return UserProfile.fromJson(response.data);
    } catch (e) {
      // Handle error
      throw Exception('Failed to fetch user profile');
    }
  }
}
```

### Manual Token Access

If you need to manually access the token:

```dart
// Get the current access token
final authState = ref.read(authProvider);
final accessToken = await ref.read(authProvider.notifier).getAccessToken();

// Use it manually (not recommended - let AuthInterceptor handle it)
final response = await dio.get(
  '/api/endpoint',
  options: Options(
    headers: {'Authorization': 'Bearer $accessToken'},
  ),
);
```

### Handling Token Refresh Errors

The `AuthInterceptor` handles token refresh automatically, but you can listen for errors:

```dart
// In your repository
class MyRepository {
  Future<void> someOperation() async {
    try {
      await _dio.post('/api/operation');
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        // Token refresh failed
        // Handle appropriately (e.g., redirect to login)
      }
      rethrow;
    }
  }
}
```

## Offline Support

### Check Offline Status

```dart
import 'package:soloadventurer/features/auth/presentation/providers/cached_data_provider.dart';

class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offlineState = ref.watch(offlineStateProvider);

    return offlineState.when(
      data: (state) {
        if (state == OfflineAuthState.online) {
          return OnlineContent();
        } else {
          return OfflineIndicator(
            isOffline: true,
            child: OfflineContent(),
          );
        }
      },
      loading: () => CircularProgressIndicator(),
      error: (_, __) => Text('Error loading offline state'),
    );
  }
}
```

### Access Cached Data

```dart
// Get cached data provider
final cachedDataProvider = ref.read(cachedDataProviderProvider);

// Get cached user profile
final result = await cachedDataProvider.getCachedUserProfile();

if (result.isSuccess && result.isFromCache) {
  final user = result.data;
  if (!result.isFresh) {
    // Show "data may be stale" indicator
    showStaleDataIndicator();
  }
}
```

### Prevent Write Operations Offline

```dart
Future<void> updateProfile(UserProfile profile) async {
  final offlineAuthManager = ref.read(offlineAuthManagerProvider);

  if (offlineAuthManager.isOffline) {
    // Show error: can't update while offline
    throw OfflineException(
      'Cannot update profile while offline',
      recoveryAction: 'Please connect to the internet and try again',
    );
  }

  // Proceed with update
  await _userProfileRepository.update(profile);
}
```

### Show Offline Indicator

```dart
Scaffold(
  appBar: AppBar(
    title: Text('My Screen'),
    actions: [
      // Compact offline indicator in app bar
      Consumer(
        builder: (context, ref, _) {
          final offlineState = ref.watch(offlineStateProvider);
          return offlineState.when(
            data: (state) {
              if (state != OfflineAuthState.online) {
                return OfflineIndicator.compact();
              }
              return Container();
            },
            loading: () => Container(),
            error: (_, __) => Container(),
          );
        },
      ),
    ],
  ),
  body: OfflineBanner(
    child: MyContent(),
  ),
)
```

## Authentication State

### Listen to Auth State Changes

```dart
class MyWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyWidget> createState() => _MyWidgetState();
}

class _MyWidgetState extends ConsumerState<MyWidget> {
  @override
  void initState() {
    super.initState();

    // Listen to auth state changes
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (previous!.isAuthenticated && !next.isAuthenticated) {
        // User just logged out
        _handleLogout();
      } else if (!previous.isAuthenticated && next.isAuthenticated) {
        // User just logged in
        _handleLogin();
      }
    });
  }

  void _handleLogin() {
    // Navigate to home, initialize services, etc.
    Navigator.of(context).pushReplacementNamed('/home');
  }

  void _handleLogout() {
    // Clear data, navigate to login, etc.
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Container();
  }
}
```

### Get Current Auth State

```dart
final authState = ref.watch(authProvider);

if (authState.isAuthenticated) {
  final user = authState.user;
  final session = authState.session;
  // Use user and session data
}
```

### Logout

```dart
Future<void> logout() async {
  try {
    await ref.read(authProvider.notifier).signOut();
    // Navigate to login screen
    Navigator.of(context).pushReplacementNamed('/login');
  } catch (e) {
    // Handle error
    showErrorSnackBar('Failed to logout: $e');
  }
}
```

## Common Patterns

### Pattern 1: Authenticated API Repository

```dart
class TripsRepository {
  final Dio _dio;

  TripsRepository(this._dio);

  Future<List<Trip>> getTrips() async {
    try {
      final response = await _dio.get('/api/trips');
      return (response.data as List)
          .map((json) => Trip.fromJson(json))
          .toList();
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Authentication failed');
      }
      throw Exception('Failed to fetch trips');
    }
  }

  Future<Trip> createTrip(CreateTripRequest request) async {
    try {
      final response = await _dio.post(
        '/api/trips',
        data: request.toJson(),
      );
      return Trip.fromJson(response.data);
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw AuthException('Authentication failed');
      }
      throw Exception('Failed to create trip');
    }
  }
}
```

### Pattern 2: Logout Button

```dart
class LogoutButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: Icon(Icons.logout),
      onPressed: () async {
        // Show confirmation dialog
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (_) => AlertDialog(
            title: Text('Logout'),
            content: Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Logout'),
              ),
            ],
          ),
        );

        if (confirmed == true) {
          await ref.read(authProvider.notifier).signOut();
          Navigator.of(context).pushReplacementNamed('/login');
        }
      },
    );
  }
}
```

### Pattern 3: Login Redirect

```dart
class LoginRequiredWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.lock, size: 64, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Login Required',
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          SizedBox(height: 8),
          Text('Please log in to access this feature'),
          SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pushNamed('/login');
            },
            child: Text('Log In'),
          ),
        ],
      ),
    );
  }
}
```

### Pattern 4: User Profile Display

```dart
class UserProfileWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final user = authState.user;

    if (user == null) {
      return Container();
    }

    return Column(
      children: [
        CircleAvatar(
          radius: 32,
          child: Text(user.username[0].toUpperCase()),
        ),
        SizedBox(height: 8),
        Text(
          user.username,
          style: Theme.of(context).textTheme.titleLarge,
        ),
        Text(
          user.email,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
```

### Pattern 5: Refresh User Data

```dart
class RefreshUserDataButton extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return IconButton(
      icon: Icon(Icons.refresh),
      onPressed: () async {
        try {
          await ref.read(authProvider.notifier).refreshUserData();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('User data refreshed')),
          );
        } catch (e) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to refresh user data')),
          );
        }
      },
    );
  }
}
```

## Testing

### Unit Testing with Mock Auth

```dart
void main() {
  test('should fetch trips when authenticated', () async {
    // Arrange
    final mockAuthRepository = MockAuthRepository();
    when(mockAuthRepository.isAuthenticated())
        .thenAnswer((_) async => true);

    final repository = TripsRepository(mockDio);

    // Act
    final trips = await repository.getTrips();

    // Assert
    expect(trips, isNotEmpty);
  });
}
```

### Widget Testing with Auth Provider

```dart
void main() {
  testWidgets('should show login prompt when not authenticated', (tester) async {
    // Arrange
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authProvider.overrideWith((ref) {
            return AuthNotifier(
              authRepository: mockAuthRepository,
            );
          }),
        ],
        child: MaterialApp(home: MyWidget()),
      ),
    );

    // Assert
    expect(find.text('Please log in'), findsOneWidget);
  });
}
```

### Integration Testing with Auth

```dart
void main() {
  testWidgets('full login flow', (tester) async {
    // Arrange
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(home: LoginScreen()),
      ),
    );

    // Act
    await tester.enterText(
      find.byKey(Key('email-field')),
      'test@example.com',
    );
    await tester.enterText(
      find.byKey(Key('password-field')),
      'password123',
    );
    await tester.tap(find.byKey(Key('login-button')));
    await tester.pumpAndSettle();

    // Assert
    expect(find.byType(HomeScreen), findsOneWidget);
  });
}
```

## Migration Guide

### From Manual Token Management to AuthInterceptor

**Before** ❌

```dart
class MyRepository {
  Future<void> fetchData() async {
    // Manually get token
    final token = await _authRepository.getAccessToken();

    // Manually add to headers
    final response = await _dio.get(
      '/api/data',
      options: Options(
        headers: {'Authorization': 'Bearer $token'},
      ),
    );

    // Manually handle 401
    if (response.statusCode == 401) {
      final newToken = await _authRepository.refreshToken();
      // Retry with new token
      final retryResponse = await _dio.get(
        '/api/data',
        options: Options(
          headers: {'Authorization': 'Bearer $newToken'},
        ),
      );
    }
  }
}
```

**After** ✅

```dart
class MyRepository {
  Future<void> fetchData() async {
    // AuthInterceptor handles everything automatically
    final response = await _dio.get('/api/data');
  }
}
```

### From SharedPreferences to Secure Storage

**Before** ❌

```dart
// Save token
await prefs.setString('access_token', token);

// Load token
final token = prefs.getString('access_token');
```

**After** ✅

```dart
// Save session
await _persistentSessionManager.saveSession(session);

// Load session
final session = await _persistentSessionManager.loadSession();
```

### From Basic Error Handling to AuthErrorHandler

**Before** ❌

```dart
try {
  await authRepository.signIn(email, password);
} catch (e) {
  showSnackBar('Login failed: $e');
}
```

**After** ✅

```dart
try {
  await authRepository.signIn(email, password);
} on AuthException catch (e) {
  final errorHandler = AuthErrorHandler();
  final userMessage = errorHandler.getUserMessage(e);
  final recoverySteps = errorHandler.getRecoverySteps(e);

  showErrorSnackBar(
    userMessage,
    recoverySteps: recoverySteps,
  );
}
```

## Checklist

When integrating authentication into a new feature:

- [ ] Check authentication status before showing protected content
- [ ] Use `AuthProvider` to access auth state
- [ ] Let `AuthInterceptor` handle token management
- [ ] Handle authentication errors appropriately
- [ ] Show offline indicator when offline
- [ ] Prevent write operations when offline
- [ ] Test authenticated and unauthenticated states
- [ ] Test offline and online states
- [ ] Test token refresh scenarios
- [ ] Provide clear error messages to users
- [ ] Log out users on critical auth errors

---

**Document Version**: 1.0
**Last Updated**: 2026-01-04
**Maintainer**: SoloAdventurer Team
