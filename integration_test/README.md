# Integration Tests

This directory contains integration tests for the SoloAdventurer application. Integration tests verify that different parts of the application work together correctly, including UI interactions, state management, and data flow.

## Test Structure

```
integration_test/
├── features/              # Feature-specific integration tests
│   ├── auth/             # Authentication flow tests
│   ├── safety/           # Safety features tests
│   └── offline/          # Offline-first functionality tests
├── test_config.dart      # Centralized test configuration
├── test_helpers.dart     # Common test utilities
└── README.md            # This file
```

## Test Files

| Test File | Description |
|-----------|-------------|
| `auth_flow_test.dart` | Complete authentication flows including signup, login, and profile creation |
| `safety_flow_test.dart` | Safety features: trusted contacts, check-ins, SOS, and location sharing |
| `offline_first_flow_test.dart` | Offline-first functionality with sync and conflict resolution |
| `operation_queue_test.dart` | Operation queue with prioritization and retry logic |
| `token_manager_integration_test.dart` | Token lifecycle management with AWS Cognito |

## Running Tests

### Run All Integration Tests

```bash
flutter test integration_test
```

### Run Specific Test File

```bash
flutter test integration_test/features/auth/auth_flow_test.dart
```

### Run on Specific Device

```bash
# On Android
flutter test integration_test --device-id=<device-id>

# On iOS
flutter test integration_test --device-id=<device-id>

# On Chrome (web)
flutter test integration_test -d chrome
```

### Run with Verbose Logging

```bash
# Enable verbose test output
flutter test integration_test --dart-define=TEST_VERBOSE_LOGGING=true
```

## Test Configuration

Tests can be configured using environment variables or the `TestConfig` class:

```dart
import 'test_config.dart';

// Use the configured values
final baseUrl = TestConfig.apiBaseUrl;
final email = TestConfig.testEmail;
```

### Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `TEST_API_BASE_URL` | API base URL for tests | `http://localhost:3000` |
| `TEST_USER_EMAIL` | Test user email | `test@soloadventurer.local` |
| `TEST_USER_PASSWORD` | Test user password | `TestPassword123!` |
| `TEST_VERBOSE_LOGGING` | Enable verbose logging | `false` |
| `TEST_SKIP_NETWORK` | Skip network-dependent tests | `false` |
| `TEST_USE_MOCK_DATA` | Use mock data instead of real API | `false` |

Example usage:

```bash
flutter test integration_test --dart-define=TEST_API_BASE_URL=https://api-staging.example.com
```

## Test Helpers

The `test_helpers.dart` file provides common utilities for writing tests:

```dart
import 'package:flutter_test/flutter_test.dart';
import 'test_helpers.dart';

testWidgets('example test', (WidgetTester tester) async {
  // Use helper methods
  await TestHelpers.enterText(
    tester,
    find.byKey('email_field'),
    TestConfig.testEmail,
  );

  await TestHelpers.tap(
    tester,
    find.text('Login'),
  );

  // Wait for specific conditions
  await TestHelpers.waitFor(
    tester,
    find.text('Welcome'),
  );

  // Assert with better error messages
  TestHelpers.expectVisible(find.text('Welcome'));
});
```

### Common Test Helper Methods

| Method | Description |
|--------|-------------|
| `enterText()` | Enters text into a field with optional clearing |
| `tap()` | Taps a widget with proper delay |
| `waitFor()` | Waits for a widget to appear |
| `waitUntilGone()` | Waits for a widget to disappear |
| `scrollUntilVisible()` | Scrolls until a widget is found |
| `expectVisible()` | Asserts a widget is visible |
| `expectText()` | Asserts text exists/doesn't exist |
| `settle()` | Waits for all animations and async operations |

## Writing New Integration Tests

