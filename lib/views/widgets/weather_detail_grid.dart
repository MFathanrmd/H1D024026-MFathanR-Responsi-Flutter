import 'package:flutter/material.dart';
import '../../data/models/weather_model.dart';

/// Grid widget untuk menampilkan detail indikator cuaca lengkap sesuai spek PDF.
class WeatherDetailGrid extends StatelessWidget {
  final CurrentWeather current;
  final DailyForecastItem? todayDaily;

  const WeatherDetailGrid({
    super.key,
    required this.current,
    this.todayDaily,
  });

  @override
  Widget build(BuildContext context) {
    final rainProb = todayDaily?.precipitationProbability ??
        (current.precipitation > 0 ? 80 : 10);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 4, vertical: 8),
          child: Text(
            'Informasi Cuaca Lengkap',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        GridView.count(
          crossAxisCount: 2,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 12,
          crossAxisSpacing: 12,
          childAspectRatio: 1.5,
          children: [
            // Kelembapan Udara
            _DetailTile(
              icon: Icons.water_drop_outlined,
              iconColor: Colors.blueAccent,
              title: 'Kelembapan',
              value: '${current.relativeHumidity}%',
              subtitle: 'Kadar air di atmosfer',
            ),
            // Kecepatan Angin
            _DetailTile(
              icon: Icons.air_rounded,
              iconColor: Colors.teal,
              title: 'Kecepatan Angin',
              value: '${current.windSpeed.toStringAsFixed(1)} km/h',
              subtitle: 'Angin 10m dari tanah',
            ),
            // Peluang Hujan
            _DetailTile(
              icon: Icons.umbrella_rounded,
              iconColor: Colors.indigoAccent,
              title: 'Peluang Hujan',
              value: '$rainProb%',
              subtitle: 'Probabilitas presipitasi',
            ),
            // Curah Hujan
            _DetailTile(
              icon: Icons.cloudy_snowing,
              iconColor: Colors.cyan,
              title: 'Curah Hujan',
              value: '${current.precipitation.toStringAsFixed(1)} mm',
              subtitle: 'Akumulasi terkini',
            ),
            // Rentang Suhu Hari Ini
            _DetailTile(
              icon: Icons.device_thermostat_rounded,
              iconColor: Colors.deepOrange,
              title: 'Rentang Suhu',
              value: todayDaily != null
                  ? '${todayDaily!.minTemperature.round()}° - ${todayDaily!.maxTemperature.round()}°C'
                  : '${current.temperature.round()}°C',
              subtitle: 'Min / Maks hari ini',
            ),
            // Suhu yang dirasakan & kode WMO
            _DetailTile(
              icon: Icons.wb_twilight_rounded,
              iconColor: Colors.amber.shade800,
              title: 'Suhu Terasa',
              value: '${current.apparentTemperature.toStringAsFixed(1)}°C',
              subtitle: 'Kode WMO: ${current.weatherCode}',
            ),
          ],
        ),
      ],
    );
  }
}

class _DetailTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String value;
  final String subtitle;

  const _DetailTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.value,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: theme.colorScheme.outlineVariant.withValues(alpha: 0.35),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          Text(
            subtitle,
            style: TextStyle(
              fontSize: 10,
              color: theme.colorScheme.onSurfaceVariant.withValues(alpha: 0.8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
