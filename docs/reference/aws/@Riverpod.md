# Riverpod Documentation

Official Documentation: [Riverpod Documentation](https://riverpod.dev/)

Riverpod is a reactive caching and data-binding framework for Flutter. For complete and up-to-date documentation, please refer to the official Riverpod documentation at https://riverpod.dev/

## Key Documentation Links

1. **Getting Started**

   - [Installation](https://riverpod.dev/docs/introduction/getting_started)
   - [Core Concepts](https://riverpod.dev/docs/concepts/providers)
   - [Migration Guide](https://riverpod.dev/docs/migration/from_provider)

2. **Providers**

   - [Provider Types](https://riverpod.dev/docs/providers/provider)
   - [StateNotifierProvider](https://riverpod.dev/docs/providers/state_notifier_provider)
   - [FutureProvider](https://riverpod.dev/docs/providers/future_provider)
   - [StreamProvider](https://riverpod.dev/docs/providers/stream_provider)

3. **State Management**

   - [Modifiers](https://riverpod.dev/docs/concepts/modifiers)
   - [Combining Providers](https://riverpod.dev/docs/concepts/combining_providers)
   - [Reading Providers](https://riverpod.dev/docs/concepts/reading)
   - [Auto-dispose](https://riverpod.dev/docs/concepts/modifiers/auto_dispose)

4. **Advanced Topics**
   - [Testing](https://riverpod.dev/docs/cookbooks/testing)
   - [Code Generation](https://riverpod.dev/docs/concepts/code_generation)
   - [Provider Observer](https://riverpod.dev/docs/concepts/provider_observer)

## API Reference

- [Riverpod API documentation](https://pub.dev/documentation/riverpod/latest/)
- [flutter_riverpod API documentation](https://pub.dev/documentation/flutter_riverpod/latest/)

## Examples and Guides

For common Riverpod patterns and recipes:

- [Official Examples](https://github.com/rrousselGit/riverpod/tree/master/examples)
- [Cookbook](https://riverpod.dev/docs/cookbooks/testing)

## Best Practices and Guidelines

For best practices and implementation guidelines, refer to:

- [Modifiers](https://riverpod.dev/docs/concepts/modifiers)
- [Selecting Provider State](https://riverpod.dev/docs/concepts/reading#using-select-to-filter-rebuilds)
- [Error Handling](https://riverpod.dev/docs/concepts/reading#handling-errors)
- [Performance Optimization](https://riverpod.dev/docs/concepts/reading#optimizing-performance)

## Overview

Riverpod is a reactive caching and data-binding framework for Flutter that provides:

- Compile-time safety
- Automatic dependency management
- Built-in caching and error handling
- Reactive state management

## Core Concepts

### 1. Providers

Providers are the fundamental building blocks of Riverpod:

```dart
// Simple provider
final counterProvider = Provider<int>((ref) => 0);

// StateNotifier provider
final counterStateProvider = StateNotifierProvider<Counter, int>((ref) => Counter());

// Future provider
final userProvider = FutureProvider<User>((ref) => fetchUser());

// Stream provider
final updatesProvider = StreamProvider<List<Update>>((ref) => getUpdates());
```

### 2. Provider Types

1. **Provider**

   - Simplest form of provider
   - Exposes an immutable value
   - Used for computed states

2. **StateProvider**

   - Exposes a mutable state
   - Simple state management
   - Best for primitive types

3. **StateNotifierProvider**

   - Exposes a StateNotifier subclass
   - Complex state management
   - Encapsulated state mutations

4. **FutureProvider**

   - Exposes a Future
   - Handles async operations
   - Built-in loading/error states

5. **StreamProvider**
   - Exposes a Stream
   - Real-time updates
   - Built-in caching

### 3. Ref Object

The `ref` object is your interface to interact with providers:

```dart
class MyNotifier extends StateNotifier<MyState> {
  MyNotifier(this.ref) : super(MyState());

  final Ref ref;

  void doSomething() {
    // Watch other providers
    final value = ref.watch(otherProvider);

    // Read providers once
    final data = ref.read(dataProvider);

    // Listen to changes
    ref.listen(stateProvider, (previous, next) {
      // Handle state changes
    });
  }
}
```

## State Management

### 1. Basic State

```dart
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  void increment() => state++;
  void decrement() => state--;
}
```

### 2. Async State

```dart
@riverpod
class UserRepository extends _$UserRepository {
  @override
  Future<User> build() => fetchUser();

  Future<void> updateUser(User user) async {
    state = const AsyncValue.loading();
    try {
      await updateUserApi(user);
      state = AsyncValue.data(user);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}
```

### 3. Complex State

```dart
@riverpod
class AuthState extends _$AuthState {
  @override
  AuthStatus build() => const AuthStatus.initial();

  Future<void> signIn(String username, String password) async {
    state = const AuthStatus.loading();
    try {
      final user = await ref.read(authServiceProvider).signIn(
        username,
        password,
      );
      state = AuthStatus.authenticated(user);
    } catch (e) {
      state = AuthStatus.error(e.toString());
    }
  }
}
```

## UI Integration

### 1. ConsumerWidget

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);
    return Text('Count: $counter');
  }
}
```

### 2. ConsumerStatefulWidget

```dart
class MyStatefulWidget extends ConsumerStatefulWidget {
  @override
  ConsumerState<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends ConsumerState<MyStatefulWidget> {
  @override
  void initState() {
    super.initState();
    ref.read(initializationProvider.notifier).initialize();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stateProvider);
    return Text('State: $state');
  }
}
```

### 3. AsyncValue Widget

```dart
class UserProfile extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    return userAsync.when(
      data: (user) => UserProfileView(user: user),
      loading: () => const LoadingSpinner(),
      error: (error, stack) => ErrorView(error: error),
    );
  }
}
```

## Best Practices

### 1. Provider Organization

```dart
// Group related providers
final userProviders = <Provider>[
  userProvider,
  userPreferencesProvider,
  userSettingsProvider,
];

// Use family modifiers for parameterized providers
final userProfileProvider = FutureProvider.family<Profile, String>(
  (ref, userId) => fetchUserProfile(userId),
);
```

### 2. Error Handling

```dart
@riverpod
class ErrorHandler extends _$ErrorHandler {
  @override
  void build() {
    ref.listen(
      authProvider.select((state) => state.error),
      (previous, next) {
        if (next != null) {
          showErrorDialog(next);
        }
      },
    );
  }
}
```

### 3. Dependency Injection

```dart
final apiClientProvider = Provider<ApiClient>((ref) {
  final config = ref.watch(configProvider);
  return ApiClient(
    baseUrl: config.apiUrl,
    timeout: config.timeout,
  );
});

final repositoryProvider = Provider<Repository>((ref) {
  final apiClient = ref.watch(apiClientProvider);
  return Repository(apiClient: apiClient);
});
```

## Testing

### 1. Provider Override

```dart
void main() {
  test('counter increments', () {
    final container = ProviderContainer(
      overrides: [
        counterProvider.overrideWith(
          (ref) => Counter()..state = 10,
        ),
      ],
    );

    expect(container.read(counterProvider), 10);
  });
}
```

### 2. Mock Dependencies

```dart
class MockApiClient implements ApiClient {
  @override
  Future<User> getUser() async => User(id: '1', name: 'Test');
}

void main() {
  test('repository gets user', () {
    final container = ProviderContainer(
      overrides: [
        apiClientProvider.overrideWithValue(MockApiClient()),
      ],
    );

    expect(
      container.read(repositoryProvider).getUser(),
      completion(isA<User>()),
    );
  });
}
```

### 3. AsyncValue Testing

```dart
void main() {
  test('async state transitions', () async {
    final container = ProviderContainer();
    final listener = Listener<AsyncValue<User>>();

    container.listen(
      userProvider,
      listener.call,
      fireImmediately: true,
    );

    verify(() => listener(AsyncValue.loading()));

    await container.read(userProvider.future);

    verify(() => listener(AsyncValue.data(User())));
  });
}
```
