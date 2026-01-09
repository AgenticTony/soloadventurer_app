import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'test_config.dart';

/// Helper utilities for integration tests
///
/// This class provides common helper methods to reduce boilerplate
/// and improve test reliability across all integration tests.
class TestHelpers {
  // ============================================
  // Widget Finding Helpers
  // ============================================

  /// Finds a widget by its key with better error messages
  static Finder byKeyString(String key) {
    return find.byKey(Key(key));
  }

  /// Finds a widget containing specific text
  static Finder withText(String text) {
    return find.text(text);
  }

  /// Finds a widget by type with optional subtype checking
  static Finder byType<T extends Widget>({bool skipOffstage = true}) {
    return find.byType(T, skipOffstage: skipOffstage);
  }

  /// Finds a widget containing specific text in a subtree
  static Finder textInSubtree(String text) {
    return find.descendant(
      of: find.byType(MaterialApp),
      matching: find.text(text),
    );
  }

  // ============================================
  // Test Action Helpers
  // ============================================

  /// Enters text into a text field and taps the done button
  static Future<void> enterText(
    WidgetTester tester,
    Finder finder,
    String text, {
    bool clearFirst = true,
  }) async {
    if (clearFirst) {
      await tester.tap(finder);
      await tester.pump(TestConfig.stepDelay);
      // Clear existing text
      await tester.enterText(finder, '');
    }
    await tester.enterText(finder, text);
    await tester.pump(TestConfig.defaultUiDelay);
  }

  /// Taps a widget with proper delay and settling
  static Future<void> tap(
    WidgetTester tester,
    Finder finder, {
    Duration? delay,
  }) async {
    await tester.tap(finder);
    await tester.pump(delay ?? TestConfig.defaultUiDelay);
  }

  /// Scrolls until a widget is found
  static Future<void> scrollUntilVisible(
    WidgetTester tester,
    Finder itemFinder,
    Finder scrollableFinder, {
    double delta = 100.0,
    int maxScrolls = 50,
  }) async {
    int scrollCount = 0;
    while (scrollCount < maxScrolls) {
      if (tester.any(itemFinder)) {
        return;
      }
      await tester.drag(scrollableFinder, Offset(0, -delta));
      await tester.pump(TestConfig.defaultUiDelay);
      scrollCount++;
    }
    throw TestFailure('Could not find widget after $maxScrolls scrolls');
  }

  /// Waits for a specific widget to appear
  static Future<void> waitFor(
    WidgetTester tester,
    Finder finder, {
    Duration? timeout,
    String? errorMessage,
  }) async {
    final deadline = timeout ?? TestConfig.maxWaitTime;
    final startTime = DateTime.now();

    while (DateTime.now().difference(startTime) < deadline) {
      if (tester.any(finder)) {
        return;
      }
      await tester.pump(TestConfig.stepDelay);
    }

    throw TestFailure(
      errorMessage ?? 'Timeout waiting for widget: ${finder.describeMatch(1)}',
    );
  }

  /// Waits for a widget to disappear
  static Future<void> waitUntilGone(
    WidgetTester tester,
    Finder finder, {
    Duration? timeout,
  }) async {
    final deadline = timeout ?? TestConfig.maxWaitTime;
    final startTime = DateTime.now();

    while (DateTime.now().difference(startTime) < deadline) {
      if (!tester.any(finder)) {
        return;
      }
      await tester.pump(TestConfig.stepDelay);
    }

    throw TestFailure(
      'Timeout waiting for widget to disappear: ${finder.describeMatch(1)}',
    );
  }

  // ============================================
  // Assertion Helpers
  // ============================================

  /// Asserts that a widget is visible
  static void expectVisible(Finder finder, {String? reason}) {
    expect(
      finder,
      findsOneWidget,
      reason: reason ?? 'Expected widget to be visible: ${finder.describeMatch(1)}',
    );
  }

  /// Asserts that a widget is not visible
  static void expectNotVisible(Finder finder, {String? reason}) {
    expect(
      finder,
      findsNothing,
      reason:
          reason ?? 'Expected widget to not be visible: ${finder.describeMatch(1)}',
    );
  }

  /// Asserts that multiple widgets exist
  static void expectCount(
    int count,
    Finder finder, {
    String? reason,
  }) {
    expect(
      finder,
      findsNWidgets(count),
      reason: reason ??
          'Expected $count widgets but found: ${finder.evaluate().length}',
    );
  }

  /// Asserts that a text widget contains specific text
  static void expectText(String text, {bool shouldContain = true}) {
    final finder = find.text(text);
    if (shouldContain) {
      expect(finder, findsOneWidget, reason: 'Expected to find text: "$text"');
    } else {
      expect(finder, findsNothing,
          reason: 'Did not expect to find text: "$text"');
    }
  }

  // ============================================
  // Navigation Helpers
  // ============================================

