# Testing Patterns Guide

This guide documents common testing patterns for Riverpod providers in the SoloAdventurer app.

## Table of Contents

1. [Introduction](#introduction)
2. [Common Testing Patterns](#common-testing-patterns)
3. [Provider Testing Patterns](#provider-testing-patterns)
4. [Integration Testing Patterns](#integration-testing-patterns)
5. [UI Testing Patterns](#ui-testing-patterns)
6. [Best Practices](#best-practices)

## Introduction

Testing is an essential part of the development process. This guide provides patterns and examples for testing different aspects of the SoloAdventurer app, with a focus on Riverpod providers.

## Common Testing Patterns

### Arrange-Act-Assert (AAA)

The AAA pattern is a common way to structure tests:

```dart
test('counter should increment', () {
  // Arrange
  final container = createContainer();

  // Act
  container.read(counterProvider.notifier).increment();

  // Assert
  expect(container.read(counterProvider), 1);
});
```

### Given-When-Then (GWT)

The GWT pattern is similar to AAA but with different terminology:

```dart
test('counter should increment', () {
  // Given
  final container = createContainer();

  // When
  container.read(counterProvider.notifier).increment();

  // Then
  expect(container.read(counterProvider), 1);
});
```

### Setup-Exercise-Verify-Teardown (SEVT)

The SEVT pattern adds a teardown step:

```dart
test('counter should increment', () {
  // Setup
  final container = createContainer();

  // Exercise
  container.read(counterProvider.notifier).increment();

  // Verify
  expect(container.read(counterProvider), 1);

  // Teardown
  container.dispose();
});
```

## Provider Testing Patterns

### Testing StateNotifierProvider

```dart
test('auth provider should sign in', () async {
  // Arrange
  final mockAuthService = MockAuthService();
  mockAuthService.setupSuccessfulSignIn('testuser');

  final container = createContainer(
    overrides: [
      authServiceProvider.overrideWithValue(mockAuthService),
    ],
  );

  // Act
  await container.read(authProvider.notifier).signIn(
    username: 'testuser',
    password: 'password',
  );

  // Assert
  final authState = container.read(authProvider);
  expect(authState.state, AuthState.authenticated);
  expect(authState.username, 'testuser');
});
```

### Testing FutureProvider

```dart
test('user profile provider should load user', () async {
  // Arrange
  final mockUserRepository = MockUserRepository();
  when(() => mockUserRepository.getUserProfile('user-1'))
      .thenAnswer((_) async => testUser);

  final container = createContainer(
    overrides: [
      userRepositoryProvider.overrideWithValue(mockUserRepository),
    ],
  );

  // Act - just reading the provider triggers the future
  final userProfileAsync = container.read(userProfileProvider('user-1'));

  // Wait for the future to complete
  await container.read(userProfileProvider('user-1').future);

  // Assert
  final userProfileAsyncAfter = container.read(userProfileProvider('user-1'));
  expect(userProfileAsyncAfter, isA<AsyncData<User>>());
  expect(userProfileAsyncAfter.value, testUser);
});
```

### Testing StreamProvider

```dart
test('notifications provider should emit notifications', () async {
  // Arrange
  final mockNotificationRepository = MockNotificationRepository();
  when(() => mockNotificationRepository.getNotifications())
      .thenAnswer((_) => Stream.fromIterable([
            [Notification(id: '1', message: 'Test')],
            [
              Notification(id: '1', message: 'Test'),
              Notification(id: '2', message: 'Test 2')
            ],
          ]));

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
  expect(notificationsAsyncAfter, isA<AsyncData<List<Notification>>>());
  expect(notificationsAsyncAfter.value?.length, 2);
});
```

### Testing Provider Dependencies

```dart
test('filtered trips provider should filter trips', () {
  // Arrange
  final allTrips = [
    Trip(id: '1', status: TripStatus.completed),
    Trip(id: '2', status: TripStatus.planning),
    Trip(id: '3', status: TripStatus.inProgress),
  ];

  final container = createContainer(
    overrides: [
      allTripsProvider.overrideWithValue(allTrips),
    ],
  );

  // Act
  final completedTrips = container.read(filteredTripsProvider(TripStatus.completed));

  // Assert
  expect(completedTrips.length, 1);
  expect(completedTrips.first.id, '1');
});
```

## Integration Testing Patterns

### Testing Provider Chains

```dart
test('auth and user profile integration', () async {
  // Arrange
  final mockAuthService = MockAuthService();
  final mockUserRepository = MockUserRepository();

  mockAuthService.setupSuccessfulSignIn('testuser');
  when(() => mockUserRepository.getUserProfile(any()))
      .thenAnswer((_) async => testUser);

  final container = createContainer(
    overrides: [
      authServiceProvider.overrideWithValue(mockAuthService),
      userRepositoryProvider.overrideWithValue(mockUserRepository),
    ],
  );

  // Act
  await container.read(authProvider.notifier).signIn(
    username: 'testuser',
    password: 'password',
  );

  // Assert
  final authState = container.read(authProvider);
  expect(authState.state, AuthState.authenticated);

  // Wait for the user profile provider to complete
  await container.read(currentUserProfileProvider.future);

  // Verify user profile state
  final userProfileState = container.read(currentUserProfileProvider);
  expect(userProfileState.value, testUser);
});
```

### Testing State Propagation

```dart
test('trip update should propagate to filtered trips', () {
  // Arrange
  final allTrips = [
    Trip(id: '1', status: TripStatus.planning),
    Trip(id: '2', status: TripStatus.planning),
  ];

  final container = createContainer(
    overrides: [
      allTripsProvider.overrideWithValue(allTrips),
    ],
  );

  // Initial state
  final initialFilteredTrips = container.read(filteredTripsProvider(TripStatus.planning));
  expect(initialFilteredTrips.length, 2);

  // Act - update a trip
  final updatedTrips = [
    Trip(id: '1', status: TripStatus.inProgress),
    Trip(id: '2', status: TripStatus.planning),
  ];

  container.updateOverrides([
    allTripsProvider.overrideWithValue(updatedTrips),
  ]);

  // Assert
  final planningTrips = container.read(filteredTripsProvider(TripStatus.planning));
  expect(planningTrips.length, 1);
  expect(planningTrips.first.id, '2');

  final inProgressTrips = container.read(filteredTripsProvider(TripStatus.inProgress));
  expect(inProgressTrips.length, 1);
  expect(inProgressTrips.first.id, '1');
});
```

## UI Testing Patterns

### Testing Widgets with Providers

```dart
testWidgets('LoginScreen should show error on failed login', (tester) async {
  // Arrange
  final mockAuthService = MockAuthService();
  mockAuthService.setupFailedSignIn('Invalid credentials');

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        authServiceProvider.overrideWithValue(mockAuthService),
      ],
      child: const MaterialApp(
        home: LoginScreen(),
      ),
    ),
  );

  // Act
  await tester.enterText(find.byType(TextField).at(0), 'testuser');
  await tester.enterText(find.byType(TextField).at(1), 'wrong-password');
  await tester.tap(find.byType(ElevatedButton));
  await tester.pump();
  await tester.pump(const Duration(seconds: 1)); // Wait for async operation

  // Assert
  expect(find.text('Invalid credentials'), findsOneWidget);
});
```

### Testing Loading States

```dart
testWidgets('ProfileScreen should show loading indicator', (tester) async {
  // Arrange
  final mockUserRepository = MockUserRepository();

  // Set up a delayed response to ensure we see the loading state
  when(() => mockUserRepository.getUserProfile(any()))
      .thenAnswer((_) async {
        await Future.delayed(const Duration(seconds: 1));
        return testUser;
      });

  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        userRepositoryProvider.overrideWithValue(mockUserRepository),
        authStateProvider.overrideWithValue(AuthState(userId: 'test-user-id')),
      ],
      child: const MaterialApp(
        home: ProfileScreen(),
      ),
    ),
  );

  // Assert - should show loading indicator initially
  expect(find.byType(CircularProgressIndicator), findsOneWidget);

  // Act - wait for the data to load
  await tester.pump(const Duration(seconds: 2));

  // Assert - should show user data
  expect(find.text(testUser.username), findsOneWidget);
  expect(find.byType(CircularProgressIndicator), findsNothing);
});
```

## Best Practices

### 1. Keep Tests Focused

Each test should focus on testing one specific behavior or scenario. This makes tests easier to understand and maintain.

```dart
// Good
test('should return loading state initially', () {
  // Test code
});

test('should return data state when repository returns data', () {
  // Test code
});

// Bad
test('should handle various states', () {
  // Test loading state
  // Test data state
  // Test error state
});
```

### 2. Use Descriptive Test Names

Test names should clearly describe what is being tested and the expected outcome.

```dart
// Good
test('should sign in user when credentials are valid', () {
  // Test code
});

// Bad
test('sign in test', () {
  // Test code
});
```

### 3. Avoid Test Interdependence

Tests should not depend on the state or outcome of other tests. Each test should be able to run independently.

```dart
// Good
test('test A', () {
  final container = createContainer();
  // Test code
});

test('test B', () {
  final container = createContainer();
  // Test code
});

// Bad
late ProviderContainer container;

setUp(() {
  container = createContainer();
});

test('test A', () {
  // Modifies container state
});

test('test B', () {
  // Depends on state from test A
});
```

### 4. Mock External Dependencies

Always mock external dependencies like repositories, services, and APIs to ensure tests are isolated and deterministic.

```dart
test('should load user profile', () async {
  final mockUserRepository = MockUserRepository();
  when(() => mockUserRepository.getUserProfile(any()))
      .thenAnswer((_) async => testUser);

  final container = createContainer(
    overrides: [
      userRepositoryProvider.overrideWithValue(mockUserRepository),
    ],
  );

  // Test code
});
```

### 5. Test Edge Cases

Don't just test the happy path. Test edge cases, error conditions, and boundary conditions.

```dart
test('should handle empty list', () {
  // Test code
});

test('should handle null values', () {
  // Test code
});

test('should handle error responses', () {
  // Test code
});
```

### 6. Use Test Helpers

Use test helpers to reduce boilerplate code and make tests more readable.

```dart
// Without helpers
test('should load user profile', () async {
  final mockUserRepository = MockUserRepository();
  when(() => mockUserRepository.getUserProfile(any()))
      .thenAnswer((_) async => testUser);

  final container = createContainer(
    overrides: [
      userRepositoryProvider.overrideWithValue(mockUserRepository),
    ],
  );

  // Test code
});

// With helpers
testFutureProvider<User>(
  provider: userProfileProvider('user-1'),
  buildMocks: [
    () {
      when(() => mockUserRepository.getUserProfile(any()))
          .thenAnswer((_) async => testUser);
    },
  ],
  testCases: [
    FutureProviderTestCase(
      description: 'should load user profile',
      action: (container) async {},
      expectedData: testUser,
    ),
  ],
);
```

### 7. Clean Up Resources

Always clean up resources after tests to avoid memory leaks and interference with other tests.

```dart
test('should load user profile', () async {
  final container = createContainer();

  // Test code

  // Clean up
  addTearDown(container.dispose);
});
```
