// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$ActivityImpl _$$ActivityImplFromJson(Map<String, dynamic> json) =>
    _$ActivityImpl(
      id: json['id'] as String,
      tripId: json['tripId'] as String,
      userId: json['userId'] as String,
      title: json['title'] as String,
      description: json['description'] as String?,
      category: $enumDecode(_$ActivityCategoryEnumMap, json['category']),
      locationName: json['locationName'] as String?,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num?)?.toDouble(),
      longitude: (json['longitude'] as num?)?.toDouble(),
      startDateTime: json['startDateTime'] == null
          ? null
          : DateTime.parse(json['startDateTime'] as String),
      endDateTime: json['endDateTime'] == null
          ? null
          : DateTime.parse(json['endDateTime'] as String),
      estimatedCost: (json['estimatedCost'] as num?)?.toDouble(),
      actualCost: (json['actualCost'] as num?)?.toDouble(),
      currency: json['currency'] as String?,
      confirmationNumber: json['confirmationNumber'] as String?,
      websiteUrl: json['websiteUrl'] as String?,
      phoneNumber: json['phoneNumber'] as String?,
      notes: json['notes'] as String?,
      isCompleted: json['isCompleted'] as bool? ?? false,
      isPriority: json['isPriority'] ?? false,
      photoIds: (json['photoIds'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      tags: (json['tags'] as List<dynamic>?)?.map((e) => e as String).toList(),
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$$ActivityImplToJson(_$ActivityImpl instance) =>
    <String, dynamic>{
      'id': instance.id,
      'tripId': instance.tripId,
      'userId': instance.userId,
      'title': instance.title,
      'description': instance.description,
      'category': _$ActivityCategoryEnumMap[instance.category]!,
      'locationName': instance.locationName,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
      'startDateTime': instance.startDateTime?.toIso8601String(),
      'endDateTime': instance.endDateTime?.toIso8601String(),
      'estimatedCost': instance.estimatedCost,
      'actualCost': instance.actualCost,
      'currency': instance.currency,
      'confirmationNumber': instance.confirmationNumber,
      'websiteUrl': instance.websiteUrl,
      'phoneNumber': instance.phoneNumber,
      'notes': instance.notes,
      'isCompleted': instance.isCompleted,
      'isPriority': instance.isPriority,
      'photoIds': instance.photoIds,
      'tags': instance.tags,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };

const _$ActivityCategoryEnumMap = {
  ActivityCategory.food: 'food',
  ActivityCategory.transport: 'transport',
  ActivityCategory.accommodation: 'accommodation',
  ActivityCategory.activity: 'activity',
  ActivityCategory.sightseeing: 'sightseeing',
  ActivityCategory.shopping: 'shopping',
  ActivityCategory.other: 'other',
};
