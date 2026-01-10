import 'dart:convert';
import 'package:equatable/equatable.dart';
import 'sync_status.dart';
import 'sync_error.dart';

/// Represents a single sync operation in the history log
class SyncHistoryEntry extends Equatable {
  /// Unique identifier for this history entry
  final String id;

  /// Status of this sync operation
  final SyncOperationStatus status;

  /// Timestamp when the sync operation started
  final DateTime startedAt;

  /// Timestamp when the sync operation completed (null if still in progress)
  final DateTime? completedAt;

  /// Number of operations successfully synced
  final int successCount;

  /// Number of operations that failed
  final int failureCount;

  /// Total number of operations processed
  final int totalCount;

  /// Error information if sync failed (null if successful or in progress)
  final SyncError? error;

  /// Whether this was a manual sync (user-triggered) or automatic
  final bool isManual;

  /// Network connection type during sync (wifi, mobile, none, etc.)
  final String? connectionType;

  /// Duration of the sync operation (null if not completed)
  Duration? get duration {
    if (completedAt == null) return null;
    return completedAt!.difference(startedAt);
  }

  /// Success rate (0.0 to 1.0, or null if no operations)
  double? get successRate {
    if (totalCount == 0) return null;
    return successCount / totalCount;
  }

  /// Whether this entry represents a successful sync
  bool get isSuccessful => status == SyncOperationStatus.success;

  /// Whether this entry represents a failed sync
  bool get isFailed => status == SyncOperationStatus.failed;

  /// Whether this entry represents a sync that's still in progress
  bool get isInProgress => status == SyncOperationStatus.syncing;

  const SyncHistoryEntry({
    required this.id,
    required this.status,
    required this.startedAt,
    this.completedAt,
    this.successCount = 0,
    this.failureCount = 0,
    this.totalCount = 0,
    this.error,
    this.isManual = false,
    this.connectionType,
  });

  /// Creates a copy of this entry with the given fields replaced
  SyncHistoryEntry copyWith({
    String? id,
    SyncOperationStatus? status,
    DateTime? startedAt,
    DateTime? completedAt,
    int? successCount,
    int? failureCount,
    int? totalCount,
    SyncError? error,
    bool? isManual,
    String? connectionType,
    bool clearError = false,
  }) {
    return SyncHistoryEntry(
      id: id ?? this.id,
      status: status ?? this.status,
      startedAt: startedAt ?? this.startedAt,
      completedAt: completedAt ?? this.completedAt,
      successCount: successCount ?? this.successCount,
      failureCount: failureCount ?? this.failureCount,
      totalCount: totalCount ?? this.totalCount,
      error: clearError ? null : (error ?? this.error),
      isManual: isManual ?? this.isManual,
      connectionType: connectionType ?? this.connectionType,
    );
  }

  /// Creates a new history entry for a sync operation that's starting
  factory SyncHistoryEntry.start({
    required String id,
    bool isManual = false,
    String? connectionType,
  }) {
    return SyncHistoryEntry(
      id: id,
      status: SyncOperationStatus.syncing,
      startedAt: DateTime.now(),
      isManual: isManual,
      connectionType: connectionType,
    );
  }

  /// Creates a successful history entry
  factory SyncHistoryEntry.success({
    required String id,
    required DateTime startedAt,
    required int successCount,
    required int failureCount,
    required int totalCount,
    bool isManual = false,
    String? connectionType,
  }) {
    return SyncHistoryEntry(
      id: id,
      status: SyncOperationStatus.success,
      startedAt: startedAt,
      completedAt: DateTime.now(),
      successCount: successCount,
      failureCount: failureCount,
      totalCount: totalCount,
      isManual: isManual,
      connectionType: connectionType,
    );
  }

  /// Creates a failed history entry
  factory SyncHistoryEntry.failure({
    required String id,
    required DateTime startedAt,
    required int successCount,
    required int failureCount,
    required int totalCount,
    required SyncError error,
    bool isManual = false,
    String? connectionType,
  }) {
    return SyncHistoryEntry(
      id: id,
      status: SyncOperationStatus.failed,
      startedAt: startedAt,
      completedAt: DateTime.now(),
      successCount: successCount,
      failureCount: failureCount,
      totalCount: totalCount,
      error: error,
      isManual: isManual,
      connectionType: connectionType,
    );
  }

  @override
  List<Object?> get props => [
        id,
        status,
        startedAt,
        completedAt,
        successCount,
        failureCount,
        totalCount,
        error,
        isManual,
        connectionType,
      ];

  @override
  String toString() {
    return 'SyncHistoryEntry('
        'id: $id, '
        'status: $status, '
        'startedAt: $startedAt, '
        'completedAt: $completedAt, '
        'successCount: $successCount, '
        'failureCount: $failureCount, '
        'totalCount: $totalCount, '
        'isManual: $isManual, '
        'connectionType: $connectionType)';
  }

  /// Convert entry to JSON for serialization
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'status': status.name,
      'startedAt': startedAt.toIso8601String(),
      'completedAt': completedAt?.toIso8601String(),
      'successCount': successCount,
      'failureCount': failureCount,
      'totalCount': totalCount,
      'error': error?.toJson(),
      'isManual': isManual,
      'connectionType': connectionType,
    };
  }

  /// Create entry from JSON
  ///
  /// Returns null if JSON is invalid or required fields are missing
  static SyncHistoryEntry? fromJson(Map<String, dynamic> json) {
    try {
      // Parse status from string
      final statusString = json['status'] as String?;
      if (statusString == null) return null;

      final status = SyncOperationStatus.values.firstWhere(
        (s) => s.name == statusString,
        orElse: () => SyncOperationStatus.idle,
      );

      // Parse error if present
      final errorJson = json['error'] as Map<String, dynamic>?;
      final error = errorJson != null ? SyncError.fromJson(errorJson) : null;

      return SyncHistoryEntry(
        id: json['id'] as String,
        status: status,
        startedAt: DateTime.parse(json['startedAt'] as String),
        completedAt: _parseDateTime(json['completedAt'] as String?),
        successCount: json['successCount'] as int? ?? 0,
        failureCount: json['failureCount'] as int? ?? 0,
        totalCount: json['totalCount'] as int? ?? 0,
        error: error,
        isManual: json['isManual'] as bool? ?? false,
        connectionType: json['connectionType'] as String?,
      );
    } catch (e) {
      // Return null on any parsing error
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

  /// Serialize entry list to JSON string
  static String toJsonString(List<SyncHistoryEntry> entries) {
    final jsonList = entries.map((e) => e.toJson()).toList();
    return const JsonEncoder.withIndent('  ').convert(jsonList);
  }

  /// Deserialize entry list from JSON string
  ///
  /// Returns empty list if string is invalid or JSON is malformed
  static List<SyncHistoryEntry> fromJsonString(String jsonString) {
    try {
      final dynamic decoded = const JsonDecoder().convert(jsonString);
      if (decoded is! List) return [];

      final entries = <SyncHistoryEntry>[];
      for (final item in decoded) {
        if (item is Map<String, dynamic>) {
          final entry = SyncHistoryEntry.fromJson(item);
          if (entry != null) {
            entries.add(entry);
          }
        }
      }
      return entries;
    } catch (e) {
      return [];
    }
  }
}
