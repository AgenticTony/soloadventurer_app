import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/operation_queue.dart';

part 'trip_planning_operation.freezed.dart';
part 'trip_planning_operation.g.dart';

/// Represents different types of trip planning operations
enum TripPlanningType {
  create,
  update,
  delete,
  addDestination,
  removeDestination,
  updateDates,
}

@freezed
class TripPlanningOperation
    with _$TripPlanningOperation
    implements QueueableOperation {
  const factory TripPlanningOperation({
    required String id,
    required String tripId,
    required TripPlanningType planningType,
    required Map<String, dynamic> changes,
    @Default(2) int priority, // Higher than location updates
    DateTime? plannedStartDate,
    DateTime? plannedEndDate,
    // Retry metadata
    DateTime? createdAt,
    DateTime? lastAttempt,
    @Default(0) int attemptCount,
    String? lastError,
    @Default(3) int maxRetries,
  }) = _TripPlanningOperation;

  factory TripPlanningOperation.fromJson(Map<String, dynamic> json) =>
      _$TripPlanningOperationFromJson(json);

  const TripPlanningOperation._();

  /// Create a new trip planning operation
  factory TripPlanningOperation.create({
    required String tripName,
    required List<String> destinations,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return TripPlanningOperation(
      id: const Uuid().v4(),
      tripId: const Uuid().v4(), // New trip gets new ID
      planningType: TripPlanningType.create,
      changes: {
        'name': tripName,
        'destinations': destinations,
      },
      plannedStartDate: startDate,
      plannedEndDate: endDate,
      createdAt: DateTime.now(),
    );
  }

  /// Update an existing trip
  factory TripPlanningOperation.update({
    required String tripId,
    String? name,
    List<String>? destinations,
    DateTime? startDate,
    DateTime? endDate,
  }) {
    return TripPlanningOperation(
      id: const Uuid().v4(),
      tripId: tripId,
      planningType: TripPlanningType.update,
      changes: {
        if (name != null) 'name': name,
        if (destinations != null) 'destinations': destinations,
      },
      plannedStartDate: startDate,
      plannedEndDate: endDate,
      createdAt: DateTime.now(),
    );
  }

  @override
  String get type => 'trip_planning';

  @override
  bool get requiresNetwork => false; // Can work offline initially

  @override
  Future<void> execute() async {
    // TODO: Implement actual trip planning operation
    // This would update local storage and sync when online
    await Future.delayed(const Duration(milliseconds: 100));
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'tripId': tripId,
        'planningType': planningType.name,
        'changes': changes,
        'priority': priority,
        if (plannedStartDate != null)
          'plannedStartDate': plannedStartDate!.toIso8601String(),
        if (plannedEndDate != null)
          'plannedEndDate': plannedEndDate!.toIso8601String(),
        // Retry metadata
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (lastAttempt != null) 'lastAttempt': lastAttempt!.toIso8601String(),
        'attemptCount': attemptCount,
        if (lastError != null) 'lastError': lastError,
        'maxRetries': maxRetries,
      };
}
