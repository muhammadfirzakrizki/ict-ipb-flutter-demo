import 'package:equatable/equatable.dart';

import 'entities/location_option.dart';
import 'entities/weather_data.dart';

class WeatherState extends Equatable {
  const WeatherState({
    this.isLoadingSuggestions = false,
    this.isLoadingWeather = false,
    this.suggestions = const [],
    this.selectedLocation,
    this.weather,
    this.query = '',
    this.errorMessage,
  });

  final bool isLoadingSuggestions;
  final bool isLoadingWeather;
  final List<LocationOption> suggestions;
  final LocationOption? selectedLocation;
  final WeatherData? weather;
  final String query;
  final String? errorMessage;

  WeatherState copyWith({
    bool? isLoadingSuggestions,
    bool? isLoadingWeather,
    List<LocationOption>? suggestions,
    LocationOption? selectedLocation,
    bool clearSelectedLocation = false,
    WeatherData? weather,
    bool clearWeather = false,
    String? query,
    String? errorMessage,
    bool clearError = false,
  }) {
    return WeatherState(
      isLoadingSuggestions: isLoadingSuggestions ?? this.isLoadingSuggestions,
      isLoadingWeather: isLoadingWeather ?? this.isLoadingWeather,
      suggestions: suggestions ?? this.suggestions,
      selectedLocation: clearSelectedLocation
          ? null
          : (selectedLocation ?? this.selectedLocation),
      weather: clearWeather ? null : (weather ?? this.weather),
      query: query ?? this.query,
      errorMessage: clearError ? null : (errorMessage ?? this.errorMessage),
    );
  }

  @override
  List<Object?> get props => [
    isLoadingSuggestions,
    isLoadingWeather,
    suggestions,
    selectedLocation,
    weather,
    query,
    errorMessage,
  ];
}
