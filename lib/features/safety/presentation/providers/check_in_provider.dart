import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../domain/usecases/create_check_in.dart';
import '../../domain/usecases/complete_check_in.dart';
import '../../domain/usecases/schedule_check_in.dart';
import '../../domain/usecases/cancel_check_in.dart';
import '../../domain/usecases/get_upcoming_check_ins.dart';
import '../../domain/entities/check_in.dart';
import '../state/check_in_state.dart';
import 'safety_providers.dart';
import '../../../auth/presentation/providers/auth_notifier_provider.dart';

part 'check_in_provider.g.dart';

/// AsyncNotifier for managing check-in state.
///
/// Riverpod 3.0 Compliant:
/// - Uses @riverpod annotation with code generation
/// - AsyncNotifier with AsyncValue handles loading/error
/// - State no longer has isLoading/error fields
@riverpod
class CheckInNotifier extends _$CheckInNotifier {
  CreateCheckInUseCase get _createCheckIn =>
      ref.watch(createCheckInUseCaseProvider);
  CompleteCheckInUseCase get _completeCheckIn =>
      ref.watch(completeCheckInUseCaseProvider);
  ScheduleCheckInUseCase get _scheduleCheckIn =>
      ref.watch(scheduleCheckInUseCaseProvider);
  CancelCheckInUseCase get _cancelCheckIn =>
      ref.watch(cancelCheckInUseCaseProvider);
  GetUpcomingCheckInsUseCase get _getUpcomingCheckIns =>
      ref.watch(getUpcomingCheckInsUseCaseProvider);

  @override
  Future<CheckInState> build() async => CheckInState.initial();

  /// Helper to compute all derived values
  ({
    bool hasUpcoming,
    bool isProcessing,
    int dueSoon,
    int missed,
    CheckIn? next
  }) _computeDerivedValues(CheckInState current) {
    final hasUpcoming = current.upcomingCheckIns.isNotEmpty;
    final isProcessing =
        current.isCreating || current.isCompleting || current.isCancelling;

    final dueSoon = current.upcomingCheckIns.where((checkIn) {
      final deadline = checkIn.deadline;
      if (deadline == null) return false;
      return deadline.isBefore(DateTime.now().add(const Duration(hours: 1)));
    }).length;

    final missed = current.checkIns
        .where((checkIn) => checkIn.status == CheckInStatus.missed)
        .length;

    CheckIn? next;
    if (current.upcomingCheckIns.isNotEmpty) {
      final sorted = List<CheckIn>.from(current.upcomingCheckIns)
        ..sort((a, b) {
          final aTime = a.scheduledTime ?? a.deadline ?? DateTime.now();
          final bTime = b.scheduledTime ?? b.deadline ?? DateTime.now();
          return aTime.compareTo(bTime);
        });
      next = sorted.first;
    }

    return (
      hasUpcoming: hasUpcoming,
      isProcessing: isProcessing,
      dueSoon: dueSoon,
      missed: missed,
      next: next,
    );
  }

