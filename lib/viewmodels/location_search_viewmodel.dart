import 'dart:async';
import 'dart:io';
import 'package:flutter/foundation.dart';
import '../data/models/location_model.dart';
import '../data/services/api_service.dart';

enum SearchUiState { idle, loading, success, empty, error }

/// ViewModel untuk mengelola pencarian kota dan hasil geocoding API.
class LocationSearchViewModel extends ChangeNotifier {
  final ApiService _apiService;

  LocationSearchViewModel({ApiService? apiService})
      : _apiService = apiService ?? ApiService();

  SearchUiState _state = SearchUiState.idle;
  SearchUiState get state => _state;

  List<LocationModel> _searchResults = [];
  List<LocationModel> get searchResults => _searchResults;

  String _errorMessage = '';
  String get errorMessage => _errorMessage;

  String _currentQuery = '';
  String get currentQuery => _currentQuery;

  Timer? _debounceTimer;

  bool get isLoading => _state == SearchUiState.loading;
  bool get isEmpty => _state == SearchUiState.empty;
  bool get isSuccess => _state == SearchUiState.success;
  bool get hasError => _state == SearchUiState.error;

  /// Pencarian dengan debounce otomatis agar tidak membebani API saat mengetik.
  void onQueryChanged(String query) {
    _currentQuery = query;
    _debounceTimer?.cancel();

    if (query.trim().isEmpty) {
      clearResults();
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      searchCity(query);
    });
  }

  /// Melakukan request pencarian langsung ke Geocoding API Open-Meteo.
  Future<void> searchCity(String query) async {
    final cleanQuery = query.trim();
    if (cleanQuery.isEmpty) {
      clearResults();
      return;
    }

    _state = SearchUiState.loading;
    _errorMessage = '';
    notifyListeners();

    try {
      final results = await _apiService.searchLocations(cleanQuery);
      if (results.isEmpty) {
        _state = SearchUiState.empty;
        _searchResults = [];
      } else {
        _searchResults = results;
        _state = SearchUiState.success;
      }
    } on SocketException catch (e) {
      _state = SearchUiState.error;
      _errorMessage = e.message;
    } on TimeoutException catch (e) {
      _state = SearchUiState.error;
      _errorMessage = e.message ?? 'Pencarian waktu habis.';
    } catch (e) {
      _state = SearchUiState.error;
      _errorMessage = 'Gagal mencari lokasi: ${e.toString()}';
    } finally {
      notifyListeners();
    }
  }

  /// Membersihkan input dan hasil pencarian.
  void clearResults() {
    _searchResults = [];
    _state = SearchUiState.idle;
    _errorMessage = '';
    _currentQuery = '';
    notifyListeners();
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
}
