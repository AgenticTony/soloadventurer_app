import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/entities/check_in.dart';

part 'check_in_state.freezed.dart';

/// Immutable state for Check-In functionality.
///
/// Riverpod 3.0 Compliant:
/// - All fields must be final (enforced by freezed)
/// - Uses sealed class as required by Freezed 3.2.x with Dart 3.10
/// - Loading/error handled by AsyncNotifier/AsyncValue, NOT state fields
@freezed
sealed class CheckInState with _$CheckInState {
  const CheckInState._();
  const factory CheckInState({
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

    /// Whether there are any upcoming check-ins
    @Default(false) bool hasUpcomingCheckIns,

    /// Whether operations are in progress
    @Default(false) bool isProcessing,

    /// Count of check-ins due within the next hour
    @Default(0) int dueSoonCount,

    /// Count of missed check-ins
    @Default(0) int missedCount,

    /// Next check-in (if any)
    CheckIn? nextCheckIn,
  }) = _CheckInState;

  factory CheckInState.initial() => const CheckInState();
}
