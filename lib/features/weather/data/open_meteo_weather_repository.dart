import '../domain/entities/location_option.dart';
import '../domain/entities/weather_data.dart';
import 'datasources/weather_service.dart';
import '../domain/weather_repository.dart';

class OpenMeteoWeatherRepository implements WeatherRepository {
  OpenMeteoWeatherRepository(this._weatherService);

  final WeatherService _weatherService;

  @override
  Future<List<LocationOption>> searchLocations(String query) {
    return _weatherService.searchLocations(query);
  }

  @override
  Future<WeatherData> fetchCurrentWeather(LocationOption location) {
    return _weatherService.fetchCurrentWeather(location);
  }
}
