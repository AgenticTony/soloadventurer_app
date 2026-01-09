import 'package:equatable/equatable.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_info.dart';
import 'package:soloadventurer/features/sync/domain/models/conflict_resolution.dart';

/// State for conflict resolution UI and logic
///
/// Represents the current state of resolving a sync conflict,
/// including pending conflicts, active resolution, and completion status.
class ConflictResolutionState extends Equatable {
  /// List of conflicts waiting to be resolved
  final List<ConflictInfo> pendingConflicts;

  /// Conflict currently being resolved
  final ConflictInfo? activeConflict;

  /// Resolution result when conflict has been resolved
  final ConflictResolution? resolution;

  /// Whether a resolution is in progress
  final bool isResolving;

  /// Error message if resolution failed
  final String? errorMessage;

  /// Whether the user cancelled the resolution
  final bool wasCancelled;

  /// Timestamp when resolution was completed
  final DateTime? completedAt;

  const ConflictResolutionState({
    this.pendingConflicts = const [],
    this.activeConflict,
    this.resolution,
    this.isResolving = false,
    this.errorMessage,
    this.wasCancelled = false,
    this.completedAt,
  });

  /// Initial state with no conflicts
  factory ConflictResolutionState.initial() {
    return const ConflictResolutionState();
  }

  /// State with active conflict being resolved
  factory ConflictResolutionState.resolving(ConflictInfo conflict) {
    return ConflictResolutionState(
      activeConflict: conflict,
      isResolving: true,
    );
  }

  /// State with successful resolution
  factory ConflictResolutionState.resolved({
    required ConflictInfo conflict,
    required ConflictResolution resolution,
  }) {
    return ConflictResolutionState(
      activeConflict: conflict,
      resolution: resolution,
      isResolving: false,
      completedAt: DateTime.now().toUtc(),
    );
  }

  /// State with failed resolution
  factory ConflictResolutionState.failed({
    required ConflictInfo conflict,
    required String errorMessage,
  }) {
    return ConflictResolutionState(
      activeConflict: conflict,
      isResolving: false,
      errorMessage: errorMessage,
      completedAt: DateTime.now().toUtc(),
    );
  }

  /// State with cancelled resolution
  factory ConflictResolutionState.cancelled(ConflictInfo conflict) {
    return ConflictResolutionState(
      activeConflict: conflict,
      isResolving: false,
      wasCancelled: true,
      completedAt: DateTime.now().toUtc(),
    );
  }

  /// State with multiple pending conflicts
  factory ConflictResolutionState.withPendingConflicts(
    List<ConflictInfo> conflicts,
  ) {
    return ConflictResolutionState(
      pendingConflicts: conflicts,
    );
  }

  /// Whether there are any conflicts (pending or active)
  bool get hasConflicts =>
      pendingConflicts.isNotEmpty || activeConflict != null;

  /// Whether the resolution was successful
  bool get isResolved => resolution != null && !isResolving;

  /// Whether the resolution failed
  bool get hasError => errorMessage != null;

  /// Number of conflicts still pending
  int get pendingCount => pendingConflicts.length;

  /// Creates a copy with the given fields replaced
  ConflictResolutionState copyWith({
    List<ConflictInfo>? pendingConflicts,
    ConflictInfo? activeConflict,
    ConflictResolution? resolution,
    bool? isResolving,
    String? errorMessage,
    bool? wasCancelled,
    DateTime? completedAt,
  }) {
    return ConflictResolutionState(
      pendingConflicts: pendingConflicts ?? this.pendingConflicts,
      activeConflict: activeConflict ?? this.activeConflict,
      resolution: resolution ?? this.resolution,
      isResolving: isResolving ?? this.isResolving,
      errorMessage: errorMessage ?? this.errorMessage,
      wasCancelled: wasCancelled ?? this.wasCancelled,
      completedAt: completedAt ?? this.completedAt,
    );
  }

  @override
  List<Object?> get props => [
        pendingConflicts,
        activeConflict,
        resolution,
        isResolving,
        errorMessage,
        wasCancelled,
        completedAt,
      ];

  @override
  String toString() => 'ConflictResolutionState('
      'pending: ${pendingConflicts.length}, '
      'active: ${activeConflict?.entityId ?? 'none'}, '
      'resolved: ${resolution != null}, '
      'resolving: $isResolving, '
      'error: ${errorMessage != null}, '
      'cancelled: $wasCancelled)';
}
