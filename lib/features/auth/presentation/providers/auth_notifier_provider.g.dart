// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auth_notifier_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// AuthNotifier - manages authentication state using AsyncNotifier pattern
///
/// Riverpod 3.0 AsyncNotifier Compliant:
/// - Uses AsyncNotifier<AuthState> with AsyncValue wrapper
/// - Loading/error states handled by AsyncValue, NOT manual state fields
/// - UI reads STATE via ref.watch(authProvider)
/// - UI calls methods via ref.read(authProvider.notifier)

@ProviderFor(AuthNotifier)
const authProvider = AuthNotifierProvider._();

/// AuthNotifier - manages authentication state using AsyncNotifier pattern
///
/// Riverpod 3.0 AsyncNotifier Compliant:
/// - Uses AsyncNotifier<AuthState> with AsyncValue wrapper
/// - Loading/error states handled by AsyncValue, NOT manual state fields
/// - UI reads STATE via ref.watch(authProvider)
/// - UI calls methods via ref.read(authProvider.notifier)
final class AuthNotifierProvider
    extends $AsyncNotifierProvider<AuthNotifier, AuthState> {
  /// AuthNotifier - manages authentication state using AsyncNotifier pattern
  ///
  /// Riverpod 3.0 AsyncNotifier Compliant:
  /// - Uses AsyncNotifier<AuthState> with AsyncValue wrapper
  /// - Loading/error states handled by AsyncValue, NOT manual state fields
  /// - UI reads STATE via ref.watch(authProvider)
  /// - UI calls methods via ref.read(authProvider.notifier)
  const AuthNotifierProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'authProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$authNotifierHash();

  @$internal
  @override
  AuthNotifier create() => AuthNotifier();
}

String _$authNotifierHash() => r'd77d5c09a66f585440761928057a5cbb537b70f5';

/// AuthNotifier - manages authentication state using AsyncNotifier pattern
///
/// Riverpod 3.0 AsyncNotifier Compliant:
/// - Uses AsyncNotifier<AuthState> with AsyncValue wrapper
/// - Loading/error states handled by AsyncValue, NOT manual state fields
/// - UI reads STATE via ref.watch(authProvider)
/// - UI calls methods via ref.read(authProvider.notifier)

abstract class _$AuthNotifier extends $AsyncNotifier<AuthState> {
  FutureOr<AuthState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<AsyncValue<AuthState>, AuthState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<AuthState>, AuthState>,
        AsyncValue<AuthState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
