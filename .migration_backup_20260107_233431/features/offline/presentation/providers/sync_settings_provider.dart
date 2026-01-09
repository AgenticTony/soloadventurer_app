import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';
import 'package:soloadventurer/app/providers/core_service_providers.dart';

part 'sync_settings_provider.g.dart';

/// Sync settings preferences
class SyncSettings {
  /// Whether sync is enabled
  final bool syncEnabled;

  /// Whether to sync only on WiFi
  final bool syncOnlyOnWifi;

  /// Created a new [SyncSettings] instance
  const SyncSettings({
    this.syncEnabled = true,
    this.syncOnlyOnWifi = false,
  });

  /// Creates a copy with updated fields
  SyncSettings copyWith({
    bool? syncEnabled,
    bool? syncOnlyOnWifi,
  }) {
    return SyncSettings(
      syncEnabled: syncEnabled ?? this.syncEnabled,
      syncOnlyOnWifi: syncOnlyOnWifi ?? this.syncOnlyOnWifi,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncSettings &&
          runtimeType == other.runtimeType &&
          syncEnabled == other.syncEnabled &&
          syncOnlyOnWifi == other.syncOnlyOnWifi;

  @override
  int get hashCode => syncEnabled.hashCode ^ syncOnlyOnWifi.hashCode;
}

/// Re-export of sharedPreferencesProvider from app/providers/core_service_providers.dart
/// The sharedPreferencesProvider is now defined in app/providers/core_service_providers.dart

/// Notifier for sync settings
@riverpod
class SyncSettingsNotifier extends _$SyncSettingsNotifier {
  /// Key for sync enabled preference
  static const String _syncEnabledKey = 'sync_enabled';

  /// Key for WiFi-only sync preference
  static const String _syncOnlyOnWifiKey = 'sync_only_on_wifi';

  @override
  SyncSettings build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    _prefs = prefs;
    _loadSettings();
    return const SyncSettings();
  }

  late final SharedPreferences _prefs;

  /// Loads settings from SharedPreferences
  void _loadSettings() {
    try {
      final syncEnabled = _prefs.getBool(_syncEnabledKey) ?? true;
      final syncOnlyOnWifi = _prefs.getBool(_syncOnlyOnWifiKey) ?? false;

      state = SyncSettings(
        syncEnabled: syncEnabled,
        syncOnlyOnWifi: syncOnlyOnWifi,
      );

      debugPrint('📱 SyncSettings loaded: enabled=$syncEnabled, wifiOnly=$syncOnlyOnWifi');
    } catch (e) {
      debugPrint('❌ Error loading sync settings: $e');
      // Keep default values
    }
  }

  /// Updates sync enabled setting
  Future<void> setSyncEnabled(bool value) async {
    try {
      await _prefs.setBool(_syncEnabledKey, value);
      state = state.copyWith(syncEnabled: value);
      debugPrint('📱 Sync enabled updated: $value');
    } catch (e) {
      debugPrint('❌ Error updating sync enabled: $e');
      rethrow;
    }
  }

  /// Updates sync only on WiFi setting
  Future<void> setSyncOnlyOnWifi(bool value) async {
    try {
      await _prefs.setBool(_syncOnlyOnWifiKey, value);
      state = state.copyWith(syncOnlyOnWifi: value);
      debugPrint('📱 Sync WiFi-only updated: $value');
    } catch (e) {
      debugPrint('❌ Error updating sync WiFi-only: $e');
      rethrow;
    }
  }

  /// Resets all settings to defaults
  Future<void> resetToDefaults() async {
    try {
      await _prefs.remove(_syncEnabledKey);
      await _prefs.remove(_syncOnlyOnWifiKey);
      state = const SyncSettings();
      debugPrint('📱 Sync settings reset to defaults');
    } catch (e) {
      debugPrint('❌ Error resetting sync settings: $e');
      rethrow;
    }
  }
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