### Template for New Tests

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:soloadventurer/app/app.dart';
import 'test_helpers.dart';
import 'test_config.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Feature Name Tests', () {
    testWidgets('should do something', (WidgetTester tester) async {
      // Arrange
      TestHelpers.logSection('Test Setup');

      // Build the app
      await tester.pumpWidget(MyApp());
      await tester.pumpAndSettle();

      // Act
      await TestHelpers.tap(
        tester,
        find.text('Button'),
      );

      await TestHelpers.waitFor(
        tester,
        find.text('Result'),
      );

      // Assert
      TestHelpers.expectVisible(find.text('Result'));
    });
  });
}
```

## Best Practices

### 1. Use Test Helpers Instead of Fixed Delays

❌ **Bad:**
```dart
await tester.pump(const Duration(seconds: 2));
```

✅ **Good:**
```dart
await TestHelpers.waitFor(
  tester,
  find.text('Expected Text'),
);
```

### 2. Use Descriptive Test Names

❌ **Bad:**
```dart
testWidgets('test1', (tester) async { ... });
```

✅ **Good:**
```dart
testWidgets('should display error message when login fails', (tester) async { ... });
```

### 3. Use Group to Organize Related Tests

```dart
group('Authentication Flow', () {
  group('Login', () {
    testWidgets('should login with valid credentials', ...);
    testWidgets('should show error with invalid credentials', ...);
  });

  group('Signup', () {
    testWidgets('should create new account', ...);
    testWidgets('should validate email format', ...);
  });
});
```

### 4. Clean Up State Between Tests

```dart
setUp(() async {
  // Clear any existing state
  await SharedPreferences.getInstance().then((prefs) => prefs.clear());
});

tearDown(() async {
  // Clean up after test
  await tester.pumpAndSettle();
});
```

### 5. Use TestConfig for Test Data

```dart
// Use the test email generator
final email = TestConfig.generateTestEmail();

// Use the random password generator
final password = TestHelpers.randomPassword();
```

## Debugging Tests

### Enable Verbose Logging

```dart
void main() {
  // This will enable print statements in tests
  TestConfig.verboseLogging = true;

  // Or use environment variable
  // flutter test --dart-define=TEST_VERBOSE_LOGGING=true
}
```

### Take Screenshots on Failure

```dart
testWidgets('example', (tester) async {
  try {
    // Test code here
  } catch (e) {
    // Take screenshot for debugging
    await binding.takeScreenshot('test_failure');
    rethrow;
  }
});
```

### Print Widget Tree

```dart
// Print the current widget tree for debugging
print(tester.widgetList(find.byType(MaterialApp)));
```

## Continuous Integration

### GitHub Actions Example

```yaml
name: Integration Tests

on: [push, pull_request]

jobs:
  test:
    runs-on: macos-latest

    steps:
      - uses: actions/checkout@v3

      - uses: subosito/flutter-action@v2
        with:
          flutter-version: '3.32.5'

      - name: Run Integration Tests
        run: |
          flutter test integration_test
```

## Troubleshooting

### Tests Fail with "Timeout"

- Increase timeout in `TestConfig.maxWaitTime`
- Check for infinite loops or pending futures
- Use `waitFor()` instead of `pumpAndSettle()`

### Tests Are Flaky

- Use `TestHelpers.retry()` for flaky tests
- Ensure proper cleanup between tests
- Avoid hardcoded delays

### Widget Not Found

- Use `find.byKey()` instead of text finders for dynamic content
- Check if widget is offstage: `find.byType(Widget, skipOffstage: false)`
- Use `scrollUntilVisible()` for scrollable lists

## Coverage

To generate test coverage reports:

```bash
# Run tests with coverage
flutter test --coverage integration_test

# Generate HTML report (requires genhtml)
genhtml coverage/lcov.info -o coverage/html

# Open the report
open coverage/html/index.html
```

## Additional Resources

- [Flutter Testing Documentation](https://flutter.dev/docs/cookbook/testing/integration)
- [Widget Testing Cookbook](https://flutter.dev/docs/cookbook/testing/widget/introduction)
- [integration_test Package](https://pub.dev/packages/integration_test)
