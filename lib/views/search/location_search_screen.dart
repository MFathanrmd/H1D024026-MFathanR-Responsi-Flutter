import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/location_model.dart';
import '../../viewmodels/location_search_viewmodel.dart';
import '../../viewmodels/weather_viewmodel.dart';

/// Screen 2: Search / Location Screen
/// Menyediakan input untuk mencari kota menggunakan Geocoding API Open-Meteo,
/// menampilkan daftar hasil pencarian, memungkinkan memilih kota,
/// serta menampilkan lokasi favorit dan riwayat pencarian dari penyimpanan lokal.
class LocationSearchScreen extends StatefulWidget {
  const LocationSearchScreen({super.key});

  @override
  State<LocationSearchScreen> createState() => _LocationSearchScreenState();
}

class _LocationSearchScreenState extends State<LocationSearchScreen> {
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    final q = Uri.base.queryParameters['q'];
    if (q != null && q.isNotEmpty) {
      _searchController.text = q;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSelectLocation(LocationModel location) {
    final weatherVm = context.read<WeatherViewModel>();
    weatherVm.fetchWeatherForLocation(location);
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final initialQuery = Uri.base.queryParameters['q'];

    return ChangeNotifierProvider(
      create: (_) {
        final vm = LocationSearchViewModel();
        if (initialQuery != null && initialQuery.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            vm.searchCity(initialQuery);
          });
        }
        return vm;
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Cari Lokasi'),
        ),
        body: Consumer2<LocationSearchViewModel, WeatherViewModel>(
          builder: (context, searchVm, weatherVm, child) {
            return Column(
              children: [
                // Input Pencarian
                Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
                  child: TextField(
                    controller: _searchController,
                    autofocus: false,
                    textInputAction: TextInputAction.search,
                    onChanged: (val) => searchVm.onQueryChanged(val),
                    onSubmitted: (val) => searchVm.searchCity(val),
                    decoration: InputDecoration(
                      hintText: 'Ketik nama kota (misal: Bandung, Tokyo)...',
                      prefixIcon: const Icon(Icons.search_rounded),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear_rounded),
                              onPressed: () {
                                _searchController.clear();
                                searchVm.clearResults();
                              },
                            )
                          : null,
                    ),
                  ),
                ),

                // Konten Body: Hasil Pencarian atau Favorit/Riwayat
                Expanded(
                  child: _buildSearchBody(
                    context,
                    searchVm,
                    weatherVm,
                    theme,
                    isDark,
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchBody(
    BuildContext context,
    LocationSearchViewModel searchVm,
    WeatherViewModel weatherVm,
    ThemeData theme,
    bool isDark,
  ) {
    // 1. Kondisi Loading
    if (searchVm.isLoading) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 14),
            Text('Mencari kota di Open-Meteo...'),
          ],
        ),
      );
    }

    // 2. Kondisi Error
    if (searchVm.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.wifi_off_rounded, size: 48, color: theme.colorScheme.error),
              const SizedBox(height: 12),
              Text(
                'Gagal Menghubungi Layanan Pencarian',
                style: theme.textTheme.titleMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 6),
              Text(
                searchVm.errorMessage,
                style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 13),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              FilledButton.tonal(
                onPressed: () => searchVm.searchCity(_searchController.text),
                child: const Text('Coba Lagi'),
              ),
            ],
          ),
        ),
      );
    }

    // 3. Kondisi Tidak Ada Hasil
    if (searchVm.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.location_off_rounded,
                size: 48, color: theme.colorScheme.outline),
            const SizedBox(height: 12),
            Text(
              'Kota "${_searchController.text}" tidak ditemukan',
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 4),
            const Text(
              'Pastikan ejaan nama kota sudah benar.',
              style: TextStyle(color: Colors.grey, fontSize: 13),
            ),
          ],
        ),
      );
    }

    // 4. Kondisi Ada Hasil Pencarian dari API
    if (searchVm.isSuccess && searchVm.searchResults.isNotEmpty) {
      return ListView.separated(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        itemCount: searchVm.searchResults.length,
        separatorBuilder: (_, _) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final loc = searchVm.searchResults[index];
          final isFav = weatherVm.favoriteLocations.any((item) => item.id == loc.id);

          return ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: CircleAvatar(
              backgroundColor: theme.colorScheme.primaryContainer,
              child: Icon(Icons.location_city_rounded,
                  color: theme.colorScheme.primary),
            ),
            title: Text(
              loc.name,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            subtitle: Text(
              loc.fullDisplayName,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(color: theme.colorScheme.onSurfaceVariant, fontSize: 12),
            ),
            trailing: IconButton(
              icon: Icon(
                isFav ? Icons.bookmark_rounded : Icons.bookmark_border_rounded,
                color: isFav ? Colors.amber.shade700 : null,
              ),
              onPressed: () => weatherVm.toggleLocationFavorite(loc),
            ),
            onTap: () => _onSelectLocation(loc),
          );
        },
      );
    }

    // 5. Kondisi Idle: Menampilkan Daftar Favorit dan Riwayat Pencarian
    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      children: [
        // Bagian Lokasi Favorit
        _buildSectionHeader(
          title: 'Lokasi Favorit',
          icon: Icons.bookmark_rounded,
          iconColor: Colors.amber.shade700,
        ),
        if (weatherVm.favoriteLocations.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Text(
              'Belum ada lokasi favorit. Tandai kota dengan ikon bookmark untuk menyimpannya.',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          ...weatherVm.favoriteLocations.map(
            (loc) => Card(
              margin: const EdgeInsets.only(bottom: 8),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: theme.colorScheme.primaryContainer,
                  child: Icon(Icons.star_rounded, color: Colors.amber.shade800),
                ),
                title: Text(loc.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                subtitle: Text(
                  loc.fullDisplayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontSize: 12),
                ),
                trailing: IconButton(
                  tooltip: 'Hapus Favorit',
                  icon: const Icon(Icons.delete_outline_rounded, color: Colors.redAccent),
                  onPressed: () => weatherVm.toggleLocationFavorite(loc),
                ),
                onTap: () => _onSelectLocation(loc),
              ),
            ),
          ),

        const SizedBox(height: 20),

        // Bagian Riwayat Pencarian
        _buildSectionHeader(
          title: 'Riwayat Pencarian',
          icon: Icons.history_rounded,
          iconColor: theme.colorScheme.primary,
          trailing: weatherVm.recentSearches.isNotEmpty
              ? TextButton(
                  onPressed: () => weatherVm.clearRecentSearches(),
                  child: const Text('Hapus Semua', style: TextStyle(fontSize: 12)),
                )
              : null,
        ),
        if (weatherVm.recentSearches.isEmpty)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
            child: Text(
              'Riwayat pencarian masih kosong.',
              style: TextStyle(
                fontSize: 13,
                color: theme.colorScheme.onSurfaceVariant,
                fontStyle: FontStyle.italic,
              ),
            ),
          )
        else
          ...weatherVm.recentSearches.map(
            (loc) => ListTile(
              dense: true,
              leading: const Icon(Icons.schedule_rounded, size: 20, color: Colors.grey),
              title: Text(loc.name),
              subtitle: Text(
                loc.fullDisplayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              onTap: () => _onSelectLocation(loc),
            ),
          ),
      ],
    );
  }

  Widget _buildSectionHeader({
    required String title,
    required IconData icon,
    required Color iconColor,
    Widget? trailing,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          ?trailing,
        ],
      ),
    );
  }
}
