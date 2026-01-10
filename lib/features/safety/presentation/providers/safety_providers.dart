import 'package:flutter_riverpod/flutter_riverpod.dart';
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

// Export new Riverpod 3.0 providers
export 'trusted_contacts_provider.dart';
export 'check_in_provider.dart';
export 'safety_provider.dart';
export 'location_sharing_provider.dart';

part 'safety_providers.g.dart';

// ============================================================================
// Core Services
// ============================================================================

/// Provider for LocationService
@riverpod
LocationService locationService(Ref ref) {
  final service = LocationServiceImpl();

  ref.onDispose(() => service.dispose());

  return service;
}

/// Provider for NotificationService
@riverpod
NotificationService notificationService(Ref ref) {
  final service = NotificationServiceImpl();

  ref.onDispose(() => service.dispose());

  return service;
}

/// Provider for BackgroundCheckInService
@riverpod
BackgroundCheckInService backgroundCheckInService(Ref ref) {
  final service = BackgroundCheckInServiceImpl();

  ref.onDispose(() => service.dispose());

  return service;
}

/// Provider for MissedCheckInDetector
@riverpod
MissedCheckInDetector missedCheckInDetector(Ref ref) {
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
AddTrustedContactUseCase addTrustedContactUseCase(Ref ref) {
  return AddTrustedContactUseCase(
    ref.watch(safetyRepositoryOverrideProvider),
  );
}

/// Provider for RemoveTrustedContactUseCase
@riverpod
RemoveTrustedContactUseCase removeTrustedContactUseCase(Ref ref) {
  return RemoveTrustedContactUseCase(
    ref.watch(safetyRepositoryOverrideProvider),
  );
}

/// Provider for UpdateTrustedContactUseCase
@riverpod
UpdateTrustedContactUseCase updateTrustedContactUseCase(Ref ref) {
  return UpdateTrustedContactUseCase(
    ref.watch(safetyRepositoryOverrideProvider),
  );
}

/// Provider for GetTrustedContactsUseCase
@riverpod
GetTrustedContactsUseCase getTrustedContactsUseCase(Ref ref) {
  return GetTrustedContactsUseCase(
    ref.watch(safetyRepositoryOverrideProvider),
  );
}

// ============================================================================
// Use Cases - Check-ins
// ============================================================================

/// Provider for CreateCheckInUseCase
@riverpod
CreateCheckInUseCase createCheckInUseCase(Ref ref) {
  return CreateCheckInUseCase(
    ref.watch(safetyRepositoryOverrideProvider),
  );
}

/// Provider for CompleteCheckInUseCase
@riverpod
CompleteCheckInUseCase completeCheckInUseCase(Ref ref) {
  return CompleteCheckInUseCase(
    ref.watch(safetyRepositoryOverrideProvider),
  );
}

/// Provider for ScheduleCheckInUseCase
@riverpod
ScheduleCheckInUseCase scheduleCheckInUseCase(Ref ref) {
  return ScheduleCheckInUseCase(
    ref.watch(safetyRepositoryOverrideProvider),
  );
}

/// Provider for CancelCheckInUseCase
@riverpod
CancelCheckInUseCase cancelCheckInUseCase(Ref ref) {
  return CancelCheckInUseCase(
    ref.watch(safetyRepositoryOverrideProvider),
  );
}

/// Provider for GetUpcomingCheckInsUseCase
@riverpod
GetUpcomingCheckInsUseCase getUpcomingCheckInsUseCase(Ref ref) {
  return GetUpcomingCheckInsUseCase(
    ref.watch(safetyRepositoryOverrideProvider),
  );
}

// ============================================================================
// Use Cases - Location Sharing
// ============================================================================

/// Provider for ShareLocationUseCase
@riverpod
ShareLocationUseCase shareLocationUseCase(Ref ref) {
  return ShareLocationUseCase(
    ref.watch(safetyRepositoryOverrideProvider),
  );
}

/// Provider for StopLocationSharingUseCase
@riverpod
StopLocationSharingUseCase stopLocationSharingUseCase(Ref ref) {
  return StopLocationSharingUseCase(
    ref.watch(safetyRepositoryOverrideProvider),
  );
}

/// Provider for GetActiveLocationSharesUseCase
@riverpod
GetActiveLocationSharesUseCase getActiveLocationSharesUseCase(Ref ref) {
  return GetActiveLocationSharesUseCase(
    ref.watch(safetyRepositoryOverrideProvider),
  );
}

// ============================================================================
// Use Cases - Emergency SOS
// ============================================================================

/// Provider for TriggerEmergencySOSUseCase
@riverpod
TriggerEmergencySOSUseCase triggerEmergencySOSUseCase(Ref ref) {
  return TriggerEmergencySOSUseCase(
    ref.watch(safetyRepositoryOverrideProvider),
  );
}

/// Provider for UpdateSafetyStatusUseCase
@riverpod
UpdateSafetyStatusUseCase updateSafetyStatusUseCase(Ref ref) {
  return UpdateSafetyStatusUseCase(
    ref.watch(safetyRepositoryOverrideProvider),
  );
}

/// Provider for GetSafetyStatusUseCase
@riverpod
GetSafetyStatusUseCase getSafetyStatusUseCase(Ref ref) {
  return GetSafetyStatusUseCase(
    ref.watch(safetyRepositoryOverrideProvider),
  );
}
