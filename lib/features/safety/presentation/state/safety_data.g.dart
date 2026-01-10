// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'safety_data.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_SafetyData _$SafetyDataFromJson(Map<String, dynamic> json) => _SafetyData(
      currentStatus: json['currentStatus'] == null
          ? null
          : SafetyStatus.fromJson(
              json['currentStatus'] as Map<String, dynamic>),
      contacts: (json['contacts'] as List<dynamic>?)
              ?.map((e) => TrustedContact.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      checkIns: (json['checkIns'] as List<dynamic>?)
              ?.map((e) => CheckIn.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      recentAlerts: (json['recentAlerts'] as List<dynamic>?)
              ?.map((e) => SafetyAlert.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      activeAlerts: (json['activeAlerts'] as List<dynamic>?)
              ?.map((e) => SafetyAlert.fromJson(e as Map<String, dynamic>))
              .toList() ??
          const [],
      selectedCheckIn: json['selectedCheckIn'] == null
          ? null
          : CheckIn.fromJson(json['selectedCheckIn'] as Map<String, dynamic>),
      selectedAlert: json['selectedAlert'] == null
          ? null
          : SafetyAlert.fromJson(json['selectedAlert'] as Map<String, dynamic>),
    );

Map<String, dynamic> _$SafetyDataToJson(_SafetyData instance) =>
    <String, dynamic>{
      'currentStatus': instance.currentStatus,
      'contacts': instance.contacts,
      'checkIns': instance.checkIns,
      'recentAlerts': instance.recentAlerts,
      'activeAlerts': instance.activeAlerts,
      'selectedCheckIn': instance.selectedCheckIn,
      'selectedAlert': instance.selectedAlert,
    };
