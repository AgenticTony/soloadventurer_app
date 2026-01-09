// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'weather_forecast.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_$WeatherForecastImpl _$$WeatherForecastImplFromJson(
        Map<String, dynamic> json) =>
    _$WeatherForecastImpl(
      date: DateTime.parse(json['date'] as String),
      temperatureMin: (json['temperatureMin'] as num).toDouble(),
      temperatureMax: (json['temperatureMax'] as num).toDouble(),
      condition: json['condition'] as String,
      iconCode: json['iconCode'] as String?,
      humidity: (json['humidity'] as num?)?.toInt(),
      precipitationProbability:
          (json['precipitationProbability'] as num?)?.toInt(),
      windSpeed: (json['windSpeed'] as num?)?.toDouble(),
      description: json['description'] as String?,
    );

Map<String, dynamic> _$$WeatherForecastImplToJson(
        _$WeatherForecastImpl instance) =>
    <String, dynamic>{
      'date': instance.date.toIso8601String(),
      'temperatureMin': instance.temperatureMin,
      'temperatureMax': instance.temperatureMax,
      'condition': instance.condition,
      'iconCode': instance.iconCode,
      'humidity': instance.humidity,
      'precipitationProbability': instance.precipitationProbability,
      'windSpeed': instance.windSpeed,
      'description': instance.description,
    };
