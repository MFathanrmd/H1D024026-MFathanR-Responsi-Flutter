import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../data/models/location_model.dart';
import '../data/models/weather_model.dart';
import '../data/services/api_service.dart';
import '../data/services/local_storage_service.dart';

enum WeatherUiState { initial, loading, success, error }

/// ViewModel untuk mengelola state cuaca terkini, forecast, dan status lokasi favorit.
class WeatherViewModel extends ChangeNotifier {
  final ApiService _apiService;
  final LocalStorageService _storageService;

  WeatherViewModel({
    ApiService? apiService,
    LocalStorageService? storageService,
  })  : _apiService = apiService ?? ApiService(),
        _storageService = storageService ?? LocalStorageService();

  WeatherUiState _state = WeatherUiState.initial;
  WeatherUiState get state => _state;

  LocationModel? _currentLocation;
  LocationModel? get currentLocation => _currentLocation;

  WeatherData? _weatherData;
  WeatherData? get weatherData => _weatherData;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  List<LocationModel> _favoriteLocations = [];
  List<LocationModel> get favoriteLocations => _favoriteLocations;

  List<LocationModel> _recentSearches = [];
  List<LocationModel> get recentSearches => _recentSearches;

  bool get isLoading => _state == WeatherUiState.loading;
  bool get hasData => _state == WeatherUiState.success && _weatherData != null;
  bool get hasError => _state == WeatherUiState.error;

  /// Inisialisasi awal saat aplikasi pertama kali terbuka.
  Future<void> initialize() async {
    await loadFavoritesAndHistory();
    final lastLocation = await _storageService.getLastSelectedLocation();
    await fetchWeatherForLocation(lastLocation);
  }

  /// Memuat daftar favorit dan riwayat pencarian dari penyimpanan lokal.
  Future<void> loadFavoritesAndHistory() async {
    _favoriteLocations = await _storageService.getFavoriteLocations();
    _recentSearches = await _storageService.getRecentSearches();
    notifyListeners();
  }

  /// Mengambil data cuaca berdasarkan lokasi yang dipilih.
  Future<void> fetchWeatherForLocation(LocationModel location) async {
    _currentLocation = location;
    _state = WeatherUiState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final isFav = await _storageService.isLocationFavorite(location.id);
      _currentLocation = location.copyWith(isFavorite: isFav);

      final data = await _apiService.getForecast(
        latitude: location.latitude,
        longitude: location.longitude,
      );

      _weatherData = data;
      _state = WeatherUiState.success;

      // Simpan lokasi terpilih dan catat ke riwayat
      await _storageService.saveLastSelectedLocation(_currentLocation!);
      await _storageService.addRecentSearch(_currentLocation!);
      await loadFavoritesAndHistory();
    } on SocketException catch (e) {
      _state = WeatherUiState.error;
      _errorMessage = e.message;
    } on TimeoutException catch (e) {
      _state = WeatherUiState.error;
      _errorMessage = e.message ?? 'Waktu tunggu koneksi habis.';
    } catch (e) {
      _state = WeatherUiState.error;
      _errorMessage = 'Terjadi kesalahan: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  /// Refresh data cuaca untuk lokasi yang saat ini sedang aktif.
  Future<void> refreshCurrentWeather() async {
    if (_currentLocation != null) {
      await fetchWeatherForLocation(_currentLocation!);
    }
  }

  /// Menambah atau menghapus lokasi saat ini dari daftar favorit.
  Future<void> toggleCurrentLocationFavorite() async {
    if (_currentLocation == null) return;

    final newStatus =
        await _storageService.toggleFavoriteLocation(_currentLocation!);
    _currentLocation = _currentLocation!.copyWith(isFavorite: newStatus);

    await loadFavoritesAndHistory();
    notifyListeners();
  }

  /// Toggle status favorit untuk lokasi tertentu (misal dari daftar favorit/pencarian).
  Future<void> toggleLocationFavorite(LocationModel location) async {
    await _storageService.toggleFavoriteLocation(location);
    if (_currentLocation != null && _currentLocation!.id == location.id) {
      final isFav = await _storageService.isLocationFavorite(location.id);
      _currentLocation = _currentLocation!.copyWith(isFavorite: isFav);
    }
    await loadFavoritesAndHistory();
    notifyListeners();
  }

  /// Menghapus seluruh riwayat pencarian.
  Future<void> clearRecentSearches() async {
    await _storageService.clearRecentSearches();
    _recentSearches = [];
    notifyListeners();
  }
}
