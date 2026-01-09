import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/auth/infrastructure/services/auth_service.dart';

/// Mock classes for testing
class MockAuthService extends Mock implements AuthService {
  @override
  String? get token => null;

  @override
  String? get username => null;

  @override
  bool get isAuthenticated => false;
}

class MockNavigatorObserver extends Mock implements NavigatorObserver {}

class MockRoute extends Fake implements Route<dynamic> {}

/// Helper to create a testable widget with overridden providers
Widget createTestableApp({
  required Widget child,
  List<Override> overrides = const [],
  List<NavigatorObserver> navigatorObservers = const [],
}) {
  return ProviderScope(
    overrides: overrides,
    child: MaterialApp(
      home: child,
      navigatorObservers: navigatorObservers,
    ),
  );
}

/// Setup common mocks for authentication tests
class AuthTestHelper {
  late MockAuthService authService;
  late MockNavigatorObserver navigatorObserver;

  AuthTestHelper() {
    authService = MockAuthService();
    navigatorObserver = MockNavigatorObserver();

    // Register fallback values
    registerFallbackValue(MockRoute());
  }

  /// Get common provider overrides for auth tests
  List<Override> get authOverrides =>
      []; // TODO: Implement proper auth service provider overrides

  /// Setup common mock behaviors
  void setupCommonMocks() {
    // Setup common mock behaviors for auth service
    when(() => authService.initialize()).thenAnswer((_) async {
      return;
    });
    when(() => authService.refreshSession()).thenAnswer((_) async => true);
    when(() => authService.signOut()).thenAnswer((_) async {
      return;
    });
  }

  /// Setup mock for failed sign in
  void setupFailedSignIn() {
    when(() => authService.refreshSession()).thenAnswer((_) async => false);
  }

  /// Setup mock for failed sign up
  void setupFailedSignUp() {
    when(() => authService.refreshSession()).thenAnswer((_) async => false);
  }
}

/// Provider container helper for unit testing providers
class ProviderTestHelper {
  late ProviderContainer container;

  ProviderTestHelper({List<Override> overrides = const []}) {
    container = ProviderContainer(overrides: overrides);
  }

  void dispose() {
    container.dispose();
  }
}

/// Extension method to simplify testing async providers
extension ProviderContainerX on ProviderContainer {
  /// Wait for a future provider to complete and return its value
  Future<T> waitFor<T>(ProviderListenable<AsyncValue<T>> provider) async {
    final completer = Completer<T>();

    final subscription = listen<AsyncValue<T>>(
      provider,
      (_, next) {
        if (next is AsyncData<T>) {
          if (!completer.isCompleted) {
            completer.complete(next.value);
          }
        } else if (next is AsyncError) {
          if (!completer.isCompleted) {
            // Handle error case differently to avoid type issues
            final error = next.error;
            final stackTrace = next.stackTrace ?? StackTrace.current;
            Zone.current.handleUncaughtError(error as Object, stackTrace);
            // Complete with a default value or rethrow based on your needs
            // For now, we'll just complete with a default value if possible
            if (T == String) {
              completer.complete('' as T);
            } else if (T == bool) {
              completer.complete(false as T);
            } else if (T == int) {
              completer.complete(0 as T);
            } else if (T == double) {
              completer.complete(0.0 as T);
            } else if (T == List) {
              completer.complete([] as T);
            } else if (T == Map) {
              completer.complete({} as T);
            } else {
              // For other types, we can't provide a default value
              // so we'll just rethrow the error
              throw error;
            }
          }
        }
      },
    );

    final value = await completer.future;
    subscription.close();
    return value;
  }
}
