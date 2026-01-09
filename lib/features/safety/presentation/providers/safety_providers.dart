import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/core/services/location_service.dart';
import 'package:soloadventurer/core/services/location_service_impl.dart';
import 'package:soloadventurer/core/services/notification_service.dart';
import 'package:soloadventurer/core/services/notification_service_impl.dart';
import 'package:soloadventurer/core/services/background_checkin_service.dart';
import 'package:soloadventurer/core/services/background_checkin_service_impl.dart';
import 'package:soloadventurer/features/safety/data/repositories/safety_providers.dart';
import 'package:soloadventurer/features/safety/domain/usecases/add_trusted_contact.dart';
import 'package:soloadventurer/features/safety/domain/usecases/remove_trusted_contact.dart';
import 'package:soloadventurer/features/safety/domain/usecases/update_trusted_contact.dart';
import 'package:soloadventurer/features/safety/domain/usecases/get_trusted_contacts.dart';
import 'package:soloadventurer/features/safety/domain/usecases/create_check_in.dart';
import 'package:soloadventurer/features/safety/domain/usecases/complete_check_in.dart';
import 'package:soloadventurer/features/safety/domain/usecases/schedule_check_in.dart';
import 'package:soloadventurer/features/safety/domain/usecases/cancel_check_in.dart';
import 'package:soloadventurer/features/safety/domain/usecases/get_upcoming_check_ins.dart';
import 'package:soloadventurer/features/safety/domain/usecases/share_location.dart';
import 'package:soloadventurer/features/safety/domain/usecases/stop_location_sharing.dart';
import 'package:soloadventurer/features/safety/domain/usecases/get_active_location_shares.dart';
import 'package:soloadventurer/features/safety/domain/usecases/trigger_emergency_sos.dart';
import 'package:soloadventurer/features/safety/domain/usecases/update_safety_status.dart';
import 'package:soloadventurer/features/safety/domain/usecases/get_safety_status.dart';
import 'package:soloadventurer/features/safety/infrastructure/services/missed_checkin_detector.dart';
import 'package:soloadventurer/features/safety/infrastructure/services/missed_checkin_detector_impl.dart';
import 'package:soloadventurer/features/safety/presentation/notifiers/location_sharing_notifier.dart';
import 'package:soloadventurer/features/safety/presentation/notifiers/safety_notifier.dart';

// Export new Riverpod 2 Phase 1 providers
export 'trusted_contacts_provider.dart';
export 'check_in_provider.dart';
import 'package:soloadventurer/features/safety/presentation/state/location_sharing_state.dart';
import 'package:soloadventurer/features/safety/presentation/state/safety_state.dart';

part 'safety_providers.g.dart';

// ============================================================================
// Core Services
// ============================================================================

/// Provider for LocationService
@riverpod
LocationService locationService(LocationServiceRef ref) {
  final service = LocationServiceImpl();

  ref.onDispose(() => service.dispose());

  return service;
}

/// Provider for NotificationService
@riverpod
NotificationService notificationService(NotificationServiceRef ref) {
  final service = NotificationServiceImpl();

  ref.onDispose(() => service.dispose());

  return service;
}

/// Provider for BackgroundCheckInService
@riverpod
BackgroundCheckInService backgroundCheckInService(
  BackgroundCheckInServiceRef ref,
) {
  final service = BackgroundCheckInServiceImpl();

  ref.onDispose(() => service.dispose());

  return service;
}

/// Provider for MissedCheckInDetector
@riverpod
MissedCheckInDetector missedCheckInDetector(MissedCheckInDetectorRef ref) {
  final service = MissedCheckInDetectorImpl(
    safetyRepository: ref.watch(safetyRepositoryOverrideProvider),
    locationService: ref.watch(locationServiceProvider),
    notificationService: ref.watch(notificationServiceProvider),
  );

  ref.onDispose(() => service.dispose());

  return service;
}

// ============================================================================
// Use Cases - Trusted Contacts
// ============================================================================

/// Provider for AddTrustedContactUseCase
@riverpod
AddTrustedContactUseCase addTrustedContactUseCase(
  AddTrustedContactUseCaseRef ref,
) {
  return AddTrustedContactUseCase(
    ref.watch(safetyRepositoryOverrideProvider),
  );
}

/// Provider for RemoveTrustedContactUseCase
@riverpod
RemoveTrustedContactUseCase removeTrustedContactUseCase(
  RemoveTrustedContactUseCaseRef ref,
) {
  return RemoveTrustedContactUseCase(
    ref.watch(safetyRepositoryOverrideProvider),
  );
}

