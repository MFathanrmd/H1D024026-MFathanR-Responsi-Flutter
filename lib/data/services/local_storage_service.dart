import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/location_model.dart';

/// Service untuk menangani penyimpanan lokal (Local Storage) menggunakan SharedPreferences.
class LocalStorageService {
  static const String _keyFavorites = 'favorite_locations';
  static const String _keyRecentSearches = 'recent_searches';
  static const String _keyLastSelected = 'last_selected_location';

  /// Default lokasi awal jika belum ada data tersimpan: Purwokerto.
  static final LocationModel defaultLocation = LocationModel(
    id: 1629001,
    name: 'Purwokerto',
    latitude: -7.4244,
    longitude: 109.2303,
    country: 'Indonesia',
    admin1: 'Jawa Tengah',
    timezone: 'Asia/Jakarta',
  );

  /// Mengambil daftar lokasi favorit yang tersimpan.
  Future<List<LocationModel>> getFavoriteLocations() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_keyFavorites);
    if (jsonList == null || jsonList.isEmpty) return [];

    try {
      return jsonList.map((item) {
        final map = jsonDecode(item) as Map<String, dynamic>;
        return LocationModel.fromJson(map).copyWith(isFavorite: true);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Menambah atau menghapus lokasi favorit.
  Future<bool> toggleFavoriteLocation(LocationModel location) async {
    final prefs = await SharedPreferences.getInstance();
    final currentFavorites = await getFavoriteLocations();

    final index = currentFavorites.indexWhere((loc) => loc.id == location.id);
    bool willBeFavorite;

    if (index >= 0) {
      currentFavorites.removeAt(index);
      willBeFavorite = false;
    } else {
      currentFavorites.insert(0, location.copyWith(isFavorite: true));
      willBeFavorite = true;
    }

    final rawList =
        currentFavorites.map((loc) => jsonEncode(loc.toJson())).toList();
    await prefs.setStringList(_keyFavorites, rawList);
    return willBeFavorite;
  }

  /// Mengecek apakah suatu lokasi sudah masuk daftar favorit.
  Future<bool> isLocationFavorite(int locationId) async {
    final favorites = await getFavoriteLocations();
    return favorites.any((loc) => loc.id == locationId);
  }

  /// Mengambil daftar riwayat pencarian terakhir (maks 10).
  Future<List<LocationModel>> getRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    final jsonList = prefs.getStringList(_keyRecentSearches);
    if (jsonList == null || jsonList.isEmpty) return [];

    try {
      return jsonList.map((item) {
        final map = jsonDecode(item) as Map<String, dynamic>;
        return LocationModel.fromJson(map);
      }).toList();
    } catch (_) {
      return [];
    }
  }

  /// Menyimpan lokasi ke riwayat pencarian.
  Future<void> addRecentSearch(LocationModel location) async {
    final prefs = await SharedPreferences.getInstance();
    final list = await getRecentSearches();

    list.removeWhere((item) => item.id == location.id);
    list.insert(0, location);

    if (list.length > 10) {
      list.removeRange(10, list.length);
    }

    final rawList = list.map((item) => jsonEncode(item.toJson())).toList();
    await prefs.setStringList(_keyRecentSearches, rawList);
  }

  /// Menghapus seluruh riwayat pencarian.
  Future<void> clearRecentSearches() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyRecentSearches);
  }

  /// Mengambil lokasi terakhir yang dipilih pengguna saat aplikasi dibuka.
  Future<LocationModel> getLastSelectedLocation() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_keyLastSelected);
    if (raw == null) return defaultLocation;

    try {
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final loc = LocationModel.fromJson(map);
      final isFav = await isLocationFavorite(loc.id);
      return loc.copyWith(isFavorite: isFav);
    } catch (_) {
      return defaultLocation;
    }
  }

  /// Menyimpan lokasi yang sedang dipilih.
  Future<void> saveLastSelectedLocation(LocationModel location) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyLastSelected, jsonEncode(location.toJson()));
  }
}
