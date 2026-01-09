import 'package:riverpod_annotation/riverpod_annotation.dart';
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

// Import notifiers to include their generated providers

part 'safety_providers.g.dart';

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

// Note: The notifier providers (TrustedContactsNotifier, CheckInNotifier,
// LocationSharingNotifier, SafetyNotifier) are auto-generated by the
// @riverpod annotation in each notifier file. To use them in your screens,
// import the notifier file directly:
//
// import 'package:soloadventurer/features/safety/presentation/notifiers/check_in_notifier.dart';
//
// The generated provider will be available as `checkInNotifierProvider`.
//
// Alternatively, you can access them through the notifier files that are
// imported at the top of this file.
