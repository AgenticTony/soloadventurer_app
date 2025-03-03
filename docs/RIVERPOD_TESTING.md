# Riverpod Testing Guide

This guide explains how to test Riverpod providers in the SoloAdventurer app.

## Table of Contents

1. [Introduction](#introduction)
2. [Testing Utilities](#testing-utilities)
3. [Provider Testing](#provider-testing)
4. [Mock Repositories and Services](#mock-repositories-and-services)
5. [Test Data](#test-data)
6. [Best Practices](#best-practices)
7. [Troubleshooting](#troubleshooting)

## Introduction

Testing Riverpod providers is essential to ensure that our state management logic works correctly. This guide covers how to test different types of providers, including:

- `Provider`
- `StateProvider`
- `StateNotifierProvider`
- `FutureProvider`
- `StreamProvider`

## Testing Utilities

We've created several utilities to make testing Riverpod providers easier:

### Provider Container Utilities

The `provider_container_utils.dart` file contains utilities for creating and testing provider containers:

```dart
// Create a provider container for testing
final container = createContainer(
  overrides: [
    myProvider.overrideWithValue(mockValue),
  ],
);

// Listen to state changes
final listener = container.listenToProvider(myProvider);

// Access the current state
final currentState = listener.lastValue;

// Access all state changes
final stateChanges = listener.values;
```

### Mock Generator

The `mock_generator.dart` file contains utilities for creating mocks:

```dart
// Create a mock provider
final mockProvider = mockProvider(myProvider, mockValue);

// Create a mock future provider
final mockFutureProvider = mockFutureProvider(myFutureProvider, mockValue);

// Create a mock state notifier provider
final mockStateNotifierProvider = mockStateNotifierProvider(
  myStateNotifierProvider,
  mockNotifier,
);
```

### Provider Test Helpers

The `provider_test_helpers.dart` file contains utilities for testing specific provider types:

```dart
// Test a state notifier provider
testStateNotifierProvider(
  provider: myStateNotifierProvider,
  buildMocks: [
    () => mockRepository(),
  ],
  testCases: [
    StateNotifierTestCase(
      description: 'should update state when action is called',
      action: (container) async {
        await container.read(myStateNotifierProvider.notifier).myAction();
      },
      expectedState: expectedState,
    ),
  ],
);

// Test a future provider
testFutureProvider(
  provider: myFutureProvider,
  buildMocks: [
    () => mockRepository(),
  ],
  testCases: [
    FutureProviderTestCase(
      description: 'should load data successfully',
      action: (container) async {},
      expectedData: expectedData,
    ),
  ],
);

// Test a stream provider
testStreamProvider(
  provider: myStreamProvider,
  buildMocks: [
    () => mockRepository(),
  ],
  testCases: [
    StreamProviderTestCase(
      description: 'should emit values',
      action: (container) async {},
      expectedData: expectedData,
    ),
  ],
);
```

## Provider Testing

### Testing StateNotifierProvider

```dart
test('counter should increment', () async {
  // Arrange
  final container = createContainer();

  // Act
  await container.read(counterProvider.notifier).increment();

  // Assert
  expect(container.read(counterProvider), 1);
});
```

### Testing FutureProvider

```dart
test('user provider should load user', () async {
  // Arrange
  final mockUserRepository = MockUserRepository();
  when(() => mockUserRepository.getUser()).thenAnswer(
    (_) async => User(id: '1', name: 'Test User'),
  );

  final container = createContainer(
    overrides: [
      userRepositoryProvider.overrideWithValue(mockUserRepository),
    ],
  );

  // Act - just reading the provider triggers the future
  final userAsync = container.read(userProvider);

  // Wait for the future to complete
  await Future.delayed(Duration.zero);

  // Assert
  final userAsyncAfter = container.read(userProvider);
  expect(userAsyncAfter.value?.name, 'Test User');
});
```

### Testing StreamProvider

```dart
test('notifications provider should emit notifications', () async {
  // Arrange
  final mockNotificationRepository = MockNotificationRepository();
  when(() => mockNotificationRepository.getNotifications()).thenAnswer(
    (_) => Stream.fromIterable([
      [Notification(id: '1', message: 'Test')],
      [Notification(id: '1', message: 'Test'), Notification(id: '2', message: 'Test 2')],
    ]),
  );

  final container = createContainer(
    overrides: [
      notificationRepositoryProvider.overrideWithValue(mockNotificationRepository),
    ],
  );

  // Act - just reading the provider triggers the stream
  final notificationsAsync = container.read(notificationsProvider);

  // Wait for the stream to emit values
  await Future.delayed(Duration(milliseconds: 10));

  // Assert
  final notificationsAsyncAfter = container.read(notificationsProvider);
  expect(notificationsAsyncAfter.value?.length, 2);
});
```

## Mock Repositories and Services

We've created mock implementations of our repositories and services to make testing easier:

### Auth Repository Mock

```dart
// Create a mock auth repository
final mockAuthRepository = MockAuthRepository();

// Set up the mock for a successful sign-in
mockAuthRepository.setupSuccessfulSignIn('testuser');

// Set up the mock for a failed sign-in
mockAuthRepository.setupFailedSignIn('Invalid credentials');
```

### API Service Mock

```dart
// Create a mock API service
final mockApiService = MockApiService();

// Set up the mock for a successful GET request
mockApiService.setupSuccessfulGet('/users', {'id': '1', 'name': 'Test User'});

// Set up the mock for a failed GET request
mockApiService.setupFailedGet('/users', 404, 'Not found');
```

## Test Data

We've created factory functions for test data to make testing easier:

```dart
// Create a test user
final user = TestData.createUser(
  id: '1',
  username: 'testuser',
  email: 'test@example.com',
);

// Create a test trip
final trip = TestData.createTrip(
  id: '1',
  userId: '1',
  title: 'Test Trip',
);

// Create test preferences
final preferences = TestData.createTravelPreference(
  userId: '1',
  preferredDestinations: ['Mountains', 'Beach'],
);
```

## Best Practices

1. **Use the provided utilities**: The utilities in `provider_container_utils.dart`, `mock_generator.dart`, and `provider_test_helpers.dart` make testing Riverpod providers easier.

2. **Mock dependencies**: Always mock dependencies like repositories and services to isolate the provider being tested.

3. **Test all state transitions**: Make sure to test all possible state transitions, including loading, success, and error states.

4. **Use descriptive test names**: Use descriptive test names that explain what the test is checking.

5. **Group related tests**: Use `group` to group related tests together.

6. **Test edge cases**: Make sure to test edge cases like empty lists, null values, and error conditions.

7. **Keep tests independent**: Each test should be independent of other tests. Don't rely on state from previous tests.

## Troubleshooting

### Common Issues

1. **Provider not found**: Make sure the provider is registered in the container.

2. **Mock not called**: Make sure the mock is set up correctly and the provider is using the mocked dependency.

3. **State not updated**: Make sure the provider is notifying listeners when the state changes.

4. **Test times out**: Make sure the provider is completing futures or emitting stream values.

### Debugging Tips

1. **Use `addTearDown`**: Use `addTearDown` to dispose resources after each test.

2. **Use `TestObserver`**: Use `TestObserver` to track state changes.

3. **Use `print`**: Use `print` to debug state changes during tests.

4. **Check mock setup**: Make sure mocks are set up correctly before the test runs.

5. **Check provider dependencies**: Make sure provider dependencies are overridden correctly.