/// Provider for UpdateTrustedContactUseCase
@riverpod
UpdateTrustedContactUseCase updateTrustedContactUseCase(
  UpdateTrustedContactUseCaseRef ref,
) {
  return UpdateTrustedContactUseCase(
    ref.watch(safetyRepositoryOverrideProvider),
  );
}

/// Provider for GetTrustedContactsUseCase
@riverpod
GetTrustedContactsUseCase getTrustedContactsUseCase(
  GetTrustedContactsUseCaseRef ref,
) {
  return GetTrustedContactsUseCase(
    ref.watch(safetyRepositoryOverrideProvider),
  );
}

// ============================================================================
// Use Cases - Check-ins
// ============================================================================

/// Provider for CreateCheckInUseCase
@riverpod
CreateCheckInUseCase createCheckInUseCase(CreateCheckInUseCaseRef ref) {
  return CreateCheckInUseCase(
    ref.watch(safetyRepositoryOverrideProvider),
  );
}

/// Provider for CompleteCheckInUseCase
@riverpod
CompleteCheckInUseCase completeCheckInUseCase(CompleteCheckInUseCaseRef ref) {
  return CompleteCheckInUseCase(
    ref.watch(safetyRepositoryOverrideProvider),
  );
}

/// Provider for ScheduleCheckInUseCase
@riverpod
ScheduleCheckInUseCase scheduleCheckInUseCase(ScheduleCheckInUseCaseRef ref) {
  return ScheduleCheckInUseCase(
    ref.watch(safetyRepositoryOverrideProvider),
  );
}

/// Provider for CancelCheckInUseCase
@riverpod
CancelCheckInUseCase cancelCheckInUseCase(CancelCheckInUseCaseRef ref) {
  return CancelCheckInUseCase(
    ref.watch(safetyRepositoryOverrideProvider),
  );
}

/// Provider for GetUpcomingCheckInsUseCase
@riverpod
GetUpcomingCheckInsUseCase getUpcomingCheckInsUseCase(
  GetUpcomingCheckInsUseCaseRef ref,
) {
  return GetUpcomingCheckInsUseCase(
    ref.watch(safetyRepositoryOverrideProvider),
  );
}

// ============================================================================
// Use Cases - Location Sharing
// ============================================================================

/// Provider for ShareLocationUseCase
@riverpod
ShareLocationUseCase shareLocationUseCase(ShareLocationUseCaseRef ref) {
  return ShareLocationUseCase(
    ref.watch(safetyRepositoryOverrideProvider),
  );
}

/// Provider for StopLocationSharingUseCase
@riverpod
StopLocationSharingUseCase stopLocationSharingUseCase(
  StopLocationSharingUseCaseRef ref,
) {
  return StopLocationSharingUseCase(
    ref.watch(safetyRepositoryOverrideProvider),
  );
}

/// Provider for GetActiveLocationSharesUseCase
@riverpod
GetActiveLocationSharesUseCase getActiveLocationSharesUseCase(
  GetActiveLocationSharesUseCaseRef ref,
) {
  return GetActiveLocationSharesUseCase(
    ref.watch(safetyRepositoryOverrideProvider),
  );
}

// ============================================================================
// Use Cases - Emergency SOS
// ============================================================================

/// Provider for TriggerEmergencySOSUseCase
@riverpod
TriggerEmergencySOSUseCase triggerEmergencySOSUseCase(
  TriggerEmergencySOSUseCaseRef ref,
) {
  return TriggerEmergencySOSUseCase(
    ref.watch(safetyRepositoryOverrideProvider),
  );
}

/// Provider for UpdateSafetyStatusUseCase
@riverpod
UpdateSafetyStatusUseCase updateSafetyStatusUseCase(
  UpdateSafetyStatusUseCaseRef ref,
) {
  return UpdateSafetyStatusUseCase(
    ref.watch(safetyRepositoryOverrideProvider),
  );
}

/// Provider for GetSafetyStatusUseCase
@riverpod
GetSafetyStatusUseCase getSafetyStatusUseCase(GetSafetyStatusUseCaseRef ref) {
  return GetSafetyStatusUseCase(
    ref.watch(safetyRepositoryOverrideProvider),
  );
}

// ============================================================================
// Notifiers - Location Sharing
// ============================================================================

/// Provider for LocationSharingNotifier
@riverpod
LocationSharingNotifier locationSharingNotifier(
    LocationSharingNotifierRef ref) {
  final notifier = LocationSharingNotifier(
    shareLocation: ref.watch(shareLocationUseCaseProvider),
    stopLocationSharing: ref.watch(stopLocationSharingUseCaseProvider),
    getActiveShares: ref.watch(getActiveLocationSharesUseCaseProvider),
  );

  ref.onDispose(() => notifier.dispose());

  return notifier;
}

