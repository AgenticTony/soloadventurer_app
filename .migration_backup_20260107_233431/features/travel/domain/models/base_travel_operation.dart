import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../core/services/operation_priority.dart';

part 'base_travel_operation.freezed.dart';
part 'base_travel_operation.g.dart';

@freezed
class BaseTravelOperation with _$BaseTravelOperation {
  const factory BaseTravelOperation({
    required String id,
    required String type,
    required DateTime timestamp,
    @OperationPriorityConverter() @Default(OperationPriority.low) OperationPriority priority,
    @Default(true) bool requiresNetwork,
    @Default({}) Map<String, dynamic> data,
  }) = _BaseTravelOperation;

  factory BaseTravelOperation.fromJson(Map<String, dynamic> json) =>
      _$BaseTravelOperationFromJson(json);
}
