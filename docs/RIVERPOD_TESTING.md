# Riverpod Testing Strategy

## Overview

This document outlines the strategy and best practices for testing Riverpod providers in the SoloAdventurer application. Riverpod is our primary state management solution, and proper testing is essential to ensure reliability and maintainability.

## Testing Principles

1. **Isolation**: Test providers in isolation from their dependencies
2. **Mocking**: Use mocks for dependencies to control test conditions
3. **Coverage**: Test all state transitions and edge cases
4. **Readability**: Write clear, concise tests that document provider behavior

## Testing Infrastructure

### Test Utilities

We've created several utilities to simplify Riverpod testing:

```dart
// test/utils/provider_container.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Creates a [ProviderContainer] with the given overrides for testing
ProviderContainer createContainer({
  List<Override> overrides = const [],
}) {
  final container = ProviderContainer(
    overrides: overrides,
  );

  // Add listener to help with debugging
  container.listen(
    provider,
    (previous, next) {
      // This helps with debugging
      print('Provider $provider changed from $previous to $next');
    },
    fireImmediately: false,
  );

  return container;
}

/// Disposes a [ProviderContainer] after tests
void disposeContainer(ProviderContainer container) {
  container.dispose();
}
```

### Mock Repositories

We use Mockito to create mock repositories for testing:

```dart
// test/mocks/mock_auth_repository.dart
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';
import 'package:soloadventurer/features/auth/domain/repositories/auth_repository.dart';

@GenerateMocks([AuthRepository])
void main() {}
```

## Testing Strategies

### 1. Testing StateNotifierProvider

For testing `StateNotifierProvider`, we focus on:

- Initial state
- State transitions
- Error handling

```dart
// Example test for AuthNotifier
void main() {
  late MockAuthRepository mockAuthRepository;
  late ProviderContainer container;

  setUp(() {
    mockAuthRepository = MockAuthRepository();
    container = createContainer(
      overrides: [
        authRepositoryProvider.overrideWithValue(mockAuthRepository),
      ],
    );
  });

  tearDown(() {
    disposeContainer(container);
  });

  test('initial state should be unauthenticated', () {
    final authState = container.read(authProvider);

    expect(authState.isAuthenticated, false);
    expect(authState.user, null);
    expect(authState.isLoading, false);
    expect(authState.error, null);
  });

  test('signIn should update state to authenticated on success', () async {
    // Arrange
    when(mockAuthRepository.signInWithEmailAndPassword(
      email: 'test@example.com',
      password: 'password',
    )).thenAnswer((_) async => mockUser);

    // Act
    await container.read(authProvider.notifier).signIn(
      email: 'test@example.com',
      password: 'password',
    );

    // Assert
    final authState = container.read(authProvider);
    expect(authState.isAuthenticated, true);
    expect(authState.user, mockUser);
    expect(authState.isLoading, false);
    expect(authState.error, null);
  });

  test('signIn should update state to error on failure', () async {
    // Arrange
    when(mockAuthRepository.signInWithEmailAndPassword(
      email: 'test@example.com',
      password: 'password',
    )).thenThrow(Exception('Invalid credentials'));

    // Act
    await container.read(authProvider.notifier).signIn(
      email: 'test@example.com',
      password: 'password',
    );

    // Assert
    final authState = container.read(authProvider);
    expect(authState.isAuthenticated, false);
    expect(authState.user, null);
    expect(authState.isLoading, false);
    expect(authState.error, isNotNull);
  });
}
```

### 2. Testing FutureProvider

For testing `FutureProvider`, we focus on:

- Loading state
- Data state
- Error state

