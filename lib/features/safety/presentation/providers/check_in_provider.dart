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

/// Notifier for managing check-in state
/// Handles check-in creation, completion, scheduling, and cancellation
///
/// Riverpod 3.0 Compliant:
/// - Uses @riverpod annotation with autoDispose (auto-disposes when unused)
/// - NO getters in state - all derived values are fields
/// - UI reads STATE only via ref.watch()
/// - UI calls methods via ref.read(provider.notifier)
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
  CheckInState build() => CheckInState.initial();

  /// Helper to compute all derived values
  ({
    bool hasUpcoming,
    bool isProcessing,
    int dueSoon,
    int missed,
    CheckIn? next
  }) _computeDerivedValues() {
    final hasUpcoming = state.upcomingCheckIns.isNotEmpty;
    final isProcessing =
        state.isCreating || state.isCompleting || state.isCancelling;

    final dueSoon = state.upcomingCheckIns.where((checkIn) {
      final deadline = checkIn.deadline;
      if (deadline == null) return false;
      return deadline.isBefore(DateTime.now().add(const Duration(hours: 1)));
    }).length;

    final missed = state.checkIns
        .where((checkIn) => checkIn.status == CheckInStatus.missed)
        .length;

    CheckIn? next;
    if (state.upcomingCheckIns.isNotEmpty) {
      final sorted = List<CheckIn>.from(state.upcomingCheckIns)
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
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);
    try {
      final checkIns = await _getUpcomingCheckIns();
      final derived = _computeDerivedValues();
      state = state.copyWith(
        isLoading: false,
        checkIns: checkIns,
        upcomingCheckIns: checkIns,
        error: null,
        hasUpcomingCheckIns: derived.hasUpcoming,
        isProcessing: derived.isProcessing,
        dueSoonCount: derived.dueSoon,
        missedCount: derived.missed,
        nextCheckIn: derived.next,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Load upcoming check-ins
  Future<void> loadUpcomingCheckIns() async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final upcoming = await _getUpcomingCheckIns();
      final derived = _computeDerivedValues();
      state = state.copyWith(
        isLoading: false,
        upcomingCheckIns: upcoming,
        error: null,
        hasUpcomingCheckIns: derived.hasUpcoming,
        isProcessing: derived.isProcessing,
        dueSoonCount: derived.dueSoon,
        missedCount: derived.missed,
        nextCheckIn: derived.next,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Create a manual check-in
  Future<void> createManualCheckIn({
    required String statusMessage,
    required double latitude,
    required double longitude,
    String? tripId,
  }) async {
    if (state.isCreating) return;

    state = state.copyWith(isCreating: true, error: null, isProcessing: true);
    try {
      // Get current user ID from auth state
      final authAsync = ref.read(authProvider);
      final userId = authAsync.value?.user?.id ?? '';

      if (userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      // Construct CheckIn entity as required by domain
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
        status: CheckInStatus
            .completed, // Manual check-ins are completed immediately
        notifyContactIds: const [],
        createdAt: now,
        completedAt: now,
        location: location,
        statusMessage: statusMessage,
        tripId: tripId,
      );

      final createdCheckIn = await _createCheckIn(checkIn);

      final updatedCheckIns = [...state.checkIns, createdCheckIn];
      final updatedUpcoming = [...state.upcomingCheckIns, createdCheckIn];
      final derived = _computeDerivedValues();

      state = state.copyWith(
        isCreating: false,
        checkIns: updatedCheckIns,
        upcomingCheckIns: updatedUpcoming,
        selectedCheckIn: createdCheckIn,
        error: null,
        isProcessing: false,
        hasUpcomingCheckIns: derived.hasUpcoming,
        dueSoonCount: derived.dueSoon,
        missedCount: derived.missed,
        nextCheckIn: derived.next,
      );
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        isProcessing: false,
        error: e.toString(),
      );
    }
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
    if (state.isCreating) return;

    state = state.copyWith(isCreating: true, error: null, isProcessing: true);
    try {
      // Get current user ID from auth state
      final authAsync = ref.read(authProvider);
      final userId = authAsync.value?.user?.id ?? '';

      if (userId.isEmpty) {
        throw Exception('User not authenticated');
      }

      // Call ScheduleCheckInUseCase with named parameters as per domain contract
      final checkIn = await _scheduleCheckIn(
        userId: userId,
        scheduledTime: scheduledTime,
        deadline: deadline,
        location: location,
        statusMessage: statusMessage,
        notifyContactIds: notifyContactIds,
        tripId: tripId,
        triggerType: CheckInTriggerType.scheduledTime, // Correct enum value
      );

      final updatedCheckIns = [...state.checkIns, checkIn];
      final updatedUpcoming = [...state.upcomingCheckIns, checkIn];
      final derived = _computeDerivedValues();

      state = state.copyWith(
        isCreating: false,
        checkIns: updatedCheckIns,
        upcomingCheckIns: updatedUpcoming,
        selectedCheckIn: checkIn,
        error: null,
        isProcessing: false,
        hasUpcomingCheckIns: derived.hasUpcoming,
        dueSoonCount: derived.dueSoon,
        missedCount: derived.missed,
        nextCheckIn: derived.next,
      );
    } catch (e) {
      state = state.copyWith(
        isCreating: false,
        isProcessing: false,
        error: e.toString(),
      );
    }
  }

  /// Complete a check-in
  /// Location is REQUIRED for safety verification as per domain contract
  Future<void> completeCheckIn({
    required String checkInId,
    required double latitude,
    required double longitude,
    String? statusMessage,
  }) async {
    if (state.isCompleting) return;

    state = state.copyWith(isCompleting: true, error: null, isProcessing: true);
    try {
      // Construct CheckInLocation as required by domain
      final location = CheckInLocation(
        latitude: latitude,
        longitude: longitude,
        timestamp: DateTime.now(),
      );

      // Call CompleteCheckInUseCase with required parameters as per domain contract
      final completedCheckIn = await _completeCheckIn(
        checkInId: checkInId,
        location: location,
        statusMessage: statusMessage,
      );

      final updatedCheckIns = state.checkIns.map((checkIn) {
        return checkIn.id == checkInId ? completedCheckIn : checkIn;
      }).toList();

      final updatedUpcoming = state.upcomingCheckIns
          .where((checkIn) => checkIn.id != checkInId)
          .toList();
      final derived = _computeDerivedValues();

      state = state.copyWith(
        isCompleting: false,
        checkIns: updatedCheckIns,
        upcomingCheckIns: updatedUpcoming,
        selectedCheckIn: completedCheckIn,
        error: null,
        isProcessing: false,
        hasUpcomingCheckIns: derived.hasUpcoming,
        dueSoonCount: derived.dueSoon,
        missedCount: derived.missed,
        nextCheckIn: derived.next,
      );
    } catch (e) {
      state = state.copyWith(
        isCompleting: false,
        isProcessing: false,
        error: e.toString(),
      );
    }
  }

  /// Cancel a check-in
  Future<void> cancelCheckIn(String checkInId) async {
    if (state.isCancelling) return;

    state = state.copyWith(isCancelling: true, error: null, isProcessing: true);
    try {
      await _cancelCheckIn(checkInId);

      final updatedCheckIns = state.checkIns.map((checkIn) {
        return checkIn.id == checkInId
            ? checkIn.copyWith(status: CheckInStatus.cancelled)
            : checkIn;
      }).toList();

      final updatedUpcoming = state.upcomingCheckIns
          .where((checkIn) => checkIn.id != checkInId)
          .toList();
      final derived = _computeDerivedValues();

      state = state.copyWith(
        isCancelling: false,
        checkIns: updatedCheckIns,
        upcomingCheckIns: updatedUpcoming,
        selectedCheckIn: state.selectedCheckIn?.id == checkInId
            ? null
            : state.selectedCheckIn,
        error: null,
        isProcessing: false,
        hasUpcomingCheckIns: derived.hasUpcoming,
        dueSoonCount: derived.dueSoon,
        missedCount: derived.missed,
        nextCheckIn: derived.next,
      );
    } catch (e) {
      state = state.copyWith(
        isCancelling: false,
        isProcessing: false,
        error: e.toString(),
      );
    }
  }

  /// Load check-ins for a specific trip
  Future<void> loadCheckInsByTrip(String tripId) async {
    state = state.copyWith(isLoading: true, error: null);
    try {
      final checkIns = await _getUpcomingCheckIns();
      final tripCheckIns =
          checkIns.where((checkIn) => checkIn.tripId == tripId).toList();
      final derived = _computeDerivedValues();

      state = state.copyWith(
        isLoading: false,
        checkIns: tripCheckIns,
        upcomingCheckIns: tripCheckIns,
        error: null,
        hasUpcomingCheckIns: derived.hasUpcoming,
        isProcessing: derived.isProcessing,
        dueSoonCount: derived.dueSoon,
        missedCount: derived.missed,
        nextCheckIn: derived.next,
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }
  }

  /// Select a check-in for viewing/editing
  void selectCheckIn(CheckIn? checkIn) {
    state = state.copyWith(selectedCheckIn: checkIn);
  }

  /// Clear the selected check-in
  void clearSelection() {
    state = state.copyWith(selectedCheckIn: null);
  }

  /// Clear any error message
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refresh upcoming check-ins
  Future<void> refreshUpcoming() async {
    await loadUpcomingCheckIns();
  }
}
