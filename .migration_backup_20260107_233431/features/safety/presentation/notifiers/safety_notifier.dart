import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/safety/data/repositories/safety_providers.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_status.dart';
import 'package:soloadventurer/features/safety/domain/entities/safety_alert.dart';
import 'package:soloadventurer/features/safety/domain/providers/safety_usecase_providers.dart';

part 'safety_notifier.freezed.dart';
part 'safety_notifier.g.dart';

/// Data class for safety state
@freezed
class SafetyData with _$SafetyData {
  const SafetyData._();

  const factory SafetyData({
    SafetyStatus? currentStatus,
    @Default([]) List<SafetyAlert> recentAlerts,
    @Default([]) List<SafetyAlert> activeAlerts,
    @Default(0) int trustedContactsCount,
  }) = _SafetyData;

  /// Whether there's an active emergency
  bool get hasActiveEmergency => activeAlerts.isNotEmpty;

  /// Whether the current status indicates danger
  bool get isInDanger =>
      currentStatus?.status == SafetyStatusType.emergency ||
      currentStatus?.status == SafetyStatusType.needHelp;

  /// Whether safety feature is initialized
  bool get isInitialized => currentStatus != null;
}

/// Notifier for managing overall safety state
/// Handles safety status, emergency SOS, and safety alerts
@riverpod
class SafetyNotifier extends _$SafetyNotifier {
  /// Initialize safety state by loading current status and alerts
  Future<void> initialize() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final currentStatus = await ref.read(getSafetyStatusUseCaseProvider)();
      final repository = ref.read(safetyRepositoryOverrideProvider);
      final recentAlerts = await repository.getRecentSafetyAlerts(limit: 10);
      final activeAlerts = recentAlerts
          .where((alert) => alert.status == SafetyAlertStatus.sent ||
                         alert.status == SafetyAlertStatus.acknowledged)
          .toList();
      final contacts = await repository.getTrustedContacts();