```dart
// Example test for userProfileProvider
void main() {
  late MockUserRepository mockUserRepository;
  late ProviderContainer container;

  setUp(() {
    mockUserRepository = MockUserRepository();
    container = createContainer(
      overrides: [
        userRepositoryProvider.overrideWithValue(mockUserRepository),
      ],
    );
  });

  tearDown(() {
    disposeContainer(container);
  });

  test('should return loading state initially', () {
    when(mockUserRepository.getUserProfile())
        .thenAnswer((_) async => mockUser);

    final userProfileState = container.read(userProfileProvider);

    expect(userProfileState, isA<AsyncLoading<User>>());
  });

  test('should return data state when repository returns data', () async {
    when(mockUserRepository.getUserProfile())
        .thenAnswer((_) async => mockUser);

    // Wait for the provider to complete
    await container.read(userProfileProvider.future);

    final userProfileState = container.read(userProfileProvider);

    expect(userProfileState, isA<AsyncData<User>>());
    expect(userProfileState.value, mockUser);
  });

  test('should return error state when repository throws', () async {
    when(mockUserRepository.getUserProfile())
        .thenThrow(Exception('Failed to load profile'));

    // Wait for the provider to complete
    await expectLater(
      container.read(userProfileProvider.future),
      throwsException,
    );

    final userProfileState = container.read(userProfileProvider);

    expect(userProfileState, isA<AsyncError<User>>());
    expect(userProfileState.error, isA<Exception>());
  });
}
```

### 3. Testing Provider Dependencies

For testing providers that depend on other providers:

```dart
// Example test for a provider with dependencies
void main() {
  late ProviderContainer container;

  setUp(() {
    container = createContainer(
      overrides: [
        // Override dependencies
        userProvider.overrideWithValue(mockUser),
        settingsProvider.overrideWithValue(mockSettings),
      ],
    );
  });

  tearDown(() {
    disposeContainer(container);
  });

  test('userSettingsProvider should combine user and settings', () {
    final userSettings = container.read(userSettingsProvider);

    expect(userSettings.userId, mockUser.id);
    expect(userSettings.theme, mockSettings.theme);
  });
}
```

## Integration Testing with Riverpod

For testing the integration of providers with UI:

```dart
// Example widget test with Riverpod
void main() {
  testWidgets('LoginScreen should show error on failed login', (tester) async {
    // Arrange
    final mockAuthRepository = MockAuthRepository();
    when(mockAuthRepository.signInWithEmailAndPassword(
      email: 'test@example.com',
      password: 'password',
    )).thenThrow(Exception('Invalid credentials'));

    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          authRepositoryProvider.overrideWithValue(mockAuthRepository),
        ],
        child: const MaterialApp(
          home: LoginScreen(),
        ),
      ),
    );

    // Act
    await tester.enterText(find.byType(EmailField), 'test@example.com');
    await tester.enterText(find.byType(PasswordField), 'password');
    await tester.tap(find.byType(ElevatedButton));
    await tester.pump();
    await tester.pump(const Duration(seconds: 1)); // Wait for async operation

    // Assert
    expect(find.text('Invalid credentials'), findsOneWidget);
  });
}
```

## Best Practices

1. **Keep Tests Focused**: Test one aspect of a provider at a time
2. **Use Descriptive Test Names**: Clearly describe what you're testing
3. **Test Edge Cases**: Test loading, error, and empty states
4. **Avoid Testing Implementation Details**: Focus on behavior, not implementation
5. **Use Test Utilities**: Leverage the test utilities for consistent testing
6. **Clean Up**: Always dispose containers in tearDown

## Common Pitfalls

1. **Not Mocking Dependencies**: Ensure all dependencies are properly mocked
2. **Not Waiting for Async Operations**: Use `await` for async provider operations
3. **Testing Too Much**: Focus on provider behavior, not implementation details
4. **Not Testing Error Cases**: Always test error handling
5. **Not Disposing Containers**: Always dispose containers in tearDown

## Conclusion

This testing strategy provides a comprehensive approach to testing Riverpod providers in the SoloAdventurer application. By following these guidelines, we can ensure that our state management is reliable, maintainable, and well-documented.
