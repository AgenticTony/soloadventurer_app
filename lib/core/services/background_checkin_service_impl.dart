import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:workmanager/workmanager.dart';
import 'background_checkin_service.dart';

part 'background_checkin_service_impl.g.dart';

/// Implementation of [BackgroundCheckInService] using workmanager
class BackgroundCheckInServiceImpl implements BackgroundCheckInService {
  final StreamController<BackgroundCheckInServiceStatus> _statusController =
      StreamController<BackgroundCheckInServiceStatus>.broadcast();

  BackgroundCheckInServiceStatus _status =
      BackgroundCheckInServiceStatus.stopped;

  @override
  BackgroundCheckInServiceStatus get status => _status;

  @override
  Stream<BackgroundCheckInServiceStatus> get onStatusChanged =>
      _statusController.stream;

  @override
  Future<void> initialize() async {
    try {
      // Initialize Workmanager with custom configuration
      await Workmanager().initialize(
        _callbackDispatcher,
        isInDebugMode: kDebugMode,
      );

      // Register periodic task for monitoring check-ins
      await Workmanager().registerPeriodicTask(
        BackgroundCheckInConfig.monitoringTaskId,
        BackgroundCheckInConfig.monitoringTaskName,
        frequency: BackgroundCheckInConfig.monitoringInterval,
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: true,
          requiresCharging: false,
          requiresDeviceIdle: false,
          requiresStorageNotLow: false,
        ),
        existingWorkPolicy: ExistingPeriodicWorkPolicy.replace,
        backoffPolicy: BackoffPolicy.exponential,
        backoffPolicyDelay: BackgroundCheckInConfig.monitoringInterval,
      );

      _updateStatus(BackgroundCheckInServiceStatus.initialized);
    } catch (e) {
      _updateStatus(BackgroundCheckInServiceStatus.error);
      throw BackgroundCheckInServiceException(
        'Failed to initialize background check-in service: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> scheduleCheckInReminder({
    required String checkInId,
    required DateTime scheduledTime,
  }) async {
    try {
      // Calculate delay from now
      final now = DateTime.now();
      if (scheduledTime.isBefore(now)) {
        throw BackgroundCheckInServiceException(
          'Scheduled time must be in the future',
        );
      }

      final initialDelay = scheduledTime.difference(now);

      // Schedule one-time task for reminder
      await Workmanager().registerOneOffTask(
        'reminder_$checkInId',
        'checkInReminderTask',
        initialDelay: initialDelay,
        constraints: Constraints(
          networkType: NetworkType.connected,
          requiresBatteryNotLow: false,
          requiresCharging: false,
        ),
        existingWorkPolicy: ExistingWorkPolicy.replace,
        tag: checkInId,
      );

      return true;
    } catch (e) {
      throw BackgroundCheckInServiceException(
        'Failed to schedule check-in reminder: ${e.toString()}',
      );
    }
  }

  @override
  Future<bool> scheduleMissedCheckInMonitoring() async {
    try {
      // This is already handled by the periodic task registered in initialize()
      // This method is kept for API compatibility and potential future enhancements
      return true;
    } catch (e) {
      throw BackgroundCheckInServiceException(
        'Failed to schedule missed check-in monitoring: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> cancelCheckInReminder(String checkInId) async {
    try {
      await Workmanager().cancelByTag(checkInId);
    } catch (e) {
      throw BackgroundCheckInServiceException(
        'Failed to cancel check-in reminder: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> cancelAllReminders() async {
    try {
      await Workmanager().cancelByUniqueName(
        BackgroundCheckInConfig.monitoringTaskId,
      );
    } catch (e) {
      throw BackgroundCheckInServiceException(
        'Failed to cancel all reminders: ${e.toString()}',
      );
    }
  }

  @override
  Future<void> stop() async {
    try {
      await Workmanager().cancelByUniqueName(
        BackgroundCheckInConfig.monitoringTaskId,
      );
      _updateStatus(BackgroundCheckInServiceStatus.stopped);
    } catch (e) {
      throw BackgroundCheckInServiceException(
        'Failed to stop background check-in service: ${e.toString()}',
      );
    }
  }

  @override
  Future<BackgroundCheckInResult> processDueCheckIns() async {
    // This method is called from the background task callback
    // The actual implementation is in the callback dispatcher
    throw UnimplementedError(
      'This method should only be called from the background task callback',
    );
  }

  @override
  void dispose() {
    stop();
    _statusController.close();
  }

  /// Updates the service status and notifies listeners
  void _updateStatus(BackgroundCheckInServiceStatus newStatus) {
    _status = newStatus;
    _statusController.add(_status);
  }
}

/// Global callback function for handling background check-in tasks
@pragma('vm:entry-point')
void _callbackDispatcher() {
  Workmanager().executeTask((taskName, inputData) async {
    try {
      if (taskName == BackgroundCheckInConfig.monitoringTaskName ||
          taskName == 'checkInReminderTask') {
        // Create a container for accessing providers
        final container = ProviderContainer();

        // Get the safety repository through the container
        // Note: This requires the safety repository provider to be accessible
        // For now, we'll return true as the actual implementation will need
        // to be integrated with the safety repository

        // TODO: Integrate with SafetyRepository to:
        // 1. Get upcoming check-ins
        // 2. Send reminders for check-ins due soon
        // 3. Mark overdue check-ins as missed
        // 4. Trigger alerts for missed check-ins

        // Placeholder for actual implementation
        await Future.delayed(const Duration(seconds: 1));

        // Return success
        return true;
      }

      return false;
    } catch (e, stack) {
      // Log error (in production, use proper logging)
      if (kDebugMode) {
        debugPrint('Background check-in task error: $e');
        debugPrint('Stack trace: $stack');
      }
      return false;
    }
  });
}

/// Exception thrown when background check-in service operations fail
class BackgroundCheckInServiceException implements Exception {
  final String message;

  BackgroundCheckInServiceException(this.message);

  @override
  String toString() => 'BackgroundCheckInServiceException: $message';
}

/// Provider for BackgroundCheckInServiceImpl
@riverpod
BackgroundCheckInService backgroundCheckInServiceImpl(
  Ref ref,
) {
  final service = BackgroundCheckInServiceImpl();

  // Dispose the service when the provider is disposed
  ref.onDispose(() => service.dispose());

  return service;
}

/// Provider override for BackgroundCheckInService interface
@riverpod
BackgroundCheckInService backgroundCheckInServiceOverride(
  Ref ref,
) {
  return ref.watch(backgroundCheckInServiceImplProvider);
}
