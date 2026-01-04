import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/services/operation_queue.dart';

part 'location_update_operation.freezed.dart';
part 'location_update_operation.g.dart';

@freezed
class LocationUpdateOperation
    with _$LocationUpdateOperation
    implements QueueableOperation {
  const factory LocationUpdateOperation({
    required String id,
    required double latitude,
    required double longitude,
    required DateTime timestamp,
    @Default(1) int priority,
    // Retry metadata
    DateTime? createdAt,
    DateTime? lastAttempt,
    @Default(0) int attemptCount,
    String? lastError,
    @Default(3) int maxRetries,
  }) = _LocationUpdateOperation;

  factory LocationUpdateOperation.fromJson(Map<String, dynamic> json) =>
      _$LocationUpdateOperationFromJson(json);

  const LocationUpdateOperation._();

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
}
