// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'travel_note_operation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TravelNoteOperation _$TravelNoteOperationFromJson(Map<String, dynamic> json) =>
    _TravelNoteOperation(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      noteType: $enumDecode(_$NoteTypeEnumMap, json['noteType']),
      content: json['content'] as Map<String, dynamic>,
      priority: json['priority'] == null
          ? OperationPriority.normal
          : const OperationPriorityConverter()
              .fromJson((json['priority'] as num).toInt()),
      locationName: json['locationName'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
      createdAt: json['createdAt'] == null
          ? null
          : DateTime.parse(json['createdAt'] as String),
      lastAttempt: json['lastAttempt'] == null
          ? null
          : DateTime.parse(json['lastAttempt'] as String),
      attemptCount: (json['attemptCount'] as num?)?.toInt() ?? 0,
      lastError: json['lastError'] as String?,
      maxRetries: (json['maxRetries'] as num?)?.toInt() ?? 3,
    );

Map<String, dynamic> _$TravelNoteOperationToJson(
        _TravelNoteOperation instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tripId': instance.tripId,
      'noteType': _$NoteTypeEnumMap[instance.noteType]!,
      'content': instance.content,
      'priority': const OperationPriorityConverter().toJson(instance.priority),
      'locationName': instance.locationName,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'timestamp': instance.timestamp?.toIso8601String(),
      'createdAt': instance.createdAt?.toIso8601String(),
      'lastAttempt': instance.lastAttempt?.toIso8601String(),
      'attemptCount': instance.attemptCount,
      'lastError': instance.lastError,
      'maxRetries': instance.maxRetries,
    };

const _$NoteTypeEnumMap = {
  NoteType.text: 'text',
  NoteType.photo: 'photo',
  NoteType.voice: 'voice',
  NoteType.location: 'location',
  NoteType.expense: 'expense',
};
