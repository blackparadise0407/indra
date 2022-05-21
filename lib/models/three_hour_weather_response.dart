import 'package:indra/models/city.dart';
import 'package:indra/models/weather_response.dart';

class ThreeHourWeatherResponse {
  final List<WeatherResponse> list;
  final City city;

  const ThreeHourWeatherResponse({
    required this.city,
    required this.list,
  });

  factory ThreeHourWeatherResponse.fromJson(Map<String, dynamic> json) {
    var list = json['list'] as List;
    List<WeatherResponse> listWeatherResponse =
        list.map((w) => WeatherResponse.fromJson(w)).toList();
    return ThreeHourWeatherResponse(
      list: listWeatherResponse,
      city: City.fromJson(json['city']),
    );
  }
}
