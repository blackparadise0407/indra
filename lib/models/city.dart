import 'package:indra/models/coordinate.dart';

class City {
  final int id;
  final String name;
  final Coordinate coord;
  final String country;
  final num timezone;
  final num sunrise;
  final num sunset;

  City({
    required this.id,
    required this.coord,
    required this.name,
    required this.timezone,
    required this.sunrise,
    required this.sunset,
    required this.country,
  });

  factory City.fromJson(Map<String, dynamic> json) {
    return City(
      id: json['id'],
      coord: Coordinate.fromJson(json['coord']),
      name: json['name'],
      timezone: json['timezone'],
      sunrise: json['sunrise'],
      sunset: json['sunset'],
      country: json['country'],
    );
  }
}
