// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'check_in_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$CheckInDataImpl _$$CheckInDataImplFromJson(Map<String, dynamic> json) =>
    _$CheckInDataImpl(
      checkIns: (json['checkIns'] as List<dynamic>?)
              ?.map((e) => CheckIn.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      upcomingCheckIns: (json['upcomingCheckIns'] as List<dynamic>?)
              ?.map((e) => CheckIn.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      selectedCheckIn: json['selectedCheckIn'] == null
          ? null
          : CheckIn.fromJson(json['selectedCheckIn'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$$CheckInDataImplToJson(_$CheckInDataImpl instance) =>
    <String, dynamic>{
      'checkIns': instance.checkIns,
      'upcomingCheckIns': instance.upcomingCheckIns,
      'selectedCheckIn': instance.selectedCheckIn,
    };
