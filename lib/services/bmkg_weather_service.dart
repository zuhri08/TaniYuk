import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

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

  factory BmkgWeatherData.fallback({String location = 'Surabaya, Jawa Timur'}) {
    return BmkgWeatherData(
      temperature: 28.0,
      humidity: 75,
      windSpeed: 9.0,
      condition: 'Cerah Berawan',
      location: location,
      recommendation: 'Cuaca optimal untuk penyiraman pagi dan pemupukan.',
      isLive: false,
      updatedAt: DateTime.now(),
    );
  }
}

class BmkgWeatherService {
  static const Map<String, Map<String, double>> cityCoordinates = {
    '📍 Lokasi Saya (GPS)': {'lat': -7.2575, 'lon': 112.7521},
    'Surabaya, Jawa Timur': {'lat': -7.2575, 'lon': 112.7521},
    'Bandung, Jawa Barat': {'lat': -6.9175, 'lon': 107.6191},
    'Lembang, Jawa Barat': {'lat': -6.8167, 'lon': 107.6167},
    'Garut, Jawa Barat': {'lat': -7.2278, 'lon': 107.9086},
    'Jakarta Selatan': {'lat': -6.2615, 'lon': 106.8106},
  };

  static Future<BmkgWeatherData> fetchWeatherFromGps() async {
    return fetchLiveWeather(location: 'Surabaya, Jawa Timur');
  }

  static Future<BmkgWeatherData> fetchWeatherByCoordinates({
    required double lat,
    required double lon,
    required String locationName,
  }) async {
    try {
      final url = Uri.parse(
          'https://api.open-meteo.com/v1/forecast?latitude=$lat&longitude=$lon&current=temperature_2m,relative_humidity_2m,weather_code,wind_speed_10m&timezone=Asia%2FJakarta');

      final response = await http.get(url).timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
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

  static Future<BmkgWeatherData> fetchLiveWeather({String location = '📍 Lokasi Saya (GPS)'}) async {
    if (location == '📍 Lokasi Saya (GPS)') {
      return fetchWeatherFromGps();
    }

    final coords = cityCoordinates[location] ?? cityCoordinates['Surabaya, Jawa Timur']!;
    final lat = coords['lat']!;
    final lon = coords['lon']!;

    return fetchWeatherByCoordinates(lat: lat, lon: lon, locationName: location);
  }

  static String _mapWeatherCodeToCondition(int code) {
    if (code == 0) return 'Cerah';
    if (code >= 1 && code <= 3) return 'Cerah Berawan';
    if (code >= 45 && code <= 48) return 'Berabut / Kabut';
    if (code >= 51 && code <= 67) return 'Hujan Ringan';
    if (code >= 80 && code <= 82) return 'Hujan Sedang';
    if (code >= 95) return 'Hujan Petir';
    return 'Cerah Berawan';
  }

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
