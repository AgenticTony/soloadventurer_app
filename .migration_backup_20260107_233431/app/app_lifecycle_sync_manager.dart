import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/core/services/connectivity_service.dart';
import 'package:soloadventurer/features/offline/presentation/providers/sync_status_provider.dart';
import 'package:soloadventurer/features/offline/presentation/providers/sync_settings_provider.dart';
import 'package:soloadventurer/features/offline/presentation/providers/connectivity_provider.dart';

/// Widget that monitors app lifecycle and triggers sync when app returns to foreground
///
/// This widget implements the following features:
/// - Listens to app lifecycle changes (foreground/background)
/// - Triggers sync when app returns to foreground
/// - Implements debouncing to avoid excessive syncs (minimum interval)
/// - Respects user preferences (sync enabled, WiFi-only)
/// - Only syncs when network is available
class AppLifecycleSyncManager extends ConsumerStatefulWidget {
  /// Child widget to wrap
  final Widget child;

  /// Minimum time between foreground syncs (default: 30 seconds)
  final Duration minSyncInterval;

  /// Creates a new [AppLifecycleSyncManager] instance
  const AppLifecycleSyncManager({
    super.key,
    required this.child,
    this.minSyncInterval = const Duration(seconds: 30),
  });

  @override
  ConsumerState<AppLifecycleSyncManager> createState() =>
      _AppLifecycleSyncManagerState();
}

class _AppLifecycleSyncManagerState
    extends ConsumerState<AppLifecycleSyncManager>
    with WidgetsBindingObserver {
  /// Timestamp of last foreground sync trigger
  DateTime? _lastForegroundSyncTime;

  /// Current app lifecycle state
  AppLifecycleState? _lifecycleState;

  @override
  void initState() {
    super.initState();
    // Register this widget as a lifecycle observer
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    // Unregister lifecycle observer
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    super.didChangeAppLifecycleState(state);

    _lifecycleState = state;

    // Trigger sync when app returns to foreground
    if (state == AppLifecycleState.resumed) {
      _onAppResumed();
    }
  }

  /// Called when the app is resumed/returns to foreground
  void _onAppResumed() {
    debugPrint('🔄 App returned to foreground - checking if sync should run');

    // Check if enough time has passed since last sync
    if (_lastForegroundSyncTime != null) {
      final timeSinceLastSync =
          DateTime.now().difference(_lastForegroundSyncTime!);
      if (timeSinceLastSync < widget.minSyncInterval) {
        final remainingTime =
            widget.minSyncInterval - timeSinceLastSync;
        debugPrint(
          '⏱️ Skipping foreground sync - not enough time elapsed. '
          'Remaining: ${remainingTime.inSeconds}s',
        );
        return;
      }
    }

    // Get current state
    final syncSettings = ref.read(syncSettingsProvider);
    final connectivityState = ref.read(connectivityProvider);
    final syncStatus = ref.read(syncStatusProvider);

    // Check if sync is enabled
    if (!syncSettings.syncEnabled) {
      debugPrint('🔄 Sync is disabled in user preferences - skipping');
      return;
    }

    // Check if device is connected to network
    if (!connectivityState.isConnected) {
      debugPrint('🔄 No network connectivity - skipping foreground sync');
      return;
    }

    // Check WiFi-only preference
    if (syncSettings.syncOnlyOnWifi) {
      if (connectivityState.connectionType != ConnectionType.wifi) {
        debugPrint(
          '🔄 WiFi-only mode enabled but not on WiFi - skipping sync',
        );
        return;
      }
    }

    // Check if sync is already running
    if (syncStatus.isSyncing) {
      debugPrint('🔄 Sync already in progress - skipping foreground sync');
      return;
    }

    // All checks passed - trigger sync
    _triggerForegroundSync();
  }

  /// Triggers a foreground sync
  Future<void> _triggerForegroundSync() async {
    debugPrint('🔄 Triggering foreground sync...');

    // Update last sync time
    _lastForegroundSyncTime = DateTime.now();

    try {
      // Get the sync status notifier
      final syncNotifier = ref.read(syncStatusProvider.notifier);

      // Trigger sync
      final result = await syncNotifier.triggerSync();

      if (result.success) {
        debugPrint(
          '✅ Foreground sync completed successfully '
          '(uploaded: ${result.uploadedCount}, downloaded: ${result.downloadedCount})',
        );
      } else {
        debugPrint(
          '⚠️ Foreground sync failed: ${result.errorMessage}',
        );
      }
    } catch (e) {
      debugPrint('❌ Error triggering foreground sync: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Simply return the child widget - this widget's purpose is lifecycle observation
    return widget.child;
  }
}
