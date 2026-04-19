// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Notifier for sync settings
///
/// Riverpod 3.0: Uses @riverpod annotation with Notifier pattern.

@ProviderFor(SyncSettings)
const syncSettingsProvider = SyncSettingsProvider._();

/// Notifier for sync settings
///
/// Riverpod 3.0: Uses @riverpod annotation with Notifier pattern.
final class SyncSettingsProvider
    extends $NotifierProvider<SyncSettings, SyncSettingsData> {
  /// Notifier for sync settings
  ///
  /// Riverpod 3.0: Uses @riverpod annotation with Notifier pattern.
  const SyncSettingsProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'syncSettingsProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$syncSettingsHash();

  @$internal
  @override
  SyncSettings create() => SyncSettings();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncSettingsData value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncSettingsData>(value),
    );
  }
}

String _$syncSettingsHash() => r'917e2bc7a8d7e88dcaef5c27e075c57aa7a8e9b1';

/// Notifier for sync settings
///
/// Riverpod 3.0: Uses @riverpod annotation with Notifier pattern.

abstract class _$SyncSettings extends $Notifier<SyncSettingsData> {
  SyncSettingsData build();
  @$mustCallSuper
  @override
  void runBuild() {
    final created = build();
    final ref = this.ref as $Ref<SyncSettingsData, SyncSettingsData>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SyncSettingsData, SyncSettingsData>,
        SyncSettingsData,
        Object?,
        Object?>;
    element.handleValue(ref, created);
  }
}

/// Provider for SharedPreferences instance

@ProviderFor(sharedPreferences)
const sharedPreferencesProvider = SharedPreferencesProvider._();

/// Provider for SharedPreferences instance

final class SharedPreferencesProvider extends $FunctionalProvider<
    SharedPreferences,
    SharedPreferences,
    SharedPreferences> with $Provider<SharedPreferences> {
  /// Provider for SharedPreferences instance
  const SharedPreferencesProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'sharedPreferencesProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$sharedPreferencesHash();

  @$internal
  @override
  $ProviderElement<SharedPreferences> $createElement(
          $ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  SharedPreferences create(Ref ref) {
    return sharedPreferences(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SharedPreferences value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SharedPreferences>(value),
    );
  }
}

String _$sharedPreferencesHash() => r'fae80ab617db0b1ad9094ee01e7c9665b96a107c';

/// Provider for sync enabled boolean (for easy access)

@ProviderFor(syncEnabled)
const syncEnabledProvider = SyncEnabledProvider._();

/// Provider for sync enabled boolean (for easy access)

final class SyncEnabledProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provider for sync enabled boolean (for easy access)
  const SyncEnabledProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'syncEnabledProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$syncEnabledHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return syncEnabled(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$syncEnabledHash() => r'53f176e6a4d76bec16fa5b0194dd938116713185';

/// Provider for WiFi-only sync boolean (for easy access)

@ProviderFor(syncOnlyOnWifi)
const syncOnlyOnWifiProvider = SyncOnlyOnWifiProvider._();

/// Provider for WiFi-only sync boolean (for easy access)

final class SyncOnlyOnWifiProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provider for WiFi-only sync boolean (for easy access)
  const SyncOnlyOnWifiProvider._()
      : super(
          from: null,
          argument: null,
          retry: null,
          name: r'syncOnlyOnWifiProvider',
          isAutoDispose: true,
          dependencies: null,
          $allTransitiveDependencies: null,
        );

  @override
  String debugGetCreateSourceHash() => _$syncOnlyOnWifiHash();

  @$internal
  @override
  $ProviderElement<bool> $createElement($ProviderPointer pointer) =>
      $ProviderElement(pointer);

  @override
  bool create(Ref ref) {
    return syncOnlyOnWifi(ref);
  }

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(bool value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<bool>(value),
    );
  }
}

String _$syncOnlyOnWifiHash() => r'b7f6b75784380c0be06e643b4f90e8ffc9eae19d';
