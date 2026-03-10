import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/location_option.dart';
import '../models/weather_data.dart';

class WeatherService {
  Future<List<LocationOption>> searchLocations(String query) async {
    final uri = Uri.https(
      'geocoding-api.open-meteo.com',
      '/v1/search',
      {
        'name': query,
        'count': '8',
        'language': 'id',
        'format': 'json',
      },
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Gagal mencari wilayah');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    final results = (data['results'] as List<dynamic>?) ?? [];
    return results
        .map((item) => LocationOption.fromJson(item as Map<String, dynamic>))
        .toList();
  }

  Future<WeatherData> fetchCurrentWeather(LocationOption location) async {
    final uri = Uri.https(
      'api.open-meteo.com',
      '/v1/forecast',
      {
        'latitude': location.latitude.toString(),
        'longitude': location.longitude.toString(),
        'current':
            'temperature_2m,relative_humidity_2m,wind_speed_10m,weather_code,is_day',
        'timezone': 'auto',
      },
    );

    final response = await http.get(uri);
    if (response.statusCode != 200) {
      throw Exception('Gagal mengambil data cuaca');
    }

    final data = jsonDecode(response.body) as Map<String, dynamic>;
    return WeatherData.fromJson(data);
  }
}
