import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:soloadventurer/features/safety/data/datasources/meetup_checkin_remote_data_source.dart';
import 'package:soloadventurer/features/safety/data/repositories/meetup_checkin_repository_impl.dart';
import 'package:soloadventurer/features/safety/domain/entities/meetup_checkin.dart';
import 'package:soloadventurer/features/safety/domain/repositories/meetup_checkin_repository.dart';
import 'package:soloadventurer/features/safety/domain/usecases/cancel_meetup_checkin_usecase.dart';
import 'package:soloadventurer/features/safety/domain/usecases/check_in_safe_usecase.dart';
import 'package:soloadventurer/features/safety/domain/usecases/create_meetup_checkin_usecase.dart';
import 'package:soloadventurer/features/safety/domain/usecases/get_active_checkins_usecase.dart';
import 'package:soloadventurer/features/safety/domain/usecases/trigger_sos_usecase.dart';

part 'meetup_checkin_providers.g.dart';

// ============================================================
// Data Source
// ============================================================

/// Provides the meetup check-in remote data source backed by Supabase
@Riverpod(keepAlive: true)
MeetupCheckinRemoteDataSource meetupCheckinRemoteDataSource(Ref ref) {
  return MeetupCheckinRemoteDataSourceImpl(client: Supabase.instance.client);
}

// ============================================================
// Repository
// ============================================================

/// Provides the meetup check-in repository implementation
@Riverpod(keepAlive: true)
MeetupCheckinRepository meetupCheckinRepository(Ref ref) {
  return MeetupCheckinRepositoryImpl(
    remoteDataSource: ref.read(meetupCheckinRemoteDataSourceProvider),
  );
}

// ============================================================
// Use Cases
// ============================================================

/// Provider for CreateMeetupCheckinUseCase
@riverpod
CreateMeetupCheckinUseCase createMeetupCheckinUseCase(Ref ref) {
  return CreateMeetupCheckinUseCase(ref.read(meetupCheckinRepositoryProvider));
}

/// Provider for CheckInSafeUseCase
@riverpod
CheckInSafeUseCase checkInSafeUseCase(Ref ref) {
  return CheckInSafeUseCase(ref.read(meetupCheckinRepositoryProvider));
}

/// Provider for TriggerSOSUseCase
@riverpod
TriggerSOSUseCase triggerSOSUseCase(Ref ref) {
  return TriggerSOSUseCase(ref.read(meetupCheckinRepositoryProvider));
}

/// Provider for CancelMeetupCheckinUseCase
@riverpod
CancelMeetupCheckinUseCase cancelMeetupCheckinUseCase(Ref ref) {
  return CancelMeetupCheckinUseCase(ref.read(meetupCheckinRepositoryProvider));
}

/// Provider for GetActiveCheckinsUseCase
@riverpod
GetActiveCheckinsUseCase getActiveCheckinsUseCase(Ref ref) {
  return GetActiveCheckinsUseCase(ref.read(meetupCheckinRepositoryProvider));
}

// ============================================================
// Active Check-ins Notifier
// ============================================================

/// Manages the list of active meetup check-ins with real-time updates
@riverpod
class ActiveCheckinsNotifier extends _$ActiveCheckinsNotifier {
  @override
  Future<List<MeetupCheckin>> build() async {
    final useCase = ref.read(getActiveCheckinsUseCaseProvider);
    final checkins = await useCase();

    // Subscribe to Supabase Realtime for meetup_checkins changes
    final userId = Supabase.instance.client.auth.currentUser?.id;
    if (userId != null) {
      Supabase.instance.client
          .from('meetup_checkins')
          .stream(primaryKey: ['id'])
          .eq('user_id', userId)
          .listen((List<Map<String, dynamic>> records) {
        // Invalidate self on any change to refresh the list
        ref.invalidateSelf();
      });
    }

    return checkins;
  }

  /// Create a new meetup check-in
  Future<void> createCheckin({
    required String trustedContactId,
    required DateTime meetupTime,
    String? locationName,
    String? meetingNote,
    int checkinBufferMins = 120,
  }) async {
    final useCase = ref.read(createMeetupCheckinUseCaseProvider);
    final newCheckin = await useCase(
      trustedContactId: trustedContactId,
      meetupTime: meetupTime,
      locationName: locationName,
      meetingNote: meetingNote,
      checkinBufferMins: checkinBufferMins,
    );

    // Prepend to current list
    final current = state.value ?? [];
    state = AsyncData([newCheckin, ...current]);
  }

  /// Mark a check-in as safe
  Future<void> checkInSafe(String checkinId) async {
    final useCase = ref.read(checkInSafeUseCaseProvider);
    await useCase(checkinId);

    // Update locally
    final current = state.value ?? [];
    final updated = current
        .where((c) => c.id != checkinId)
        .toList();
    state = AsyncData(updated);
  }

  /// Trigger SOS on a check-in
  Future<void> triggerSOS(String checkinId, {double? lat, double? lon}) async {
    final useCase = ref.read(triggerSOSUseCaseProvider);
    await useCase(checkinId, lat: lat, lon: lon);

    // Update locally
    final current = state.value ?? [];
    final updated = current.map((c) {
      if (c.id == checkinId) {
        return c.copyWith(
          status: MeetupCheckinStatus.sos,
          sosTriggeredAt: DateTime.now(),
        );
      }
      return c;
    }).toList();
    state = AsyncData(updated);
  }

  /// Cancel a check-in
  Future<void> cancelCheckin(String checkinId) async {
    final useCase = ref.read(cancelMeetupCheckinUseCaseProvider);
    await useCase(checkinId);

    // Remove from active list
    final current = state.value ?? [];
    final updated = current
        .where((c) => c.id != checkinId)
        .toList();
    state = AsyncData(updated);
  }
}
