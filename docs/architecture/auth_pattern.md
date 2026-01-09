# Auth Feature Architecture

## Current State vs. Target Pattern

This document describes both the current Auth architecture and the target Riverpod 3.0 + Freezed pattern that should be used for consistency with other features (like Safety).

---

## Current Architecture

### State: `lib/features/auth/presentation/state/auth_state.dart`

The current `AuthState` uses a traditional class with constructor-based state management:

```dart
class AuthState {
  final User? user;
  final bool isAuthenticated;
  final bool requiresMFA;
  final bool requiresEmailVerification;
  final bool requiresPasswordReset;
  final String? accessToken;
  final String? idToken;
  final String? refreshToken;
  final DateTime? tokenExpiresAt;

  const AuthState.initial()
  const AuthState.authenticated({required User user, ...})
  const AuthState.unverified({required User user})
  const AuthState.mfaRequired({required User user})
  const AuthState.passwordResetRequired({required User user})
  const AuthState.unauthenticated()
  const AuthState.loading()
  const AuthState.error()

  AuthState copyWith({...})
}
```

**Key Characteristics:**
- Immutable class with const constructors
- Boolean fields for state checks: `isAuthenticated`, `requiresMFA`, etc.
- Includes token information directly in state
- Manual `copyWith` method for state updates
- Equality operator and hashCode implemented

### Provider/Notifier: Multiple Files

Currently there are multiple AuthNotifier implementations:

1. `lib/features/auth/domain/notifiers/auth_notifier.dart` - Domain layer
2. `lib/features/auth/presentation/notifiers/auth_notifier.dart` - Presentation layer
3. `lib/features/auth/presentation/providers/auth_provider.dart` - Provider definition

**This duplication is a known issue** that should be resolved.

### Current Usage Pattern

```dart
// Watching state
final authAsync = ref.watch(authNotifierProvider);
return authAsync.when(
  data: (state) {
    if (state.isAuthenticated) {
      return HomeScreen(user: state.user!);
    }
    return LoginScreen();
  },
  loading: () => LoadingIndicator(),
  error: (err, st) => ErrorWidget(err.toString()),
);

// Calling methods
ref.read(authNotifierProvider.notifier).signIn(
  email: email,
  password: password,
);
```

---

## Target Architecture: Riverpod 3.0 + Freezed

For consistency with Safety features (Trusted Contacts, Check-In), the Auth feature should migrate to:

### 1. State with Freezed

```dart
@freezed
class AuthState with _$AuthState {
  const factory AuthState.initial() = AuthInitial;
  const factory AuthState.loading() = AuthLoading;
  const factory AuthState.authenticated({
    required User user,
    String? accessToken,
    String? idToken,
    String? refreshToken,
    DateTime? tokenExpiresAt,
  }) = Authenticated;

  const factory AuthState.unauthenticated({
    AuthError? error,
  }) = Unauthenticated;

  const factory AuthState.unverified({
    required User user,
  }) = Unverified;

  const factory AuthState.mfaRequired({
    required User user,
  }) = MfaRequired;

  const factory AuthState.passwordResetRequired({
    required User user,
  }) = PasswordResetRequired;

  // Boolean fields for type-safe state checking
  bool get isAuthenticated => maybeWhen(
    authenticated: (_) => true,
    orElse: () => false,
  );

  bool get isUnauthenticated => maybeWhen(
    unauthenticated: (_) => true,
    orElse: () => false,
  );
}
```

### 2. Provider with @riverpod

```dart
@riverpod
class AuthNotifier extends _$AuthNotifier {
  @override
  Future<AuthState> build() async {
    // Check if user is already authenticated
    final user = await _authRepository.getCurrentUser();
    if (user != null) {
      return AuthState.authenticated(user: user);
    }
    return const AuthState.unauthenticated();
  }

  Future<void> signIn({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await _authRepository.signIn(email, password);
      return AuthState.authenticated(user: user);
    });
  }

  Future<void> signUp({required String email, required String password}) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await _authRepository.signUp(email, password);
      return AuthState.unverified(user: user);
    });
  }

  Future<void> signOut() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      await _authRepository.signOut();
      return const AuthState.unauthenticated();
    });
  }

  Future<void> refreshTokens() async {
    final currentState = state.valueOrNull;
    if (currentState?.isAuthenticated != true) return;

    state = await AsyncValue.guard(() async {
      final tokens = await _authRepository.refreshTokens();
      return currentState!.copyWith(
        accessToken: tokens.accessToken,
        idToken: tokens.idToken,
        refreshToken: tokens.refreshToken,
        tokenExpiresAt: tokens.expiresAt,
      );
    });
  }
}
```

---

## Architecture Comparison

