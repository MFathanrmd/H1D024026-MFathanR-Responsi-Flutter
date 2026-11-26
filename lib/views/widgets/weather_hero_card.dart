import 'package:flutter/material.dart';
import '../../core/utils/weather_helper.dart';
import '../../data/models/location_model.dart';
import '../../data/models/weather_model.dart';

/// Kartu utama cuaca dengan latar gradasi elegan dan informasi primer.
class WeatherHeroCard extends StatelessWidget {
  final LocationModel location;
  final CurrentWeather current;
  final VoidCallback onFavoriteTap;

  const WeatherHeroCard({
    super.key,
    required this.location,
    required this.current,
    required this.onFavoriteTap,
  });

  @override
  Widget build(BuildContext context) {
    final gradientColors = WeatherHelper.getHeroGradient(current.weatherCode);
    final conditionLabel = WeatherHelper.getConditionLabel(current.weatherCode);
    final conditionIcon = WeatherHelper.getConditionIcon(current.weatherCode);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: gradientColors,
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: gradientColors.first.withValues(alpha: 0.35),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header lokasi dan tombol favorit
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.location_on_rounded,
                  color: Colors.white,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      location.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 2),
                    Text(
                      location.admin1 != null && location.admin1!.isNotEmpty
                          ? '${location.admin1}, ${location.country}'
                          : location.country,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.85),
                        fontSize: 13,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: onFavoriteTap,
                tooltip: location.isFavorite
                    ? 'Hapus dari Favorit'
                    : 'Simpan ke Favorit',
                icon: Icon(
                  location.isFavorite
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: location.isFavorite ? Colors.amberAccent : Colors.white,
                  size: 28,
                ),
              ),
            ],
          ),

          const SizedBox(height: 28),

          // Suhu dan Ikon Cuaca
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${current.temperature.round()}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 68,
                          fontWeight: FontWeight.w700,
                          height: 1.0,
                        ),
                      ),
                      const Text(
                        '°C',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 28,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    conditionLabel,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  conditionIcon,
                  size: 64,
                  color: Colors.white,
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
          const Divider(color: Colors.white24, height: 1),
          const SizedBox(height: 14),

          // Ringkasan suhu terasa & koordinat
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(
                    Icons.thermostat_rounded,
                    color: Colors.white70,
                    size: 18,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Terasa seperti ${current.apparentTemperature.toStringAsFixed(1)}°C',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
              Text(
                '${location.latitude.toStringAsFixed(2)}°, ${location.longitude.toStringAsFixed(2)}°',
                style: const TextStyle(
                  color: Colors.white60,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
