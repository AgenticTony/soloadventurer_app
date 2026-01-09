// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'recommendation_request.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_RecommendationRequest _$RecommendationRequestFromJson(
        Map<String, dynamic> json) =>
    _RecommendationRequest(
      itineraryId: json['itineraryId'] as String,
      destination:
          Destination.fromJson(json['destination'] as Map<String, dynamic>),
      tripDates: DateRange.fromJson(json['tripDates'] as Map<String, dynamic>),
      interests: (json['interests'] as List<dynamic>)
          .map((e) => $enumDecode(_$TravelInterestEnumMap, e))
          .toSet(),
      hotelLocation: json['hotelLocation'] == null
          ? null
          : HotelLocation.fromJson(
              json['hotelLocation'] as Map<String, dynamic>),
      budget: json['budget'] == null
          ? null
          : BudgetRange.fromJson(json['budget'] as Map<String, dynamic>),
      categories: (json['categories'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$RecommendationCategoryEnumMap, e))
          .toSet(),
      weatherPreference: (json['weatherPreference'] as List<dynamic>?)
          ?.map((e) => $enumDecode(_$WeatherContextEnumMap, e))
          .toSet(),
      maxDistance:
          $enumDecodeNullable(_$DistanceFromHotelEnumMap, json['maxDistance']),
      limit: (json['limit'] as num?)?.toInt() ?? 20,
      excludeItineraryItems: json['excludeItineraryItems'] as bool? ?? true,
    );

Map<String, dynamic> _$RecommendationRequestToJson(
        _RecommendationRequest instance) =>
    <String, dynamic>{
      'itineraryId': instance.itineraryId,
      'destination': instance.destination,
      'tripDates': instance.tripDates,
      'interests':
          instance.interests.map((e) => _$TravelInterestEnumMap[e]!).toList(),
      'hotelLocation': instance.hotelLocation,
      'budget': instance.budget,
      'categories': instance.categories
          ?.map((e) => _$RecommendationCategoryEnumMap[e]!)
          .toList(),
      'weatherPreference': instance.weatherPreference
          ?.map((e) => _$WeatherContextEnumMap[e]!)
          .toList(),
      'maxDistance': _$DistanceFromHotelEnumMap[instance.maxDistance],
      'limit': instance.limit,
      'excludeItineraryItems': instance.excludeItineraryItems,
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

const _$RecommendationCategoryEnumMap = {
  RecommendationCategory.food: 'food',
  RecommendationCategory.attraction: 'attraction',
  RecommendationCategory.activity: 'activity',
  RecommendationCategory.entertainment: 'entertainment',
  RecommendationCategory.shopping: 'shopping',
  RecommendationCategory.wellness: 'wellness',
  RecommendationCategory.culture: 'culture',
  RecommendationCategory.adventure: 'adventure',
};

const _$WeatherContextEnumMap = {
  WeatherContext.anyWeather: 'anyWeather',
  WeatherContext.indoor: 'indoor',
  WeatherContext.outdoor: 'outdoor',
  WeatherContext.weatherDependent: 'weatherDependent',
};

const _$DistanceFromHotelEnumMap = {
  DistanceFromHotel.walking: 'walking',
  DistanceFromHotel.shortTrip: 'shortTrip',
  DistanceFromHotel.mediumTrip: 'mediumTrip',
  DistanceFromHotel.far: 'far',
};

_HotelLocation _$HotelLocationFromJson(Map<String, dynamic> json) =>
    _HotelLocation(
      name: json['name'] as String,
      address: json['address'] as String?,
      latitude: (json['latitude'] as num).toDouble(),
      longitude: (json['longitude'] as num).toDouble(),
    );

Map<String, dynamic> _$HotelLocationToJson(_HotelLocation instance) =>
    <String, dynamic>{
      'name': instance.name,
      'address': instance.address,
      'latitude': instance.latitude,
      'longitude': instance.longitude,
    };

_BudgetRange _$BudgetRangeFromJson(Map<String, dynamic> json) => _BudgetRange(
      min: (json['min'] as num?)?.toDouble(),
      max: (json['max'] as num?)?.toDouble(),
      currency: json['currency'] as String? ?? 'USD',
    );

Map<String, dynamic> _$BudgetRangeToJson(_BudgetRange instance) =>
    <String, dynamic>{
      'min': instance.min,
      'max': instance.max,
      'currency': instance.currency,
    };
