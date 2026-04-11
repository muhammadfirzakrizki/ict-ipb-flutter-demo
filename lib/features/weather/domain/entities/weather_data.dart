import 'package:equatable/equatable.dart';

class WeatherData extends Equatable {
  final double temperatureC;
  final double humidity;
  final double windSpeedKmh;
  final double pressureMb; // Tambahkan ini
  final int weatherCode;
  final bool isDay;

  const WeatherData({
    required this.temperatureC,
    required this.humidity,
    required this.windSpeedKmh,
    required this.pressureMb, // Tambahkan ini
    required this.weatherCode,
    required this.isDay,
  });

  factory WeatherData.fromJson(Map<String, dynamic> json) {
    final current = (json['current'] as Map<String, dynamic>?) ?? {};
    return WeatherData(
      temperatureC: (current['temperature_2m'] as num?)?.toDouble() ?? 0,
      humidity: (current['relative_humidity_2m'] as num?)?.toDouble() ?? 0,
      windSpeedKmh: (current['wind_speed_10m'] as num?)?.toDouble() ?? 0,
      pressureMb: (current['surface_pressure'] as num?)?.toDouble() ?? 0,
      weatherCode: (current['weather_code'] as num?)?.toInt() ?? -1,
      isDay: ((current['is_day'] as num?)?.toInt() ?? 1) == 1,
    );
  }

  String get weatherDescription {
    switch (weatherCode) {
      case 0:
        return 'Clear';
      case 1:
      case 2:
      case 3:
        return 'Cloudy';
      case 45:
      case 48:
        return 'Fog';
      case 51:
      case 53:
      case 55:
        return 'Drizzle';
      case 61:
      case 63:
      case 65:
        return 'Rain';
      case 80:
      case 81:
      case 82:
        return 'Heavy Rain';
      case 95:
      case 96:
      case 99:
        return 'Thunderstorm';
      default:
        return 'Unknown weather';
    }
  }

  @override
  List<Object?> get props => [
        temperatureC,
        humidity,
        windSpeedKmh,
        pressureMb, // Masukkan ke props
        weatherCode,
        isDay,
      ];
}
