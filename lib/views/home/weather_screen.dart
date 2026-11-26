import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../viewmodels/weather_viewmodel.dart';
import '../about/student_info_dialog.dart';
import '../search/location_search_screen.dart';
import '../widgets/daily_forecast_list.dart';
import '../widgets/weather_detail_grid.dart';
import '../widgets/weather_hero_card.dart';

/// Screen 1: Home / Weather Screen
/// Menampilkan nama kota yang sedang dipilih, kondisi cuaca terkini,
/// suhu saat ini, informasi tambahan lengkap, dan forecast beberapa hari ke depan.
class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WeatherViewModel>().initialize();
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Info Cuaca'),
        actions: [
          IconButton(
            tooltip: 'Cari Kota / Lokasi',
            icon: const Icon(Icons.search_rounded),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const LocationSearchScreen(),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Profil Mahasiswa',
            icon: const Icon(Icons.info_outline_rounded),
            onPressed: () => StudentInfoDialog.show(context),
          ),
        ],
      ),
      body: Consumer<WeatherViewModel>(
        builder: (context, vm, child) {
          if (vm.isLoading && vm.weatherData == null) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircularProgressIndicator(),
                  SizedBox(height: 16),
                  Text(
                    'Memuat informasi cuaca...',
                    style: TextStyle(fontSize: 15),
                  ),
                ],
              ),
            );
          }

          if (vm.hasError && vm.weatherData == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(28.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Container(
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.errorContainer.withValues(alpha: 0.4),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.cloud_off_rounded,
                        size: 56,
                        color: theme.colorScheme.error,
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text(
                      'Gagal Memuat Cuaca',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      vm.errorMessage,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 13,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 24),
                    FilledButton.icon(
                      onPressed: () => vm.refreshCurrentWeather(),
                      icon: const Icon(Icons.refresh_rounded),
                      label: const Text('Coba Lagi'),
                    ),
                    const SizedBox(height: 12),
                    TextButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const LocationSearchScreen(),
                          ),
                        );
                      },
                      icon: const Icon(Icons.search_rounded),
                      label: const Text('Pilih Kota Lain'),
                    ),
                  ],
                ),
              ),
            );
          }

          final location = vm.currentLocation;
          final weatherData = vm.weatherData;

          if (location == null || weatherData == null) {
            return const Center(
              child: Text('Silakan pilih lokasi untuk melihat cuaca.'),
            );
          }

          final todayDaily = weatherData.dailyForecasts.isNotEmpty
              ? weatherData.dailyForecasts.first
              : null;

          return RefreshIndicator(
            onRefresh: () => vm.refreshCurrentWeather(),
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Hero Card Cuaca
                  WeatherHeroCard(
                    location: location,
                    current: weatherData.current,
                    onFavoriteTap: () async {
                      await vm.toggleCurrentLocationFavorite();
                      if (!context.mounted) return;
                      final isFav = vm.currentLocation?.isFavorite ?? false;
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          duration: const Duration(seconds: 2),
                          content: Text(
                            isFav
                                ? '${location.name} ditambahkan ke favorit'
                                : '${location.name} dihapus dari favorit',
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 20),

                  // Detail Grid Cuaca
                  WeatherDetailGrid(
                    current: weatherData.current,
                    todayDaily: todayDaily,
                  ),

                  const SizedBox(height: 20),

                  // Prakiraan Cuaca 7 Hari
                  DailyForecastList(
                    forecasts: weatherData.dailyForecasts,
                  ),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