| Aspect | Current | Target |
|--------|---------|--------|
| State Definition | Manual class | `@freezed` annotation |
| Immutability | Manual enforcement | Automatic via Freezed |
| copyWith | Manual implementation | Auto-generated |
| Pattern Matching | Not available | Available via `when`/`maybeWhen` |
| Provider | `StateNotifierProvider` | `@riverpod` code generation |
| Notifier | `StateNotifier<AsyncValue<T>>` | `AutoDisposeAsyncNotifier<T>` |
| State Access | `AsyncValue<AuthState>` | `AsyncValue<AuthState>` (implicit) |
| Code Generation | Not used | Required (`build_runner`) |

---

## Forbidden Patterns (Apply to Both Current and Target)

❌ **DO NOT** use type checking with 'is' keyword
```dart
if (state is Authenticated) { // ❌ FORBIDDEN
```
- Use boolean fields: `if (state.isAuthenticated)`

❌ **DO NOT** access `.state` directly on provider
```dart
ref.read(authNotifierProvider.state); // ❌ FORBIDDEN
```
- State is managed by Riverpod through `AsyncValue`

❌ **DO NOT** create duplicate AuthNotifier classes
- Only one `AuthNotifier` class should exist

❌ **DO NOT** use manual state mutation
```dart
state.user = newUser; // ❌ FORBIDDEN
```
- Always create new state instances

---

## Required Patterns (Apply to Both Current and Target)

✅ **MUST** use boolean fields for state checking
- `isAuthenticated`, `isUnauthenticated`, `requiresMFA`, etc.

✅ **MUST** use `AsyncValue` for state management
- Handle loading, data, and error states consistently

✅ **MUST** use `ref.watch()` for reading state
- `ref.watch(authNotifierProvider)`

✅ **MUST** use `ref.read()` with `.notifier` for methods
- `ref.read(authNotifierProvider.notifier).signIn(...)`

✅ **MUST** handle all three AsyncValue states
```dart
authAsync.when(
  data: (state) { /* handle data */ },
  loading: () => /* show loading */,
  error: (err, st) => /* show error */,
)
```

---

## Usage Pattern (Works for Both Current and Target)

### Watching State

```dart
class AuthWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authNotifierProvider);

    return authAsync.when(
      data: (state) {
        // Use boolean fields, not type checking
        if (state.isAuthenticated) {
          return AuthenticatedView(user: state.user!);
        }
        if (state.requiresMFA) {
          return MFAView();
        }
        if (state.requiresEmailVerification) {
          return EmailVerificationView(user: state.user!);
        }
        return LoginView();
      },
      loading: () => LoadingIndicator(),
      error: (err, st) => ErrorDisplay(error: err.toString()),
    );
  }
}
```

### Calling Methods

```dart
// Sign in
ref.read(authNotifierProvider.notifier).signIn(
  email: email,
  password: password,
);

// Sign up
ref.read(authNotifierProvider.notifier).signUp(
  email: email,
  password: password,
);

// Sign out
ref.read(authNotifierProvider.notifier).signOut();

// Refresh tokens
ref.read(authNotifierProvider.notifier).refreshTokens();
```

### Navigation with ref.listen

```dart
class AuthWrapper extends ConsumerStatefulWidget {
  @override
  ConsumerState<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends ConsumerState<AuthWrapper> {
  @override
  void initState() {
    super.initState();
    // Listen to auth state changes for navigation
    ref.listen(authNotifierProvider, (previous, next) {
      next.when(
        data: (state) {
          if (state.isAuthenticated && !previous?.value?.isAuthenticated == true) {
            // Just logged in
            context.go('/home');
          } else if (state.isUnauthenticated && previous?.value?.isAuthenticated == true) {
            // Just logged out
            context.go('/login');
          }
        },
        loading: () {},
        error: (err, st) {
          // Show error snackbar
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Authentication error: $err')),
          );
        },
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    final authAsync = ref.watch(authNotifierProvider);
    // ... rest of build
  }
}
```

---

## Validation

Run the architecture validation script:

```bash
./scripts/validate_auth_architecture.sh
```

This script validates:
1. AuthState file exists with proper structure
2. AuthNotifier files present
3. Provider files exist
4. No pseudo-type checking with 'is' keyword
5. State constructors follow pattern
6. Proper field access patterns used
7. Provider naming consistent
8. No problematic .state access

---

## Migration Checklist (Current → Target)

To migrate from current to target architecture:

### Phase 1: Preparation
- [ ] Review current AuthState usage across the codebase
- [ ] Identify all screens/widgets using auth state
- [ ] Document all current auth methods and their behavior
- [ ] Create feature branch for migration

