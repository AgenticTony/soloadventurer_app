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
  }) = _LocationUpdateOperation;

  factory LocationUpdateOperation.fromJson(Map<String, dynamic> json) =>
      _$LocationUpdateOperationFromJson(json);

  const LocationUpdateOperation._();

  @override
  String get type => 'location_update';

  @override
  bool get requiresNetwork => true;

  @override
  Future<void> execute() async {
    // TODO: Implement actual location update
    // This would call your travel service to update the user's location
    await Future.delayed(const Duration(seconds: 1)); // Simulate network call
  }
}
