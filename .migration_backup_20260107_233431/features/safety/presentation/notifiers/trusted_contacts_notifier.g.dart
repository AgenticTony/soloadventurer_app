// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trusted_contacts_notifier.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for managing trusted contacts state
/// Handles CRUD operations for trusted contacts

@ProviderFor(TrustedContactsNotifier)
final trustedContactsProvider = TrustedContactsNotifierProvider._();

/// Notifier for managing trusted contacts state
/// Handles CRUD operations for trusted contacts
final class TrustedContactsNotifierProvider extends $NotifierProvider<
    TrustedContactsNotifier, AsyncValue<List<TrustedContact>>> {
  /// Notifier for managing trusted contacts state
  /// Handles CRUD operations for trusted contacts
  TrustedContactsNotifierProvider._()
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
  String debugGetCreateSourceHash() => _$trustedContactsNotifierHash();

  @$internal
  @override
  TrustedContactsNotifier create() => TrustedContactsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(AsyncValue<List<TrustedContact>> value) {
    return $ProviderOverride(
      origin: this,
      providerOverride:
          $SyncValueProvider<AsyncValue<List<TrustedContact>>>(value),
    );
  }
}

String _$trustedContactsNotifierHash() =>
    r'8a6f95ef52103af6c55ba37f851be9289072bad7';

/// Notifier for managing trusted contacts state
/// Handles CRUD operations for trusted contacts

abstract class _$TrustedContactsNotifier
    extends $Notifier<AsyncValue<List<TrustedContact>>> {
  AsyncValue<List<TrustedContact>> build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<AsyncValue<List<TrustedContact>>,
        AsyncValue<List<TrustedContact>>>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<AsyncValue<List<TrustedContact>>,
            AsyncValue<List<TrustedContact>>>,
        AsyncValue<List<TrustedContact>>,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}
