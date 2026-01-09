import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:soloadventurer/features/safety/data/repositories/safety_providers.dart';
import 'package:soloadventurer/features/safety/domain/usecases/add_trusted_contact.dart';
import 'package:soloadventurer/features/safety/domain/usecases/cancel_check_in.dart';
import 'package:soloadventurer/features/safety/domain/usecases/complete_check_in.dart';
import 'package:soloadventurer/features/safety/domain/usecases/create_check_in.dart';
import 'package:soloadventurer/features/safety/domain/usecases/get_active_location_shares.dart';
import 'package:soloadventurer/features/safety/domain/usecases/get_safety_status.dart';
import 'package:soloadventurer/features/safety/domain/usecases/get_trusted_contacts.dart';
import 'package:soloadventurer/features/safety/domain/usecases/get_upcoming_check_ins.dart';
import 'package:soloadventurer/features/safety/domain/usecases/remove_trusted_contact.dart';
import 'package:soloadventurer/features/safety/domain/usecases/schedule_check_in.dart';
import 'package:soloadventurer/features/safety/domain/usecases/share_location.dart';
import 'package:soloadventurer/features/safety/domain/usecases/stop_location_sharing.dart';
import 'package:soloadventurer/features/safety/domain/usecases/trigger_emergency_sos.dart';
import 'package:soloadventurer/features/safety/domain/usecases/update_safety_status.dart';
import 'package:soloadventurer/features/safety/domain/usecases/update_trusted_contact.dart';

// ==================== Trusted Contacts Use Cases ====================

/// Provider for GetTrustedContactsUseCase
final getTrustedContactsUseCaseProvider = Provider<GetTrustedContactsUseCase>(
  (ref) => GetTrustedContactsUseCase(ref.watch(safetyRepositoryProvider)),
);

/// Provider for AddTrustedContactUseCase
final addTrustedContactUseCaseProvider = Provider<AddTrustedContactUseCase>(
  (ref) => AddTrustedContactUseCase(ref.watch(safetyRepositoryProvider)),
);

/// Provider for UpdateTrustedContactUseCase
final updateTrustedContactUseCaseProvider = Provider<UpdateTrustedContactUseCase>(
  (ref) => UpdateTrustedContactUseCase(ref.watch(safetyRepositoryProvider)),
);

/// Provider for RemoveTrustedContactUseCase
final removeTrustedContactUseCaseProvider = Provider<RemoveTrustedContactUseCase>(
  (ref) => RemoveTrustedContactUseCase(ref.watch(safetyRepositoryProvider)),
);

// ==================== Check-in Use Cases ====================

/// Provider for GetUpcomingCheckInsUseCase
final getUpcomingCheckInsUseCaseProvider = Provider<GetUpcomingCheckInsUseCase>(
  (ref) => GetUpcomingCheckInsUseCase(ref.watch(safetyRepositoryProvider)),
);

/// Provider for CreateCheckInUseCase
final createCheckInUseCaseProvider = Provider<CreateCheckInUseCase>(
  (ref) => CreateCheckInUseCase(ref.watch(safetyRepositoryProvider)),
);

/// Provider for ScheduleCheckInUseCase
final scheduleCheckInUseCaseProvider = Provider<ScheduleCheckInUseCase>(
  (ref) => ScheduleCheckInUseCase(ref.watch(safetyRepositoryProvider)),
);

/// Provider for CompleteCheckInUseCase
final completeCheckInUseCaseProvider = Provider<CompleteCheckInUseCase>(
  (ref) => CompleteCheckInUseCase(ref.watch(safetyRepositoryProvider)),
);

/// Provider for CancelCheckInUseCase
final cancelCheckInUseCaseProvider = Provider<CancelCheckInUseCase>(
  (ref) => CancelCheckInUseCase(ref.watch(safetyRepositoryProvider)),
);

// ==================== Location Sharing Use Cases ====================

/// Provider for GetActiveLocationSharesUseCase
final getActiveLocationSharesUseCaseProvider = Provider<GetActiveLocationSharesUseCase>(
  (ref) => GetActiveLocationSharesUseCase(ref.watch(safetyRepositoryProvider)),
);

/// Provider for ShareLocationUseCase
final shareLocationUseCaseProvider = Provider<ShareLocationUseCase>(
  (ref) => ShareLocationUseCase(ref.watch(safetyRepositoryProvider)),
);

/// Provider for StopLocationSharingUseCase
final stopLocationSharingUseCaseProvider = Provider<StopLocationSharingUseCase>(
  (ref) => StopLocationSharingUseCase(ref.watch(safetyRepositoryProvider)),
);

// ==================== Safety Status & Alerts Use Cases ====================

/// Provider for GetSafetyStatusUseCase
final getSafetyStatusUseCaseProvider = Provider<GetSafetyStatusUseCase>(
  (ref) => GetSafetyStatusUseCase(ref.watch(safetyRepositoryProvider)),
);

/// Provider for UpdateSafetyStatusUseCase
final updateSafetyStatusUseCaseProvider = Provider<UpdateSafetyStatusUseCase>(
  (ref) => UpdateSafetyStatusUseCase(ref.watch(safetyRepositoryProvider)),
);

/// Provider for TriggerEmergencySOSUseCase
final triggerEmergencySOSUseCaseProvider = Provider<TriggerEmergencySOSUseCase>(
  (ref) => TriggerEmergencySOSUseCase(ref.watch(safetyRepositoryProvider)),
);
