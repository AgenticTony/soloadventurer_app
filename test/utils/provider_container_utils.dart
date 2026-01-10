import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

/// Creates a [ProviderContainer] for testing with optional overrides.
///
/// Riverpod 3.0 Migration:
/// - Overrides now use provider-specific overrideWithValue methods
/// - Test utilities updated for Riverpod 3.0 compatibility
///
/// This utility function creates a container that can be used in tests
/// to interact with providers without a widget tree.
///
/// [overrides] - Optional list of provider overrides to use in the container.
/// [observers] - Optional list of provider observers to use in the container.
///
/// Returns a [ProviderContainer] that should be disposed after use.
ProviderContainer createContainer({
  List<Object> overrides = const [],
  List<ProviderObserver> observers = const [],
}) {
  final container = ProviderContainer(
    overrides: overrides.map((e) => e as RiverpodOverride).toList(),
    observers: observers,
  );

  // Add a teardown callback to dispose the container when the test is complete
  addTearDown(container.dispose);

  return container;
}

/// A test observer that tracks provider changes.
///
/// Riverpod 3.0 Migration:
/// - Updated didUpdateProvider to use ProviderObserverContext
/// - Class marked as `base` to match ProviderObserver's base requirement
/// - Removed ProviderBase references (no longer a public type in Riverpod 3.0)
/// - Access provider and container through context object
///
/// This observer can be used to track state changes in providers during tests.
base class TestObserver extends ProviderObserver {
  final List<ProviderChange> changes = [];

  @override
  void didUpdateProvider(
    ProviderObserverContext context,
    Object? previousValue,
    Object? newValue,
  ) {
    changes.add(
      ProviderChange(
        provider: context.provider,
        previousValue: previousValue,
        newValue: newValue,
      ),
    );
  }

  void reset() {
    changes.clear();
  }

  List<ProviderChange> getChangesFor(Object provider) {
    return changes.where((change) => change.provider == provider).toList();
  }
}

/// Represents a change in a provider's state.
///
/// Riverpod 3.0 Migration:
/// - Provider type changed from ProviderBase to Object
/// - ProviderBase is no longer a public type in Riverpod 3.0
class ProviderChange {
  final Object provider;
  final Object? previousValue;
  final Object? newValue;

  ProviderChange({
    required this.provider,
    required this.previousValue,
    required this.newValue,
  });
}

/// A utility class to listen to a provider and collect its state changes.
///
/// Riverpod 3.0 Migration:
/// - ProviderListenable is no longer available
/// - Updated to use Riverpod 3.0 listen API
class ProviderListener<T> {
  final List<T> _values = [];
  RiverpodSubscription? _subscription;

  List<T> get values => List.unmodifiable(_values);
  T? get lastValue => _values.isEmpty ? null : _values.last;

  void startListening(
    ProviderContainer container,
    Object provider,
  ) {
    _subscription = container.listen(
      provider,
      (previous, value) {
        if (value is T) {
          _values.add(value as T);
        }
      },
      fireImmediately: true,
    );
  }

  void reset() {
    _values.clear();
  }

  void dispose() {
    _subscription?.close();
    _subscription = null;
  }
}

/// Extension method to add a listener to a provider in a container.
///
/// Riverpod 3.0 Migration:
/// - ProviderListenable is no longer available
/// - Uses provider listen API directly
extension ProviderContainerExtension on ProviderContainer {
  /// Adds a listener to the specified provider and returns a [ProviderListener]
  /// that can be used to track state changes.
  ProviderListener<T> listenToProvider<T>(Object provider) {
    final listener = ProviderListener<T>();
    listener.startListening(this, provider);
    addTearDown(listener.dispose);
    return listener;
  }
}
