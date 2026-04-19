// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trusted_contacts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// AsyncNotifier for managing trusted contacts state.
///
/// Riverpod 3.0 Compliant:
/// - Uses @riverpod annotation with code generation
/// - AsyncNotifier with AsyncValue handles loading/error
/// - State no longer has isLoading/error fields

@ProviderFor(TrustedContacts)
const trustedContactsProvider = TrustedContactsProvider._();

/// AsyncNotifier for managing trusted contacts state.
///
/// Riverpod 3.0 Compliant:
/// - Uses @riverpod annotation with code generation
/// - AsyncNotifier with AsyncValue handles loading/error
/// - State no longer has isLoading/error fields
final class TrustedContactsProvider
    extends $AsyncNotifierProvider<TrustedContacts, TrustedContactsState> {
  /// AsyncNotifier for managing trusted contacts state.
  ///
  /// Riverpod 3.0 Compliant:
  /// - Uses @riverpod annotation with code generation
  /// - AsyncNotifier with AsyncValue handles loading/error
  /// - State no longer has isLoading/error fields
  const TrustedContactsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'trustedContactsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$trustedContactsHash();

  @$internal
  @override
  TrustedContacts create() => TrustedContacts();
}

String _$trustedContactsHash() => r'5bc6320062f6c1352c21e1ecfe31dfdf3f5379be';

/// AsyncNotifier for managing trusted contacts state.
///
/// Riverpod 3.0 Compliant:
/// - Uses @riverpod annotation with code generation
/// - AsyncNotifier with AsyncValue handles loading/error
/// - State no longer has isLoading/error fields

abstract class _$TrustedContacts extends $AsyncNotifier<TrustedContactsState> {
  FutureOr<TrustedContactsState> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref
        as $Ref<AsyncValue<TrustedContactsState>, TrustedContactsState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<TrustedContactsState>, TrustedContactsState>,
        AsyncValue<TrustedContactsState>,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
