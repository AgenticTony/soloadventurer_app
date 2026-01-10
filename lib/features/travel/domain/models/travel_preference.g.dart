// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'travel_preference.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_TravelPreference _$TravelPreferenceFromJson(Map<String, dynamic> json) =>
    _TravelPreference(
      id: json['id'] as String,
      userId: json['userId'] as String,
      travelStyles: (json['travelStyles'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      accommodationTypes: (json['accommodationTypes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      transportationTypes: (json['transportationTypes'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      minBudget: (json['minBudget'] as num).toInt(),
      maxBudget: (json['maxBudget'] as num).toInt(),
      minTripDuration: (json['minTripDuration'] as num).toInt(),
      maxTripDuration: (json['maxTripDuration'] as num).toInt(),
      preferredDestinations: (json['preferredDestinations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      avoidDestinations: (json['avoidDestinations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      isFlexibleDates: json['isFlexibleDates'] as bool,
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
    );

Map<String, dynamic> _$TravelPreferenceToJson(_TravelPreference instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'travelStyles': instance.travelStyles,
      'accommodationTypes': instance.accommodationTypes,
      'transportationTypes': instance.transportationTypes,
      'minBudget': instance.minBudget,
      'maxBudget': instance.maxBudget,
      'minTripDuration': instance.minTripDuration,
      'maxTripDuration': instance.maxTripDuration,
      'preferredDestinations': instance.preferredDestinations,
      'avoidDestinations': instance.avoidDestinations,
      'isFlexibleDates': instance.isFlexibleDates,
      'createdAt': instance.createdAt.toIso8601String(),
      'updatedAt': instance.updatedAt.toIso8601String(),
    };
