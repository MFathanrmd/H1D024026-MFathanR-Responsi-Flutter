/// Konstanta endpoint dan parameter untuk API Open-Meteo.
class ApiConstants {
  ApiConstants._();

  static const String forecastBaseUrl =
      'https://api.open-meteo.com/v1/forecast';
  static const String geocodingBaseUrl =
      'https://geocoding-api.open-meteo.com/v1/search';

  static const String currentParameters =
      'temperature_2m,relative_humidity_2m,apparent_temperature,precipitation,weather_code,wind_speed_10m';

  static const String dailyParameters =
      'weather_code,temperature_2m_max,temperature_2m_min,precipitation_probability_max';

  static const String defaultTimezone = 'auto';
  static const int geocodingResultCount = 10;
  static const int forecastDays = 7;

  static const Duration requestTimeout = Duration(seconds: 15);
}
