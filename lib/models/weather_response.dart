class WeatherResponse {
  final int? id;
  final String? main;
  final String? description;
  final String? icon;
  final int? lon;
  final int? lat;
  final double? temp;
  final double? feelsLike;
  final double? tempMin;
  final double? tempMax;
  final int? pressure;
  final int? humidity;
  final int? seaLevel;
  final int? grndLevel;
  final String? country;
  final double? sunrise;
  final double? sunset;
  final String? name;

  const WeatherResponse({
    required this.id,
    required this.country,
    required this.description,
    required this.feelsLike,
    required this.grndLevel,
    required this.humidity,
    required this.icon,
    required this.lat,
    required this.lon,
    required this.main,
    required this.name,
    required this.seaLevel,
    required this.pressure,
    required this.sunrise,
    required this.sunset,
    required this.temp,
    required this.tempMax,
    required this.tempMin,
  });

  factory WeatherResponse.fromJson(Map<String, dynamic> json) {
    return WeatherResponse(
      id: json['weather'][0]['id'],
      country: json['sys']['country'],
      description: json['weather'][0]['description'],
      feelsLike: json['main']['feels_like'],
      grndLevel: json['main']['grnd_level'],
      humidity: json['main']['humidity'],
      icon: json['weather'][0]['icon'],
      lat: json['coord']['lat'],
      lon: json['coord']['lon'],
      main: json['weather'][0]['main'],
      name: json['name'],
      seaLevel: json['main']['sea_level'],
      pressure: json['main']['pressure'],
      sunrise: json['sys']['sunrise'],
      sunset: json['sys']['sunset'],
      temp: json['main']['temp'],
      tempMax: json['main']['temp_max'],
      tempMin: json['main']['temp_min'],
    );
  }
}
