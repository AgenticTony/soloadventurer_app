import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'provider_container_utils.dart';

/// Tests a [StateNotifierProvider] with various scenarios.
///
/// This utility function helps test state notifier providers by running
/// a series of test cases with different inputs and expected outputs.
///
/// [provider] - The provider to test.
/// [buildMocks] - A function that builds any necessary mocks.
/// [testCases] - A list of test cases to run.
/// [setUp] - An optional function to run before each test.
/// [tearDown] - An optional function to run after each test.
void testStateNotifierProvider<Notifier extends StateNotifier<State>, State>({
  required StateNotifierProvider<Notifier, State> provider,
  required List<Function> buildMocks,
  required List<StateNotifierTestCase<State>> testCases,
  Function()? setUp,
  Function()? tearDown,
}) {
  group('${provider.name}', () {
    for (final testCase in testCases) {
      test(testCase.description, () async {
        // Run setup if provided
        if (setUp != null) {
          setUp();
        }

        // Build mocks
        for (final buildMock in buildMocks) {
          buildMock();
        }

        // Create container with overrides
        final container = createContainer(
          overrides: testCase.overrides ?? [],
        );

        // Add listener to track state changes
        final listener = container.listenToProvider(provider);

        // Run the action that should trigger state changes
        await testCase.action(container);

        // Verify the expected state
        if (testCase.expectedState != null) {
          expect(listener.lastValue, testCase.expectedState);
        }

        // Verify the expected state changes
        if (testCase.expectedStateChanges != null) {
          expect(listener.values.length,
              testCase.expectedStateChanges!.length + 1);
          for (var i = 0; i < testCase.expectedStateChanges!.length; i++) {
            expect(listener.values[i + 1], testCase.expectedStateChanges![i]);
          }
        }

        // Run teardown if provided
        if (tearDown != null) {
          tearDown();
        }
      });
    }
  });
}

/// Tests a [FutureProvider] with various scenarios.
///
/// This utility function helps test future providers by running
/// a series of test cases with different inputs and expected outputs.
///
/// [provider] - The provider to test.
/// [buildMocks] - A function that builds any necessary mocks.
/// [testCases] - A list of test cases to run.
/// [setUp] - An optional function to run before each test.
/// [tearDown] - An optional function to run after each test.
void testFutureProvider<T>({
  required FutureProvider<T> provider,
  required List<Function> buildMocks,
  required List<FutureProviderTestCase<T>> testCases,
  Function()? setUp,
  Function()? tearDown,
}) {
  group('${provider.name}', () {
    for (final testCase in testCases) {
      test(testCase.description, () async {
        // Run setup if provided
        if (setUp != null) {
          setUp();
        }

        // Build mocks
        for (final buildMock in buildMocks) {
          buildMock();
        }

        // Create container with overrides
        final container = createContainer(
          overrides: testCase.overrides ?? [],
        );

        // Add listener to track state changes
        final listener = container.listenToProvider(provider);

        // Initial state should be loading
        expect(listener.lastValue, isA<AsyncLoading<T>>());

        // Run the action that should trigger state changes
        await testCase.action(container);

        // Wait for the future to complete
        await Future.delayed(Duration.zero);

        // Verify the expected state
        if (testCase.expectedState != null) {
          expect(listener.lastValue, testCase.expectedState);
        }

        // Verify the expected data
        if (testCase.expectedData != null &&
            listener.lastValue is AsyncData<T>) {
          expect((listener.lastValue as AsyncData<T>).value,
              testCase.expectedData);
        }

        // Verify the expected error
        if (testCase.expectedError != null &&
            listener.lastValue is AsyncError) {
          expect(
              (listener.lastValue as AsyncError).error, testCase.expectedError);
        }

        // Run teardown if provided
        if (tearDown != null) {
          tearDown();
        }
      });
    }
  });
}

/// Tests a [StreamProvider] with various scenarios.
///
/// This utility function helps test stream providers by running
/// a series of test cases with different inputs and expected outputs.
///
/// [provider] - The provider to test.
/// [buildMocks] - A function that builds any necessary mocks.
/// [testCases] - A list of test cases to run.
/// [setUp] - An optional function to run before each test.
/// [tearDown] - An optional function to run after each test.
void testStreamProvider<T>({
  required StreamProvider<T> provider,
  required List<Function> buildMocks,
  required List<StreamProviderTestCase<T>> testCases,
  Function()? setUp,
  Function()? tearDown,
}) {
  group('${provider.name}', () {
    for (final testCase in testCases) {
      test(testCase.description, () async {
        // Run setup if provided
        if (setUp != null) {
          setUp();
        }

        // Build mocks
        for (final buildMock in buildMocks) {
          buildMock();
        }

        // Create container with overrides
        final container = createContainer(
          overrides: testCase.overrides ?? [],
        );

        // Add listener to track state changes
        final listener = container.listenToProvider(provider);

        // Initial state should be loading
        expect(listener.lastValue, isA<AsyncLoading<T>>());

        // Run the action that should trigger state changes
        await testCase.action(container);

        // Wait for the stream to emit values
        await Future.delayed(testCase.delay ?? Duration.zero);

        // Verify the expected state
        if (testCase.expectedState != null) {
          expect(listener.lastValue, testCase.expectedState);
        }

        // Verify the expected data
        if (testCase.expectedData != null &&
            listener.lastValue is AsyncData<T>) {
          expect((listener.lastValue as AsyncData<T>).value,
              testCase.expectedData);
        }

        // Verify the expected error
        if (testCase.expectedError != null &&
            listener.lastValue is AsyncError) {
          expect(
              (listener.lastValue as AsyncError).error, testCase.expectedError);
        }

        // Run teardown if provided
        if (tearDown != null) {
          tearDown();
        }
      });
    }
  });
}

/// A test case for a [StateNotifierProvider].
class StateNotifierTestCase<T> {
  final String description;
  final List<Override>? overrides;
  final Future<void> Function(ProviderContainer container) action;
  final T? expectedState;
  final List<T>? expectedStateChanges;

  StateNotifierTestCase({
    required this.description,
    this.overrides,
    required this.action,
    this.expectedState,
    this.expectedStateChanges,
  });
}

/// A test case for a [FutureProvider].
class FutureProviderTestCase<T> {
  final String description;
  final List<Override>? overrides;
  final Future<void> Function(ProviderContainer container) action;
  final AsyncValue<T>? expectedState;
  final T? expectedData;
  final Object? expectedError;

  FutureProviderTestCase({
    required this.description,
    this.overrides,
    required this.action,
    this.expectedState,
    this.expectedData,
    this.expectedError,
  });
}

/// A test case for a [StreamProvider].
class StreamProviderTestCase<T> {
  final String description;
  final List<Override>? overrides;
  final Future<void> Function(ProviderContainer container) action;
  final AsyncValue<T>? expectedState;
  final T? expectedData;
  final Object? expectedError;
  final Duration? delay;

  StreamProviderTestCase({
    required this.description,
    this.overrides,
    required this.action,
    this.expectedState,
    this.expectedData,
    this.expectedError,
    this.delay,
  });
}
