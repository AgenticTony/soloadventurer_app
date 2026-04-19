import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_info.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_resolution.dart';

part 'conflict_resolution_state.freezed.dart';

/// State for conflict resolution UI and logic
///
/// Represents the current state of resolving a sync conflict,
/// including pending conflicts, active resolution, and completion status.
///
/// Riverpod 3.0 Migration:
/// - Removed isResolving (handled by AsyncValue loading state)
/// - Removed errorMessage (handled by AsyncValue error state)
/// - Uses @freezed for immutability and copyWith
@freezed
sealed class ConflictResolutionState with _$ConflictResolutionState {
  const ConflictResolutionState._();

  /// Default constructor
  const factory ConflictResolutionState({
    /// List of conflicts waiting to be resolved
    @Default([]) List<ConflictInfo> pendingConflicts,

    /// Conflict currently being resolved
    ConflictInfo? activeConflict,

    /// Resolution result when conflict has been resolved
    ConflictResolution? resolution,

    /// Whether the user cancelled the resolution
    @Default(false) bool wasCancelled,

    /// Timestamp when resolution was completed
    DateTime? completedAt,
  }) = _ConflictResolutionState;

  /// Initial state with no conflicts
  factory ConflictResolutionState.initial() => const ConflictResolutionState();

  /// State with active conflict being resolved
  factory ConflictResolutionState.resolving(ConflictInfo conflict) =>
      ConflictResolutionState(
        activeConflict: conflict,
      );

  /// State with successful resolution
  factory ConflictResolutionState.resolved({
    required ConflictInfo conflict,
    required ConflictResolution resolution,
  }) =>
      ConflictResolutionState(
        activeConflict: conflict,
        resolution: resolution,
        completedAt: DateTime.now().toUtc(),
      );

  /// State with cancelled resolution
  factory ConflictResolutionState.cancelled(ConflictInfo conflict) =>
      ConflictResolutionState(
        activeConflict: conflict,
        wasCancelled: true,
        completedAt: DateTime.now().toUtc(),
      );

  /// State with multiple pending conflicts
  factory ConflictResolutionState.withPendingConflicts(
    List<ConflictInfo> conflicts,
  ) =>
      ConflictResolutionState(
        pendingConflicts: conflicts,
      );

  /// Whether there are any conflicts (pending or active)
  bool get hasConflicts =>
      pendingConflicts.isNotEmpty || activeConflict != null;

  /// Whether the resolution was successful
  bool get isResolved => resolution != null;

  /// Number of conflicts still pending
  int get pendingCount => pendingConflicts.length;
}
