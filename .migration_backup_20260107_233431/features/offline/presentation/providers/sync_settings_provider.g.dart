// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'sync_settings_provider.dart';

// **************************************************************************
// RiverpodGenerator
// **************************************************************************

// GENERATED CODE - DO NOT MODIFY BY HAND
// ignore_for_file: type=lint, type=warning
/// Re-export of sharedPreferencesProvider from app/providers/core_service_providers.dart
/// The sharedPreferencesProvider is now defined in app/providers/core_service_providers.dart
/// Notifier for sync settings

@ProviderFor(SyncSettingsNotifier)
final syncSettingsProvider = SyncSettingsNotifierProvider._();

/// Re-export of sharedPreferencesProvider from app/providers/core_service_providers.dart
/// The sharedPreferencesProvider is now defined in app/providers/core_service_providers.dart
/// Notifier for sync settings
final class SyncSettingsNotifierProvider
    extends $NotifierProvider<SyncSettingsNotifier, SyncSettings> {
  /// Re-export of sharedPreferencesProvider from app/providers/core_service_providers.dart
  /// The sharedPreferencesProvider is now defined in app/providers/core_service_providers.dart
  /// Notifier for sync settings
  SyncSettingsNotifierProvider._()
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
  String debugGetCreateSourceHash() => _$syncSettingsNotifierHash();

  @$internal
  @override
  SyncSettingsNotifier create() => SyncSettingsNotifier();

  /// {@macro riverpod.override_with_value}
  Override overrideWithValue(SyncSettings value) {
    return $ProviderOverride(
      origin: this,
      providerOverride: $SyncValueProvider<SyncSettings>(value),
    );
  }
}

String _$syncSettingsNotifierHash() =>
    r'd5c677b6f204cb2debd6e66d057b40d3f3ed6196';

/// Re-export of sharedPreferencesProvider from app/providers/core_service_providers.dart
/// The sharedPreferencesProvider is now defined in app/providers/core_service_providers.dart
/// Notifier for sync settings

abstract class _$SyncSettingsNotifier extends $Notifier<SyncSettings> {
  SyncSettings build();
  @$mustCallSuper
  @override
  void runBuild() {
    final ref = this.ref as $Ref<SyncSettings, SyncSettings>;
    final element = ref.element as $ClassProviderElement<
        AnyNotifier<SyncSettings, SyncSettings>,
        SyncSettings,
        Object?,
        Object?>;
    element.handleCreate(ref, build);
  }
}

/// Provider for sync enabled boolean (for easy access)

@ProviderFor(syncEnabled)
final syncEnabledProvider = SyncEnabledProvider._();

/// Provider for sync enabled boolean (for easy access)

final class SyncEnabledProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provider for sync enabled boolean (for easy access)
  SyncEnabledProvider._()
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
final syncOnlyOnWifiProvider = SyncOnlyOnWifiProvider._();

/// Provider for WiFi-only sync boolean (for easy access)

final class SyncOnlyOnWifiProvider extends $FunctionalProvider<bool, bool, bool>
    with $Provider<bool> {
  /// Provider for WiFi-only sync boolean (for easy access)
  SyncOnlyOnWifiProvider._()
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