  /// Simulates pressing the back button
  static Future<void> pressBack(WidgetTester tester) async {
    await tester.pageBack();
    await tester.pump(TestConfig.defaultUiDelay);
  }

  /// Simulates pressing the done/submit button on keyboard
  static Future<void> submit(WidgetTester tester) async {
    await tester.testTextInput.receiveAction(TextInputAction.done);
    await tester.pump(TestConfig.defaultUiDelay);
  }

  // ============================================
  // Timing Helpers
  // ============================================

  /// Pauses execution for a specified duration
  static Future<void> delay(Duration duration) async {
    await Future.delayed(duration);
  }

  /// Waits for all animations and async operations to complete
  static Future<void> settle(WidgetTester tester) async {
    await tester.pumpAndSettle(TestConfig.maxWaitTime);
  }

  /// Pumps frames for a specified duration (better than fixed delays)
  static Future<void> pumpFor(
    WidgetTester tester,
    Duration duration,
  ) async {
    final endTime = DateTime.now().add(duration);
    while (DateTime.now().isBefore(endTime)) {
      await tester.pump(TestConfig.stepDelay);
    }
  }

  // ============================================
  // Test Setup Helpers
  // ============================================

  /// Sets up the test binding if not already initialized
  static void ensureInitialized() {
    IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  }

  /// Prints test information if verbose logging is enabled
  static void log(String message) {
    if (TestConfig.verboseLogging) {
      print('[TEST] $message');
    }
  }

  /// Prints a section header for better test output readability
  static void logSection(String title) {
    if (TestConfig.verboseLogging) {
      print('\n${'=' * 60}');
      print('  $title');
      print('${'=' * 60}\n');
    }
  }

  // ============================================
  // Data Generation Helpers
  // ============================================

  /// Generates a random email address for testing
  static String randomEmail() {
    return TestConfig.generateTestEmail();
  }

  /// Generates a random user ID for testing
  static String randomUserId() {
    return TestConfig.generateTestUserId();
  }

  /// Generates a random password for testing
  static String randomPassword() {
    const validPasswords = TestConfig.validPasswords;
    return validPasswords[DateTime.now().millisecond % validPasswords.length];
  }

  /// Generates test coordinates for location testing
  static Map<String, double> randomLocation() {
    // New York City area coordinates
    return {
      'latitude': 40.7128 + (DateTime.now().millisecond % 1000) / 10000,
      'longitude': -74.0060 - (DateTime.now().millisecond % 1000) / 10000,
    };
  }

  // ============================================
  // Retry Helper for Flaky Tests
  // ============================================

  /// Runs a test function with retries if it fails
  static Future<T> retry<T>(
    Future<T> Function() testFn, {
    int maxAttempts = 3,
    Duration? delayBetweenAttempts,
  }) async {
    late T result;
    late Object lastError;

    for (int attempt = 1; attempt <= maxAttempts; attempt++) {
      try {
        result = await testFn();
        if (attempt > 1) {
          log('Test passed on attempt $attempt');
        }
        return result;
      } catch (e) {
        lastError = e;
        if (attempt < maxAttempts) {
          log('Test failed on attempt $attempt: $e');
          await Future.delayed(delayBetweenAttempts ?? TestConfig.stepDelay);
        }
      }
    }

    throw TestFailure('Test failed after $maxAttempts attempts: $lastError');
  }
}

/// Extension methods for WidgetTester
extension TestHelpersWidgetTesterExtension on WidgetTester {
  /// Convenience method for entering text
  Future<void> enterText(
    Finder finder,
    String text, {
    bool clearFirst = true,
  }) async {
    await TestHelpers.enterText(this, finder, text, clearFirst: clearFirst);
  }

  /// Convenience method for tapping with delay
  Future<void> tap(
    Finder finder, {
    Duration? delay,
  }) async {
    await TestHelpers.tap(this, finder, delay: delay);
  }

  /// Convenience method for waiting for a widget
  Future<void> waitFor(
    Finder finder, {
    Duration? timeout,
  }) async {
    await TestHelpers.waitFor(this, finder, timeout: timeout);
  }

  /// Convenience method for settling
  Future<void> settle() async {
    await TestHelpers.settle(this);
  }
}

/// Custom matcher for checking async state completion
class CompletesWithin extends Matcher {
  final Duration timeout;
  final String? description;

  const CompletesWithin(
    this.timeout, {
    this.description,
  });

  @override
  bool matches(covariant Future<Object?> item, Map matchState) {
    final completer = item.asStream().drain<void>();
    return completer.timeout(timeout).then(
          (_) => true,
          (_) => false,
        );
  }

  @override
  Description describe(Description description) {
    return description.add('completes within ${timeout.inSeconds} seconds');
  }

  @override
  Description describeMismatch(
    dynamic item,
    Description mismatchDescription,
    Map matchState,
    bool verbose,
  ) {
    return mismatchDescription
        .add('did not complete within ${timeout.inSeconds} seconds');
  }
}
