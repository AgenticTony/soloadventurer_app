import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/operation_queue.dart';
import '../../../core/services/operation_priority.dart';

part 'location_update_operation.freezed.dart';
part 'location_update_operation.g.dart';

@freezed
sealed class LocationUpdateOperation
    with _$LocationUpdateOperation
    implements QueueableOperation {
  // Private constructor for freezed with custom members
  const LocationUpdateOperation._();

  const factory LocationUpdateOperation({
    required String id,
    required double latitude,
    required double longitude,
    required DateTime timestamp,
    required int priority,
    // Retry metadata
    DateTime? createdAt,
    DateTime? lastAttempt,
    @Default(0) int attemptCount,
    String? lastError,
    @Default(3) int maxRetries,
  }) = _LocationUpdateOperation;

  factory LocationUpdateOperation.fromJson(Map<String, dynamic> json) =>
      _$LocationUpdateOperationFromJson(json);

  /// Create a new location update operation
  factory LocationUpdateOperation.create({
    required double latitude,
    required double longitude,
    DateTime? timestamp,
  }) {
    return LocationUpdateOperation(
      id: const Uuid().v4(),
      latitude: latitude,
      longitude: longitude,
      timestamp: timestamp ?? DateTime.now(),
      priority: OperationPriority.low.value,
      createdAt: DateTime.now(),
    );
  }

  @override
  String get type => 'location_update';

  @override
  bool get requiresNetwork => true;

  @override
  String? get deduplicationKey {
    // Location updates form a time-series data stream and should not be deduplicated.
    // Each location update represents the user's location at a specific point in time,
    // and losing any updates would result in gaps in the location history.
    // The queue system will process them in timestamp order to maintain chronological integrity.
    return null;
  }

  @override
  Future<void> execute() async {
    // TODO: Implement actual location update
    // This would call your travel service to update the user's location
    await Future.delayed(const Duration(seconds: 1)); // Simulate network call
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'latitude': latitude,
        'longitude': longitude,
        'timestamp': timestamp.toIso8601String(),
        'priority': priority,
        // Retry metadata
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (lastAttempt != null) 'lastAttempt': lastAttempt!.toIso8601String(),
        'attemptCount': attemptCount,
        if (lastError != null) 'lastError': lastError,
        'maxRetries': maxRetries,
      };

  @override
  QueueableOperation withAttemptMetadata({
    DateTime? lastAttempt,
    int? attemptCount,
    String? lastError,
  }) {
    return copyWith(
      lastAttempt: lastAttempt ?? this.lastAttempt,
      attemptCount: attemptCount ?? this.attemptCount,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  QueueableOperation resetForRetry() {
    return copyWith(
      lastAttempt: null,
      attemptCount: 0,
      lastError: null,
    );
  }
}
