import 'package:equatable/equatable.dart';

class LocationOption extends Equatable {
  final String name;
  final String? admin1;
  final String country;
  final double latitude;
  final double longitude;
  final String timezone;

  const LocationOption({
    required this.name,
    required this.country,
    required this.latitude,
    required this.longitude,
    required this.timezone,
    this.admin1,
  });

  factory LocationOption.fromJson(Map<String, dynamic> json) {
    return LocationOption(
      name: json['name'] as String? ?? '-',
      admin1: json['admin1'] as String?,
      country: json['country'] as String? ?? '-',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0,
      timezone: json['timezone'] as String? ?? 'auto',
    );
  }

  String get label {
    final region = (admin1 != null && admin1!.isNotEmpty) ? ', $admin1' : '';
    return '$name$region, $country';
  }

  @override
  List<Object?> get props => [name, admin1, country, latitude, longitude];
}
