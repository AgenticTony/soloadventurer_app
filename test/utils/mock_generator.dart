import 'package:mocktail/mocktail.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A registry for mock objects to ensure consistent usage across tests.
class MockRegistry {
  static final Map<Type, Object> _mocks = {};

  /// Registers a mock instance for a specific type.
  ///
  /// [T] - The type to register the mock for.
  /// [mock] - The mock instance to register.
  static void register<T extends Object>(T mock) {
    _mocks[T] = mock;
  }

  /// Gets a registered mock instance for a specific type.
  ///
  /// [T] - The type to get the mock for.
  ///
  /// Returns the registered mock instance or throws an exception if not found.
  static T get<T>() {
    final mock = _mocks[T];
    if (mock == null) {
      throw Exception('No mock registered for type $T');
    }
    return mock as T;
  }

  /// Checks if a mock is registered for a specific type.
  ///
  /// [T] - The type to check for.
  ///
  /// Returns true if a mock is registered for the type, false otherwise.
  static bool isRegistered<T>() {
    return _mocks.containsKey(T);
  }

  /// Clears all registered mocks.
  static void clear() {
    _mocks.clear();
  }
}

/// Creates a provider override for a specific provider using a mock.
///
/// [provider] - The provider to override.
/// [mock] - The mock instance to use for the override.
///
/// Returns an [Override] that can be used in a [ProviderContainer].
Override mockProvider<T>(Provider<T> provider, T mock) {
  return provider.overrideWithValue(mock);
}

/// Creates a provider override for a specific future provider using a mock.
///
/// [provider] - The future provider to override.
/// [value] - The value to return from the mock.
///
/// Returns an [Override] that can be used in a [ProviderContainer].
Override mockFutureProvider<T>(FutureProvider<T> provider, T value) {
  return provider.overrideWith((ref) => Future.value(value));
}

/// Creates a provider override for a specific future provider to simulate loading.
///
/// [provider] - The future provider to override.
///
/// Returns an [Override] that can be used in a [ProviderContainer].
Override mockFutureProviderLoading<T>(FutureProvider<T> provider) {
  return provider.overrideWith((ref) => Future<T>.delayed(
        const Duration(
            days: 365), // Long delay to ensure it stays in loading state
        () => throw UnimplementedError(),
      ));
}

/// Creates a provider override for a specific future provider to simulate an error.
///
/// [provider] - The future provider to override.
/// [error] - The error to simulate.
/// [stackTrace] - Optional stack trace to include with the error.
///
/// Returns an [Override] that can be used in a [ProviderContainer].
Override mockFutureProviderError<T>(
  FutureProvider<T> provider,
  Object error, [
  StackTrace? stackTrace,
]) {
  return provider.overrideWith((ref) => Future<T>.error(
        error,
        stackTrace ?? StackTrace.current,
      ));
}

/// Creates a provider override for a specific state notifier provider using a mock.
///
/// [provider] - The state notifier provider to override.
/// [mockNotifier] - The mock state notifier to use.
///
/// Returns an [Override] that can be used in a [ProviderContainer].
Override
    mockStateNotifierProvider<Notifier extends StateNotifier<State>, State>(
  StateNotifierProvider<Notifier, State> provider,
  Notifier mockNotifier,
) {
  return provider.overrideWith((_) => mockNotifier);
}

/// A utility class to create mock state notifiers for testing.
///
/// [T] - The state type for the notifier.
class MockStateNotifier<T> extends Mock implements StateNotifier<T> {
  T _state;

  MockStateNotifier(this._state);

  @override
  T get state => _state;

  @override
  set state(T value) {
    _state = value;
  }
}

/// Resets all registered mocks to their default state.
///
/// This should be called in the setUp method of each test.
void resetMocks() {
  reset(MockRegistry._mocks.values.toList());
}
