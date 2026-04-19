import 'dart:convert';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/models/sync_status.dart';

part 'sync_state.freezed.dart';

/// Comprehensive state for sync operations
///
/// Tracks all sync-related state including current status,
/// queue information, and last sync results for real-time UI updates.
///
/// Riverpod 3.0 Migration:
/// - Removed isProcessing (handled by AsyncValue loading state)
/// - Removed lastError (handled by AsyncValue error state)
/// - Uses @freezed for immutability and copyWith
@freezed
sealed class SyncState with _$SyncState {
  const SyncState._();

  /// Default constructor
  const factory SyncState({
    /// Current sync status
    required SyncOperationStatus status,

    /// Number of operations in the sync queue
    @Default(0) int queueSize,

    /// Timestamp of last status change
    DateTime? lastStatusChangeAt,

    /// Timestamp of last successful sync
    DateTime? lastSuccessfulSyncAt,

    /// Number of operations successfully synced in last sync
    @Default(0) int lastSuccessCount,

    /// Number of operations that failed in last sync
    @Default(0) int lastFailureCount,

    /// Whether there are pending operations
    @Default(false) bool hasPendingOperations,
  }) = _SyncState;

  /// Factory constructor for initial state
  factory SyncState.initial() => const SyncState(
        status: SyncOperationStatus.idle,
        queueSize: 0,
      );

  /// Whether the current state represents an active sync
  bool get isSyncing => status == SyncOperationStatus.syncing;

  /// Whether the last sync was successful
  bool get wasLastSyncSuccessful => status == SyncOperationStatus.success;

  /// Whether the last sync failed
  bool get didLastSyncFail => status == SyncOperationStatus.failed;

  /// Whether there are operations waiting to sync
  bool get hasQueue => queueSize > 0;

  /// Total operations from last sync
  int get lastTotalOperations => lastSuccessCount + lastFailureCount;

  /// Success rate of last sync (0.0 to 1.0, or null if no operations)
  double? get lastSuccessRate {
    if (lastTotalOperations == 0) return null;
    return lastSuccessCount / lastTotalOperations;
  }

  /// Convert state to JSON for serialization
  Map<String, dynamic> toJson() => {
        'status': status.name,
        'queueSize': queueSize,
        'lastStatusChangeAt': lastStatusChangeAt?.toIso8601String(),
        'lastSuccessfulSyncAt': lastSuccessfulSyncAt?.toIso8601String(),
        'lastSuccessCount': lastSuccessCount,
        'lastFailureCount': lastFailureCount,
        'hasPendingOperations': hasPendingOperations,
      };

  /// Create state from JSON
  static SyncState? fromJson(Map<String, dynamic> json) {
    try {
      final statusString = json['status'] as String?;
      if (statusString == null) return null;

      SyncOperationStatus? status;
      for (final s in SyncOperationStatus.values) {
        if (s.name == statusString) {
          status = s;
          break;
        }
      }
      if (status == null) return null;

      return SyncState(
        status: status,
        queueSize: json['queueSize'] as int? ?? 0,
        lastStatusChangeAt:
            _parseDateTime(json['lastStatusChangeAt'] as String?),
        lastSuccessfulSyncAt:
            _parseDateTime(json['lastSuccessfulSyncAt'] as String?),
        lastSuccessCount: json['lastSuccessCount'] as int? ?? 0,
        lastFailureCount: json['lastFailureCount'] as int? ?? 0,
        hasPendingOperations: json['hasPendingOperations'] as bool? ?? false,
      );
    } catch (e) {
      return null;
    }
  }

  /// Parse DateTime from ISO8601 string
  static DateTime? _parseDateTime(String? dateTimeString) {
    if (dateTimeString == null || dateTimeString.isEmpty) return null;
    try {
      return DateTime.parse(dateTimeString);
    } catch (e) {
      return null;
    }
  }

  /// Serialize state to JSON string
  String toJsonString() => jsonEncode(toJson());

  /// Deserialize state from JSON string
  static SyncState? fromJsonString(String jsonString) {
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return fromJson(json);
    } catch (e) {
      return null;
    }
  }
}
