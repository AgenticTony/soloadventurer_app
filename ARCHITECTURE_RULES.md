# Architecture Rules - Riverpod 3.0 AsyncNotifier Pattern

## Locked Standard (2026+)

This document defines the non-negotiable architecture standards for Riverpod 3.0 using the AsyncNotifier pattern.

## Core Principles

1. **Riverpod 3.0 @riverpod Annotations**: Use code-first `@riverpod` annotations with code generation
2. **AsyncNotifier for Async State**: Use `AsyncNotifier<T>` for features with async operations
3. **AsyncValue Wrapper**: State is wrapped in `AsyncValue<T>` - loading/error handled by wrapper
4. **Immutable State Classes**: All state must be immutable using `@freezed` classes
5. **No Manual Loading/Error Fields**: AsyncValue handles loading/error states automatically
6. **One Provider Per Feature**: Single canonical provider per feature

## Auth Feature Architecture (Reference Implementation)

The auth feature is the reference implementation for all features.

### State Pattern

```dart
@freezed
class AuthState with _$AuthState {
  const AuthState._();  // Private constructor for computed getters

  const factory AuthState({
    User? user,
    @Default(false) bool isAuthenticated,
    String? sessionToken,
    DateTime? lastActivity,
  }) = _AuthState;

  // Computed getters for derived state
  bool get hasUser => user != null;
  bool get isLoggedIn => isAuthenticated && hasUser;
}
```

**Key Rules:**
- ❌ NO `bool isLoading` field - AsyncValue.loading() handles this
- ❌ NO `String? error` field - AsyncValue.error() handles this
- ✅ Use `@freezed` for immutable state
- ✅ Add computed getters for derived state

### Notifier Pattern

```dart
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier {
  @override
  FutureOr<AuthState> build() async {
    // Bootstrap: Check for existing session on app start
    final isAuthenticated = await _isSignedIn();
    if (isAuthenticated) {
      final user = await _getCurrentUser();
      if (user != null) {
        return AuthState.authenticated(user: user);
      }
    }
    return AuthState.initial();
  }

  Future<void> signIn(String email, String password) async {
    // Set loading state
    state = const AsyncValue.loading();

    // Use AsyncValue.guard for error handling
    state = await AsyncValue.guard(() async {
      final user = await _login(LoginParams(email: email, password: password));
      return AuthState.authenticated(user: user);
    });
  }
}
```

**Key Rules:**
- ✅ Use `@Riverpod(keepAlive: true)` for auth/state that persists
- ✅ Return `FutureOr<T>` from build() for async initialization
- ✅ Use `AsyncValue.guard()` for all async operations
- ✅ Set `state = const AsyncValue.loading()` before async operations
- ✅ Return state objects from AsyncValue.guard, not set state directly

### Provider Pattern

```dart
// Dependency providers throw UnimplementedError for DI overriding
@riverpod
GetCurrentUser getCurrentUser(GetCurrentUserRef ref) {
  throw UnimplementedError('getCurrentUserProvider must be overridden');
}

// Main provider uses @riverpod annotation - code generation creates:
// - authNotifierProvider (AsyncNotifierProvider<AuthNotifier, AuthState>)
// - authNotifierProvider.notifier (AuthNotifier)
@Riverpod(keepAlive: true)
class AuthNotifier extends _$AuthNotifier { ... }
```

**Key Rules:**
- ✅ Use `@riverpod` annotation - code generation creates provider
- ✅ Abstract providers throw `UnimplementedError` for test DI
- ✅ Generated provider is `AsyncNotifierProvider` (not AutoDisposeNotifierProvider)
- ✅ Use `keepAlive: true` for state that should persist

### UI Pattern

```dart
class LoginScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authAsync = ref.watch(authNotifierProvider);

    return authAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stack) => ErrorWidget(error: error),
      data: (authState) => LoginForm(authState: authState),
    );
  }

  void onLoginPressed() {
    ref.read(authNotifierProvider.notifier).signIn(email, password);
  }
}
```

**Key Rules:**
- ✅ UI uses `.when()` for loading/error/data states
- ✅ UI reads state via `ref.watch(provider)`
- ✅ UI calls methods via `ref.read(provider.notifier).method()`
- ✅ Use `ref.invalidate(provider)` for retry/refresh

### Testing Pattern

