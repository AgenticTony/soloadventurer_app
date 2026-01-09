# Riverpod Documentation (Updated for 2026)

Official Documentation: [Riverpod Documentation](https://riverpod.dev/)

**Current Version:** Riverpod 3.0+ / 2.5+ (2025)

Riverpod is a reactive caching and data-binding framework for Flutter. For complete and up-to-date documentation, please refer to the official Riverpod documentation at https://riverpod.dev/

> **🚀 2026 Update:** This document now covers modern @riverpod code generation, AsyncNotifier, AsyncLoading patterns, and Dart 3 switch pattern matching.

## Key Documentation Links

### 1. **Getting Started**
   - [Installation](https://riverpod.dev/docs/introduction/getting_started)
   - [Core Concepts](https://riverpod.dev/docs/concepts/providers)
   - [Code Generation](https://riverpod.dev/docs/concepts/code_generation)

### 2. **Providers (Modern)**
   - [@riverpod annotation](https://riverpod.dev/docs/concepts/code_generation)
   - [AsyncNotifierProvider](https://riverpod.dev/docs/providers/async_notifier_provider)
   - [NotifierProvider](https://riverpod.dev/docs/providers/notifier_provider)
   - [FutureProvider](https://riverpod.dev/docs/providers/future_provider)

### 3. **State Management**
   - [Modifiers](https://riverpod.dev/docs/concepts/modifiers)
   - [Reading Providers](https://riverpod.dev/docs/concepts/reading)
   - [Auto-dispose](https://riverpod.dev/docs/concepts/modifiers/auto_dispose)
   - [Select for filtering rebuilds](https://riverpod.dev/docs/concepts/reading#using-select-to-filter-rebuilds)

### 4. **Advanced Topics**
   - [Testing with Riverpod](https://riverpod.dev/docs/cookbooks/testing)
   - [Provider Observer](https://riverpod.dev/docs/concepts/provider_observer)
   - [Migration from StateNotifier](https://riverpod.dev/docs/migration/from_state_notifier)

## API Reference
- [Riverpod API](https://pub.dev/documentation/riverpod/latest/)
- [flutter_riverpod API](https://pub.dev/documentation/flutter_riverpod/latest/)
- [riverpod_annotation API](https://pub.dev/documentation/riverpod_annotation/latest/)

---

## What's New in Riverpod 3.0 (2025)

### Key Features Added:
- **Sealed AsyncValue** - Exhaustive pattern matching support
- **Enhanced code generation** - Better @riverpod annotations
- **AsyncNotifier improvements** - Simplified async state management
- **Better TypeScript integration** for cross-platform
- **Improved performance** - Optimized rebuilds
- **Provider observers** - Enhanced debugging capabilities

---

## Core Concepts (2026 Edition)

### 1. Modern @riverpod Code Generation

**⚠️ DEPRECATED:** Manual provider definitions, StateNotifierProvider
**✅ RECOMMENDED:** @riverpod annotation with code generation

```dart
// Modern @riverpod pattern
import 'package:riverpod_annotation/riverpod_annotation.dart';

part 'my_provider.g.dart';

@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  void increment() => state++;
  void decrement() => state--;
}

// Generated: counterProvider
// Usage: ref.watch(counterProvider)
// Notifier: ref.read(counterProvider.notifier).increment()
```

### 2. AsyncNotifier for Async State

```dart
@riverpod
class UserRepository extends _$UserRepository {
  @override
  Future<User> build() async {
    // Initialization happens once
    return fetchUser();
  }

  Future<void> updateUser(User user) async {
    // ✅ Modern AsyncLoading syntax
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      return await updateUserApi(user);
    });
  }
}
```

### 3. Function Providers with Parameters

```dart
@riverpod
Future<User> fetchUser(Ref ref, {required String userId}) async {
  final response = await http.get('/users/$userId');
  return User.fromJson(jsonDecode(response.body));
}

// Generated: fetchUserProvider(userId: '123')
```

### 4. Provider Dependencies

```dart
@riverpod
class UserProfile extends _$UserProfile {
  @override
  Future<Profile> build(String userId) async {
    // Watch other providers
    final user = await ref.watch(fetchUserProvider(userId: userId).future);
    final settings = await ref.watch(userSettingsProvider(userId).future);

    return Profile(user: user, settings: settings);
  }
}
```

---

## Modern State Management Patterns

### 1. Simple State

```dart
@riverpod
class Counter extends _$Counter {
  @override
  int build() => 0;

  void increment() => state++;
  void decrement() => state--;
}
```

### 2. Async State with AsyncNotifier

```dart
@riverpod
class TodoList extends _$TodoList {
  @override
  Future<List<Todo>> build() async {
    final response = await http.get('/todos');
    return (jsonDecode(response.body) as List)
        .map((json) => Todo.fromJson(json))
        .toList();
  }

  Future<void> addTodo(String description) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final response = await http.post(
        '/todos',
        body: jsonEncode({'description': description}),
      );
      final newTodo = Todo.fromJson(jsonDecode(response.body));
      return [...await future, newTodo];
    });
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
    state = await AsyncValue.guard(() async {
      final user = await ref.read(authServiceProvider).signIn(
        username,
        password,
      );
      return AuthStatus.authenticated(user);
    });
  }
}
```

---

## Modern UI Integration (2026)

### 1. ConsumerWidget (Preferred)

```dart
class MyWidget extends ConsumerWidget {
  const MyWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final counter = ref.watch(counterProvider);
    return Text('Count: $counter');
  }
}
```

### 2. AsyncValue with Pattern Matching (Dart 3)

```dart
class UserProfile extends ConsumerWidget {
  const UserProfile({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userProvider);

    // ✅ Modern: Exhaustive pattern matching
    return switch (userAsync) {
      AsyncData(:final value?) => UserProfileView(user: value),
      AsyncError(:final error?) => ErrorView(error: error),
      _ => const LoadingSpinner(),
    };
  }
}
```

### 3. AsyncValue with .when() (Still Valid)

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

### 4. ConsumerStatefulWidget (Only when needed)

```dart
class MyStatefulWidget extends ConsumerStatefulWidget {
  const MyStatefulWidget({super.key});

  @override
  ConsumerState<MyStatefulWidget> createState() => _MyStatefulWidgetState();
}

class _MyStatefulWidgetState extends ConsumerState<MyStatefulWidget> {
  @override
  void initState() {
    super.initState();
    // Use addPostFrameCallback for initialization
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(initializationProvider.notifier).initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(stateProvider);
    return Text('State: $state');
  }
}
```

---

## Provider Modifiers

### 1. Keep Alive

```dart
@Riverpod(keepAlive: true)
class PersistentState extends _$PersistentState {
  @override
  int build() => 0;
}
```

### 2. Family (Parameterized Providers)

```dart
@riverpod
Future<User> fetchUser(Ref ref, {required String userId}) async {
  return fetchUserFromApi(userId);
}

// Usage
ref.watch(fetchUserProvider(userId: '123'))
```

### 3. Auto Dispose (Default)

```dart
// Automatically disposes when no longer listened to
@riverpod
class EphemeralState extends _$EphemeralState {
  @override
  int build() => 0;
}
```

---

## Best Practices (2026)

### 1. Provider Organization

```dart
// Group related providers in same file
@riverpod
int counter(Ref ref) => 0;

@riverpod
class CounterNotifier extends _$CounterNotifier {
  @override
  int build() => ref.watch(counterProvider);
}

// Use family for parameterized providers
@riverpod
Future<Profile> userProfile(Ref ref, {required String userId}) async {
  return fetchUserProfile(userId);
}
```

### 2. Error Handling with ref.listen

```dart
@riverpod
class ErrorHandler extends _$ErrorHandler {
  @override
  void build() {
    ref.listen(authProvider, (previous, next) {
      // ✅ Modern: Pattern matching
      switch (next) {
        case AsyncValue(:final error?):
          showErrorDialog(error);
        case AsyncData():
          clearErrors();
        case _:
          break; // Loading state
      }
    });
  }
}
```

### 3. Dependency Injection

```dart
@riverpod
ApiClient apiClient(Ref ref) {
  final config = ref.watch(configProvider);
  return ApiClient(
    baseUrl: config.apiUrl,
    timeout: config.timeout,
  );
}

@riverpod
Repository repository(Ref ref) {
  final apiClient = ref.watch(apiClientProvider);
  return Repository(apiClient: apiClient);
}
```

### 4. Selective Rebuilds

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Only rebuild when name changes, not entire user object
    final name = ref.watch(
      userProvider.select((user) => user.name)
    );
    return Text(name);
  }
}
```

---

## Testing (2026 Patterns)

### 1. Provider Container Testing

```dart
void main() {
  test('counter increments', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final notifier = container.read(counterProvider.notifier);

    notifier.increment();
    expect(container.read(counterProvider), 1);
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
    addTearDown(container.dispose);

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
    addTearDown(container.dispose);

    final listener = Listener<AsyncValue<User>>();

    container.listen(
      userProvider,
      listener.call,
      fireImmediately: true,
    );

    // Verify loading state
    verify(() => listener(const AsyncLoading()));

    await container.read(userProvider.future);

    // Verify data state
    verify(() => listener(AsyncData(User())));
  });
}
```

---

## Migration Guide

### From StateNotifier to AsyncNotifier

**❌ OLD (StateNotifier):**
```dart
class TodoListNotifier extends StateNotifier<AsyncValue<List<String>>> {
  TodoListNotifier() : super(const AsyncValue.loading());

  Future<void> fetchTodos() async {
    try {
      final todos = await api.getTodos();
      state = AsyncValue.data(todos);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}
```

**✅ NEW (AsyncNotifier):**
```dart
@riverpod
class TodoList extends _$TodoList {
  @override
  Future<List<String>> build() async {
    return api.getTodos();
  }

  Future<void> addTodo(String todo) async {
    state = await AsyncValue.guard(() async {
      final current = await future;
      return [...current, todo];
    });
  }
}
```

---

## Common Patterns

### 1. Computed Providers

```dart
@riverpod
int filteredTodoCount(Ref ref) {
  final todos = ref.watch(todoListProvider);
  final filter = ref.watch(todoFilterProvider);

  return switch (filter) {
    TodoFilter.all => todos.length,
    TodoFilter.completed => todos.where((t) => t.isCompleted).length,
    TodoFilter.active => todos.where((t) => !t.isCompleted).length,
  };
}
```

### 2. Derived State

```dart
@riverpod
class FormState extends _$FormState {
  @override
  FormState build() {
    return FormState(
      email: '',
      password: '',
    );
  }

  void updateEmail(String email) {
    state = state.copyWith(email: email);
  }

  bool get isValid => state.email.isNotEmpty && state.password.isNotEmpty;
}
```

### 3. Reactive Side Effects

```dart
@riverpod
void sideEffects(Ref ref) {
  ref.listen(userProvider, (previous, next) {
    next.whenData((user) {
      Analytics.track('user_loaded', {'userId': user.id});
    });
  });
}
```

---

## Performance Tips

### 1. Use select for Granular Updates

```dart
// ❌ BAD: Rebuilds on entire object change
final user = ref.watch(userProvider);
return Text(user.name);

// ✅ GOOD: Only rebuilds when name changes
final name = ref.watch(userProvider.select((user) => user.name));
return Text(name);
```

### 2. Auto Dispose for Temporary State

```dart
// Automatically disposed when not in use
@riverpod
class DialogState extends _$DialogState {
  @override
  bool build() => false;
}
```

### 3. Lazy Loading

```dart
@riverpod
Future<ExpensiveData> expensiveData(Ref ref) async {
  // Only computed when first watched
  return await computeExpensiveCalculation();
}
```

---

## Resources

### Official
- [Riverpod Documentation](https://riverpod.dev/)
- [Riverpod Examples](https://github.com/rrousselGit/riverpod/tree/master/examples)
- [API Reference](https://pub.dev/documentation/riverpod/latest/)

### Community
- [Riverpod Discord](https://discord.gg/BSt2B39J6n)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/riverpod)
- [Reddit r/FlutterDev](https://reddit.com/r/FlutterDev)

### Packages
- [riverpod](https://pub.dev/packages/riverpod)
- [flutter_riverpod](https://pub.dev/packages/flutter_riverpod)
- [riverpod_annotation](https://pub.dev/packages/riverpod_annotation)
- [riverpod_generator](https://pub.dev/packages/riverpod_generator)

---

**Last Updated:** January 2026
**Riverpod Version:** 3.0+ / 2.5+
**Dart Version:** 3.3+

## Key Takeaways

### ✅ Modern Patterns (2026):
- Use `@riverpod` annotation with code generation
- Use `AsyncNotifier` for async state
- Use `AsyncLoading()` for loading states
- Use Dart 3 `switch` pattern matching
- Use `ref.watch()` for reactive dependencies
- Use `ref.select()` for granular updates

### ❌ Deprecated Patterns:
- Manual provider definitions (use @riverpod)
- `StateNotifier` (use Notifier/AsyncNotifier)
- `AsyncValue.loading()` (use AsyncLoading())
- `.whenOrNull()` without null checks
