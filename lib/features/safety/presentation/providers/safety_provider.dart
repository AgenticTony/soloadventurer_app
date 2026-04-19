import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../domain/usecases/trigger_emergency_sos.dart';
import '../../domain/usecases/update_safety_status.dart';
import '../../domain/usecases/get_safety_status.dart';
import '../../domain/repositories/safety_repository.dart';
import '../../domain/entities/safety_status.dart';
import '../../domain/entities/safety_alert.dart';
import '../state/safety_state.dart';
import 'safety_providers.dart';
import '../../data/repositories/safety_providers.dart' as data;

part 'safety_provider.g.dart';

/// AsyncNotifier for managing overall safety state.
///
/// Riverpod 3.0 Compliant:
/// - Uses @riverpod annotation with code generation
/// - AsyncNotifier with AsyncValue handles loading/error
/// - State no longer has isLoading/error fields
@riverpod
class Safety extends _$Safety {
  @override
  Future<SafetyState> build() async => SafetyState.initial();

  TriggerEmergencySOSUseCase get _triggerSOS =>
      ref.watch(triggerEmergencySOSUseCaseProvider);
  UpdateSafetyStatusUseCase get _updateStatus =>
      ref.watch(updateSafetyStatusUseCaseProvider);
  GetSafetyStatusUseCase get _getStatus =>
      ref.watch(getSafetyStatusUseCaseProvider);
  SafetyRepository get _repository =>
      ref.watch(data.safetyRepositoryOverrideProvider);

  /// Initialize safety state by loading current status and alerts
  Future<void> initialize() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final currentStatus = await _getStatus();
      final recentAlerts = await _repository.getRecentSafetyAlerts(limit: 10);
      final activeAlerts = recentAlerts
          .where((alert) =>
              alert.status == SafetyAlertStatus.sent ||
              alert.status == SafetyAlertStatus.acknowledged)
          .toList();
      final contacts = await _repository.getTrustedContacts();

