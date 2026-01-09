import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../core/services/operation_queue.dart';
import '../../../core/services/operation_priority.dart';

part 'travel_note_operation.freezed.dart';
part 'travel_note_operation.g.dart';

/// Types of travel notes
enum NoteType {
  text,
  photo,
  voice,
  location,
  expense,
}

@freezed
class TravelNoteOperation
    with _$TravelNoteOperation
    implements QueueableOperation {
  const factory TravelNoteOperation({
    required String id,
    required String tripId,
    required NoteType noteType,
    required Map<String, dynamic> content,
    required int priority,
    String? locationName,
    double? latitude,
    double? longitude,
    DateTime? timestamp,
    // Retry metadata
    DateTime? createdAt,
    DateTime? lastAttempt,
    @Default(0) int attemptCount,
    String? lastError,
    @Default(3) int maxRetries,
  }) = _TravelNoteOperation;

  factory TravelNoteOperation.fromJson(Map<String, dynamic> json) =>
      _$TravelNoteOperationFromJson(json);

  const TravelNoteOperation._();

  /// Create a text note
  factory TravelNoteOperation.text({
    required String tripId,
    required String text,
    String? locationName,
    double? latitude,
    double? longitude,
  }) {
    return TravelNoteOperation(
      id: const Uuid().v4(),
      tripId: tripId,
      noteType: NoteType.text,
      content: {'text': text},
      priority: OperationPriority.normal.value,
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  /// Create an expense note
  factory TravelNoteOperation.expense({
    required String tripId,
    required double amount,
    required String currency,
    required String category,
    String? description,
    String? locationName,
    double? latitude,
    double? longitude,
  }) {
    return TravelNoteOperation(
      id: const Uuid().v4(),
      tripId: tripId,
      noteType: NoteType.expense,
      content: {
        'amount': amount,
        'currency': currency,
        'category': category,
        if (description != null) 'description': description,
      },
      priority: OperationPriority.normal.value,
      locationName: locationName,
      latitude: latitude,
      longitude: longitude,
      timestamp: DateTime.now(),
      createdAt: DateTime.now(),
    );
  }

  @override
  String get type => 'travel_note';

  @override
  bool get requiresNetwork => false; // Notes work offline

  @override
  String? get deduplicationKey {
    // Notes are unique user actions and should not be deduplicated.
    // Each note operation has its own UUID and represents a distinct
    // piece of content created by the user (text, expense, photo, etc.).
    // Even if multiple notes of the same type are created for the same trip,
    // they should all be processed to ensure no data loss.
    return null;
  }

  @override
  Future<void> execute() async {
    // TODO: Implement actual note storage
    // This would save to local storage and sync when online
    await Future.delayed(const Duration(milliseconds: 50));
  }

  @override
  Map<String, dynamic> toJson() => {
        'id': id,
        'tripId': tripId,
        'noteType': noteType.toString(),
        'content': content,
        'priority': priority,
        if (locationName != null) 'locationName': locationName,
        if (latitude != null) 'latitude': latitude,
        if (longitude != null) 'longitude': longitude,
        if (timestamp != null) 'timestamp': timestamp!.toIso8601String(),
        // Retry metadata
        if (createdAt != null) 'createdAt': createdAt!.toIso8601String(),
        if (lastAttempt != null) 'lastAttempt': lastAttempt!.toIso8601String(),
        'attemptCount': attemptCount,
        if (lastError != null) 'lastError': lastError,
        'maxRetries': maxRetries,
      };
}
