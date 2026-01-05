import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/usecases/trigger_emergency_sos.dart';
import '../../domain/usecases/update_safety_status.dart';
import '../../domain/usecases/get_safety_status.dart';
import '../../domain/repositories/safety_repository.dart';
import '../../domain/entities/safety_status.dart';
import '../../domain/entities/safety_alert.dart';
import '../state/safety_state.dart';

/// Notifier for managing overall safety state
/// Handles safety status, emergency SOS, and safety alerts
class SafetyNotifier extends StateNotifier<SafetyState> {
  final TriggerEmergencySOSUseCase _triggerSOS;
  final UpdateSafetyStatusUseCase _updateStatus;
  final GetSafetyStatusUseCase _getStatus;
  final SafetyRepository _repository;
  final StateNotifierProviderRef _ref;

  SafetyNotifier({
    required TriggerEmergencySOSUseCase triggerSOS,
    required UpdateSafetyStatusUseCase updateStatus,
    required GetSafetyStatusUseCase getStatus,
    required SafetyRepository repository,
    required StateNotifierProviderRef ref,
  })  : _triggerSOS = triggerSOS,
        _updateStatus = updateStatus,
        _getStatus = getStatus,
        _repository = repository,
        _ref = ref,
        super(const SafetyState());

  /// Initialize safety state by loading current status and alerts
  Future<void> initialize() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final currentStatus = await _getStatus();
      final recentAlerts = await _repository.getRecentSafetyAlerts(limit: 10);
      final activeAlerts = recentAlerts
          .where((alert) => alert.status == SafetyAlertStatus.active)
          .toList();
      final contacts = await _repository.getTrustedContacts();

      state = state.copyWith(
        isLoading: false,
        currentStatus: currentStatus,
        recentAlerts: recentAlerts,
        activeAlerts: activeAlerts,
        trustedContactsCount: contacts.length,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load current safety status
  Future<void> loadSafetyStatus() async {
    if (state.isProcessing) return;

    state = state.copyWith(isProcessing: true, error: null);
    try {
      final status = await _getStatus();

      state = state.copyWith(
        isProcessing: false,
        currentStatus: status,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
      );
    }
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
    if (state.isProcessing) return;

    state = state.copyWith(isProcessing: true, error: null);
    try {
      // Get all trusted contacts if none specified
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

      final updatedAlerts = [alert, ...state.recentAlerts];
      final updatedActiveAlerts = [alert, ...state.activeAlerts];

      state = state.copyWith(
        isProcessing: false,
        recentAlerts: updatedAlerts,
        activeAlerts: updatedActiveAlerts,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
      );
    }
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
    if (state.isProcessing) return;

    state = state.copyWith(isProcessing: true, error: null);
    try {
      final updatedStatus = await _updateStatus(
        status: status,
        message: message,
        location: location,
        batteryLevel: batteryLevel,
        safetyAlertId: safetyAlertId,
        checkInId: checkInId,
      );

      state = state.copyWith(
        isProcessing: false,
        currentStatus: updatedStatus,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
      );
    }
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
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final recentAlerts = await _repository.getRecentSafetyAlerts(limit: limit);
      final activeAlerts = recentAlerts
          .where((alert) => alert.status == SafetyAlertStatus.active)
          .toList();

      state = state.copyWith(
        isLoading: false,
        recentAlerts: recentAlerts,
        activeAlerts: activeAlerts,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Acknowledge a safety alert (as a trusted contact)
  Future<void> acknowledgeAlert(String alertId, String contactId) async {
    if (state.isProcessing) return;

    state = state.copyWith(isProcessing: true, error: null);
    try {
      await _repository.acknowledgeSafetyAlert(alertId, contactId);

      final updatedAlerts = state.recentAlerts.map((alert) {
        if (alert.id == alertId) {
          final acknowledgedBy = [...alert.acknowledgedBy, contactId];
          return alert.copyWith(acknowledgedBy: acknowledgedBy);
        }
        return alert;
      }).toList();

      final updatedActiveAlerts = state.activeAlerts.map((alert) {
        if (alert.id == alertId) {
          final acknowledgedBy = [...alert.acknowledgedBy, contactId];
          return alert.copyWith(acknowledgedBy: acknowledgedBy);
        }
        return alert;
      }).toList();

      state = state.copyWith(
        isProcessing: false,
        recentAlerts: updatedAlerts,
        activeAlerts: updatedActiveAlerts,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
      );
    }
  }

  /// Resolve a safety alert (user is safe)
  Future<void> resolveAlert(String alertId) async {
    if (state.isProcessing) return;

    state = state.copyWith(isProcessing: true, error: null);
    try {
      await _repository.resolveSafetyAlert(alertId);

      final updatedAlerts = state.recentAlerts.map((alert) {
        return alert.id == alertId
            ? alert.copyWith(status: SafetyAlertStatus.resolved)
            : alert;
      }).toList();

      final updatedActiveAlerts = state.activeAlerts
          .where((alert) => alert.id != alertId)
          .toList();

      state = state.copyWith(
        isProcessing: false,
        recentAlerts: updatedAlerts,
        activeAlerts: updatedActiveAlerts,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
      );
    }
  }

  /// Cancel a safety alert (false alarm)
  Future<void> cancelAlert(String alertId) async {
    if (state.isProcessing) return;

    state = state.copyWith(isProcessing: true, error: null);
    try {
      await _repository.cancelSafetyAlert(alertId);

      final updatedAlerts = state.recentAlerts.map((alert) {
        return alert.id == alertId
            ? alert.copyWith(status: SafetyAlertStatus.cancelled)
            : alert;
      }).toList();

      final updatedActiveAlerts = state.activeAlerts
          .where((alert) => alert.id != alertId)
          .toList();

      state = state.copyWith(
        isProcessing: false,
        recentAlerts: updatedAlerts,
        activeAlerts: updatedActiveAlerts,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isProcessing: false,
        error: e.toString(),
      );
    }
  }

  /// Get missed check-in alerts
  Future<void> loadMissedCheckInAlerts() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final missedAlerts = await _repository.getMissedCheckInAlerts();

      state = state.copyWith(
        isLoading: false,
        recentAlerts: missedAlerts,
        error: null,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Update battery level
  Future<void> updateBatteryLevel(int level) async {
    try {
      await _repository.updateBatteryLevel(level);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Get current battery level
  Future<int?> getBatteryLevel() async {
    try {
      return await _repository.getBatteryLevel();
    } catch (e) {
      state = state.copyWith(error: e.toString());
      return null;
    }
  }

  /// Update trusted contacts count
  Future<void> updateContactsCount() async {
    try {
      final contacts = await _repository.getTrustedContacts();
      state = state.copyWith(trustedContactsCount: contacts.length);
    } catch (e) {
      state = state.copyWith(error: e.toString());
    }
  }

  /// Clear any error message
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refresh all safety data
  Future<void> refresh() async {
    await initialize();
  }
}
