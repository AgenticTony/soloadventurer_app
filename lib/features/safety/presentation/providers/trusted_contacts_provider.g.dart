// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trusted_contacts_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

String _$trustedContactsHash() => r'1e279e949c721c57383773d4adb6bcad3accde4a';

/// Notifier for managing trusted contacts state
/// Handles CRUD operations for trusted contacts
///
/// Riverpod 2 Compliant:
/// - Uses AutoDisposeNotifier (auto-disposes when unused)
/// - NO getters in state - all derived values are fields
/// - UI reads STATE only via ref.watch()
/// - UI calls methods via ref.read(provider.notifier)
///
/// Copied from [TrustedContacts].
@ProviderFor(TrustedContacts)
final trustedContactsProvider =
    AutoDisposeNotifierProvider<TrustedContacts, TrustedContactsState>.internal(
  TrustedContacts.new,
  name: r'trustedContactsProvider',
  debugGetCreateSourceHash: const bool.fromEnvironment('dart.vm.product')
      ? null
      : _$trustedContactsHash,
  dependencies: null,
  allTransitiveDependencies: null,
);

typedef _$TrustedContacts = AutoDisposeNotifier<TrustedContactsState>;
// ignore_for_file: type=lint
// ignore_for_file: subtype_of_sealed_class, invalid_use_of_internal_member, invalid_use_of_visible_for_testing_member, deprecated_member_use_from_same_package
