// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trusted_contacts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing trusted contacts state
/// Handles CRUD operations for trusted contacts
///
/// Riverpod 3.0 Compliant:
/// - Uses @riverpod annotation with autoDispose (auto-disposes when unused)
/// - NO getters in state - all derived values are fields
/// - UI reads STATE only via ref.watch()
/// - UI calls methods via ref.read(provider.notifier)

@ProviderFor(TrustedContacts)
const trustedContactsProvider = TrustedContactsProvider._();

/// Notifier for managing trusted contacts state
/// Handles CRUD operations for trusted contacts
///
/// Riverpod 3.0 Compliant:
/// - Uses @riverpod annotation with autoDispose (auto-disposes when unused)
/// - NO getters in state - all derived values are fields
/// - UI reads STATE only via ref.watch()
/// - UI calls methods via ref.read(provider.notifier)
final class TrustedContactsProvider
    extends $NotifierProvider<TrustedContacts, TrustedContactsState> {
  /// Notifier for managing trusted contacts state
  /// Handles CRUD operations for trusted contacts
  ///
  /// Riverpod 3.0 Compliant:
  /// - Uses @riverpod annotation with autoDispose (auto-disposes when unused)
  /// - NO getters in state - all derived values are fields
  /// - UI reads STATE only via ref.watch()
  /// - UI calls methods via ref.read(provider.notifier)
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

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(TrustedContactsState value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<TrustedContactsState>(value),
    );
  }
}

String _$trustedContactsHash() => r'1e279e949c721c57383773d4adb6bcad3accde4a';

/// Notifier for managing trusted contacts state
/// Handles CRUD operations for trusted contacts
///
/// Riverpod 3.0 Compliant:
/// - Uses @riverpod annotation with autoDispose (auto-disposes when unused)
/// - NO getters in state - all derived values are fields
/// - UI reads STATE only via ref.watch()
/// - UI calls methods via ref.read(provider.notifier)

abstract class _$TrustedContacts extends $Notifier<TrustedContactsState> {
  TrustedContactsState build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<TrustedContactsState, TrustedContactsState>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<TrustedContactsState, TrustedContactsState>,
        TrustedContactsState,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}
