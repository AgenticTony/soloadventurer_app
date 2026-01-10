import 'package:freezed_annotation/freezed_annotation.dart';

part 'weather_forecast.freezed.dart';
part 'weather_forecast.g.dart';

/// Weather forecast data for a specific date and location
///
/// Used during itinerary generation to provide weather-based
/// activity recommendations and packing suggestions.
@freezed
class WeatherForecast with _$WeatherForecast {

  /// Creates a weather forecast with all required fields
  ///
  /// [date] The date for this forecast
  /// [temperatureMin] Minimum temperature in Celsius
  /// [temperatureMax] Maximum temperature in Celsius
  /// [condition] Weather condition description (e.g., "Sunny", "Rainy")
  /// [iconCode] Weather icon code for UI display
  /// [humidity] Humidity percentage (-)
  /// [precipitationProbability] Probability of precipitation (-)
  /// [windSpeed] Wind speed in km/h
  /// [description] Detailed weather description
  const factory WeatherForecast({
    required DateTime date,
    required double temperatureMin,
    required double temperatureMax,
    required String condition,
    String? iconCode,
    int? humidity,
    int? precipitationProbability,
    double? windSpeed,
    String? description,
  }) = _WeatherForecast;

  /// Creates a WeatherForecast from JSON
  factory WeatherForecast.fromJson(Map<String, dynamic> json) =>
      _$WeatherForecastFromJson(json);
}

/// WeatherForecast extensions for computed properties
extension WeatherForecastExtension on WeatherForecast {
  /// Returns true if rain is expected
  ///
  /// Considers precipitation probability and condition text.
  bool get isRainy =>
      (precipitationProbability != null && precipitationProbability! > 50) ||
      condition.toLowerCase().contains('rain') ||
      condition.toLowerCase().contains('drizzle') ||
      condition.toLowerCase().contains('shower');

  /// Returns true if the weather is generally good for outdoor activities
  ///
  /// Considers temperature range and precipitation.
  bool get isGoodForOutdoors =>
      !isRainy &&
      temperatureMax > 10 &&
      temperatureMax < 35 &&
      (precipitationProbability ?? 0) < 50;

  /// Returns a formatted temperature range string
  ///
  /// Example: "°C - °C"
  String get temperatureRange =>
      '${temperatureMin.round()}°C - ${temperatureMax.round()}°C';
}