// ============================================================================
// Notifiers - Safety
// ============================================================================

/// Provider for SafetyNotifier
@riverpod
SafetyNotifier safetyNotifier(SafetyNotifierRef ref) {
  final notifier = SafetyNotifier(
    triggerSOS: ref.watch(triggerEmergencySOSUseCaseProvider),
    updateStatus: ref.watch(updateSafetyStatusUseCaseProvider),
    getStatus: ref.watch(getSafetyStatusUseCaseProvider),
    repository: ref.watch(safetyRepositoryOverrideProvider),
  );

  ref.onDispose(() => notifier.dispose());

  return notifier;
}

// ============================================================================
// State Providers - Location Sharing
// ============================================================================

/// Provider for location sharing state
final locationSharingStateProvider = Provider<LocationSharingState>((ref) {
  return ref.watch(locationSharingNotifierProvider).state;
});

/// Provider for active location shares
final activeLocationSharesProvider = Provider((ref) {
  final state = ref.watch(locationSharingNotifierProvider).state;
  return state.activeShares;
});

/// Provider for location updates
final locationUpdatesProvider = Provider((ref) {
  final state = ref.watch(locationSharingNotifierProvider).state;
  return state.locationUpdates;
});

/// Provider for latest location
final latestLocationProvider = Provider((ref) {
  final state = ref.watch(locationSharingNotifierProvider).state;
  return state.latestLocation;
});

/// Provider for location sharing loading state
final locationSharingLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(locationSharingNotifierProvider).state;
  return state.isLoading;
});

/// Provider for location sharing error
final locationSharingErrorProvider = Provider<String?>((ref) {
  final state = ref.watch(locationSharingNotifierProvider).state;
  return state.error;
});

/// Provider for active sharing count
final activeSharingCountProvider = Provider<int>((ref) {
  final state = ref.watch(locationSharingNotifierProvider).state;
  return state.activeSharingCount;
});

/// Provider for has emergency sharing
final hasEmergencySharingProvider = Provider<bool>((ref) {
  final state = ref.watch(locationSharingNotifierProvider).state;
  return state.hasEmergencySharing;
});

/// Provider for active contact IDs
final activeContactIdsProvider = Provider((ref) {
  final state = ref.watch(locationSharingNotifierProvider).state;
  return state.activeContactIds;
});

// ============================================================================
// State Providers - Safety
// ============================================================================

/// Provider for safety state
final safetyStateProvider = Provider<SafetyState>((ref) {
  return ref.watch(safetyNotifierProvider).state;
});

/// Provider for current safety status
final currentSafetyStatusProvider = Provider((ref) {
  final state = ref.watch(safetyNotifierProvider).state;
  return state.currentStatus;
});

/// Provider for recent safety alerts
final recentSafetyAlertsProvider = Provider((ref) {
  final state = ref.watch(safetyNotifierProvider).state;
  return state.recentAlerts;
});

/// Provider for active safety alerts
final activeSafetyAlertsProvider = Provider((ref) {
  final state = ref.watch(safetyNotifierProvider).state;
  return state.activeAlerts;
});

/// Provider for safety loading state
final safetyLoadingProvider = Provider<bool>((ref) {
  final state = ref.watch(safetyNotifierProvider).state;
  return state.isLoading;
});

/// Provider for safety processing state
final safetyProcessingProvider = Provider<bool>((ref) {
  final state = ref.watch(safetyNotifierProvider).state;
  return state.isProcessing;
});

/// Provider for safety error
final safetyErrorProvider = Provider<String?>((ref) {
  final state = ref.watch(safetyNotifierProvider).state;
  return state.error;
});

/// Provider for trusted contacts count
final trustedContactsCountProvider = Provider<int>((ref) {
  final state = ref.watch(safetyNotifierProvider).state;
  return state.trustedContactsCount;
});

/// Provider for has active emergency
final hasActiveEmergencyProvider = Provider<bool>((ref) {
  final state = ref.watch(safetyNotifierProvider).state;
  return state.hasActiveEmergency;
});

/// Provider for is in danger
final isInDangerProvider = Provider<bool>((ref) {
  final state = ref.watch(safetyNotifierProvider).state;
  return state.isInDanger;
});

/// Provider for safety initialized
final safetyInitializedProvider = Provider<bool>((ref) {
  final state = ref.watch(safetyNotifierProvider).state;
  return state.isInitialized;
});
