import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:info_cuaca/core/theme/app_theme.dart';
import 'package:info_cuaca/data/models/location_model.dart';
import 'package:info_cuaca/data/models/weather_model.dart';
import 'package:info_cuaca/views/about/student_info_dialog.dart';
import 'package:info_cuaca/views/widgets/daily_forecast_list.dart';
import 'package:info_cuaca/views/widgets/weather_detail_grid.dart';
import 'package:info_cuaca/views/widgets/weather_hero_card.dart';

final mockLocation = LocationModel(
  id: 1629001,
  name: 'Purwokerto',
  latitude: -7.4244,
  longitude: 109.2303,
  country: 'Indonesia',
  admin1: 'Jawa Tengah',
  timezone: 'Asia/Jakarta',
  isFavorite: true,
);

final mockCurrent = CurrentWeather(
  temperature: 28.4,
  relativeHumidity: 78,
  apparentTemperature: 31.2,
  precipitation: 1.2,
  weatherCode: 61,
  windSpeed: 12.5,
);

final mockDaily = [
  DailyForecastItem(date: '2026-11-26', weatherCode: 61, maxTemperature: 30.5, minTemperature: 23.2, precipitationProbability: 75),
  DailyForecastItem(date: '2026-11-27', weatherCode: 80, maxTemperature: 31.0, minTemperature: 23.0, precipitationProbability: 80),
  DailyForecastItem(date: '2026-11-28', weatherCode: 2, maxTemperature: 32.1, minTemperature: 22.8, precipitationProbability: 35),
  DailyForecastItem(date: '2026-11-29', weatherCode: 0, maxTemperature: 33.0, minTemperature: 23.5, precipitationProbability: 10),
  DailyForecastItem(date: '2026-11-30', weatherCode: 1, maxTemperature: 32.4, minTemperature: 23.1, precipitationProbability: 20),
  DailyForecastItem(date: '2026-12-01', weatherCode: 63, maxTemperature: 29.8, minTemperature: 22.6, precipitationProbability: 85),
  DailyForecastItem(date: '2026-12-02', weatherCode: 95, maxTemperature: 28.5, minTemperature: 22.0, precipitationProbability: 90),
];

Future<void> saveScreenshot(GlobalKey key, String fileName) async {
  await Future.delayed(const Duration(milliseconds: 200));
  final boundary = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null) return;
  final image = await boundary.toImage(pixelRatio: 2.0);
  final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
  if (byteData == null) return;
  final pngBytes = byteData.buffer.asUint8List();
  final dir = Directory('screenshots');
  if (!dir.existsSync()) dir.createSync(recursive: true);
  await File('screenshots/$fileName').writeAsBytes(pngBytes);
  debugPrint('Saved: screenshots/$fileName (${pngBytes.length} bytes)');
}