```dart
group('AuthNotifier Tests', () {
  ProviderContainer createContainer() {
    return ProviderContainer(
      overrides: [
        getCurrentUserProvider.overrideWithValue(mockGetCurrentUser),
        loginUseCaseProvider.overrideWithValue(mockLoginUseCase),
      ],
    );
  }

  test('signs in successfully', () async {
    final container = createContainer();
    addTearDown(container.dispose);

    await container.read(authNotifierProvider.notifier).signIn(
      'test@example.com',
      'password',
    );

    final authStateAsync = container.read(authNotifierProvider);
    expect(
      authStateAsync,
      isA<AsyncData<AuthState>>()
          .having((s) => s.value?.isAuthenticated, 'isAuthenticated', true),
    );
  });
});
```

**Key Rules:**
- ✅ Use `ProviderContainer(overrides: [...])` for test isolation
- ✅ Always `addTearDown(container.dispose)`
- ✅ Test AsyncValue states: `AsyncData`, `AsyncError`, `AsyncValue.loading()`
- ✅ Override providers with mock implementations

## Approved Patterns

### For Features with Async Operations (Like Auth)

```dart
@riverpod
class FeatureNotifier extends _$FeatureNotifier {
  @override
  FutureOr<FeatureState> build() async => FeatureState.initial();

  Future<void> fetchData() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final data = await _repository.getData();
      return FeatureState.data(data);
    });
  }
}
```

### For Features with Simple State (No Async)

```dart
@riverpod
class SimpleNotifier extends _$SimpleNotifier {
  @override
  SimpleState build() => SimpleState.initial();

  void updateValue(String value) {
    state = state.copyWith(value: value);
  }
}
```

## Forbidden Patterns

❌ **StateNotifier** - Legacy pattern, use AsyncNotifier
❌ **AutoDisposeNotifierProvider** - Use @riverpod with keepAlive parameter
❌ **Manual isLoading/error fields in State** - AsyncValue handles this
❌ **state.copyWith(isLoading: true)** - Use AsyncValue.loading()
❌ **GetIt in tests** - Use ProviderContainer with overrides
❌ **Nullable State** - State must always have a value
❌ **Multiple providers for same feature** - One canonical provider only

## Migration Checklist

Use this checklist when creating new features or migrating existing ones:

- [ ] State uses `@freezed` annotation
- [ ] State has NO `isLoading` field
- [ ] State has NO `error` field
- [ ] Notifier extends `AsyncNotifier<T>` or `Notifier<T>`
- [ ] Notifier uses `@riverpod` or `@Riverpod(keepAlive: true)` annotation
- [ ] Build method returns `FutureOr<T>` for async operations
- [ ] All async methods use `AsyncValue.guard()` pattern
- [ ] UI uses `.when()` for state handling
- [ ] Tests use `ProviderContainer` with overrides
- [ ] Code generation run: `dart run build_runner build`

## Quality Gates

Every PR must pass:
```bash
# Static analysis
flutter analyze lib/features/auth/

# Run tests
flutter test test/features/auth/

# Check for legacy patterns
grep -rn "StateNotifier" lib/features/auth/
grep -rn "isLoading" lib/features/auth/presentation/state/

# Build verification
flutter build apk --debug
```

## CI Checks

The `.github/workflows/code-quality.yml` workflow includes:
- ✅ No StateNotifier in auth feature
- ✅ No manual isLoading in AuthState
- ✅ No old auth_providers.dart files
- ✅ AsyncNotifierProvider (not AutoDisposeNotifierProvider)
- ✅ Auth screens use AsyncValue.when() pattern

## File Organization

Each feature should follow this structure:
```
features/feature/
├── data/
│   ├── repositories/
│   │   └── feature_repository_impl.dart
│   └── models/
├── domain/
│   ├── entities/
│   │   └── feature_state.dart
│   ├── repositories/
│   │   └── feature_repository.dart
│   └── usecases/
├── presentation/
│   ├── state/
│   │   └── feature_state.dart
│   ├── providers/
│   │   └── feature_notifier_provider.dart
│   └── screens/
```

## Success Criteria

Feature migration is complete when:
- ✅ `flutter analyze` is clean (0 issues)
- ✅ All tests pass with `ProviderContainer` pattern
- ✅ No `StateNotifier` references remain
- ✅ No manual `isLoading`/`error` fields in state
- ✅ UI uses `AsyncValue.when()` pattern
- ✅ Code generation successful
- ✅ APK builds successfully
