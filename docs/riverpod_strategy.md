# Riverpod Strategy for SoloAdventurer

This document outlines our approach to using Riverpod for state management in the SoloAdventurer app, including provider organization, testing strategy, and best practices.

## Provider Organization

### Directory Structure

We organize providers by feature and type:

```
lib/
├─ providers/
│  ├─ core/
│  │  ├─ app_providers.dart      // App-wide providers
│  ├─ features/
│  │  ├─ auth/
│  │  │  ├─ auth_provider.dart   // Authentication providers
│  │  ├─ profile/
│  │  │  ├─ profile_provider.dart // Profile-related providers
```

### Provider Types

We categorize providers into three main types:

1. **Service Providers**: External dependencies and services

   ```dart
   final authServiceProvider = Provider<AuthService>((ref) {
     return AuthService();
   });
   ```

2. **State Providers**: Business logic and UI state

   ```dart
   final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
     return AuthNotifier(ref.watch(authServiceProvider));
   });
   ```

3. **Utility Providers**: Formatting, calculations, etc.
   ```dart
   final dateFormatterProvider = Provider<DateFormatter>((ref) {
     return DateFormatter();
   });
   ```

### Naming Conventions

- Service providers: `{service}Provider`
- State providers: `{feature}Provider`
- Utility providers: `{utility}Provider`

## Testing Strategy

### Multi-Layered Testing Approach

We use a multi-layered approach to testing Riverpod:

1. **Mock Screen Tests**: Simplified tests using mock implementations of screens

   - Advantages: Stable, focused, fast
   - Use cases: Testing form validation, basic UI interactions

2. **Actual Screen Tests**: Tests using the actual screen implementations with mocked providers

   - Advantages: Tests real implementation, catches integration issues
   - Use cases: Testing provider interactions, complex workflows

3. **Provider Unit Tests**: Tests for providers in isolation

   - Advantages: Fast, focused on business logic
   - Use cases: Testing state transitions, async operations

4. **Provider Integration Tests**: Tests for provider interactions
   - Advantages: Tests provider dependencies and interactions
   - Use cases: Testing complex provider chains

### Testing Utilities

We use the following utilities to simplify testing:

```dart
// lib/test_utils/provider_test_utils.dart

/// Helper to create a testable widget with overridden providers
Widget createTestableApp({
  required Widget child,
  List<Override> overrides = const [],
  List<NavigatorObserver> navigatorObservers = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: child,
      navigatorObservers: navigatorObservers,
    ),
  );
}

/// Setup common mocks for authentication tests
class AuthTestHelper {
  late MockAuthService authService;
  late MockNavigatorObserver navigatorObserver;

  AuthTestHelper() {
    authService = MockAuthService();
    navigatorObserver = MockNavigatorObserver();

    // Register fallback values
    registerFallbackValue(MockRoute());
  }

  /// Get common provider overrides for auth tests
  List<Override> get authOverrides => [
    authServiceProvider.overrideWithValue(authService)
  ];
}
```

### Provider Unit Testing

```dart
// Example of provider unit testing
test('AuthNotifier changes state to loading when signing in', () {
  final container = ProviderContainer(
    overrides: [
      authServiceProvider.overrideWithValue(mockAuthService),
    ],
  );
  addTearDown(container.dispose);

  final notifier = container.read(authProvider.notifier);

  expect(container.read(authProvider), isA<AuthInitial>());

  notifier.signIn('email', 'password');

  expect(container.read(authProvider), isA<AuthLoading>());
});
```

### Widget Testing with Providers

```dart
// Example of widget testing with providers
testWidgets('SignUpScreen validates email format', (WidgetTester tester) async {
  final helper = AuthTestHelper();

  await tester.pumpWidget(
    createTestableApp(
      child: const SignUpScreen(),
      overrides: helper.authOverrides,
      navigatorObservers: [helper.navigatorObserver],
    ),
  );

  // Test interactions
  await tester.enterText(find.byType(TextFormField).at(0), 'invalid-email');
  await tester.tap(find.text('Sign Up'));
  await tester.pump();

  expect(find.text('Please enter a valid email'), findsOneWidget);
});
```

## Best Practices

### Provider Creation

1. **Keep providers focused**: Each provider should have a single responsibility
2. **Use dependency injection**: Inject dependencies through `ref.watch`
3. **Consider provider lifecycle**: Use `.autoDispose` for providers that should be disposed when no longer used

```dart
// Good: Focused provider with dependency injection
final userProfileProvider = FutureProvider.autoDispose.family<UserProfile, String>((ref, userId) async {
  final repository = ref.watch(userRepositoryProvider);
  return repository.getUserProfile(userId);
});

// Bad: Provider doing too much
final userProvider = Provider((ref) {
  final user = User();
  user.fetchProfile(); // Direct API call
  return user;
});
```

### State Management

1. **Use appropriate provider types**:

   - `Provider` for simple values
   - `StateProvider` for simple state
   - `StateNotifierProvider` for complex state
   - `FutureProvider` for async data
   - `StreamProvider` for streams

2. **Handle loading and error states**:
   - Use `AsyncValue` for async operations
   - Handle loading, data, and error states in the UI

```dart
// Good: Using AsyncValue for state management
class AuthNotifier extends StateNotifier<AsyncValue<User?>> {
  AuthNotifier(this._authService) : super(const AsyncValue.data(null));

  Future<void> signIn(String email, String password) async {
    state = const AsyncValue.loading();
    state = await AsyncValue.guard(() => _authService.signIn(email, password));
  }
}

// In UI
ref.watch(authProvider).when(
  data: (user) => user != null ? HomeScreen() : LoginScreen(),
  loading: () => LoadingScreen(),
  error: (error, stack) => ErrorScreen(error),
);
```

### Performance Optimization

1. **Minimize rebuilds**:
   - Use `select` to watch specific parts of state
   - Split large providers into smaller, focused providers

```dart
// Good: Using select to minimize rebuilds
final userName = ref.watch(userProvider.select((user) => user.name));

// Bad: Watching entire user object when only name is needed
final user = ref.watch(userProvider);
final userName = user.name;
```

2. **Use caching effectively**:
   - Use `.family` providers with caching for parameterized data
   - Consider custom caching for expensive operations

### Debugging

1. **Add provider observers**:
   - Use `ProviderObserver` to log state changes
   - Add debug prints in development

```dart
// Provider observer for debugging
class LoggerProviderObserver extends ProviderObserver {
  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    debugPrint(
      '[${provider.name ?? provider.runtimeType}] value: $newValue',
    );
  }
}

// In main.dart
void main() {
  runApp(
    ProviderScope(
      observers: [LoggerProviderObserver()],
      child: MyApp(),
    ),
  );
}
```

## Migration Plan

1. **Phase 1**: Create testing utilities and documentation
2. **Phase 2**: Reorganize existing providers by feature
3. **Phase 3**: Add integration tests for actual screens
4. **Phase 4**: Implement provider observers for debugging

## Conclusion

Riverpod is the optimal state management solution for SoloAdventurer due to its flexibility, dependency injection capabilities, and performance characteristics. By following these patterns and best practices, we can leverage Riverpod's strengths while mitigating its challenges.
