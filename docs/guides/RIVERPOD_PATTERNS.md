# Riverpod Implementation Patterns

## Overview

This document outlines the standard patterns and best practices for Riverpod implementation in the SoloAdventurer app. These patterns ensure consistent state management, proper error handling, and maintainable code.

## Core Patterns

### 1. AsyncValue Usage

Always wrap async operations with AsyncValue for proper loading and error handling:

```dart
@riverpod
class UserProfile extends _$UserProfile {
  @override
  FutureOr<User> build(String userId) async {
    // AsyncValue is automatically handled by Riverpod
    return _userRepository.getUser(userId);
  }

  Future<void> updateProfile(UserUpdateData data) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final updatedUser = await _userRepository.updateUser(data);
      return updatedUser;
    });
  }
}
```

### 2. Error Handling

Use pattern matching for comprehensive error handling:

```dart
@riverpod
class ErrorHandler extends _$ErrorHandler {
  @override
  void build() {
    ref.listen(userProfileProvider, (previous, next) {
      next.whenOrNull(
        error: (error, stack) => _handleError(error, stack),
        data: (data) => _clearErrors(),
      );
    });
  }

  void _handleError(Object error, StackTrace stack) {
    switch (error) {
      case NetworkException():
        _showNetworkError();
      case ValidationException():
        _showValidationError();
      default:
        _showGenericError();
    }
  }
}
```

### 3. State Updates

Use immutable state updates:

```dart
@riverpod
class TodoList extends _$TodoList {
  @override
  List<Todo> build() => [];

  void addTodo(Todo todo) {
    state = [...state, todo];
  }

  void removeTodo(String id) {
    state = state.where((todo) => todo.id != id).toList();
  }

  void updateTodo(Todo updated) {
    state = state.map((todo) =>
      todo.id == updated.id ? updated : todo
    ).toList();
  }
}
```

## Provider Organization

### 1. Feature-based Providers

Organize providers by feature:

```dart
// auth_providers.dart
@riverpod
class Auth extends _$Auth {
  @override
  AsyncValue<AuthState> build() => const AsyncValue.data(AuthState.initial());
}

// profile_providers.dart
@riverpod
class Profile extends _$Profile {
  @override
  AsyncValue<ProfileState> build() => const AsyncValue.data(ProfileState.empty());
}
```

### 2. Provider Dependencies

Use ref.watch for reactive dependencies:

```dart
@riverpod
class FilteredTodos extends _$FilteredTodos {
  @override
  List<Todo> build() {
    final todos = ref.watch(todoListProvider);
    final filter = ref.watch(filterProvider);

    return switch (filter) {
      TodoFilter.all => todos,
      TodoFilter.completed => todos.where((todo) => todo.isCompleted).toList(),
      TodoFilter.active => todos.where((todo) => !todo.isCompleted).toList(),
    };
  }
}
```

### 3. Scoped Providers

Use provider scoping for localized state:

```dart
@riverpod
class TodoItemController extends _$TodoItemController {
  @override
  AsyncValue<void> build(String todoId) => const AsyncValue.data(null);

  Future<void> toggleComplete() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      final todo = await _repository.toggleTodo(todoId);
      ref.invalidate(todoListProvider);
      return null;
    });
  }
}
```

## Testing Patterns

### 1. Provider Testing

Test providers in isolation:

```dart
void main() {
  test('TodoList provider', () {
    final container = ProviderContainer();
    addTearDown(container.dispose);

    final todoList = container.read(todoListProvider.notifier);

    todoList.addTodo(Todo(id: '1', title: 'Test'));
    expect(container.read(todoListProvider).length, 1);

    todoList.removeTodo('1');
    expect(container.read(todoListProvider).length, 0);
  });
}
```

### 2. Mock Dependencies

Use overrides for testing:

```dart
void main() {
  test('Profile provider with mocked repository', () {
    final container = ProviderContainer(
      overrides: [
        profileRepositoryProvider.overrideWithValue(
          MockProfileRepository(),
        ),
      ],
    );

    expect(
      container.read(profileProvider),
      isA<AsyncData<Profile>>(),
    );
  });
}
```

