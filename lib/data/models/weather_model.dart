/// Model untuk data cuaca saat ini dari response Open-Meteo.
class CurrentWeather {
  final double temperature;
  final int relativeHumidity;
  final double apparentTemperature;
  final double precipitation;
  final int weatherCode;
  final double windSpeed;

  CurrentWeather({
    required this.temperature,
    required this.relativeHumidity,
    required this.apparentTemperature,
    required this.precipitation,
    required this.weatherCode,
    required this.windSpeed,
  });

  factory CurrentWeather.fromJson(Map<String, dynamic> json) {
    return CurrentWeather(
      temperature: (json['temperature_2m'] as num?)?.toDouble() ?? 0.0,
      relativeHumidity: (json['relative_humidity_2m'] as num?)?.toInt() ?? 0,
      apparentTemperature:
          (json['apparent_temperature'] as num?)?.toDouble() ?? 0.0,
      precipitation: (json['precipitation'] as num?)?.toDouble() ?? 0.0,
      weatherCode: (json['weather_code'] as num?)?.toInt() ?? 0,
      windSpeed: (json['wind_speed_10m'] as num?)?.toDouble() ?? 0.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'temperature_2m': temperature,
      'relative_humidity_2m': relativeHumidity,
      'apparent_temperature': apparentTemperature,
      'precipitation': precipitation,
      'weather_code': weatherCode,
      'wind_speed_10m': windSpeed,
    };
  }
}

/// Model untuk data perkiraan cuaca per hari.
class DailyForecastItem {
  final String date;
  final int weatherCode;
  final double maxTemperature;
  final double minTemperature;
  final int precipitationProbability;

  DailyForecastItem({
    required this.date,
    required this.weatherCode,
    required this.maxTemperature,
    required this.minTemperature,
    required this.precipitationProbability,
  });
}

/// Model utama pembungkus data cuaca terkini dan forecast harian.
class WeatherData {
  final double latitude;
  final double longitude;
  final String timezone;
  final CurrentWeather current;
  final List<DailyForecastItem> dailyForecasts;

  WeatherData({
    required this.latitude,
    required this.longitude,
    required this.timezone,
    required this.current,
    required this.dailyForecasts,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final currentJson = json['current'] as Map<String, dynamic>? ?? {};
    final dailyJson = json['daily'] as Map<String, dynamic>? ?? {};

    final dates = List<String>.from(dailyJson['time'] as List? ?? []);
    final weatherCodes =
        List<num>.from(dailyJson['weather_code'] as List? ?? []);
    final maxTemps =
        List<num>.from(dailyJson['temperature_2m_max'] as List? ?? []);
    final minTemps =
        List<num>.from(dailyJson['temperature_2m_min'] as List? ?? []);
    final precipProbs =
        List<num>.from(dailyJson['precipitation_probability_max'] as List? ?? []);

    final items = <DailyForecastItem>[];
    for (int i = 0; i < dates.length; i++) {
      items.add(
        DailyForecastItem(
          date: dates[i],
          weatherCode: i < weatherCodes.length ? weatherCodes[i].toInt() : 0,
          maxTemperature:
              i < maxTemps.length ? maxTemps[i].toDouble() : 0.0,
          minTemperature:
              i < minTemps.length ? minTemps[i].toDouble() : 0.0,
          precipitationProbability:
              i < precipProbs.length ? precipProbs[i].toInt() : 0,
        ),
      );
    }

    return WeatherData(
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      timezone: json['timezone'] as String? ?? 'UTC',
      current: CurrentWeather.fromJson(currentJson),
      dailyForecasts: items,
    );
  }
}
