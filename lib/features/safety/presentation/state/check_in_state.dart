import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/check_in.dart';

part 'check_in_state.freezed.dart';

/// Immutable state for Check-In functionality.
///
/// Riverpod 2 Compliant:
/// - All fields must be final (enforced by freezed)
/// - NO getters - all derived values are fields
/// - isLoading and error are ALWAYS fields on state
/// - State is NEVER nullable
@freezed
sealed class CheckInState with _$CheckInState {
  const factory CheckInState({
    /// Loading indicator - always a field on State
    @Default(false) bool isLoading,

    /// Whether a check-in creation is in progress
    @Default(false) bool isCreating,

    /// Whether a check-in completion is in progress
    @Default(false) bool isCompleting,

    /// Whether a check-in cancellation is in progress
    @Default(false) bool isCancelling,

    /// List of all check-ins
    @Default([]) List<CheckIn> checkIns,

    /// List of upcoming (scheduled/active) check-ins
    @Default([]) List<CheckIn> upcomingCheckIns,

    /// Currently selected check-in (for viewing/editing)
    CheckIn? selectedCheckIn,

    /// Error message - always a field on State
    String? error,

    /// Whether there are any upcoming check-ins (was a getter, now a field)
    @Default(false) bool hasUpcomingCheckIns,

    /// Whether operations are in progress (was a getter, now a field)
    @Default(false) bool isProcessing,

    /// Count of check-ins due within the next hour (was a getter, now a field)
    @Default(0) int dueSoonCount,

    /// Count of missed check-ins (was a getter, now a field)
    @Default(0) int missedCount,

    /// Next check-in (if any) - was a getter, now a field
    CheckIn? nextCheckIn,
  }) = _CheckInState;

  factory CheckInState.initial() => const CheckInState();
}
