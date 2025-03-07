import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:soloadventurer/features/auth/domain/providers/auth_providers.dart';
import 'package:soloadventurer/features/auth/domain/notifiers/auth_notifier.dart'
    as domain;
import 'package:soloadventurer/features/core/domain/services/connectivity_service.dart';
import 'package:soloadventurer/core/storage/secure_storage.dart';
import 'package:flutter/material.dart';
import 'package:mocktail/mocktail.dart';
import 'package:soloadventurer/features/auth/presentation/providers/auth_provider.dart';
import 'package:soloadventurer/features/auth/presentation/state/auth_state.dart';

/// Creates a test container with all necessary auth-related providers properly initialized
Future<ProviderContainer> createAuthTestContainer({
  List<Override> overrides = const [],
}) async {
  final container = ProviderContainer(
    overrides: [
      // Core service overrides
      connectivityServiceProvider.overrideWith(
        (ref) => FakeConnectivityService(isOnline: true),
      ),
      // Use the existing SecureStorage class but with an in-memory implementation
      Provider<SecureStorage>((ref) => SecureStorage()),
      ...overrides,
    ],
  );

  // Add teardown callback
  addTearDown(container.dispose);

  // Read initial state to trigger initialization
  container.read(authProvider);
  // Wait for any pending state updates
  await container.pump();

  return container;
}

/// Fake connectivity service for testing
class FakeConnectivityService implements ConnectivityService {
  bool _isOnline;
  final _controller = StreamController<NetworkStatus>.broadcast();

  FakeConnectivityService({bool isOnline = true}) : _isOnline = isOnline {
    _controller
        .add(isOnline ? NetworkStatus.connected : NetworkStatus.disconnected);
  }

  @override
  Stream<NetworkStatus> get onConnectivityChanged => _controller.stream;

  @override
  Future<NetworkStatus> checkConnectivity() async {
    return _isOnline ? NetworkStatus.connected : NetworkStatus.disconnected;
  }

  @override
  Future<bool> get hasConnectivity async => _isOnline;

  @override
  bool get hasConnectivitySync => _isOnline;

  void setOnline(bool online) {
    _isOnline = online;
    _controller
        .add(online ? NetworkStatus.connected : NetworkStatus.disconnected);
  }

  @override
  void dispose() {
    _controller.close();
  }
}

/// Helper extension for auth testing
extension AuthTestingX on ProviderContainer {
  /// Simulates a successful sign in
  Future<void> signInUser({
    required String email,
    required String password,
  }) async {
    await read(authProvider.notifier).signIn(email, password);
    // Wait for all auth-related state updates
    await pump();
  }

  /// Simulates a sign out
  Future<void> signOutUser() async {
    await read(authProvider.notifier).signOut();
    // Wait for all auth-related state updates
    await pump();
  }

  /// Helper to wait for all async operations to complete
  Future<void> pump() async {
    await Future.delayed(Duration.zero);
  }
}

class MockAuthNotifier extends StateNotifier<AsyncValue<AuthState>>
    with Mock
    implements AuthNotifier {
  MockAuthNotifier() : super(AsyncValue.data(AuthState.initial()));
}

Widget createAuthTestWidget({
  required Widget child,
  MockAuthNotifier? mockAuthNotifier,
}) {
  return ProviderScope(
    overrides: [
      if (mockAuthNotifier != null)
        authProvider.overrideWithProvider(
          StateNotifierProvider<AuthNotifier, AsyncValue<AuthState>>(
            (ref) => mockAuthNotifier,
          ),
        ),
    ],
    child: MaterialApp(
      home: child,
    ),
  );
}
