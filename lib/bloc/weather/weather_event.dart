import 'package:equatable/equatable.dart';
import '../../models/location_option.dart';

abstract class WeatherEvent extends Equatable {
  const WeatherEvent();

  @override
  List<Object?> get props => [];
}

class WeatherQueryChanged extends WeatherEvent {
  final String query;

  const WeatherQueryChanged(this.query);

  @override
  List<Object?> get props => [query];
}

class WeatherLocationSelected extends WeatherEvent {
  final LocationOption location;

  const WeatherLocationSelected(this.location);

  @override
  List<Object?> get props => [location];
}
