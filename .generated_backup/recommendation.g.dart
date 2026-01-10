// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$RecommendationMetadataImpl _$$RecommendationMetadataImplFromJson(
        Map<String, dynamic> json) =>
    _$RecommendationMetadataImpl(
      matchedInterests: (json['matchedInterests'] as List<dynamic>)
          .map((e) => $enumDecode(_$TravelInterestEnumMap, e))
          .toSet(),
      suggestedDate: DateTime.parse(json['suggestedDate'] as String),
      suggestedTime:
          TimeOfDay.fromJson(json['suggestedTime'] as Map<String, dynamic>),
      distance: $enumDecode(_$DistanceFromHotelEnumMap, json['distance']),
      weather: $enumDecode(_$WeatherContextEnumMap, json['weather']),
      crowdLevel: $enumDecode(_$CrowdLevelEnumMap, json['crowdLevel']),
      estimatedCost: json['estimatedCost'] == null
          ? null
          : Money.fromJson(json['estimatedCost'] as Map<String, dynamic>),
      estimatedDuration: json['estimatedDuration'] == null
          ? Duration.zero
          : Duration(microseconds: (json['estimatedDuration'] as num).toInt()),
      bookingUrl: json['bookingUrl'] as String?,
      requiresAdvanceBooking: json['requiresAdvanceBooking'] as bool? ?? false,
      isIndoor: json['isIndoor'] as bool? ?? false,
    );

Map<String, dynamic> _$$RecommendationMetadataImplToJson(
        _$RecommendationMetadataImpl instance) =>
    <String, dynamic>{
      'matchedInterests': instance.matchedInterests
          .map((e) => _$TravelInterestEnumMap[e]!)
          .toList(),
      'suggestedDate': instance.suggestedDate.toIso8601String(),
      'suggestedTime': instance.suggestedTime,
      'distance': _$DistanceFromHotelEnumMap[instance.distance]!,
      'weather': _$WeatherContextEnumMap[instance.weather]!,
      'crowdLevel': _$CrowdLevelEnumMap[instance.crowdLevel]!,
      'estimatedCost': instance.estimatedCost,
      'estimatedDuration': instance.estimatedDuration.inMicroseconds,
      'bookingUrl': instance.bookingUrl,
      'requiresAdvanceBooking': instance.requiresAdvanceBooking,
      'isIndoor': instance.isIndoor,
    };

const _$TravelInterestEnumMap = {
  TravelInterest.food: 'food',
  TravelInterest.culture: 'culture',
  TravelInterest.art: 'art',
  TravelInterest.adventure: 'adventure',
  TravelInterest.wellness: 'wellness',
  TravelInterest.nightlife: 'nightlife',
  TravelInterest.nature: 'nature',
  TravelInterest.shopping: 'shopping',
  TravelInterest.photography: 'photography',
  TravelInterest.localExperience: 'localExperience',
};

const _$DistanceFromHotelEnumMap = {
  DistanceFromHotel.walking: 'walking',
  DistanceFromHotel.shortTrip: 'shortTrip',
  DistanceFromHotel.mediumTrip: 'mediumTrip',
  DistanceFromHotel.far: 'far',
};

const _$WeatherContextEnumMap = {
  WeatherContext.anyWeather: 'anyWeather',
  WeatherContext.indoor: 'indoor',
  WeatherContext.outdoor: 'outdoor',
  WeatherContext.weatherDependent: 'weatherDependent',
};

const _$CrowdLevelEnumMap = {
  CrowdLevel.low: 'low',
  CrowdLevel.medium: 'medium',
  CrowdLevel.high: 'high',
  CrowdLevel.peak: 'peak',
};

_$TimeOfDayImpl _$$TimeOfDayImplFromJson(Map<String, dynamic> json) =>
    _$TimeOfDayImpl(
      hour: (json['hour'] as num).toInt(),
      minute: (json['minute'] as num?)?.toInt() ?? 0,
    );

Map<String, dynamic> _$$TimeOfDayImplToJson(_$TimeOfDayImpl instance) =>
    <String, dynamic>{
      'hour': instance.hour,
      'minute': instance.minute,
    };

_$MoneyImpl _$$MoneyImplFromJson(Map<String, dynamic> json) => _$MoneyImpl(
      amount: (json['amount'] as num).toDouble(),
      currency: json['currency'] as String? ?? 'USD',
    );

Map<String, dynamic> _$$MoneyImplToJson(_$MoneyImpl instance) =>
    <String, dynamic>{
      'amount': instance.amount,
      'currency': instance.currency,
    };
