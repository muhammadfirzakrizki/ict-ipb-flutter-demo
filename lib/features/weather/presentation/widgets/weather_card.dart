import 'package:flutter/material.dart';

import '../../../../core/l10n/app_localization.dart';
import '../../domain/entities/weather_data.dart';
import '../../domain/weather_state.dart';

class WeatherCard extends StatelessWidget {
  const WeatherCard({
    super.key,
    required this.state,
    required this.colorScheme,
  });

  final WeatherState state;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    if (state.weather == null) {
      return EmptyWeatherCard(colorScheme: colorScheme);
    }

    final weather = state.weather!;
    return Container(
      padding: const EdgeInsets.all(28),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: colorScheme.primary.withValues(alpha: 0.08),
            blurRadius: 30,
            offset: const Offset(0, 15),
          ),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    state.selectedLocation?.label.split(',')[0] ?? '',
                    style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      color: colorScheme.primary,
                    ),
                  ),
                  Text(
                    context.tr('current_condition'),
                    style: const TextStyle(
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              WeatherBadge(weather: weather, colorScheme: colorScheme),
            ],
          ),
          const SizedBox(height: 35),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                weather.temperatureC.toStringAsFixed(0),
                style: TextStyle(
                  fontSize: 100,
                  fontWeight: FontWeight.w900,
                  color: colorScheme.primary,
                  height: 1,
                  letterSpacing: -5,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 15),
                child: Text(
                  '°',
                  style: TextStyle(
                    fontSize: 40,
                    fontWeight: FontWeight.bold,
                    color: colorScheme.secondary,
                  ),
                ),
              ),
            ],
          ),
          Text(
            _localizedWeatherDescription(
              context,
              weather.weatherDescription,
            ).toUpperCase(),
            style: TextStyle(
              letterSpacing: 4,
              fontWeight: FontWeight.w900,
              color: colorScheme.secondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 35),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20),
            decoration: BoxDecoration(
              color: colorScheme.primary.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                WeatherDetail(
                  icon: Icons.water_drop_rounded,
                  value: '${weather.humidity}%',
                  label: 'RH',
                  color: Colors.blue,
                ),
                WeatherDetail(
                  icon: Icons.air_rounded,
                  value: weather.windSpeedKmh.toStringAsFixed(1),
                  label: 'KM/H',
                  color: Colors.teal,
                ),
                WeatherDetail(
                  icon: Icons.speed_rounded,
                  value: weather.pressureMb.toStringAsFixed(0),
                  label: 'HPA',
                  color: Colors.orange,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _localizedWeatherDescription(
    BuildContext context,
    String description,
  ) {
    if (Localizations.localeOf(context).languageCode != 'id') {
      return description;
    }

    const translated = {
      'sunny': 'Cerah',
      'clear': 'Cerah',
      'partly cloudy': 'Cerah Berawan',
      'cloudy': 'Berawan',
      'overcast': 'Mendung',
      'mist': 'Berkabut',
      'fog': 'Kabut',
      'freezing fog': 'Kabut Beku',
      'rain': 'Hujan',
      'patchy rain possible': 'Kemungkinan Hujan Lokal',
      'light rain': 'Hujan Ringan',
      'moderate rain': 'Hujan Sedang',
      'heavy rain': 'Hujan Lebat',
      'light drizzle': 'Gerimis Ringan',
      'drizzle': 'Gerimis',
      'thunderstorm': 'Badai Petir',
      'thundery outbreaks possible': 'Potensi Badai Petir',
      'patchy light rain with thunder': 'Hujan Ringan Petir Lokal',
      'moderate or heavy rain with thunder': 'Hujan Petir Sedang Hingga Lebat',
      'patchy snow possible': 'Kemungkinan Salju Lokal',
      'light snow': 'Salju Ringan',
      'moderate snow': 'Salju Sedang',
      'heavy snow': 'Salju Lebat',
      'unknown weather': 'Cuaca Tidak Diketahui',
    };

    final key = description.trim().toLowerCase();
    return translated[key] ?? description;
  }
}

class WeatherBadge extends StatelessWidget {
  const WeatherBadge({
    super.key,
    required this.weather,
    required this.colorScheme,
  });

  final WeatherData weather;
  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: colorScheme.secondary.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Icon(
            weather.isDay ? Icons.wb_sunny_rounded : Icons.nightlight_round,
            color: colorScheme.secondary,
            size: 18,
          ),
          const SizedBox(width: 6),
          Text(
            weather.isDay ? context.tr('day') : context.tr('night'),
            style: TextStyle(
              color: colorScheme.secondary,
              fontWeight: FontWeight.w800,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class WeatherDetail extends StatelessWidget {
  const WeatherDetail({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String value;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Icon(icon, size: 24, color: color),
        const SizedBox(height: 8),
        Text(
          value,
          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16),
        ),
        Text(
          label,
          style: const TextStyle(
            color: Colors.grey,
            fontSize: 10,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

class EmptyWeatherCard extends StatelessWidget {
  const EmptyWeatherCard({
    super.key,
    required this.colorScheme,
  });

  final ColorScheme colorScheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(32),
      ),
      child: Column(
        children: [
          const Icon(Icons.location_on_outlined, size: 50, color: Colors.grey),
          const SizedBox(height: 10),
          Text(
            context.tr('search_empty'),
            style: const TextStyle(
              color: Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