void main() {
  testWidgets('01_home_weather_screen', (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: RepaintBoundary(
        key: key,
        child: Scaffold(
          appBar: AppBar(
            title: const Text('Info Cuaca'),
            actions: [
              IconButton(icon: const Icon(Icons.search_rounded), onPressed: () {}),
              IconButton(icon: const Icon(Icons.info_outline_rounded), onPressed: () {}),
            ],
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                WeatherHeroCard(location: mockLocation, current: mockCurrent, onFavoriteTap: () {}),
                const SizedBox(height: 20),
                WeatherDetailGrid(current: mockCurrent, todayDaily: mockDaily.first),
                const SizedBox(height: 20),
                DailyForecastList(forecasts: mockDaily),
                const SizedBox(height: 24),
              ],
            ),
          ),
        ),
      ),
    ));
    await tester.pump();
    await saveScreenshot(key, '01_home_weather_screen.png');
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('02_search_favorites_screen', (tester) async {
    final key = GlobalKey();

    final favList = [
      mockLocation,
      LocationModel(id: 1642911, name: 'Jakarta', latitude: -6.2088, longitude: 106.8456, country: 'Indonesia', admin1: 'DKI Jakarta', isFavorite: true),
      LocationModel(id: 1650357, name: 'Bandung', latitude: -6.9175, longitude: 107.6191, country: 'Indonesia', admin1: 'Jawa Barat', isFavorite: true),
    ];
    final recentList = [
      LocationModel(id: 1625822, name: 'Surabaya', latitude: -7.2575, longitude: 112.7521, country: 'Indonesia', admin1: 'Jawa Timur'),
      LocationModel(id: 1621177, name: 'Yogyakarta', latitude: -7.7956, longitude: 110.3695, country: 'Indonesia', admin1: 'DIY'),
    ];

    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: RepaintBoundary(
        key: key,
        child: Scaffold(
          appBar: AppBar(title: const Text('Cari Lokasi')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: TextField(decoration: InputDecoration(hintText: 'Ketik nama kota...', prefixIcon: const Icon(Icons.search_rounded))),
              ),
              Expanded(
                child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  children: [
                    Row(children: [
                      Icon(Icons.bookmark_rounded, color: Colors.amber.shade700, size: 20),
                      const SizedBox(width: 8),
                      const Text('Lokasi Favorit', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    ]),
                    const SizedBox(height: 8),
                    ...favList.map((loc) => Card(
                      margin: const EdgeInsets.only(bottom: 8),
                      child: ListTile(
                        leading: CircleAvatar(backgroundColor: Colors.blue.shade50, child: Icon(Icons.star_rounded, color: Colors.amber.shade800)),
                        title: Text(loc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                        subtitle: Text(loc.fullDisplayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 12)),
                        trailing: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                      ),
                    )),
                    const SizedBox(height: 20),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Row(children: [
                        const Icon(Icons.history_rounded, color: Color(0xFF1565C0), size: 20),
                        const SizedBox(width: 8),
                        const Text('Riwayat Pencarian', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ]),
                      const Text('Hapus Semua', style: TextStyle(fontSize: 12, color: Color(0xFF1565C0))),
                    ]),
                    const SizedBox(height: 8),
                    ...recentList.map((loc) => ListTile(
                      dense: true,
                      leading: const Icon(Icons.schedule_rounded, size: 20, color: Colors.grey),
                      title: Text(loc.name),
                      subtitle: Text(loc.fullDisplayName, maxLines: 1, overflow: TextOverflow.ellipsis),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    ));
    await tester.pump();
    await saveScreenshot(key, '02_search_favorites_screen.png');
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('03_search_results_screen', (tester) async {
    final key = GlobalKey();
    final results = [
      LocationModel(id: 1650357, name: 'Bandung', latitude: -6.9175, longitude: 107.6191, country: 'Indonesia', admin1: 'Jawa Barat', isFavorite: true),
      LocationModel(id: 1650356, name: 'Bandung', latitude: -7.0267, longitude: 107.5256, country: 'Indonesia', admin1: 'Kabupaten Bandung, Jawa Barat'),
      LocationModel(id: 1650358, name: 'Bandung Barat', latitude: -6.8436, longitude: 107.5028, country: 'Indonesia', admin1: 'Kabupaten Bandung Barat, Jawa Barat'),
      LocationModel(id: 1650359, name: 'Bandungan', latitude: -7.2183, longitude: 110.3703, country: 'Indonesia', admin1: 'Kabupaten Semarang, Jawa Tengah'),
    ];

    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: RepaintBoundary(
        key: key,
        child: Scaffold(
          appBar: AppBar(title: const Text('Cari Lokasi')),
          body: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                child: TextField(
                  controller: TextEditingController(text: 'Bandung'),
                  decoration: const InputDecoration(
                    hintText: 'Ketik nama kota...',
                    prefixIcon: Icon(Icons.search_rounded),
                    suffixIcon: Icon(Icons.clear_rounded),
                  ),
                ),
              ),
              Expanded(
                child: ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: results.length,
                  separatorBuilder: (_, _) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final loc = results[index];
                    return ListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                      leading: CircleAvatar(
                        backgroundColor: Colors.blue.shade50,
                        child: const Icon(Icons.location_city_rounded, color: Color(0xFF1565C0)),
                      ),
                      title: Text(loc.name, style: const TextStyle(fontWeight: FontWeight.w600)),
                      subtitle: Text(loc.fullDisplayName, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(color: Colors.black54, fontSize: 12)),
                      trailing: Icon(loc.isFavorite ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                          color: loc.isFavorite ? Colors.amber.shade700 : null),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    ));
    await tester.pump();
    await saveScreenshot(key, '03_search_results_screen.png');
  }, timeout: const Timeout(Duration(seconds: 30)));

  testWidgets('04_student_info_dialog', (tester) async {
    final key = GlobalKey();
    await tester.pumpWidget(MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      home: RepaintBoundary(
        key: key,
        child: Scaffold(
          appBar: AppBar(title: const Text('Info Cuaca')),
          body: const Center(child: StudentInfoDialog()),
        ),
      ),
    ));
    await tester.pump();
    await saveScreenshot(key, '04_student_info_dialog.png');
  }, timeout: const Timeout(Duration(seconds: 30)));
}
