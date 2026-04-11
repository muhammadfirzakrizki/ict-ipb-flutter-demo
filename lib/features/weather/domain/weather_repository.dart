import 'entities/location_option.dart';
import 'entities/weather_data.dart';

abstract class WeatherRepository {
  Future<List<LocationOption>> searchLocations(String query);

  Future<WeatherData> fetchCurrentWeather(LocationOption location);
}