      return SafetyData(
        currentStatus: currentStatus,
        recentAlerts: recentAlerts,
        activeAlerts: activeAlerts,
        trustedContactsCount: contacts.length,
      );
    });
  }

  /// Load current safety status
  Future<void> loadSafetyStatus() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final status = await ref.read(getSafetyStatusUseCaseProvider)();

      final currentData = state.value ?? const SafetyData();
      return currentData.copyWith(currentStatus: status);
    });
  }

  /// Trigger emergency SOS with progress reporting
  ///
  /// Uses Riverpod 3.0's progress reporting feature to provide
  /// feedback during this critical operation.
  /// Progress values:
  /// - 0.0 = started
  /// - 0.3 = fetching contacts
  /// - 0.6 = sending alerts
  /// - 1.0 = complete
  Future<void> triggerEmergencySOS({
    required String userId,
    required SafetyAlertLocation location,
    String? message,
    List<String>? notifyContactIds,
    int? batteryLevel,
    String? tripId,
  }) async {
    state = const AsyncLoading(progress: 0.0);

    state = await AsyncValue.guard(() async {
      final repository = ref.read(safetyRepositoryOverrideProvider);

      // Update progress: fetching contacts
      state = const AsyncLoading(progress: 0.3);

      // Get all trusted contacts if none specified
      final contacts = notifyContactIds ??
          (await repository.getTrustedContacts())
              .where((c) => c.receivesEmergencyAlerts)
              .map((c) => c.id)
              .toList();

      // Update progress: sending alerts
      state = const AsyncLoading(progress: 0.6);

      final alert = await ref.read(triggerEmergencySOSUseCaseProvider)(
        userId: userId,
        location: location,
        message: message,
        notifyContactIds: contacts,
        batteryLevel: batteryLevel,
        tripId: tripId,
      );

      // Update progress: completing
      state = const AsyncLoading(progress: 0.9);

      final currentData = state.value ?? const SafetyData();
      final updatedAlerts = [alert, ...currentData.recentAlerts];
      final updatedActiveAlerts = [alert, ...currentData.activeAlerts];

      return currentData.copyWith(
        recentAlerts: updatedAlerts,
        activeAlerts: updatedActiveAlerts,
      );
    });
  }

  /// Update safety status
  Future<void> updateSafetyStatus({
    required SafetyStatusType status,
    String? message,
    SafetyStatusLocation? location,
    int? batteryLevel,
    String? safetyAlertId,
    String? checkInId,
  }) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final updatedStatus = await ref.read(updateSafetyStatusUseCaseProvider)(
        status: status,
        message: message,
        location: location,
        batteryLevel: batteryLevel,
        safetyAlertId: safetyAlertId,
        checkInId: checkInId,
      );

      final currentData = state.value ?? const SafetyData();
      return currentData.copyWith(currentStatus: updatedStatus);
    });
  }

  /// Mark user as safe
  Future<void> markAsSafe({
    String? message,
    SafetyStatusLocation? location,
    int? batteryLevel,
  }) async {
    await updateSafetyStatus(
      status: SafetyStatusType.safe,
      message: message,
      location: location,
      batteryLevel: batteryLevel,
    );
  }

  /// Mark user as needing help
  Future<void> markAsNeedHelp({
    String? message,
    SafetyStatusLocation? location,
    int? batteryLevel,
  }) async {
    await updateSafetyStatus(
      status: SafetyStatusType.needHelp,
      message: message,
      location: location,
      batteryLevel: batteryLevel,
    );
  }

  /// Mark user as in emergency
  Future<void> markAsEmergency({
    String? message,
    SafetyStatusLocation? location,
    int? batteryLevel,
    String? safetyAlertId,
  }) async {
    await updateSafetyStatus(
      status: SafetyStatusType.emergency,
      message: message,
      location: location,
      batteryLevel: batteryLevel,
      safetyAlertId: safetyAlertId,
    );
  }

  /// Load recent safety alerts
  Future<void> loadRecentAlerts({int limit = 20}) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(safetyRepositoryOverrideProvider);
      final recentAlerts = await repository.getRecentSafetyAlerts(limit: limit);
      final activeAlerts = recentAlerts
          .where((alert) => alert.status == SafetyAlertStatus.sent ||
                         alert.status == SafetyAlertStatus.acknowledged)
          .toList();

      final currentData = state.value ?? const SafetyData();
      return currentData.copyWith(
        recentAlerts: recentAlerts,
        activeAlerts: activeAlerts,
      );
    });
  }

  /// Acknowledge a safety alert (as a trusted contact)
  Future<void> acknowledgeAlert(String alertId, String contactId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(safetyRepositoryOverrideProvider);
      await repository.acknowledgeSafetyAlert(alertId, contactId);

      final currentData = state.value ?? const SafetyData();

      final updatedAlerts = currentData.recentAlerts.map((alert) {
        if (alert.id == alertId) {
          final acknowledgedByContactIds = [...alert.acknowledgedByContactIds, contactId];
          return alert.copyWith(acknowledgedByContactIds: acknowledgedByContactIds);
        }
        return alert;
      }).toList();

      final updatedActiveAlerts = currentData.activeAlerts.map((alert) {
        if (alert.id == alertId) {
          final acknowledgedByContactIds = [...alert.acknowledgedByContactIds, contactId];
          return alert.copyWith(acknowledgedByContactIds: acknowledgedByContactIds);
        }
        return alert;
      }).toList();

      return currentData.copyWith(
        recentAlerts: updatedAlerts,
        activeAlerts: updatedActiveAlerts,
      );
    });
  }

  /// Resolve a safety alert (user is safe)
  Future<void> resolveAlert(String alertId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(safetyRepositoryOverrideProvider);
      await repository.resolveSafetyAlert(alertId);

      final currentData = state.value ?? const SafetyData();

      final updatedAlerts = currentData.recentAlerts.map((alert) {
        return alert.id == alertId
            ? alert.copyWith(status: SafetyAlertStatus.resolved)
            : alert;
      }).toList();

      final updatedActiveAlerts = currentData.activeAlerts
          .where((alert) => alert.id != alertId)
          .toList();

      return currentData.copyWith(
        recentAlerts: updatedAlerts,
        activeAlerts: updatedActiveAlerts,
      );
    });
  }

  /// Cancel a safety alert (false alarm)
  Future<void> cancelAlert(String alertId) async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(safetyRepositoryOverrideProvider);
      await repository.cancelSafetyAlert(alertId);

      final currentData = state.value ?? const SafetyData();

      final updatedAlerts = currentData.recentAlerts.map((alert) {
        return alert.id == alertId
            ? alert.copyWith(status: SafetyAlertStatus.cancelled)
            : alert;
      }).toList();

      final updatedActiveAlerts = currentData.activeAlerts
          .where((alert) => alert.id != alertId)
          .toList();

      return currentData.copyWith(
        recentAlerts: updatedAlerts,
        activeAlerts: updatedActiveAlerts,
      );
    });
  }

  /// Get missed check-in alerts
  Future<void> loadMissedCheckInAlerts() async {
    state = const AsyncLoading();

    state = await AsyncValue.guard(() async {
      final repository = ref.read(safetyRepositoryOverrideProvider);
      final missedAlerts = await repository.getMissedCheckInAlerts();

      final currentData = state.value ?? const SafetyData();
      return currentData.copyWith(recentAlerts: missedAlerts);
    });
  }

  /// Update battery level
  Future<void> updateBatteryLevel(int level) async {
    final repository = ref.read(safetyRepositoryOverrideProvider);
    await repository.updateBatteryLevel(level);
  }

  /// Get current battery level
  Future<int?> getBatteryLevel() async {
    try {
      final repository = ref.read(safetyRepositoryOverrideProvider);
      return await repository.getBatteryLevel();
    } catch (e) {
      return null;
    }
  }

  /// Update trusted contacts count
  Future<void> updateContactsCount() async {
    try {
      final repository = ref.read(safetyRepositoryOverrideProvider);
      final contacts = await repository.getTrustedContacts();

      final currentData = state.value;
      if (currentData != null) {
        state = AsyncValue.data(currentData.copyWith(trustedContactsCount: contacts.length));
      }
    } catch (e) {
      // Handle error silently or update state with error
    }
  }

  /// Refresh all safety data
  Future<void> refresh() async {
    await initialize();
  }

  @override
  AsyncValue<SafetyData> build() {
    // Don't auto-initialize - let consumers explicitly call initialize()
    // This allows for better control over when initialization happens
    return const AsyncValue.data(SafetyData());
  }
}
