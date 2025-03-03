import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Creates a [ProviderContainer] for testing with optional overrides.
///
/// This utility function creates a container that can be used in tests
/// to interact with providers without a widget tree.
///
/// [overrides] - Optional list of provider overrides to use in the container.
/// [observers] - Optional list of provider observers to use in the container.
///
/// Returns a [ProviderContainer] that should be disposed after use.
ProviderContainer createContainer({
  List<Override> overrides = const [],
  List<ProviderObserver> observers = const [],
}) {
  final container = ProviderContainer(
    overrides: overrides,
    observers: observers,
  );

  // Add a teardown callback to dispose the container when the test is complete
  addTearDown(container.dispose);

  return container;
}

/// A test observer that tracks provider changes.
///
/// This observer can be used to track state changes in providers during tests.
class TestObserver extends ProviderObserver {
  final List<ProviderChange> changes = [];

  @override
  void didUpdateProvider(
    ProviderBase provider,
    Object? previousValue,
    Object? newValue,
    ProviderContainer container,
  ) {
    changes.add(
      ProviderChange(
        provider: provider,
        previousValue: previousValue,
        newValue: newValue,
      ),
    );
  }

  void reset() {
    changes.clear();
  }

  List<ProviderChange> getChangesFor(ProviderBase provider) {
    return changes.where((change) => change.provider == provider).toList();
  }
}

/// Represents a change in a provider's state.
class ProviderChange {
  final ProviderBase provider;
  final Object? previousValue;
  final Object? newValue;

  ProviderChange({
    required this.provider,
    required this.previousValue,
    required this.newValue,
  });
}

/// A utility class to listen to a provider and collect its state changes.
class ProviderListener<T> {
  final List<T> _values = [];

  List<T> get values => List.unmodifiable(_values);
  T? get lastValue => _values.isEmpty ? null : _values.last;

  void Function(T?, T) get callback => (T? previous, T value) {
        _values.add(value);
      };

  void reset() {
    _values.clear();
  }
}

/// Extension method to add a listener to a provider in a container.
extension ProviderContainerExtension on ProviderContainer {
  /// Adds a listener to the specified provider and returns a [ProviderListener]
  /// that can be used to track state changes.
  ProviderListener<T> listenToProvider<T>(ProviderListenable<T> provider) {
    final listener = ProviderListener<T>();
    listen<T>(
      provider,
      listener.callback,
      fireImmediately: true,
    );
    return listener;
  }
}
