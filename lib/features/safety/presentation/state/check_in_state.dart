import 'package:equatable/equatable.dart';
import '../../domain/entities/check_in.dart';

/// State for check-in functionality
/// Manages check-ins, scheduled check-ins, and check-in history
class CheckInState extends Equatable {
  /// Whether check-ins are currently loading
  final bool isLoading;

  /// Whether a check-in creation is in progress
  final bool isCreating;

  /// Whether a check-in completion is in progress
  final bool isCompleting;

  /// Whether a check-in cancellation is in progress
  final bool isCancelling;

  /// List of all check-ins
  final List<CheckIn> checkIns;

  /// List of upcoming (scheduled/active) check-ins
  final List<CheckIn> upcomingCheckIns;

  /// Currently selected check-in (for viewing/editing)
  final CheckIn? selectedCheckIn;

  /// Error message if any operation failed
  final String? error;

  /// Whether there are any upcoming check-ins
  bool get hasUpcomingCheckIns => upcomingCheckIns.isNotEmpty;

  /// Whether operations are in progress
  bool get isProcessing => isCreating || isCompleting || isCancelling;

  /// Count of check-ins due within the next hour
  int get dueSoonCount => upcomingCheckIns
      .where((checkIn) {
        final deadline = checkIn.deadline;
        if (deadline == null) return false;
        return deadline.isBefore(DateTime.now().add(const Duration(hours: 1)));
      })
      .length;

  /// Count of missed check-ins
  int get missedCount => checkIns
      .where((checkIn) => checkIn.status == CheckInStatus.missed)
      .length;

  /// Next check-in (if any)
  CheckIn? get nextCheckIn {
    if (upcomingCheckIns.isEmpty) return null;
    upcomingCheckIns.sort((a, b) {
      final aTime = a.scheduledTime ?? a.deadline ?? DateTime.now();
      final bTime = b.scheduledTime ?? b.deadline ?? DateTime.now();
      return aTime.compareTo(bTime);
    });
    return upcomingCheckIns.first;
  }

  const CheckInState({
    this.isLoading = false,
    this.isCreating = false,
    this.isCompleting = false,
    this.isCancelling = false,
    this.checkIns = const [],
    this.upcomingCheckIns = const [],
    this.selectedCheckIn,
    this.error,
  });

  /// Creates a copy of this state with the given fields replaced
  CheckInState copyWith({
    bool? isLoading,
    bool? isCreating,
    bool? isCompleting,
    bool? isCancelling,
    List<CheckIn>? checkIns,
    List<CheckIn>? upcomingCheckIns,
    CheckIn? selectedCheckIn,
    String? error,
    bool clearSelected = false,
  }) {
    return CheckInState(
      isLoading: isLoading ?? this.isLoading,
      isCreating: isCreating ?? this.isCreating,
      isCompleting: isCompleting ?? this.isCompleting,
      isCancelling: isCancelling ?? this.isCancelling,
      checkIns: checkIns ?? this.checkIns,
      upcomingCheckIns: upcomingCheckIns ?? this.upcomingCheckIns,
      selectedCheckIn: clearSelected ? null : (selectedCheckIn ?? this.selectedCheckIn),
      error: error ?? this.error,
    );
  }

  @override
  List<Object?> get props => [
        isLoading,
        isCreating,
        isCompleting,
        isCancelling,
        checkIns,
        upcomingCheckIns,
        selectedCheckIn,
        error,
      ];
}
