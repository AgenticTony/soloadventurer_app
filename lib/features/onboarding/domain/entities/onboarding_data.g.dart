// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'onboarding_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$OnboardingDataImpl _$$OnboardingDataImplFromJson(Map<String, dynamic> json) =>
    _$OnboardingDataImpl(
      name: json['name'] as String,
      destination:
          Destination.fromJson(json['destination'] as Map<String, dynamic>),
      dateRange: DateRange.fromJson(json['dateRange'] as Map<String, dynamic>),
      interests: (json['interests'] as List<dynamic>)
          .map((e) => $enumDecode(_$TravelInterestEnumMap, e))
          .toSet(),
      budget: $enumDecodeNullable(_$BudgetRangeEnumMap, json['budget']),
    );

Map<String, dynamic> _$$OnboardingDataImplToJson(
        _$OnboardingDataImpl instance) =>
    <String, dynamic>{
      'name': instance.name,
      'destination': instance.destination,
      'dateRange': instance.dateRange,
      'interests':
          instance.interests.map((e) => _$TravelInterestEnumMap[e]!).toList(),
      'budget': _$BudgetRangeEnumMap[instance.budget],
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

const _$BudgetRangeEnumMap = {
  BudgetRange.budgetFriendly: 'budgetFriendly',
  BudgetRange.moderate: 'moderate',
  BudgetRange.flexible: 'flexible',
};