  /// Load all check-ins
  Future<void> loadCheckIns() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final checkIns = await _getUpcomingCheckIns();
      final derived = _computeDerivedValues(state.value ?? CheckInState.initial());
      return (state.value ?? CheckInState.initial()).copyWith(
        checkIns: checkIns,
        upcomingCheckIns: checkIns,
        hasUpcomingCheckIns: derived.hasUpcoming,
        isProcessing: derived.isProcessing,
        dueSoonCount: derived.dueSoon,
        missedCount: derived.missed,
        nextCheckIn: derived.next,
      );
    });
  }

  /// Load upcoming check-ins
  Future<void> loadUpcomingCheckIns() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final upcoming = await _getUpcomingCheckIns();
      final derived = _computeDerivedValues(state.value ?? CheckInState.initial());
      return (state.value ?? CheckInState.initial()).copyWith(
        upcomingCheckIns: upcoming,
        hasUpcomingCheckIns: derived.hasUpcoming,
        isProcessing: derived.isProcessing,
        dueSoonCount: derived.dueSoon,
        missedCount: derived.missed,
        nextCheckIn: derived.next,
      );
    });
  }

  /// Create a manual check-in
  Future<void> createManualCheckIn({
    required String statusMessage,
    required double latitude,
    required double longitude,
    String? tripId,
  }) async {
    final current = state.value!;
    if (current.isCreating) return;

    state = AsyncData(current.copyWith(isCreating: true, isProcessing: true));
    state = await AsyncValue.guard(() async {
      final authAsync = ref.read(authProvider);
      final userId = authAsync.value?.user?.id ?? '';

      if (userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      final now = DateTime.now();
      final location = CheckInLocation(
        latitude: latitude,
        longitude: longitude,
        timestamp: now,
      );

      final checkIn = CheckIn(
        id: const Uuid().v4(),
        userId: userId,
        triggerType: CheckInTriggerType.manual,
        status: CheckInStatus.completed,
        notifyContactIds: const [],
        createdAt: now,
        completedAt: now,
        location: location,
        statusMessage: statusMessage,
        tripId: tripId,
      );

      final createdCheckIn = await _createCheckIn(checkIn);

      final updatedCheckIns = [...current.checkIns, createdCheckIn];
      final updatedUpcoming = [...current.upcomingCheckIns, createdCheckIn];
      final derived = _computeDerivedValues(
        current.copyWith(
          checkIns: updatedCheckIns,
          upcomingCheckIns: updatedUpcoming,
        ),
      );

      return current.copyWith(
        isCreating: false,
        checkIns: updatedCheckIns,
        upcomingCheckIns: updatedUpcoming,
        selectedCheckIn: createdCheckIn,
        isProcessing: false,
        hasUpcomingCheckIns: derived.hasUpcoming,
        dueSoonCount: derived.dueSoon,
        missedCount: derived.missed,
        nextCheckIn: derived.next,
      );
    });
  }

  /// Schedule a check-in
  Future<void> scheduleCheckIn({
    required DateTime scheduledTime,
    CheckInLocation? location,
    required String statusMessage,
    List<String> notifyContactIds = const [],
    String? tripId,
    DateTime? deadline,
  }) async {
    final current = state.value!;
    if (current.isCreating) return;

    state = AsyncData(current.copyWith(isCreating: true, isProcessing: true));
    state = await AsyncValue.guard(() async {
      final authAsync = ref.read(authProvider);
      final userId = authAsync.value?.user?.id ?? '';

      if (userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      final checkIn = await _scheduleCheckIn(
        userId: userId,
        scheduledTime: scheduledTime,
        deadline: deadline,
        location: location,
        statusMessage: statusMessage,
        notifyContactIds: notifyContactIds,
        tripId: tripId,
        triggerType: CheckInTriggerType.scheduledTime,
      );

      final updatedCheckIns = [...current.checkIns, checkIn];
      final updatedUpcoming = [...current.upcomingCheckIns, checkIn];
      final derived = _computeDerivedValues(
        current.copyWith(
          checkIns: updatedCheckIns,
          upcomingCheckIns: updatedUpcoming,
        ),
      );

      return current.copyWith(
        isCreating: false,
        checkIns: updatedCheckIns,
        upcomingCheckIns: updatedUpcoming,
        selectedCheckIn: checkIn,
        isProcessing: false,
        hasUpcomingCheckIns: derived.hasUpcoming,
        dueSoonCount: derived.dueSoon,
        missedCount: derived.missed,
        nextCheckIn: derived.next,
      );
    });
  }

  /// Complete a check-in
  Future<void> completeCheckIn({
    required String checkInId,
    required double latitude,
    required double longitude,
    String? statusMessage,
  }) async {
    final current = state.value!;
    if (current.isCompleting) return;

    state = AsyncData(current.copyWith(isCompleting: true, isProcessing: true));
    state = await AsyncValue.guard(() async {
      final location = CheckInLocation(
        latitude: latitude,
        longitude: longitude,
        timestamp: DateTime.now(),
      );

      final completedCheckIn = await _completeCheckIn(
        checkInId: checkInId,
        location: location,
        statusMessage: statusMessage,
      );

      final updatedCheckIns = current.checkIns.map((checkIn) {
        return checkIn.id == checkInId ? completedCheckIn : checkIn;
      }).toList();

      final updatedUpcoming = current.upcomingCheckIns
          .where((checkIn) => checkIn.id != checkInId)
          .toList();
      final derived = _computeDerivedValues(
        current.copyWith(
          checkIns: updatedCheckIns,
          upcomingCheckIns: updatedUpcoming,
        ),
      );

      return current.copyWith(
        isCompleting: false,
        checkIns: updatedCheckIns,
        upcomingCheckIns: updatedUpcoming,
        selectedCheckIn: completedCheckIn,
        isProcessing: false,
        hasUpcomingCheckIns: derived.hasUpcoming,
        dueSoonCount: derived.dueSoon,
        missedCount: derived.missed,
        nextCheckIn: derived.next,
      );
    });
  }

  /// Cancel a check-in
  Future<void> cancelCheckIn(String checkInId) async {
    final current = state.value!;
    if (current.isCancelling) return;

    state = AsyncData(current.copyWith(isCancelling: true, isProcessing: true));
    state = await AsyncValue.guard(() async {
      await _cancelCheckIn(checkInId);

      final updatedCheckIns = current.checkIns.map((checkIn) {
        return checkIn.id == checkInId
            ? checkIn.copyWith(status: CheckInStatus.cancelled)
            : checkIn;
      }).toList();

      final updatedUpcoming = current.upcomingCheckIns
          .where((checkIn) => checkIn.id != checkInId)
          .toList();
      final derived = _computeDerivedValues(
        current.copyWith(
          checkIns: updatedCheckIns,
          upcomingCheckIns: updatedUpcoming,
        ),
      );

      return current.copyWith(
        isCancelling: false,
        checkIns: updatedCheckIns,
        upcomingCheckIns: updatedUpcoming,
        selectedCheckIn:
            current.selectedCheckIn?.id == checkInId ? null : current.selectedCheckIn,
        isProcessing: false,
        hasUpcomingCheckIns: derived.hasUpcoming,
        dueSoonCount: derived.dueSoon,
        missedCount: derived.missed,
        nextCheckIn: derived.next,
      );
    });
  }

  /// Load check-ins for a specific trip
  Future<void> loadCheckInsByTrip(String tripId) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final checkIns = await _getUpcomingCheckIns();
      final tripCheckIns =
          checkIns.where((checkIn) => checkIn.tripId == tripId).toList();
      final derived = _computeDerivedValues(state.value ?? CheckInState.initial());
      return (state.value ?? CheckInState.initial()).copyWith(
        checkIns: tripCheckIns,
        upcomingCheckIns: tripCheckIns,
        hasUpcomingCheckIns: derived.hasUpcoming,
        isProcessing: derived.isProcessing,
        dueSoonCount: derived.dueSoon,
        missedCount: derived.missed,
        nextCheckIn: derived.next,
      );
    });
  }

  /// Select a check-in for viewing/editing
  void selectCheckIn(CheckIn? checkIn) {
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(selectedCheckIn: checkIn));
    }
  }

  /// Clear the selected check-in
  void clearSelection() {
    final current = state.value;
    if (current != null) {
      state = AsyncData(current.copyWith(selectedCheckIn: null));
    }
  }

  /// Refresh upcoming check-ins
  Future<void> refreshUpcoming() async {
    await loadUpcomingCheckIns();
  }
}