### Phase 2: Update State
- [ ] Add `@freezed` dependency to `pubspec.yaml` (if not present)
- [ ] Convert `AuthState` to Freezed class
- [ ] Add `@freezed` annotation
- [ ] Run `dart run build_runner build --delete-conflicting-outputs`
- [ ] Update imports to use generated file

### Phase 3: Update Provider
- [ ] Consolidate AuthNotifier to single file
- [ ] Add `@riverpod` annotation
- [ ] Change from `StateNotifier` to `AutoDisposeAsyncNotifier`
- [ ] Remove manual provider definitions
- [ ] Update build method
- [ ] Run `dart run build_runner build --delete-conflicting-outputs`

### Phase 4: Update Usage
- [ ] Update state access patterns (if needed)
- [ ] Ensure all tests pass
- [ ] Update integration tests
- [ ] Run validation script

### Phase 5: Testing
- [ ] Unit tests for AuthState
- [ ] Unit tests for AuthNotifier
- [ ] Widget tests for auth screens
- [ ] Integration tests for auth flow
- [ ] Manual testing of all auth flows

### Phase 6: Cleanup
- [ ] Remove old AuthNotifier files
- [ ] Remove unused imports
- [ ] Update documentation
- [ ] Create PR with migration notes

---

## Testing Patterns

### Unit Test for AuthNotifier

```dart
test('auth state changes on login', () async {
  final container = ProviderContainer(
    overrides: [
      authRepositoryProvider.overrideWithValue(mockAuthRepository),
    ],
  );

  // Initial state
  expect(
    container.read(authNotifierProvider).value,
    isA<AuthState>().having((s) => s.isUnauthenticated, 'isUnauthenticated', true),
  );

  // Sign in
  await container.read(authNotifierProvider.notifier).signIn(
    email: 'test@example.com',
    password: 'password',
  );

  // State should be authenticated
  expect(
    container.read(authNotifierProvider).value,
    isA<AuthState>().having((s) => s.isAuthenticated, 'isAuthenticated', true),
  );
});
```

### Widget Test for Auth Screen

```dart
testWidgets('login screen shows error on failed login', (tester) async {
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockFailingAuthRepository),
      ],
      child: MaterialApp(home: LoginScreen()),
    ),
  );

  // Enter credentials
  await tester.enterText(find.byKey(Key('emailField')), 'test@example.com');
  await tester.enterText(find.byKey(Key('passwordField')), 'wrongpassword');

  // Tap login button
  await tester.tap(find.byKey(Key('loginButton')));
  await tester.pumpAndSettle();

  // Verify error shown
  expect(find.text('Invalid credentials'), findsOneWidget);
});
```

---

## Related Documentation

- [Riverpod Patterns](/Users/anthonyforan/SoloAdventurer_app/docs/RIVERPOD_PATTERNS.md)
- [Testing Patterns](/Users/anthonyforan/SoloAdventurer_app/docs/TESTING_PATTERNS.md)
- [Auth Architecture](/Users/anthonyforan/SoloAdventurer_app/docs/AUTH_ARCHITECTURE.md)
- [Architecture Overview](/Users/anthonyforan/SoloAdventurer_app/docs/ARCHITECTURE.md)
- [Safety Feature Pattern](/Users/anthonyforan/SoloAdventurer_app/docs/architecture/safety_pattern.md) - Reference for target pattern

---

## Quick Reference

### File Locations

| Component | Location |
|-----------|----------|
| State | `lib/features/auth/presentation/state/auth_state.dart` |
| Provider | `lib/features/auth/presentation/providers/auth_provider.dart` |
| Notifier | `lib/features/auth/presentation/notifiers/auth_notifier.dart` (to be consolidated) |
| Repository | `lib/features/auth/data/repositories/auth_repository_impl.dart` |
| Use Cases | `lib/features/auth/domain/usecases/` |

### Key Commands

```bash
# Validate architecture
./scripts/validate_auth_architecture.sh

# Generate code (after adding @freezed or @riverpod)
dart run build_runner build --delete-conflicting-outputs

# Run auth tests
flutter test test/features/auth/

# Run integration tests
flutter test integration_test/auth_flow_test.dart
```

### Common Patterns

```dart
// Watch auth state
final authAsync = ref.watch(authNotifierProvider);

// Call auth method
ref.read(authNotifierProvider.notifier).signIn(...);

// Check if authenticated
if (authState.isAuthenticated) { ... }

// Check if requires MFA
if (authState.requiresMFA) { ... }

// Access current user
final user = authState.user;

// Access tokens
final accessToken = authState.accessToken;
```

---

**Last Updated:** 2026-01-09
**Status:** Current architecture documented, migration to Riverpod 3.0 + Freezed planned