### 3. Integration Testing

Test provider interactions:

```dart
void main() {
  testWidgets('Profile update flow', (tester) async {
    await tester.pumpWidget(
      ProviderScope(
        child: MaterialApp(
          home: ProfileScreen(),
        ),
      ),
    );

    // Verify initial state
    expect(find.text('John Doe'), findsOneWidget);

    // Trigger update
    await tester.tap(find.byType(EditButton));
    await tester.pumpAndSettle();

    // Verify updated state
    expect(find.text('Updated Name'), findsOneWidget);
  });
}
```

## State Persistence

### 1. Hydration

Persist and restore state:

```dart
@Riverpod(keepAlive: true)
class PersistedState extends _$PersistedState {
  @override
  Future<State> build() async {
    return _storage.getState() ?? State.initial();
  }

  Future<void> updateState(State newState) async {
    await _storage.saveState(newState);
    state = AsyncData(newState);
  }
}
```

### 2. Caching

Implement caching strategies:

```dart
@riverpod
class CachedData extends _$CachedData {
  @override
  Future<Data> build() async {
    final cached = await _cache.get('key');
    if (cached != null) return cached;

    final fresh = await _api.fetchData();
    await _cache.set('key', fresh);
    return fresh;
  }
}
```

## Performance Optimization

### 1. Selective Updates

Use select for granular updates:

```dart
class ProfileWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final name = ref.watch(
      profileProvider.select((profile) => profile.name)
    );
    return Text(name);
  }
}
```

### 2. Computed Properties

Cache computed values:

```dart
@riverpod
class ComputedValue extends _$ComputedValue {
  @override
  int build() {
    final items = ref.watch(itemsProvider);
    return items.fold(0, (sum, item) => sum + item.value);
  }
}
```

## Best Practices

1. **Always use AsyncValue for async operations**
2. **Implement proper error handling**
3. **Keep providers focused and single-purpose**
4. **Use proper scoping for state management**
5. **Implement comprehensive testing**
6. **Document provider purposes and dependencies**
7. **Use proper state persistence when needed**
8. **Optimize for performance with selective updates**

## Common Pitfalls to Avoid

1. **Don't use global state when scoped state is sufficient**
2. **Avoid mixing different state management solutions**
3. **Don't skip error handling in AsyncValue operations**
4. **Avoid unnecessary provider dependencies**
5. **Don't forget to dispose of resources**

## References

- [Riverpod Documentation](https://riverpod.dev)
- [Flutter State Management](https://flutter.dev/docs/development/data-and-backend/state-mgmt/options)
- [Riverpod Testing Guide](https://riverpod.dev/docs/essentials/testing)
- [AsyncValue Documentation](https://pub.dev/documentation/riverpod/latest/riverpod/AsyncValue-class.html)

## Error Handling Patterns

### Inline Error Display with SnackBar

```dart
class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Listen for state changes and show errors
    ref.listen(myStateProvider, (previous, next) {
      if (next.error?.isNotEmpty == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(next.error!),
            backgroundColor: Theme.of(context).colorScheme.error,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    });

    return Scaffold(
      // ... rest of the widget
    );
  }
}
```

### State Error Handling

```dart
@riverpod
class MyNotifier extends _$MyNotifier {
  @override
  AsyncValue<MyState> build() => const AsyncValue.data(MyState.initial());

  Future<void> performAction() async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() async {
      // Perform the action
      return newState;
    });
  }
}
```

### Loading State Management

```dart
Widget build(BuildContext context, WidgetRef ref) {
  final state = ref.watch(myStateProvider);

  return state.when(
    data: (data) => MyContent(data: data),
    loading: () => const Center(child: CircularProgressIndicator()),
    error: (error, stack) => ErrorDisplay(error: error),
  );
}
```

### Best Practices

1. Error Display

   - Use SnackBar for transient errors
   - Show inline errors for form validation
   - Maintain context during error recovery

2. State Management

   - Use AsyncValue for consistent error handling
   - Handle loading states explicitly
   - Provide clear error messages

3. Error Recovery
   - Implement retry mechanisms where appropriate
   - Clear error state after recovery
   - Maintain user progress where possible
