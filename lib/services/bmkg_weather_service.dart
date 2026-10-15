import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
// ignore: avoid_web_libraries_in_flutter
import 'dart:html' as html;

class BmkgWeatherData {
  final double temperature;
  final int humidity;
  final double windSpeed;
  final String condition;
  final String location;
  final String recommendation;
  final bool isLive;
  final DateTime updatedAt;

  BmkgWeatherData({
    required this.temperature,
    required this.humidity,
    required this.windSpeed,
    required this.condition,
    required this.location,
    required this.recommendation,
    this.isLive = true,
    required this.updatedAt,
  });

  factory BmkgWeatherData.fallback({String location = 'Bandung, Jawa Barat'}) {
    return BmkgWeatherData(
      temperature: 27.5,
      humidity: 76,
      windSpeed: 8.5,
      condition: 'Cerah Berawan',
      location: location,
      recommendation: 'Cuaca optimal untuk penyiraman pagi dan pemupukan.',
      isLive: false,
      updatedAt: DateTime.now(),
    );
  }
}

class BmkgWeatherService {
  // BMKG / Open-Meteo Indonesia Coordinates for Major Agricultural Regions
  static const Map<String, Map<String, double>> cityCoordinates = {
    '📍 Lokasi Saya (GPS)': {'lat': -6.9175, 'lon': 107.6191},
    'Bandung, Jawa Barat': {'lat': -6.9175, 'lon': 107.6191},
    'Lembang, Jawa Barat': {'lat': -6.8167, 'lon': 107.6167},
    'Garut, Jawa Barat': {'lat': -7.2278, 'lon': 107.9086},
    'Jakarta Selatan': {'lat': -6.2615, 'lon': 106.8106},
    'Surabaya, Jawa Timur': {'lat': -7.2575, 'lon': 112.7521},
  };

  /// Automatically detects user's GPS coordinates and fetches live BMKG weather
  static Future<BmkgWeatherData> fetchWeatherFromGps() async {
    if (kIsWeb) {
      try {
        final position = await html.window.navigator.geolocation.getCurrentPosition(
          enableHighAccuracy: true,
          timeout: const Duration(seconds: 5),
        );

        final lat = position.coords?.latitude?.toDouble();
        final lon = position.coords?.longitude?.toDouble();

        if (lat != null && lon != null) {
          return fetchWeatherByCoordinates(lat: lat, lon: lon, locationName: '📍 Lokasi Saya (GPS)');
        }
      } catch (e) {
        debugPrint('GPS Geolocation Error / Permission Denied: $e');
      }
    }
    // Default to Bandung if GPS unavailable or denied
    return fetchLiveWeather(location: 'Bandung, Jawa Barat');
  }

  /// Fetches weather by exact latitude and longitude coordinates
  static Future<BmkgWeatherData> fetchWeatherByCoordinates({
    required double lat,
    required double lon,
    required String locationName,
  }) async {
    try {
      final url =
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m&timezone=Asia%2FJakarta';

      if (kIsWeb) {
        final responseText = await html.HttpRequest.getString(url).timeout(const Duration(seconds: 6));
        final data = json.decode(responseText);
        final current = data['current'];

        final double temp = (current['temperature_2m'] as num).toDouble();
        final int humidity = (current['relative_humidity_2m'] as num).toInt();
        final double wind = (current['wind_speed_10m'] as num).toDouble();
        final int weatherCode = (current['weather_code'] as num).toInt();

        final condition = _mapWeatherCodeToCondition(weatherCode);
        final recommendation = _generateFarmingRecommendation(condition, temp, humidity);

        return BmkgWeatherData(
          temperature: temp,
          humidity: humidity,
          windSpeed: wind,
          condition: condition,
          location: locationName,
          recommendation: recommendation,
          isLive: true,
          updatedAt: DateTime.now(),
        );
      }
    } catch (e) {
      debugPrint('Error fetching BMKG weather API by coords: $e');
    }

    return BmkgWeatherData.fallback(location: locationName);
  }

  /// Fetches Real Live BMKG Weather Data for the specified region name
  static Future<BmkgWeatherData> fetchLiveWeather({String location = '📍 Lokasi Saya (GPS)'}) async {
    if (location == '📍 Lokasi Saya (GPS)') {
      return fetchWeatherFromGps();
    }

    final coords = cityCoordinates[location] ?? cityCoordinates['Bandung, Jawa Barat']!;
    final lat = coords['lat']!;
    final lon = coords['lon']!;

    return fetchWeatherByCoordinates(lat: lat, lon: lon, locationName: location);
  }

  /// Convert BMKG WMO Weather Codes to Indonesian Weather Conditions
  static String _mapWeatherCodeToCondition(int code) {
    if (code == 0) return 'Cerah';
    if (code >= 1 && code <= 3) return 'Cerah Berawan';
    if (code >= 45 && code <= 48) return 'Berabut / Kabut';
    if (code >= 51 && code <= 67) return 'Hujan Ringan';
    if (code >= 80 && code <= 82) return 'Hujan Sedang';
    if (code >= 95) return 'Hujan Petir';
    return 'Cerah Berawan';
  }

  /// Generate Agricultural Recommendation based on BMKG weather
  static String _generateFarmingRecommendation(String condition, double temp, int humidity) {
    if (condition.contains('Hujan')) {
      return 'Siapkan drainase lahan dan tunda penyemprotan pupuk hingga hujan reda.';
    } else if (temp > 30) {
      return 'Suhu agak tinggi. Tingkatkan frekuensi penyiraman tanaman pagi & sore.';
    } else if (humidity > 80) {
      return 'Kelembapan tinggi. Waspada potensi jamur dan bercak daun.';
    } else {
      return 'Kondisi cuaca sangat optimal untuk penyiraman dan aktivitas pertanian.';
    }
  }
}
