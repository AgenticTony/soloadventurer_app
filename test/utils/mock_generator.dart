import 'package:mocktail/mocktail.dart';

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

/// Resets all registered mocks to their default state.
///
/// This should be called in the setUp method of each test.
void resetMocks() {
  reset(MockRegistry._mocks.values.toList());
}