      return (state.value ?? SafetyState.initial()).copyWith(
        currentStatus: currentStatus,
        recentAlerts: recentAlerts,
        activeAlerts: activeAlerts,
        trustedContactsCount: contacts.length,
      );
    });
  }

  /// Load current safety status
  Future<void> loadSafetyStatus() async {
    final current = state.value;
    if (current == null || current.isProcessing) return;

    state = AsyncData(current.copyWith(isProcessing: true));
    state = await AsyncValue.guard(() async {
      final status = await _getStatus();
      return (state.value ?? current).copyWith(
        isProcessing: false,
        currentStatus: status,
      );
    });
  }

  /// Trigger emergency SOS
  Future<void> triggerEmergencySOS({
    required String userId,
    required SafetyAlertLocation location,
    String? message,
    List<String>? notifyContactIds,
    int? batteryLevel,
    String? tripId,
  }) async {
    final current = state.value;
    if (current == null || current.isProcessing) return;

    state = AsyncData(current.copyWith(isProcessing: true));
    state = await AsyncValue.guard(() async {
      final contacts = notifyContactIds ??
          (await _repository.getTrustedContacts())
              .where((c) => c.receivesEmergencyAlerts)
              .map((c) => c.id)
              .toList();

      final alert = await _triggerSOS(
        userId: userId,
        location: location,
        message: message,
        notifyContactIds: contacts,
        batteryLevel: batteryLevel,
        tripId: tripId,
      );

      final updatedAlerts = [alert, ...current.recentAlerts];
      final updatedActiveAlerts = [alert, ...current.activeAlerts];

      return current.copyWith(
        isProcessing: false,
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
    final current = state.value;
    if (current == null || current.isProcessing) return;

    state = AsyncData(current.copyWith(isProcessing: true));
    state = await AsyncValue.guard(() async {
      final updatedStatus = await _updateStatus(
        status: status,
        message: message,
        location: location,
        batteryLevel: batteryLevel,
        safetyAlertId: safetyAlertId,
        checkInId: checkInId,
      );

      return current.copyWith(
        isProcessing: false,
        currentStatus: updatedStatus,
      );
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
      final recentAlerts =
          await _repository.getRecentSafetyAlerts(limit: limit);
      final activeAlerts = recentAlerts
          .where((alert) =>
              alert.status == SafetyAlertStatus.sent ||
              alert.status == SafetyAlertStatus.acknowledged)
          .toList();

      return (state.value ?? SafetyState.initial()).copyWith(
        recentAlerts: recentAlerts,
        activeAlerts: activeAlerts,
      );
    });
  }

  /// Acknowledge a safety alert (as a trusted contact)
  Future<void> acknowledgeAlert(String alertId, String contactId) async {
    final current = state.value;
    if (current == null || current.isProcessing) return;

    state = AsyncData(current.copyWith(isProcessing: true));
    state = await AsyncValue.guard(() async {
      await _repository.acknowledgeSafetyAlert(alertId, contactId);

      final updatedAlerts = current.recentAlerts.map((alert) {
        if (alert.id == alertId) {
          final acknowledgedByContactIds = [
            ...alert.acknowledgedByContactIds,
            contactId
          ];
          return alert.copyWith(
              acknowledgedByContactIds: acknowledgedByContactIds);
        }
        return alert;
      }).toList();

      final updatedActiveAlerts = current.activeAlerts.map((alert) {
        if (alert.id == alertId) {
          final acknowledgedByContactIds = [
            ...alert.acknowledgedByContactIds,
            contactId
          ];
          return alert.copyWith(
              acknowledgedByContactIds: acknowledgedByContactIds);
        }
        return alert;
      }).toList();

      return current.copyWith(
        isProcessing: false,
        recentAlerts: updatedAlerts,
        activeAlerts: updatedActiveAlerts,
      );
    });
  }

  /// Resolve a safety alert (user is safe)
  Future<void> resolveAlert(String alertId) async {
    final current = state.value;
    if (current == null || current.isProcessing) return;

    state = AsyncData(current.copyWith(isProcessing: true));
    state = await AsyncValue.guard(() async {
      await _repository.resolveSafetyAlert(alertId);

      final updatedAlerts = current.recentAlerts.map((alert) {
        return alert.id == alertId
            ? alert.copyWith(status: SafetyAlertStatus.resolved)
            : alert;
      }).toList();

      final updatedActiveAlerts =
          current.activeAlerts.where((alert) => alert.id != alertId).toList();

      return current.copyWith(
        isProcessing: false,
        recentAlerts: updatedAlerts,
        activeAlerts: updatedActiveAlerts,
      );
    });
  }

  /// Cancel a safety alert (false alarm)
  Future<void> cancelAlert(String alertId) async {
    final current = state.value;
    if (current == null || current.isProcessing) return;

    state = AsyncData(current.copyWith(isProcessing: true));
    state = await AsyncValue.guard(() async {
      await _repository.cancelSafetyAlert(alertId);

      final updatedAlerts = current.recentAlerts.map((alert) {
        return alert.id == alertId
            ? alert.copyWith(status: SafetyAlertStatus.cancelled)
            : alert;
      }).toList();

      final updatedActiveAlerts =
          current.activeAlerts.where((alert) => alert.id != alertId).toList();

      return current.copyWith(
        isProcessing: false,
        recentAlerts: updatedAlerts,
        activeAlerts: updatedActiveAlerts,
      );
    });
  }

  /// Get missed check-in alerts
  Future<void> loadMissedCheckInAlerts() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final missedAlerts = await _repository.getMissedCheckInAlerts();
      return (state.value ?? SafetyState.initial()).copyWith(
        recentAlerts: missedAlerts,
      );
    });
  }

  /// Update battery level
  Future<void> updateBatteryLevel(int level) async {
    try {
      await _repository.updateBatteryLevel(level);
    } catch (_) {
      // Silent fail for background battery updates
    }
  }

  /// Get current battery level
  Future<int?> getBatteryLevel() async {
    try {
      return await _repository.getBatteryLevel();
    } catch (_) {
      return null;
    }
  }

  /// Update trusted contacts count
  Future<void> updateContactsCount() async {
    final current = state.value;
    if (current == null) return;

    try {
      final contacts = await _repository.getTrustedContacts();
      state = AsyncData(current.copyWith(trustedContactsCount: contacts.length));
    } catch (_) {
      // Silent fail for background count updates
    }
  }

  /// Refresh all safety data
  Future<void> refresh() async {
    await initialize();
  }
}
