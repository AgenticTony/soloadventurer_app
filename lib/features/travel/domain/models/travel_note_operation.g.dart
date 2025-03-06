// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'travel_note_operation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$TravelNoteOperationImpl _$$TravelNoteOperationImplFromJson(
        Map<String, dynamic> json) =>
    _$TravelNoteOperationImpl(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      noteType: $enumDecode(_$NoteTypeEnumMap, json['noteType']),
      content: json['content'] as Map<String, dynamic>,
      priority: (json['priority'] as num?)?.toInt() ?? 1,
      locationName: json['locationName'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      timestamp: json['timestamp'] == null
          ? null
          : DateTime.parse(json['timestamp'] as String),
    );

Map<String, dynamic> _$$TravelNoteOperationImplToJson(
        _$TravelNoteOperationImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tripId': instance.tripId,
      'noteType': _$NoteTypeEnumMap[instance.noteType]!,
      'content': instance.content,
      'priority': instance.priority,
      'locationName': instance.locationName,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'timestamp': instance.timestamp?.toIso8601String(),
    };

const _$NoteTypeEnumMap = {
  NoteType.text: 'text',
  NoteType.photo: 'photo',
  NoteType.voice: 'voice',
  NoteType.location: 'location',
  NoteType.expense: 'expense',
};
