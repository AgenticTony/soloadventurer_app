import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Creates a [ProviderContainer] for testing with optional overrides.
///
/// This is a convenience wrapper around [ProviderContainer] for tests.
/// Use this instead of the raw [ProviderContainer] constructor.
///
/// Example:
/// ```dart
/// test('my provider test', () {
///   final container = createTestContainer(
///     overrides: [
///       myProvider.overrideWithValue(myMockValue),
///     ],
///   );
///
///   final result = container.read(myProvider);
///   expect(result, equals(expectedValue));
/// });
/// ```
ProviderContainer createTestContainer({
  List<Object> overrides = const [],
  List<ProviderObserver> observers = const [],
}) {
  final container = ProviderContainer(
    overrides: overrides.cast(),
    observers: observers,
  );

  addTearDown(container.dispose);

  return container;
}

/// A test case for a basic provider.
class ProviderTestCase<T> {
  final String description;
  final List<Object>? overrides;
  final Future<void> Function(ProviderContainer container) action;
  final T? expectedValue;

  ProviderTestCase({
    required this.description,
    this.overrides,
    required this.action,
    this.expectedValue,
  });
}

/// A test case for an async provider.
class AsyncProviderTestCase<T> {
  final String description;
  final List<Object>? overrides;
  final Future<void> Function(ProviderContainer container) action;
  final AsyncValue<T>? expectedState;
  final T? expectedData;
  final Object? expectedError;
  final Duration? delay;

  AsyncProviderTestCase({
    required this.description,
    this.overrides,
    required this.action,
    this.expectedState,
    this.expectedData,
    this.expectedError,
    this.delay,
  });
}
