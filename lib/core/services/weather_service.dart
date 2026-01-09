import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/destination.dart';
import 'package:soloadventurer/features/onboarding/domain/entities/date_range.dart';
import 'package:soloadventurer/features/travel/domain/models/weather_forecast.dart';

part 'weather_service.g.dart';

/// Service for fetching weather forecasts
///
/// Provides weather data for travel planning, including daily forecasts
/// for specific destinations and date ranges. Used during itinerary
/// generation to make weather-based activity recommendations.
abstract class WeatherService {
  /// Gets weather forecast for a destination over a date range
  ///
  /// [destination] The destination to get weather for
  /// [dateRange] The date range to get forecasts for
  ///
  /// Returns a list of daily weather forecasts, one for each day in the range
  ///
  /// Throws [ServerException] if the weather API is unavailable
  /// Throws [NetworkConnectivityException] if there's a connectivity issue
  /// Throws [CacheException] if unable to cache the results
  Future<List<WeatherForecast>> getForecast(
    Destination destination,
    DateRange dateRange,
  );

  /// Gets current weather conditions for a destination
  ///
  /// [destination] The destination to get current weather for
  ///
  /// Returns the current weather conditions
  ///
  /// Throws [ServerException] if the weather API is unavailable
  /// Throws [NetworkConnectivityException] if there's a connectivity issue
  Future<WeatherForecast> getCurrentWeather(Destination destination);

  /// Checks if weather data is available for a destination
  ///
  /// [destination] The destination to check
  ///
  /// Returns true if weather data can be fetched for this destination
  Future<bool> isWeatherAvailable(Destination destination);
}

/// Provider for the weather service implementation
@Riverpod(keepAlive: true)
WeatherService weatherService(Ref ref) {
  throw UnimplementedError(
    'WeatherService implementation not provided. '
    'Use weatherServiceProvider from weather_service_impl.dart',
  );
}
