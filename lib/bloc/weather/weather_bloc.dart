import 'package:flutter_bloc/flutter_bloc.dart';
import 'weather_event.dart';
import 'weather_state.dart';
import '../../services/weather_service.dart';

class WeatherBloc extends Bloc<WeatherEvent, WeatherState> {
  final WeatherService weatherService;
  int _searchToken = 0;

  WeatherBloc({required this.weatherService}) : super(const WeatherState()) {
    on<WeatherQueryChanged>(_onQueryChanged);
    on<WeatherLocationSelected>(_onLocationSelected);
  }

  Future<void> _onQueryChanged(
    WeatherQueryChanged event,
    Emitter<WeatherState> emit,
  ) async {
    final currentToken = ++_searchToken;
    final query = event.query.trim();
    emit(state.copyWith(query: event.query, clearError: true));

    if (query.isEmpty || query.length < 2) {
      emit(state.copyWith(
        isLoadingSuggestions: false,
        suggestions: const [],
      ));
      return;
    }

    if (state.selectedLocation != null &&
        query == state.selectedLocation!.label) {
      emit(state.copyWith(suggestions: const []));
      return;
    }

    try {
      emit(state.copyWith(isLoadingSuggestions: true));
      final suggestions = await weatherService.searchLocations(query);
      if (currentToken != _searchToken) {
        return;
      }
      emit(state.copyWith(
        isLoadingSuggestions: false,
        suggestions: suggestions,
      ));
    } catch (_) {
      emit(state.copyWith(
        isLoadingSuggestions: false,
        suggestions: const [],
        errorMessage: 'Gagal mencari wilayah',
      ));
    }
  }

  Future<void> _onLocationSelected(
    WeatherLocationSelected event,
    Emitter<WeatherState> emit,
  ) async {
    try {
      emit(state.copyWith(
        selectedLocation: event.location,
        isLoadingWeather: true,
        query: event.location.label,
        suggestions: const [],
        clearError: true,
      ));
      final weather = await weatherService.fetchCurrentWeather(event.location);
      emit(state.copyWith(
        isLoadingWeather: false,
        weather: weather,
      ));
    } catch (_) {
      emit(state.copyWith(
        isLoadingWeather: false,
        errorMessage: 'Gagal mengambil cuaca wilayah terpilih',
      ));
    }
  }
}
