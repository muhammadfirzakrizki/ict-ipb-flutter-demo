import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/open_meteo_weather_repository.dart';
import '../data/datasources/weather_service.dart';
import '../domain/entities/location_option.dart';
import '../domain/weather_repository.dart';
import '../domain/weather_state.dart';

final weatherServiceProvider = Provider<WeatherService>((ref) {
  return WeatherService();
});

final weatherRepositoryProvider = Provider<WeatherRepository>((ref) {
  return OpenMeteoWeatherRepository(ref.watch(weatherServiceProvider));
});

final weatherControllerProvider =
    NotifierProvider.autoDispose<WeatherController, WeatherState>(
      WeatherController.new,
    );

class WeatherController extends Notifier<WeatherState> {
  late final WeatherRepository _weatherRepository;

  int _searchToken = 0;

  @override
  WeatherState build() {
    _weatherRepository = ref.watch(weatherRepositoryProvider);
    return const WeatherState();
  }

  Future<void> queryChanged(String value) async {
    final currentToken = ++_searchToken;
    final query = value.trim();

    state = state.copyWith(query: value, clearError: true);

    // ⛔ validasi awal
    if (query.isEmpty || query.length < 2) {
      state = state.copyWith(
        isLoadingSuggestions: false,
        suggestions: const [],
      );
      return;
    }

    // ⛔ prevent duplicate query
    if (state.selectedLocation != null &&
        query == state.selectedLocation!.label) {
      state = state.copyWith(suggestions: const []);
      return;
    }

    try {
      state = state.copyWith(isLoadingSuggestions: true);

      final suggestions = await _weatherRepository.searchLocations(query);

      // 🔥 race condition guard
      if (currentToken != _searchToken) return;

      state = state.copyWith(
        isLoadingSuggestions: false,
        suggestions: suggestions,
      );
    } catch (e) {
      state = state.copyWith(
        isLoadingSuggestions: false,
        suggestions: const [],
        errorMessage: 'Gagal mencari wilayah',
      );
    }
  }

  Future<void> locationSelected(LocationOption location) async {
    try {
      state = state.copyWith(
        selectedLocation: location,
        isLoadingWeather: true,
        query: location.label,
        suggestions: const [],
        clearError: true,
      );

      final weather = await _weatherRepository.fetchCurrentWeather(location);

      state = state.copyWith(isLoadingWeather: false, weather: weather);
    } catch (e) {
      state = state.copyWith(
        isLoadingWeather: false,
        errorMessage: 'Gagal mengambil cuaca wilayah terpilih',
      );
    }
  }
}
