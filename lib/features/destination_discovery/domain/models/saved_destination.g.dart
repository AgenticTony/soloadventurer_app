// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'saved_destination.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SavedDestination _$SavedDestinationFromJson(Map<String, dynamic> json) =>
    _SavedDestination(
      id: json['id'] as String,
      userId: json['userId'] as String,
      destination:
          Destination.fromJson(json['destination'] as Map<String, dynamic>),
      saveType: $enumDecode(_$SaveTypeEnumMap, json['saveType']),
      tripId: json['tripId'] as String?,
      notes: json['notes'] as String?,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$SavedDestinationToJson(_SavedDestination instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'destination': instance.destination,
      'saveType': _$SaveTypeEnumMap[instance.saveType]!,
      'tripId': instance.tripId,
      'notes': instance.notes,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$SaveTypeEnumMap = {
  SaveType.wishlist: 'wishlist',
  SaveType.trip: 'trip',
};
