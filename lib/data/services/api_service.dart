import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../../core/constants/api_constants.dart';
import '../models/location_model.dart';
import '../models/weather_model.dart';

/// Service untuk menangani request HTTP ke Open-Meteo REST API.
class ApiService {
  final http.Client _client;

  ApiService({http.Client? client}) : _client = client ?? http.Client();

  /// Mengambil data cuaca berdasarkan koordinat latitude & longitude.
  Future<WeatherData> getForecast({
    required double latitude,
    required double longitude,
  }) async {
    final queryParams = {
      'latitude': latitude.toString(),
      'longitude': longitude.toString(),
      'current': ApiConstants.currentParameters,
      'daily': ApiConstants.dailyParameters,
      'timezone': ApiConstants.defaultTimezone,
      'forecast_days': ApiConstants.forecastDays.toString(),
    };

    final uri = Uri.parse(ApiConstants.forecastBaseUrl)
        .replace(queryParameters: queryParams);

    try {
      final response = await _client
          .get(uri)
          .timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        return WeatherData.fromJson(decoded);
      } else {
        throw HttpException(
          'Gagal mengambil cuaca dari server (HTTP ${response.statusCode})',
        );
      }
    } on SocketException {
      throw const SocketException('Tidak ada koneksi internet. Periksa jaringan Anda.');
    } on TimeoutException {
      throw TimeoutException('Koneksi waktu habis saat menghubungi server cuaca.');
    } catch (e) {
      rethrow;
    }
  }

  /// Mencari lokasi kota menggunakan Open-Meteo Geocoding API.
  Future<List<LocationModel>> searchLocations(String query) async {
    final trimmed = query.trim();
    if (trimmed.isEmpty) return [];

    final queryParams = {
      'name': trimmed,
      'count': ApiConstants.geocodingResultCount.toString(),
      'language': 'id',
      'format': 'json',
    };

    final uri = Uri.parse(ApiConstants.geocodingBaseUrl)
        .replace(queryParameters: queryParams);

    try {
      final response = await _client
          .get(uri)
          .timeout(ApiConstants.requestTimeout);

      if (response.statusCode == 200) {
        final decoded = jsonDecode(response.body) as Map<String, dynamic>;
        final results = decoded['results'] as List<dynamic>?;
        if (results == null || results.isEmpty) {
          return [];
        }
        return results
            .map((item) => LocationModel.fromJson(item as Map<String, dynamic>))
            .toList();
      } else {
        throw HttpException(
          'Gagal mencari lokasi (HTTP ${response.statusCode})',
        );
      }
    } on SocketException {
      throw const SocketException('Tidak ada koneksi internet saat mencari lokasi.');
    } on TimeoutException {
      throw TimeoutException('Koneksi pencarian lokasi waktu habis.');
    } catch (e) {
      rethrow;
    }
  }
}
