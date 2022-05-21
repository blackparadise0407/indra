import 'package:indra/models/coordinate.dart';
import 'package:indra/models/main.dart';
import 'package:indra/models/sys.dart';
import 'package:indra/models/weather.dart';
import 'package:indra/models/wind.dart';

class WeatherResponse {
  final int? id;
  final Coordinate? coord;
  final String? name;
  final List<Weather> weather;
  final Wind wind;
  final Sys sys;
  final Main main;
  final int? dt;
  final int? visibility;

  const WeatherResponse({
    required this.id,
    required this.name,
    required this.weather,
    required this.wind,
    required this.coord,
    required this.sys,
    required this.main,
    required this.dt,
    required this.visibility,
  });

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    var weather = json['weather'] as List;

    List<Weather> weathers = weather.map((w) => Weather.fromJson(w)).toList();

    return WeatherResponse(
      id: json['id'],
      dt: json['dt'],
      coord: Coordinate.fromJson(json['coord']),
      name: json['name'],
      weather: weathers,
      wind: Wind.fromJson(json['wind']),
      sys: Sys.fromJson(json['sys']),
      main: Main.fromJson(json['main']),
      visibility: json['visibility'],
    );
  }
}
