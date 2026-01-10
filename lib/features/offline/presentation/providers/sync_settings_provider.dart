import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

part 'sync_settings_provider.g.dart';

/// Riverpod 3.0 Migration Notes:
/// - Converted from StateNotifier<SyncSettings> to Notifier<SyncSettingsData>
/// - Dependencies injected via ref.watch() in build() method
/// - build() returns SyncSettingsData not AsyncValue
/// - Constructor auto-load moved to build() method
/// - SharedPreferences persistence in mutation methods

/// Sync settings preferences
class SyncSettingsData {
  final bool syncEnabled;
  final bool syncOnlyOnWifi;

  const SyncSettingsData({
    this.syncEnabled = true,
    this.syncOnlyOnWifi = false,
  });

  SyncSettingsData copyWith({
    bool? syncEnabled,
    bool? syncOnlyOnWifi,
  }) {
    return SyncSettingsData(
      syncEnabled: syncEnabled ?? this.syncEnabled,
      syncOnlyOnWifi: syncOnlyOnWifi ?? this.syncOnlyOnWifi,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncSettingsData &&
          runtimeType == other.runtimeType &&
          syncEnabled == other.syncEnabled &&
          syncOnlyOnWifi == other.syncOnlyOnWifi;

  @override
  int get hashCode => syncEnabled.hashCode ^ syncOnlyOnWifi.hashCode;
}

/// Notifier for sync settings
///
/// Riverpod 3.0: Uses @riverpod annotation with Notifier pattern.
@riverpod
class SyncSettings extends _$SyncSettings {
  static const String _syncEnabledKey = 'sync_enabled';
  static const String _syncOnlyOnWifiKey = 'sync_only_on_wifi';

  @override
  SyncSettingsData build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    _loadSettings(prefs);
    return const SyncSettingsData();
  }

  void _loadSettings(SharedPreferences prefs) {
    try {
      final syncEnabled = prefs.getBool(_syncEnabledKey) ?? true;
      final syncOnlyOnWifi = prefs.getBool(_syncOnlyOnWifiKey) ?? false;

      state = SyncSettingsData(
        syncEnabled: syncEnabled,
        syncOnlyOnWifi: syncOnlyOnWifi,
      );

      debugPrint(
          'SyncSettings loaded: enabled=$syncEnabled, wifiOnly=$syncOnlyOnWifi');
    } catch (e) {
      debugPrint('Error loading sync settings: $e');
    }
  }

  Future<void> setSyncEnabled(bool value) async {
    final prefs = ref.read(sharedPreferencesProvider);
    try {
      await prefs.setBool(_syncEnabledKey, value);
      state = state.copyWith(syncEnabled: value);
      debugPrint('Sync enabled updated: $value');
    } catch (e) {
      debugPrint('Error updating sync enabled: $e');
      rethrow;
    }
  }

  Future<void> setSyncOnlyOnWifi(bool value) async {
    final prefs = ref.read(sharedPreferencesProvider);
    try {
      await prefs.setBool(_syncOnlyOnWifiKey, value);
      state = state.copyWith(syncOnlyOnWifi: value);
      debugPrint('Sync WiFi-only updated: $value');
    } catch (e) {
      debugPrint('Error updating sync WiFi-only: $e');
      rethrow;
    }
  }

  Future<void> resetToDefaults() async {
    final prefs = ref.read(sharedPreferencesProvider);
    try {
      await prefs.remove(_syncEnabledKey);
      await prefs.remove(_syncOnlyOnWifiKey);
      state = const SyncSettingsData();
      debugPrint('Sync settings reset to defaults');
    } catch (e) {
      debugPrint('Error resetting sync settings: $e');
      rethrow;
    }
  }
}

/// Provider for SharedPreferences instance
@riverpod
SharedPreferences sharedPreferences(Ref ref) {
  throw UnimplementedError(
    'SharedPreferencesProvider must be overridden in main app initialization. '
    'Use ProviderScope with overrides to provide SharedPreferences instance.',
  );
}

/// Provider for sync enabled boolean (for easy access)
@riverpod
bool syncEnabled(Ref ref) {
  return ref.watch(syncSettingsProvider).syncEnabled;
}

/// Provider for WiFi-only sync boolean (for easy access)
@riverpod
bool syncOnlyOnWifi(Ref ref) {
  return ref.watch(syncSettingsProvider).syncOnlyOnWifi;
}
