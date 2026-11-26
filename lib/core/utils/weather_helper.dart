import 'package:flutter/material.dart';

/// Utilitas untuk memetakan kode cuaca WMO Open-Meteo dan memformat tanggal.
class WeatherHelper {
  WeatherHelper._();

  static const List<String> _dayNames = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
    'Sabtu',
    'Minggu',
  ];

  static const List<String> _monthNames = [
    'Jan',
    'Feb',
    'Mar',
    'Apr',
    'Mei',
    'Jun',
    'Jul',
    'Agu',
    'Sep',
    'Okt',
    'Nov',
    'Des',
  ];

  /// Mengembalikan deskripsi kondisi cuaca dalam bahasa Indonesia sesuai WMO code.
  static String getConditionLabel(int weatherCode) {
    switch (weatherCode) {
      case 0:
        return 'Cerah';
      case 1:
        return 'Cerah Berawan';
      case 2:
        return 'Berawan Sebagian';
      case 3:
        return 'Mendung';
      case 45:
      case 48:
        return 'Berkabut';
      case 51:
        return 'Gerimis Ringan';
      case 53:
        return 'Gerimis Sedang';
      case 55:
        return 'Gerimis Lebat';
      case 56:
      case 57:
        return 'Gerimis Beku';
      case 61:
        return 'Hujan Ringan';
      case 63:
        return 'Hujan Sedang';
      case 65:
        return 'Hujan Lebat';
      case 66:
      case 67:
        return 'Hujan Beku';
      case 71:
      case 73:
      case 75:
      case 77:
        return 'Salju';
      case 80:
        return 'Hujan Lokal Ringan';
      case 81:
        return 'Hujan Lokal Sedang';
      case 82:
        return 'Hujan Lokal Deras';
      case 85:
      case 86:
        return 'Hujan Salju';
      case 95:
        return 'Badai Petir';
      case 96:
      case 99:
        return 'Badai Petir & Hujan Es';
      default:
        return 'Cuaca Tidak Diketahui';
    }
  }

  /// Mengembalikan ikon Material yang merepresentasikan kode cuaca WMO.
  static IconData getConditionIcon(int weatherCode) {
    if (weatherCode == 0) {
      return Icons.wb_sunny_rounded;
    } else if (weatherCode == 1 || weatherCode == 2) {
      return Icons.wb_cloudy_rounded;
    } else if (weatherCode == 3) {
      return Icons.cloud_rounded;
    } else if (weatherCode == 45 || weatherCode == 48) {
      return Icons.foggy;
    } else if (weatherCode >= 51 && weatherCode <= 67) {
      return Icons.water_drop_rounded;
    } else if (weatherCode >= 71 && weatherCode <= 77 ||
        weatherCode == 85 ||
        weatherCode == 86) {
      return Icons.ac_unit_rounded;
    } else if (weatherCode >= 80 && weatherCode <= 82) {
      return Icons.grain_rounded;
    } else if (weatherCode >= 95) {
      return Icons.thunderstorm_rounded;
    }
    return Icons.cloud_queue_rounded;
  }

  /// Mengembalikan gradasi warna kartu utama sesuai kondisi cuaca terkini.
  static List<Color> getHeroGradient(int weatherCode) {
    if (weatherCode == 0 || weatherCode == 1) {
      return const [Color(0xFF1E88E5), Color(0xFF0D47A1)];
    } else if (weatherCode == 2 || weatherCode == 3 || weatherCode == 45 || weatherCode == 48) {
      return const [Color(0xFF546E7A), Color(0xFF263238)];
    } else if (weatherCode >= 51 && weatherCode <= 82) {
      return const [Color(0xFF283593), Color(0xFF1A237E)];
    } else if (weatherCode >= 95) {
      return const [Color(0xFF37474F), Color(0xFF1C262B)];
    }
    return const [Color(0xFF1565C0), Color(0xFF0D47A1)];
  }

  /// Memformat string tanggal ISO (yyyy-MM-dd) menjadi label hari yang mudah dibaca.
  static String formatForecastDate(String isoDate, {int index = -1}) {
    final parsed = DateTime.tryParse(isoDate);
    if (parsed == null) return isoDate;

    final datePart = '${parsed.day} ${_monthNames[parsed.month - 1]}';
    if (index == 0) {
      return 'Hari Ini • $datePart';
    }
    if (index == 1) {
      return 'Besok • $datePart';
    }

    final dayName = _dayNames[parsed.weekday - 1];
    return '$dayName • $datePart';
  }
}
