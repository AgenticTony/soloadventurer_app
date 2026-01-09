import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:soloadventurer/features/offline/domain/services/sync_manager.dart';
import 'package:soloadventurer/core/services/notification_service.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:shared_preferences/shared_preferences.dart';

part 'sync_notification_service.g.dart';

/// Sync notification preferences
class SyncNotificationPreferences {
  /// Whether to show notifications when sync completes successfully
  final bool notifyOnSuccess;

  /// Whether to show notifications when sync fails
  final bool notifyOnFailure;

  /// Whether to show notifications when pending operations exceed threshold
  final bool notifyOnPendingThreshold;

  /// Threshold for pending operations before showing notification
  final int pendingThreshold;

  /// Whether to show notifications when conflicts require user action
  final bool notifyOnConflicts;

  /// Creates a new [SyncNotificationPreferences] instance
  const SyncNotificationPreferences({
    this.notifyOnSuccess = false,
    this.notifyOnFailure = true,
    this.notifyOnPendingThreshold = true,
    this.pendingThreshold = 10,
    this.notifyOnConflicts = true,
  });

  /// Creates a copy with updated fields
  SyncNotificationPreferences copyWith({
    bool? notifyOnSuccess,
    bool? notifyOnFailure,
    bool? notifyOnPendingThreshold,
    int? pendingThreshold,
    bool? notifyOnConflicts,
  }) {
    return SyncNotificationPreferences(
      notifyOnSuccess: notifyOnSuccess ?? this.notifyOnSuccess,
      notifyOnFailure: notifyOnFailure ?? this.notifyOnFailure,
      notifyOnPendingThreshold:
          notifyOnPendingThreshold ?? this.notifyOnPendingThreshold,
      pendingThreshold: pendingThreshold ?? this.pendingThreshold,
      notifyOnConflicts: notifyOnConflicts ?? this.notifyOnConflicts,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SyncNotificationPreferences &&
          runtimeType == other.runtimeType &&
          notifyOnSuccess == other.notifyOnSuccess &&
          notifyOnFailure == other.notifyOnFailure &&
          notifyOnPendingThreshold == other.notifyOnPendingThreshold &&
          pendingThreshold == other.pendingThreshold &&
          notifyOnConflicts == other.notifyOnConflicts;

  @override
  int get hashCode =>
      notifyOnSuccess.hashCode ^
      notifyOnFailure.hashCode ^
      notifyOnPendingThreshold.hashCode ^
      pendingThreshold.hashCode ^
      notifyOnConflicts.hashCode;
}

/// Sync notification service for showing local notifications
///
/// This service monitors sync status changes and displays appropriate
/// local notifications to keep users informed about sync events.
///
/// The service provides notifications for:
/// - Sync completion (configurable)
/// - Sync failures
/// - Pending operations exceeding threshold
/// - Conflicts requiring user action
///
/// Example usage:
/// ```dart
/// final notificationService = SyncNotificationService(
///   syncManager: syncManager,
///   notificationService: notificationService,
///   preferences: SyncNotificationPreferences(),
/// );
///
/// await notificationService.initialize();
/// ```
class SyncNotificationService {
  /// Sync manager for monitoring sync status
  final SyncManager _syncManager;

  /// Notification service for displaying notifications
  final NotificationService _notificationService;

  /// SharedPreferences for persisting notification preferences
  final SharedPreferences _prefs;

  /// Notification preferences
  SyncNotificationPreferences _preferences;

  /// Stream subscription to sync status
  StreamSubscription<SyncStatus>? _syncStatusSubscription;

  /// Last known pending operations count
  int _lastPendingCount = 0;

  /// Tag for logging
  static const String _tag = '🔔 SyncNotification';

  /// Notification channel ID for sync notifications
  static const String _channelId = 'com.soloadventurer.sync';

  /// Notification channel name
  static const String _channelName = 'Sync Notifications';

  /// Notification channel description
  static const String _channelDescription =
      'Notifications for sync events and status updates';

  /// SharedPreferences keys
  static const String _keyNotifyOnSuccess = 'sync_notify_success';
  static const String _keyNotifyOnFailure = 'sync_notify_failure';
  static const String _keyNotifyOnPending = 'sync_notify_pending';
  static const String _keyPendingThreshold = 'sync_pending_threshold';
  static const String _keyNotifyOnConflicts = 'sync_notify_conflicts';

  /// Creates a new [SyncNotificationService] instance
  ///
  /// [syncManager] - Sync manager for monitoring sync status
  /// [notificationService] - Notification service for displaying notifications
  /// [prefs] - SharedPreferences for persisting preferences
  /// [preferences] - Initial notification preferences (loaded from storage if not provided)
  SyncNotificationService({
    required SyncManager syncManager,
    required NotificationService notificationService,
    required SharedPreferences prefs,
    SyncNotificationPreferences? preferences,
  })  : _syncManager = syncManager,
        _notificationService = notificationService,
        _prefs = prefs,
        _preferences = preferences ?? const SyncNotificationPreferences();

  /// Gets the current notification preferences
  SyncNotificationPreferences get preferences => _preferences;

  /// Initializes the sync notification service
  ///
  /// This method:
  /// 1. Loads notification preferences from storage
  /// 2. Starts listening to sync status changes
  /// 3. Creates notification channel (Android)
  ///
  /// Returns [true] if initialization was successful.
  Future<bool> initialize() async {
    try {
      debugPrint('$_tag: Initializing sync notification service...');

      // Load preferences from storage
      await _loadPreferences();

      // Start monitoring sync status
      _startMonitoring();

      debugPrint('$_tag: ✅ Initialized successfully');
      debugPrint('$_tag: Preferences: $_preferences');

      return true;
    } catch (e, stackTrace) {
      debugPrint('$_tag: ❌ Initialization failed: $e');
      debugPrint('$_tag: Stack trace: $stackTrace');
      return false;
    }
  }

  /// Starts monitoring sync status for notification triggers
  void _startMonitoring() {
    // Subscribe to sync status stream
    _syncStatusSubscription = _syncManager.syncStatusStream.listen(
      (status) => _handleSyncStatusChange(status),
      onError: (error) {
        debugPrint('$_tag: ❌ Error in sync status stream: $error');
      },
    );

    debugPrint('$_tag: Started monitoring sync status');
  }

  /// Handles sync status changes and shows appropriate notifications
  void _handleSyncStatusChange(SyncStatus status) {
    // Check for different sync events and show notifications

    // 1. Check for sync completion
    if (status.state == SyncState.idle &&
        status.lastSyncTime != null &&
        _preferences.notifyOnSuccess) {
      _showSyncSuccessNotification();
    }

    // 2. Check for sync failure
    if (status.state == SyncState.error &&
        _preferences.notifyOnFailure) {
      _showSyncFailureNotification(status.errorMessage);
    }

    // 3. Check for pending operations threshold
    if (_preferences.notifyOnPendingThreshold) {
      _checkPendingOperationsThreshold(status.pendingOperations);
    }

    // Update last pending count
    _lastPendingCount = status.pendingOperations;
  }

  /// Shows a notification when sync completes successfully
  Future<void> _showSyncSuccessNotification() async {
    try {
      const title = 'Sync Complete';
      const body = 'Your data has been synchronized successfully';

      debugPrint('$_tag: Showing success notification');

      await _notificationService.show(
        title: title,
        body: body,
        notificationId: _generateNotificationId('success'),
        channel: _channelId,
      );
    } catch (e) {
      debugPrint('$_tag: ❌ Failed to show success notification: $e');
    }
  }

  /// Shows a notification when sync fails
  Future<void> _showSyncFailureNotification(String? errorMessage) async {
    try {
      const title = 'Sync Failed';
      final body = errorMessage ?? 'An error occurred during synchronization';
      final truncatedBody =
          body.length > 100 ? '${body.substring(0, 97)}...' : body;

      debugPrint('$_tag: Showing failure notification: $truncatedBody');

      await _notificationService.show(
        title: title,
        body: truncatedBody,
        notificationId: _generateNotificationId('failure'),
        channel: _channelId,
      );
    } catch (e) {
      debugPrint('$_tag: ❌ Failed to show failure notification: $e');
    }
  }

  /// Shows a notification when pending operations exceed threshold
  Future<void> _showPendingOperationsNotification(int count) async {
    try {
      const title = 'Pending Sync Operations';
      final body =
          'You have $count changes waiting to sync. Connect to the internet to sync.';

      debugPrint('$_tag: Showing pending operations notification: $count');

      await _notificationService.show(
        title: title,
        body: body,
        notificationId: _generateNotificationId('pending_$count'),
        channel: _channelId,
      );
    } catch (e) {
      debugPrint('$_tag: ❌ Failed to show pending notification: $e');
    }
  }

  /// Shows a notification when conflicts require user action
  Future<void> showConflictNotification(int conflictCount) async {
    if (!_preferences.notifyOnConflicts) {
      return;
    }

    try {
      const title = 'Sync Conflicts Detected';
      final body =
          '$conflictCount conflict(s) need your attention. Please review and resolve.';

      debugPrint('$_tag: Showing conflict notification: $conflictCount');

      await _notificationService.show(
        title: title,
        body: body,
        notificationId: _generateNotificationId('conflict_$conflictCount'),
        channel: _channelId,
      );
    } catch (e) {
      debugPrint('$_tag: ❌ Failed to show conflict notification: $e');
    }
  }

  /// Checks if pending operations have exceeded the threshold
  void _checkPendingOperationsThreshold(int currentCount) {
    // Only show notification when crossing threshold upward
    if (_lastPendingCount < _preferences.pendingThreshold &&
        currentCount >= _preferences.pendingThreshold) {
      _showPendingOperationsNotification(currentCount);
    }
  }

  /// Updates notification preferences
  ///
  /// Updates the specified preference and persists it to storage.
  Future<void> updatePreferences(
      SyncNotificationPreferences newPreferences) async {
    try {
      // Save to storage
      await _prefs.setBool(_keyNotifyOnSuccess, newPreferences.notifyOnSuccess);
      await _prefs.setBool(_keyNotifyOnFailure, newPreferences.notifyOnFailure);
      await _prefs.setBool(
          _keyNotifyOnPending, newPreferences.notifyOnPendingThreshold);
      await _prefs.setInt(_keyPendingThreshold, newPreferences.pendingThreshold);
      await _prefs.setBool(
          _keyNotifyOnConflicts, newPreferences.notifyOnConflicts);

      // Update local preferences
      _preferences = newPreferences;

      debugPrint('$_tag: ✅ Preferences updated: $_preferences');
    } catch (e) {
      debugPrint('$_tag: ❌ Failed to update preferences: $e');
      rethrow;
    }
  }

  /// Loads notification preferences from SharedPreferences
  Future<void> _loadPreferences() async {
    try {
      final notifyOnSuccess = _prefs.getBool(_keyNotifyOnSuccess) ?? true;
      final notifyOnFailure = _prefs.getBool(_keyNotifyOnFailure) ?? true;
      final notifyOnPending =
          _prefs.getBool(_keyNotifyOnPending) ?? true;
      final pendingThreshold = _prefs.getInt(_keyPendingThreshold) ?? 10;
      final notifyOnConflicts = _prefs.getBool(_keyNotifyOnConflicts) ?? true;

      _preferences = SyncNotificationPreferences(
        notifyOnSuccess: notifyOnSuccess,
        notifyOnFailure: notifyOnFailure,
        notifyOnPendingThreshold: notifyOnPending,
        pendingThreshold: pendingThreshold,
        notifyOnConflicts: notifyOnConflicts,
      );

      debugPrint('$_tag: Preferences loaded from storage');
    } catch (e) {
      debugPrint('$_tag: ❌ Failed to load preferences, using defaults: $e');
      // Keep default preferences
    }
  }

  /// Generates a unique notification ID based on the notification type
  ///
  /// Uses timestamp to ensure uniqueness while maintaining some consistency.
  int _generateNotificationId(String type) {
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final typeHash = type.hashCode;
    return (timestamp + typeHash) % 100000;
  }

  /// Pauses notifications
  ///
  /// Stops showing notifications temporarily. Can be resumed with [resume].
  void pause() {
    debugPrint('$_tag: ⏸️ Pausing notifications');
    _syncStatusSubscription?.pause();
  }

  /// Resumes notifications
  ///
  /// Resumes showing notifications after being paused.
  void resume() {
    debugPrint('$_tag: ▶️ Resuming notifications');
    _syncStatusSubscription?.resume();
  }

  /// Disposes of resources
  ///
  /// Cancels subscriptions and cleans up resources.
  void dispose() {
    debugPrint('$_tag: Disposing sync notification service');

    _syncStatusSubscription?.cancel();
    _syncStatusSubscription = null;
  }
}

/// Provider for SyncNotificationService
///
/// This provider creates and manages the SyncNotificationService instance.
/// It auto-disposes when no longer being listened to.
@riverpod
SyncNotificationService syncNotificationService(Ref ref) {
  throw UnimplementedError(
    'SyncNotificationService provider must be overridden in main app initialization. '
    'Use ProviderScope with overrides or GetIt DI to provide the service.',
  );
}
