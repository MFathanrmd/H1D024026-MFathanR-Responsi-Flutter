import 'package:flutter/material.dart';
import '../../core/utils/weather_helper.dart';
import '../../data/models/weather_model.dart';

/// Daftar perkiraan cuaca 7 hari ke depan.
class DailyForecastList extends StatelessWidget {
  final List<DailyForecastItem> forecasts;

  const DailyForecastList({
    super.key,
    required this.forecasts,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            'Perkiraan Cuaca 7 Hari',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF1E293B) : Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
            ),
          ),
          child: ListView.separated(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: forecasts.length,
            separatorBuilder: (context, index) => Divider(
              height: 1,
              indent: 16,
              endIndent: 16,
              color: theme.colorScheme.outlineVariant.withValues(alpha: 0.25),
            ),
            itemBuilder: (context, index) {
              final item = forecasts[index];
              final label = WeatherHelper.formatForecastDate(item.date, index: index);
              final condition = WeatherHelper.getConditionLabel(item.weatherCode);
              final icon = WeatherHelper.getConditionIcon(item.weatherCode);

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    // Tanggal / Hari & Kondisi
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            label,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            condition,
                            style: TextStyle(
                              fontSize: 12,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Probabilitas Hujan
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.water_drop_rounded,
                          size: 14,
                          color: item.precipitationProbability > 40
                              ? Colors.blueAccent
                              : Colors.grey,
                        ),
                        const SizedBox(width: 3),
                        Text(
                          '${item.precipitationProbability}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: item.precipitationProbability > 40
                                ? Colors.blueAccent
                                : theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(width: 14),

                    // Ikon cuaca
                    Icon(
                      icon,
                      color: theme.colorScheme.primary,
                      size: 22,
                    ),
                    const SizedBox(width: 12),

                    // Suhu Min - Max
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '${item.minTemperature.round()}°',
                          style: TextStyle(
                            fontSize: 13,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const Text(' / ', style: TextStyle(color: Colors.grey, fontSize: 12)),
                        Text(
                          '${item.maxTemperature.round()}°C',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
